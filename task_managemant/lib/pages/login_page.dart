import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  final email = TextEditingController();
  final password = TextEditingController();
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Color(0xFF1976D2), foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            Obx(
              () => controller.isLoading.value
                  ? CircularProgressIndicator(color: Color(0xFF1976D2))
                  : ElevatedButton(
                      onPressed: () =>
                          controller.login(email.text, password.text),
                      child: Text("Login"),
                    ),
            ),
            TextButton(
              onPressed: () => Get.to(SignupPage()),
              child: Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
