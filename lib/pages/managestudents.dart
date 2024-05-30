import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:tuition_management/models/student.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class ManageStudents extends StatefulWidget {
  User user;
  ManageStudents(this.user, {super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState(user);
}

class _ManageStudentsState extends State<ManageStudents> {
  User user;
  _ManageStudentsState(this.user);
  GlobalKey<FormState> _form = GlobalKey();
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _parents_phone = TextEditingController();

  GlobalKey<FormState> form = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController parents_phone = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  List<String> _batchlist = [];
  final db = DatabaseHelper();
  String _batchname = '';
  String _batch = '';
  List<Students> _students = [];
  List<Students> _filteredStudents = [];
  TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController datecontroller = TextEditingController();

  Future<void> _fetchStudents() async {
    _students.clear();
    _batchlist = await db.getBatches(int.parse(user.id));
    _students = await db.getStudents(int.parse(user.id));
    setState(() {
      _filteredStudents = _students;
    });
  }

  addStudent(String studentname, String studentphone, String studentemail,
      String parents_phone, String batchname, String added_on) async {
    var response = await db.addStudent(
        studentname.trim(),
        studentphone.trim(),
        studentemail.trim(),
        parents_phone.trim(),
        batchname.trim(),
        added_on.trim(),
        int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      AwesomeDialog(
        dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.success,
        title: 'Add Student',
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        desc: 'Successfully Added',
        descTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        btnOkOnPress: () {},
      ).show();
      _fetchStudents();
    }
  }

  updateStudentDetails(
    int index,
    int studentid,
    String studentname,
    String studentphone,
    String studentemail,
    String parents_phone,
    String batchname,
  ) async {
    var response = await db.updateStudentDetails(
        studentid,
        studentname.trim(),
        studentphone.trim(),
        studentemail.trim(),
        parents_phone.trim(),
        batchname.trim(),
        int.parse(user.id));
    if (response == true) {
      Navigator.pop(context);
      if (!mounted) return;
      setState(() {
        _filteredStudents[index].studentname = studentname.trim();
        _filteredStudents[index].studentphone = studentphone.trim();
        _filteredStudents[index].studentemail =
            studentemail.toLowerCase().trim();
        _filteredStudents[index].parents_phone = parents_phone.trim();
        _filteredStudents[index].batchname = batchname.trim();
      });
    }
  }

  updateStatus(int index, int studentid, int status) async {
    var response = await db.updateStatus(studentid, status, int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      setState(() {
        _filteredStudents[index].status = status.toString();
      });
    }
  }

  deleteStudent(int index, int studentid) async {
    var response = await db.deleteStudent(studentid, int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      setState(() {
        _filteredStudents.removeAt(index);
      });
    }
  }

  @override
  void initState() {
    _fetchStudents();
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = _students
          .where((data) =>
              data.studentname.toLowerCase().contains(query.toLowerCase()) ||
              data.batchname.toLowerCase().contains(query.toLowerCase()) ||
              data.studentphone.toLowerCase().contains(query.toLowerCase()) ||
              data.studentemail.toLowerCase().contains(query.toLowerCase()) ||
              data.parents_phone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text(
          "Manage Students",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: AlertDialog(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          title: Center(
                            child: Text(
                              'Information',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          content: const Text(
                            'You must add atleast one batch for adding Student otherwise you cannot add Student.',
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(color: Colors.deepPurple),
                                )),
                          ],
                        ),
                      );
                    });
              },
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimary,
              ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: FloatingActionButton.extended(
          label: const Text(
            'Add Student',
          ),
          backgroundColor: Colors.green,
          onPressed: () {
            _name.text = '';
            _phone.text = '';
            _email.text = '';
            _parents_phone.text = '';
            _batchname = '';
            datecontroller.text = '';
            if (_batchlist.isNotEmpty) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      title: Center(
                        child: Text(
                          'Add Student',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      content: Form(
                        key: _form,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.transparent,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 3),
                                    ),
                                    hintText: 'Enter Student Name',
                                    labelText: 'Student Name *',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  controller: _name,
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Name Required';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 3),
                                    ),
                                    hintText: 'Enter Student Phone Number',
                                    labelText: 'Student Phone Number',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  controller: _phone,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 3),
                                    ),
                                    hintText: 'Enter Parents Phone Number',
                                    labelText: 'Parents Phone Number *',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  controller: _parents_phone,
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Phone Number Required';
                                    } else if (value!.length < 10) {
                                      return "Please enter valid phone";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 3),
                                    ),
                                    hintText: 'Enter Student Email ID',
                                    labelText: 'Student Email ID',
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  controller: _email,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Choose Batch....',
                                    labelText: 'SELECT BATCH *',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.school_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  value: _batchlist.contains(_batchname)
                                      ? _batchname
                                      : null,
                                  items: _batchlist.map(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _batchname = value.toString();
                                    });
                                  },
                                  validator: (value) =>
                                      value == null ? 'Field required' : null,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller: datecontroller,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "field required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter Joining Date",
                                    labelText: "Joining Date",
                                    fillColor: Colors.transparent,
                                    filled: true,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        showDatePickerDialog(
                                          context: context,
                                          initialDate: selectedDate,
                                          minDate: DateTime(2000, 1, 1),
                                          maxDate: DateTime(2107, 12, 31),
                                          currentDateDecoration:
                                              const BoxDecoration(
                                            color: Colors.cyan,
                                            shape: BoxShape.circle,
                                          ),
                                          currentDateTextStyle: const TextStyle(
                                              fontWeight: FontWeight.normal),
                                          daysOfTheWeekTextStyle:
                                              const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                          initialPickerType: PickerType.days,
                                          selectedCellDecoration:
                                              const BoxDecoration(
                                            color: Colors.cyan,
                                            shape: BoxShape.circle,
                                          ),
                                          selectedCellTextStyle:
                                              const TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal),
                                          slidersColor: Colors.lightBlue,
                                          highlightColor: Colors.redAccent,
                                          slidersSize: 20,
                                          splashColor: Colors.lightBlueAccent,
                                          splashRadius: 40,
                                          centerLeadingDate: true,
                                        ).then(
                                          (pickedDate) {
                                            if (pickedDate != null &&
                                                pickedDate != selectedDate) {
                                              setState(
                                                () {
                                                  selectedDate = pickedDate;
                                                  String formattedDate =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate);
                                                  datecontroller.text =
                                                      formattedDate;
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.calendar_month_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.date_range_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.black, width: 3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _name.text = '';
                            _phone.text = '';
                            _email.text = '';
                            _parents_phone.text = '';
                            _batchname = '';
                            datecontroller.text = '';
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_form.currentState!.validate()) {
                              if (_name.text.isNotEmpty &&
                                  _parents_phone.text.isNotEmpty &&
                                  _batchname.isNotEmpty &&
                                  datecontroller.text.isNotEmpty) {
                                addStudent(
                                    _name.text.toString(),
                                    _phone.text.toString(),
                                    _email.text.toLowerCase().toString(),
                                    _parents_phone.text.toString(),
                                    _batchname.toUpperCase().toString(),
                                    datecontroller.text.toString());
                                Navigator.of(context).pop();
                                _name.text = '';
                                _phone.text = '';
                                _email.text = '';
                                _parents_phone.text = '';
                                _batchname = '';
                                datecontroller.text = '';
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Enter all the details");
                              }
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                dialogBackgroundColor:
                    Theme.of(context).scaffoldBackgroundColor,
                animType: AnimType.rightSlide,
                headerAnimationLoop: false,
                title: 'Error',
                desc:
                    'You must add atleast one batch for adding Student, otherwise you cannot add Student.',
                btnOkOnPress: () {},
                btnOkIcon: Icons.cancel,
                btnOkColor: Colors.red,
              ).show();
            }
          },
          icon: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                labelText: 'Search Student',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredStudents.isNotEmpty
                ? Scrollbar(
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
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
                          child: ExpansionTile(
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide.none,
                            ),
                            shape: const RoundedRectangleBorder(
                              side: BorderSide.none,
                            ),
                            childrenPadding:
                                const EdgeInsets.symmetric(horizontal: 17),
                            expandedCrossAxisAlignment: CrossAxisAlignment.end,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _filteredStudents[index].status == '1'
                                        ? const Flexible(
                                            child: AutoSizeText(
                                              'Active ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                                color: Colors.green,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : const Flexible(
                                            child: AutoSizeText(
                                              'Inactive ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                                color: Colors.red,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        _filteredStudents[index]
                                            .studentname
                                            .toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Flexible(
                                      child: AutoSizeText(
                                        'Batch Name: ',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        _filteredStudents[index]
                                            .batchname
                                            .toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: AutoSizeText(
                                      'Phone: ',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _filteredStudents[index].studentphone != ''
                                      ? Flexible(
                                          child: AutoSizeText(
                                            _filteredStudents[index]
                                                .studentphone
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        )
                                      : const Flexible(
                                          child: AutoSizeText(
                                            'Do Not Have',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    child: AutoSizeText(
                                      'Parents Phone: ',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: AutoSizeText(
                                      _filteredStudents[index]
                                          .parents_phone
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    child: AutoSizeText(
                                      'Email ID: ',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _filteredStudents[index].studentemail != ''
                                      ? Flexible(
                                          child: AutoSizeText(
                                            _filteredStudents[index]
                                                .studentemail
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        )
                                      : const Flexible(
                                          child: AutoSizeText(
                                            'Do Not Have',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Flexible(
                                    child: AutoSizeText(
                                      'Added On: ',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: AutoSizeText(
                                      _filteredStudents[index]
                                          .added_on
                                          .toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 5.0, top: 5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _filteredStudents[index].status == '1'
                                        ? Flexible(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                shape: const StadiumBorder(),
                                              ),
                                              onPressed: () {
                                                updateStatus(
                                                    index,
                                                    _filteredStudents[index]
                                                        .studentid,
                                                    0);
                                              },
                                              child: const Text(
                                                'INACTIVE',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Flexible(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: const StadiumBorder(),
                                              ),
                                              onPressed: () {
                                                updateStatus(
                                                    index,
                                                    _filteredStudents[index]
                                                        .studentid,
                                                    1);
                                              },
                                              child: const Text(
                                                'ACTIVE',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: const StadiumBorder(),
                                        ),
                                        onPressed: () {
                                          name.text = _filteredStudents[index]
                                              .studentname
                                              .toString();
                                          phone.text = _filteredStudents[index]
                                              .studentphone
                                              .toString();
                                          email.text = _filteredStudents[index]
                                              .studentemail
                                              .toLowerCase()
                                              .toString();
                                          parents_phone.text =
                                              _filteredStudents[index]
                                                  .parents_phone
                                                  .toString();
                                          _batch = _filteredStudents[index]
                                              .batchname
                                              .toString();

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
                                                      'Update Student Details',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                    ),
                                                  ),
                                                  content: Form(
                                                    key: form,
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      color: Colors.transparent,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .name,
                                                              decoration:
                                                                  InputDecoration(
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.person,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 3),
                                                                ),
                                                                hintText:
                                                                    'Enter Student Name',
                                                                labelText:
                                                                    'Student Name *',
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
                                                              controller: name,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    '') {
                                                                  return 'Name Required';
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
                                                                  Icons.phone,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 3),
                                                                ),
                                                                hintText:
                                                                    'Enter Student Phone Number',
                                                                labelText:
                                                                    'Student Phone Number',
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
                                                              controller: phone,
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
                                                                  Icons.phone,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 3),
                                                                ),
                                                                hintText:
                                                                    'Enter Parents Phone Number',
                                                                labelText:
                                                                    'Parents Phone Number *',
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
                                                                  parents_phone,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                    '') {
                                                                  return 'Parents Phone Number Required';
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
                                                                      .emailAddress,
                                                              decoration:
                                                                  InputDecoration(
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.email,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 3),
                                                                ),
                                                                hintText:
                                                                    'Enter Student Email ID',
                                                                labelText:
                                                                    'Student Email ID',
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
                                                              controller: email,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            DropdownButtonFormField<
                                                                String>(
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Choose Batch....',
                                                                labelText:
                                                                    'SELECT BATCH *',
                                                                hintStyle:
                                                                    TextStyle(
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
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .school_outlined,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onPrimary,
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                ),
                                                              ),
                                                              value: _batchlist
                                                                      .contains(
                                                                          _batch)
                                                                  ? _batch
                                                                  : null,
                                                              items: _batchlist
                                                                  .map(
                                                                (String value) {
                                                                  return DropdownMenuItem<
                                                                      String>(
                                                                    value:
                                                                        value,
                                                                    child: Text(
                                                                        value),
                                                                  );
                                                                },
                                                              ).toList(),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _batch = value
                                                                      .toString();
                                                                });
                                                              },
                                                              validator: (value) =>
                                                                  value == null
                                                                      ? 'Field required'
                                                                      : null,
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_drop_down,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary,
                                                              ),
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
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        if (form.currentState!
                                                            .validate()) {
                                                          if (name.text
                                                                  .isNotEmpty &&
                                                              parents_phone.text
                                                                  .isNotEmpty &&
                                                              _batch
                                                                  .isNotEmpty) {
                                                            updateStudentDetails(
                                                              index,
                                                              _filteredStudents[
                                                                      index]
                                                                  .studentid,
                                                              name.text
                                                                  .toString(),
                                                              phone.text
                                                                  .toString(),
                                                              email.text
                                                                  .toLowerCase()
                                                                  .toString(),
                                                              parents_phone.text
                                                                  .toString(),
                                                              _batch.toString(),
                                                            );
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Enter all the details");
                                                          }
                                                        }
                                                      },
                                                      child: Text('Update'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'edit'.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: const StadiumBorder(),
                                        ),
                                        onPressed: () {
                                          AwesomeDialog(
                                            context: context,
                                            dialogBackgroundColor:
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                            dialogType: DialogType.warning,
                                            animType: AnimType.bottomSlide,
                                            title: 'Student Delete',
                                            desc: 'Are you Sure ?',
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () {
                                              deleteStudent(
                                                  index,
                                                  _filteredStudents[index]
                                                      .studentid);
                                            },
                                          ).show();
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        label: Text(
                                          'Delete'.toUpperCase(),
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
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: AutoSizeText(
                      "Student Not Found",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
