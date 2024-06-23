import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/pages/home/page_home.dart';
import 'package:food_deliver/pages/page_register.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

import 'admin/page_admin_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = true;
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              const SizedBox(
                height: 100,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 200,
                  child: Image.asset(
                    "assets/img/login_bg.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "MEITUAN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _showPassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  _login();
                },
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not a member?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (ctx) {
                        return const RegisterPage();
                      }));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      "Register now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Forgot Password?",
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _resetPasswordDialog(context),
                    child: const Text(
                      "Reset now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty) {
      myShowDialog(context, "Input Email");
      return;
    }
    if (_passwordController.text.isEmpty) {
      myShowDialog(context, "Input Password");
      return;
    }
    setState(() {
      _showLoading = true;
    });
    try {
      await AuthService.signInWithEmailPassword(
          _emailController.text, _passwordController.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (ctx) {
            if (_emailController.text == "admin@gmail.com") {
              return const AdminHomePage();
            }
            return const HomePage();
          }),
        );
      }
    } catch (e) {
      LoggerUtils.e(e);
      if (mounted) {
        myShowDialog(context, "$e");
      }
    } finally {
      setState(() {
        _showLoading = false;
      });
    }
  }

  void _resetPasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        TextEditingController resetEmailController = TextEditingController();
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(
              hintText: "Input your Email",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _resetPassword(context, resetEmailController.text);
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  void _resetPassword(BuildContext context, String text) async {
    try {
      if (text.isEmpty) {
        return;
      }
      await AuthService.sendPasswordResetEmail(text);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset link has been sent to your email")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send password reset email: $e")),
        );
      }
    }
  }
}
