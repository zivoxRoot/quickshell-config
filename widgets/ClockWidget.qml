import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Shapes
import QtQuick.Layouts

import "../config"
import "../services/time"

// TODO: fix the height of this shit, it is not aligned right now

Variants {
  model: Quickshell.screens

  PanelWindow {
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    anchors { top: true; left: true }
    margins { top: 150; left: 150 }
    width: 400
    height: 70
    // color: "blue"
    color: "transparent"
    
    RowLayout {
      spacing: 5

      // Hours
      Text {
        text: Qt.formatTime(TimeService.time, "h")
        color: Config.md3.primary
        font.pixelSize: 66
        font.weight: 900
      }

      Text {
        text: ":"
        color: Config.md3.primary
        font.pixelSize: 66
        font.weight: 900
      }

      // Minutes
      Text {
        text: Qt.formatTime(TimeService.time, "mm")
        color: Config.md3.tertiary
        font.pixelSize: 66
        font.weight: 900
      }

      // AM / PM
      Text {
        text: Qt.formatTime(TimeService.time, "AP")
        color: Config.md3.tertiary
        font.pixelSize: 16
        Layout.alignment: Qt.AlignTop
        font.weight: 500
      }

      // Colorful separator
      Rectangle {
        color: Config.md3.tertiary
        Layout.fillHeight: true
        width: 4
      }

      // Date
      ColumnLayout {
        // Month
        Text {
          text: Qt.formatDateTime(TimeService.time, "MMMM")
          color: Config.md3.tertiary
          font.pixelSize: 16
          font.weight: 900
        }

        // Day number
        Text {
          text: Qt.formatDateTime(TimeService.time, "d")
          color: Config.md3.primary
          font.pixelSize: 16
          font.weight: 900
        }

        // Date text
        Text {
          text: Qt.formatDateTime(TimeService.time, "dddd")
          color: Config.md3.tertiary
          font.pixelSize: 16
          font.weight: 400
        }
      }

      // Push everything to the left
      Item {
        Layout.fillWidth: true
      }
    }
  }
}
