class Customer {
  String name;
  String usercode;
  String password;
  String email;
  String phone;
  String address;
  String building;
  String bottleDay;
  int bottleAmount;
  int dues;

  Customer({
    required this.name,
    required this.usercode,
    required this.password,
    required this.email,
    required this.phone,
    required this.address,
    required this.building,
    required this.bottleDay,
    required this.bottleAmount,
    required this.dues,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      usercode: json['usercode'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      building: json['building'],
      bottleDay: json['bottleDay'],
      bottleAmount: json['bottleAmount'],
      dues: json['dues'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "usercode": usercode,
      "password": password,
      "email": email,
      "phone": phone,
      "address": address,
      "building": building,
      "bottleDay": bottleDay,
      "bottleAmount": bottleAmount,
      "dues": dues,
    };
  }
}
