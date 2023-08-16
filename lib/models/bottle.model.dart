class Bottle {
  String bottleID;
  String? issuedTo = "";

  Bottle({
    required this.bottleID,
    this.issuedTo,
  });

  factory Bottle.fromJson(Map<String, dynamic> json) {
    return Bottle(
      bottleID: json["bottleID"],
      issuedTo: json["issuedTo"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "bottleID": this.bottleID,
      "issuedTo": this.issuedTo,
    };
  }
}
