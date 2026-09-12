#include <QGuiApplication>
#include <QCoreApplication>
#include <QQuickWindow>
#include <QtGlobal>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QAbstractListModel>
#include <QHash>
#include <QVector>
#include <QByteArray>

class SongItem
{
public:
    QString title;
    QString artist;
    QString album;
    QString duration;
};

class SongListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum SongRoles {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        AlbumRole,
        DurationRole
    };

    explicit SongListModel(QObject *parent = nullptr)
        : QAbstractListModel(parent)
    {
        QVector<SongItem> songs = {
            {"Midnight City", "M83", "Hurry Up, We're Dreaming", "4:12"},
            {"Bohemian Rhapsody", "Queen", "A Night at the Opera", "5:54"},
            {"Someone Like You", "Adele", "21", "4:45"},
            {"Shape of You", "Ed Sheeran", "÷", "3:53"},
            {"Dreams", "Fleetwood Mac", "Rumours", "4:32"},
            {"Rolling in the Deep", "Adele", "21", "3:48"},
            {"Stay", "The Kid LAROI & Justin Bieber", "F*CK LOVE 3: OVER YOU", "2:21"},
            {"Sunflower", "Post Malone & Swae Lee", "Spider-Man: Into the Spider-Verse", "2:38"},
            {"Perfect", "Ed Sheeran", "÷", "4:23"},
            {"Yellow", "Coldplay", "Parachutes", "4:29"},
            {"Levitating", "Dua Lipa", "Future Nostalgia", "3:23"},
            {"Blinding Lights", "The Weeknd", "After Hours", "3:20"},
            {"Flowers", "Miley Cyrus", "Endless Summer Vacation", "3:20"},
            {"As It Was", "Harry Styles", "Harry's House", "2:47"},
            {"Take on Me", "a-ha", "Hunting High and Low", "3:46"}
        };

        for (const SongItem &song : songs)
            m_songs.append(song);
    }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override
    {
        Q_UNUSED(parent)
        return m_songs.size();
    }

    QVariant data(const QModelIndex &index, int role) const override
    {
        if (!index.isValid() || index.row() < 0 || index.row() >= m_songs.size())
            return {};

        const SongItem &song = m_songs.at(index.row());

        switch (role) {
        case TitleRole:
            return song.title;
        case ArtistRole:
            return song.artist;
        case AlbumRole:
            return song.album;
        case DurationRole:
            return song.duration;
        default:
            return {};
        }
    }

    QHash<int, QByteArray> roleNames() const override
    {
        return {
            {TitleRole, "title"},
            {ArtistRole, "artist"},
            {AlbumRole, "album"},
            {DurationRole, "duration"}
        };
    }

private:
    QVector<SongItem> m_songs;
};

int main(int argc, char *argv[])
{
    // Enable high-DPI scaling and pixmaps before creating the app
    // AA_EnableHighDpiScaling / AA_UseHighDpiPixmaps were removed/changed in Qt6,
    // so only set them for Qt5 to avoid build errors on Qt6.
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif

    QGuiApplication app(argc, argv);

    // Enable alpha buffer so windows can be transparent and let the compositor
    // apply blur/translucency on Wayland (hyprland) if available.
    QQuickWindow::setDefaultAlphaBuffer(true);

    SongListModel songModel;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("songModel", &songModel);
    engine.loadFromModule("echomp", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

#include "main.moc"
