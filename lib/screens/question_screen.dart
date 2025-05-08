import 'package:flutter/material.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/widgets/fill_question_widget.dart';
import 'package:learning_app/widgets/image_match_question_widget.dart';
import 'package:learning_app/widgets/audio_question_widget.dart';
import 'package:learning_app/widgets/custom_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionScreen extends StatefulWidget {
  final List<CourseContent> contents;
  final String questionType;
  final Function(int) onCompleted;
  final Color themeColor;
  final String typeName;

  const QuestionScreen({
    Key? key,
    required this.contents,
    required this.questionType,
    required this.onCompleted,
    required this.themeColor,
    required this.typeName,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isCompleting = false;

  void _nextQuestion(bool isCorrect) {
    // Prevent multiple calls to onCompleted
    if (_isCompleting) return;
    
    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    if (_currentIndex < widget.contents.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // All questions of this type are completed
      // Set flag to prevent multiple calls
      setState(() {
        _isCompleting = true;
      });
      
      // Use Future.microtask to avoid calling during build
      Future.microtask(() {
        widget.onCompleted(_score);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for empty contents
    if (widget.contents.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'No ${widget.typeName} Questions',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: widget.themeColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 64, color: widget.themeColor),
              const SizedBox(height: 16),
              Text(
                'No questions available',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  widget.onCompleted(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Safety check for index out of bounds
    if (_currentIndex >= widget.contents.length) {
      // Reset to a valid index or complete
      setState(() {
        _currentIndex = widget.contents.length - 1;
        _isCompleting = true;
      });
      
      // Use Future.microtask to avoid calling during build
      Future.microtask(() {
        widget.onCompleted(_score);
      });
      
      // Show loading indicator while transitioning
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.typeName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: widget.themeColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final content = widget.contents[_currentIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.typeName} ${_currentIndex + 1}/${widget.contents.length}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom progress bar for this question type
            CustomProgressBar(
              currentIndex: _currentIndex,
              totalQuestions: widget.contents.length,
              themeColor: widget.themeColor,
              typeName: widget.typeName,
            ),
            
            // Question content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        minWidth: constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildQuestionWidget(
                          content, 
                          Key('question_$_currentIndex'),
                          widget.themeColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(CourseContent content, Key key, Color themeColor) {
    switch (content.type) {
      case 'fill':
        return FillQuestionWidget(
          key: key,
          content: content, 
          onAnswered: _nextQuestion,
          themeColor: themeColor,
        );
      case 'image_match':
        return ImageMatchQuestionWidget(
          key: key,
          content: content,
          onAnswered: _nextQuestion,
          themeColor: themeColor,
        );
      case 'audio':
        return AudioQuestionWidget(
          key: key,
          content: content, 
          onAnswered: _nextQuestion,
          themeColor: themeColor,
        );
      default:
        return Center(
          child: Text(
            'Unsupported question type: ${content.type}',
            style: GoogleFonts.poppins(),
          ),
        );
    }
  }
}
