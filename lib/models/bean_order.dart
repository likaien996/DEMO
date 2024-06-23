class OrderBean {
  late String id;
  late String info;
  late int time;
  late String userId;

  OrderBean({
    this.id = "",
    required this.info,
    required this.time,
    this.userId = "",
  });

  OrderBean.fromJson(Map<String, dynamic> json, this.id) {
    info = json['info'];
    time = json['time'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "info": info,
        "userId": userId,
        "time": time,
      };
}
