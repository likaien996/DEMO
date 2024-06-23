import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/config/config_cloud_firebase_store.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/pages/admin/page_add_food.dart';
import 'package:food_deliver/pages/home/widget_food_item.dart';
import 'package:food_deliver/pages/page_login.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection(CloudFirebaseStoreConfig.foods)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Manager"),
        actions: [
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) {
                    return const AddFoodPage();
                  },
                ),
              );
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var dataRes = snapshot.data;
          if (dataRes == null) {
            return const Center(child: Text('NO Data'));
          }
          List<FoodBean> dataList = [];
          for (var doc in dataRes.docs) {
            var data = doc.data();
            LoggerUtils.i(data);
            if (data is Map<String, dynamic>) {
              var food = FoodBean.fromJson(data);
              food.id = doc.id;
              dataList.add(food);
            }
          }
          if (dataList.isEmpty) {
            return const Center(child: Text('NO Data'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) {
                      return AddFoodPage(
                        food: dataList[index],
                      );
                    }),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: FoodItemWidget(food: dataList[index]),
              );
            },
            separatorBuilder: (index, context) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: dataList.length,
          );
        },
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
}
