import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuition_management/theme/theme.dart';
import 'package:tuition_management/pages/startpage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String connectionStatus = 'Unknown';

  
  late StreamSubscription<ConnectivityResult> subscription;

  startMonitoringConnectivity() async {
    bool connection = await InternetConnectionChecker().hasConnection;
    if (connection == false) {
      connectionStatus = 'No Internet Connection';
      Fluttertoast.showToast(msg: connectionStatus);
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.none) {
          connectionStatus = 'No Internet Connection';
          Fluttertoast.showToast(msg: connectionStatus);
        } else if (result == ConnectivityResult.wifi) {
          connectionStatus = 'Connected to Wi-Fi';
          Fluttertoast.showToast(msg: connectionStatus);
        } else if (result == ConnectivityResult.mobile) {
          connectionStatus = 'Connected to Mobile Data';
          Fluttertoast.showToast(msg: connectionStatus);
        }
      });
    });
    return connectionStatus;
  }

  @override
  void initState() {
    setState(() {
      startMonitoringConnectivity();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Teach Mint',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const StartPage(),
    );
  }
}