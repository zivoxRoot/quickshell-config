import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../components"
import "../../services/screenshot"

ColumnLayout {
  property int focusedScreenshotType: 0
  property list<string> screenshotTypes: ["Region", "Window", "Full"]

  spacing: 10

  // Screenshot type
  Rectangle {
    height: 80
    Layout.fillWidth: true
    color: Config.md3.secondary_container
    radius: 10

    Column {
      anchors.fill: parent
      spacing: 10

      RowLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        spacing: 10

        // Icon
        Text {
          text: ""
          color: Config.md3.on_secondary_container
          font.pixelSize: Config.fontSize + 12
        }

        // Title
        Text {
          text: "Screenshot type"
          color: Config.md3.on_secondary_container
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
          font.weight: 600
        }

        // Spacing
        Item { Layout.fillWidth: true }
      }

      ButtonList {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: parent.width - 20
        buttons: screenshotTypes
        focused: focusedScreenshotType
        onClicked: index => focusedScreenshotType = index
      }
    }
  }

  // Freeze
  Rectangle {
    height: 50
    Layout.fillWidth: true
    color: Config.md3.secondary_container
    radius: 10

    MouseArea {
      anchors.fill: parent
      onClicked: ScreenshotService.toggleFreeze()
    }

    RowLayout {
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      // Freeze icon
      Text {
        text: ""
        color: Config.md3.on_secondary_container
        font.pixelSize: Config.fontSize + 12
      }

      // Freeze title
      Text {
        text: "Freeze screen"
        color: Config.md3.on_secondary_container
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.weight: 600
      }

      // Spacing
      Item { Layout.fillWidth: true }

      // Freeze switch
      Switch {
        toggled: ScreenshotService.freeze
      }
    }
  }

  // Start recording button
  Button {
    anchors.right: parent.right

    icon: ""
    text: "Start"

    onClicked: {
      screenshotTypes[focusedScreenshotType] === "Region" ? ScreenshotService.region() :
        screenshotTypes[focusedScreenshotType] === "Window" ? ScreenshotService.window() :
        ScreenshotService.full()
      root.visible = false
    }
  }
}
