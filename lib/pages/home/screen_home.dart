import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_deliver/models/bean_food_category.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/pages/home/widget_food_item.dart';
import 'package:food_deliver/pages/page_food_detail.dart';
import 'package:food_deliver/services/service_food.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<FoodCategoryBean> _tabs = [];
  final List<FoodBean> _dataList = [];

  int _currentIndex = 0;
  bool _showLoading = false;

  @override
  void initState() {
    _getFoodCategories();
    super.initState();
  }

  void _getFoodCategories() async {
    var list = await FoodService.getFoodCategories();
    setState(() {
      _tabs.clear();
      _tabs.addAll(list);
    });
    await _getFoods();
  }

  Future<void> _getFoods() async {
    if (_currentIndex < _tabs.length) {
      setState(() {
        _showLoading = true;
      });
      var list = await FoodService.getFoods(_tabs[_currentIndex].name);
      setState(() {
        _showLoading = false;
        _dataList.clear();
        _dataList.addAll(list);
      });
    }
  }

  void _changeTab(int index) async {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    await _getFoods();
  }

  @override
  Widget build(context) {
    return SafeArea(
      child: Column(
        children: [
          _topFoodCategory(context),
          Expanded(
            child: Container(
              color: const Color(0xfff8f8f8),
              child: Stack(
                children: [
                  ListView.separated(
                    padding: const EdgeInsets.all(15),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(builder: (ctx) {
                              return FoodDetailPage(
                                foodId: _dataList[index].id,
                              );
                            }),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: FoodItemWidget(food: _dataList[index]),
                      );
                    },
                    separatorBuilder: (index, context) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                    itemCount: _dataList.length,
                  ),
                  _showLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox(),
                  _dataList.isEmpty && !_showLoading
                      ? const Center(child: Text("No Data"))
                      : const SizedBox()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _topFoodCategory(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _changeTab(index);
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 64,
              width: (MediaQuery.of(context).size.width) /
                  (_tabs.isEmpty ? 1 : _tabs.length),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 15,
                ),
                alignment: Alignment.center,
                decoration: _currentIndex == index
                    ? BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      )
                    : null,
                height: 48,
                child: Text(
                  _tabs[index].name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: _currentIndex == index ? Colors.white : Colors.black,
                    fontWeight: _currentIndex == index
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: _tabs.length,
      ),
    );
  }
}
