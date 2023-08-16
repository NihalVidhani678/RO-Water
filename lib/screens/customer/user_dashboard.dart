import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/screens/onboarding_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Customer? customer;

  @override
  void initState() {
    getCustomerData();
    super.initState();
  }

  getCustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DBHandler dbHandler = DBHandler();
    Customer currentCustomer =
        await dbHandler.getCustomer(prefs.getString("usercode")!);
    setState(() {
      customer = currentCustomer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: customer == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                          "Welcome, ${customer!.name}.",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ListTile(
                          dense: false,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "${customer!.bottleAmount} bottle(s) are delivered to you every ${customer!.bottleDay} to \"${customer!.address}.\"",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Pending Dues: ${customer!.dues} -/RS",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
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
