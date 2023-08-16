import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle_history.model.dart';
import 'package:water_service/models/bottle_order.model.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/models/delivery.model.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({Key? key}) : super(key: key);

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  String name = "...";
  String email = "...";
  String username = "...";

  String averageBottlesPW = "...";
  String averageRevenuePW = "...";
  String thisWeeksBottles = "...";
  String thisWeeksRevenue = "...";
  String bottlesInUse = "...";
  String bottlesFree = "...";
  String totalCollectableDues = "...";

  bool isLoading = true;

  @override
  void initState() {
    getAdminData();
    super.initState();
  }

  getAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name")!;
      email = prefs.getString("email")!;
      username = prefs.getString("username")!;
    });
    getLastSevenDayTab();
  }

  getLastSevenDayTab() async {
    DBHandler dbHandler = DBHandler();

    final _currentDate = DateTime.now();
    final _weekdayFormatter = DateFormat('EEEE');

    int bottlesDeliveredLastWeek = 0;
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.subtract(
        Duration(
          days: i,
        ),
      );
      String dateDay = DateFormat("dd-MM-yyyy").format(date);
      List<BottleHistory> deliveries =
          await dbHandler.getBottleHistoryForDate(dateDay);

      deliveries.forEach((element) {
        bottlesDeliveredLastWeek += int.parse(element.bottleAmount);
      });
    }
    setState(() {
      thisWeeksBottles = bottlesDeliveredLastWeek.toString();
      thisWeeksRevenue =
          (bottlesDeliveredLastWeek * AppTheme.singleBottlePrice).toString();
    });
    getDailyDeliveries();
  }

  getDailyDeliveries() async {
    DBHandler dbHandler = DBHandler();

    final _currentDate = DateTime.now();
    final _weekdayFormatter = DateFormat('EEEE');

    int bottlesPerWeek = 0;
    for (int i = 0; i < 7; i++) {
      final date = _currentDate.add(
        Duration(
          days: i,
        ),
      );
      String nameOfDay = _weekdayFormatter.format(date);
      List<Customer> deliveries = await dbHandler.getDeliveryForDay(nameOfDay);

      deliveries.forEach((element) {
        bottlesPerWeek += element.bottleAmount;
      });
    }
    setState(() {
      averageBottlesPW = bottlesPerWeek.toString();
      averageRevenuePW =
          (bottlesPerWeek * AppTheme.singleBottlePrice).toString();
    });
    getBottlesData();
  }

  getBottlesData() async {
    DBHandler dbHandler = DBHandler();
    int inUseBottles = await dbHandler.getInUseBottlesCount();
    int freeBottles = await dbHandler.getFreeBottlesCount();
    setState(() {
      bottlesFree = freeBottles.toString();
      bottlesInUse = inUseBottles.toString();
    });
    getCollectableDues();
  }

  getCollectableDues() async {
    DBHandler dbHandler = DBHandler();
    int allDues = await dbHandler.getTotalCollectableDues();
    setState(() {
      totalCollectableDues = allDues.toString();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Generating Reports... Please Wait.",
                  ),
                ],
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "$averageBottlesPW bottles",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Avg bottles per week",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Rs. $averageRevenuePW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Avg Revenue per week",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "$thisWeeksBottles bottles",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Bottles delivered in last 7 days",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Rs.$thisWeeksRevenue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Revenue in last 7 days",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Rs.$totalCollectableDues",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Dues Collectable",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "$bottlesFree bottles",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Free bottles in stock",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "$bottlesInUse bottles",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Center(
                                child: Text(
                                  "Bottles In Use",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
