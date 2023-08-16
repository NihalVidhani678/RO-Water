import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle_order.model.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/models/delivery.model.dart';
import 'package:water_service/screens/admin/receive_bottles.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String name = "...";
  String email = "...";
  String username = "...";

  bool isLoading = true;

  List<Delivery> deliveriesSchedule = [];

  @override
  void initState() {
    getAdminData();
    getDailyDeliveries();
    super.initState();
  }

  getAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name")!;
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
    });
  }

  getDailyDeliveries() async {
    List<Delivery> _deliveriesSchedule = [];
    DBHandler dbHandler = DBHandler();

    final _currentDate = DateTime.now();
    final _dayFormatter = DateFormat('d');
    final _monthFormatter = DateFormat('MM');
    final _yearFormatter = DateFormat('yyyy');
    final _weekdayFormatter = DateFormat('EEEE');

    List<String> nextWeekDates = [];
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(
        Duration(
          days: i,
        ),
      );

      String dateOfDay = _dayFormatter.format(date) +
          "/" +
          _monthFormatter.format(date) +
          "/" +
          _yearFormatter.format(date);
      String nameOfDay = _weekdayFormatter.format(date);
      List<Customer> deliveries = await dbHandler.getDeliveryForDay(nameOfDay);

      Delivery newDayDelivery =
          Delivery(date: dateOfDay, day: nameOfDay, deliveries: deliveries);

      _deliveriesSchedule.add(newDayDelivery);
    }
    setState(() {
      deliveriesSchedule = _deliveriesSchedule;
    });
    getUrgentDeliveries();
  }

  getUrgentDeliveries() {
    DBHandler dbHandler = DBHandler();
    deliveriesSchedule.forEach((element) async {
      print(element.date);
      List<BottleOrder> dateDeliveries = await dbHandler.getOrdersForDate(
        element.date,
      );
      dateDeliveries.forEach((element) async {
        print(element.usercode);
        Customer thisCustomer = await dbHandler.getCustomer(element.usercode);
        thisCustomer.bottleAmount = element.bottleAmount;
        int dateInd = deliveriesSchedule.indexWhere(
            (delivElement) => delivElement.date == element.bottleDate);
        setState(() {
          deliveriesSchedule[dateInd].deliveries.add(thisCustomer);
        });
      });
      print(dateDeliveries);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Welcome, $name.",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (!isLoading)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: ListView.builder(
                        itemCount: deliveriesSchedule.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                deliveriesSchedule[index].day +
                                    " (${deliveriesSchedule[index].date})",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    deliveriesSchedule[index].deliveries.length,
                                itemBuilder: (context, delIndex) {
                                  Customer currDelivery =
                                      deliveriesSchedule[index]
                                          .deliveries[delIndex];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReceiveBottles(
                                            customer: currDelivery,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(
                                        currDelivery.name,
                                      ),
                                      subtitle: Text(currDelivery.address),
                                      trailing: Text(
                                        currDelivery.bottleAmount.toString() +
                                            " bottles",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                color: Colors.blue,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
