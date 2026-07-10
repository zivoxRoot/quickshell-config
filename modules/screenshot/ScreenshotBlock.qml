import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../services/screenshot"

ColumnLayout {
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
