import 'package:brt_mobile/res/constant/app_assets.dart';
import 'package:brt_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:brt_mobile/views/home/home.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/google_fonts.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String phoneNumber;
  late String codeSMS;
  bool isValidNumber = false;

  int nbStep=1;

  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController nomController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.appColor,
        elevation: 0,
        leading: const BackButton(),
        title:  Text(
          "Connexion",
          style: safeGoogleFont(
            'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.appColor,
            fontSize: 25,
          ),
        ),
      ),
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
                  if(nbStep==1)...[
                    Text(
                      "Saisissez votre numéro de téléphone",
                      style: safeGoogleFont(
                        'Poppins',
                        fontWeight: FontWeight.w400,
                        color: AppColors.appColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    IntlPhoneField(
                      controller: phoneNumberController,
                      style: safeGoogleFont(
                        'Poppins',
                        color: AppColors.black,
                      ),
                      dropdownTextStyle: safeGoogleFont(
                        'Poppins',
                        color: AppColors.black,  // Change la couleur des textes des pays
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Téléphone',
                        prefixIcon: const Icon(Icons.phone_android, color: AppColors.appColor),
                        hintStyle: TextStyle(color: Colors.blue.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: AppColors.appColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: AppColors.appColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        ),
                      ),
                      initialCountryCode: 'SN',
                      keyboardType: TextInputType.phone,
                      onChanged: (phone) {
                        phoneNumber=phone.number;
                        isValidNumber = phone.isValidNumber();
                      },
                    ),
                    const SizedBox(height: 8,),
                    TextField(
                      controller: prenomController,
                      decoration: InputDecoration(
                        hintText: "Prénom...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13,),
                    TextField(
                      controller: nomController,
                      decoration: InputDecoration(
                        hintText: "Nom...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                  if(nbStep==2)...[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextField(
                        controller: loginController,
                        decoration: InputDecoration(
                          hintText: "Login...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Mot de passe...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),

                    ),
                    const SizedBox(height: 40.0),
                  ],
                  if(nbStep==3)...[
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Text(
                            "Saisissez ici le code reçu par SMS",
                            style: safeGoogleFont(
                              'Poppins',
                              fontWeight: FontWeight.w400,
                              color: AppColors.appColor,
                              fontSize: 16,
                            ),
                          ),
                          Center(
                            child: OTPTextField(
                              textFieldAlignment: MainAxisAlignment.spaceEvenly,
                              otpFieldStyle: OtpFieldStyle(
                                borderColor: AppColors.appColor,
                                enabledBorderColor: AppColors.buttonBg,
                                focusBorderColor: AppColors.textField,
                              ),
                              //controller: _passwordController,
                              length: 5,
                              isDense: true,
                              obscureText: false,
                              width: 320,
                              fieldWidth: 50,
                              fieldStyle: FieldStyle.underline,
                              style: safeGoogleFont(
                                'Poppins',
                                fontSize: 20,
                                color: AppColors.appColor,
                              ),
                              onChanged: (pin){
                                codeSMS = pin;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50.0),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        if(nbStep>1)...[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                nbStep--;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, color: Colors.white),
                                SizedBox(width: 5.0),
                                Text(
                                  'Prec',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async{
                              if(nbStep==1){
                                if(isValidNumber){
                                  phoneNumberController.text = phoneNumber;
                                  setState(() {
                                    nbStep++;
                                  });
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Numéro de téléphone invalide...')),
                                  );
                                }
                              }else if (nbStep==2){
                                if(loginController.text.isNotEmpty && passwordController.text.isNotEmpty){
                                  EasyLoading.instance.backgroundColor = Colors.black;
                                  EasyLoading.show(status: 'Requête en cours...');
                                  bool result = await AuthService.getFirstConnexion(numTel: phoneNumber, prenom: prenomController.text, nom: nomController.text, deviceInfo: global.phoneIdentifier);
                                  EasyLoading.dismiss();
                                  print(phoneNumber);
                                  if(result){
                                    setState(() {
                                      nbStep++;
                                    });
                                  }else{
                                    EasyLoading.instance.backgroundColor = Colors.red;
                                    EasyLoading.showError("Numéro de téléphone non reconnu !");
                                  }
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez renseigner le login et le mot de passe...')),
                                  );
                                }
                              }
                              else{
                                EasyLoading.instance.backgroundColor = Colors.black;
                                EasyLoading.show(status: 'Requête en cours...');
                                var result = await AuthService.getInfoUser(numTel: phoneNumber, login: loginController.text, mp: passwordController.text, code: codeSMS);
                                EasyLoading.dismiss();
                                print(result);
                                if(result!=null){
                                  Get.offAll(const HomeScreen(), transition: Transition.rightToLeft);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.appColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            child: Text(
                              nbStep<3 ? 'SUIVANT' : 'SE CONNECTER',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Register Screen
                      print('Navigate to Register Screen');
                    },
                    child: const Text(
                      "Je n'ai pas de compte? m'inscrire",
                      style: TextStyle(
                        color: AppColors.appColor,
                        fontSize: 16.0,
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
