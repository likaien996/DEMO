class FoodCategoryBean {
  late String name;
  late int sort;

  FoodCategoryBean({this.name = "", this.sort = 0});

  FoodCategoryBean.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    sort = json['sort'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["name"] = name;
    data["price"] = sort;
    return data;
  }
}
