import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../services/screenshot"

FocusScope {
  id: root
  implicitHeight: 420
  implicitWidth: 300

  property int focusedIndex: 1

  Keys.onPressed: event => {
    switch (event.key) {

    // Close with `escape`
    case Qt.Key_Escape:
      root.visible = false
      break

    // Move focus with `h/l` or `j/k` or `tab/shiftTab`
    case Qt.Key_L:
    case Qt.Key_J:
    case Qt.Key_Tab:
      root.focusedIndex = Math.min(focusedIndex + 1, 2)
      break

    case Qt.Key_H:
    case Qt.Key_K:
    case Qt.Key_Backtab:
      root.focusedIndex = Math.max(focusedIndex - 1, 0)
      break
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Config.md3.background
    radius: 14

    ColumnLayout {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 10
      spacing: 10

      // Top navigation buttons
      RowLayout {
        spacing: 3

        // Screen recording
        Rectangle {
          radius: focusedIndex == 0 ? height / 2 : 3
          topLeftRadius: height / 2
          bottomLeftRadius: height / 2
          color: focusedIndex == 0 ? Config.md3.primary : Config.md3.tertiary
          height: 30
          Layout.fillWidth: true

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Behavior on radius {
            NumberAnimation {
              duration: 150
              easing.type: Easing.InOutQuad
            }
          }

          Text {
            anchors.centerIn: parent
            text: "Recording"
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
        }

        // Screenshot
        Rectangle {
          radius: focusedIndex == 1 ? height / 2 : 3
          color: focusedIndex == 1 ? Config.md3.primary : Config.md3.tertiary
          height: 30
          Layout.fillWidth: true

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Behavior on radius {
            NumberAnimation {
              duration: 150
              easing.type: Easing.InOutQuad
            }
          }

          Text {
            anchors.centerIn: parent
            text: "Screenshot"
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
        }

        // Other
        Rectangle {
          radius: focusedIndex == 2 ? height / 2 : 3
          topRightRadius: height / 2
          bottomRightRadius: height / 2
          color: focusedIndex == 2 ? Config.md3.primary : Config.md3.tertiary
          height: 30
          Layout.fillWidth: true

          Behavior on color {
            ColorAnimation { duration: 150 }
          }

          Behavior on radius {
            NumberAnimation {
              duration: 150
              easing.type: Easing.InOutQuad
            }
          }

          Text {
            anchors.centerIn: parent
            text: "Other"
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
          }
        }
      }

      // Bottom block -> options for selected recording type
      Rectangle {
        Layout.fillWidth: true

        ScreenrecordingBlock {
          anchors.fill: parent
          visible: focusedIndex === 0
        }

        ScreenshotBlock {
          anchors.fill: parent
          visible: focusedIndex === 1
        }
      }
    }
  }
}
