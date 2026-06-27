import QtQuick
import Quickshell
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland

import "../../config"

Rectangle {
  id: root
  required property LockContext context
  color: Config.md3.background

  property string pass: ""
  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      case Qt.Key_Backspace:
        pass = pass.slice(0, -1)
        break
      case Qt.Key_Return:
        pass = ""
        root.context.tryUnlock()
        break
      default:
        if (event.text.length > 0)
          pass += event.text
        root.context.currentText = pass
        break
      }

      event.accepted = true
    }
  }

  // Background image
  Image {
    id: background
    anchors.fill: parent
    source: Quickshell.env("HOME") + "/.cache/current_wallpaper/current.jpg"
    layer.enabled: true
    layer.effect: MultiEffect {
      blurEnabled: true
      blur: 0.95
    }
  }

  // Safety button
  Button {
    text: "LET ME OUT PLEASE!"
    onClicked: context.unlocked();
  }

  // Main rectangle
  Rectangle {
    id: block
    anchors.centerIn: parent
    height: 700
    width: 1200
    color: Config.md3.background
    radius: 32

    RowLayout {
      height: parent.height - 20
      width: parent.width - 20
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter

      // Left
      Rectangle {
        Layout.preferredWidth: 350
        Layout.fillHeight: true
        color: "transparent"

        ColumnLayout {
          height: parent.height
          width: parent.width
          anchors.margins: 10
          spacing: 10

          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Config.md3.surface_container
            radius: 22
          }
          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Config.md3.surface_container
            radius: 22
          }
        }
      }

      // Center
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Config.md3.background

        ColumnLayout {
          height: parent.height
          width: parent.width

          ColumnLayout {

            // Time & date
            Clock {}

            // Password characters
            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: Config.md3.background

              RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter

                Repeater {
                  model: pass
                  visible: !root.context.unlockInProgress

                  Rectangle {
                    color: Config.md3.primary
                    height: 10
                    width: 10
                    radius: height / 2
                  }
                }
              }
            }
          }

          // Loader
          Label {
            visible: root.context.unlockInProgress
            text: "LOADING..."
            color: Config.md3.on_background
          }

          // Error
          Label {
            visible: root.context.showFailure
            text: "Incorrect password"
            color: Config.md3.on_background
          }
        }
      }

      // Right
      Rectangle {
        Layout.preferredWidth: 350
        Layout.fillHeight: true
        color: "transparent"

        ColumnLayout {
          height: parent.height
          width: parent.width
          anchors.margins: 10
          spacing: 10

          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Config.md3.surface_container
            radius: 22
          }
          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Config.md3.surface_container
            radius: 22
          }
        }
      }
    }
  }
}
