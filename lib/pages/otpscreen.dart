import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:tuition_management/pages/setpassword.dart';
import 'package:tuition_management/models/store_email.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  Email email;
  OtpScreen(this.email, {super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState(email);
}

class _OtpScreenState extends State<OtpScreen> {
  Email email;
  _OtpScreenState(this.email);

  OtpTimerButtonController resendOTP = OtpTimerButtonController();
  TextEditingController o = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _requestOtp() async {
    resendOTP.loading();
    await sendOtp();
    Future.delayed(Duration(seconds: 2), () {
      resendOTP.startTimer();
    });
  }

  EmailOTP otp = EmailOTP();
  String verificationCode = '';
  Future sendOtp() async {
    otp.setConfig(
      appEmail: 'teachmint@gmail.com',
      userEmail: email.email,
      appName: 'Teach Mint',
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );

    if (await otp.sendOTP() == true) {
      // Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP has been sent"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Oops, OTP send failed"),
      ));
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    sendOtp().whenComplete(() => null);
  }

  void otpVerify(String x) async {
    try {
      if (await otp.verifyOTP(otp: x)) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SetPassword(email)));
      } else {
        Fluttertoast.showToast(msg: 'Invalid OTP');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 3, 203, 203)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Material(
      child: Material(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(30),
              alignment: Alignment.center,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/otp.png',
                      width: 250,
                      height: 250,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Text(
                      "OTP Verification",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.onPrimary,),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Check your registered Email Id to Enter OTP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      showCursor: true,
                      controller: o,
                      onChanged: (value) {
                        verificationCode = value;
                      },
                      onSubmitted: (v) {
                        verificationCode = v;
                        otpVerify(verificationCode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.red),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                          ),
                          onPressed: () {
                            otpVerify(verificationCode);
                          },
                          child: const Text(
                            "VERIFY",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 0),
                          ),
                          OtpTimerButton(
                            controller: resendOTP,
                            onPressed: () => _requestOtp(),
                            height: 60,
                            text: const Text(
                              'Resend OTP',
                            ),
                            duration: 30,
                            radius: 30,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            buttonType: ButtonType
                                .elevated_button,
                            loadingIndicator: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                            loadingIndicatorColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
