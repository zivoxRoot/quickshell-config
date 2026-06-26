import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

import "../../config"

PanelWindow {
  id: root
  visible: false
  anchors { top: true }
  margins { top: 48 }
  color: "transparent"
  implicitHeight: Math.min(
    maxPopupHeight,
    contentColumn.implicitHeight + 10
  )
  implicitWidth: 400
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  property int focusedIndex: 0
  readonly property int maxPopupHeight: 600
  readonly property var desktopEntries: DesktopEntries
  property var filteredApps: desktopEntries.applications.values

  function launch(index) {
    const item = repeater.itemAt(focusedIndex)
    if (!item) return
    item.modelData.execute()
    root.visible = false
    focusedIndex = 0
  }

  IpcHandler {
    target: "launcher"
    function toggle(): void {
      root.visible = !root.visible

      if (root.visible) {
        focusedIndex = 0
        input.text = ""
        input.forceActiveFocus()
      }
    }
  }
  
  // Autoscroll
  onFocusedIndexChanged: {
    const item = repeater.itemAt(focusedIndex)

    if (!item) return

    const itemTop = item.y
    const itemBottom = item.y + item.height

    const viewTop = list.contentY
    const viewBottom = list.contentY + list.height

    if (itemTop < viewTop) {
      list.contentY = itemTop
    } else if (itemBottom > viewBottom) {
      list.contentY = itemBottom - list.height
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
        focusedIndex = Math.min(focusedIndex + 1, repeater.count - 1)
        break
      case Qt.Key_K:
        focusedIndex = Math.max(focusedIndex - 1, 0)
        break

      // Launch with `space` or `return`
      case Qt.Key_Return:
      case Qt.Key_Space:
        launch(focusedIndex)
        break

      // Go in insert mode with `i`
      case Qt.Key_I:
        focusedIndex = 0
        input.forceActiveFocus()
        break
      }
    }
  }

  // Main window layout
  Rectangle {
    anchors.fill: parent
    color: Config.md3.background
    radius: 14

    ColumnLayout {
      id: contentColumn
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      TextField {
        id: input
        Layout.fillWidth: true
        placeholderText: "Search an application"
        placeholderTextColor: Config.md3.on_background
        color: "white"
        background: textBg

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            focusItem.forceActiveFocus()
            event.accepted = true
          }
          if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            launch(focusedIndex)
            event.accepted = true
          }
        }

        focus: root.visible
    
        onTextChanged: {
          filteredApps = desktopEntries.applications.values.filter(app =>
            app.name.toLowerCase().includes(text.toLowerCase())
          )
          focusedIndex = 0
        }
      }
      Item {
        id: textBg
        Layout.fillWidth: true
      }

      // Devices list
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(rows.implicitHeight + 10, 410)
        color: "transparent"

        Flickable {
          id: list
          anchors.fill: parent
          contentHeight: rows.implicitHeight
          contentWidth: rows.width
          clip: true
          bottomMargin: 10

          Column {
            id: rows
            width: list.width

            Repeater {
              id: repeater
              model: filteredApps

              // One application
              Rectangle {
                required property var modelData
                required property int index
                color: index === focusedIndex ? Config.md3.secondary_container : Config.md3.surface
                radius: height / 2
                height: 60
                width: rows.width

                // Launch on click
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    launch(index)
                  }
                }

                RowLayout {
                  id: content
                  anchors.fill: parent
                  anchors.margins: 12

                  // App icon
                  IconImage {
                    id: image
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    Layout.alignment: Qt.AlignVCenter
                    source: Quickshell.iconPath(modelData.icon)
                  }

                  Column  {
                    Layout.leftMargin: 8
                    Layout.alignment: Qt.AlignVCenter
                    // Layout.fillWidth: true
                    spacing: 2

                    // App name
                    Text {
                      text: modelData.name
                      color: index === focusedIndex ? Config.md3.on_secondary_container : Config.md3.on_surface
                      font.family: Config.fontFamily
                      font.pixelSize: Config.fontSize
                    }

                    // App description
                    Text {
                      visible: modelData.genericName !== ""
                      text: modelData.genericName
                      color: index === focusedIndex ? Config.md3.on_secondary_container : Config.md3.on_surface
                      font.family: Config.fontFamily
                      font.pixelSize: Config.fontSize
                    }
                  }

                  Item {
                    Layout.fillWidth: true
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
