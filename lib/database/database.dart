import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuition_management/models/batch.dart';
import 'package:tuition_management/models/payment.dart';
import 'package:tuition_management/models/student.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  final String databaseName = "database.db";
  final String registerTable =
      "CREATE TABLE register (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT UNIQUE, email TEXT UNIQUE, password TEXT,image TEXT DEFAULT 'assets/images/default_image.jpg')";
  final String batchTable =
      "CREATE TABLE batch (batchid INTEGER PRIMARY KEY AUTOINCREMENT, batchname TEXT, batchfees TEXT,userid INTEGER,FOREIGN KEY (userid) REFERENCES register(id))";
  final String studentTable =
      "CREATE TABLE student (studentid INTEGER PRIMARY KEY AUTOINCREMENT, studentname TEXT,studentphone TEXT, studentemail TEXT, parents_phone TEXT, batchname TEXT,added_on TEXT,status INTEGER DEFAULT 1,userid INTEGER,FOREIGN KEY (userid) REFERENCES register(id), FOREIGN KEY (batchname) REFERENCES batch(batchname))";
  final String paymentTable =
      "CREATE TABLE payment (paymentid INTEGER PRIMARY KEY AUTOINCREMENT, studentid INTEGER,batchname TEXT, paid_ammount TEXT, paymentdate TEXT, month TEXT, year TEXT, discount INTEGER DEFAULT 0,userid INTEGER,FOREIGN KEY (userid) REFERENCES register(id), FOREIGN KEY (studentid) REFERENCES student(studentid), FOREIGN KEY (batchname) REFERENCES batch(batchname))";

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(registerTable);
      await db.execute(batchTable);
      await db.execute(studentTable);
      await db.execute(paymentTable);
    });
  }

  Future<List<Map<String, dynamic>>> getAllStudentDetailsForMonth(
      int userid, int month, int year) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> students = await db.rawQuery('''
    SELECT batch.*, student.studentid, student.studentname, student.studentphone, student.studentemail, student.parents_phone, student.added_on, student.status
    FROM student
    INNER JOIN batch ON student.batchname = batch.batchname
    WHERE student.userid = ? AND student.status = ?
  ''', [userid, 1]);

    final List<Map<String, dynamic>> payments =
        await db.query('payment', where: 'userid = ?', whereArgs: [userid]);

    final List<Map<String, dynamic>> studentDetails = [];

    for (final student in students) {
      final int studentId = student['studentid'];

      List<String> parts = student['added_on'].toString().split('-');
      int addday = int.parse(parts[0]);
      int addmonth = int.parse(parts[1]);
      int addyear = int.parse(parts[2]);

      DateTime joiningDate = DateTime(addyear, addmonth, addday);

      if (year < joiningDate.year ||
          (year == joiningDate.year && month < joiningDate.month)) {
        continue;
      }

      final List<Map<String, dynamic>> studentPayments = payments
          .where((payment) =>
              payment['studentid'] == studentId &&
              int.parse(payment['month']) == month &&
              int.parse(payment['year']) == year)
          .toList();

      bool hasPaid = studentPayments.isNotEmpty;

      double totalPaidAmount = 0.0;
      double totaldiscount = 0.0;
      for (final payment in studentPayments) {
        double paidAmount = double.parse(payment['paid_ammount']);
        double discount = double.parse(payment['discount'].toString()) ?? 0.0;
        totalPaidAmount += paidAmount;
        totaldiscount += discount;
      }

      Map<String, dynamic> studentDetail = Map.from(student);
      studentDetail['paid'] = hasPaid;
      studentDetail['totalPaidAmount'] = totalPaidAmount;
      studentDetail['totaldiscount'] = totaldiscount;
      studentDetail['payments'] = studentPayments;

      if (!hasPaid) {
        List<Map<String, dynamic>> dues = [];

        final int studentJoiningMonth = joiningDate.month;
        final int studentJoiningYear = joiningDate.year;

        for (int yearIter = studentJoiningYear; yearIter <= year; yearIter++) {
          int startMonth =
              (yearIter == studentJoiningYear) ? studentJoiningMonth : 1;
          int endMonth = (yearIter == year) ? month : 12;

          for (int monthIter = startMonth; monthIter <= endMonth; monthIter++) {
            if (yearIter == year && monthIter > month) {
              break;
            }
            if (!payments.any((payment) =>
                payment['studentid'] == studentId &&
                int.parse(payment['month']) == monthIter &&
                int.parse(payment['year']) == yearIter)) {
              dues.add({'month': monthIter, 'year': yearIter});
            }
          }
        }

        studentDetail['dues'] = dues;
      }

      studentDetails.add(studentDetail);
    }

    return studentDetails;
  }

  Future<List<Map<String, dynamic>>> getStudentsWithDues(
      int studentid, int userid) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> students = await db.query('student',
        where: 'studentid = ? AND userid=?', whereArgs: [studentid, userid]);
    final List<Map<String, dynamic>> payments = await db.query('payment',
        where: 'studentid = ? AND userid=?', whereArgs: [studentid, userid]);

    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> duePayments = [];

    for (final student in students) {
      final int studentId = studentid;

      List<String> parts = student['added_on'].toString().split('-');
      int addday = int.parse(parts[0]);
      int addmonth = int.parse(parts[1]);
      int addyear = int.parse(parts[2]);

      DateTime date = DateTime(addyear, addmonth, addday);
      int extractedYear = date.year;

      final int studentJoiningMonth = date.month;
      final int studentJoiningYear = extractedYear;

      for (int year = studentJoiningYear; year <= currentYear; year++) {
        int startMonth = 1;
        if (year == studentJoiningYear) {
          startMonth = studentJoiningMonth;
        }

        int endMonth = 12;
        if (year == currentYear) {
          endMonth = currentMonth;
        }

        for (int month = startMonth; month <= endMonth; month++) {
          if (!payments.any((payment) =>
              payment['studentid'] == studentId &&
              int.parse(payment['month']) == month &&
              int.parse(payment['year']) == year)) {
            duePayments.add({'month': month, 'year': year});
          }
        }
      }
    }
    return duePayments;
  }

  Future<List<Map<String, dynamic>>> getAllStudentWithDues(int userid) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> students = await db.rawQuery('''
    SELECT batch.*, student.studentid, student.studentname, student.studentphone, student.studentemail, student.parents_phone, student.added_on, student.status
    FROM student
    INNER JOIN batch ON student.batchname = batch.batchname
    WHERE student.userid = ? AND student.status= ?
  ''', [userid, 1]);

    final List<Map<String, dynamic>> payments =
        await db.query('payment', where: 'userid=?', whereArgs: [userid]);

    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> studentsWithDues = [];

    for (final student in students) {
      final int studentId = student['studentid'];

      List<String> parts = student['added_on'].toString().split('-');
      int addday = int.parse(parts[0]);
      int addmonth = int.parse(parts[1]);
      int addyear = int.parse(parts[2]);

      DateTime date = DateTime(addyear, addmonth, addday);
      int extractedYear = date.year;

      final int studentJoiningMonth = date.month;
      final int studentJoiningYear = extractedYear;

      List<Map<String, dynamic>> dues = [];

      for (int year = studentJoiningYear; year <= currentYear; year++) {
        int startMonth = 1;
        if (year == studentJoiningYear) {
          startMonth = studentJoiningMonth;
        }

        int endMonth = 12;
        if (year == currentYear) {
          endMonth = currentMonth;
        }

        for (int month = startMonth; month <= endMonth; month++) {
          if (!payments.any((payment) =>
              payment['studentid'] == studentId &&
              int.parse(payment['month']) == month &&
              int.parse(payment['year']) == year)) {
            dues.add({'month': month, 'year': year});
          }
        }
      }

      if (dues.isNotEmpty) {
        Map<String, dynamic> studentWithDues = Map.from(student);
        studentWithDues['dues'] = dues;
        studentsWithDues.add(studentWithDues);
      }
    }

    return studentsWithDues;
  }

  Future<bool> login(String email, String password) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> existingEmail =
        await db.query('register', where: 'email = ?', whereArgs: [email]);

    if (existingEmail.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Account not found. Please create an account');
      return false;
    }

    if (existingEmail.isNotEmpty) {
      final String savedPassword = existingEmail.first['password'];
      if (password != savedPassword) {
        Fluttertoast.showToast(msg: 'Password is Incorrect');
        return false;
      }
    }
    try {
      final List<Map<String, dynamic>> res = await db.query('register',
          where: 'email = ? AND password = ?', whereArgs: [email, password]);

      if (res.isNotEmpty) {
        for (int i = 0; i < res.length; i++) {
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setString("id", res[i]["id"].toString());
          sharedPref.setString("name", res[i]["name"].toString());
          sharedPref.setString("phone", res[i]["phone"].toString());
          sharedPref.setString("email", res[i]["email"].toString());
          sharedPref.setString("image", res[i]["image"].toString());
        }
        Fluttertoast.showToast(msg: "Login Successful");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> emailVerification(String email) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> existingEmail =
        await db.query('register', where: 'email = ?', whereArgs: [email]);

    if (existingEmail.isNotEmpty) {
      return true;
    } else {
      Fluttertoast.showToast(
          msg: 'Account not found. Please Check Your Email ID');
      return false;
    }
  }

  Future<bool> signup(
      String name, String phone, String email, String password) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> existingEmail =
        await db.query('register', where: 'email = ?', whereArgs: [email]);

    final List<Map<String, dynamic>> existingPhone =
        await db.query('register', where: 'phone = ?', whereArgs: [phone]);

    if (existingEmail.isNotEmpty) {
      Fluttertoast.showToast(msg: 'Email already exists');
      return false;
    }

    if (existingPhone.isNotEmpty) {
      Fluttertoast.showToast(msg: "phone number already exists");
      return false;
    }

    try {
      if (existingEmail.isEmpty && existingPhone.isEmpty) {
        var createAccount = await db.insert('register', {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password
        });
        if (createAccount.toString().isNotEmpty) {
          final List<Map<String, dynamic>> res = await db
              .query('register', where: 'email = ?', whereArgs: [email]);
          for (int i = 0; i < res.length; i++) {
            var sharedPref = await SharedPreferences.getInstance();
            sharedPref.setString("id", res[i]["id"].toString());
            sharedPref.setString("name", res[i]["name"].toString());
            sharedPref.setString("phone", res[i]["phone"].toString());
            sharedPref.setString("email", res[i]["email"].toString());
            sharedPref.setString("image", res[i]["image"].toString());
          }
        }
        Fluttertoast.showToast(msg: "Registration Successful");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error signing up: $e');
      return false;
    }
  }

  Future<bool> updateImage(int id, File newImageFile) async {
    final Database db = await initDB();

    try {
      String imageBase64 = base64Encode(await newImageFile.readAsBytes());

      var imageUpdate = await db.update(
        'register',
        {'image': imageBase64},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (imageUpdate.toString().isNotEmpty) {
        final List<Map<String, dynamic>> res =
            await db.query('register', where: 'id = ?', whereArgs: [id]);
        for (int i = 0; i < res.length; i++) {
          var sharedPref = await SharedPreferences.getInstance();
          sharedPref.setString("id", res[i]["id"].toString());
          sharedPref.setString("name", res[i]["name"].toString());
          sharedPref.setString("phone", res[i]["phone"].toString());
          sharedPref.setString("email", res[i]["email"].toString());
          sharedPref.setString("image", res[i]["image"].toString());
        }
      }
      Fluttertoast.showToast(msg: "Image Updated");
      return true; // Update successful
    } catch (e) {
      print('Error updating image: $e');
      Fluttertoast.showToast(msg: "Image Update failed");
      return false; // Error during update
    }
  }

  Future<bool> update(int id, String name, String phone, String email) async {
    final Database db = await initDB();
    try {
      await db.update(
        'register',
        {
          'name': name,
          'phone': phone,
          'email': email,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      Fluttertoast.showToast(msg: "Update Successful");
      return true; // Update successful
    } catch (e) {
      print('Error updating user: $e');
      Fluttertoast.showToast(msg: "Update failed");
      return false; // Error during update
    }
  }

  Future<bool> updatePassword(String email, String password) async {
    final Database db = await initDB();
    try {
      await db.update(
        'register',
        {
          'password': password,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      Fluttertoast.showToast(msg: "Password Successfully Updated");
      return true; // Update successful
    } catch (e) {
      print('Error updating user: $e');
      Fluttertoast.showToast(msg: "Update failed");
      return false; // Error during update
    }
  }

  Future<bool> passwordVerification(String email, String password) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> existingEmail =
        await db.query('register', where: 'email = ?', whereArgs: [email]);

    if (existingEmail.isNotEmpty) {
      final String savedPassword = existingEmail.first['password'];
      if (password != savedPassword) {
        Fluttertoast.showToast(msg: 'Password is Incorrect');
        return false;
      }
    }
    try {
      final List<Map<String, dynamic>> res = await db.query('register',
          where: 'email = ? AND password = ?', whereArgs: [email, password]);

      if (res.isNotEmpty) {
        Fluttertoast.showToast(msg: "Successfully Verified");
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in Password Verification: $e');
      return false;
    }
  }

  Future<bool> classAdd(String batchname, String fees, int userid) async {
    final Database db = await initDB();

    final List<Map<String, dynamic>> existingBatch = await db.query('batch',
        where: 'batchname = ? AND userid = ?', whereArgs: [batchname, userid]);

    if (existingBatch.isNotEmpty) {
      Fluttertoast.showToast(msg: 'This Batch already exists');
      return false;
    }

    try {
      if (existingBatch.isEmpty) {
        await db.insert('batch',
            {'batchname': batchname, 'batchfees': fees, 'userid': userid});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error in Batch added: $e');
      return false;
    }
  }

  Future<bool> paymentDone(
      int studentid,
      String batchname,
      String paid_ammount,
      String paymentdate,
      String month,
      String year,
      int discount,
      int userid) async {
    final Database db = await initDB();
    try {
      await db.insert('payment', {
        'studentid': studentid,
        'batchname': batchname,
        'paid_ammount': paid_ammount,
        'paymentdate': paymentdate,
        'month': month,
        'year': year,
        'discount': discount,
        'userid': userid
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error in Payment Done: $e');
      return false;
    }
  }

  Future<List<Payment>> getPaymentDetails(int studentid, int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT batch.*, student.studentid, student.studentname, student.studentphone, student.studentemail, student.parents_phone, student.added_on, student.status, payment.paymentid, payment.paid_ammount, payment.paymentdate, payment.month, payment.year, payment.discount FROM payment INNER JOIN student ON payment.studentid = student.studentid INNER JOIN batch ON batch.batchname = payment.batchname WHERE payment.studentid = $studentid AND payment.userid = $userid");
    return List.generate(maps.length, (i) {
      return Payment(
        batchid: maps[i]['batchid'],
        batchname: maps[i]['batchname'].toString(),
        batchfees: maps[i]['batchfees'].toString(),
        studentid: maps[i]['studentid'],
        studentname: maps[i]['studentname'].toString(),
        studentphone: maps[i]['studentphone'].toString(),
        studentemail: maps[i]['studentemail'].toString(),
        parents_phone: maps[i]['parents_phone'].toString(),
        added_on: maps[i]['added_on'].toString(),
        status: maps[i]['status'],
        paymentid: maps[i]['paymentid'],
        paid_ammount: maps[i]['paid_ammount'].toString(),
        paymentdate: maps[i]['paymentdate'].toString(),
        month: maps[i]['month'].toString(),
        year: maps[i]['year'].toString(),
        discount: maps[i]['discount'],
      );
    });
  }

  Future<List<Payment>> getAllPaymentDetails(int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT batch.*, student.studentid, student.studentname, student.studentphone, student.studentemail, student.parents_phone, student.added_on, student.status, payment.paymentid, payment.paid_ammount, payment.paymentdate, payment.month, payment.year, payment.discount FROM payment INNER JOIN student ON payment.studentid = student.studentid INNER JOIN batch ON batch.batchname = payment.batchname WHERE payment.userid = $userid");
    return List.generate(maps.length, (i) {
      return Payment(
        batchid: maps[i]['batchid'],
        batchname: maps[i]['batchname'].toString(),
        batchfees: maps[i]['batchfees'].toString(),
        studentid: maps[i]['studentid'],
        studentname: maps[i]['studentname'].toString(),
        studentphone: maps[i]['studentphone'].toString(),
        studentemail: maps[i]['studentemail'].toString(),
        parents_phone: maps[i]['parents_phone'].toString(),
        added_on: maps[i]['added_on'].toString(),
        status: maps[i]['status'],
        paymentid: maps[i]['paymentid'],
        paid_ammount: maps[i]['paid_ammount'].toString(),
        paymentdate: maps[i]['paymentdate'].toString(),
        month: maps[i]['month'].toString(),
        year: maps[i]['year'].toString(),
        discount: maps[i]['discount'],
      );
    });
  }

  Future<List<Batches>> getAllBatches(int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps =
        await db.query('batch', where: 'userid = ?', whereArgs: [userid]);
    return List.generate(maps.length, (i) {
      return Batches(
        batchid: maps[i]['batchid'],
        batchname: maps[i]['batchname'].toString(),
        batchfees: maps[i]['batchfees'].toString(),
      );
    });
  }

  Future<List<Batches>> getBatchFee(String batchname, int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query('batch',
        where: 'batchname = ? AND userid=?', whereArgs: [batchname, userid]);
    return List.generate(maps.length, (i) {
      return Batches(
        batchid: maps[i]['batchid'],
        batchname: maps[i]['batchname'].toString(),
        batchfees: maps[i]['batchfees'].toString(),
      );
    });
  }

  Future<bool> updateBatch(
      int batchid, String batchname, String batchfees, int userid) async {
    final Database db = await initDB();
    try {
      await db.update(
        'batch',
        {'batchname': batchname, 'batchfees': batchfees},
        where: 'batchid = ? AND userid = ?',
        whereArgs: [batchid, userid],
      );
      Fluttertoast.showToast(msg: "Update Successful");
      return true; // Update successful
    } catch (e) {
      print('Error updating user: $e');
      Fluttertoast.showToast(msg: "Update failed");
      return false; // Error during update
    }
  }

  Future<bool> deleteBatch(int batchid, int userid) async {
    final Database db = await initDB();
    try {
      await db.delete(
        'batch',
        where: 'batchid = ? AND userid = ?',
        whereArgs: [batchid, userid],
      );
      Fluttertoast.showToast(msg: "Delete Successful");
      return true; // Update successful
    } catch (e) {
      print('Error updating user: $e');
      Fluttertoast.showToast(msg: "Deletion failed");
      return false; // Error during update
    }
  }

  Future<List<String>> getBatches(int userid) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> batches = await db.query(
      'batch',
      where: 'userid = ?',
      whereArgs: [userid],
    );
    final List<String> _batches = [];
    if (batches.isNotEmpty) {
      for (int i = 0; i < batches.length; i++) {
        _batches.add(batches[i]["batchname"].toString());
      }
      return _batches;
    } else {
      return _batches;
    }
  }

  Future<bool> addStudent(
      String studentname,
      String studentphone,
      String studentemail,
      String parents_phone,
      String batchname,
      String added_on,
      int userid) async {
    final Database db = await initDB();

    try {
      await db.insert('student', {
        'studentname': studentname,
        'studentphone': studentphone,
        'studentemail': studentemail,
        'parents_phone': parents_phone,
        'batchname': batchname,
        'added_on': added_on,
        'userid': userid,
      });
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error in Student added: $e');
      return false;
    }
  }

  Future<List<Students>> getStudents(int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query(
      'student',
      where: 'userid = ?',
      whereArgs: [userid],
    );
    return List.generate(maps.length, (i) {
      return Students(
        studentid: maps[i]['studentid'],
        studentname: maps[i]['studentname'].toString(),
        studentphone: maps[i]['studentphone'].toString(),
        studentemail: maps[i]['studentemail'].toString(),
        parents_phone: maps[i]['parents_phone'].toString(),
        batchname: maps[i]['batchname'].toString(),
        added_on: maps[i]['added_on'].toString(),
        status: maps[i]['status'].toString(),
      );
    });
  }

  Future<List<Students>> getBatchStudents(String batchname, int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query('student',
        where: 'batchname = ? AND userid=?', whereArgs: [batchname, userid]);
    return List.generate(maps.length, (i) {
      return Students(
        studentid: maps[i]['studentid'],
        studentname: maps[i]['studentname'].toString(),
        studentphone: maps[i]['studentphone'].toString(),
        studentemail: maps[i]['studentemail'].toString(),
        parents_phone: maps[i]['parents_phone'].toString(),
        batchname: maps[i]['batchname'].toString(),
        added_on: maps[i]['added_on'].toString(),
        status: maps[i]['status'].toString(),
      );
    });
  }

  Future<List<Students>> getActiveStudents(int userid) async {
    final Database db = await initDB();
    List<Map<String, dynamic>> maps = await db.query('student',
        where: 'status = ? AND userid=?', whereArgs: [1, userid]);
    return List.generate(maps.length, (i) {
      return Students(
        studentid: maps[i]['studentid'],
        studentname: maps[i]['studentname'].toString(),
        studentphone: maps[i]['studentphone'].toString(),
        studentemail: maps[i]['studentemail'].toString(),
        parents_phone: maps[i]['parents_phone'].toString(),
        batchname: maps[i]['batchname'].toString(),
        added_on: maps[i]['added_on'].toString(),
        status: maps[i]['status'].toString(),
      );
    });
  }

  Future<bool> updateStudentDetails(
      int studentid,
      String studentname,
      String studentphone,
      String studentemail,
      String parents_phone,
      String batchname,
      int userid) async {
    final Database db = await initDB();
    try {
      await db.update(
        'student',
        {
          'studentname': studentname,
          'studentphone': studentphone,
          'studentemail': studentemail,
          'parents_phone': parents_phone,
          'batchname': batchname
        },
        where: 'studentid = ? AND userid=?',
        whereArgs: [studentid, userid],
      );
      Fluttertoast.showToast(msg: "Update Successful");
      return true; // Update successful
    } catch (e) {
      print('Error updating student: $e');
      Fluttertoast.showToast(msg: "Update failed");
      return false; // Error during update
    }
  }

  Future<bool> updateStatus(int studentid, int status, int userid) async {
    final Database db = await initDB();
    try {
      await db.update(
        'student',
        {
          'status': status,
        },
        where: 'studentid = ? AND userid=?',
        whereArgs: [studentid, userid],
      );
      if (status == 1) {
        Fluttertoast.showToast(msg: "Active".toUpperCase());
      } else {
        Fluttertoast.showToast(msg: "Inactive".toUpperCase());
      }
      return true;
    } catch (e) {
      print('Error updating status: $e');
      Fluttertoast.showToast(msg: "Update failed");
      return false; // Error during update
    }
  }

  Future<bool> deleteStudent(int studentid, int userid) async {
    final Database db = await initDB();
    try {
      await db.delete(
        'student',
        where: 'studentid = ? AND userid=?',
        whereArgs: [studentid, userid],
      );
      Fluttertoast.showToast(msg: "Delete Successful");
      return true; // Update successful
    } catch (e) {
      print('Error updating user: $e');
      Fluttertoast.showToast(msg: "Deletion failed");
      return false; // Error during update
    }
  }
}
