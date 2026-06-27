import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 2.11

PanelWindow {
  id: root
  visible: false
  anchors { top: true }
  margins { top: 48 }
  exclusionMode: ExclusionMode.Ignore
  width: 800
  height: 150
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  color: "transparent"

  property int focusedIndex: 0

  IpcHandler {
    target: "wallpaper-switcher"
    function toggle(): void {
      if (root.visible) focusedIndex = 0
      root.visible = !root.visible
    }
  }

  Item {
    id: focusItem
    anchors.fill: parent
    focus: true

    Keys.onPressed: event => {
      switch (event.key) {
      // Close with `escape`
      case Qt.Key_Escape:
        root.visible = false
        focusedIndex = 0
        break

      // Navigate with vim keys
      case Qt.Key_J:
        focusedIndex = Math.min(focusedIndex + 1, wallpapers.count - 1)
        break
      case Qt.Key_K:
        focusedIndex = Math.max(focusedIndex - 1, 0)
        break

      // Select wallpaper with `return` and `space`
      case Qt.Key_Return:
      case Qt.Key_Space:
        switchWallpaper(repeater.itemAt(focusedIndex))
        break
      }
    }
  }

  function switchWallpaper(wallpaper) {
    const url = new URL(wallpaper.fileUrl)
    const filename = url.pathname.split("/").pop()
    const target = "/home/theophile/Pictures/Wallpapers/" + filename
    Quickshell.execDetached(["bash", Quickshell.shellPath("modules/wallpaper_switcher/switch.sh"), target])
    root.visible = false
  }

  // Autoscroll
  onFocusedIndexChanged: {
      const item = repeater.itemAt(focusedIndex)
      if (!item)
          return

      const itemLeft = item.x
      const itemRight = item.x + item.width

      const viewLeft = list.contentX
      const viewRight = list.contentX + list.width

      if (itemLeft < viewLeft) {
          list.contentX = itemLeft
      } else if (itemRight > viewRight) {
          list.contentX = itemRight - list.width
      }
  }

  FolderListModel {
    id: wallpapers
    folder: "file:///home/theophile/.cache/wallpaper-select"
    nameFilters: ["*.jpg", "*.png"]
    showDirs: false
  }

  Rectangle {
    color: "transparent"
    anchors.fill: parent

    Flickable {
      id: list
      anchors.fill: parent
      contentHeight: rows.implicitHeight
      contentWidth: rows.width
      clip: true

      Behavior on contentX {
        NumberAnimation {
          duration: 150
          easing.type: Easing.OutCubic
        }
      }

      Row {
        id: rows
        spacing: 24
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
          id: repeater
          model: wallpapers

          Rectangle {
            anchors.verticalCenter: parent.verticalCenter 
            required property int index
            required property var fileUrl
            width: 216
            height: 120
            scale: index === focusedIndex ? 1.2 : 1.0

            Behavior on scale {
              NumberAnimation {
                duration: 150
              }
            }

            Image {
              anchors.fill: parent
              source: fileUrl
              fillMode: Image.PreserveAspectLayout
            }
          }
        }
      }
    }
  }
}
