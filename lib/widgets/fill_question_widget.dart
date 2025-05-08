import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/custom_button.dart';

class FillQuestionWidget extends StatefulWidget {
  final CourseContent content;
  final Function(bool) onAnswered;
  final Color themeColor;

  const FillQuestionWidget({
    Key? key,
    required this.content,
    required this.onAnswered,
    this.themeColor = Colors.purple,
  }) : super(key: key);

  @override
  State<FillQuestionWidget> createState() => _FillQuestionWidgetState();
}

class _FillQuestionWidgetState extends State<FillQuestionWidget> {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

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
      });
      _audioPlayer.playerStateStream.listen((state) 
          {
        _isPlaying = true;
      });
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;

    final isCorrect = _selectedAnswer == widget.content.correctAnswer;
    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
    });

    // Delay to show the result before moving to next question
    Future.delayed(const Duration(seconds: 1), () {
      widget.onAnswered(isCorrect);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Split the question to find where the blank is
    final parts = widget.content.question.split('____');
    final Color themeColor = widget.themeColor;
    final Color lightThemeColor = themeColor.withOpacity(0.15);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.content.audioUrl != null) ...[
              Center(
                child: IconButton(
                  onPressed: _playAudio,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: isSmallScreen ? 40 : 48,
                    color: themeColor,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
            ],

            // Question with blank
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: lightThemeColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Fill in the blank:',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 20, 
                        color: Colors.black
                      ),
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: _selectedAnswer ?? '______',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                _isAnswered
                                    ? (_isCorrect ? Colors.green : Colors.red)
                                    : themeColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        if (parts.length > 1) TextSpan(text: parts[1]),
                      ],
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
                    _isAnswered
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
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16)
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
                  _selectedAnswer == null
                      ? null
                      : _isAnswered
                      ? () => widget.onAnswered(_isCorrect)
                      : _checkAnswer,
              isLoading: false,
              color: themeColor,
            ),
          ],
        );
      }
    );
  }
}
