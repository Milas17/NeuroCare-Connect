import 'dart:io';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:zego_express_engine/zego_express_engine.dart';


class VideoCallBackgroundService {
  static const MethodChannel _callkitChannel = MethodChannel("callkit_channel");
  static setupForgroundService() {
    FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'video_call_channel',
            channelName: 'Video Call Service',
            channelDescription:
                'This notification keeps the video call active.',
            channelImportance: NotificationChannelImportance.HIGH,
            priority: NotificationPriority.HIGH,
            playSound: true),
        iosNotificationOptions: const IOSNotificationOptions(
            showNotification: true, playSound: true),
        foregroundTaskOptions: ForegroundTaskOptions(
            eventAction: ForegroundTaskEventAction.nothing()));
  }

  static Future<void> startForegroundService(BuildContext context) async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    // Create notification content
    const String notificationTitle = 'Video Call in Progress';
    const String notificationContent =
        'Your video call is active in the background.';
    await FlutterForegroundTask.startService(
      notificationTitle: notificationTitle,
      notificationText: notificationContent,
      // notificationButtons: [
      //   const NotificationButton(id: "1", text: "End Call")
      // ],
      serviceTypes: [
        ForegroundServiceTypes.camera,
        ForegroundServiceTypes.microphone,
        ForegroundServiceTypes.mediaPlayback
      ],
    );
  }

  static Future<void> stopForegroundService() async {
    if (Platform.isAndroid) {
      ZegoExpressEngine.destroyEngine();
      await FlutterForegroundTask.stopService();
    } else if (Platform.isIOS) {
      try {
        await _callkitChannel.invokeMethod("endCall");
      } catch (e) {
        printLog("iOS CallKit endCall error: $e");
      }
    }
  }

  static Future<void> startIOSBackground() async {
    if (Platform.isIOS) {
      try {
        // Configure CallKit & AVAudioSession on native side
        await _callkitChannel.invokeMethod("configureAudioSession");
      } catch (e) {
        printLog("iOS CallKit init error: $e");
      }
    }
  }
}
