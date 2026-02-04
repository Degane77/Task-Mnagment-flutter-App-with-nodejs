import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignupPage extends StatelessWidget {
  // Text controllers for user input fields
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  // Getting the AuthController instance using GetX
  final controller = Get.find<AuthController>();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors (You can change these easily)
    const primaryColor = Color(0xFF6A1B9A); // Deep Purple
    const backgroundColor = Color(0xFFF4F1FA); // Soft light background

    return Scaffold(
      backgroundColor: backgroundColor,

      // Top AppBar
      appBar: AppBar(
        title: const Text("Signup"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // Name Input Field
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: "Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Email Input Field
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Password Input Field
            TextField(
              controller: password,
              obscureText: true, // Hides the password text
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Signup Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // When user presses signup
              onPressed: () {
                // Call signup function from controller
                controller.signup(name.text, email.text, password.text);
              },

              child: const Text(
                "Signup",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
