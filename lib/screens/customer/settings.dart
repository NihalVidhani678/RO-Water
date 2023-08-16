import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';
import 'package:water_service/screens/customer/user_navigator.dart';
import 'package:water_service/screens/customer_history.dart';

class CustomerSettings extends StatefulWidget {
  @override
  State<CustomerSettings> createState() => _CustomerSettingsState();
}

class _CustomerSettingsState extends State<CustomerSettings> {
  final _formKey = GlobalKey<FormState>();

  String usercode = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController usercodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String customerName = "";
  String customerCode = "";
  String customerEmail = "";
  String customerPhone = "";
  String customerAddress = "";
  String? customerBuilding;
  String? customerBottleDay;
  String? customerBottleAmount;

  int customerDues = 0;
  String customerPassword = "";

  bool isLoading = false;

  List<String> weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  List<String> numberOfBottles = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  List<String> allBuildings = [];

  DBHandler dbHandler = new DBHandler();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usercode = prefs.getString("usercode")!;
    });
    loadBuildings();
    getCustomerDetails();
  }

  loadBuildings() async {
    allBuildings = await dbHandler.getBuildings();
    setState(() {});
  }

  getCustomerDetails() async {
    Customer customer = await dbHandler.getCustomer(usercode);
    setState(() {
      customerName = customer.name;
      customerPassword = customer.password;
      nameController.text = customer.name;
      customerCode = customer.usercode;
      usercodeController.text = customer.usercode;
      customerEmail = customer.email;
      emailController.text = customer.email;
      phoneController.text = customer.phone;
      customerPhone = customer.phone;
      addressController.text = customer.address;
      customerAddress = customer.address;
      customerBuilding = customer.building;
      customerBottleDay = customer.bottleDay;
      customerBottleAmount = customer.bottleAmount.toString();
      customerDues = customer.dues;
    });
  }

  editCustomer() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      if (customerBottleDay == null) {
        Fluttertoast.showToast(msg: "Please enter the day of bottle delivery");
      } else {
        if (customerBottleAmount == null) {
          Fluttertoast.showToast(
              msg: "Please enter the amount of bottle delivery");
        } else {
          print("Good To GO");
          setState(() {
            isLoading = true;
          });
          Customer customerData = Customer(
            name: customerName,
            usercode: usercode,
            email: customerEmail,
            phone: customerPhone,
            address: customerAddress,
            building: customerBuilding!,
            bottleDay: customerBottleDay!,
            bottleAmount: int.parse(customerBottleAmount!),
            dues: customerDues,
            password: customerPassword,
          );
          DBHandler dbHandler = new DBHandler();
          bool response = await dbHandler.editCustomer(customerData);
          if (response) {
            Fluttertoast.showToast(msg: "Customer updated successfully");
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
                msg: "Could not edit customer, please try again.");
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    }
  }

  deleteCustomer(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Customer"),
          content: Text(
              "Are you sure you want to delete all customer data related to $customerName? This can not be undone."),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                DBHandler dbHandler = new DBHandler();
                bool response = await dbHandler.deleteCustomer(usercode);
                if (response) {
                  Fluttertoast.showToast(msg: "Customer deleted successfully");
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => AdminNavigator(
                        initialIndex: 1,
                      ),
                    ),
                    (route) => false,
                  );
                } else {
                  Fluttertoast.showToast(
                      msg: "Could not delete customer, please try again.");
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Delete $customerName",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: usercode == ""
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFFF3F6FA),
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
                            child: TextFormField(
                              controller: nameController,
                              validator: (value) {
                                if (value!.trim().length < 3) {
                                  return "Name is too short";
                                }
                                if (value.trim().length > 15) {
                                  return "Name is too long";
                                }
                              },
                              onChanged: (value) {
                                customerName = value;
                              },
                              cursorColor: AppTheme.primaryColor,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: "Eg: Sami",
                                filled: true,
                                fillColor: Color(0xFFF3F6FA),
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Usercode: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFFF3F6FA),
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
                            child: TextFormField(
                              controller: usercodeController,
                              readOnly: true,
                              validator: (value) {
                                if (value!.trim().length < 3) {
                                  return "Usercode is too short";
                                }
                                if (value.trim().length > 15) {
                                  return "Usercode is too long";
                                }
                              },
                              onChanged: (value) {
                                customerCode = value;
                              },
                              cursorColor: AppTheme.primaryColor,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: "Eg: sami_15",
                                filled: true,
                                fillColor: Color(0xFFF3F6FA),
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Email: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFFF3F6FA),
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
                            child: TextFormField(
                              controller: emailController,
                              validator: (value) {
                                if (value!.length > 0) {
                                  if ((!value.contains("@") ||
                                      !value.contains("."))) {
                                    return "Please enter a valid email address";
                                  }
                                }
                              },
                              onChanged: (value) {
                                customerEmail = value;
                              },
                              cursorColor: AppTheme.primaryColor,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: "Eg: sami@mailer.com [OPTIONAL]",
                                filled: true,
                                fillColor: Color(0xFFF3F6FA),
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Phone Number: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFFF3F6FA),
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
                            child: TextFormField(
                              controller: phoneController,
                              validator: (value) {
                                if (value!.trim().length != 11) {
                                  return "Invalid phone number, please enter 11 digits";
                                }
                              },
                              onChanged: (value) {
                                customerPhone = value;
                              },
                              cursorColor: AppTheme.primaryColor,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: "Eg: 03247295621",
                                filled: true,
                                fillColor: Color(0xFFF3F6FA),
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Home Address: ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              // color: Color(0xFFF3F6FA),
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
                            child: TextFormField(
                              controller: addressController,
                              validator: (value) {
                                if (value!.trim().length < 5) {
                                  return "Address is too short";
                                }
                              },
                              onChanged: (value) {
                                customerAddress = value;
                              },
                              cursorColor: AppTheme.primaryColor,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Eg: A5 Lakhani Towers",
                                filled: true,
                                fillColor: Color(0xFFF3F6FA),
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "Building Name: ",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isExpanded: true,
                                  hint: Text(
                                    'Please choose an option',
                                  ), // Not necessary for Option 1
                                  value: customerBuilding,
                                  onChanged: (newValue) {
                                    setState(() {
                                      customerBuilding = newValue as String;
                                    });
                                  },
                                  items: allBuildings.map((location) {
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
                              "Delivery Day: ",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isExpanded: true,
                                  hint: Text(
                                      'Please choose an option'), // Not necessary for Option 1
                                  value: customerBottleDay,
                                  onChanged: (newValue) {
                                    setState(() {
                                      customerBottleDay = newValue as String?;
                                    });
                                  },
                                  items: weekdays.map((location) {
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                          const SizedBox(
                            height: 25,
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
                                      editCustomer();
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
                                              "Save Details",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.save,
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
                  ),
                ],
              ),
            ),
    );
  }
}
