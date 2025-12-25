import 'dart:async';

import 'package:yourappname/pages/videocall/service/background_service.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class VideoCallService {
  Future<void> startEngine() async {
    //await ZegoExpressEngine.destroyEngine();

    ZegoEngineProfile profile = ZegoEngineProfile(
      Constant.zegoAppId,
      ZegoScenario.StandardVideoCall,
      appSign: Constant.zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
  }

  Future<void> joinRoom({
    required String userId,
    required String currentUserStreamId,
    required String roomId,
  }) async {
    final ZegoUser user = ZegoUser(userId, 'user_$userId');
    await ZegoExpressEngine.instance.loginRoom(roomId, user);
    await ZegoExpressEngine.instance.enableHeadphoneAEC(true);
    await cameraStatus(true);
    await switchStatus(false);
  }

  Future<Widget> createLocalView({
    required Function(int) updateLocalViewId,
  }) async {
    Widget? localView = await ZegoExpressEngine.instance.createCanvasView((
      viewID,
    ) async {
      updateLocalViewId(viewID);

      await startPreview(ZegoCanvas.view(viewID));
    });
    return localView ?? const SizedBox();
  }

  Future<Widget?> createRemoteView({
    required Function(int) updateRemoteViewId,
  }) async {
    Widget? remoteView = await ZegoExpressEngine.instance.createCanvasView((
      viewID,
    ) {
      updateRemoteViewId(viewID);
    });
    return remoteView;
  }

  Future<void> startPublishingVideo(String streamID) async {
    await ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublishingVideo() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayingVideo({
    required String streamID,
    required int remoteViewId,
  }) async {
    if (remoteViewId != 0) {
      await ZegoExpressEngine.instance.startPlayingStream(
        streamID,
        canvas: ZegoCanvas.view(remoteViewId),
      );
    }
  }

  Future<void> stopPlayingVideo(String streamID) async {
    try {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID);
    } catch (e) {
      await ZegoExpressEngine.instance.stopPublishingStream();
    }
  }

  Future<void> startPreview(ZegoCanvas canvas) async {
    await ZegoExpressEngine.instance.startPreview(canvas: canvas);
  }

  Future<void> stopPreview() async {
    await ZegoExpressEngine.instance.stopPreview();
  }

  Future<void> cameraStatus(bool isOpen) async {
    try {
      await ZegoExpressEngine.instance.enableCamera(isOpen);
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future<void> switchStatus(bool isFront) async {
    try {
      await ZegoExpressEngine.instance.useFrontCamera(isFront);
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future<void> microphoneStatus(bool isOpen) async {
    try {
      await ZegoExpressEngine.instance.muteMicrophone(isOpen);
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future<void> endCall({
    required String roomId,
    required String remoteStreamID,
  }) async {
    await ZegoExpressEngine.instance.stopSoundLevelMonitor();

    await stopPreview();
    await stopPlayingVideo(remoteStreamID);

    await ZegoExpressEngine.instance.logoutRoom(roomId);
    ZegoExpressEngine.destroyEngine();
    await VideoCallBackgroundService.stopForegroundService();
  }
}
