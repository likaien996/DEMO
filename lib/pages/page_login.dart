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
          // 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)], // 从蓝绿到浅紫的渐变
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 登录页面内容
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 80),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                hintText: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                hintText: "Password",
                icon: Icons.lock,
                obscureText: _showPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildSignInButton(),
              const SizedBox(height: 40),
              _buildFooter(context),
            ],
          ),
          if (_showLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 150,
              height: 150,
              color: Colors.white.withOpacity(0.1), // 淡白色背景
              child: Center(
                child: Image.asset(
                  "assets/img/login_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "MEITUAN",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0, // 增加字间距
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        suffixIcon: suffixIcon,
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintStyle: TextStyle(color: Colors.grey[400]), // 提示文字颜色
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: () {
        _login();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.tealAccent, // 使用更亮的颜色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5, // 增加阴影
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black, // 确保文字在按钮上清晰可见
        ),
      ),
      child: const Text("Sign In"),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Not a member?",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                  return const RegisterPage();
                }));
              },
              child: const Text(
                "Register now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _resetPasswordDialog(context),
              child: const Text(
                "Reset now",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
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
