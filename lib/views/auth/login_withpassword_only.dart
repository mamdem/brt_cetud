import 'package:brt_mobile/res/constant/app_assets.dart';
import 'package:brt_mobile/services/auth_service.dart';
import 'package:brt_mobile/views/auth/pin_setup_page.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../core/utils/app_colors.dart';
import '../../core/utils/google_fonts.dart';
import '../../sqflite/database_helper.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

class LoginWithPasswordOnly extends StatefulWidget {
  @override
  _LoginWithPasswordOnlyState createState() => _LoginWithPasswordOnlyState();
}

class _LoginWithPasswordOnlyState extends State<LoginWithPasswordOnly> {
  String pin = '';
  String codeSMS = '';
  bool isVerifying = false;

  Future<void> _initialize() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    global.phoneIdentifier = androidInfo.id;

    bool? result = await global.isConnected();

    if (!(result != null && (result == true))) {
      Get.offAll(const StartupScreen());
    }
  }

  Future<void> sendSMSCode() async {
    EasyLoading.show(status: 'Envoi du code en cours...');
    try {
      // Récupérer les informations de l'utilisateur depuis la base de données SQLite
      final DatabaseHelper dbHelper = DatabaseHelper();
      final Map<String, dynamic>? user = await dbHelper.getUser();

      if (user == null) {
        EasyLoading.showError('Aucun utilisateur trouvé');
        return;
      }

      // Utiliser le service d'authentification pour envoyer le code
      bool success = await AuthService.getFirstConnexion(
        numTel: user['num_tel'] ?? '',
        prenom: user['prenom'] ?? '',
        nom: user['nom'] ?? '',
        deviceInfo: global.phoneIdentifier,
      );

      if (success) {
        //EasyLoading.showSuccess('Code envoyé avec succès');
        _showSMSVerificationDialog();
      } else {
        EasyLoading.showError('Échec de l\'envoi du code');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du code: $e');
      EasyLoading.showError('Erreur: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> verifySMSCode() async {
    if (codeSMS.length != 5) {
      EasyLoading.showInfo('Veuillez saisir le code à 5 chiffres');
      return;
    }

    setState(() {
      isVerifying = true;
    });

    EasyLoading.show(status: 'Vérification du code...');
    try {
      // Récupérer les informations de l'utilisateur depuis la base de données SQLite
      final DatabaseHelper dbHelper = DatabaseHelper();
      final Map<String, dynamic>? user = await dbHelper.getUser();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? serverPwd = await prefs.getString("serverPwd");

      if (user == null) {
        EasyLoading.showError('Aucun utilisateur trouvé');
        return;
      }

      final Uri url = Uri.parse(
          "${global.baseUrl}/getInfoUser?num_tel=${user['num_tel']}&login=${user['email']}&mp=${serverPwd}&code=$codeSMS");

      print(
          "${global.baseUrl}/getInfoUser?num_tel=${user['num_tel']}&login=${user['email']}&mp=${serverPwd}&code=$codeSMS");
      try {
        final response = await http.post(url);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          if (jsonData['succes'] == true) {
            EasyLoading.showSuccess('Code vérifié avec succès');
            Navigator.pop(context); // Fermer le popup
            Get.to(() => const PinSetupPage(),
                transition: Transition.rightToLeft);
          } else {
            EasyLoading.showError('Code incorrect');
          }
        } else {
          EasyLoading.showError('Erreur Serveur !!!!');
        }
      } catch (error) {
        print('Erreur lors de la vérification du code: $error');
        EasyLoading.showError('Erreur: $error');
      } finally {
        EasyLoading.dismiss();
        setState(() {
          isVerifying = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du code: $e');
      EasyLoading.showError('Erreur: $e');
    } finally {
      EasyLoading.dismiss();
      setState(() {
        isVerifying = false;
      });
    }
  }

  void _showSMSVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Vérification par SMS",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.appColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Un code a été envoyé au numéro de téléphone associé à votre compte",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Saisissez ici le code reçu par SMS",
                  style: safeGoogleFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    color: AppColors.appColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: OTPTextField(
                    textFieldAlignment: MainAxisAlignment.spaceEvenly,
                    otpFieldStyle: OtpFieldStyle(
                      borderColor: AppColors.appColor,
                      enabledBorderColor: AppColors.buttonBg,
                      focusBorderColor: AppColors.textField,
                    ),
                    length: 5,
                    isDense: true,
                    obscureText: false,
                    width: 250,
                    fieldWidth: 40,
                    fieldStyle: FieldStyle.underline,
                    style: safeGoogleFont(
                      'Poppins',
                      fontSize: 18,
                      color: AppColors.appColor,
                    ),
                    onChanged: (pin) {
                      setState(() {
                        codeSMS = pin;
                      });
                    },
                    onCompleted: (pin) {
                      codeSMS = pin;
                      verifySMSCode();
                    },
                  ),
                ),
                TextButton(
                  onPressed: sendSMSCode,
                  child: Text(
                    "Renvoyer le code",
                    style: GoogleFonts.poppins(
                      color: AppColors.appColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Annuler",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isVerifying ? null : verifySMSCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Vérifier",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage(AppAssets.brt_logo),
                    width: 150.0,
                    height: 150.0,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
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
                      onCompleted: (code) async {
                        EasyLoading.instance.backgroundColor = Colors.black;
                        EasyLoading.show(status: 'Connexion en cours...');
                        String? pwd = await global.getPassword();
                        print(pin);
                        if (!pin.isEmpty) {
                          if (pwd != null && (pwd == pin)) {
                            Get.offAll(const HomeScreen(),
                                transition: Transition.rightToLeft);
                          } else {
                            EasyLoading.instance.backgroundColor = Colors.red;
                            EasyLoading.showError("Mot de passe incorrect !");
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Veuillez renseigner le mot de passe...')),
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
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: sendSMSCode,
                    child: Text(
                      "Mot de passe oublié ?",
                      style: GoogleFonts.poppins(
                        color: AppColors.appColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
