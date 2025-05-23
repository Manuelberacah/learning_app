import 'package:flutter/material.dart';
import 'package:learning_app/models/course_content.dart';
import 'package:learning_app/screens/question_screen.dart';
import 'package:learning_app/screens/completion_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionTypeManager extends StatefulWidget {
  final List<CourseContent> contents;

  const QuestionTypeManager({Key? key, required this.contents}) : super(key: key);

  @override
  State<QuestionTypeManager> createState() => _QuestionTypeManagerState();
}

class _QuestionTypeManagerState extends State<QuestionTypeManager> with TickerProviderStateMixin {
  late List<CourseContent> _imageQuestions;
  late List<CourseContent> _audioQuestions;
  int _imageScore = 0;
  int _audioScore = 0;
  bool _completedImageQuestions = false;
  bool _completedAudioQuestions = false;
  bool _isTransitioning = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    
    _fadeController.forward();
    _sortQuestionsByType();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _sortQuestionsByType() {
    try {
      _imageQuestions = widget.contents.where((q) => q.type == 'image_match').toList();
      _audioQuestions = widget.contents.where((q) => q.type == 'audio').toList();
      
      // If there are no questions of a type, mark it as completed
      if (_imageQuestions.isEmpty) {
        _completedImageQuestions = true;
      }
      
      if (_audioQuestions.isEmpty) {
        _completedAudioQuestions = true;
      }
      
      debugPrint('Image questions: ${_imageQuestions.length}');
      debugPrint('Audio questions: ${_audioQuestions.length}');
    } catch (e) {
      debugPrint('Error sorting questions: $e');
      // Initialize with empty lists to prevent null errors
      _imageQuestions = [];
      _audioQuestions = [];
      _completedImageQuestions = true;
      _completedAudioQuestions = true;
    }
  }

  void _onImageQuestionsCompleted(int score) {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
      _imageScore = score;
      _completedImageQuestions = true;
    });
    
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
        _fadeController.forward();
      }
    });
  }

  void _onAudioQuestionsCompleted(int score) {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
      _audioScore = score;
      _completedAudioQuestions = true;
    });
    
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
        _fadeController.forward();
      }
    });
  }

  void _restartQuiz() {
    _fadeController.reverse().then((_) {
      setState(() {
        _imageScore = 0;
        _audioScore = 0;
        _completedImageQuestions = false;
        _completedAudioQuestions = false;
        _isTransitioning = false;
      });
      
      _sortQuestionsByType();
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator during transitions to prevent flicker
    if (_isTransitioning) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // If all question types are completed, show the final completion screen
    if (_completedImageQuestions && _completedAudioQuestions) {
      final totalScore = _imageScore + _audioScore;
      final totalQuestions = _imageQuestions.length + _audioQuestions.length;
      
      return FadeTransition(
        opacity: _fadeAnimation,
        child: CompletionScreen(
          score: totalScore,
          totalQuestions: totalQuestions,
          onRestart: _restartQuiz,
        ),
      );
    }
    
    // If image questions are not completed and there are image questions
    if (!_completedImageQuestions && _imageQuestions.isNotEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: QuestionScreen(
          contents: _imageQuestions,
          questionType: 'image_match',
          onCompleted: _onImageQuestionsCompleted,
          themeColor: const Color(0xFF4355B9),
          typeName: 'Image Recognition',
        ),
      );
    }
    
    // If audio questions are not completed and there are audio questions
    if (!_completedAudioQuestions && _audioQuestions.isNotEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: QuestionScreen(
          contents: _audioQuestions,
          questionType: 'audio',
          onCompleted: _onAudioQuestionsCompleted,
          themeColor: const Color(0xFF6789CA),
          typeName: 'Listening',
        ),
      );
    }
    
    // Fallback - should not reach here with the checks above
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
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
                Navigator.of(context).pop();
              },
              child: Text(
                'Back to Home',
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
}
