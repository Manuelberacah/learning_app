import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learning_app/models/course_content.dart';

class ContentProvider extends ChangeNotifier {
  List<CourseContent> _courseContents = [];
  bool _isLoading = false;
  String? _error;

  List<CourseContent> get courseContents => _courseContents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourseContent(String token, String className) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(
          'https://ai-qna-gvhkarb0faf3fvhs.eastus-01.azurewebsites.net/createCourseContent',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'className': className}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _courseContents = parseContentFromJson(data);
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load course content';
        _isLoading = false;
        notifyListeners();
        // Load dummy data if API fails
        _loadDummyData();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      // Load dummy data if API fails
      _loadDummyData();
    }
  }

  List<CourseContent> parseContentFromJson(dynamic json) {
    // Parse the API response based on the actual structure
    // This is a placeholder implementation
    List<CourseContent> contents = [];

    if (json['data'] != null && json['data'] is List) {
      for (var item in json['data']) {
        contents.add(CourseContent.fromJson(item));
      }
    }

    return contents;
  }

  void _loadDummyData() {
    // Load dummy data for testing
    _courseContents = [
      // Fill in the blanks questions
      CourseContent(
        id: '1',
        type: 'fill',
        question: 'The color of the sky is ____.',
        options: ['blue', 'green', 'red', 'yellow'],
        correctAnswer: 'blue',
        audioUrl: 'assets/audio/sky_color.mp3',
      ),
      CourseContent(
        id: '2',
        type: 'fill',
        question: 'A ____ has four legs.',
        options: ['dog', 'bird', 'fish', 'snake'],
        correctAnswer: 'dog',
        audioUrl: 'assets/audio/animal_legs.mp3',
      ),

      // Image match questions
      CourseContent(
        id: '3',
        type: 'image_match',
        question: 'Match the animal with its name:',
        imageUrl: 'assets/images/dog.png',
        options: ['Dog', 'Cat', 'Elephant', 'Lion'],
        correctAnswer: 'Dog',
      ),
      CourseContent(
        id: '4',
        type: 'image_match',
        question: 'What fruit is this?',
        imageUrl: 'assets/images/apple.png',
        options: ['Apple', 'Banana', 'Orange', 'Grapes'],
        correctAnswer: 'Apple',
      ),

      // Audio questions
      CourseContent(
        id: '5',
        type: 'audio',
        question: 'Listen and select the correct animal:',
        audioUrl: 'assets/audio/dog_bark.mp3',
        options: ['Dog', 'Cat', 'Cow', 'Lion'],
        correctAnswer: 'Dog',
      ),

      // Sentence questions
      CourseContent(
        id: '6',
        type: 'sentence',
        question: 'Arrange the words to form a sentence:',
        options: ['I', 'to', 'school', 'go'],
        correctAnswer: 'I go to school',
      ),
    ];
    notifyListeners();
  }
}
