import 'package:flutter/material.dart';
import 'package:food_deliver/models/cart_item.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/services/service_food.dart';
import 'package:food_deliver/utils/utils_logger.dart';
import 'package:intl/intl.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems.toList();

  CartProvider() {
    _refreshData();
  }

  List<AddonBean> getSelectedAddonsByFoodId(String foodId) {
    for (var value in _cartItems) {
      if (value.food.id == foodId) {
        return value.selectedAddons;
      }
    }
    return [];
  }

  void _refreshData() async {
    var cartList = await FoodService.getCartList();
    LoggerUtils.i(cartList);

    _cartItems = cartList;
    notifyListeners();
  }

  Future<bool> addToCart(FoodBean food, List<AddonBean> selectedAddons) async {
    _cartItems.removeWhere((e) => e.food.id == food.id);
    _cartItems = [
      ..._cartItems,
      CartItem(food: food, selectedAddons: selectedAddons)
    ];
    await FoodService.saveCart(_cartItems);
    notifyListeners();
    return true;
  }

  void onIncrementOrDecrement(CartItem item, bool state) async {
    if (state) {
      item.quantity++;
    } else {
      item.quantity--;
    }
    if (item.quantity <= 0) {
      _cartItems.removeWhere((e) => e.food.id == item.food.id);
    }
    _cartItems = [..._cartItems];
    notifyListeners();
    await FoodService.saveCart(_cartItems);
  }

  Future<void> clearCart() async {
    _cartItems = [];
    notifyListeners();
    await FoodService.clearCart();
  }

  num _getTotalPrice() {
    num total = 0.0;
    for (CartItem cartItem in _cartItems) {
      total += cartItem.totalPrice;
    }
    return total;
  }

  String formatTotalPrice() {
    return "RM ${_getTotalPrice().toStringAsFixed(2)}";
  }

  String _formatPrice(num price) {
    return "RM ${price.toStringAsFixed(2)}";
  }

  String displayCartReceipt(String deliveryAddress) {
    final receipt = StringBuffer();
    receipt.writeln("Here is your receipt.");
    receipt.writeln();

    String formattedDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln("-----------");
    receipt.writeln("Order Details");
    receipt.writeln("-----------");

    for (final cartItem in _cartItems) {
      receipt.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt.writeln("Addons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      receipt.writeln();
    }
    receipt.writeln("-----------");
    receipt.writeln();
    receipt.writeln("Total Items: ${_getTotalItemCount()}");
    receipt.writeln("Total Price: ${_formatPrice(_getTotalPrice())}");
    receipt.writeln("Delivery Address: $deliveryAddress");
    return receipt.toString();
  }

  int _getTotalItemCount() {
    int totalItemCount = 0;
    for (CartItem cartItem in _cartItems) {
      totalItemCount += cartItem.quantity;
    }
    return totalItemCount;
  }

  String _formatAddons(List<AddonBean> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }
}
