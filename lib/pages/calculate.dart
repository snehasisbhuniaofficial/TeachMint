import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class Calculate extends StatefulWidget {
  User user;
  Calculate(this.user, {super.key});

  @override
  State<Calculate> createState() => _CalculateState(user);
}

class _CalculateState extends State<Calculate> with TickerProviderStateMixin {
  User user;
  _CalculateState(this.user);

  String selectedMonth = "";
  String selectedYear = "";
  List<Map<String, dynamic>> studentDetails = [];
  bool isVisible = false;

  double total = 0.0;
  double due = 0.0;
  double totalpaid = 0.0;
  double discount = 0.0;

  DateTime selectedDate = DateTime.now();
  GlobalKey<FormState> form = GlobalKey();
  TextEditingController datecontroller = TextEditingController();
  TextEditingController paid_ammount = TextEditingController();
  TextEditingController discountamt = TextEditingController();

  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  List<String> years = List.generate(101, (index) => (2000 + index).toString());
  final db = DatabaseHelper();

  Future<void> fetchStudentDetails() async {
    if (selectedMonth.isNotEmpty && selectedYear.isNotEmpty) {
      int monthIndex = DateFormat('MMMM').parse(selectedMonth).month;
      final details = await db.getAllStudentDetailsForMonth(
          int.parse(widget.user.id), monthIndex, int.parse(selectedYear));
      setState(() {
        studentDetails = details;
        isVisible = true;
      });
      total = 0.0;
      totalpaid = 0.0;
      due = 0.0;
      discount = 0.0;
      for (int i = 0; i < studentDetails.length; i++) {
        total = total + double.parse(studentDetails[i]["batchfees"]);
        discount = discount +
            double.parse(studentDetails[i]['totaldiscount'].toString());
        if (studentDetails[i]['paid']) {
          totalpaid = totalpaid +
              double.parse(studentDetails[i]['totalPaidAmount'].toString());
        } else {
          due = due +
              (double.parse(studentDetails[i]["batchfees"]) -
                  (double.parse(
                          studentDetails[i]['totalPaidAmount'].toString()) -
                      double.parse(
                          studentDetails[i]['totaldiscount'].toString())));
        }
      }
    } else {
      if (selectedMonth.isEmpty && selectedYear.isEmpty) {
        Fluttertoast.showToast(msg: "Select Month and Year");
      } else if (selectedMonth.isEmpty) {
        Fluttertoast.showToast(msg: "Select Month");
      } else {
        Fluttertoast.showToast(msg: "Select Year");
      }
    }
  }

  makePayment(
      int studentid,
      String batchname,
      String paid_ammount,
      String paymentdate,
      String month,
      String year,
      int discount,
      int userid) async {
    int monthIndex = DateFormat('MMMM').parse(month).month;
    var response = await db.paymentDone(
        studentid,
        batchname.trim(),
        paid_ammount.trim(),
        paymentdate.trim(),
        monthIndex.toString().trim(),
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
      fetchStudentDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Choose Month....',
                  labelText: 'SELECT MONTH',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                value: months.contains(selectedMonth) ? selectedMonth : null,
                items: months.map(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value.toString();
                  });
                  fetchStudentDetails();
                },
                validator: (value) => value == null ? 'Field required' : null,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Choose Year....',
                  labelText: 'SELECT YEAR',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                value: years.contains(selectedYear) ? selectedYear : null,
                items: years.map(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value.toString();
                  });
                  fetchStudentDetails();
                },
                validator: (value) => value == null ? 'Field required' : null,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Visibility(
              visible: isVisible && studentDetails.length > 0,
              child: ListTile(
                title: AutoSizeText(
                  studentDetails.length > 1 ? "Students :" : "Student :",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: studentDetails.length > 0
                    ? ListView.builder(
                        itemCount: studentDetails.length,
                        itemBuilder: (context, index) {
                          final student = studentDetails[index];
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Card(
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
                                title: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            "${student['studentname']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Flexible(
                                          child: AutoSizeText(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            "Batch: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20),
                                          ),
                                        ),
                                        Flexible(
                                          child: AutoSizeText(
                                            "${student['batchname']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Flexible(
                                          child: AutoSizeText(
                                            "Fee: ",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20),
                                          ),
                                        ),
                                        Flexible(
                                          child: AutoSizeText(
                                            "₹${student['batchfees']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Visibility(
                                  visible: student['paid'] == false,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: const StadiumBorder(),
                                          ),
                                          onPressed: () {
                                            datecontroller.text = '';
                                            paid_ammount.text =
                                                student['batchfees'].toString();
                                            discountamt.text = '0';
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 5, sigmaY: 5),
                                                  child: AlertDialog(
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    title: Center(
                                                      child: Text(
                                                        'Make Payment',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                      ),
                                                    ),
                                                    content: Form(
                                                      key: form,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color:
                                                            Colors.transparent,
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
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  hintText:
                                                                      'Enter Payment Ammount',
                                                                  labelText:
                                                                      'Payment Ammount',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
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
                                                                readOnly: true,
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
                                                                  fillColor: Colors
                                                                      .transparent,
                                                                  filled: true,
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
                                                                          color:
                                                                              Colors.cyan,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        currentDateTextStyle:
                                                                            const TextStyle(fontWeight: FontWeight.normal),
                                                                        daysOfTheWeekTextStyle:
                                                                            const TextStyle(fontWeight: FontWeight.bold),
                                                                        initialPickerType:
                                                                            PickerType.days,
                                                                        selectedCellDecoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.cyan,
                                                                          shape:
                                                                              BoxShape.circle,
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
                                                                          if (pickedDate != null &&
                                                                              pickedDate != selectedDate) {
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
                                                                    icon: Icon(
                                                                      Icons
                                                                          .calendar_month_outlined,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary,
                                                                    ),
                                                                  ),
                                                                  prefixIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .date_range_outlined,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
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
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  hintText:
                                                                      'Enter Discount Ammount',
                                                                  labelText:
                                                                      'Discount Ammount',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                ),
                                                                controller:
                                                                    discountamt,
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
                                                          Navigator.of(context)
                                                              .pop();
                                                          paid_ammount.text =
                                                              '';
                                                          discountamt.text = '';
                                                          datecontroller.text =
                                                              '';
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          if (form.currentState!
                                                              .validate()) {
                                                            if (paid_ammount
                                                                    .text
                                                                    .isNotEmpty &&
                                                                discountamt.text
                                                                    .isNotEmpty &&
                                                                datecontroller
                                                                    .text
                                                                    .isNotEmpty) {
                                                              makePayment(
                                                                  int.parse(student[
                                                                          'studentid']
                                                                      .toString()),
                                                                  student[
                                                                      'batchname'],
                                                                  paid_ammount
                                                                      .text,
                                                                  datecontroller
                                                                      .text,
                                                                  selectedMonth
                                                                      .toString(),
                                                                  selectedYear
                                                                      .toString(),
                                                                  int.parse(
                                                                      discountamt
                                                                          .text),
                                                                  int.parse(
                                                                      widget
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
                                                        child:
                                                            const Text('Pay'),
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: const StadiumBorder(),
                                          ),
                                          onPressed: () {
                                            datecontroller.text = '';
                                            paid_ammount.text = '0';
                                            discountamt.text =
                                                student['batchfees'].toString();
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 5, sigmaY: 5),
                                                  child: AlertDialog(
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    title: Center(
                                                      child: Text(
                                                        'Wave Off',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                      ),
                                                    ),
                                                    content: Form(
                                                      key: form,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color:
                                                            Colors.transparent,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextFormField(
                                                                readOnly: true,
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
                                                                  fillColor: Colors
                                                                      .transparent,
                                                                  filled: true,
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
                                                                          color:
                                                                              Colors.cyan,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        currentDateTextStyle:
                                                                            const TextStyle(fontWeight: FontWeight.normal),
                                                                        daysOfTheWeekTextStyle:
                                                                            const TextStyle(fontWeight: FontWeight.bold),
                                                                        initialPickerType:
                                                                            PickerType.days,
                                                                        selectedCellDecoration:
                                                                            const BoxDecoration(
                                                                          color:
                                                                              Colors.cyan,
                                                                          shape:
                                                                              BoxShape.circle,
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
                                                                          if (pickedDate != null &&
                                                                              pickedDate != selectedDate) {
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
                                                                    icon: Icon(
                                                                      Icons
                                                                          .calendar_month_outlined,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary,
                                                                    ),
                                                                  ),
                                                                  prefixIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .date_range_outlined,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
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
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  hintText:
                                                                      'Enter Payment Ammount',
                                                                  labelText:
                                                                      'Payment Ammount',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
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
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  prefixIcon:
                                                                      Icon(
                                                                    Icons
                                                                        .currency_rupee_rounded,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            3),
                                                                  ),
                                                                  hintText:
                                                                      'Enter Discount Ammount',
                                                                  labelText:
                                                                      'Discount Ammount',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                  ),
                                                                ),
                                                                controller:
                                                                    discountamt,
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
                                                          Navigator.of(context)
                                                              .pop();
                                                          paid_ammount.text =
                                                              '';
                                                          discountamt.text = '';
                                                          datecontroller.text =
                                                              '';
                                                        },
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          if (form.currentState!
                                                              .validate()) {
                                                            if (paid_ammount
                                                                    .text
                                                                    .isNotEmpty &&
                                                                discountamt.text
                                                                    .isNotEmpty &&
                                                                datecontroller
                                                                    .text
                                                                    .isNotEmpty) {
                                                              makePayment(
                                                                  int.parse(student[
                                                                          'studentid']
                                                                      .toString()),
                                                                  student[
                                                                      'batchname'],
                                                                  paid_ammount
                                                                      .text,
                                                                  datecontroller
                                                                      .text,
                                                                  selectedMonth
                                                                      .toString(),
                                                                  selectedYear
                                                                      .toString(),
                                                                  int.parse(
                                                                      discountamt
                                                                          .text),
                                                                  int.parse(
                                                                      widget
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
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: student['paid']
                                    ? const Column(
                                        children: [
                                          Icon(Icons.check,
                                              color: Colors.green),
                                          AutoSizeText('Paid',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ],
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.red),
                                          AutoSizeText('Due',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      )
                    : Visibility(
                        visible: isVisible,
                        child:
                            const Center(child: AutoSizeText("No Data Found"))),
              ),
            ),
            Visibility(
              visible: isVisible && studentDetails.length > 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              'Total Fees: ₹${total.toStringAsFixed(2)},',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Flexible(
                            child: AutoSizeText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              '  Fees Earned: ₹${totalpaid.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              'Total Due: ₹${due.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          discount > 0.0
                              ? Flexible(
                                  child: AutoSizeText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    ',  Total Discount: ₹${discount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                )
                              : const Flexible(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
