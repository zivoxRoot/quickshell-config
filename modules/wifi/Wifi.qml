import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Networking
import Quickshell.Wayland
import Quickshell.Io

import "../../config"

PanelWindow {
  id: root
  visible: false
  anchors { top: true; right: true }
  margins { top: 48; right: 10 }

  implicitWidth: 380
  implicitHeight: 600
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  property int focusedIndex: 0
  property var wifiDevice

  IpcHandler {
    target: "wifi"
    function toggle(): void {
      root.visible = !root.visible
      // console.log(wifiDevice)
      // console.log(wifiDevice?.networks)
    }
  }

  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Config.colBg
    border.color: Config.colFg

    Repeater {
      model: Networking.devices

      Rectangle {
        required property var modelData
        color: Config.colFg
        implicitHeight: label.implicitHeight
        implicitWidth: label.implicitWidth

        Component.onCompleted: {
            // console.log(modelData)
            // console.log(modelData.name)
            // console.log(modelData.networks)
            // console.log(modelData.connected)

            if (modelData.name.startsWith("wl"))
                root.wifiDevice = modelData
        }

        Text {
          id: label
          padding: 10
          height: 10
          width: 10
          text: `${modelData.name} ${modelData.connected}`
          color: Config.colFocused
          font.family: Config.fontFamily
          font.pixelSize: Config.fontSize
        }
      }
    }
  }
}
