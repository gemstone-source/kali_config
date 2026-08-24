import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Text {
    id: root
    color: Colors.fg
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    horizontalAlignment: Text.AlignHCenter
    elide: Text.ElideRight
    Layout.fillWidth: true

    property string _text: ""

    text: _text

    Process {
        id: proc
        command: ["sh", "-c", "hyprctl activewindow -j 2>/dev/null | jq -r '.title // empty'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root._text = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
