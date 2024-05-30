import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuition_management/pages/otpscreen.dart';
import 'package:tuition_management/database/database.dart';
import 'package:tuition_management/pages/newpassword.dart';
import 'package:tuition_management/models/store_email.dart';
import 'package:tuition_management/models/userdetails.dart';

// ignore: must_be_immutable
class CurrentPassword extends StatefulWidget {
  User user;
  CurrentPassword(this.user, {super.key});

  @override
  State<CurrentPassword> createState() => _CurrentPasswordState(user);
}

class _CurrentPasswordState extends State<CurrentPassword> {
  User user;
  _CurrentPasswordState(this.user);

  GlobalKey<FormState> formkey = GlobalKey();
  TextEditingController t1 = TextEditingController();
  bool isVisible = true;

  final db = DatabaseHelper();

  currentPassword(String email, String password) async {
    var response = await db.passwordVerification(
        email.toString().trim(), password.toString().trim());
    if (response == true) {
      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NewPassword(user)));
      t1.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pass.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Enter Your Current Password",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: 80,
                    child: TextFormField(
                      obscureText: isVisible,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      controller: t1,
                      keyboardType: TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          labelText: "Enter Your Current Password",
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28)),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "password is required";
                        } else if (t1.text.length <= 5) {
                          return 'Password must be atleast 6 Characters';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Email email = Email(user.email);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OtpScreen(email)));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState!.validate()) {
                          if (t1.text.isNotEmpty) {
                            currentPassword(
                                user.email.toString(), t1.text.toString());
                          } else {
                            Fluttertoast.showToast(
                                msg: "Enter all the details");
                          }
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.red),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Verify'.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
