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

class _ImageMatchQuestionWidgetState extends State<ImageMatchQuestionWidget> {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isSubmitting = false;

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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final imageHeight = isSmallScreen ? 150.0 : 200.0;
        
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

            // Image
            if (widget.content.imageUrl != null)
              Container(
                height: imageHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: themeColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.content.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image: $error');
                      return Center(
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
                      );
                    },
                  ),
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
                  _selectedAnswer == null || _isSubmitting
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
