import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../config"
import "../../services/time"

Rectangle {
  Layout.fillWidth: true
  Layout.fillHeight: true
  color: Config.md3.background

  ColumnLayout {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.verticalCenter
    Layout.alignment: Qt.AlignHCenter

    RowLayout {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 5

      // Hour
      Text {
        text: Qt.formatTime(Time.time, "h")
        color: Config.md3.primary
        font.pixelSize: 66
        font.weight: 900
      }

      Text {
        text: ":"
        color: Config.md3.tertiary
        font.pixelSize: 66
        font.weight: 900
      }

      // Minutes
      Text {
        text: Qt.formatTime(Time.time, "mm")
        color: Config.md3.primary
        font.pixelSize: 66
        font.weight: 900
      }

      // AM/PM
      Text {
        text: Qt.formatTime(Time.time, "AP")
        color: Config.md3.tertiary
        font.pixelSize: 66
        font.weight: 900
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(Time.time, "dddd, d MMMM yyyy")
      color: Config.md3.secondary
      font.pixelSize: 24
      font.weight: 600
      font.family: Config.fontFamily
    }
  }
}
