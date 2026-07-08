import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import "../../services/music"
import "../../config"

FocusScope {
  id: root
  implicitHeight: 120
  implicitWidth: 400

  Keys.onPressed: event => {
    switch (event.key) {

    // Close with `escape`
    case Qt.Key_Escape:
      root.visible = false
      // focusedIndex = 0
      break

    // Toggle playing state with `space` and `K`
    case Qt.Key_Space:
    case Qt.Key_K:
      MusicService.active.canTogglePlaying ? MusicService.active.togglePlaying() : null
      MusicService.active.canTogglePlaying ? playPauseBtn.playPressAnimation() : null
      break

    // Next/Previous track with `N` and `P`
    case Qt.Key_P:
      MusicService.active.canGoPrevious ? MusicService.active.previous() : null
      break

    case Qt.Key_N:
      MusicService.active.canGoNext ? MusicService.active.next() : null
      break

    // Move in song advancement with `H` and `L`
    case Qt.Key_L:
      MusicService.active.seek(10)
      break

    case Qt.Key_H:
      MusicService.active.seek(-10)
      break

    // Switch player with `S`
    case Qt.Key_S:
      MusicService.nextPlayer()
      break
    }
  }

  Rectangle {
  anchors.fill: parent
  color: Config.md3.background
  radius: 14

    ColumnLayout {
      anchors.fill: parent

      // Top block
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: "transparent"
        topLeftRadius: 14
        topRightRadius: 14

        RowLayout {
          anchors.fill: parent

          // Left -> song image + name
          Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            topLeftRadius: 14

            RowLayout {
              anchors.fill: parent
              anchors.centerIn: parent
              spacing: 5

              // Song cover
              Item {
                Layout.preferredWidth: parent.height - 20
                Layout.preferredHeight: parent.height - 20
                Layout.leftMargin: 10
                Layout.topMargin: 10
                Layout.bottomMargin: 10

                Rectangle {
                  color: "transparent"
                  radius: 14
                  height: parent.height
                  width: parent.width

                  ClippingWrapperRectangle {
                    height: parent.height
                    width: parent.width
                    radius: 14

                    Image {
                      anchors.fill: parent
                      source: MusicService.active.trackArtUrl
                      fillMode: Image.PreserveAspectCrop
                    }
                  }
                }

                // Player icon
                Rectangle {
                  width: 26
                  height: 26
                  color: Config.md3.background
                  radius: height / 2
                  anchors.right: parent.right
                  anchors.bottom: parent.bottom
                  anchors.rightMargin: -3
                  anchors.bottomMargin: -3

                  MouseArea {
                    anchors.fill: parent
                    onClicked: MusicService.nextPlayer()
                  }

                  Rectangle {
                    width: parent.width - 7
                    height: parent.height - 7
                    color: Config.md3.tertiary
                    radius: height / 2
                    anchors.centerIn: parent

                    Text {
                      text: MusicService.getPlayerIcon()
                      color: Config.md3.on_tertiary
                      anchors.centerIn: parent
                      font.family: Config.fontFamily
                      font.pixelSize: Config.fontSize + 4
                    }
                  }
                }
              }

              // Song infos (title, artist)
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height - 40
                color: "transparent"
                Layout.leftMargin: 10
                Layout.bottomMargin: 10
                Layout.topMargin: 10

                ColumnLayout {
                  anchors.fill: parent

                  // Title
                  Text {
                    text: MusicService.active.trackTitle || "Unknown title"
                    color: Config.md3.on_background
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize + 4
                    font.weight: 800
                    elide: Text.ElideRight
                  }

                  // Artist
                  Text {
                    text: MusicService.active.trackArtist || "Unknown artist"
                    color: Config.md3.on_background
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                  }
                }
              }
            }
          }

          // Right -> control buttons
          Rectangle {
            Layout.preferredWidth: 170
            Layout.fillHeight: true
            color: Config.md3.background
            topRightRadius: 14

            RowLayout {
              anchors.fill: parent
              anchors.centerIn: parent
              spacing: 5

              // Previous track
              Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Config.md3.secondary
                radius: height / 2
                Layout.leftMargin: 10
                Layout.bottomMargin: 10
                Layout.topMargin: 10

                MouseArea {
                  anchors.fill: parent
                  onClicked: MusicService.active.canGoPrevious ? MusicService.active.previous() : null
                }

                Text {
                  text: "󰒮"
                  font.pixelSize: 20
                  anchors.centerIn: parent
                }
              }

              // Play/pause
              Rectangle {
                id: playPauseBtn
                property bool pressed: false
                Layout.preferredWidth: pressed ? parent.height + 30 : parent.height - 20
                Layout.preferredHeight: parent.height - 20
                radius: MusicService.active.isPlaying ? 20 : height / 2
                color: Config.md3.primary
                Layout.bottomMargin: 10
                Layout.topMargin: 10

                function playPressAnimation() {
                  pressed = true
                  resetTimer.restart()
                }

                Timer {
                  id: resetTimer
                  interval: 120
                  onTriggered: playPauseBtn.pressed = false
                }

                Behavior on radius {
                  NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                  }
                }

                Behavior on Layout.preferredWidth {
                  NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                  }
                }

                MouseArea {
                  onPressed: playPauseBtn.playPressAnimation()
                  anchors.fill: parent
                  onClicked: MusicService.active.canTogglePlaying ? MusicService.active.togglePlaying() : null
                }

                Text {
                  text: MusicService.active.isPlaying ? "󰏤" : ""
                  font.pixelSize: 30
                  anchors.centerIn: parent
                }
              }

              // Next track
              Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Config.md3.secondary
                radius: height / 2
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                Layout.topMargin: 10

                MouseArea {
                  anchors.fill: parent
                  onClicked: MusicService.active.canGoNext ? MusicService.active.next() : null
                }

                Text {
                  text: "󰒭"
                  font.pixelSize: 20
                  anchors.centerIn: parent
                }
              }
            }
          }
        }
      }

      // Bottom block (song advancement)
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Config.md3.background
        bottomLeftRadius: 14
        bottomRightRadius: 14

        Rectangle {
          anchors.centerIn: parent
          width: parent.width - 20
          height: parent.height - 30
          color: "transparent"
          radius: height / 2

          Rectangle {
            width: (MusicService.songPercentage / 100) * parent.width
            height: parent.height
            color: Config.md3.primary
            radius: height / 2

            Behavior on width {
              NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
              }
            }

            // Tip
            Rectangle {
              width: 15
              height: 15
              anchors.right: parent.right
              anchors.rightMargin: -5
              anchors.verticalCenter: parent.verticalCenter
              color: Config.md3.primary
              radius: height / 2
            }
          }

          Rectangle {
            width: parent.width - ((MusicService.songPercentage / 100) * parent.width) - 10
            height: parent.height
            anchors.right: parent.right
            color: Config.md3.surface_bright
            radius: height / 2
          }
        }
      }
    }
  }
}
