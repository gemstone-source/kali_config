import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    required property var screen
    readonly property var monitor: Hyprland.monitorFor(screen)
    spacing: 6

    Repeater {
        model: Hyprland.workspaces
        Rectangle {
            required property var modelData
            readonly property var ws: modelData
            visible: root.monitor && ws.monitor && ws.monitor.id === root.monitor.id && ws.toplevels.values.length > 0

            width: 22
            height: 22
            radius: 6
            color: ws.focused ? Colors.accent : Colors.bg
            border.width: 1
            border.color: ws.focused ? Colors.accent : (ws.active ? Colors.accent : Colors.border)

            Text {
                anchors.centerIn: parent
                text: ws.id > 0 ? ws.id.toString() : ws.name
                color: ws.focused ? Colors.accentFg : (ws.active ? Colors.fg : Colors.fgDim)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                font.bold: ws.focused
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ws.activate()
            }
        }
    }
}
