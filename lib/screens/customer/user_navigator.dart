import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/screens/admin/add_customer.dart';
import 'package:water_service/screens/admin/admin_complaints.dart';
import 'package:water_service/screens/admin/admin_dashboard.dart';
import 'package:water_service/screens/admin/bottles.dart';
import 'package:water_service/screens/admin/view_customers.dart';
import 'package:water_service/screens/customer/contact_admin.dart';
import 'package:water_service/screens/customer/order_bottle.dart';
import 'package:water_service/screens/customer/settings.dart';
import 'package:water_service/screens/customer/user_dashboard.dart';
import 'package:water_service/screens/customer/view_payment_history.dart';
import 'package:water_service/screens/onboarding_screen.dart';
import 'package:water_service/screens/reset_password.dart';

class UserNavigator extends StatefulWidget {
  int initialIndex;

  UserNavigator({required this.initialIndex});

  @override
  State<UserNavigator> createState() => _UserNavigatorState();
}

class _UserNavigatorState extends State<UserNavigator> {
  List<Widget> screens = [
    UserDashboard(),
    OrderBottle(),
    ViewPaymentHistory(),
    ContactAdmin(),
    CustomerSettings(),
    ResetPassword(
      collection: "customers",
    ),
  ];

  List<String> titles = [
    'RO Water Service',
    'Order Bottle',
    'View Payment History',
    'Contact Admin',
    'Settings',
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
                    "Order Bottle",
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
                    currentIndex = 2;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "View Payment History",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.wallet_membership,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String username = prefs.getString("usercode")!;
                  launch(
                    "mailto:samiakhtarali1@gmail.com?subject=RO Water Service - Contact by $username",
                  );
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Contact Admin",
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
                    currentIndex = 4;
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  leading: Icon(
                    Icons.support_agent,
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
                    Icons.support_agent,
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
