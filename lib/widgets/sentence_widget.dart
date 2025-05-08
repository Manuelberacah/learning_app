import 'package:flutter/material.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/custom_button.dart';

class SentenceQuestionWidget extends StatefulWidget {
  final CourseContent content;
  final Function(bool) onAnswered;
  final Color themeColor;

  const SentenceQuestionWidget({
    Key? key,
    required this.content,
    required this.onAnswered,
    this.themeColor = Colors.orange,
  }) : super(key: key);

  @override
  State<SentenceQuestionWidget> createState() => _SentenceQuestionWidgetState();
}

class _SentenceQuestionWidgetState extends State<SentenceQuestionWidget> {
  List<String> _selectedWords = [];
  List<String> _availableWords = [];
  bool _isAnswered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _availableWords = List.from(widget.content.options);
    _availableWords.shuffle(); // Randomize the order
  }

  void _selectWord(String word) {
    if (_isAnswered) return;

    setState(() {
      _availableWords.remove(word);
      _selectedWords.add(word);
    });
  }

  void _removeWord(int index) {
    if (_isAnswered) return;

    setState(() {
      final word = _selectedWords.removeAt(index);
      _availableWords.add(word);
    });
  }

  void _checkAnswer() {
    final userSentence = _selectedWords.join(' ');
    final isCorrect = userSentence == widget.content.correctAnswer;

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
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20, 
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Selected words (sentence being built)
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      _isAnswered
                          ? (_isCorrect ? Colors.green : Colors.red)
                          : themeColor.withOpacity(0.3),
                  width: _isAnswered ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color:
                    _isAnswered
                        ? (_isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                        : Colors.white,
              ),
              constraints: BoxConstraints(minHeight: isSmallScreen ? 80 : 100),
              child:
                  _selectedWords.isEmpty
                      ? Center(
                        child: Text(
                          'Tap words below to form a sentence',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_selectedWords.length, (index) {
                          return GestureDetector(
                            onTap: () => _removeWord(index),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 8 : 12,
                                vertical: isSmallScreen ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: themeColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedWords[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                  if (!_isAnswered) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.close,
                                      size: isSmallScreen ? 14 : 16,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
            ),

            if (_isAnswered && !_isCorrect) ...[
              const SizedBox(height: 12),
              Text(
                'Correct answer: ${widget.content.correctAnswer}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 14 : 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Available words
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _availableWords.map((word) {
                    return GestureDetector(
                      onTap: () => _selectWord(word),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          word,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            SizedBox(height: isSmallScreen ? 16 : 24),

            // Submit button
            CustomButton(
              text: _isAnswered ? 'Next Question' : 'Check Answer',
              onPressed:
                  _selectedWords.isEmpty
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
