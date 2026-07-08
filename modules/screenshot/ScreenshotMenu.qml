import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell.Widgets

import "../../config"

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

  function launchCommand(command) {
    visible = false

    switch (command) {
    case "screenshot_fullscreen":
      screenshot_fullscreen.running = true
      break
    case "screenshot_window":
      screenshot_window.running = true
      break
    case "screenshot_region":
      screenshot_region.running = true
      break
    }
  }

  property bool freeze: false
  readonly property list<string> hyprshot_args: ["hyprshot", "--output-folder", Quickshell.env("HOME") + "/Pictures/Screenshots", freeze ? "--freeze" : ""]

  Process {
    id: screenshot_fullscreen
    running: false
    command: [...hyprshot_args, "--mode", "output"]
  }

  Process {
    id: screenshot_window
    running: false
    command: [...hyprshot_args, "--mode", "window"]
  }

  Process {
    id: screenshot_region
    running: false
    command: [...hyprshot_args, "--mode", "region"]
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

        // Screenshot
        ColumnLayout {
          anchors.fill: parent
          visible: focusedIndex === 1
          spacing: 10

          RowLayout {
            spacing: 3

            // Selection
            Rectangle {
              color: Config.md3.secondary
              height: 100
              Layout.fillWidth: true
              radius: 10

              MouseArea {
                anchors.fill: parent
                onClicked: launchCommand("screenshot_region")
              }

              Text {
                anchors.centerIn: parent
                text: "Selection"
                color: Config.md3.on_secondary
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
              }
            }

            // Window
            Rectangle {
              color: Config.md3.secondary
              Layout.fillWidth: true
              height: 100
              radius: 10

              MouseArea {
                anchors.fill: parent
                onClicked: launchCommand("screenshot_window")
              }

              Text {
                anchors.centerIn: parent
                text: "Window"
                color: Config.md3.on_secondary
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
              }
            }

            // Full screen
            Rectangle {
              color: Config.md3.secondary
              height: 100
              Layout.fillWidth: true
              radius: 10

              MouseArea {
                anchors.fill: parent
                onClicked: launchCommand("screenshot_fullscreen")
              }

              Text {
                anchors.centerIn: parent
                text: "Full screen"
                color: Config.md3.on_secondary
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
              }
            }
          }

          // Freeze
          Rectangle {
            height: 30
            Layout.fillWidth: true
            color: freeze ? Config.md3.primary : Config.md3.tertiary
            radius: 10

            MouseArea {
              anchors.fill: parent
              onClicked: freeze = !freeze
            }

            Text {
              anchors.centerIn: parent
              text: freeze ? "Freeze on" : "Freeze off"
              color: freeze ? Config.md3.on_primary : Config.md3.on_tertiary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize
            }
          }
        }
      }
    }
  }
}
