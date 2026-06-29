import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import "../../config"

FocusScope {
  id: root
  implicitWidth: 800
  implicitHeight: 200

  property int focusedIndex: 0

  FolderListModel {
    id: wallpapers
    folder: "file:///home/theophile/.cache/wallpaper-select"
    nameFilters: ["*.jpg", "*.png"]
    showDirs: false
  }

  Rectangle {
    color: Config.md3.background
    anchors.fill: parent
    radius: 14

    PathView {
      id: pv
      anchors.fill: parent
      focus: true
      model: wallpapers

      pathItemCount: 7
      preferredHighlightBegin: 0.5
      preferredHighlightEnd: 0.5
      highlightRangeMode: PathView.StrictlyEnforceRange
      snapMode: PathView.SnapToItem
      highlightMoveDuration: 300

      property real baseWidth: width / 7

      path: Path {
        startX: -pv.baseWidth
        startY: pv.height / 2

        // Side, smaller
        PathAttribute { name: "zVal"; value: 1 }
        PathAttribute { name: "progress"; value: 0.0 }
        PathAttribute { name: "itemOpacity"; value: 0.7 }

        PathLine { x: root.width / 2; y: pv.height / 2 }

        // Center, bigger
        PathAttribute { name: "zVal"; value: 100 }
        PathAttribute { name: "progress"; value: 1.0 }
        PathAttribute { name: "itemOpacity"; value: 1.0 }

        PathLine { x: root.width + pv.baseWidth; y: pv.height / 2 }

        PathAttribute { name: "zVal"; value: 1 }
        PathAttribute { name: "progress"; value: 0.0 }
      }

      delegate: Item {
        id: delegateRoot

        readonly property real imgAspect: (img.implicitWidth > 0) ? (img.implicitWidth / img.implicitHeight) : (16/9)
        readonly property real targetWidth: (pv.height - 10) * imgAspect

        width: pv.baseWidth + ((targetWidth - pv.baseWidth) * (PathView.progress || 0))
        height: 120 + ((pv.height - 130) * (PathView.progress || 0))

        z: PathView.zVal || 1

        Rectangle {
          anchors.centerIn: parent
          width: parent.width
          height: parent.height
          color: "transparent"
          clip: true

          Image {
            id: img
            anchors.fill: parent
            anchors.topMargin: (1.0 - (PathView.progress || 0)) * 5
            anchors.bottomMargin: (1.0 - (PathView.progress || 0)) * 5

            source: "file:///home/theophile/.cache/wallpaper-select/" + model.fileName
            fillMode: PathView.isCurrentItem ? Image.PreserveAspectFit : Image.PreserveAspectCrop

            asynchronous: true
            smooth: true
            mipmap: true
          }

          // Selection
          Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.width: PathView.isCurrentItem ? 3 : 0
            border.color: "red"
            z: 5
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: pv.currentIndex = index
        }
      }

      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_L || event.key === Qt.Key_J) incrementCurrentIndex()
        else if (event.key === Qt.Key_H || event.key === Qt.Key_K) decrementCurrentIndex()
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
          const filename = wallpapers.get(currentIndex, "filePath").split("/").pop()
          const target = "/home/theophile/Pictures/Wallpapers/" + filename

          Quickshell.execDetached(["bash", Quickshell.shellPath("modules/wallpaper_switcher/switch.sh"), target])
          root.visible = false
        }
        else if (event.key === Qt.Key_Escape) root.visible = false
      }
    }
  }
}
