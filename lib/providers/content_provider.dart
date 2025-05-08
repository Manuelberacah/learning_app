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
        type: 'image_match',
        question: 'Match the animal with its name:',
        imageUrl: 'assets/images/dog.png',
        options: ['Dog', 'Cat', 'Elephant', 'Lion'],
        correctAnswer: 'Dog',
      ),
      CourseContent(
        id: '2',
        type: 'image_match',
        question: 'What fruit is this?',
        imageUrl: 'assets/images/apple.png',
        options: ['Apple', 'Banana', 'Orange', 'Grapes'],
        correctAnswer: 'Apple',
      ),
      CourseContent(
        id: '3',
        type: 'image_match',
        question: 'Identify this vehicle:',
        imageUrl: 'assets/images/car.png',
        options: ['Car', 'Bus', 'Bicycle', 'Train'],
        correctAnswer: 'Car',
      ),
      CourseContent(
        id: '4',
        type: 'image_match',
        question: 'What shape is this?',
        imageUrl: 'assets/images/circle.png',
        options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
        correctAnswer: 'Circle',
      ),
      CourseContent(
        id: '5',
        type: 'image_match',
        question: 'Which color is shown?',
        imageUrl: 'assets/images/red.png',
        options: ['Red', 'Blue', 'Green', 'Yellow'],
        correctAnswer: 'Red',
      ),
      CourseContent(
        id: '6',
        type: 'image_match',
        question: 'Identify this body part:',
        imageUrl: 'assets/images/hand.png',
        options: ['Hand', 'Foot', 'Head', 'Leg'],
        correctAnswer: 'Hand',
      ),
      CourseContent(
        id: '7',
        type: 'image_match',
        question: 'What weather condition is shown?',
        imageUrl: 'assets/images/rain.png',
        options: ['Rain', 'Snow', 'Sun', 'Wind'],
        correctAnswer: 'Rain',
      ),
      CourseContent(
        id: '8',
        type: 'image_match',
        question: 'Which number is displayed?',
        imageUrl: 'assets/images/five.png',
        options: ['5', '3', '7', '9'],
        correctAnswer: '5',
      ),

      // Audio questions
      CourseContent(
        id: '9',
        type: 'audio',
        question: 'Listen and select the correct animal:',
        audioUrl: 'assets/audio/dog_bark.mp3',
        options: ['Dog', 'Cat', 'Cow', 'Lion'],
        correctAnswer: 'Dog',
      ),
      CourseContent(
        id: '10',
        type: 'audio',
        question: 'Which instrument is playing?',
        audioUrl: 'assets/audio/piano.mp3',
        options: ['Piano', 'Guitar', 'Drums', 'Violin'],
        correctAnswer: 'Piano',
      ),
      CourseContent(
        id: '11',
        type: 'audio',
        question: 'Listen and identify the language:',
        audioUrl: 'assets/audio/french.mp3',
        options: ['French', 'Spanish', 'English', 'German'],
        correctAnswer: 'French',
      ),
      CourseContent(
        id: '12',
        type: 'audio',
        question: 'What sound is this?',
        audioUrl: 'assets/audio/thunder.mp3',
        options: ['Thunder', 'Rain', 'Wind', 'Ocean'],
        correctAnswer: 'Thunder',
      ),
      CourseContent(
        id: '13',
        type: 'audio',
        question: 'Listen and select the correct vehicle:',
        audioUrl: 'assets/audio/train.mp3',
        options: ['Train', 'Car', 'Airplane', 'Motorcycle'],
        correctAnswer: 'Train',
      ),
      CourseContent(
        id: '14',
        type: 'audio',
        question: 'Which bird makes this sound?',
        audioUrl: 'assets/audio/owl.mp3',
        options: ['Owl', 'Eagle', 'Parrot', 'Chicken'],
        correctAnswer: 'Owl',
      ),
      CourseContent(
        id: '15',
        type: 'audio',
        question: 'Listen and identify the emotion:',
        audioUrl: 'assets/audio/laughter.mp3',
        options: ['Happiness', 'Sadness', 'Anger', 'Fear'],
        correctAnswer: 'Happiness',
      ),
      CourseContent(
        id: '16',
        type: 'audio',
        question: 'What number is being spoken?',
        audioUrl: 'assets/audio/seven.mp3',
        options: ['7', '3', '5', '9'],
        correctAnswer: '7',
      ),
    ];
    notifyListeners();
  }
}
