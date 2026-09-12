import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

ApplicationWindow {
    id: root

    width: 1200
    height: 720
    minimumWidth: 900
    minimumHeight: 560
    visible: true
    title: "Music Player"
    color: "transparent"

    property color windowColor: "#CC17131F"
    property color topBarColor: "#D91B1127"
    property color panelColor: "#B5161420"
    property color selectedColor: "#7A33283A"
    property color hoverColor: "#421F1C27"
    property color textMain: "#E9E4EA"
    property color textSecondary: "#AAA2AE"
    property color textMuted: "#776F7B"
    property color accentColor: "#F1A331"
    property color borderColor: "#392C39"
    property color dividerColor: "#322734"
    property int detailsWidth: 320
    property int playerHeight: 62
    property int topBarHeight: 38
    property int selectedIndex: -1

    property bool libraryReady: audioLibrary.hasScanned && !audioLibrary.scanning

    function songValue(index, role, fallback) {
        if (index < 0 || index >= audioLibrary.rowCount())
            return fallback
        var value = audioLibrary.data(audioLibrary.index(index, 0), role)
        return value === undefined || value === null || value === "" ? fallback : value
    }

    function fileName(index) { return songValue(index, 258, ""); }
    function parentFolder(index) { return songValue(index, 259, ""); }
    function filePath(index) { return songValue(index, 257, ""); }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // ========================================================
        // FIRST PAGE — FOLDER SELECTION
        // ========================================================
        Rectangle {
            anchors.fill: parent
            visible: !root.libraryReady && !audioLibrary.scanning
            color: root.windowColor
            border.width: 1
            border.color: root.borderColor
            radius: 4

            Column {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 420)
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Your Music"
                    color: root.textMain
                    font.pixelSize: 21
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    text: "Select the folder that contains your music."
                    color: root.textSecondary
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    text: "Default: " + audioLibrary.defaultFolderUrl.toString().replace("file://", "")
                    color: root.textMuted
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }

                Item { width: 1; height: 5 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 170
                    height: 38
                    radius: 6
                    color: root.accentColor

                    Text {
                        anchors.centerIn: parent
                        text: "SELECT FOLDER"
                        color: "#1C1410"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: folderDialog.open()
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: audioLibrary.errorMessage.length > 0
                    text: audioLibrary.errorMessage
                    color: "#D97878"
                    font.pixelSize: 10
                }
            }
        }

        // ========================================================
        // SCANNING
        // ========================================================
        Rectangle {
            anchors.fill: parent
            visible: audioLibrary.scanning
            color: root.windowColor
            border.width: 1
            border.color: root.borderColor
            radius: 4

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Scanning Music"
                    color: root.textMain
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Searching audio files recursively..."
                    color: root.textMuted
                    font.pixelSize: 11
                }
            }
        }

        // ========================================================
        // MAIN UI — ORIGINAL STYLE
        // ========================================================
        Rectangle {
            anchors.fill: parent
            visible: root.libraryReady
            radius: 4
            color: root.windowColor
            border.width: 1
            border.color: root.borderColor
            clip: true

            // ====================================================
            // TOP BAR
            // ====================================================
            Rectangle {
                id: topBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: root.topBarHeight
                color: root.topBarColor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.fillHeight: true
                        color: menuMouse.containsMouse ? "#3A313C" : "transparent"
                        Text { anchors.centerIn: parent; text: "☰"; color: root.textSecondary; font.pixelSize: 15 }
                        MouseArea { id: menuMouse; anchors.fill: parent; hoverEnabled: true }
                    }

                    Rectangle { width: 1; Layout.fillHeight: true; color: root.borderColor }

                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.fillHeight: true
                        color: "#713A3D"
                        Text { anchors.centerIn: parent; text: "Default"; color: root.textMain; font.pixelSize: 12; font.bold: true }
                    }

                    Rectangle {
                        Layout.preferredWidth: 145
                        Layout.fillHeight: true
                        color: "transparent"
                        Text { anchors.centerIn: parent; text: "MEEPLEDGDON"; color: root.textMain; font.pixelSize: 12; font.bold: true }
                    }

                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.fillHeight: true
                        color: "transparent"
                        Text { anchors.centerIn: parent; text: "MENU"; color: root.textMuted; font.pixelSize: 12 }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 96
                        Layout.preferredHeight: 18
                        color: "#241C28"
                        border.width: 1
                        border.color: "#473441"

                        Row {
                            anchors.centerIn: parent
                            spacing: 2
                            Repeater {
                                model: 16
                                Rectangle {
                                    width: 5
                                    height: 6 + ((index * 13) % 10)
                                    color: index < 10 ? root.accentColor : "#5D7E34"
                                }
                            }
                        }
                    }

                    Item { width: 14 }
                    Text { text: "—"; color: root.textMuted; font.pixelSize: 15 }
                    Item { width: 10 }
                    Text { text: "□"; color: root.textMuted; font.pixelSize: 13 }
                    Item { width: 10 }
                    Text { text: "×"; color: root.textMuted; font.pixelSize: 17; rightPadding: 12 }
                }
            }

            // ====================================================
            // MAIN CONTENT
            // ====================================================
            RowLayout {
                id: mainContent
                anchors.top: topBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: playerBar.top
                spacing: 0

                // =================================================
                // LIBRARY / LIST
                // =================================================
                Rectangle {
                    id: libraryPanel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.panelColor

                    Rectangle {
                        id: tableHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 38
                        color: "#421C1922"
                        border.color: root.dividerColor
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 10
                            spacing: 0

                            Text { width: 190; anchors.verticalCenter: parent.verticalCenter; text: "Artist"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                            Text { width: 195; anchors.verticalCenter: parent.verticalCenter; text: "Title"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                            Text { width: 165; anchors.verticalCenter: parent.verticalCenter; text: "Album"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                            Text { width: 70; anchors.verticalCenter: parent.verticalCenter; text: "Date"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                            Text { width: 70; anchors.verticalCenter: parent.verticalCenter; text: "Codec"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                            Text { width: 60; anchors.verticalCenter: parent.verticalCenter; text: "Time"; color: root.textMain; font.pixelSize: 13; font.bold: true }
                        }
                    }

                    ListView {
                        id: songList
                        anchors.top: tableHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        model: audioLibrary
                        clip: true
                        spacing: 0
                        currentIndex: root.selectedIndex

                        delegate: Rectangle {
                            id: row
                            width: songList.width
                            height: 36
                            color: index === root.selectedIndex ? root.selectedColor : (rowMouse.containsMouse ? root.hoverColor : "transparent")

                            Behavior on color { ColorAnimation { duration: 80 } }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: index === root.selectedIndex ? 3 : 0
                                color: root.accentColor
                            }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 10
                                spacing: 0

                                Text {
                                    width: 190
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: parentFolder
                                    color: index === root.selectedIndex ? root.accentColor : root.textSecondary
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 195
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: fileName
                                    color: index === root.selectedIndex ? root.accentColor : root.textMain
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: 165
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: path
                                    color: index === root.selectedIndex ? root.accentColor : root.textSecondary
                                    font.pixelSize: 11
                                    elide: Text.ElideMiddle
                                }

                                Text { width: 70; anchors.verticalCenter: parent.verticalCenter; text: "—"; color: root.textMuted; font.pixelSize: 13 }

                                Text {
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: fileName.indexOf(".") >= 0 ? fileName.substring(fileName.lastIndexOf(".") + 1).toUpperCase() : "—"
                                    color: root.textSecondary
                                    font.pixelSize: 13
                                }

                                Text { width: 60; anchors.verticalCenter: parent.verticalCenter; text: "—"; color: root.textSecondary; font.pixelSize: 13 }
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1
                                color: root.dividerColor
                            }

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.selectedIndex = index
                                    songList.currentIndex = index
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            id: scrollBar
                            policy: ScrollBar.AsNeeded
                            width: 6
                            contentItem: Rectangle { implicitWidth: 6; radius: 3; color: root.textMuted; opacity: 0.45 }
                            background: null
                        }
                    }
                }

                Rectangle { id: splitter; Layout.preferredWidth: 2; Layout.fillHeight: true; color: root.dividerColor }

                // =================================================
                // DETAILS
                // =================================================
                Rectangle {
                    id: detailsPanel
                    Layout.preferredWidth: root.detailsWidth
                    Layout.fillHeight: true
                    color: "#9A191520"

                    Rectangle {
                        id: albumArt
                        anchors.top: parent.top
                        anchors.topMargin: 34
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(detailsPanel.width - 48, detailsPanel.height * 0.56)
                        height: width
                        color: "#09A7DC"
                        border.width: 1
                        border.color: "#5B6482"

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.58
                            height: parent.height * 0.58
                            radius: width / 2
                            color: "#1937A8"
                            border.width: 2
                            border.color: "#D6F2FF"
                            opacity: 0.9

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 0.62
                                height: parent.height * 0.76
                                radius: width / 2
                                color: "#7D55E8"
                                border.width: 2
                                border.color: "#BFF2FF"
                                opacity: 0.8
                            }
                        }

                        Text { anchors.centerIn: parent; text: "♫"; color: "#D9FFFF"; opacity: 0.72; font.pixelSize: 42; font.bold: true }
                    }

                    Column {
                        anchors.top: albumArt.bottom
                        anchors.topMargin: 24
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.selectedIndex >= 0 ? parentFolder(root.selectedIndex) : "No Folder"
                            color: root.textSecondary
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 30
                            text: root.selectedIndex >= 0 ? fileName(root.selectedIndex) : "Select a song"
                            color: root.textMain
                            font.pixelSize: 20
                            font.bold: true
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 30
                            text: root.selectedIndex >= 0 ? filePath(root.selectedIndex) : "No file selected"
                            color: root.textMuted
                            font.pixelSize: 10
                            elide: Text.ElideMiddle
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // ====================================================
            // PLAYER BAR
            // ====================================================
            Rectangle {
                id: playerBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: root.playerHeight
                color: "#C01A1622"
                border.color: root.borderColor
                border.width: 1

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: parent.width * 0.31
                    height: 3
                    color: root.accentColor
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 16
                    spacing: 16

                    Text { text: "▶"; color: root.textMain; font.pixelSize: 18; MouseArea { anchors.fill: parent } }
                    Text { text: "Ⅱ"; color: root.textMuted; font.pixelSize: 17; MouseArea { anchors.fill: parent } }
                    Text { text: "■"; color: root.textMuted; font.pixelSize: 15; MouseArea { anchors.fill: parent } }
                    Item { width: 14 }
                    Text { text: "◀◀"; color: root.textMuted; font.pixelSize: 13 }
                    Text { text: "▶▶"; color: root.textMuted; font.pixelSize: 13 }
                    Item { Layout.fillWidth: true }
                    Text { text: "↶"; color: root.textMuted; font.pixelSize: 20 }
                    Text { text: "⇄"; color: root.textMuted; font.pixelSize: 20 }
                    Text { text: "☷"; color: root.textMuted; font.pixelSize: 20 }
                    Text { text: "▰"; color: root.textMuted; font.pixelSize: 12 }

                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 5
                        radius: 2
                        color: "#35313A"
                        Rectangle { width: parent.width * 0.55; height: parent.height; radius: 2; color: root.textSecondary }
                    }

                    Text { text: "00:04"; color: root.accentColor; font.pixelSize: 12; font.bold: true; Layout.preferredWidth: 40 }
                }
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Select Music Folder"
        currentFolder: audioLibrary.defaultFolderUrl
        onAccepted: audioLibrary.scanFolderUrl(selectedFolder)
    }
}
