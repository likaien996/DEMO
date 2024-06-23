import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/models/bean_user_card.dart';
import 'package:food_deliver/pages/page_delivery_progress.dart';
import 'package:food_deliver/providers/provider_cart.dart';
import 'package:food_deliver/services/service_order.dart';
import 'package:food_deliver/services/service_user_card.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  var _cardNumberController = TextEditingController();
  var _expiryDateController = TextEditingController();
  var _cardHolderNameController = TextEditingController();
  var _cvvCodeController = TextEditingController();
  var _deliveryAddressController = TextEditingController();

  bool _showLoading = false;

  UserCard? userCard;

  void _getUserCard() async {
    var temp = await UserCardService.getLatestCard();
    userCard = temp;
    if (temp != null) {
      setState(() {
        _cardNumberController = TextEditingController(text: temp.cardNumber);
        _expiryDateController = TextEditingController(text: temp.expiryDate);
        _cardHolderNameController =
            TextEditingController(text: temp.cardHolderName);
        _cvvCodeController = TextEditingController(text: temp.cvvCode);
        _deliveryAddressController =
            TextEditingController(text: temp.deliveryAddress);
      });
    }
  }

  @override
  void initState() {
    _getUserCard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(15),
            children: [
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  hintText: "Card Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  hintText: "Expiry Date",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cardHolderNameController,
                decoration: const InputDecoration(
                  hintText: "Card Holder Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cvvCodeController,
                decoration: const InputDecoration(
                  hintText: "CVV Code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _deliveryAddressController,
                decoration: const InputDecoration(
                  hintText: "Delivery Address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                  onPressed: () {
                    _pay(context);
                  },
                  child: const Text("Pay Now")),
            ],
          ),
          _showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  void _pay(BuildContext context) async {
    var cardNumber = _cardNumberController.text;
    if (cardNumber.isEmpty) {
      myShowDialog(context, "Input cardNumber");
      return;
    }
    var expiryDate = _expiryDateController.text;
    if (expiryDate.isEmpty) {
      myShowDialog(context, "Input expiryDate");
      return;
    }
    var cardHolderName = _cardHolderNameController.text;
    if (cardHolderName.isEmpty) {
      myShowDialog(context, "Input cardHolderName");
      return;
    }
    var cvvCode = _cvvCodeController.text;
    if (cvvCode.isEmpty) {
      myShowDialog(context, "Input cvvCode");
      return;
    }
    var deliveryAddress = _deliveryAddressController.text;
    if (deliveryAddress.isEmpty) {
      myShowDialog(context, "Input Delivery Address");
      return;
    }

    var dialogRes = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Card Number: $cardNumber"),
              Text("Expiry Date: $expiryDate"),
              Text("Card Holder Name: $cardHolderName"),
              Text("CVV Code: $cvvCode"),
              Text("Delivery Address: $deliveryAddress"),
            ],
          ),
        ),
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

    if (dialogRes != true) {
      return;
    }

    setState(() {
      _showLoading = true;
    });

    var res = await UserCardService.saveCard(
      UserCard(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cardHolderName: cardHolderName,
        cvvCode: cvvCode,
        deliveryAddress: deliveryAddress,
        time: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (!context.mounted) {
      setState(() {
        _showLoading = false;
      });
      return;
    }
    if (!res) {
      setState(() {
        _showLoading = false;
      });
      myShowDialog(context, "Error");
      return;
    }

    var displayCartReceipt =
        context.read<CartProvider>().displayCartReceipt(deliveryAddress);

    var orderId = await OrderService.saveOrder(displayCartReceipt);
    setState(() {
      _showLoading = false;
    });
    if (!context.mounted) {
      return;
    }
    if (orderId.isEmpty) {
      myShowDialog(context, "Error");
      return;
    }
    context.read<CartProvider>().clearCart();
    Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (ctx) {
      return DeliveryProgressPage(orderId: orderId);
    }));
  }
}
