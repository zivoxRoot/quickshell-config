import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import "../../config"

PanelWindow {
  id: root
  color: "transparent"
  anchors { top: true }
  margins { top: 48 }
  visible: false
  implicitHeight: 40
  implicitWidth: 200
  exclusionMode: ExclusionMode.Ignore

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }
  property real volume: Pipewire.defaultAudioSink.audio.volume * 100
  property bool muted: Pipewire.defaultAudioSink.audio.muted

  onVolumeChanged: {
    root.visible = true
    hideTimer.restart()
  }
  
  onMutedChanged: {
    root.visible = true
    hideTimer.restart()
  }

  // Hide after 1s
  Timer {
    id: hideTimer
    interval: 1000
    onTriggered: root.visible = false
  }

  // Main window
  Rectangle {
    id: mainWindow
    anchors.fill: parent
    radius: height / 2
    color: "transparent"

    Rectangle {
      id: main
      anchors.fill: parent
      color: "transparent"
      implicitHeight: 30
      radius: height / 4

      // Left block
      Rectangle {
        id: left
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter 
        implicitHeight: 30
        width: 2 * volume - 6
        color: Config.md3.primary
        topLeftRadius: height / 4
        bottomLeftRadius: height / 4

        Text {
          visible: volume >= 50
          text: muted ? "󰎊" : "󰎇"
          anchors.verticalCenter: parent.verticalCenter 
          leftPadding: 12
          color: Config.md3.on_primary
          font.family: Config.fontFamily + 4
          font.pixelSize: Config.fontSize
        }
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
          color: Config.md3.primary
          radius: height / 2
        }
      }

      // Right block
      Rectangle {
        id: right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter 
        implicitHeight: 30
        width: 200 - (2 * volume) - 6
        color: Config.md3.surface_container_highest
        topRightRadius: height / 4
        bottomRightRadius: height / 4

        Text {
          visible: volume < 50
          text: muted ? "󰎊" : "󰎇"
          anchors.verticalCenter: parent.verticalCenter 
          anchors.right: parent.right
          rightPadding: 12
          color: Config.md3.on_surface_container_highest
          font.family: Config.fontFamily + 4
          font.pixelSize: Config.fontSize
        }
      }
    }
  }
}
