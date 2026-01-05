import 'package:flutter/material.dart';
import 'package:recall_flutter/src/core/app_colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class VoiceRecordingSheet extends StatefulWidget {
  const VoiceRecordingSheet({super.key});

  @override
  State<VoiceRecordingSheet> createState() => _VoiceRecordingSheetState();
}

class _VoiceRecordingSheetState extends State<VoiceRecordingSheet> with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  double _soundLevel = 0.0;
  
  // Animation for the glow
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // Request permissions first
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          setState(() => _isListening = true);
        } else if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        // Handle error silently or show toast
      },
    );

    if (available) {
      _startListening();
    }
  }

  void _startListening() {
    _speech.listen(
      onResult: (val) {
        setState(() {
          _text = val.recognizedWords;
        });
      },
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  void _stopListening() {
    _speech.stop();
    // Return result
    Navigator.pop(context, _text.isNotEmpty ? _text : null);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _speech.cancel(); // Ensure we stop listening
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          if (_isListening)
            Positioned(
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Mic Button
              ScaleTransition(
                scale: _isListening ? _glowAnimation : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Status Text
              Text(
                _isListening ? 'Listening...' : 'Tap to Speak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              
              // Waveform Visualization (Mock + Sound Level)
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(20, (index) {
                    final height = 10 + math.Random().nextInt(20) + (_soundLevel * 2); 
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      width: 4,
                      height: _isListening ? height.clamp(4.0, 50.0) : 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Transcript Preview
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _text.isEmpty ? (_isListening ? "Say something..." : "") : _text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
          
          // Close button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
