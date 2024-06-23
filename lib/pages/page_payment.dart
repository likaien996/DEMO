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
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _cvvCodeController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  bool _showLoading = false;

  UserCard? userCard;

  void _getUserCard() async {
    var temp = await UserCardService.getLatestCard();
    userCard = temp;
    if (temp != null) {
      setState(() {
        _cardNumberController.text = temp.cardNumber;
        _expiryDateController.text = temp.expiryDate;
        _cardHolderNameController.text = temp.cardHolderName;
        _cvvCodeController.text = temp.cvvCode;
        _deliveryAddressController.text = temp.deliveryAddress;
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
        backgroundColor: const Color(0xFF42A5F5), // 使用现代感的蓝色
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTextField(
            controller: _cardNumberController,
            hintText: "Card Number",
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _expiryDateController,
            hintText: "Expiry Date",
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cardHolderNameController,
            hintText: "Card Holder Name",
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cvvCodeController,
            hintText: "CVV Code",
            icon: Icons.lock,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _deliveryAddressController,
            hintText: "Delivery Address",
            icon: Icons.location_on,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42A5F5), // 蓝色按钮
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF42A5F5)), // 图标使用蓝色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200], // 浅灰色背景
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  void _pay() async {
    var cardNumber = _cardNumberController.text;
    if (cardNumber.isEmpty) {
      myShowDialog(context, "Please enter card number");
      return;
    }
    var expiryDate = _expiryDateController.text;
    if (expiryDate.isEmpty) {
      myShowDialog(context, "Please enter expiry date");
      return;
    }
    var cardHolderName = _cardHolderNameController.text;
    if (cardHolderName.isEmpty) {
      myShowDialog(context, "Please enter card holder name");
      return;
    }
    var cvvCode = _cvvCodeController.text;
    if (cvvCode.isEmpty) {
      myShowDialog(context, "Please enter CVV code");
      return;
    }
    var deliveryAddress = _deliveryAddressController.text;
    if (deliveryAddress.isEmpty) {
      myShowDialog(context, "Please enter delivery address");
      return;
    }

    var dialogRes = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Payment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Card Number: $cardNumber",
                  style: const TextStyle(fontSize: 16)),
              Text("Expiry Date: $expiryDate",
                  style: const TextStyle(fontSize: 16)),
              Text("Card Holder Name: $cardHolderName",
                  style: const TextStyle(fontSize: 16)),
              Text("CVV Code: $cvvCode", style: const TextStyle(fontSize: 16)),
              Text("Delivery Address: $deliveryAddress",
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Yes", style: TextStyle(fontSize: 16)),
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

    setState(() {
      _showLoading = false;
    });

    if (!context.mounted) {
      return;
    }

    if (!res) {
      myShowDialog(context, "Error saving card details");
      return;
    }

    var displayCartReceipt =
        context.read<CartProvider>().displayCartReceipt(deliveryAddress);
    var orderId = await OrderService.saveOrder(displayCartReceipt);

    if (orderId.isEmpty) {
      myShowDialog(context, "Error processing order");
      return;
    }

    context.read<CartProvider>().clearCart();
    Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (ctx) {
      return DeliveryProgressPage(orderId: orderId);
    }));
  }
}
