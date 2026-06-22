import Quickshell

import "modules/bar"
import "modules/notifications"
import "modules/logoutMenu"
import "modules/wifi"
import "modules/bluetooth"
import "modules/morpheBar"

Scope {
  Bar {}
  Notifications {}
  LogoutMenu {}
  Wifi {}
  Bluetooth {}
  // MorpheBar {}
}
