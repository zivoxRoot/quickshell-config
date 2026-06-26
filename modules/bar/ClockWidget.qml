import QtQuick

import "../../services/time"
import "../../config"

Text {
  text: Time.time
  color: Config.md3.on_background

  font {
    family: Config.fontFamily
    pixelSize: Config.fontSize
  }
}
