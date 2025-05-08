import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/providers/auth_provider.dart';
import 'package:learning_app/providers/content_provider.dart';
import 'package:learning_app/screens/question_type_manager.dart';
import 'package:learning_app/widgets/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _classes = [
    'KG1',
    'KG2',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
  ];
  String _selectedClass = 'KG1';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load content for default class
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );

    await contentProvider.fetchCourseContent(
      authProvider.token ?? '',
      _selectedClass,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _startLearning() {
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );
    if (contentProvider.courseContents.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionTypeManager(
            contents: contentProvider.courseContents,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No content available. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final contentProvider = Provider.of<ContentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sheshya Learning',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authProvider.logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to Sheshya Learning!',
              style: GoogleFonts.montserrat(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Select your class:',
              style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedClass,
                isExpanded: true,
                underline: const SizedBox(),
                items:
                    _classes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedClass = newValue;
                    });
                    _loadContent();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Start Learning',
              isLoading: _isLoading || contentProvider.isLoading,
              onPressed:
                  (_isLoading || contentProvider.isLoading)
                      ? null
                      : _startLearning,
              color: Colors.indigo,
            ),
            const SizedBox(height: 24),
            if (contentProvider.error != null)
              Text(
                'Error: ${contentProvider.error}',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 80, color: Colors.indigo),
                    SizedBox(height: 16),
                    Text(
                      'Learn through interactive questions!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
