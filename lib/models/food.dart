class FoodBean {
  late String id;
  late String name;
  late String description;
  late String imagePath;
  late num price;
  late String category;
  late List<AddonBean> availableAddons;

  FoodBean({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddons,
  });

  FoodBean.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imagePath = json['imagePath'];
    price = json['price'];
    category = json['category'];
    availableAddons = [];
    var aa = json['availableAddons'];
    if (aa is List<dynamic>) {
      for (var value in aa) {
        availableAddons.add(AddonBean.fromJson(value));
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["id"] = id;
    data["name"] = name;
    data["description"] = description;
    data["imagePath"] = imagePath;
    data["price"] = price;
    data["category"] = category;
    data["availableAddons"] = availableAddons.map((e) => e.toJson());
    return data;
  }
}

class AddonBean {
  late String name;
  late String id;
  late num price;

  AddonBean({
    required this.name,
    required this.price,
    required this.id,
  });

  AddonBean.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["name"] = name;
    data["price"] = price;
    data["id"] = id;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddonBean && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
