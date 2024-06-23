import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/my_img.dart';
import 'package:food_deliver/models/cart_item.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/pages/page_payment.dart';
import 'package:food_deliver/providers/provider_cart.dart';
import 'package:food_deliver/services/service_food.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _clearCartDialog(context);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
          )
        ],
      ),
      body: Consumer<CartProvider>(builder: (context, cartProvider, child) {
        return Column(
          children: [
            Expanded(
              child: cartProvider.cartItems.isNotEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.all(15),
                      itemBuilder: (context, index) {
                        return MyCartTile(
                            cartItem: cartProvider.cartItems[index]);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 15,
                        );
                      },
                      itemCount: cartProvider.cartItems.length,
                    )
                  : const Center(
                      child: Text(
                        "Your cart is empty..",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cartProvider.formatTotalPrice(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (cartProvider.cartItems.isNotEmpty) {
                        Navigator.of(context)
                            .push(CupertinoPageRoute(builder: (ctx) {
                          return const PaymentPage();
                        }));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black26,
                      elevation: 5,
                    ),
                    child: const Text(
                      "Go to checkout",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _clearCartDialog(BuildContext context) async {
    var res = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure you want to clear your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (!context.mounted) {
      return;
    }
    if (res != true) {
      return;
    }
    await context.read<CartProvider>().clearCart();
  }
}

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;

  const MyCartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, provider, child) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                      width: 80,
                      height: 80,
                      child: MyImgWidget(
                        url: cartItem.food.imagePath,
                      )),
                ),

                const SizedBox(width: 15),
                // food name and price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // food name
                      Text(
                        cartItem.food.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // food price
                      Text(
                        'RM${cartItem.food.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // increment or decrement quantity
                      QuantitySelector(
                        quantity: cartItem.quantity,
                        food: cartItem.food,
                        onIncrement: () {
                          provider.onIncrementOrDecrement(cartItem, true);
                        },
                        onDecrement: () {
                          provider.onIncrementOrDecrement(cartItem, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (cartItem.selectedAddons.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index) {
                    var addon = cartItem.selectedAddons[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.teal,
                      ),
                      child: Center(
                        child: Text(
                          '${addon.name} (RM${addon.price.toStringAsFixed(2)})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 10);
                  },
                  itemCount: cartItem.selectedAddons.length,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final FoodBean food;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.food,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Icon(
              Icons.remove,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 20,
              child: Center(
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
