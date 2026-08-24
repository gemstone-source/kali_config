import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Text {
    id: root
    color: Colors.fgDim
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    Layout.rightMargin: 16

    property string _text: ""

    text: _text

    Process {
        id: proc
        command: ["sh", "-c", "~/.local/bin/rice-stats"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root._text = this.text.trim()
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
