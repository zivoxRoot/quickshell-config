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
    // source: Quickshell.env("HOME") + "/dotfiles/wallpaper.png"
    source: "/home/theophile/dotfiles/wallpaper.png"
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
    radius: 14

    RowLayout {
      height: parent.height
      width: parent.width

      // Left
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "green"
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
            Rectangle {
              Layout.fillWidth: true
              Layout.fillHeight: true
              color: Config.md3.background

              ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: "11:28 AM"
                  color: Config.md3.on_background
                  font.pixelSize: 46
                  font.family: Config.fontFamily
                }

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: "Monday, 26 January 2026"
                  color: Config.md3.on_background
                  font.pixelSize: 24
                  font.family: Config.fontFamily
                }
              }
            }

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
            color: "black"
          }

          // Error
          Label {
            visible: root.context.showFailure
            text: "Incorrect password"
            color: "black"
          }
        }
      }

      // Right
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "red"
      }
    }
  }
}
