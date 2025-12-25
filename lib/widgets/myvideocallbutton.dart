import 'package:yourappname/utils/colors.dart';
import 'package:flutter/material.dart';

class VideoCallButton extends StatelessWidget {
  const VideoCallButton({
    super.key,
    required this.muteMicrophone,
    required this.frontCamera,
    required this.offCamera,
    required this.onMuteBtnClick,
    required this.onCameraDirectionChangeBtnClick,
    required this.onCallEndBthClick,
    required this.onCallCameraStatusBtnClick,
  });

  final bool muteMicrophone;
  final bool frontCamera;
  final bool offCamera;
  final VoidCallback onMuteBtnClick;
  final VoidCallback onCameraDirectionChangeBtnClick;
  final VoidCallback onCallEndBthClick;
  final VoidCallback onCallCameraStatusBtnClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightGrey.withValues(alpha:  0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //Mic Mute
          CircleAvatar(
            backgroundColor: muteMicrophone ? black : white,
            radius: 30,
            child: IconButton(
              onPressed: () async {
                onMuteBtnClick();
              },
              icon: Icon(
                muteMicrophone ? Icons.mic_off : Icons.mic,
                color: muteMicrophone ? white : black,
              ),
            ),
          ),
          //Camera Switch
          CircleAvatar(
            backgroundColor: black,
            radius: 30,
            child: IconButton(
              onPressed: () async {
                onCameraDirectionChangeBtnClick();
              },
              icon: Icon(
                frontCamera ? Icons.camera_front : Icons.camera_rear,
                color: white,
              ),
            ),
          ),
          //End call
          CircleAvatar(
            backgroundColor: red,
            radius: 30,
            child: IconButton(
              onPressed: () async {
                onCallEndBthClick();
              },
              icon: const Icon(Icons.call_end, color: white),
            ),
          ),
          // Camera status
          CircleAvatar(
            backgroundColor: offCamera ? black : white,
            radius: 30,
            child: IconButton(
              onPressed: () async {
                onCallCameraStatusBtnClick();
              },
              icon: Icon(
                offCamera ? Icons.videocam_off : Icons.videocam,
                color: offCamera ? white : black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
