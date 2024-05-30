import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:tuition_management/pages/dashboard.dart';
import 'package:tuition_management/pages/loginpage.dart';
import 'package:tuition_management/pages/startpage.dart';
import 'package:tuition_management/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_management/models/userdetails.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  GlobalKey<FormState> formkey = GlobalKey();

  bool isVisible = true;
  bool isvisible = true;

  final db = DatabaseHelper();
  signup() async {
    var response = await db.signup(
        name.text.toString().trim(),
        phone.text.toString().trim(),
        email.text.toString().toLowerCase().trim(),
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
          title: AutoSizeText(
            "Signup Here!",
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
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 160, 151, 148),
                      radius: 80,
                      child: Image(
                        image: AssetImage(
                          'assets/images/login.png',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: name,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name is required";
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintText: "Enter your Full Name",
                        labelText: 'Name',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Phone no Required";
                        } else if (value.length < 10) {
                          return "Please enter valid phone";
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintText: "Enter your Phone Number",
                        labelText: 'Phone',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: email,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email ID Required";
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$')
                            .hasMatch(value)) {
                          return "Please enter valid email ID";
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintText: "Enter your Email ID",
                        labelText: 'Email',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: TextFormField(
                      obscuringCharacter: '*',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password Required";
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
                        labelText: "Create Password",
                        hintText: "Create a strong password",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
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
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: TextFormField(
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      obscuringCharacter: '*',
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      controller: confirmPassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please re enter your Password";
                        } else if (password.text != confirmPassword.text) {
                          return "Password Do not match";
                        } else {
                          return null;
                        }
                      },
                      obscureText: isvisible,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        hintText: "Confirm Your password",
                        suffixIcon: TextButton(
                          child: isvisible
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
                                isvisible = !isvisible;
                              },
                            );
                          },
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Container(
                      height: 55,
                      width: MediaQuery.of(context).size.width * .9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: Colors.blue),
                      child: TextButton(
                          onPressed: () {
                            if (formkey.currentState!.validate()) {
                              if (name.text.isNotEmpty &&
                                  phone.text.isNotEmpty &&
                                  email.text.isNotEmpty &&
                                  password.text.isNotEmpty &&
                                  confirmPassword.text.isNotEmpty) {
                                signup();
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Enter all the details");
                              }
                            }
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
