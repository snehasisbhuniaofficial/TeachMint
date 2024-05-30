import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/specificstudent.dart';

// ignore: must_be_immutable
class DuePayment extends StatefulWidget {
  User user;
  DuePayment(this.user, {super.key});

  @override
  State<DuePayment> createState() => _DuePaymentState(user);
}

class _DuePaymentState extends State<DuePayment> {
  User user;
  _DuePaymentState(this.user);
  final db = DatabaseHelper();

  List<Map<String, dynamic>> _duePayments = [];
  List<Map<String, dynamic>> filteredDues = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchTextChanged);
    _fetchDuePayments();
  }

  Future<void> _fetchDuePayments() async {
    final dues = await db.getAllStudentWithDues(int.parse(widget.user.id));
    setState(() {
      _duePayments = dues;
    });
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  List<Map<String, dynamic>> _applySearchFilter() {
    final query = searchController.text.toLowerCase();

    return _duePayments.where((due) {
      final studentName = due['studentname'].toLowerCase();
      final batchName = due['batchname'].toLowerCase();
      return studentName.contains(query) || batchName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Student Name or Batch',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Expanded(
            child: _applySearchFilter().isNotEmpty
                ? Scrollbar(
                    child: ListView.builder(
                      itemCount: _applySearchFilter().length,
                      itemBuilder: (context, index) {
                        filteredDues = _applySearchFilter();
                        final due = filteredDues[index];
                        final studentName = due['studentname'];
                        final batchName = due['batchname'];
                        final joiningDate = due["added_on"];
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
                            leading: CircleAvatar(
                              child: AutoSizeText(due['studentname'][0].toUpperCase()),
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        "${studentName}",
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
                                        "Batch: ",
                                        maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        "$batchName",
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
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        'Parents Phone: ',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        due['parents_phone'].toString(),
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
                                         maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        "Joining Date: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    Flexible(
                                      child: AutoSizeText(
                                        "$joiningDate",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SpecificStudent(
                                              due['studentid'],
                                              due['studentname'].toString(),
                                              due['studentphone'].toString(),
                                              due['studentemail'].toString(),
                                              due['parents_phone'].toString(),
                                              due['batchname'].toString(),
                                              due['added_on'].toString(),
                                              due['status'].toString(),
                                              user)));
                                },
                                child: const AutoSizeText(
                                   maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                  "Show Dues",
                                  style: TextStyle(color: Colors.red),
                                )),
                          ),
                        );
                      },
                    ),
                  )
                : const Center(child: AutoSizeText("Student Not Found")),
          ),
        ],
      ),
    );
  }
}
