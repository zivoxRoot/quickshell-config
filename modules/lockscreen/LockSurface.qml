import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland

import "../../config"

Rectangle {
  id: root
  required property LockContext context
  color: Config.md3.background

  Image {
    id: background
    anchors.fill: parent
    // source: Quickshell.env("HOME") + "/dotfiles/wallpaper.png"
    source: "/home/theophile/dotfiles/wallpaper.png"

    // BackgroundEffect.blurRegion: Region { item: background.contentItem }
  }

  // Button {
    // text: "LET ME OUT PLEASE!"
    // onClicked: context.unlocked();
  // }

  ColumnLayout {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.verticalCenter

    RowLayout {
      TextField {
        id: passwordBox

        implicitWidth: 400
        padding: 10

        focus: true
        enabled: !root.context.unlockInProgress
        echoMode: TextInput.Password

        onTextChanged: root.context.currentText = this.text;
        onAccepted: root.context.tryUnlock();

        Connections {
          target: root.context

          function onCurrentTextChanged() {
            passwordBox.text = root.context.currentText;
          }
        }
      }
    }

    Label {
      visible: root.context.showFailure
      text: "Incorrect password"
      color: Config.md3.on_background
    }
  }
}
