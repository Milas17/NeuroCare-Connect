import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchSuffix extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final String? lottieAnimationPath;

  const VoiceSearchSuffix({
    Key? key,
    required this.controller,
    required this.onClear,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    this.lottieAnimationPath,
  }) : super(key: key);

  @override
  _VoiceSearchSuffixState createState() => _VoiceSearchSuffixState();
}

class _VoiceSearchSuffixState extends State<VoiceSearchSuffix> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = "";
  Timer? _debounce;
  Timer? _stopFallbackTimer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Speech status: $status");
          if (status == 'done' || status == 'notListening') {
            _stopListening();
          }
        },
        onError: (error) {
          debugPrint("Speech recognition error: $error");
          _stopListening();
        },
      );

      if (available) {
        setState(() => _isListening = true);

        // Safety fallback: auto-stop if nothing happens in 5s
        _stopFallbackTimer?.cancel();
        _stopFallbackTimer = Timer(Duration(seconds: 5), () {
          if (_isListening) _stopListening();
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _voiceInput = result.recognizedWords;
              widget.controller.text = _voiceInput;
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                widget.onSearchChanged(_voiceInput);
              });
            });

            // If speech recognizer says it's the final result, stop
            if (result.finalResult) {
              _stopListening();
              widget.onSearchSubmitted(_voiceInput.trim());
            }
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    if (!_isListening) return;
    _speech.stop();
    _stopFallbackTimer?.cancel();
    setState(() => _isListening = false);

    if (_voiceInput.trim().isNotEmpty) {
      widget.controller.text = _voiceInput.trim();
      widget.onSearchSubmitted(_voiceInput.trim());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _stopFallbackTimer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isListening) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.lottieAnimationPath != null)
            Lottie.asset(
              widget.lottieAnimationPath!,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              _stopListening();
              widget.onClear();
            },
          ),
        ],
      );
    }

    if (widget.controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear, color: Colors.grey),
        onPressed: widget.onClear,
      );
    }

    return IconButton(
      icon: Icon(Icons.mic, color: Colors.grey),
      onPressed: _listen,
    );
  }
}
