import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle.model.dart';
import 'package:water_service/models/bottle_history.model.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';

class AddBottles extends StatefulWidget {
  Customer customer;

  AddBottles({required this.customer});

  @override
  State<AddBottles> createState() => _AddBottlesState();
}

class _AddBottlesState extends State<AddBottles> {
  DBHandler dbHandler = DBHandler();

  List<Bottle> bottles = [];

  int newBottleCount = 0;

  bool isLoading = false;

  TextEditingController bottleIdController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBottles();
  }

  getBottles() async {
    List<Bottle> newBottles =
        await dbHandler.getGivenBottles(widget.customer.usercode);
    if (bottles.length == 0) {
      print("No Bottles");
      // Navigator.push(context, MaterialPageRoute(builder: (_) ))
    }
    setState(() {
      bottles = newBottles;
    });
  }

  addToHistory() async {
    if (newBottleCount == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AdminNavigator(
            initialIndex: 0,
          ),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        isLoading = true;
      });
      int amount = 0;
      amount = newBottleCount * 80;
      BottleHistory history = BottleHistory(
        usercode: widget.customer.usercode,
        bottleAmount: newBottleCount.toString(),
        amount: amount,
        date: DateFormat("dd-MM-yyyy").format(DateTime.now()),
      );
      bool added = await dbHandler.addToHistory(history);
      if (added) {
        bool updated =
            await dbHandler.addToDue(amount, widget.customer.usercode);
        if (updated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bottles to ${widget.customer.name}"),
        actions: [
          IconButton(
            onPressed: () async {
              await Permission.camera.request();
              String? cameraScanResult = await scanner.scan();
              if (cameraScanResult != null) {
                Fluttertoast.showToast(
                    msg: "Scanned $cameraScanResult. Adding to customer...");
                bool response = await dbHandler.giveBottles(
                  cameraScanResult,
                  widget.customer.usercode,
                );
                if (response) {
                  Fluttertoast.showToast(msg: "Bottle successfully added");
                  newBottleCount++;
                  getBottles();
                } else {
                  Fluttertoast.showToast(
                      msg: "Could not issue bottle, please try again.");
                }
              }
            },
            icon: Icon(
              Icons.qr_code_2,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("Add Bottle"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          autofocus: true,
                          controller: bottleIdController,
                          validator: (val) {
                            if (val!.length < 3) {
                              return "Please enter a valid user code";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            labelText: "Bottle ID",
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                              bool response = await dbHandler.giveBottles(
                                  bottleIdController.text,
                                  widget.customer.usercode);
                              if (response) {
                                setState(() {
                                  bottleIdController.text = "";
                                });
                                Fluttertoast.showToast(
                                    msg: "Bottle successfully added");
                                newBottleCount++;
                                getBottles();
                                Navigator.pop(context);
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        "Could not issue bottle, please try again.");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Deliver Bottle",
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.numbers,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () {
                addToHistory();
              },
              child: Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Finish",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
      body: ListView.builder(
        itemCount: bottles.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              Icons.local_drink,
              color: Colors.blue,
            ),
            title: Text(
              bottles[index].bottleID,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Issued to: " +
                  (bottles[index].issuedTo == ""
                      ? "No one"
                      : bottles[index].issuedTo!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          );
        },
      ),
    );
  }
}
