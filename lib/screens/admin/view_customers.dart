import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:water_service/config/app_theme.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';
import 'package:water_service/screens/admin/customer.dart';

class ViewCustomers extends StatefulWidget {
  const ViewCustomers({Key? key}) : super(key: key);

  @override
  State<ViewCustomers> createState() => _ViewCustomersState();
}

class _ViewCustomersState extends State<ViewCustomers> {
  DBHandler dbHandler = new DBHandler();

  TextEditingController dueController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Customer>>(
        future: dbHandler.getCustomers(),
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
                        builder: (_) => CustomerScreen(
                          usercode: snapshot.data![index].usercode,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                    title: Text(
                      snapshot.data![index].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      snapshot.data![index].address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    trailing: Wrap(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  title: Text("Pay Amount"),
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        "Customer Due: ${snapshot.data![index].dues}",
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: TextFormField(
                                        autofocus: true,
                                        controller: dueController,
                                        validator: (val) {
                                          if (int.parse(val!) <
                                              AppTheme.singleBottlePrice) {
                                            return "Please enter a valid amount. Should be above ${AppTheme.singleBottlePrice} rupees";
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
                                          labelText: "Amount",
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
                                            if (dueController.text.isNotEmpty &&
                                                int.parse(dueController.text) >=
                                                    AppTheme
                                                        .singleBottlePrice) {
                                              await dbHandler
                                                  .updateCustomerDues(
                                                int.parse(dueController.text),
                                                snapshot.data![index].usercode,
                                              );
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (_) =>
                                                      AdminNavigator(
                                                    initialIndex: 1,
                                                  ),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Mark Paid",
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
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.edit, color: Colors.blue),
                      ],
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
