#include <QCoreApplication>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QGuiApplication>
#include <QHash>
#include <QPointer>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QAbstractListModel>
#include <QThread>
#include <QUrl>
#include <QStringList>
#include <utility>

class AudioScanner final : public QThread
{
    Q_OBJECT
public:
    explicit AudioScanner(QString rootPath, QObject *parent = nullptr)
        : QThread(parent), m_rootPath(std::move(rootPath)) {}

signals:
    void filesFound(const QStringList &paths);
    void scanFailed(const QString &message);

protected:
    void run() override
    {
        QDir root(m_rootPath);
        if (!root.exists()) {
            emit scanFailed(QStringLiteral("Selected folder does not exist."));
            return;
        }

        static const QSet<QString> audioExtensions = {
            QStringLiteral("mp3"), QStringLiteral("wav"), QStringLiteral("flac"),
            QStringLiteral("ogg"), QStringLiteral("oga"), QStringLiteral("opus"),
            QStringLiteral("m4a"), QStringLiteral("aac"), QStringLiteral("wma"),
            QStringLiteral("aiff"), QStringLiteral("aif"), QStringLiteral("ape"),
            QStringLiteral("alac"), QStringLiteral("mka")
        };

        QStringList paths;
        QDirIterator it(
            m_rootPath,
            QDir::Files | QDir::Readable | QDir::NoSymLinks,
            QDirIterator::Subdirectories
        );

        while (it.hasNext()) {
            if (isInterruptionRequested())
                return;

            const QString path = it.next();
            const QFileInfo info(path);
            if (!audioExtensions.contains(info.suffix().toLower()))
                continue;

            paths.append(QDir::cleanPath(info.absoluteFilePath()));
        }

        paths.sort(Qt::CaseInsensitive);
        emit filesFound(paths);
    }

private:
    QString m_rootPath;
};

class AudioLibraryModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl defaultFolderUrl READ defaultFolderUrl CONSTANT)
    Q_PROPERTY(QString rootFolder READ rootFolder NOTIFY rootFolderChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged)
    Q_PROPERTY(bool hasScanned READ hasScanned NOTIFY hasScannedChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
    enum Roles {
        PathRole = Qt::UserRole + 1,
        FileNameRole,
        ParentFolderRole
    };
    Q_ENUM(Roles)

    explicit AudioLibraryModel(QObject *parent = nullptr)
        : QAbstractListModel(parent)
    {
        const QString home = QDir::homePath();
        const QString music = QDir(home).filePath(QStringLiteral("Music"));
        const QString musics = QDir(home).filePath(QStringLiteral("Musics"));

        m_defaultFolder = QDir(music).exists() ? music : musics;
    }

    ~AudioLibraryModel() override
    {
        if (m_scanner) {
            m_scanner->requestInterruption();
            m_scanner->wait();
            delete m_scanner;
            m_scanner = nullptr;
        }
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent)
        return m_files.size();
    }

    QVariant data(const QModelIndex &index, int role) const override
    {
        if (!index.isValid() || index.row() < 0 || index.row() >= m_files.size())
            return {};

        const QString &path = m_files.at(index.row());
        const QFileInfo info(path);

        switch (role) {
        case PathRole: return path;
        case FileNameRole: return info.fileName();
        case ParentFolderRole: return info.dir().dirName();
        default: return {};
        }
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return {
            {PathRole, "path"},
            {FileNameRole, "fileName"},
            {ParentFolderRole, "parentFolder"}
        };
    }

    QUrl defaultFolderUrl() const { return QUrl::fromLocalFile(m_defaultFolder); }
    QString rootFolder() const { return m_rootFolder; }
    bool scanning() const { return m_scanning; }
    bool hasScanned() const { return m_hasScanned; }
    int count() const { return m_files.size(); }
    QString errorMessage() const { return m_errorMessage; }

    Q_INVOKABLE void scanFolderUrl(const QUrl &url)
    {
        if (!url.isLocalFile()) {
            setError(QStringLiteral("Only local folders are supported."));
            return;
        }
        scanFolder(url.toLocalFile());
    }

    Q_INVOKABLE void scanFolder(const QString &folderPath)
    {
        if (m_scanner)
            return;

        const QString absolutePath = QDir(folderPath).absolutePath();
        if (!QDir(absolutePath).exists()) {
            setError(QStringLiteral("Selected folder does not exist."));
            return;
        }

        m_rootFolder = absolutePath;
        emit rootFolderChanged();
        setError(QString());
        setScanning(true);
        setHasScanned(false);

        beginResetModel();
        m_files.clear();
        endResetModel();
        emit countChanged();

        auto *scanner = new AudioScanner(absolutePath, this);
        m_scanner = scanner;

        connect(scanner, &AudioScanner::filesFound,
                this, &AudioLibraryModel::applyScanResult, Qt::QueuedConnection);
        connect(scanner, &AudioScanner::scanFailed,
                this, &AudioLibraryModel::setError, Qt::QueuedConnection);
        connect(scanner, &QThread::finished, this, [this, scanner]() {
            if (m_scanner == scanner)
                m_scanner = nullptr;
            setScanning(false);
            if (m_errorMessage.isEmpty())
                setHasScanned(true);
            scanner->deleteLater();
        }, Qt::QueuedConnection);

        scanner->start();
    }

signals:
    void rootFolderChanged();
    void scanningChanged();
    void hasScannedChanged();
    void countChanged();
    void errorMessageChanged();

private slots:
    void applyScanResult(const QStringList &paths)
    {
        beginResetModel();
        m_files = paths;
        endResetModel();
        emit countChanged();
    }

    void setError(const QString &message)
    {
        if (m_errorMessage == message)
            return;
        m_errorMessage = message;
        emit errorMessageChanged();
    }

private:
    void setScanning(bool value)
    {
        if (m_scanning == value)
            return;
        m_scanning = value;
        emit scanningChanged();
    }

    void setHasScanned(bool value)
    {
        if (m_hasScanned == value)
            return;
        m_hasScanned = value;
        emit hasScannedChanged();
    }

    QString m_defaultFolder;
    QString m_rootFolder;
    QStringList m_files;
    QString m_errorMessage;
    bool m_scanning = false;
    bool m_hasScanned = false;
    QPointer<AudioScanner> m_scanner;
};

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif

    QGuiApplication app(argc, argv);
    QQuickWindow::setDefaultAlphaBuffer(true);

    AudioLibraryModel audioLibrary;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("audioLibrary", &audioLibrary);
    engine.loadFromModule("echomp", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

#include "main.moc"
