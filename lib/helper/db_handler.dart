import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:water_service/models/bottle.model.dart';
import 'package:water_service/models/bottle_history.model.dart';
import 'package:water_service/models/customer.model.dart';
import 'package:water_service/models/bottle_order.model.dart';
import 'package:water_service/models/payment_history.model.dart';

class DBHandler {
  Future checkAdminLogin(String username, String password) async {
    var collection = FirebaseFirestore.instance.collection('administrators');
    var docSnapshot =
        await collection.where("username", isEqualTo: username).limit(1).get();
    // final List<DocumentSnapshot> documents = doc;
    if (docSnapshot.size == 1) {
      final bool checkPassword =
          BCrypt.checkpw(password, docSnapshot.docs.first.data()['password']);
      if (checkPassword) {
        return docSnapshot.docs.first.data();
      }
    }
    return false;
  }

  Future checkCustomerLogin(String username, String password) async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot =
        await collection.where("usercode", isEqualTo: username).limit(1).get();
    // final List<DocumentSnapshot> documents = doc;
    if (docSnapshot.size == 1) {
      final bool checkPassword =
          BCrypt.checkpw(password, docSnapshot.docs.first.data()['password']);
      if (checkPassword) {
        return docSnapshot.docs.first.data();
      }
    }
    return false;
  }

  Future<String> createCustomer(Customer customerData) async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot = await collection
        .where("usercode", isEqualTo: customerData.usercode)
        .get();

    if (docSnapshot.docs.length == 0) {
      customerData.password = BCrypt.hashpw(
        customerData.password,
        BCrypt.gensalt(),
      );
      final docCustomer =
          FirebaseFirestore.instance.collection('customers').doc();
      final customerJson = customerData.toJson();
      await docCustomer.set(customerJson).onError((error, stackTrace) {
        return "error";
      });
      return "registered";
    } else {
      return "exists";
    }
  }

  Future<bool> deleteCustomer(String usercode) async {
    final customerCollection =
        FirebaseFirestore.instance.collection("customers");
    final currentCustomerDoc =
        await customerCollection.where("usercode", isEqualTo: usercode).get();
    customerCollection.doc(currentCustomerDoc.docs.first.id).delete().then(
      (value) {
        return true;
      },
      onError: (e) {
        return false;
      },
    );
    return true;
  }

  Future<bool> editCustomer(Customer customerData) async {
    final customerCollection =
        FirebaseFirestore.instance.collection("customers");
    final currentCustomerDoc = await customerCollection
        .where("usercode", isEqualTo: customerData.usercode)
        .get();
    customerCollection
        .doc(currentCustomerDoc.docs.first.id)
        .update(
          customerData.toJson(),
        )
        .then(
      (value) {
        return true;
      },
      onError: (e) {
        return false;
      },
    );
    return true;
  }

  Future<List<Customer>> getCustomers() async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot = await collection.get();
    List<Customer> customers = [];
    docSnapshot.docs.forEach((element) {
      Customer fetchedCustomer = Customer.fromJson(element.data());
      customers.add(fetchedCustomer);
    });
    return customers;
  }

  Future<Customer> getCustomer(String usercode) async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot =
        await collection.where("usercode", isEqualTo: usercode).limit(1).get();
    Customer fetchedCustomer = Customer.fromJson(
      docSnapshot.docs.first.data(),
    );

    return fetchedCustomer;
  }

  Future<List<Bottle>> getBottles() async {
    var collection = FirebaseFirestore.instance.collection('bottles');
    var docSnapshot = await collection.get();
    List<Bottle> bottles = [];
    docSnapshot.docs.forEach((element) {
      Bottle fetchedBottle = Bottle.fromJson(element.data());
      bottles.add(fetchedBottle);
    });
    return bottles;
  }

  Future<List<BottleHistory>> getBottleHistory(String usercode) async {
    var collection =
        FirebaseFirestore.instance.collection('bottleHistory').where(
              "usercode",
              isEqualTo: usercode,
            );
    var docSnapshot = await collection.get();
    List<BottleHistory> bottleHistory = [];
    docSnapshot.docs.forEach((element) {
      BottleHistory fetchedBottleHistory =
          BottleHistory.fromJson(element.data());
      bottleHistory.add(fetchedBottleHistory);
    });
    return bottleHistory;
  }

  Future<List<BottleHistory>> getBottleHistoryForDate(String date) async {
    var collection =
        FirebaseFirestore.instance.collection('bottleHistory').where(
              "date",
              isEqualTo: date,
            );
    var docSnapshot = await collection.get();
    List<BottleHistory> bottleHistory = [];
    docSnapshot.docs.forEach((element) {
      BottleHistory fetchedBottleHistory =
          BottleHistory.fromJson(element.data());
      bottleHistory.add(fetchedBottleHistory);
    });
    return bottleHistory;
  }

  Future<int> getTotalCollectableDues() async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot = await collection.get();
    int dues = 0;
    docSnapshot.docs.forEach((element) {
      Customer fetchedCustomer = Customer.fromJson(element.data());
      int newDue = fetchedCustomer.dues;
      dues += newDue;
    });
    return dues;
  }

  Future<int> getInUseBottlesCount() async {
    var collection = FirebaseFirestore.instance.collection("bottles");
    var docs = await collection
        .where(
          "issuedTo",
          isNotEqualTo: "",
        )
        .get();
    return docs.size;
  }

  Future<int> getFreeBottlesCount() async {
    var collection = FirebaseFirestore.instance.collection("bottles");
    var docs = await collection
        .where(
          "issuedTo",
          isEqualTo: "",
        )
        .get();
    return docs.size;
  }

  Future<List<PaymentHistory>> getPaymentHistory(String usercode) async {
    var collection =
        FirebaseFirestore.instance.collection('paymentHistory').where(
              "usercode",
              isEqualTo: usercode,
            );
    var docSnapshot = await collection.get();
    List<PaymentHistory> paymentHistory = [];
    docSnapshot.docs.forEach((element) {
      PaymentHistory fetchedPaymentHistory =
          PaymentHistory.fromJson(element.data());
      paymentHistory.add(fetchedPaymentHistory);
    });
    return paymentHistory;
  }

  Future<List<String>> getBuildings() async {
    print("Hello");
    var collection = FirebaseFirestore.instance.collection('buildings');
    var docSnapshot = await collection.get();
    List<String> buildings = [];
    docSnapshot.docs.forEach((element) {
      buildings.add(element.data()['name']);
    });
    return buildings;
  }

  Future<String> addBottle() async {
    final docBottle = FirebaseFirestore.instance.collection('bottles').doc();
    final String randomBottleID = getRandomString(8);
    Bottle bottle = Bottle(bottleID: randomBottleID, issuedTo: "");
    final bottleJson = bottle.toJson();
    await docBottle.set(bottleJson).onError((error, stackTrace) {
      return "error";
    });
    return randomBottleID;
  }

  Future<bool> deleteBottle(String bottleID) async {
    var collection = FirebaseFirestore.instance.collection('bottles');
    var docSnapshot =
        await collection.where("bottleID", isEqualTo: bottleID).limit(1).get();
    collection.doc(docSnapshot.docs.first.id).delete().then(
      (doc) {},
      onError: (e) {
        return false;
      },
    );
    return true;
  }

  Future<bool> placeUrgentOrder(BottleOrder order) async {
    final docOrder = FirebaseFirestore.instance.collection('orders').doc();

    final orderJson = order.toJson();
    await docOrder.set(orderJson).onError((error, stackTrace) {
      return false;
    });
    return true;
  }

  Future<bool> addToHistory(BottleHistory history) async {
    final docHistory =
        FirebaseFirestore.instance.collection('bottleHistory').doc();

    final historyJson = history.toJson();
    await docHistory.set(historyJson).onError((error, stackTrace) {
      return false;
    });
    return true;
  }

  Future<bool> addToDue(int amount, String usercode) async {
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot =
        await collection.where("usercode", isEqualTo: usercode).limit(1).get();
    int currentDue = docSnapshot.docs.first.data()['dues'];
    int newDue = currentDue + amount;
    collection.doc(docSnapshot.docs.first.id).update({"dues": newDue}).then(
      (value) {
        return true;
      },
      onError: (e) {
        return false;
      },
    );
    return true;
  }

  Future<bool> updateCustomerDues(int amount, String usercode) async {
    final docHistory =
        FirebaseFirestore.instance.collection('paymentHistory').doc();
    PaymentHistory history = PaymentHistory(
      usercode: usercode,
      amount: amount,
      date: DateFormat("dd-MM-yyyy").format(
        DateTime.now(),
      ),
    );
    final historyJson = history.toJson();
    await docHistory.set(historyJson).onError((error, stackTrace) {
      return false;
    });
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot =
        await collection.where("usercode", isEqualTo: usercode).limit(1).get();
    int currentDue = docSnapshot.docs.first.data()['dues'];
    int newDue = currentDue - amount;
    collection.doc(docSnapshot.docs.first.id).update({"dues": newDue}).then(
      (value) {
        return true;
      },
      onError: (e) {
        return false;
      },
    );
    return true;
  }

  Future<List<Bottle>> getGivenBottles(String usercode) async {
    var collection = FirebaseFirestore.instance
        .collection('bottles')
        .where("issuedTo", isEqualTo: usercode);
    var docSnapshot = await collection.get();
    List<Bottle> bottles = [];
    docSnapshot.docs.forEach((element) {
      Bottle fetchedBottle = Bottle.fromJson(element.data());
      bottles.add(fetchedBottle);
    });
    return bottles;
  }

  Future<bool> giveBottles(String bottleID, String usercode) async {
    var collection = FirebaseFirestore.instance
        .collection('bottles')
        .where("bottleID", isEqualTo: bottleID);
    var docSnapshot = await collection.get();
    Bottle fetchedBottle = Bottle.fromJson(docSnapshot.docs.first.data());
    if (fetchedBottle.issuedTo != "") {
      return false;
    } else {
      FirebaseFirestore.instance
          .collection('bottles')
          .doc(docSnapshot.docs.first.id)
          .update({"issuedTo": usercode}).then((value) {
        return true;
      }).onError((error, stackTrace) {
        return false;
      });
    }
    return true;
  }

  Future<bool> receiveBottle(String bottleID) async {
    var collection = FirebaseFirestore.instance
        .collection('bottles')
        .where("bottleID", isEqualTo: bottleID);
    var docSnapshot = await collection.get();
    FirebaseFirestore.instance
        .collection('bottles')
        .doc(docSnapshot.docs.first.id)
        .update({"issuedTo": ""}).then((value) {
      return true;
    }).onError((error, stackTrace) {
      return false;
    });
    return true;
  }

  Future<List<Customer>> getDeliveryForDay(String day) async {
    List<Customer> customers = [];
    var collection = FirebaseFirestore.instance.collection('customers');
    var docSnapshot = await collection.where("bottleDay", isEqualTo: day).get();
    docSnapshot.docs.forEach((customer) {
      customers.add(
        Customer.fromJson(
          customer.data(),
        ),
      );
    });

    return customers;
  }

  Future<List<BottleOrder>> getOrdersForDate(String date) async {
    List<BottleOrder> orders = [];
    var collection = FirebaseFirestore.instance
        .collection('orders')
        .where("bottleDate", isEqualTo: date);
    var docSnapshot = await collection.get();
    docSnapshot.docs.forEach((order) {
      orders.add(
        BottleOrder.fromJson(
          order.data(),
        ),
      );
    });

    return orders;
  }

  String getRandomString(int length) {
    const _chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(
            _chars.length,
          ),
        ),
      ),
    );
  }
}
