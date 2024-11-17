import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Lucerna/login_page.dart';
import 'package:Lucerna/main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _errorMessage = null;
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to login page after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(80, 80, 80, 50),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Register',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(_emailController, 'Email'),
                            const SizedBox(height: 20),
                            _buildTextField(_passwordController, 'Password', hide: true),
                            const SizedBox(height: 20),
                            _buildTextField(_confirmPasswordController, 'Confirm Password', hide: true),
                            const SizedBox(height: 20),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 20),
                            _buildRegisterButton(),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              child: Text('Already have an account? Log in'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool hide = false}) {
    return TextFormField(
      controller: controller,
      obscureText: hide,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label cannot be empty.';
        }
        if (label == 'Email' && !_isValidEmail(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _register();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 8.5),
        ),
        child: Text(
          'Register',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
