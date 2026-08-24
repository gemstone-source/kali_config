import Quickshell
import QtQuick

Text {
    color: Colors.fgDim
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 13
    text: Qt.formatDateTime(clock.date, "ddd MMM d  hh:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
