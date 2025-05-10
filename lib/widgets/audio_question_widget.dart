import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

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

class _AudioQuestionWidgetState extends State<AudioQuestionWidget> with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isSubmitting = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _hasPlayed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
    _controller.dispose();
    super.dispose();
  }

  // Helper method to highlight the blank in the question
  Widget _buildQuestionWithBlank() {
    final question = widget.content.question;
    if (!question.contains('____')) {
      return Text(
        question,
        style: GoogleFonts.montserrat(
          fontSize: 20, 
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    }

    final parts = question.split('____');
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: '____',
            style: TextStyle(
              color: widget.themeColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.themeColor;
    final Color lightThemeColor = themeColor.withOpacity(0.15);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildQuestionWithBlank(),
              ),

              const SizedBox(height: 24),

              // Audio player
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _playAudio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isPlaying)
                            Lottie.network(
                              'https://assets9.lottiefiles.com/packages/lf20_jJJl6i.json',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: themeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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

              const SizedBox(height: 24),

              // Options
              ...widget.content.options.map((option) {
                final isSelected = _selectedAnswer == option;
                final isCorrectAnswer = option == widget.content.correctAnswer;

                Color backgroundColor = Colors.white;
                Color borderColor = Colors.grey.shade300;
                
                if (_isAnswered) {
                  if (isCorrectAnswer) {
                    backgroundColor = Colors.green.shade100;
                    borderColor = Colors.green;
                  } else if (isSelected && !isCorrectAnswer) {
                    backgroundColor = Colors.red.shade100;
                    borderColor = Colors.red;
                  }
                } else if (isSelected) {
                  backgroundColor = themeColor.withOpacity(0.15);
                  borderColor = themeColor;
                }

                return GestureDetector(
                  onTap: _isAnswered || _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswer = option;
                          });
                          _controller.forward().then((_) {
                            _controller.reverse();
                          });
                        },
                  child: ScaleTransition(
                    scale: isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(
                          color: borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? themeColor : Colors.grey.shade200,
                              border: Border.all(
                                color: isSelected ? themeColor : Colors.grey.shade400,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _isAnswered
                                    ? (isCorrectAnswer
                                        ? Icons.check
                                        : (isSelected ? Icons.close : null))
                                    : (isSelected ? Icons.check : null),
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option, 
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? themeColor : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

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
          ),
        ),
      ),
    );
  }
}
