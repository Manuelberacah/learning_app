import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioQuestionWidget extends StatefulWidget {
  final CourseContent content;
  final Function(bool) onAnswered;
  final Color themeColor;

  const AudioQuestionWidget({
    Key? key,
    required this.content,
    required this.onAnswered,
    this.themeColor = Colors.blue,
  }) : super(key: key);

  @override
  State<AudioQuestionWidget> createState() => _AudioQuestionWidgetState();
}

class _AudioQuestionWidgetState extends State<AudioQuestionWidget> {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isSubmitting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (widget.content.audioUrl != null) {
      try {
        await _audioPlayer.setUrl(widget.content.audioUrl!);
      } catch (e) {
        debugPrint('Error loading audio: $e');
      }
    }
  }

  void _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
        _hasPlayed = true;
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
            });
          }
        }
      });
    }
  }

  void _checkAnswer() {
    if (_selectedAnswer == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _isAnswered = true;
      _isCorrect = _selectedAnswer == widget.content.correctAnswer;
    });

    // Delay to show the result before moving to next question
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        widget.onAnswered(_isCorrect);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.themeColor;
    final Color lightThemeColor = themeColor.withOpacity(0.15);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: lightThemeColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Text(
                widget.content.question,
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 18 : 20, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Audio player
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Listen to the audio',
                    style: GoogleFonts.poppins(
                      fontSize: 16, 
                      fontWeight: FontWeight.w500,
                      color: themeColor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  IconButton(
                    onPressed: _playAudio,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: isSmallScreen ? 48 : 64,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasPlayed ? 'Tap to play again' : 'Tap to play',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700, 
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Options
            ...widget.content.options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isCorrectAnswer = option == widget.content.correctAnswer;

              Color backgroundColor = Colors.white;
              if (_isAnswered) {
                if (isCorrectAnswer) {
                  backgroundColor = Colors.green.shade100;
                } else if (isSelected && !isCorrectAnswer) {
                  backgroundColor = Colors.red.shade100;
                }
              } else if (isSelected) {
                backgroundColor = themeColor.withOpacity(0.15);
              }

              return GestureDetector(
                onTap:
                    _isAnswered || _isSubmitting
                        ? null
                        : () {
                          setState(() {
                            _selectedAnswer = option;
                          });
                        },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                      color: isSelected ? themeColor : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAnswered
                            ? (isCorrectAnswer
                                ? Icons.check_circle
                                : (isSelected
                                    ? Icons.cancel
                                    : Icons.circle_outlined))
                            : (isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined),
                        color:
                            _isAnswered
                                ? (isCorrectAnswer
                                    ? Colors.green
                                    : (isSelected ? Colors.red : Colors.grey))
                                : (isSelected ? themeColor : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option, 
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Submit button
            CustomButton(
              text: _isAnswered ? 'Next Question' : 'Submit Answer',
              onPressed:
                  (_selectedAnswer == null || !_hasPlayed || _isSubmitting)
                      ? null
                      : _isAnswered
                      ? () => widget.onAnswered(_isCorrect)
                      : _checkAnswer,
              isLoading: _isSubmitting,
              color: themeColor,
            ),
          ],
        );
      }
    );
  }
}
