class BottleHistory {
  String usercode;
  String bottleAmount;
  int amount;
  String date;

  BottleHistory({
    required this.usercode,
    required this.bottleAmount,
    required this.amount,
    required this.date,
  });

  factory BottleHistory.fromJson(Map<String, dynamic> json) {
    return BottleHistory(
      usercode: json['usercode'],
      bottleAmount: json['bottleAmount'],
      amount: json['amount'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usercode': this.usercode,
      'bottleAmount': this.bottleAmount,
      'amount': this.amount,
      'date': this.date,
    };
  }
}
