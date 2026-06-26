import QtQuick
import Quickshell
import Quickshell.Services.UPower

import "../../config"

Item {
  implicitHeight: text.implicitHeight
  implicitWidth: text.implicitWidth

  readonly property var battery: UPower.displayDevice
  readonly property real percentage: battery?.percentage ?? 0
  readonly property int batteryLevel: Math.round(percentage * 100)
  readonly property bool isCharging: battery?.state === UPowerDevice.Charging
  readonly property bool isLow: batteryLevel < 30 && batteryLevel > 15
  readonly property bool isCritical: batteryLevel < 15

  function getIcon(): string {
    if (isCharging)
      return "󰂄"
    if (batteryLevel >= 80)
      return ""
    if (batteryLevel >= 60)
      return ""
    if (batteryLevel >= 40)
      return ""
    if (batteryLevel >= 20)
      return ""

    return ""
  }

  Text {
    id: text
    text: getIcon() + " " + batteryLevel + "%"
    color: isLow ? "orange" : (isCritical ? "red" : Config.md3.on_background)

    font {
      family: Config.fontFamily
      pixelSize: Config.fontSize
    }
  }
}
