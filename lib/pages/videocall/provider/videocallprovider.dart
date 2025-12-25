import 'package:flutter/cupertino.dart';

import '../../../utils/app_string.dart';
import '../../../utils/utils.dart';
import '../service/background_service.dart';
import 'dart:io';
import '../service/videocallservice.dart';

class VideoCallProvider with ChangeNotifier {
  VideoCallService _videoService = VideoCallService();
  bool isLoading = true;
  String remoteStreamID = "";
  int localViewID = 0;
  int remoteViewId = 0;
  bool error = false;

  Future<bool> init(
      {required String roomId,
      required String currentUserId,
      required String currentUserStreamId,
      required VoidCallback startListener,
      required BuildContext context}) async {
    isLoading = true;
    error = false;
    try {
      await _videoService.startEngine();
      startListener();
      await _videoService.joinRoom(
        userId: currentUserId,
        currentUserStreamId: currentUserStreamId,
        roomId: roomId,
      );

      if (!context.mounted) return error;
      printLog("Logged in Room");
      if (Platform.isAndroid) {
        VideoCallBackgroundService.setupForgroundService();
        await VideoCallBackgroundService.startForegroundService(context);
      } else if (Platform.isIOS) {
        VideoCallBackgroundService.setupForgroundService();
        // iOS: configure CallKit + AVAudioSession
        await VideoCallBackgroundService.startIOSBackground();
      }

      return error;
    } catch (e) {
      error = true;
      printLog("Error: $e");
      return error;
    } finally {
      isLoading = false;
      notifyListeners();
      // return error;
    }
  }

  Future<Widget> createUserCameraView(BuildContext context) async {
    try {
      final updateCameraView = await _videoService.createLocalView(
        updateLocalViewId: (int id) {
          localViewID = id;
          notifyListeners();
        },
      );
      return updateCameraView;
    } catch (e) {
      if (context.mounted) {
        Utils.showSnackbar(context, AppString.unableToLoadCamera, false);
      }
      printLog("Error creating local view: $e");
      notifyListeners();
      return const SizedBox();
    }
  }

  Future<Widget?> createCallerUserCameraView(BuildContext context) async {
    try {
      final updateCameraView = await _videoService.createRemoteView(
        updateRemoteViewId: (int id) {
          remoteViewId = id;
          notifyListeners();
        },
      );
      return updateCameraView;
    } catch (e) {
      if (context.mounted) {
        Utils.showSnackbar(
            context, AppString.participantVideoStreamIssue, false);
      }
      printLog("Error creating remote view: $e");
      notifyListeners();
      return null;
    }
  }

  Future<void> startPublishingUserView(String streamId) async {
    try {
      printLog("Current Stream ud :- $streamId");
      await _videoService.startPublishingVideo(streamId);
    } catch (e) {
      printLog("Error publishing video: $e");
      notifyListeners();
    }
  }

  void updateView() {
    notifyListeners();
  }

  clear() {
    _videoService = VideoCallService();
    isLoading = true;
    remoteStreamID = "";
    localViewID = 0;
    remoteViewId = 0;
    error = false;
  }
}
