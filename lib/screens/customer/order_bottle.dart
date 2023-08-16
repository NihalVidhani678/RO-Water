import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle_order.model.dart';
import 'package:water_service/screens/customer/user_navigator.dart';

class OrderBottle extends StatefulWidget {
  const OrderBottle({Key? key}) : super(key: key);

  @override
  State<OrderBottle> createState() => _OrderBottleState();
}

class _OrderBottleState extends State<OrderBottle> {
  bool isLoading = false;
  String? customerBottleAmount;
  String? bottleDeliveryDate;
  List<String> numberOfBottles = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  final _currentDate = DateTime.now();
  final _dayFormatter = DateFormat('d');
  final _monthFormatter = DateFormat('MM');
  final _yearFormatter = DateFormat('yyyy');

  List<String> nextWeekDates = [];

  decideNextDates() {
    for (int i = 1; i < 8; i++) {
      final date = _currentDate.add(
        Duration(
          days: i,
        ),
      );
      setState(() {
        nextWeekDates.add(
          _dayFormatter.format(date) +
              "/" +
              _monthFormatter.format(date) +
              "/" +
              _yearFormatter.format(date),
        );
      });
    }
  }

  placeOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBHandler dbHandler = DBHandler();
    if (customerBottleAmount != null) {
      if (bottleDeliveryDate != null) {
        setState(() {
          isLoading = true;
        });
        bool isPlaced = await dbHandler.placeUrgentOrder(
          BottleOrder(
            bottleAmount: int.parse(customerBottleAmount!),
            bottleDate: bottleDeliveryDate!,
            usercode: prefs.getString("usercode")!,
          ),
        );
        if (isPlaced) {
          Fluttertoast.showToast(
            msg:
                "We have received your order, your bottles will be delivered timely",
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => UserNavigator(
                initialIndex: 0,
              ),
            ),
            (route) => false,
          );
        } else {
          Fluttertoast.showToast(
            msg: "An error has occurred, please try again later.",
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Please enter a delivery date");
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please enter the amount of bottles you need",
      );
    }
  }

  @override
  void initState() {
    decideNextDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Delivery Bottle Amount: ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(
                          0,
                          2,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text(
                          'Please choose an option',
                        ), // Not necessary for Option 1
                        value: customerBottleAmount,
                        onChanged: (newValue) {
                          setState(() {
                            customerBottleAmount = newValue as String;
                          });
                        },
                        items: numberOfBottles.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Delivery Date: ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(
                          0,
                          2,
                        ), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: Text(
                          'Please choose an option',
                        ), // Not necessary for Option 1
                        value: bottleDeliveryDate,
                        onChanged: (newValue) {
                          setState(() {
                            bottleDeliveryDate = newValue as String;
                          });
                        },
                        items: nextWeekDates.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            placeOrder();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(
                                30,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Place Order",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.menu_open_sharp,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
