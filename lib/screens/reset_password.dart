import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/screens/login.dart';

class ResetPassword extends StatefulWidget {
  String collection;

  ResetPassword({
    required this.collection,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController oldpasswordController = TextEditingController();
  TextEditingController newpasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> saveNewPassword() async {
    setState(() {
      isLoading = true;
    });
    String newPassword = newpasswordController.text;
    String confirmedPassword = confirmPasswordController.text;

    if (newPassword.length >= 6) {
      if (newPassword == confirmedPassword) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String email = preferences.getString("email")!;
        final userCollection =
            FirebaseFirestore.instance.collection(widget.collection);
        final currentuserDoc =
            await userCollection.where("email", isEqualTo: email).get();
        var oldPassCheck = BCrypt.checkpw(
          oldpasswordController.text,
          currentuserDoc.docs.first['password'],
        );
        if (oldPassCheck) {
          newPassword = BCrypt.hashpw(
            newPassword,
            BCrypt.gensalt(),
          );
          userCollection.doc(currentuserDoc.docs.first.id).update({
            "password": newPassword,
          }).then(
            (value) {
              preferences.clear();
              Fluttertoast.showToast(
                  msg: "Password updated successfully, please login again.");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
                (route) => false,
              );
            },
            onError: (e) {
              Fluttertoast.showToast(
                  msg: "Password reset failed, please try again later.");
              setState(() {
                isLoading = false;
              });
            },
          );
        } else {
          Fluttertoast.showToast(
              msg: "Old password doesn't checkout from database.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: "New passwords do not match.");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Password should be atleast 6 characters");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    MediaQueryData queryData; //
    queryData = MediaQuery.of(context); //
    double pixels = queryData.devicePixelRatio; //

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(//to avoid pixel problem
          children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: w,
                    height: h * 0.28,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30),
                        Container(
                          width: w,
                          height: h * 0.1,
                        ),
                        SizedBox(height: pixels * h * 0.015), //h*0.1
                        Text(
                          "Reset Password",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: w,
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "Please enter your new password and save.",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: oldpasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Old Password",
                      ),
                      readOnly: isLoading,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: newpasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "New Password",
                      ),
                      readOnly: isLoading,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm New Password",
                      ),
                      readOnly: isLoading,
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
              SizedBox(height: 60),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              if (!isLoading)
                InkWell(
                  onTap: () {
                    saveNewPassword();
                  },
                  child: Container(
                    width: w * 0.5,
                    height: h * 0.08,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 2),
                    ),
                    child: Center(
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
