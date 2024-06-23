import 'food.dart';

class UserInfoBean {
  late List<CartItem> carts;

  UserInfoBean({
    required this.carts,
  });

  UserInfoBean.fromJson(Map<String, dynamic>? json) {
    carts = (json?['carts'] as List<dynamic>?)
            ?.map((cartJson) => CartItem.fromJson(cartJson))
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() => {
        "carts": carts.map((e) => e.toJson()),
      };
}

class CartItem {
  late FoodBean food;
  late List<AddonBean> selectedAddons;
  late int quantity;

  num get totalPrice {
    num tmp = 0;
    if (food.category == "pizza") {
      for (var value in selectedAddons) {
        tmp += value.price;
      }
      return tmp * quantity;
    }
    for (var value in selectedAddons) {
      tmp += value.price;
    }
    return (food.price + tmp) * quantity;
  }

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
  });

  CartItem.fromJson(Map<String, dynamic> json) {
    food = FoodBean.fromJson(json['food']);
    quantity = json['quantity'];
    selectedAddons = (json['selectedAddons'] as List<dynamic>?)
            ?.map((cartJson) => AddonBean.fromJson(cartJson))
            .toList() ??
        [];
  }

  Map<String, dynamic> toJson() => {
        "food": food.toJson(),
        "quantity": quantity,
        "selectedAddons": selectedAddons.map((e) => e.toJson()).toList(),
      };
}
