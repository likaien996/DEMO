import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = true;
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              const SizedBox(
                height: 100,
              ),
              const Icon(
                Icons.lock_open_rounded,
                size: 200,
              ),
              const SizedBox(height: 25),
              const Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 16,
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: _showPassword,
                decoration: InputDecoration(
                  hintText: "Confirm Password",
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
                  _register(context);
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      "Login now",
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

  void _register(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      myShowDialog(context, "Input Email");
      return;
    }
    if (_passwordController.text.isEmpty) {
      myShowDialog(context, "Input Password");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      myShowDialog(context, "Password != Confirm Password");
      return;
    }
    try {
      setState(() {
        _showLoading = true;
      });
      await AuthService.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      LoggerUtils.e(e);
      if (context.mounted) {
        myShowDialog(context, "$e");
      }
    } finally {
      setState(() {
        _showLoading = false;
      });
    }
  }
}
