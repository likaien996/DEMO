import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/my_img.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/providers/provider_cart.dart';
import 'package:food_deliver/services/service_food.dart';
import 'package:food_deliver/utils/utils_logger.dart';
import 'package:provider/provider.dart';

class FoodDetailPage extends StatefulWidget {
  final String foodId;

  const FoodDetailPage({super.key, required this.foodId});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  FoodBean? _foodBean;
  bool _showLoading = false;
  final Map<String, AddonBean> _selectedAddons = {};

  bool _isSingleChoice() {
    return _foodBean?.category == "pizza";
  }

  @override
  void initState() {
    _getDetail();
    super.initState();

    var selectedAddonsByFoodId =
        context.read<CartProvider>().getSelectedAddonsByFoodId(widget.foodId);
    for (var value in selectedAddonsByFoodId) {
      _selectedAddons[value.id] = value;
    }
  }

  void _getDetail() async {
    setState(() {
      _showLoading = true;
    });
    _foodBean = await FoodService.getFood(widget.foodId);
    LoggerUtils.i(_foodBean?.availableAddons);
    setState(() {
      _showLoading = false;
    });
  }

  void _addToCart() async {
    var temp = _foodBean;
    if (temp == null) {
      return;
    }
    LoggerUtils.i(_selectedAddons);
    List<AddonBean> ids = _selectedAddons.entries.map((e) => e.value).toList();

    await context.read<CartProvider>().addToCart(temp, ids);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          _createContent(context, _foodBean),
          SafeArea(
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 15),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _showLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
          _foodBean == null && !_showLoading
              ? const Center(
                  child: Text("No data"),
                )
              : const SizedBox(),
          Positioned(
            left: 15,
            right: 15,
            bottom: 15,
            child: SafeArea(
              child: FilledButton(
                onPressed: () {
                  _addToCart();
                },
                child: const Text("Add to Cart"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createContent(BuildContext context, FoodBean? food) {
    if (food == null) {
      return const SizedBox();
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: SizedBox(
              width: double.infinity,
              child: MyImgWidget(url: food.imagePath,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'RM ${food.price.toString()}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(food.description),
                const SizedBox(height: 10),
                ...food.availableAddons.isNotEmpty
                    ? [
                        Container(height: 1, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          "Selections",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: food.availableAddons.length,
                          itemBuilder: (context, index) {
                            AddonBean addon = food.availableAddons[index];
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(addon.name),
                              subtitle: Text(
                                'RM ${addon.price}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              value: _selectedAddons[addon.id] != null,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (_isSingleChoice()) {
                                    _selectedAddons.clear();
                                    _selectedAddons[addon.id] = addon;
                                  } else {
                                    if (_selectedAddons.containsKey(addon.id)) {
                                      _selectedAddons.remove(addon.id);
                                    } else {
                                      _selectedAddons[addon.id] = addon;
                                    }
                                  }
                                });
                              },
                            );
                          },
                        )
                      ]
                    : [],
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
