import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Color themeColor;
  final String typeName;

  const CustomProgressBar({
    Key? key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.themeColor,
    required this.typeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (currentIndex + 1) / totalQuestions;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress text
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$typeName Progress',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: themeColor,
                  ),
                ),
                Text(
                  '${(progressPercentage * 100).toInt()}%',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: progressPercentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Question count
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
