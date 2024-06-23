class UserCard {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  late String deliveryAddress;
  late String userId;
  late int time;

  UserCard({
    this.cardNumber = '',
    this.expiryDate = '',
    this.cardHolderName = '',
    this.cvvCode = '',
    this.userId = '',
    this.deliveryAddress = '',
    this.time = 0,
  });

  UserCard.fromJson(Map<String, dynamic>? json) {
    cardNumber = json?['cardNumber'] ?? "";
    expiryDate = json?['expiryDate'] ?? "";
    cardHolderName = json?['cardHolderName'] ?? "";
    cvvCode = json?['cvvCode'] ?? "";
    userId = json?['userId'] ?? "";
    deliveryAddress = json?['deliveryAddress'] ?? "";
    time = json?['time'] ?? "";
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["cardNumber"] = cardNumber;
    data["expiryDate"] = expiryDate;
    data["cardHolderName"] = cardHolderName;
    data["cvvCode"] = cvvCode;
    data["userId"] = userId;
    data["deliveryAddress"] = deliveryAddress;
    data["time"] = time;
    return data;
  }
}

class UserCards {
  late List<UserCard> items;

  UserCards({
    required this.items,
  });

  UserCards.fromJson(Map<String, dynamic>? json) {
    items = [];
    if (json != null) {
      var aa = json['items'];
      if (aa is List<dynamic>) {
        for (var value in aa) {
          items.add(UserCard.fromJson(value));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["items"] = items.map((e) => e.toJson());
    return data;
  }
}
