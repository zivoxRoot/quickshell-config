import Quickshell

import "modules/bar"
import "modules/notifications"
import "modules/logoutMenu"
import "modules/wifi"
import "modules/bluetooth"
import "modules/brightness"
import "modules/launcher"
import "modules/morpheBar"

Scope {
  Bar {}
  Notifications {}
  LogoutMenu {}
  Wifi {}
  Bluetooth {}
  Brightness {}
  Launcher {}
  // MorpheBar {}
}
