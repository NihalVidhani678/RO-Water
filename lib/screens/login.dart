import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';
import 'package:water_service/screens/customer/user_dashboard.dart';
import 'package:water_service/screens/customer/user_navigator.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userCode = "";
  String password = "";

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  login() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (userCode != "admin_rowater") {
        setState(() {
          isLoading = true;
        });
        DBHandler dbHandler = new DBHandler();
        var loginResponse =
            await dbHandler.checkCustomerLogin(userCode, password);
        if (loginResponse == false) {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            "Username or password is incorrect, please try again",
            Colors.red,
          );
        } else {
          var userData = loginResponse;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("email", userData['email']);
          prefs.setString("name", userData['name']);
          prefs.setString("usercode", userData['usercode']);
          prefs.setBool("isAdmin", false);
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => UserNavigator(
                initialIndex: 0,
              ),
            ),
            (route) => false,
          );
        }
      } else {
        setState(() {
          isLoading = true;
        });
        DBHandler dbHandler = new DBHandler();
        var loginResponse = await dbHandler.checkAdminLogin(userCode, password);
        if (loginResponse == false) {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            "Username or password is incorrect, please try again",
            Colors.red,
          );
        } else {
          var userData = loginResponse;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("email", userData['email']);
          prefs.setString("name", userData['name']);
          prefs.setString("username", userData['username']);
          prefs.setBool("isAdmin", true);
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => AdminNavigator(
                initialIndex: 0,
              ),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  void showSnackBar(String content, Color bgColor) {
    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      // onTap: fakeLogin,
                      child: Text(
                        "Welcome to",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "RO Water Service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 33,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextFormField(
                          onChanged: (val) {
                            setState(() {
                              userCode = val;
                            });
                          },
                          validator: (val) {
                            if (val!.length < 3) {
                              return "Please enter a valid user code";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "User Code",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Please enter your user code (eg: A4LAKHANITOWERS)",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (val) {
                            if (val!.length < 6) {
                              return "Please enter atleast 6 digits";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            password = val;
                          },
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          obscureText: true,
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "Password",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Please enter the password assigned to you upon registration.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              login();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                      "Login",
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppTheme.primaryColor,
                                      size: 30,
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
          ),
        ),
      ),
    );
  }
}
