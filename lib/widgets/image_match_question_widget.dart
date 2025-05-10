import 'package:flutter/material.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageMatchQuestionWidget extends StatefulWidget {
  final CourseContent content;
  final Function(bool) onAnswered;
  final Color themeColor;

  const ImageMatchQuestionWidget({
    Key? key,
    required this.content,
    required this.onAnswered,
    this.themeColor = Colors.teal,
  }) : super(key: key);

  @override
  State<ImageMatchQuestionWidget> createState() =>
      _ImageMatchQuestionWidgetState();
}

class _ImageMatchQuestionWidgetState extends State<ImageMatchQuestionWidget> with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isSubmitting = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final Color themeColor = widget.themeColor;
    final Color lightThemeColor = themeColor.withOpacity(0.15);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
              child: Text(
                widget.content.question,
                style: GoogleFonts.montserrat(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Image
            if (widget.content.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.content.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image: $error');
                      return Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: themeColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
                  _selectedAnswer == null || _isSubmitting
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
    );
  }
}
