import 'package:yourappname/pages/videocall/service/background_service.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    printLog("Foreground service started at $timestamp");
  }

  @override
  void onNotificationButtonPressed(String id) async {
    printLog("Notification on Tap :- $id");
    if (id == "1") {
      await VideoCallBackgroundService.stopForegroundService();
    }
    super.onNotificationButtonPressed(id);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isClosed) async {
    printLog("Foreground service stopped at $timestamp");
  }

  // @override
  // void onButtonPressed(String id) {
  //   printLog('Button pressed: $id');
  // }

  @override
  void onNotificationPressed() {
    // Handle notification press
    printLog('Notification pressed');
  }

  // @override
  // void onNotificationDismissed() {
  //   super.onNotificationDismissed();
  // }

  @override
  void onRepeatEvent(DateTime timestamp) {
  }
}
