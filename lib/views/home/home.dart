import 'dart:async';

import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/error/sync_log_page.dart';
import 'package:brt_mobile/services/accident_incident_service.dart';
import 'package:brt_mobile/services/auth_service.dart';
import 'package:brt_mobile/views/auth/login_screen.dart';
import 'package:brt_mobile/views/auth/startup_screen.dart';
import 'package:brt_mobile/views/fiche/all_incident.dart';
import 'package:brt_mobile/views/signalement/signalement_accident_screen.dart';
import 'package:brt_mobile/views/signalement/signalement_incident_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:jiffy/jiffy.dart';
import 'package:unique_identifier/unique_identifier.dart';
import '../../sqflite/database_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/incident_card.dart';
import '../../core/utils/google_fonts.dart';
import '../../models/setting_model.dart';
import '../../res/common/setting_common.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import '../../widgets/success_alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _firstIncidents = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late ConnectivityResult _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;

  bool _isLoading = true;

  String nomComplet = "loading...";
  String imagePath = "";

  int _totalAlerts = 0;

  Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    print("INFO APPP : ${androidInfo.model}");
    return androidInfo.model ?? "Nom d'appareil inconnu";
  }

  void openDialogSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Synchronisation effectuée !",
          onPressed: () {
            Get.back();
          },
          onClose: () {
            Get.back();
          },
        );
      },
    );
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier la connexion
      bool? result = await global.isConnected();
      if (!(result != null && (result == true))) {
        Get.offAll(const StartupScreen());
        return;
      }

      // Vérifier la connectivité avant de charger les données
      ConnectivityResult connectivityResult =
          await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        showInfo("Impossible de récupérer les données en mode hors ligne");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Chargement des données utilisateur
      await fetchUser();

      // Chargement des données du serveur
      await AuthService.fetchAndSaveData();

      // Chargement des incidents et alertes de la base de données locale
      await _fetchFirstIncidents();
      await _fetchTotalAlerts();
    } catch (e) {
      print("Erreur lors de l'initialisation: $e");
      // Afficher un message d'erreur à l'utilisateur si nécessaire
    } finally {
      // Toujours mettre à jour l'état, même en cas d'erreur
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _fetchStructureData() async {
    final db = DatabaseHelper();
    final result = await db.getUserStructure();
    if (result != null && result.isNotEmpty) {
      return result;
    } else {
      return {
        'nom_structure': 'Aucune structure',
        'logo': null,
      };
    }
  }

  Future<void> fetchUser() async {
    final db = DatabaseHelper();
    final user = await db.getUser();

    if (user != null) {
      setState(() {
        global.user = user;
        nomComplet = "${user['prenom_user']} ${user['nom_user']}";
        imagePath = user['photo'];
      });
    } else {
      print('Aucun utilisateur trouvé avec cet email.');
    }
  }

  @override
  void initState() {
    super.initState();

    // Configuration de la connectivité
    _connectionStatus = ConnectivityResult.none;
    _connectivityStream = _connectivity.onConnectivityChanged;
    _initConnectivity();

    // Un seul appel pour initialiser les données
    _initialize();
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print("Erreur lors de la vérification de la connectivité : $e");
      result = ConnectivityResult.none;
    }
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<void> _fetchTotalAlerts() async {
    final db = DatabaseHelper();
    final total = await db.getTotalAlertsCount();
    setState(() {
      _totalAlerts = total;
    });
  }

  Future<void> _fetchFirstIncidents() async {
    final db = DatabaseHelper();
    final incidents = await db.get2firstsFiches();
    setState(() {
      _firstIncidents = [];
      _firstIncidents = incidents;
    });
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Non défini';
    try {
      final dateTime = DateTime.parse(isoDate);
      return Jiffy(dateTime).format("dd MMM yyyy 'à' HH:mm");
    } catch (e) {
      return 'Non défini';
    }
  }

  void showReportTypeDialog() {
    Get.defaultDialog(
      title: "Signalement",
      titleStyle: safeGoogleFont(
        'Poppins',
        color: AppColors.red,
        fontWeight: FontWeight.w600,
        fontSize: 25,
        decoration: TextDecoration.underline,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            indent: 10,
            endIndent: 10,
            color: AppColors.divider,
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                Get.back();
                Get.to(const SignalementAccidentScreen(),
                    transition: Transition.rightToLeft);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: AppColors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Accident",
                    style: safeGoogleFont(
                      'Poppins',
                      color: AppColors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                Get.back();
                Get.to(const SignalementIncidentScreen(),
                    transition: Transition.rightToLeft);
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_rounded,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Incident",
                    style: safeGoogleFont(
                      'Poppins',
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_connectionStatus == ConnectivityResult.wifi ||
        _connectionStatus == ConnectivityResult.mobile) {
      try {
        await fetchUser();
        await AuthService.fetchAndSaveData().then((value) {
          _fetchFirstIncidents();
          _fetchTotalAlerts();
        });
      } catch (e) {}
    } else {
      showInfo("Impossible de rafraîchir en mode hors ligne");
    }
  }

  void showInfo(String message) {
    Get.snackbar(
      "Hors ligne",
      message,
      //backgroundColor: Colors.grey.shade100,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
    );
  }

  void showError(String message) {
    Get.snackbar(
      "Validation",
      message,
      //backgroundColor: Colors.grey.shade100,
      colorText: Colors.red,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(width: 1, color: AppColors.textField),
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nomComplet,
                            style: safeGoogleFont(
                              'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Police",
                            textAlign: TextAlign.center,
                            style: safeGoogleFont(
                              'Poppins',
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                              color: AppColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.emoji_emotions,
                      color: AppColors.black,
                      size: 30,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: settingList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        if (index == 0) {
                          Get.to(const AllIncident(),
                              transition: Transition.rightToLeft);
                        } else if (index == 1) {
                          Get.defaultDialog(
                            title: "Synchronisation",
                            titleStyle: safeGoogleFont(
                              'Poppins',
                              color: AppColors.appColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 25,
                              decoration: TextDecoration.underline,
                            ),
                            content: Column(
                              children: [
                                const Divider(
                                  indent: 10,
                                  endIndent: 10,
                                  color: AppColors.divider,
                                ),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Souhaiter vous vraiment synchroniser?",
                                  style: safeGoogleFont(
                                    'Poppins',
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      backgroundColor: AppColors.white,
                                      foregroundColor: AppColors.appColor,
                                      side: const BorderSide(
                                          color: AppColors.containerBgColor,
                                          width: 1.5),
                                      buttonText: "Non",
                                      fixedSize: const Size(100, 35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    AppButton(
                                      onPressed: () async {
                                        if (_connectionStatus ==
                                                ConnectivityResult.wifi ||
                                            _connectionStatus ==
                                                ConnectivityResult.mobile) {
                                          Navigator.pop(context);

                                          // Initialiser et afficher le loading
                                          EasyLoading.show(
                                            status:
                                                'Synchronisation en cours...',
                                            maskType: EasyLoadingMaskType.black,
                                            dismissOnTap: false,
                                          );

                                          try {
                                            await AccIncService.syncAll();

                                            // Afficher le dialogue de succès
                                            if (EasyLoading.isShow) {
                                              await EasyLoading.dismiss();
                                            }

                                            await Get.dialog(
                                              AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 20, 20, 10),
                                                title: const Column(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 70,
                                                    ),
                                                    SizedBox(height: 15),
                                                    Text(
                                                      'Succès',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content:
                                                    const SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Divider(height: 25),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 10,
                                                                horizontal: 5),
                                                        child: Text(
                                                          "Synchronisation effectuée avec succès.",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Container(
                                                    width: double.infinity,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: const Text(
                                                        'OK',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              barrierDismissible: false,
                                            );
                                          } catch (e) {
                                            // En cas d'erreur, fermer le loading
                                            if (EasyLoading.isShow) {
                                              await EasyLoading.dismiss();
                                            }
                                            showError(
                                                "Une erreur est survenue durant la synchronisation.");
                                          }
                                        } else {
                                          showError(
                                              "Impossible de synchroniser en mode hors ligne !");
                                        }
                                      },
                                      backgroundColor: AppColors.appColor,
                                      foregroundColor: AppColors.white,
                                      side: BorderSide.none,
                                      buttonText: "Oui",
                                      fixedSize: const Size(100, 35),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else if (index == 4) {
                          Get.to(SyncLogPage(),
                              transition: Transition.rightToLeft);
                          //Navigator.pop(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: SettingCommon(
                          border: Border.all(
                            width: 1,
                            color: AppColors.containerBgColor,
                          ),
                          isDisconnect: false,
                          icon: (settingList[index]["settingImage"]),
                          text: Text(
                            settingList[index]["settingTitle"],
                            style: safeGoogleFont(
                              'Poppins',
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          child: const Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton de déconnexion
              GestureDetector(
                onTap: () async {
                  Get.defaultDialog(
                    title: "Déconnexion",
                    titleStyle: safeGoogleFont(
                      'Poppins',
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      decoration: TextDecoration.underline,
                    ),
                    content: Column(
                      children: [
                        const Divider(
                          indent: 10,
                          endIndent: 10,
                          color: AppColors.divider,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "Souhaitez-vous vraiement vous déconnecter?",
                          style: safeGoogleFont(
                            'Poppins',
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              onPressed: () {
                                Get.back();
                              },
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.appColor,
                              side: const BorderSide(
                                  color: AppColors.containerBgColor,
                                  width: 1.5),
                              buttonText: "Annuler",
                              fixedSize: const Size(100, 35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            AppButton(
                              onPressed: () async {
                                Get.offAll(StartupScreen(),
                                    transition: Transition.circularReveal);
                                global.saveIsConnected(false);
                                DatabaseHelper.deleteLocalDatabase();
                              },
                              backgroundColor: AppColors.red,
                              foregroundColor: AppColors.white,
                              side: BorderSide.none,
                              buttonText: "Oui",
                              fixedSize: const Size(100, 35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: SettingCommon(
                    border: Border.all(
                      width: 1,
                      color: AppColors.containerBgColor,
                    ),
                    icon: Icons.logout,
                    isDisconnect: true,
                    text: Text(
                      "Déconnexion",
                      style: safeGoogleFont(
                        'Poppins',
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                    child: null,
                  ),
                ),
              ),

              // Ligne de séparation horizontale
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
              ),

              // Section copyright et numéro vert
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "© 2024 - Application de collecte\nd'accidents et d'incidents\n.Tous droits réservés.",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Version : V01.00.04",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: StreamBuilder<ConnectivityResult>(
          stream: _connectivityStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              _connectionStatus = snapshot.data!;
            }
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.appColor,
                          Color(0xFF6495ED),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Builder(
                          builder: (context) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.menu,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Scaffold.of(context).openDrawer();
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          "Système d'Alerte BRT",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.person_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                // Conteneur de signalement amélioré
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Icon(
                                          Icons.warning_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Système de Signalement',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Rapportez tout incident en un clic',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: (_connectionStatus ==
                                                      ConnectivityResult.wifi ||
                                                  _connectionStatus ==
                                                      ConnectivityResult.mobile)
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: (_connectionStatus ==
                                                    ConnectivityResult.wifi ||
                                                _connectionStatus ==
                                                    ConnectivityResult.mobile)
                                            ? const Icon(
                                                Icons.cloud_queue_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            : const Icon(
                                                Icons.cloud_off,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Contenu principal
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      children: [
                        // Bouton de signalement amélioré
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.25),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: showReportTypeDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.notifications_active,
                                    size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'FAIRE UN SIGNALEMENT',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statistiques et structure améliorées
                        SizedBox(
                          height: 130,
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.warning_amber,
                                            color: Colors.blue, size: 28),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Alertes Actives',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$_totalAlerts",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: FutureBuilder<Map<String, dynamic>>(
                                      future: _fetchStructureData(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ));
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                              child:
                                                  Text('Erreur de chargement'));
                                        } else if (!snapshot.hasData ||
                                            snapshot.data == null) {
                                          return const Center(
                                              child: Text(
                                                  'Aucune structure disponible'));
                                        }
                                        // Données récupérées
                                        final structureData = snapshot.data!;
                                        final String structureName =
                                            structureData['nom_structure'] ??
                                                'Nom inconnu';
                                        final String? logoPath =
                                            structureData['logo'];

                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (logoPath != null &&
                                                File(logoPath).existsSync())
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4),
                                                child: SizedBox(
                                                  width: 75,
                                                  height: 65,
                                                  child: Center(
                                                    child: Image.file(
                                                      File(logoPath),
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 4),
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                    size: 60),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              structureName,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Section incidents récents améliorée
                        if (_firstIncidents.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.appColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.appColor.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.history,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Incidents/Accidents Récents',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.to(const AllIncident(),
                                        transition: Transition.rightToLeft);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Voir',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                      ),
                                      Icon(Icons.arrow_forward,
                                          color: Colors.white, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        _isLoading
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 60),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.appColor),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "Chargement des données...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _firstIncidents.isEmpty
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.notifications_off,
                                          size: 50,
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          "Aucun signalement !",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Les incidents et accidents récents apparaîtront ici",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.grey.withOpacity(0.7)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ))
                                : Column(
                                    children: _firstIncidents.map((incident) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: FutureBuilder<String>(
                                          future: (incident['position_lat'] !=
                                                      null &&
                                                  incident['position_long'] !=
                                                      null)
                                              ? global.getAddressFromLatLong(
                                                  incident['position_lat'],
                                                  incident['position_long'],
                                                  2)
                                              : Future.value(
                                                  "Coordonnées indisponibles"),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return IncidentCard(
                                                idficheAlert:
                                                    incident['idfiche_alert'],
                                                title:
                                                    incident['type_alert'] == 41
                                                        ? 'Accident'
                                                        : 'Incident',
                                                location: incident['voie'] == 1
                                                    ? "Corridor: Chargement..."
                                                    : "Hors Corridor: Chargement...",
                                                time: formatDate(
                                                    incident['date_alert']),
                                                userAffected:
                                                    incident['prenom_nom'],
                                                isIncident:
                                                    !(incident['type_alert'] ==
                                                        41),
                                                isSynced:
                                                    incident['id_user'] != null,
                                              );
                                            } else if (snapshot.hasError) {
                                              return IncidentCard(
                                                idficheAlert:
                                                    incident['idfiche_alert'],
                                                title:
                                                    incident['type_alert'] == 41
                                                        ? 'Accident'
                                                        : 'Incident',
                                                location: incident['voie'] == 1
                                                    ? "Corridor: Adresse indisponible"
                                                    : "Hors Corridor: Adresse indisponible",
                                                time: formatDate(
                                                    incident['date_alert']),
                                                userAffected:
                                                    incident['prenom_nom'],
                                                isIncident:
                                                    !(incident['type_alert'] ==
                                                        41),
                                                isSynced:
                                                    incident['id_user'] != null,
                                              );
                                            } else {
                                              return IncidentCard(
                                                idficheAlert:
                                                    incident['idfiche_alert'],
                                                title:
                                                    incident['type_alert'] == 41
                                                        ? 'Accident'
                                                        : 'Incident',
                                                location: incident['voie'] == 1
                                                    ? "Corridor: ${snapshot.data!}"
                                                    : "Hors Corridor: ${snapshot.data!}",
                                                time: formatDate(
                                                    incident['date_alert']),
                                                userAffected:
                                                    incident['prenom_nom'],
                                                isIncident:
                                                    !(incident['type_alert'] ==
                                                        41),
                                                isSynced:
                                                    incident['id_server'] !=
                                                        null,
                                              );
                                            }
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
