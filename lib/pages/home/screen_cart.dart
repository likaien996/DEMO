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
        backgroundColor: Colors.white,
        leading: null,
        title: const Text("Cart"),
        actions: [
          IconButton(
            onPressed: () {
              _clearCartDialog(context);
            },
            icon: const Icon(Icons.delete),
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
                      child: Text("Your cart is empty.."),
                    ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 54,
              child: Row(
                children: [
                  Expanded(child: Text(cartProvider.formatTotalPrice())),
                  FilledButton(
                      onPressed: () {
                        if (cartProvider.cartItems.isNotEmpty) {
                          Navigator.of(context)
                              .push(CupertinoPageRoute(builder: (ctx) {
                            return const PaymentPage();
                          }));
                        }
                      },
                      child: const Text("Go to checkout"))
                ],
              ),
            )
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
                    width: 100,
                    height: 100,
                    child: MyImgWidget(
                      url: cartItem.food.imagePath,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // food name and price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // food name
                    Text(
                      cartItem.food.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                    // food price
                    Text(
                      'RM${cartItem.food.price}',
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
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: cartItem.selectedAddons.isEmpty ? 0 : 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  var addon = cartItem.selectedAddons[index];
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Row(
                      children: [
                        Text(
                          addon.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          ' (RM${addon.price})',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(
                    width: 10,
                  );
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

  const QuantitySelector(
      {super.key,
      required this.quantity,
      required this.food,
      required this.onIncrement,
      required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(8),
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
