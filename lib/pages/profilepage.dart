import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tuition_management/pages/dashboard.dart';
import 'package:tuition_management/pages/startpage.dart';
import 'package:tuition_management/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuition_management/models/userdetails.dart';
import 'package:tuition_management/pages/currentpassword.dart';
import 'package:tuition_management/theme/theme_controller.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage(this.user, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState(user);
}

class _ProfilePageState extends State<ProfilePage> {
  GlobalKey<FormState> fromkey = GlobalKey();
  bool edittype = false;
  User user;
  _ProfilePageState(this.user);

  TextEditingController _id = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _id.text = user.id.trim();
    _name.text = user.name.trim();
    _phone.text = user.phone.trim();
    _email.text = user.email.toLowerCase().trim();
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashBoard(user),
      ),
    );
    return false;
  }

  File? pickedImage;
  Future pickImage(ImageSource imageType) async {
    try {
      final photo =
          await ImagePicker().pickImage(source: imageType, imageQuality: 50);
      if (photo == null) return;
      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  final db = DatabaseHelper();

  update(int id, String name, String phone, String email) async {
    var response = await db.update(id, name.trim(), phone.trim(), email.trim());
    if (response == true) {
      if (!mounted) return;
      var sharedPref = await SharedPreferences.getInstance();
      setState(() {
        sharedPref.setString("name", name.trim());
        sharedPref.setString("phone", phone.toString().trim());
        sharedPref.setString("email", email.toString().trim());
        user.name = _name.text.trim();
        user.phone = _phone.text.trim();
        user.email = _email.text.toLowerCase().trim();
        user.id = _id.text.trim();
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfilePage(user)));
    }
  }

  updateImage(int id, File image) async {
    var response = await db.updateImage(id, image);
    if (response == true) {
      if (!mounted) return;
      var sharedPref = await SharedPreferences.getInstance();
      String image = sharedPref.getString("image") ?? "";
      setState(() {
        user.image = image;
      });
    }
  }

  Future<void> showImageOptions() async {
    return showModalBottomSheet<void>(
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.remove_red_eye_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Text(
                'View Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (context) {
                      return user.image == "assets/images/default_image.jpg"
                          ? fixedImage(user.image)
                          : imageShow(user.image);
                    });
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 25,
              ),
              title: Text(
                'Take a Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera).whenComplete(
                  () {
                    if (pickedImage != null) {
                      updateImage(int.parse(user.id), pickedImage!);
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Colors.blue,
                size: 25,
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery).whenComplete(
                  () {
                    if (pickedImage != null) {
                      updateImage(int.parse(user.id), pickedImage!);
                    }
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.close,
                color: Colors.red,
                size: 25,
              ),
              title: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeController = Get.put(ThemeController());
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        return _onWillPop();
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            title: Text(
              "Profile Page",
              style: TextStyle(
                  fontSize: 25, color: Theme.of(context).colorScheme.onPrimary),
            ),
            centerTitle: true,
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 190,
                    width: 190,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    child: FittedBox(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showImageOptions();
                            },
                            child: CircleAvatar(
                                radius: 70,
                                backgroundColor:
                                    Theme.of(context).colorScheme.background,
                                child: user.image ==
                                        "assets/images/default_image.jpg"
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
                          Positioned(
                            bottom: 3,
                            right: 10,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle),
                              child: InkWell(
                                onTap: () {
                                  showImageOptions();
                                },
                                child: const Icon(
                                  CupertinoIcons.camera_circle_fill,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Form(
                    key: fromkey,
                    child: Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 30),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: themeController.isDark.value
                            ? Theme.of(context).colorScheme.primaryContainer
                            : const Color.fromARGB(255, 233, 232, 232),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Text(
                                  "Personal Details :",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      edittype = !edittype;
                                    });
                                  },
                                  icon: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 15, left: 36, right: 36),
                            child: TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              controller: _id,
                              decoration: InputDecoration(
                                fillColor: themeController.isDark.value
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : const Color.fromARGB(255, 238, 236, 236),
                                filled: true,
                                labelText: "ID",
                                enabled: false,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                contentPadding: const EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                prefixIcon: Icon(
                                  Icons.app_registration_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 15, left: 36, right: 36),
                            child: TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Name is required";
                                } else {
                                  return null;
                                }
                              },
                              enabled: edittype,
                              controller: _name,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                fillColor: themeController.isDark.value
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : const Color.fromARGB(255, 238, 236, 236),
                                filled: true,
                                label: const Text(
                                  "Name",
                                ),
                                enabled: false,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                contentPadding: const EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 15, left: 36, right: 36),
                            child: TextFormField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Phone no Required";
                                } else if (value.length < 10) {
                                  return "Please enter valid phone";
                                } else {
                                  return null;
                                }
                              },
                              enabled: edittype,
                              controller: _phone,
                              decoration: InputDecoration(
                                fillColor: themeController.isDark.value
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : const Color.fromARGB(255, 238, 236, 236),
                                filled: true,
                                label: const Text(
                                  "Phone Number",
                                ),
                                enabled: false,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                contentPadding: const EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 15, left: 36, right: 36),
                            child: TextFormField(
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Email ID Required";
                                } else if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$')
                                    .hasMatch(value)) {
                                  return "Please enter valid email ID";
                                } else {
                                  return null;
                                }
                              },
                              controller: _email,
                              enabled: edittype,
                              decoration: InputDecoration(
                                fillColor: themeController.isDark.value
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : const Color.fromARGB(255, 238, 236, 236),
                                filled: true,
                                label: const Text(
                                  " Email Id ",
                                ),
                                enabled: false,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                contentPadding: const EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 40),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CurrentPassword(user)));
                          },
                          child: const Text(
                            'Change Password ?',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      child: Visibility(
                        visible: edittype,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (fromkey.currentState!.validate()) {
                              if (_id.text.isNotEmpty &&
                                  _name.text.isNotEmpty &&
                                  _phone.text.isNotEmpty &&
                                  _email.text.isNotEmpty) {
                                update(
                                    int.parse(_id.text),
                                    _name.text.toString().trim(),
                                    _phone.text.toString().trim(),
                                    _email.text.toString().toLowerCase().trim());
                                setState(() {
                                  edittype = !edittype;
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Enter all the details',
                                );
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.cyan),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.save_as_outlined,
                            color: Colors.white,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'UPDATE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AwesomeDialog(
                            dialogBackgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            context: context,
                            dialogType: DialogType.warning,
                            headerAnimationLoop: false,
                            animType: AnimType.bottomSlide,
                            title: 'Log Out',
                            titleTextStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            desc: 'Do You Want to Log Out from the App?',
                            descTextStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            btnCancelOnPress: () {},
                            onDismissCallback: (type) {
                              debugPrint('Dialog Dismiss from callback $type');
                            },
                            btnOkOnPress: () async {
                              var sharedPref =
                                  await SharedPreferences.getInstance();
                              sharedPref.clear();
                              Fluttertoast.showToast(msg: "Logout Successful");
                              // ignore: use_build_context_synchronously
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const StartPage()),
                                  (route) => false);
                            },
                          ).show();
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
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
}
