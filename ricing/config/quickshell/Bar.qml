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

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                Workspaces {
                    screen: modelData
                }

                ActiveWindow {
                    Layout.fillWidth: true
                }

                Media {}
                Tray { panel: bar }
                Stats {}
                Clock {}
            }
        }
    }
}
