import QtQuick

import "../../services/time"
import "../../config"

Text {
  text: Qt.formatDateTime(Time.time, "hh:mm")
  color: Config.md3.on_background

  font {
    family: Config.fontFamily
    pixelSize: Config.fontSize
  }
}
