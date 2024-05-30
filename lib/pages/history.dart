import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tuition_management/models/payment.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class History extends StatefulWidget {
  User user;
  History(this.user, {super.key});

  @override
  State<History> createState() => _HistoryState(user);
}

class _HistoryState extends State<History> {
  User user;
  _HistoryState(this.user);

  List<Payment> _history = [];
  List<Payment> _filterhistory = [];
  final db = DatabaseHelper();

  Future<List<Payment>> _getPaymentHistory() async {
    _filterhistory.clear();
    _filterhistory = await db.getAllPaymentDetails(int.parse(widget.user.id));

    _history.clear();
    for (int i = _filterhistory.length - 1; i >= 0; i--) {
      _history.add(_filterhistory[i]);
    }

    return _history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: FutureBuilder<List<Payment>>(
            future: _getPaymentHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.red,
                  )),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (_history.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Center(
                      child: Text('Payment history not found.'),
                    ),
                  );
                }
                return Scrollbar(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final student = _history[index];
                      return Card(
                        elevation: 10,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(13),
                          ),
                        ),
                        color: Theme.of(context).colorScheme.primaryContainer,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        '${student.studentname}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        'Batch :',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        '${student.batchname}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        'Payment Of :',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        '${DateFormat('MMMM').format(DateTime(int.parse(student.year), int.parse(student.month)))}-${int.parse(student.year)}',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        "Paid Amount :",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Flexible(child: Icon(Icons.currency_rupee_rounded)),
                                    Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        student.paid_ammount.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        "Discount :",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Flexible(child: Icon(Icons.currency_rupee_rounded)),
                                    Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        student.discount.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        "Paid On :",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        student.paymentdate.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing:
                              int.parse(student.batchfees) == student.discount
                                  ? const AutoSizeText(
                                      "Waved Off",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.normal),
                                    )
                                  : const AutoSizeText(
                                      "Paid",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.green,
                                          fontWeight: FontWeight.normal),
                                    ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
