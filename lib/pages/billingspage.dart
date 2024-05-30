import 'package:flutter/material.dart';
import 'package:tuition_management/pages/history.dart';
import 'package:tuition_management/pages/calculate.dart';
import 'package:tuition_management/pages/allstudent.dart';
import 'package:tuition_management/pages/duepayment.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class BillingsPage extends StatefulWidget {
  User user;
  BillingsPage(this.user, {super.key});

  @override
  State<BillingsPage> createState() => _BillingsPageState(user);
}

class _BillingsPageState extends State<BillingsPage> {
  User user;
  _BillingsPageState(this.user);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: Text('Billings Page',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20)),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary, fontSize: 15),
            tabs: const <Widget>[
              Tab(
                text: "Students",
              ),
              Tab(
                text: "Due",
              ),
              Tab(
                text: "Calculate",
              ),
              Tab(
                text: "History",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AllStudent(user),
            DuePayment(user),
            Calculate(user),
            History(user),
          ],
        ),
      ),
    );
  }
}
