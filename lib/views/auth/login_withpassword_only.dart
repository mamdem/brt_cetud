import 'package:brt_mobile/res/constant/app_assets.dart';
import 'package:brt_mobile/services/auth_service.dart';
import 'package:brt_mobile/views/auth/startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/google_fonts.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

class LoginWithPasswordOnly extends StatefulWidget {
  @override
  _LoginWithPasswordOnlyState createState() => _LoginWithPasswordOnlyState();
}

class _LoginWithPasswordOnlyState extends State<LoginWithPasswordOnly> {

  String pin='';

  Future<void> _initialize() async {
    String?  identifier = await UniqueIdentifier.serial;
    global.phoneIdentifier = identifier??"";

    bool? result = await global.isConnected();

    if(!(result!=null && (result==true))){
      Get.offAll(const StartupScreen());
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage(AppAssets.brt_logo),
                    width: 150.0,
                    height: 150.0,
                  ),
                    const SizedBox(height: 30,),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: OTPTextField(
                        textFieldAlignment: MainAxisAlignment.spaceEvenly,
                        otpFieldStyle: OtpFieldStyle(
                          borderColor: AppColors.appColor,
                          enabledBorderColor: AppColors.appColor,
                          focusBorderColor: AppColors.appColor,
                        ),
                        length: 4,
                        isDense: true,
                        obscureText: true,
                        width: 320,
                        fieldWidth: 50,
                        fieldStyle: FieldStyle.box,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: AppColors.appColor,
                        ),
                        onCompleted: (code)async{
                          EasyLoading.instance.backgroundColor = Colors.black;
                          EasyLoading.show(status: 'Connexion en cours...');
                          String? pwd = await global.getPassword();
                          print(pin);
                          if(!pin.isEmpty){
                            if(pwd!=null && (pwd == pin)){
                              Get.offAll(const HomeScreen(), transition: Transition.rightToLeft);
                            }else{
                              EasyLoading.instance.backgroundColor = Colors.red;
                              EasyLoading.showError("Mot de passe incorrect !");
                            }
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez renseigner le mot de passe...')),
                            );
                          }
                          EasyLoading.dismiss();
                        },
                        onChanged: (code) {
                          setState(() {
                            pin = code;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
