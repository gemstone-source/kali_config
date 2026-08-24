import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Row {
    id: root
    spacing: 10
    Layout.rightMargin: 16

    required property var panel

    function hideItem(item) {
        const title = String(item.title || "").toLowerCase()
        const icon = String(item.icon || "").toLowerCase()
        return title === "network" || title === "udiskie" ||
            icon === "drive-removable-media-usb-panel"
    }

    Repeater {
        model: SystemTray.items
        WrapperMouseArea {
            required property var modelData
            visible: !root.hideItem(modelData)
            implicitWidth: visible ? 22 : 0
            implicitHeight: visible ? 22 : 0
            margin: 2
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

            IconImage {
                source: modelData.icon
                implicitWidth: 18
                implicitHeight: 18
            }

            onClicked: function(event) {
                if (event.button === Qt.LeftButton) {
                    modelData.activate()
                } else if (event.button === Qt.MiddleButton) {
                    modelData.secondaryActivate()
                } else if (event.button === Qt.RightButton) {
                    const pos = mapToItem(root.panel.contentItem, event.x, event.y)
                    modelData.display(root.panel, Math.round(pos.x), Math.round(pos.y))
                }
            }

            onWheel: function(event) {
                modelData.scroll(event.angleDelta.y, false)
            }
        }
    }
}
