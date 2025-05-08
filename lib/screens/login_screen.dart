import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/providers/auth_provider.dart';
import 'package:learning_app/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    // In a real app, you would call an API to request OTP
    setState(() {
      _isOtpSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent to your email/phone')),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text,
      '', // Phone is empty as we're using email
      _otpController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sheshya Learning',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              if (_isOtpSent) ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
              ],
              CustomButton(
                text: _isOtpSent ? 'Login' : 'Request OTP',
                isLoading: authProvider.isLoading,
                onPressed:
                    authProvider.isLoading
                        ? null
                        : _isOtpSent
                        ? _login
                        : _requestOtp,
              ),
              const SizedBox(height: 16),
              if (_isOtpSent)
                TextButton(
                  onPressed: _requestOtp,
                  child: const Text('Resend OTP'),
                ),
              const SizedBox(height: 24),
              // For testing purposes, auto-fill with test credentials
              TextButton(
                onPressed: () {
                  _emailController.text = 'testStudent@sheshya.in';
                  _otpController.text = '123456';
                  setState(() {
                    _isOtpSent = true;
                  });
                },
                child: const Text('Use Test Credentials'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
