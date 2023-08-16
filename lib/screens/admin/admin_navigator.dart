import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/screens/admin/add_customer.dart';
import 'package:water_service/screens/admin/admin_complaints.dart';
import 'package:water_service/screens/admin/admin_dashboard.dart';
import 'package:water_service/screens/admin/admin_reports.dart';
import 'package:water_service/screens/admin/bottles.dart';
import 'package:water_service/screens/admin/view_customers.dart';
import 'package:water_service/screens/onboarding_screen.dart';
import 'package:water_service/screens/reset_password.dart';

class AdminNavigator extends StatefulWidget {
  int initialIndex;

  AdminNavigator({required this.initialIndex});

  @override
  State<AdminNavigator> createState() => _AdminNavigatorState();
}

class _AdminNavigatorState extends State<AdminNavigator> {
  List<Widget> screens = [
    AdminDashboard(),
    AdminReports(),
    ViewCustomers(),
    AddCustomer(),
    IssueBottle(),
    ResetPassword(
      collection: "administrators",
    ),
  ];

  List<String> titles = [
    'RO Water Service Admin',
    'Reports',
    "View Customer",
    'Add Customer',
    'Gallon Info',
    'Change Password',
  ];

  int currentIndex = 0;

  @override
  void initState() {
    setState(() {
      currentIndex = widget.initialIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            titles[currentIndex],
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppTheme.primaryColor,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.dashboard_sharp,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Reports",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 2;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "View Customers",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 3;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Add Customer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.group_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 4;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Gallon Info",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.liquor,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 5;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Change Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => OnboardingScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: ListTile(
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: screens[currentIndex],
      ),
    );
  }
}
