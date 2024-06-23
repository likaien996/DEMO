import 'package:flutter/material.dart';
import 'package:food_deliver/common_widget/my_img.dart';
import 'package:food_deliver/models/food.dart';

class FoodItemWidget extends StatelessWidget {
  final FoodBean food;

  const FoodItemWidget({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text('RM ${food.price}'),
                      const SizedBox(height: 10),
                      Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: MyImgWidget(
                      url: food.imagePath,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
