import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuition_management/pages/dashboard.dart';
import 'package:tuition_management/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/theme/theme_controller.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  static const String KEYLOGIN = "login";

  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/playstore.png",
                    width: 300,
                    height: 300,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Developed By Snehasis Bhunia",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);

    ThemeController themeController = Get.put(ThemeController());

    String id = sharedPref.getString("id") ?? "";
    String name = sharedPref.getString("name") ?? "";
    String phone = sharedPref.getString("phone") ?? "";
    String email = sharedPref.getString("email") ?? "";
    String image = sharedPref.getString("image") ?? "";

    bool theme = sharedPref.getBool("theme") ?? false;
    themeController.changeTheme(theme);

    Timer(const Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if (isLoggedIn) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DashBoard(User(id, name, phone, email, image)),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
        }
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      }
    });
  }
}
