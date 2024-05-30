import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tuition_management/models/batch.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/viewstudents.dart';

// ignore: must_be_immutable
class ViewBatches extends StatefulWidget {
  User user;
  ViewBatches(this.user, {Key? key}) : super(key: key);

  @override
  State<ViewBatches> createState() => _ViewBatchesState(user);
}

class _ViewBatchesState extends State<ViewBatches> {
  User user;
  _ViewBatchesState(this.user);

  final db = DatabaseHelper();
  List<Batches> _batches = [];
  List<Batches> _filteredBatches = [];
  TextEditingController searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  GlobalKey<FormState> batch = GlobalKey();
  TextEditingController batch_name = TextEditingController();
  TextEditingController fee = TextEditingController();

  GlobalKey<FormState> form = GlobalKey();
  TextEditingController batchname = TextEditingController();
  TextEditingController fees = TextEditingController();

  @override
  void initState() {
    _fetchBatches();
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

  Future<void> _fetchBatches() async {
    _batches.clear();
    _batches = await db.getAllBatches(int.parse(user.id));
    setState(() {
      _filteredBatches = _batches;
    });
  }

  void _filterBatches(String query) {
    setState(() {
      _filteredBatches = _batches
          .where((batch) =>
              batch.batchname.toLowerCase().contains(query.toLowerCase()) ||
              batch.batchfees.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  updateBatch(
      int index, int batchid, String batchname, String batchfees) async {
    var response = await db.updateBatch(
        batchid, batchname.trim(), batchfees.trim(), int.parse(user.id));
    if (response == true) {
      Navigator.pop(context);
      if (!mounted) return;
      setState(() {
        _filteredBatches[index].batchfees = batchfees.trim();
        _filteredBatches[index].batchname = batchname.trim();
      });
    }
  }

  deleteBatch(int index, int batchid) async {
    var response = await db.deleteBatch(batchid, int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      setState(() {
        _filteredBatches.removeAt(index);
      });
    }
  }

  classAdd(String batchname, String batchfees) async {
    var response = await db.classAdd(
        batchname.trim(), batchfees.trim(), int.parse(user.id));
    if (response == true) {
      if (!mounted) return;
      Navigator.pop(context);
      AwesomeDialog(
        dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        animType: AnimType.bottomSlide,
        dialogType: DialogType.success,
        title: 'Add Batch',
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        desc: 'Batch Successfully Added',
        descTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        btnOkOnPress: () {},
      ).show();
      _fetchBatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        centerTitle: true,
        title: Text(
          'Manage Batches',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary, fontSize: 20),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: FloatingActionButton.extended(
          label: const Text(
            'Add Batch',
          ),
          backgroundColor: Colors.green,
          onPressed: () {
            batch_name.text = '';
            fee.text = '';
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: Center(
                      child: Text(
                        'Add Batch',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    content: Form(
                      key: batch,
                      child: Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.school_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                  ),
                                  hintText: 'Enter Batch Name',
                                  hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                controller: batch_name,
                                validator: (value) {
                                  if (value == '') {
                                    return 'Batch Name Required';
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
                                    Icons.currency_rupee_rounded,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                  ),
                                  hintText: 'Enter Fees',
                                  hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                controller: fee,
                                validator: (value) {
                                  if (value == '') {
                                    return 'Fees Required';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          batch_name.text = '';
                          fee.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (batch.currentState!.validate()) {
                            if (batch_name.text.isNotEmpty &&
                                fee.text.isNotEmpty) {
                              classAdd(
                                batch_name.text.toUpperCase().toString(),
                                fee.text.toString(),
                              );
                              batch_name.text = '';
                              fee.text = '';
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Enter all the details");
                            }
                          }
                        },
                        child: Text(
                          'Add',
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
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
              onChanged: _filterBatches,
              decoration: InputDecoration(
                labelText: 'Search Batch',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredBatches.isNotEmpty
                ? Scrollbar(
                    child: ListView.builder(
                      itemCount: _filteredBatches.length,
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
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: AutoSizeText(
                                        'Batch Name:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: 20,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        ' ${_filteredBatches[index].batchname}'
                                            .toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: AutoSizeText(
                                        'Batch Fees:  ₹',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        ' ${_filteredBatches[index].batchfees}'
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                          color: Colors.green,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: const StadiumBorder(),
                                    ),
                                    onPressed: () {
                                      fees.text = _filteredBatches[index]
                                          .batchfees
                                          .toString();
                                      batchname.text = _filteredBatches[index]
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
                                              backgroundColor: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              title: Center(
                                                child: Text(
                                                  'Update Batch',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ),
                                              content: Form(
                                                key: form,
                                                child: Container(
                                                  color: Colors.transparent,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: SingleChildScrollView(
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
                                                            prefixIcon: Icon(
                                                              Icons
                                                                  .school_outlined,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 3)),
                                                            hintText:
                                                                'Enter Batch Name',
                                                            hintStyle:
                                                                TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                          ),
                                                          controller: batchname,
                                                          validator: (value) {
                                                            if (value == '') {
                                                              return 'Batch Name Required';
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
                                                            prefixIcon: Icon(
                                                              Icons
                                                                  .currency_rupee_rounded,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 3)),
                                                            hintText:
                                                                'Enter Fees',
                                                            hintStyle:
                                                                TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                          ),
                                                          controller: fees,
                                                          validator: (value) {
                                                            if (value == '') {
                                                              return 'Fees Required';
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
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
                                                  },
                                                  child: Text(
                                                    'Cancel',
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (form.currentState!
                                                        .validate()) {
                                                      if (batchname.text
                                                              .isNotEmpty &&
                                                          fees.text
                                                              .isNotEmpty) {
                                                        updateBatch(
                                                            index,
                                                            _filteredBatches[
                                                                    index]
                                                                .batchid,
                                                            batchname.text
                                                                .toUpperCase()
                                                                .toString(),
                                                            fees.text
                                                                .toString());
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Enter all the details");
                                                      }
                                                    }
                                                  },
                                                  child: AutoSizeText(
                                                    'Update',
                                                  ),
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
                                    label: AutoSizeText(
                                      'edit'.toUpperCase(),
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
                                      // ignore: avoid_single_cascade_in_expression_statements
                                      AwesomeDialog(
                                        context: context,
                                        dialogBackgroundColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        dialogType: DialogType.warning,
                                        animType: AnimType.bottomSlide,
                                        title: 'Batch Delete',
                                        desc: 'Are you Sure ?',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {
                                          deleteBatch(index,
                                              _filteredBatches[index].batchid);
                                        },
                                      )..show();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    label: AutoSizeText(
                                      'Delete'.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewStudents(
                                          _filteredBatches[index]
                                              .batchname
                                              .toString(),
                                          user)));
                            },
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: AutoSizeText(
                      "Batch Not Found",
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
