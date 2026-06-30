import QtQuick
import Quickshell
import Quickshell.Io

import "../../config"

Rectangle {
  color: currentTheme === "light" ? Config.md3.primary : Config.md3.inverse_primary
  height: 42
  width: 52
  radius: currentTheme === "light" ? 10 : height / 2

  property string currentTheme: themeFile.text

  function changeTheme() {
    currentTheme = currentTheme === "light" ? "dark" : "light"
    themeFile.setText(currentTheme)
    Quickshell.execDetached(["bash", Quickshell.shellPath("modules/wallpaper_switcher/switch.sh"), "/home/theophile/.cache/current_wallpaper/current.jpg"])
  }

  FileView {
    id: themeFile
    path: Qt.resolvedUrl("/home/theophile/.cache/current-theme.txt")
  }

  MouseArea {
    anchors.fill: parent
    onClicked: changeTheme()
  }

  Text {
    text: "󰌵"
    anchors.centerIn: parent
    color: currentTheme === "light" ? Config.md3.on_primary : Config.md3.on_inverse_primary
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize + 6
  }
}
