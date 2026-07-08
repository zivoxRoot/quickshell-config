import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell.Widgets

import "../config"
import "../services/music"

Variants {
  model: Quickshell.screens

  PanelWindow {
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    anchors { top: true; right: true }
    margins { top: 150; right: 150 }
    height: 200
    width: height
    color: "transparent"
    
    Rectangle {
      anchors.fill: parent
      color: "transparent"

      // Song album art
      ClippingWrapperRectangle {
        height: parent.height
        width: parent.width
        radius: height / 2

        Image {
          anchors.fill: parent
          source: MusicService.active.trackArtUrl
          fillMode: Image.PreserveAspectCrop
        }
      }

      // Play/pause button
      Rectangle {
        color: Config.md3.primary
        radius: MusicService.active.isPlaying ? 20 : height / 2
        height: 60
        width: height
        anchors.bottom: parent.bottom

        Behavior on radius {
          NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: MusicService.active.canTogglePlaying ? MusicService.active.togglePlaying() : null
        }

        Text {
          text: MusicService.active.isPlaying ? "󰏤" : ""
          font.pixelSize: 30
          anchors.centerIn: parent
        }
      }

      // Next song button
      Rectangle {
        color: Config.md3.tertiary
        radius: height / 2
        height: 50
        width: height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10

        MouseArea {
          anchors.fill: parent
          onClicked: MusicService.active.canGoNext ? MusicService.active.next() : null
        }

        Text {
          text: "󰒭"
          font.pixelSize: 30
          anchors.centerIn: parent
        }
      }
    }
  }
}
