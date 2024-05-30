import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tuition_management/models/batch.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:tuition_management/models/payment.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class SpecificStudent extends StatefulWidget {
  int studentid;
  String studentname;
  String studentphone;
  String studentemail;
  String parents_phone;
  String batchname;
  String added_on;
  String status;
  User user;
  SpecificStudent(
      this.studentid,
      this.studentname,
      this.studentphone,
      this.studentemail,
      this.parents_phone,
      this.batchname,
      this.added_on,
      this.status,
      this.user,
      {super.key});

  @override
  State<SpecificStudent> createState() => _SpecificStudentState(
      studentid,
      studentname,
      studentphone,
      studentemail,
      parents_phone,
      batchname,
      added_on,
      status,
      user);
}

class _SpecificStudentState extends State<SpecificStudent>
    with TickerProviderStateMixin {
  int studentid;
  String studentname;
  String studentphone;
  String studentemail;
  String parents_phone;
  String batchname;
  String added_on;
  String status;
  User user;
  _SpecificStudentState(
      this.studentid,
      this.studentname,
      this.studentphone,
      this.studentemail,
      this.parents_phone,
      this.batchname,
      this.added_on,
      this.status,
      this.user);

  final db = DatabaseHelper();
  late TabController _tabController;

  List<Batches> _fee = [];
  List<Payment> _history = [];
  List<Payment> _filterhistory = [];

  List<Map<String, dynamic>> _payment = [];
  List<Map<String, dynamic>> _filterpayment = [];

  DateTime selectedDate = DateTime.now();
  GlobalKey<FormState> form = GlobalKey();
  TextEditingController datecontroller = TextEditingController();
  TextEditingController paid_ammount = TextEditingController();
  TextEditingController discount = TextEditingController();

  Future<void> _fetchFee() async {
    _fee.clear();
    _fee = await db.getBatchFee(widget.batchname, int.parse(widget.user.id));
  }

  Future<List<Payment>> _getPaymentHistory() async {
    _filterhistory.clear();
    _filterhistory =
        await db.getPaymentDetails(widget.studentid, int.parse(widget.user.id));

    _history.clear();
    for (int i = _filterhistory.length - 1; i >= 0; i--) {
      _history.add(_filterhistory[i]);
    }

    return _history;
  }

  Future<List<Map<String, dynamic>>> _getDues() async {
    _filterpayment.clear();

    _filterpayment = await db.getStudentsWithDues(
        widget.studentid, int.parse(widget.user.id));

    _payment.clear();
    for (int i = _filterpayment.length - 1; i >= 0; i--) {
      _payment.add(_filterpayment[i]);
    }

    return _payment;
  }

  makePayment(
      int index,
      int studentid,
      String batchname,
      String paid_ammount,
      String paymentdate,
      String month,
      String year,
      int discount,
      int userid) async {
    var response = await db.paymentDone(
        studentid,
        batchname.trim(),
        paid_ammount.trim(),
        paymentdate.trim(),
        month.trim(),
        year.trim(),
        discount,
        int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      Navigator.pop(context);
      AwesomeDialog(
        dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.success,
        title: 'Make Payment',
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        desc: 'Payment Successfully Done',
        descTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        btnOkOnPress: () {},
      ).show();

      setState(() {
        _payment.removeAt(index);
      });

      _getPaymentHistory();
    }
  }

  @override
  void initState() {
    _fetchFee();
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: const Text(
            'Student Information',
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: AutoSizeText(
                    studentname[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.background,
                    ),
                  ),
                ),
                title: AutoSizeText(
                  studentname.toUpperCase(),
                ),
              ),
              const SizedBox(
                height: 30,
                child: ListTile(
                  leading: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    'Other Details :',
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Phone Number:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: studentphone.isNotEmpty
                      ? AutoSizeText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          studentphone,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : const AutoSizeText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          "Do Not Have ",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                ),
              ),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Email:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: studentemail.isNotEmpty
                      ? AutoSizeText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          studentemail,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      : const AutoSizeText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          "Do Not Have ",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                ),
              ),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Parent Phone Number:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    parents_phone,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Batch Name:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    batchname,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Added On:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    added_on,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
                child: ListTile(
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: const SizedBox(
                    width: 120,
                    child: AutoSizeText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      'Status:',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  title: AutoSizeText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    status == '1' ? 'ACTIVE' : "INACTIVE",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Payment Dues"),
                      Tab(text: "Payment History"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _getDues(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              if (_payment.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Center(
                                    child: Text('No dues found.'),
                                  ),
                                );
                              }
                              return Scrollbar(
                                child: ListView.builder(
                                  itemCount: _payment.length,
                                  itemBuilder: (context, index) {
                                    final student = _payment[index];
                                    return Card(
                                      elevation: 10,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(13),
                                        ),
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: AutoSizeText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            '${DateFormat('MMMM').format(DateTime(student['year'], student['month']))}-${student['year']}',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: const StadiumBorder(),
                                                ),
                                                onPressed: () {
                                                  datecontroller.text = '';
                                                  paid_ammount.text = _fee[0]
                                                      .batchfees
                                                      .toString();
                                                  discount.text = '0';
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return BackdropFilter(
                                                        filter: ImageFilter.blur(
                                                            sigmaX: 5, sigmaY: 5),
                                                        child: AlertDialog(
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .scaffoldBackgroundColor,
                                                          title: Center(
                                                            child: Text(
                                                              'Make Payment',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                            ),
                                                          ),
                                                          content: Form(
                                                            key: form,
                                                            child: Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color: Colors
                                                                  .transparent,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    TextFormField(
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .currency_rupee_rounded,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color:
                                                                                  Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                        hintText:
                                                                            'Enter Payment Ammount',
                                                                        labelText:
                                                                            'Payment Ammount',
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                      ),
                                                                      controller:
                                                                          paid_ammount,
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return "field required";
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    TextFormField(
                                                                      readOnly:
                                                                          true,
                                                                      controller:
                                                                          datecontroller,
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return "field required";
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            "Enter Payment Date",
                                                                        labelText:
                                                                            "Payment Date",
                                                                        fillColor:
                                                                            Colors
                                                                                .transparent,
                                                                        filled:
                                                                            true,
                                                                        suffixIcon:
                                                                            IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            showDatePickerDialog(
                                                                              context:
                                                                                  context,
                                                                              initialDate:
                                                                                  selectedDate,
                                                                              minDate: DateTime(
                                                                                  2000,
                                                                                  1,
                                                                                  1),
                                                                              maxDate: DateTime(
                                                                                  2107,
                                                                                  12,
                                                                                  31),
                                                                              currentDateDecoration:
                                                                                  const BoxDecoration(
                                                                                color: Colors.cyan,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              currentDateTextStyle:
                                                                                  const TextStyle(fontWeight: FontWeight.normal),
                                                                              daysOfTheWeekTextStyle:
                                                                                  const TextStyle(fontWeight: FontWeight.bold),
                                                                              initialPickerType:
                                                                                  PickerType.days,
                                                                              selectedCellDecoration:
                                                                                  const BoxDecoration(
                                                                                color: Colors.cyan,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              selectedCellTextStyle:
                                                                                  const TextStyle(fontWeight: FontWeight.normal),
                                                                              slidersColor:
                                                                                  Colors.lightBlue,
                                                                              highlightColor:
                                                                                  Colors.redAccent,
                                                                              slidersSize:
                                                                                  20,
                                                                              splashColor:
                                                                                  Colors.lightBlueAccent,
                                                                              splashRadius:
                                                                                  40,
                                                                              centerLeadingDate:
                                                                                  true,
                                                                            ).then(
                                                                              (pickedDate) {
                                                                                if (pickedDate != null && pickedDate != selectedDate) {
                                                                                  setState(
                                                                                    () {
                                                                                      selectedDate = pickedDate;
                                                                                      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                                                                      datecontroller.text = formattedDate;
                                                                                    },
                                                                                  );
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons
                                                                                .calendar_month_outlined,
                                                                            color: Theme.of(context)
                                                                                .colorScheme
                                                                                .onPrimary,
                                                                          ),
                                                                        ),
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .date_range_outlined,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color:
                                                                                  Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    TextFormField(
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .currency_rupee_rounded,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color:
                                                                                  Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                        hintText:
                                                                            'Enter Discount Ammount',
                                                                        labelText:
                                                                            'Discount Ammount',
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                      ),
                                                                      controller:
                                                                          discount,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                            '') {
                                                                          return 'Discount Required';
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                paid_ammount
                                                                    .text = '';
                                                                discount.text =
                                                                    '';
                                                                datecontroller
                                                                    .text = '';
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                if (form
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (paid_ammount
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      discount
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      datecontroller
                                                                          .text
                                                                          .isNotEmpty) {
                                                                    makePayment(
                                                                        index,
                                                                        widget
                                                                            .studentid,
                                                                        widget
                                                                            .batchname,
                                                                        paid_ammount
                                                                            .text,
                                                                        datecontroller
                                                                            .text,
                                                                        student['month']
                                                                            .toString(),
                                                                        student['year']
                                                                            .toString(),
                                                                        int.parse(
                                                                            discount
                                                                                .text),
                                                                        int.parse(widget
                                                                            .user
                                                                            .id));
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Enter all the details");
                                                                  }
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Pay'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.currency_rupee,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                label: Text(
                                                  'Pay'.toUpperCase(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                            Flexible(
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: const StadiumBorder(),
                                                ),
                                                onPressed: () {
                                                  datecontroller.text = '';
                                                  paid_ammount.text = '0';
                                                  discount.text = _fee[0]
                                                      .batchfees
                                                      .toString();
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 5,
                                                                sigmaY: 5),
                                                        child: AlertDialog(
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .scaffoldBackgroundColor,
                                                          title: Center(
                                                            child: Text(
                                                              'Wave Off',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                            ),
                                                          ),
                                                          content: Form(
                                                            key: form,
                                                            child: Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              color: Colors
                                                                  .transparent,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    TextFormField(
                                                                      readOnly:
                                                                          true,
                                                                      controller:
                                                                          datecontroller,
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return "field required";
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintText:
                                                                            "Enter Payment Date",
                                                                        labelText:
                                                                            "Payment Date",
                                                                        fillColor:
                                                                            Colors.transparent,
                                                                        filled:
                                                                            true,
                                                                        suffixIcon:
                                                                            IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            showDatePickerDialog(
                                                                              context: context,
                                                                              initialDate: selectedDate,
                                                                              minDate: DateTime(2000, 1, 1),
                                                                              maxDate: DateTime(2107, 12, 31),
                                                                              currentDateDecoration: const BoxDecoration(
                                                                                color: Colors.cyan,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              currentDateTextStyle: const TextStyle(fontWeight: FontWeight.normal),
                                                                              daysOfTheWeekTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                                              initialPickerType: PickerType.days,
                                                                              selectedCellDecoration: const BoxDecoration(
                                                                                color: Colors.cyan,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              selectedCellTextStyle: const TextStyle(fontWeight: FontWeight.normal),
                                                                              slidersColor: Colors.lightBlue,
                                                                              highlightColor: Colors.redAccent,
                                                                              slidersSize: 20,
                                                                              splashColor: Colors.lightBlueAccent,
                                                                              splashRadius: 40,
                                                                              centerLeadingDate: true,
                                                                            ).then(
                                                                              (pickedDate) {
                                                                                if (pickedDate != null && pickedDate != selectedDate) {
                                                                                  setState(
                                                                                    () {
                                                                                      selectedDate = pickedDate;
                                                                                      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
                                                                                      datecontroller.text = formattedDate;
                                                                                    },
                                                                                  );
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons.calendar_month_outlined,
                                                                            color:
                                                                                Theme.of(context).colorScheme.onPrimary,
                                                                          ),
                                                                        ),
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .date_range_outlined,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color: Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextFormField(
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .currency_rupee_rounded,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color: Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                        hintText:
                                                                            'Enter Payment Ammount',
                                                                        labelText:
                                                                            'Payment Ammount',
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                      ),
                                                                      controller:
                                                                          paid_ammount,
                                                                      validator:
                                                                          (value) {
                                                                        if (value!
                                                                            .isEmpty) {
                                                                          return "field required";
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    TextFormField(
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        prefixIcon:
                                                                            Icon(
                                                                          Icons
                                                                              .currency_rupee_rounded,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(25),
                                                                          borderSide: const BorderSide(
                                                                              color: Colors.black,
                                                                              width: 3),
                                                                        ),
                                                                        hintText:
                                                                            'Enter Discount Ammount',
                                                                        labelText:
                                                                            'Discount Ammount',
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimary,
                                                                        ),
                                                                      ),
                                                                      controller:
                                                                          discount,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                            '') {
                                                                          return 'Discount Required';
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                paid_ammount
                                                                    .text = '';
                                                                discount.text =
                                                                    '';
                                                                datecontroller
                                                                    .text = '';
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                if (form
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (paid_ammount
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      discount
                                                                          .text
                                                                          .isNotEmpty &&
                                                                      datecontroller
                                                                          .text
                                                                          .isNotEmpty) {
                                                                    makePayment(
                                                                        index,
                                                                        widget
                                                                            .studentid,
                                                                        widget
                                                                            .batchname,
                                                                        paid_ammount
                                                                            .text,
                                                                        datecontroller
                                                                            .text,
                                                                        student['month']
                                                                            .toString(),
                                                                        student['year']
                                                                            .toString(),
                                                                        int.parse(discount
                                                                            .text),
                                                                        int.parse(widget
                                                                            .user
                                                                            .id));
                                                                  } else {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Enter all the details");
                                                                  }
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Wave Off'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.currency_rupee,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                                label: Text(
                                                  'Wave Off'.toUpperCase(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: AutoSizeText(
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          "₹${_fee[0].batchfees}",
                                          style: const TextStyle(
                                              fontSize: 18,
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
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: FutureBuilder<List<Payment>>(
                          future: _getPaymentHistory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: ListTile(
                                        title: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: AutoSizeText(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            '${DateFormat('MMMM').format(DateTime(int.parse(student.year), int.parse(student.month)))}-${int.parse(student.year)}',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Flexible(
                                                  child: AutoSizeText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    "Paid On :",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: AutoSizeText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    student.paymentdate
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              child: Row(
                                                children: [
                                                  const Flexible(
                                                    child: AutoSizeText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      "Paid Amount :",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal),
                                                    ),
                                                  ),
                                                  const Flexible(
                                                    child: Icon(Icons
                                                        .currency_rupee_rounded),
                                                  ),
                                                  Flexible(
                                                    child: AutoSizeText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      student.paid_ammount
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Flexible(
                                                  child: AutoSizeText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    "Discount:",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                                const Flexible(
                                                  child: Icon(Icons
                                                      .currency_rupee_rounded),
                                                ),
                                                Flexible(
                                                  child: AutoSizeText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    student.discount.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: int.parse(
                                                    student.batchfees) ==
                                                student.discount
                                            ? const AutoSizeText(
                                                "Waved Off",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              )
                                            : const AutoSizeText(
                                                "Paid",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.normal),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
