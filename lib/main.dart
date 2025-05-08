import 'package:flutter/material.dart';
import 'package:learning_app/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/providers/auth_provider.dart';
import 'package:learning_app/providers/content_provider.dart';
import 'package:learning_app/screens/login_screen.dart';
import 'package:learning_app/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: MaterialApp(
        title: 'Sheshya Learning',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isAuthenticated
                ? const HomeScreen()
                : const HomeScreen();
          },
        ),
      ),
    );
  }
}
