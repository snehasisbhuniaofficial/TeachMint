import 'dart:ui';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuition_management/pages/profilepage.dart';
import 'package:tuition_management/pages/billingspage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/managebatches.dart';
import 'package:tuition_management/pages/managestudents.dart';
import 'package:tuition_management/theme/theme_controller.dart';

// ignore: must_be_immutable
class DashBoard extends StatefulWidget {
  User user;
  DashBoard(this.user, {super.key});

  @override
  State<DashBoard> createState() => _DashBoardState(user);
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  User user;
  _DashBoardState(this.user);

  Widget imageShow(image) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            maxRadius: 150,
            foregroundImage: MemoryImage(base64Decode(image)),
          ),
        ),
      ),
    );
  }

  Widget fixedImage(image) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            maxRadius: 150,
            foregroundImage: AssetImage(image),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text('Hello, ${user.name}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary, fontSize: 20)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.to(() => ProfilePage(user), transition: Transition.downToUp);
          },
          icon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.background,
                child: user.image == "assets/images/default_image.jpg"
                    ? ClipOval(
                        child: Image.asset(
                        user.image,
                        fit: BoxFit.cover,
                      ))
                    : ClipOval(
                        child: Image.memory(
                          base64Decode(user.image),
                          height: 135,
                          width: 135,
                          fit: BoxFit.cover,
                        ),
                      )),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Obx(
              () => IconButton(
                onPressed: () async {
                  themeController.isDark.value = !themeController.isDark.value;
                  var sharedPref = await SharedPreferences.getInstance();
                  themeController.changeTheme(themeController.isDark.value);
                  sharedPref.setBool("theme", themeController.isDark.value);
                },
                icon: Icon(
                  themeController.isDark.value
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewBatches(user)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(0, 5),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.2),
                                spreadRadius: 2,
                                blurRadius: 5)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  "assets/images/batch.png",
                                  height: 50,
                                  width: 50,
                                )),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Manage Batches'.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageStudents(user)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(0, 5),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.2),
                                spreadRadius: 2,
                                blurRadius: 5)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "assets/images/student.png",
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Manage Students'.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BillingsPage(user)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(0, 5),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.2),
                                spreadRadius: 2,
                                blurRadius: 5)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.lime,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  "assets/images/money.png",
                                  height: 50,
                                  width: 50,
                                )),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Billings'.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
