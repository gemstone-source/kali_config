import Quickshell
import Quickshell.Wayland
import QtQuick

// Static anime wallpaper rotation. The image changes every five minutes;
// there are no moving effects or video playback.
Scope {
    id: root

    property int index: 0
    property string wallpaperRoot: Quickshell.env("HOME") + "/.local/share/riceshell/wallpapers/anime/"
    property var wallpapers: [
        "naruto-akatsuki.jpg",
        "sakamoto-days.png",
        "one-punch-man.png",
        "solo-leveling.png",
        "arcane.png"
    ]

    Timer {
        interval: 300000
        repeat: true
        running: true
        onTriggered: root.index = (root.index + 1) % root.wallpapers.length
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "rice-anime-wallpaper"
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            color: "#080808"

            Image {
                anchors.fill: parent
                source: root.wallpaperRoot + root.wallpapers[root.index]
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }
    }
}
