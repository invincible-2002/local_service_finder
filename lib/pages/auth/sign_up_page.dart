import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final service = AuthService();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _signUp,
                child: loading
                    ? const CircularProgressIndicator(color: Color.fromARGB(255, 199, 144, 144))
                    : const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _signUp() async {
  if (passwordController.text != confirmController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => loading = true);

  try {
    await service.signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Fix: Check if widget is still mounted before using context
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Check your email to verify your account!"),
        duration: Duration(seconds: 5),
      ),
    );

    Navigator.pop(context);
  } catch (e) {
    // Fix: Check if widget is still mounted before using context
    if (!mounted) return;
    
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
  }

  setState(() => loading = false);
}
  
}
