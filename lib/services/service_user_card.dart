import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_deliver/config/config_cloud_firebase_store.dart';
import 'package:food_deliver/models/bean_food_category.dart';
import 'package:food_deliver/models/bean_user_card.dart';
import 'package:food_deliver/models/cart_item.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class UserCardService {
  const UserCardService._();

  static Future<List<UserCard>> getUserCards() async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return [];
      }

      final res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.userCard)
          .where("userId", isEqualTo: uid)
          .get();

      return res.docs.map((e) => UserCard.fromJson(e.data())).toList();
    } catch (e) {
      LoggerUtils.e(e);
    }
    return [];
  }

  static Future<UserCard?> getLatestCard() async {
    var userCards = await getUserCards();
    userCards.sort((a, b) => b.time.compareTo(a.time));
    return userCards.firstOrNull;
  }

  static Future<bool> saveCard(UserCard userCard) async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return false;
      }

      userCard.userId = uid;

      await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.userCard)
          .add(userCard.toJson());
      return true;
    } catch (e) {
      LoggerUtils.e(e);
    }
    return false;
  }
}
