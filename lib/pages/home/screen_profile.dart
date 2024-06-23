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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_circle,
            size: 80,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(AuthService
              .getCurrentUser()
              ?.email ?? ""),
          const SizedBox(
            height: 20,
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.white,
            child: Column(
              children: [
                _buildItem(
                  const Icon(Icons.exit_to_app),
                  "logout",
                  onTap: () async {
                    _signOut();
                  },
                ),
                // _buildItem(
                //   const Icon(Icons.data_array),
                //   "add product data",
                //   onTap: () {
                //     Navigator.of(context).push(
                //       CupertinoPageRoute(builder: (ctx) {
                //         return const AdminHomePage();
                //       }),);
                //   },
                // )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context)
            .pushReplacement(CupertinoPageRoute(builder: (ctx) {
          return const LoginPage();
        }));
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[350]!))),
        child: Row(
          children: [
            left,
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(text),
            ),
            const Icon(Icons.arrow_forward_ios)
          ],
        ),
      ),
    );
  }

  void _saveProductData() async {
    try {
      var list = await _loadJson();

      FoodService.saveProductData(list);
      LoggerUtils.i("add success");
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
