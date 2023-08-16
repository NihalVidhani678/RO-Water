class BottleOrder {
  int bottleAmount;
  String bottleDate;
  String usercode;

  BottleOrder({
    required this.bottleAmount,
    required this.bottleDate,
    required this.usercode,
  });

  factory BottleOrder.fromJson(Map<String, dynamic> json) {
    return BottleOrder(
      bottleAmount: json["bottleAmount"],
      bottleDate: json["bottleDate"],
      usercode: json["usercode"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "bottleAmount": bottleAmount,
      "bottleDate": bottleDate,
      "usercode": usercode,
    };
  }
}
