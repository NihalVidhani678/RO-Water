import 'package:flutter/material.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle_history.model.dart';

class CustomerHistory extends StatefulWidget {
  String usercode;

  CustomerHistory({required this.usercode});

  @override
  State<CustomerHistory> createState() => _CustomerHistoryState();
}

class _CustomerHistoryState extends State<CustomerHistory> {
  DBHandler dbHandler = new DBHandler();

  Future<List<BottleHistory>> getBottleHistory() async {
    return await dbHandler.getBottleHistory(widget.usercode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bottle History"),
      ),
      body: FutureBuilder<List<BottleHistory>>(
        future: getBottleHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: ListTile(
                    leading: Icon(
                      Icons.local_drink,
                      color: Colors.blue,
                    ),
                    title: Text(
                      snapshot.data![index].bottleAmount +
                          " Bottles | RS." +
                          snapshot.data![index].amount.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.data![index].date,
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
