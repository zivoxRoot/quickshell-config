import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../services/screenshot"

ColumnLayout {
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
