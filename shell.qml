import Quickshell

import "modules/notifications"
import "modules/brightness"
import "modules/volume"
import "modules/lockscreen"
import "modules/pill"

Scope {
  NotificationsCenter {}
  NotificationsPopup {}
  Brightness {}
  Volume {}
  Lockscreen {}
  Pill {}
}
