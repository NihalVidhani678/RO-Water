import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle.model.dart';
import 'package:water_service/screens/admin/bottle_info.dart';

class IssueBottle extends StatefulWidget {
  const IssueBottle({Key? key}) : super(key: key);

  @override
  State<IssueBottle> createState() => _IssueBottleState();
}

class _IssueBottleState extends State<IssueBottle> {
  DBHandler dbHandler = new DBHandler();

  Future<List<Bottle>> getBottleData() async {
    return await dbHandler.getBottles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Add New Gallon",
                ),
                content: Text("Are you sure you want to add a new gallon?"),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      String newBottleID = await dbHandler.addBottle();
                      getBottleData();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => BottleInfo(
                            bottleID: newBottleID,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Add Gallon",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<List<Bottle>>(
        future: getBottleData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => BottleInfo(
                          bottleID: snapshot.data![index].bottleID,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.local_drink,
                      color: Colors.blue,
                    ),
                    title: Text(
                      snapshot.data![index].bottleID,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Issued to: " +
                          (snapshot.data![index].issuedTo == ""
                              ? "No one"
                              : snapshot.data![index].issuedTo!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
