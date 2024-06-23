import 'package:flutter/material.dart';
import 'package:food_deliver/models/bean_order.dart';
import 'package:food_deliver/services/service_order.dart';

class DeliveryProgressPage extends StatefulWidget {
  final String orderId;

  const DeliveryProgressPage({super.key, required this.orderId});

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  OrderBean? _orderBean;

  @override
  void initState() {
    _getOrder();
    super.initState();
  }

  void _getOrder() async {
    _orderBean = await OrderService.getOrder(widget.orderId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Delivery Progress',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD1DC), Color(0xFFFFC0CB)], // 粉色渐变
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _orderBean == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black54))
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  const SizedBox(height: 120), // 调整位置
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Thank you for your order!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE91E63), // 使用较深的粉色
                              shadows: [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black12,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 12,
                          shadowColor: Colors.black26,
                          color: Colors.white.withOpacity(0.95),
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.receipt,
                                  color: Color(0xFFE91E63),
                                  size: 60,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  _orderBean?.info ??
                                      "Loading order details...",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Your package is estimated to arrive within 20 ~ 25 minutes. Thank you for your patience.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 2.0,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.delivery_dining,
                          color: Color(0xFFE91E63),
                          size: 100,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 4.0,
                              color: Colors.black12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFE91E63), // 使用较深的粉色
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -2),
            blurRadius: 6.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Icon
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFE91E63),
              size: 50,
            ),
          ),
          // Driver details
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kamal Jit Singh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const Text(
                "Driver",
                style: TextStyle(
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Action buttons
          Row(
            children: [
              // Message button
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                elevation: 5,
                child: const Icon(Icons.message, color: Color(0xFFE91E63)),
              ),
              const SizedBox(width: 10),
              // Call button
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                elevation: 5,
                child: const Icon(Icons.call, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
