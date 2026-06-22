import QtQuick
import Quickshell
import QtQuick.Layouts

import "../../config"
import "../../services/time"

Scope {
  Variants {
    model: Quickshell.screens

    FloatingWindow {
      required property var modelData
      // screen: modelData

      color: "transparent"
      width: pill.width
      height: pill.height

      // x: (screen.width - width) / 2
      // y: 8

      Rectangle {
        id: pill

        width: text.implicitWidth + 28
        height: 32

        radius: height / 2
        color: "red"

        Text {
          id: text
          text: "SIU"
          anchors.centerIn: parent
        }
      }
    }
  }
}
