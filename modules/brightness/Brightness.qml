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

  function refreshBrightness() {
    updateBrightness.running = false
    updateBrightness.running = true
  }

  // Attach to the udev for brightness
  Process {
    running: true
    command: ["udevadm", "monitor",  "--subsystem-match=backlight", "--udev"]
    stdout: SplitParser {
    onRead: {
      refreshBrightness()
      root.visible = true
      hideTimer.restart()
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
    interval: 1000
    onTriggered: root.visible = false
  }

  // Main window
  Rectangle {
    id: mainWindow
    anchors.fill: parent
    color: "transparent"
    radius: height / 4

    // Left block
    Rectangle {
      id: left
      anchors.left: parent.left
      height: root.height
      width: 2 * brightnessValue - 6
      color: "#1f222b"
      topLeftRadius: height / 4
      bottomLeftRadius: height / 4
    }

    // Central tile
    Rectangle {
      anchors.left: left.right
      anchors.right: right.left
      height: root.height
      color: "transparent"
      radius: height / 4

      Rectangle {
        height: root.height
        anchors.centerIn: parent
        width: parent.width - 6
        color: "#1f222b"
        radius: height / 2
      }
    }

    // Right block
    Rectangle {
      id: right
      anchors.right: parent.right
      height: root.height
      width: 200 - (2 * brightnessValue) - 6
      color: "#36393f"
      topRightRadius: height / 4
      bottomRightRadius: height / 4
    }
  }
}
