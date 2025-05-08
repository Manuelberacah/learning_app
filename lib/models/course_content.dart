class CourseContent {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? imageUrl;
  final String? audioUrl;

  CourseContent({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.imageUrl,
    this.audioUrl,
  });

  factory CourseContent.fromJson(Map<String, dynamic> json) {
    return CourseContent(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
    );
  }

  // Helper method to fix asset paths
  String? get fixedImageUrl {
    if (imageUrl == null) return null;
    
    // If it's a network URL, return as is
    if (imageUrl!.startsWith('http')) return imageUrl;
    
    // Fix duplicated 'assets/' prefix if needed
    if (imageUrl!.startsWith('assets/assets/')) {
      return imageUrl!.replaceFirst('assets/', '');
    }
    
    // Ensure assets/ prefix
    if (!imageUrl!.startsWith('assets/')) {
      return 'assets/$imageUrl';
    }
    
    return imageUrl;
  }

  // Helper method to fix audio paths
  String? get fixedAudioUrl {
    if (audioUrl == null) return null;
    
    // If it's a network URL, return as is
    if (audioUrl!.startsWith('http')) return audioUrl;
    
    // Fix duplicated 'assets/' prefix if needed
    if (audioUrl!.startsWith('assets/assets/')) {
      return audioUrl!.replaceFirst('assets/', '');
    }
    
    // Ensure assets/ prefix
    if (!audioUrl!.startsWith('assets/')) {
      return 'assets/$audioUrl';
    }
    
    return audioUrl;
  }
}
