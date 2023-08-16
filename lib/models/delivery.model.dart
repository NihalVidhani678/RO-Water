import 'package:water_service/models/customer.model.dart';

class Delivery {
  String date;
  String day;
  List<Customer> deliveries;

  Delivery({
    required this.date,
    required this.day,
    required this.deliveries,
  });
}
