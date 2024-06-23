import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_deliver/common_widget/dialog_my.dart';
import 'package:food_deliver/common_widget/my_img.dart';
import 'package:food_deliver/models/bean_food_category.dart';
import 'package:food_deliver/models/food.dart';
import 'package:food_deliver/services/service_food.dart';
import 'package:food_deliver/services/service_upload.dart';
import 'package:food_deliver/utils/utils_logger.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodPage extends StatefulWidget {
  final FoodBean? food;

  const AddFoodPage({super.key, this.food});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final ImagePicker _imagePicker = ImagePicker();

  List<FoodCategoryBean> _categoryList = [];
  final List<AddonBean> _addonsList = [];

  String _imagePath = "";
  FoodCategoryBean? _category;

  late TextEditingController _nameTextEditingController;
  late TextEditingController _descTextEditingController;
  late TextEditingController _priceTextEditingController;

  @override
  void initState() {
    _initData();
    _imagePath = widget.food?.imagePath ?? "";
    _nameTextEditingController =
        TextEditingController(text: widget.food?.name ?? "");
    _descTextEditingController =
        TextEditingController(text: widget.food?.description ?? "");
    var price = widget.food?.price;
    if (price != null) {
      _priceTextEditingController = TextEditingController(text: "$price");
    } else {
      _priceTextEditingController = TextEditingController();
    }
    _addonsList.addAll(widget.food?.availableAddons ?? []);

    super.initState();
  }

  void _initData() async {
    _categoryList = await FoodService.getFoodCategories();
    var category = widget.food?.category;
    if (category != null && category.isNotEmpty) {
      _category = _categoryList.firstWhere((test) => test.name == category);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.food == null
            ? const Text("Add Food")
            : const Text("Update Food"),
        actions: widget.food == null
            ? [
                TextButton(
                  onPressed: () {
                    _submitData(context);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ]
            : [
                IconButton(
                  onPressed: () {
                    _deleteFood(context);
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    _submitData(context);
                  },
                  icon: const Icon(Icons.check),
                ),
              ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        children: [
          _buildHeader(
            "Category",
          ),
          DropdownButtonFormField<FoodCategoryBean>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _category,
            hint: const Text("Select"),
            onChanged: (FoodCategoryBean? newValue) {
              _category = newValue;
            },
            items: _categoryList.map<DropdownMenuItem<FoodCategoryBean>>(
                (FoodCategoryBean value) {
              return DropdownMenuItem<FoodCategoryBean>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
          _buildHeader(
            "Food Name",
          ),
          TextField(
            controller: _nameTextEditingController,
            decoration: const InputDecoration(
              hintText: "input",
              border: OutlineInputBorder(),
            ),
          ),
          _buildHeader(
            "Price",
          ),
          TextField(
            controller: _priceTextEditingController,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: "input",
              border: OutlineInputBorder(),
            ),
          ),
          _buildHeader(
            "Description",
          ),
          TextField(
            maxLines: null,
            controller: _descTextEditingController,
            decoration: const InputDecoration(
              hintText: "input",
              border: OutlineInputBorder(),
            ),
          ),
          _buildHeader(
            "Cover",
          ),
          _buildAddPic(),
          _buildHeader("Addons", isNeed: false),
          _buildAddons(context),
          GestureDetector(
            onTap: () {
              _showDialog(context);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  Text("Add Addon"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPic() {
    final list = <Widget>[];
    if (_imagePath.isEmpty) {
      list.add(GestureDetector(
        onTap: () {
          _addPic();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add),
        ),
      ));
    } else {
      list.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 100,
            height: 100,
            child: MyImgWidget(
              url: _imagePath,
            ),
          ),
        ),
      );
      list.add(
        Positioned(
          top: 0,
          left: 76,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(
                () {
                  _imagePath = "";
                },
              );
            },
            child: const Icon(Icons.cancel),
          ),
        ),
      );
    }
    return Stack(
      children: list,
    );
  }

  void _addPic() async {
    try {
      var pickImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickImage == null) {
        return;
      }

      _imagePath = await UploadService.uploadPic(pickImage.path);
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  void _showDialog(BuildContext context, {AddonBean? data}) async {
    late TextEditingController nameTextEditingController;
    late TextEditingController priceTextEditingController;
    if (data == null) {
      priceTextEditingController = TextEditingController();
      nameTextEditingController = TextEditingController();
    } else {
      priceTextEditingController = TextEditingController(text: "${data.price}");
      nameTextEditingController = TextEditingController(text: data.name);
    }

    final res = await showDialog<AddonBean>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(
                "Name",
              ),
              TextField(
                controller: nameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "input",
                  border: OutlineInputBorder(),
                ),
              ),
              _buildHeader(
                "Price",
              ),
              TextField(
                controller: priceTextEditingController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: "input",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                var name = nameTextEditingController.text;
                if (name.isEmpty) {
                  return;
                }
                var price = priceTextEditingController.text;
                if (price.isEmpty) {
                  return;
                }
                var tryParse = num.tryParse(price);
                if (tryParse == null) {
                  return;
                }

                if (data != null) {
                  data.price = tryParse;
                  data.name = name;
                  Navigator.of(context).pop(data);
                } else {
                  Navigator.of(context).pop(
                    AddonBean(
                        name: name,
                        price: tryParse,
                        id: "${DateTime.now().millisecondsSinceEpoch}"),
                  );
                }
              },
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
    if (res != null && context.mounted) {
      if (data == null) {
        _addonsList.add(res);
      }
      setState(() {});
    }
  }

  _buildAddons(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Container(height: 1, color: Colors.grey);
      },
      itemBuilder: (context, index) {
        var addonBean = _addonsList[index];
        return Container(
          padding: const EdgeInsets.only(top: 5, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addonBean.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "RM ${addonBean.price}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _addonsList.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete))
            ],
          ),
        );
      },
      itemCount: _addonsList.length,
    );
  }

  void _submitData(BuildContext context) async {
    final category = _category;
    if (category == null) {
      myShowDialog(context, "Category");
      return;
    }
    var name = _nameTextEditingController.text;
    if (name.isEmpty) {
      myShowDialog(context, "Food Name");
      return;
    }

    var tempPrice = _priceTextEditingController.text;
    var price = num.tryParse(tempPrice);
    if (price == null) {
      myShowDialog(context, "Price");
      return;
    }

    var description = _descTextEditingController.text;
    if (description.isEmpty) {
      myShowDialog(context, "Description");
      return;
    }
    var imagePath = _imagePath;

    if (imagePath.isEmpty) {
      myShowDialog(context, "Cover");
      return;
    }
    var foodBean = FoodBean(
        id: widget.food?.id ?? "",
        name: name,
        description: description,
        imagePath: imagePath,
        price: price,
        category: category.name,
        availableAddons: _addonsList);
    final res = await FoodService.addOrUpdateFood(foodBean);
    if (context.mounted) {
      if (res) {
        Navigator.of(context).pop();
      } else {
        myShowDialog(context, "Error");
      }
    }
  }

  _deleteFood(BuildContext context) async {
    var res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Delete ${widget.food?.name}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
    if (!context.mounted) {
      return;
    }
    if (res == null) {
      return;
    }
    if (!res) {
      return;
    }
    var id = widget.food?.id;
    if (id == null || id.isEmpty) {
      return;
    }
    var res2 = await FoodService.deleteFood(id);
    if (!context.mounted) {
      return;
    }
    if(res2){
      Navigator.of(context).pop();
    }else{
      myShowDialog(context, "Delete Error");
    }
  }
}

Widget _buildHeader(String name, {bool isNeed = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: isNeed ? "*" : " ",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    ),
  );
}
