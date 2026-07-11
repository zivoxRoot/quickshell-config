import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../components"
import "../../config"
import "../../services/screenshot"

ColumnLayout {
  property int focusedRecordingType: 0
  property list<string> recordingTypes: ["Region", "Window", "Full"]

  spacing: 10

  // Running or not
  Rectangle {
    visible: ScreenrecordService.screen_recording
    height: 50
    Layout.fillWidth: true
    color: Config.md3.primary
    radius: 10

    MouseArea {
      anchors.fill: parent
      onClicked: ScreenrecordService.screen_recording ? ScreenrecordService.stop() : null
    }

    RowLayout {
      anchors.centerIn: parent
      spacing: 8

      Text {
        text: ""
        color: Config.md3.on_primary
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
      }

      Text {
        text: "Stop recording"
        color: Config.md3.on_primary
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.weight: 600
      }
    }
  }

  // Screen recording type
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
          text: "Recording type"
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
        buttons: recordingTypes
        focused: focusedRecordingType
        onClicked: index => focusedRecordingType = index
      }
    }
  }

  // Output list
  Rectangle {
    id: list
    property bool activated: recordingTypes[focusedRecordingType] === "Full"

    height: 80
    Layout.fillWidth: true
    color: list.activated ? Config.md3.secondary_container : Qt.alpha(Config.md3.on_surface, 0.12)
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
          text: "󰹑"
          color: list.activated ? Config.md3.on_secondary_container : Qt.alpha(Config.md3.on_surface, 0.38)
          font.pixelSize: Config.fontSize + 6
        }

        // Title
        Text {
          text: "Output to record"
          color: list.activated ? Config.md3.on_secondary_container : Qt.alpha(Config.md3.on_surface, 0.38)
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

        buttons: ScreenrecordService.outputs
        focused: ScreenrecordService.output_to_record
        activated: list.activated

        onClicked: index => ScreenrecordService.output_to_record = index
      }
    }
  }

  // Start recording button
  Button {
    anchors.right: parent.right

    icon: ""
    text: "Start"

    onClicked: {
      recordingTypes[focusedRecordingType] === "Region" ? ScreenrecordService.region() :
        recordingTypes[focusedRecordingType] === "Window" ? ScreenrecordService.window() :
        ScreenrecordService.full()
      root.visible = false
    }
  }
}
