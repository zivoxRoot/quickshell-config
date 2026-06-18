import QtQuick

import "../../services/time"
import "../../config"

Text {
  text: Time.time
  color: Config.colFg

  font {
    family: Config.fontFamily
    pixelSize: Config.fontSize
  }
}
