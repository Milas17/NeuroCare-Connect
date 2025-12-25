import 'package:yourappname/pages/videocall/provider/videocallprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/myvideocallbutton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../utils/app_string.dart';
import '../../../utils/appconstant.dart';
import '../../../utils/utils.dart';
import '../service/background_service.dart';
import '../service/videocallservice.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen(
      {super.key, required this.roomId, required this.userId});

  final String roomId;
  final String userId;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Widget? localVideoView;
  Widget? remoteVideoView;

  String currentUserId = "";
  String currentRoomId = "";
  String currentStreamId = "";

  bool muteMicrophone = false;
  bool offCamera = false;
  bool frontCamera = false;

  VideoCallService videoService = VideoCallService();

  late VideoCallProvider videoCallProvider;

  @override
  void initState() {
    videoCallProvider = Provider.of<VideoCallProvider>(context, listen: false);

    currentUserId = widget.userId;
    currentRoomId = widget.roomId;
    currentStreamId = "${widget.userId}_stream";
    printLog("Room Id :- $currentRoomId");
    printLog("stream Id :- $currentStreamId");
    init();
    super.initState();
  }

  @override
  void dispose() {
    videoCallProvider.clear();
    super.dispose();
  }

  init() async {
    await videoCallProvider
        .init(
      roomId: currentRoomId,
      currentUserId: currentUserId,
      currentUserStreamId: currentStreamId,
      context: context,
      startListener: () async {
        await registerEngineListener(
          userId: currentUserId,
          onUserAdd: () async {
            remoteVideoView =
                await videoCallProvider.createCallerUserCameraView(context);
            videoCallProvider.updateView();
            await videoService.startPlayingVideo(
              streamID: videoCallProvider.remoteStreamID,
              remoteViewId: videoCallProvider.remoteViewId,
            );
            videoCallProvider.updateView();
          },
          onUserRemove: () {
            remoteVideoView = null;
            videoCallProvider.updateView();
          },
        );
      },
    )
        .then((isError) async {
      if (!isError) {
        if (!mounted) return;
        localVideoView = await videoCallProvider.createUserCameraView(context);
        await videoCallProvider.startPublishingUserView(currentStreamId);
        videoCallProvider.updateView();
      }
    });
  }

  Future<void> registerEngineListener({
    required String userId,
    required VoidCallback onUserAdd,
    required VoidCallback onUserRemove,
  }) async {
    await ZegoExpressEngine.instance.startSoundLevelMonitor();

    ZegoExpressEngine.onRoomStreamUpdate = (
      String roomID,
      ZegoUpdateType updateType,
      List<ZegoStream> streamList,
      Map<String, dynamic> extendedData,
    ) async {
      if (updateType == ZegoUpdateType.Add) {
        for (var stream in streamList) {
          if (stream.user.userID != userId) {
            videoCallProvider.remoteStreamID = stream.streamID;
            onUserAdd();
          }
        }
      } else if (updateType == ZegoUpdateType.Delete) {
        for (var stream in streamList) {
          ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
          if (videoCallProvider.remoteStreamID == stream.streamID) {
            videoCallProvider.remoteStreamID = "";
            onUserRemove();
          }
        }
      }
    };

    ZegoExpressEngine.onNetworkModeChanged = (ZegoNetworkMode mode) {
      if (mode == ZegoNetworkMode.Offline) {
        Utils.showSnackbar(context, AppString.noInternetConnection, false);
      }
    };
    ZegoExpressEngine.onCapturedSoundLevelUpdate = (
      double level,
    ) {
      // 'level' is a double value representing the sound level.
      // A level greater than 0.0 generally indicates that sound is being captured.
      printLog('My sound level: $level');

      // // You can use this to update UI or logs
      if (level > 0.0) {
        printLog('My voice is being transmitted!');
        // You might want to update a UI element here to show your mic is active
      } else {
        printLog('No sound detected from my microphone.');
        // You might want to update a UI element here to show your mic is inactive or muted
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(child: builderBody()),
      ),
    );
  }

  Widget builderBody() {
    return Consumer<VideoCallProvider>(
      builder: (context, videoCallProvider, child) {
        if (videoCallProvider.isLoading) {
          return loadingView();
        } else if (videoCallProvider.error) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!context.mounted) return;
            showVideoCallErrorDialog(
              context,
              onEnd: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              onRetry: () async {
                Navigator.of(context).pop();
                await VideoCallBackgroundService.stopForegroundService();
                await ZegoExpressEngine.destroyEngine();
                init();
              },
            );
          });
          return mainBody();
        } else {
          return mainBody();
        }
      },
    );
  }

  Widget mainBody() {
    return Stack(
      children: [
        remoteVideoView ??
            Center(
                child: MyText(
              text: AppString.waitingForOtherToJoin,
              multilanguage: false,
            )),
        if (localVideoView != null)
          Positioned(
            top: 10,
            right: 10,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: white, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: localVideoView ?? const SizedBox.shrink(),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: VideoCallButton(
            muteMicrophone: muteMicrophone,
            frontCamera: frontCamera,
            offCamera: offCamera,
            onMuteBtnClick: () async {
              muteMicrophone = !muteMicrophone;
              await videoService.microphoneStatus(!muteMicrophone);
              videoCallProvider.updateView();
            },
            onCameraDirectionChangeBtnClick: () async {
              frontCamera = !frontCamera;
              offCamera = false;
              await videoService.cameraStatus(!offCamera);
              await videoService.switchStatus(frontCamera);
              videoCallProvider.updateView();
            },
            onCallEndBthClick: () async {
              await videoService.endCall(
                roomId: currentRoomId,
                remoteStreamID: videoCallProvider.remoteStreamID,
              );
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            onCallCameraStatusBtnClick: () async {
              offCamera = !offCamera;
              await videoService.cameraStatus(!offCamera);
              videoCallProvider.updateView();
            },
          ),
        ),
      ],
    );
  }

  Widget loadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  void showVideoCallErrorDialog(BuildContext context,
      {VoidCallback? onRetry, VoidCallback? onEnd}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          key: AppConstant.videoCallDialogKey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: red, size: 32),
              const SizedBox(width: 8),
              MyText(
                text: AppString.callFailed,
                fontweight: FontWeight.bold,
              ),
            ],
          ),
          content: MyText(
            text: AppString.videoCallInitializeFailure,
            fontsize: 15,
          ),
          actions: [
            TextButton(
              onPressed: onEnd ?? () => Navigator.of(context).pop(),
              child: MyText(
                text: AppString.endCall,
                color: red,
                fontweight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: MyText(
                text: AppString.retry,
                multilanguage: false,
              ),
            ),
          ],
        );
      },
    );
  }
}
