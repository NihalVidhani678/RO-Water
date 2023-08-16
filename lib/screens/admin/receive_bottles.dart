import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle.model.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/screens/admin/add_bottles.dart';

class ReceiveBottles extends StatefulWidget {
  Customer customer;

  ReceiveBottles({required this.customer});

  @override
  State<ReceiveBottles> createState() => _ReceiveBottlesState();
}

class _ReceiveBottlesState extends State<ReceiveBottles> {
  DBHandler dbHandler = DBHandler();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBottles();
  }

  Future<List<Bottle>> getBottles() async {
    List<Bottle> bottles =
        await dbHandler.getGivenBottles(widget.customer.usercode);
    if (bottles.length == 0) {
      print("No Bottles");
      // Navigator.push(context, MaterialPageRoute(builder: (_) ))
    }
    return bottles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bottles with ${widget.customer.name}"),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddBottles(
                customer: widget.customer,
              ),
            ),
          );
        },
        child: Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Continue",
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
      body: FutureBuilder<List<Bottle>>(
        future: getBottles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
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
                  trailing: GestureDetector(
                    onTap: () async {
                      bool isTaken = await dbHandler
                          .receiveBottle(snapshot.data![index].bottleID);
                      print(isTaken);
                      if (isTaken) {
                        setState(() {
                          snapshot.data!.removeAt(index);
                        });
                      }
                    },
                    child: Text(
                      "RECEIVE",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
