import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_deliver/config/config_cloud_firebase_store.dart';
import 'package:food_deliver/models/bean_food_category.dart';
import 'package:food_deliver/models/cart_item.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class FoodService {
  const FoodService._();

  static Future<List<FoodCategoryBean>> getFoodCategories() async {
    try {
      final res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.foodCategories)
          .orderBy("sort", descending: true)
          .get();
      for (var item in res.docs) {
        LoggerUtils.i(item.data());
      }
      return res.docs.map((e) => FoodCategoryBean.fromJson(e.data())).toList();
    } catch (e) {
      LoggerUtils.e(e);
    }
    return [];
  }

  static Future<List<FoodBean>> getFoods(String category) async {
    try {
      final res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.foods)
          .where("category", isEqualTo: category)
          .get();
      for (var item in res.docs) {
        LoggerUtils.i(item.data());
      }
      return res.docs.map((e) {
        var data = FoodBean.fromJson(e.data());
        data.id = e.id;
        return data;
      }).toList();
    } catch (e) {
      LoggerUtils.e(e);
    }
    return [];
  }

  static Future<FoodBean?> getFood(String foodId) async {
    try {
      final res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.foods)
          .doc(foodId)
          .get();
      var data = res.data();
      if (data != null) {
        var foodBean = FoodBean.fromJson(data);
        foodBean.id = res.id;
        return foodBean;
      }
    } catch (e) {
      LoggerUtils.e(e);
    }
    return null;
  }

  static Future<bool> deleteFood(String foodId) async {
    try {
      await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.foods)
          .doc(foodId)
          .delete();
      return true;
    } catch (e) {
      LoggerUtils.e(e);
    }
    return false;
  }

  static Future<bool> addOrUpdateFood(FoodBean food) async {
    try {
      if (food.id.isEmpty) {
        await FirebaseFirestore.instance
            .collection(CloudFirebaseStoreConfig.foods)
            .add(food.toJson());
      } else {
        await FirebaseFirestore.instance
            .collection(CloudFirebaseStoreConfig.foods)
            .doc(food.id)
            .set(food.toJson());
      }
      return true;
    } catch (e) {
      LoggerUtils.e(e);
    }
    return false;
  }

  static Future<List<CartItem>> getCartList() async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return [];
      }
      final docRef = FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.userCart)
          .doc(uid);
      final res = await docRef.get();
      var data = res.data();
      if (data == null) {
        return [];
      }
      var userInfoBean = UserInfoBean.fromJson(data);
      if (userInfoBean.carts.isEmpty) {
        return [];
      }
      return userInfoBean.carts;
    } catch (e) {
      LoggerUtils.e(e);
    }
    return [];
  }

  static Future<void> clearCart() async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return;
      }

      await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.userCart)
          .doc(uid)
          .delete();
      LoggerUtils.i("clearCart success");
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  static void saveProductData(List<FoodBean> dataList) async {
    final docRef =
        FirebaseFirestore.instance.collection(CloudFirebaseStoreConfig.foods);
    var querySnapshot = await docRef.get();
    for (var value in querySnapshot.docs) {
      await docRef.doc(value.id).delete();
    }
    for (var value1 in dataList) {
      await docRef.add(value1.toJson());
    }
  }

  static Future<void> saveCart(List<CartItem> cartItems) async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return;
      }

      await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.userCart)
          .doc(uid)
          .set(UserInfoBean(carts: cartItems).toJson());
      LoggerUtils.i("saveCart success");
    } catch (e) {
      LoggerUtils.e(e);
    }
  }
}
