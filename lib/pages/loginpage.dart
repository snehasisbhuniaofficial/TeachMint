import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuition_management/pages/dashboard.dart';
import 'package:tuition_management/pages/startpage.dart';
import 'package:tuition_management/pages/signuppage.dart';
import 'package:tuition_management/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/verificationpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formkey = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isVisible = true;

  final db = DatabaseHelper();

  login() async {
    var response = await db.login(email.text.toString().toLowerCase().trim(),
        password.text.toString().trim());
    if (response == true) {
      if (!mounted) return;
      var sharedPref = await SharedPreferences.getInstance();
      sharedPref.setBool(StartPageState.KEYLOGIN, true);
      String id = sharedPref.getString("id") ?? "";
      String name = sharedPref.getString("name") ?? "";
      String phone = sharedPref.getString("phone") ?? "";
      String email = sharedPref.getString("email") ?? "";
      String image = sharedPref.getString("image") ?? "";

      User user = User(
          id.trim(), name.trim(), phone.trim(), email.trim(), image.trim());
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashBoard(user)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: Text(
            "User's Login!",
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/login.png',
                    width: 300,
                    height: 300,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 25, left: 20, right: 20),
                    child: TextFormField(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email Id is required";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$')
                            .hasMatch(value)) {
                          return "Please enter valid email";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        prefixIcon: Icon(
                          Icons.email_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintText: "Enter your Email ID",
                        labelText: 'Email ID',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      controller: email,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 25, left: 20, right: 20),
                    child: TextFormField(
                      obscuringCharacter: '*',
                      controller: password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "password is required";
                        } else if (password.text.length <= 5) {
                          return 'Password must be atleast 6 Characters';
                        } else {
                          return null;
                        }
                      },
                      obscureText: isVisible,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      decoration: InputDecoration(
                        hintText: "Enter Your password",
                        labelText: "Password",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        suffixIcon: TextButton(
                          child: isVisible
                              ? Icon(
                                  Icons.visibility_off,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          onPressed: () {
                            setState(
                              () {
                                isVisible = !isVisible;
                              },
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VerificationPage()));
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: Colors.blue),
                    child: TextButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            if (email.text.isNotEmpty &&
                                password.text.isNotEmpty) {
                              login();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Enter all the details");
                            }
                          }
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpPage()));
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
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
