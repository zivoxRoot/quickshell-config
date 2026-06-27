import QtQuick
import Quickshell
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland

import "../../config"

Rectangle {
  id: root
  required property LockContext context
  color: Config.md3.background

  property string pass: ""
  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      case Qt.Key_Backspace:
        pass = pass.slice(0, -1)
        break
      case Qt.Key_Return:
        pass = ""
        root.context.tryUnlock()
        break
      default:
        if (event.text.length > 0)
          pass += event.text
        root.context.currentText = pass
        break
      }

      event.accepted = true
    }
  }

  Image {
    id: background
    anchors.fill: parent
    // source: Quickshell.env("HOME") + "/dotfiles/wallpaper.png"
    source: "/home/theophile/dotfiles/wallpaper.png"
    layer.enabled: true
    layer.effect: MultiEffect {
      blurEnabled: true
      blur: 0.95
    }
  }

  Button {
    text: "LET ME OUT PLEASE!"
    onClicked: context.unlocked();
  }

  ColumnLayout {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.verticalCenter

    // Password characters
    RowLayout {
      Repeater {
        model: pass
        visible: !root.context.unlockInProgress

        Rectangle {
          color: Config.md3.primary
          height: 10
          width: 10
          radius: height / 2
        }
      }
    }

    // Loader
    Label {
      visible: root.context.unlockInProgress
      text: "LOADING..."
      color: "black"
    }

    // Error
    Label {
      visible: root.context.showFailure
      text: "Incorrect password"
      color: "black"
    }
  }
}
