import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 36

            Rectangle {
                anchors.fill: parent
                color: Colors.bgAlt
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14

                Workspaces {
                    id: workspaces
                    screen: modelData
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                ActiveWindow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, parent.width -
                        (2 * Math.max(workspaces.width, rightModules.width)) - 24)
                }

                Row {
                    id: rightModules
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Media {}
                    Tray { panel: bar }
                    Stats {}
                    Clock {}
                }
            }
        }
    }
}
