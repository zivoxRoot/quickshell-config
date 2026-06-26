import Quickshell

import "modules/bar"
import "modules/notifications"
import "modules/logoutMenu"
import "modules/wifi"
import "modules/bluetooth"
import "modules/brightness"
import "modules/volume"
import "modules/launcher"
import "modules/wallpaper-switcher"
import "modules/morpheBar"

Scope {
  Bar {}
  Notifications {}
  LogoutMenu {}
  Wifi {}
  Bluetooth {}
  Brightness {}
  Volume {}
  Launcher {}
  Switcher {}
  // MorpheBar {}
}
