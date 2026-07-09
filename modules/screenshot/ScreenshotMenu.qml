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

        // Screen recording
        ColumnLayout {
          anchors.fill: parent
          visible: focusedIndex === 0
          spacing: 10

          // Running or not
          Rectangle {
            height: 30
            Layout.fillWidth: true
            color: ScreenrecordService.screen_recording ? "red" : Config.md3.tertiary
            radius: 10

            MouseArea {
              anchors.fill: parent
              onClicked: ScreenrecordService.screen_recording ? ScreenrecordService.stop() : null
            }

            Text {
              anchors.centerIn: parent
              text: ScreenrecordService.screen_recording ? "Recording on" : "Recording off"
              color: ScreenrecordService.screen_recording ? Config.md3.on_primary : Config.md3.on_tertiary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize
            }
          }

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
                onClicked: {
                  root.visible = false
                  ScreenrecordService.region()
                }
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
                onClicked: {
                  root.visible = false
                  ScreenrecordService.window()
                }
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
                onClicked: {
                  root.visible = false
                  ScreenrecordService.fullscreen()
                }
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

          // Outputs list
          Rectangle {
            height: 30
            Layout.fillWidth: true
            color: ScreenrecordService.screen_recording ? Config.md3.primary : Config.md3.tertiary
            radius: 10

            RowLayout {
              Layout.fillWidth: true
              spacing: 5

              Repeater {
                model: ScreenrecordService.outputs

                Rectangle {
                  required property var modelData
                  required property int index
                  height: 30
                  width: 70
                  color: index === ScreenrecordService.output_to_record ? Config.md3.primary : Config.md3.tertiary
                  radius: index === ScreenrecordService.output_to_record ? height / 2 : 10

                  MouseArea {
                    anchors.fill: parent
                    onClicked: ScreenrecordService.output_to_record = index
                  }

                  Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: "black"
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                  }
                }
              }
            }
          }
        }

        // Screenshot
        ColumnLayout {
          anchors.fill: parent
          visible: focusedIndex === 1
          spacing: 10

          RowLayout {
            spacing: 3

            // Region
            Rectangle {
              color: Config.md3.secondary
              height: 100
              Layout.fillWidth: true
              radius: 10

              MouseArea {
                anchors.fill: parent
                onClicked: {
                  root.visible = false
                  ScreenshotService.region()
                }
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
                onClicked: {
                  root.visible = false
                  ScreenshotService.window()
                }
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
                onClicked: {
                  root.visible = false
                  ScreenshotService.fullscreen()
                }
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
            color: ScreenshotService.freeze ? Config.md3.primary : Config.md3.tertiary
            radius: 10

            MouseArea {
              anchors.fill: parent
              onClicked: ScreenshotService.toggleFreeze()
            }

            Text {
              anchors.centerIn: parent
              text: ScreenshotService.freeze ? "Freeze on" : "Freeze off"
              color: ScreenshotService.freeze ? Config.md3.on_primary : Config.md3.on_tertiary
              font.family: Config.fontFamily
              font.pixelSize: Config.fontSize
            }
          }
        }
      }
    }
  }
}
