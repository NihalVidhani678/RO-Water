class PaymentHistory {
  String usercode;
  int amount;
  String date;

  PaymentHistory({
    required this.usercode,
    required this.amount,
    required this.date,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      usercode: json['usercode'],
      amount: json['amount'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usercode': this.usercode,
      'amount': this.amount,
      'date': this.date,
    };
  }
}
