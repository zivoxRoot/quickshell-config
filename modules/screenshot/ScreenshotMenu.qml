import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../components"
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

      ButtonList {
        buttons: ["Recording", "Screenshot", "Other"]
        focused: focusedIndex
        onClicked: index => focusedIndex = index
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
