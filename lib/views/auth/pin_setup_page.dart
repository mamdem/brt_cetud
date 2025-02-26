import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:get/get.dart';
import '../../core/utils/google_fonts.dart';
import '../home/home.dart';

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String pin = '', confPin = '';
  bool _isButtonEnabled = false;

  OtpFieldController pinController = OtpFieldController();
  OtpFieldController confPinController = OtpFieldController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.appColor,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          "Code PIN",
          style: safeGoogleFont(
            'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.appColor,
            fontSize: 25,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: AppColors.appColor,
                ),
                const SizedBox(height: 40),
                Text(
                  "Créez votre code PIN",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Ce code vous permettra de sécuriser votre compte",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Saisissez le code PIN",
                  style: safeGoogleFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.appColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                OTPTextField(
                  controller: pinController,
                  textFieldAlignment: MainAxisAlignment.spaceEvenly,
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: AppColors.appColor,
                    enabledBorderColor: AppColors.appColor,
                    focusBorderColor: AppColors.appColor,
                  ),
                  length: 4,
                  obscureText: true,
                  isDense: true,
                  width: 320,
                  fieldWidth: 50,
                  fieldStyle: FieldStyle.box,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: AppColors.appColor,
                  ),
                  onCompleted: (code) {
                    setState(() {
                      pin = code;
                    });
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  "Confirmer le code PIN",
                  style: safeGoogleFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.appColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                OTPTextField(
                  controller: confPinController,
                  textFieldAlignment: MainAxisAlignment.spaceEvenly,
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: AppColors.appColor,
                    enabledBorderColor: AppColors.appColor,
                    focusBorderColor: AppColors.appColor,
                  ),
                  length: 4,
                  isDense: true,
                  width: 320,
                  obscureText: true,
                  fieldWidth: 50,
                  fieldStyle: FieldStyle.box,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: AppColors.appColor,
                  ),
                  onChanged: (code) {
                    setState(() {
                      confPin = code;
                      _isButtonEnabled = (confPin.length == 4);
                    });
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () async {
                    EasyLoading.instance.backgroundColor = Colors.black;
                    EasyLoading.show(status: 'Connexion en cours...');
                    if (pin == confPin) {
                      await global.savePassword(pin);
                      Get.offAll(const HomeScreen(), transition: Transition.rightToLeft);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Les PIN ne correspondent pas...')),
                      );
                    }
                    EasyLoading.dismiss();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Confirmer',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
