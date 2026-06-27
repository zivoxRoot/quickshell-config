import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
  IpcHandler {
    target: "lockscreen"
    function lock(): void {
      lock.locked = true;
    }
  }

  LockContext {
    id: lockContext

    onUnlocked: {
      lock.locked = false;
    }
  }

  WlSessionLock {
    id: lock

    locked: false

    WlSessionLockSurface {
      LockSurface {
        anchors.fill: parent
        context: lockContext
      }
    }
  }
}
