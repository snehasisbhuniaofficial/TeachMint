import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tuition_management/models/student.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/specificstudent.dart';

// ignore: must_be_immutable
class AllStudent extends StatefulWidget {
  User user;
  AllStudent(this.user,{super.key});

  @override
  State<AllStudent> createState() => _AllStudentState(user);
}

class _AllStudentState extends State<AllStudent> {
  User user;
  _AllStudentState(this.user);

  List<Students> _students = [];
  List<Students> _filteredStudents = [];

  TextEditingController searchController = TextEditingController();
  final db = DatabaseHelper();

  Future<void> _fetchStudents() async {
    _students.clear();
    _students = await db.getActiveStudents(int.parse(user.id));
    setState(() {
      _filteredStudents = _students;
    });
  }

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = _students
          .where((data) =>
              data.studentname.toLowerCase().contains(query.toLowerCase()) ||
              data.batchname.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

   @override
  void initState() {
    _fetchStudents();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      controller: searchController,
                      onChanged: _filterStudents,
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
                      child: _filteredStudents.isNotEmpty
                          ? Scrollbar(
                              child: ListView.builder(
                                  itemCount: _filteredStudents.length,
                                  itemBuilder: (context, index) {
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
                                        leading: CircleAvatar(
                                          child: AutoSizeText(_filteredStudents[index]
                                              .studentname[0]
                                              .toUpperCase()),
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AutoSizeText(
                                                    _filteredStudents[index]
                                                        .studentname
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          children: [
                                             Row(
                                              children: [
                                                const Flexible(
                                                  child: AutoSizeText(
                                                    'Batch Name: ',
                                                     overflow:
                                                          TextOverflow.ellipsis,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Flexible(
                                                  child: AutoSizeText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    _filteredStudents[index]
                                                        .parents_phone
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                                                     overflow:
                                                          TextOverflow.ellipsis,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios_rounded),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SpecificStudent(
                                                          _filteredStudents[
                                                                  index]
                                                              .studentid,
                                                          _filteredStudents[
                                                                  index]
                                                              .studentname,
                                                          _filteredStudents[
                                                                  index]
                                                              .studentphone,
                                                          _filteredStudents[
                                                                  index]
                                                              .studentemail,
                                                          _filteredStudents[
                                                                  index]
                                                              .parents_phone,
                                                          _filteredStudents[
                                                                  index]
                                                              .batchname,
                                                          _filteredStudents[
                                                                  index]
                                                              .added_on,
                                                          _filteredStudents[
                                                                  index]
                                                              .status,
                                                          user)));
                                        },
                                      ),
                                    );
                                  }))
                          : const Center(child: AutoSizeText("Student Not Found"))),
                ],
              ),
            ),
    );
  }
}