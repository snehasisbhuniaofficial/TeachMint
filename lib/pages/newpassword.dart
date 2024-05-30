import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/pages/profilepage.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class NewPassword extends StatefulWidget {
  User user;
  NewPassword(this.user, {super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState(user);
}

class _NewPasswordState extends State<NewPassword> {
  User user;
  _NewPasswordState(this.user);
  bool type = true;
  bool type1 = true;

  TextEditingController t1 = TextEditingController();
  TextEditingController t2 = TextEditingController();
  TextEditingController t3 = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey();

  final db = DatabaseHelper();

  updatePassword(String email, String password) async {
    var response = await db.updatePassword(
        email.toString().trim(), password.toString().trim());
    if (response == true) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfilePage(user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            color: Colors.transparent,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.info_circle,
                                      color: Colors.blue,
                                      size: 60,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Set Password',
                                      // ignore: deprecated_member_use
                                      textScaleFactor: 2,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Enter a new password \nto reset your old password',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Form(
                                      key: formkey,
                                      child: Flexible(
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: TextFormField(
                                                controller: t2,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "New Password Required";
                                                  } else if (t2.text.length <=
                                                      5) {
                                                    return 'Password must be atleast 6 digit';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: type,
                                                decoration: InputDecoration(
                                                  labelText: 'New Password',
                                                  hintText: 'New Password',
                                                  labelStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                  prefixIconColor: Colors.cyan,
                                                  prefixIcon: const Icon(
                                                      CupertinoIcons.lock),
                                                  suffixIcon: TextButton(
                                                    child: type
                                                        ? Icon(
                                                            Icons
                                                                .visibility_off,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                          )
                                                        : Icon(
                                                            Icons.visibility,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary,
                                                          ),
                                                    onPressed: () {
                                                      setState(() {
                                                        type = !type;
                                                      });
                                                    },
                                                  ),
                                                  fillColor: Colors.grey[150],
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 0, left: 10),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 25),
                                              child: TextFormField(
                                                controller: t3,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return "Please re enter your Password";
                                                  } else if (t2.text !=
                                                      t3.text) {
                                                    return "Password Do not match";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                keyboardType: TextInputType
                                                    .visiblePassword,
                                                obscureText: type1,
                                                decoration: InputDecoration(
                                                  labelText: 'Confirm Password',
                                                  hintText: 'Confirm Password',
                                                  labelStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary),
                                                  prefixIconColor: Colors.cyan,
                                                  prefixIcon: const Icon(
                                                      CupertinoIcons.lock),
                                                  suffixIcon: TextButton(
                                                    child: type1
                                                        ? Icon(
                                                            Icons
                                                                .visibility_off,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary)
                                                        : Icon(Icons.visibility,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onPrimary),
                                                    onPressed: () {
                                                      setState(() {
                                                        type1 = !type1;
                                                      });
                                                    },
                                                  ),
                                                  fillColor: Colors.grey[150],
                                                  filled: true,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 10,
                                                          bottom: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 30, bottom: 10),
                                              width: 200,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (formkey.currentState!
                                                      .validate()) {
                                                    if (t2.text.isNotEmpty &&
                                                        t3.text.isNotEmpty) {
                                                      updatePassword(
                                                          user.email.toString(),
                                                          t2.text.toString());
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Enter all the details");
                                                    }
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (states) => Colors.blue,
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20),
                                                  child: Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
