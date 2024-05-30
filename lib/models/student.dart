class Students {
  int studentid;
  String studentname;
  String studentphone;
  String studentemail;
  String parents_phone;
  String batchname;
  String added_on;
  String status;

  Students(
      {required this.studentid,
      required this.studentname,
      required this.studentphone,
      required this.studentemail,
      required this.parents_phone,
      required this.batchname,
      required this.added_on,
      required this.status});

  factory Students.fromMap(Map<String, dynamic> map) {
    return Students(
      studentid: map['studentid'],
      studentname: map['studentname'],
      studentphone: map['studentphone'],
      studentemail: map['studentemail'],
      parents_phone: map['parents_phone'],
      batchname: map['batchname'],
      added_on: map['added_on'],
      status: map['status'],
    );
  }
}
