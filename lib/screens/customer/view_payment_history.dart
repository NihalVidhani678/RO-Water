import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/bottle_history.model.dart';
import 'package:water_service/models/payment_history.model.dart';

class ViewPaymentHistory extends StatefulWidget {
  @override
  State<ViewPaymentHistory> createState() => _ViewPaymentHistoryState();
}

class _ViewPaymentHistoryState extends State<ViewPaymentHistory> {
  DBHandler dbHandler = new DBHandler();

  Future<List<PaymentHistory>> getPaymentHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usercode = prefs.getString("usercode")!;
    return await dbHandler.getPaymentHistory(usercode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PaymentHistory>>(
        future: getPaymentHistory(),
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
                      "Rs. " +
                          snapshot.data![index].amount.toString() +
                          " Paid",
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
