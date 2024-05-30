class Payment {
  int batchid;
  String batchname;
  String batchfees;
  int studentid;
  String studentname;
  String studentphone;
  String studentemail;
  String parents_phone;
  String added_on;
  int status;
  int paymentid;
  String paid_ammount;
  String paymentdate;
  String month;
  String year;
  int discount;
  Payment(
      {required this.batchid,
      required this.batchname,
      required this.batchfees,
      required this.studentid,
      required this.studentname,
      required this.studentphone,
      required this.studentemail,
      required this.parents_phone,
      required this.added_on,
      required this.status,
      required this.paymentid,
      required this.paid_ammount,
      required this.paymentdate,
      required this.month,
      required this.year,
      required this.discount});

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      batchid: map['batchid'],
      batchname: map['batchname'],
      batchfees: map['batchfees'],
      studentid: map['studentid'],
      studentname: map['studentname'],
      studentphone: map['studentphone'],
      studentemail: map['studentemail'],
      parents_phone: map['parents_phone'],
      added_on: map['added_on'],
      status: map['status'],
      paymentid: map['paymentid'],
      paid_ammount: map['paid_ammount'],
      paymentdate: map['paymentdate'],
      month: map['month'],
      year: map['year'],
      discount: map['discount'],
    );
  }
}
