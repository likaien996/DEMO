import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/pages/admin/page_admin_home.dart';
import 'package:food_deliver/pages/page_login.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/services/service_food.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // 使用柔和的灰色背景
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFA8B8B), Color(0xFFFD7F7F)], // 柔和的粉红渐变
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF48FB1), // 使用粉红色
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AuthService.getCurrentUser()?.email ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFD81B60), // 深粉色
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildItem(
                      const Icon(Icons.exit_to_app, color: Colors.redAccent),
                      "Logout",
                      onTap: () async {
                        _signOut();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (ctx) {
            return const LoginPage();
          }),
        );
      }
    } catch (e) {
      if (mounted) {
        myShowDialog(context, "$e");
      }
    }
  }

  Widget _buildItem(Icon left, String text, {GestureTapCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            left,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  void _saveProductData() async {
    try {
      var list = await _loadJson();
      FoodService.saveProductData(list);
      LoggerUtils.i("Add success");
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  Future<List<FoodBean>> _loadJson() async {
    // 读取 JSON 文件
    String jsonString = await rootBundle.loadString('assets/foods.json');

    // 解析 JSON 数据
    List<dynamic> jsonData = json.decode(jsonString);

    // 返回解析后的数据
    return jsonData.map((e) => FoodBean.fromJson(e)).toList();
  }
}
