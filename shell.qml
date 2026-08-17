import Quickshell

import "modules/notifications"
import "modules/brightness"
import "modules/volume"
import "modules/lockscreen"
import "modules/pill"
import "modules/calendar"
import "widgets"

Scope {
  NotificationsCenter {}
  NotificationsPopup {}
  Brightness {}
  Volume {}
  Lockscreen {}
  ClockWidget {}
  MusicWidget {}
  Pill {}
  Calendar {}
}
