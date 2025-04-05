import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/views/pages/main_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:frontend/views/pages/home_page.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Check if the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => errorMessage = e.message ?? 'Login failed');
        }
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      print(e.toString());
      setState(() => errorMessage = "Google sign-in failed. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight - 32),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Get Started now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create an account or log in to explore about our app',
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(Icons.email, 'Email', emailController),
                        const SizedBox(height: 12),
                        _buildInputField(
                            Icons.lock, 'Password', passwordController,
                            isPassword: true),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(errorMessage!,
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        const SizedBox(height: 20),
                        _buildButton("Log In", signInWithEmail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:
                          Text("Or", style: TextStyle(color: Colors.white70)),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ]),
                  const SizedBox(height: 16),
                  Center(
                    child: _buildSocialButton("Continue with Google",
                        "assets/google.png", signInWithGoogle),
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpPage()),
                        );
                      },
                      child: Text("Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.amber)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      IconData icon, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      validator: (value) =>
          (value == null || value.isEmpty) ? '$hint cannot be empty' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.amber),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }

  Widget _buildSocialButton(String text, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(iconPath, height: 24),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: Colors.white)),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
