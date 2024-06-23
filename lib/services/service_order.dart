import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_deliver/config/config_cloud_firebase_store.dart';
import 'package:food_deliver/models/bean_order.dart';
import 'package:food_deliver/services/service_auth.dart';
import 'package:food_deliver/utils/utils_logger.dart';

class OrderService {
  const OrderService._();

  static Future<String> saveOrder(String data) async {
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return "";
      }
      var orderBean = OrderBean(
          info: data, time: DateTime.now().millisecondsSinceEpoch, userId: uid);

      var res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.orders)
          .add(
            orderBean.toJson(),
          );
      LoggerUtils.i("saveOrder success:$orderBean");
      return res.id;
    } catch (e) {
      LoggerUtils.e(e);
    }

    return "";
  }

  static Future<OrderBean?> getOrder(String data) async {
    if (data.isEmpty) {
      return null;
    }
    try {
      var uid = AuthService.getCurrentUser()?.uid;
      if (uid == null || uid.isEmpty) {
        return null;
      }

      var res = await FirebaseFirestore.instance
          .collection(CloudFirebaseStoreConfig.orders)
          .where("userId", isEqualTo: uid)
          .get();
      var list =
          res.docs.map((e) => OrderBean.fromJson(e.data(), e.id)).toList();
      LoggerUtils.i("getOrder success:$list");
      return list.where((e) => e.id == data).firstOrNull;
    } catch (e) {
      LoggerUtils.e(e);
    }

    return null;
  }
}
