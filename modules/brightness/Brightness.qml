import Quickshell
import Quickshell.Io
import QtQuick

import "../../config"

PanelWindow {
  id: root
  color: "transparent"
  anchors { top: true }
  margins { top: 48 }
  visible: true
  implicitHeight: 30
  implicitWidth: 200
  exclusionMode: ExclusionMode.Ignore

  property int brightnessValue: 84

  // Attach to the udev for brightness
  Process {
    running: true
    command: ["sh", "-c", "udevadm monitor --subsystem-match=backlight --udev"]
    stdout: SplitParser {
    onRead: {
      updateBrightness.running = true
      root.visible = true
      hideTimer.running = true
    }
    }
  }

  // Read and update brightness
  Process {
    id: updateBrightness
    running: true
    command: ["sh", "-c", "brightnessctl -m"]
    stdout: StdioCollector {
      onStreamFinished: {
        let val = parseInt(this.text.split(",")[3].replace("%", ""))
        if (!isNaN(val)) 
          root.brightnessValue = val
      }
    }
  }

  // Hide after 2s
  Timer {
    id: hideTimer
    interval: 2000
    onTriggered: root.visible = false
  }

  // Main window
  Rectangle {
    id: mainWindow
    anchors.fill: parent
    color: "#36393f"
    radius: height / 2

    // Value window
    Rectangle {
      anchors.left: parent.left
      height: root.height
      width: (root.width / 100) * brightnessValue
      color: "#1f222b"
      radius: height / 2

      // Round textbox
      Rectangle {
        anchors.right: parent.right
        height: root.height
        width: root.height
        color: "#1b1e25"
        radius: height / 2

        Text {
          anchors.centerIn: parent
          text: root.brightnessValue
          color: Config.colFg
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
      }
    }
  }
}
