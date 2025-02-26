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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late ConnectivityResult _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;

  bool _isLoading = true;

  String nomComplet="loading...";
  String imagePath="";

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

    bool? result = await global.isConnected();

    if(!(result!=null && (result==true))){
      Get.offAll(const StartupScreen());
    }

    Future.delayed(const Duration(seconds: 3), () async {
      if(_connectionStatus==ConnectivityResult.wifi || _connectionStatus==ConnectivityResult.mobile){
        await fetchUser();
        await AuthService.fetchAndSaveData().then((value){
          _fetchFirstIncidents();
          _fetchTotalAlerts();
        });
      }else{
        showInfo("Impossible de recupérer les données en mode hors ligne");
      }
      setState(() {
        _isLoading=false;
      });
    });

    Timer.periodic(const Duration(seconds: 20000), (timer) async {
      if(_connectionStatus==ConnectivityResult.wifi || _connectionStatus==ConnectivityResult.mobile){
        print("Recupération données...");
        //await fetchUser();
        await AuthService.fetchAndSaveData().then((value){
          _fetchFirstIncidents();
          _fetchTotalAlerts();
        });
      }
    });
  }

  Future<Map<String, dynamic>> _fetchStructureData() async {
    final db = DatabaseHelper();
    final result = await db.getUserStructure();
    if (result!=null && result.isNotEmpty) {
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
    _initialize();
    //DatabaseHelper().clearTables();
    _fetchFirstIncidents();
    _fetchTotalAlerts();

    _connectionStatus = ConnectivityResult.none;
    _connectivityStream = _connectivity.onConnectivityChanged;

    _initConnectivity();
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
      _firstIncidents=[];
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
                Get.to(const SignalementAccidentScreen(), transition: Transition.rightToLeft);
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
                Get.to(const SignalementIncidentScreen(), transition: Transition.rightToLeft);
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
    setState(() {
      _isLoading = true;
    });
    if(_connectionStatus==ConnectivityResult.wifi || _connectionStatus==ConnectivityResult.mobile){
      try {
        await fetchUser();
        await AuthService.fetchAndSaveData().then((value){
          _fetchFirstIncidents();
          _fetchTotalAlerts();
        });
      } catch (e) {
      }
    }else{
      showInfo("Impossible de rafraîchir en mode hors ligne");
    }
    setState(() {
      _isLoading = false;
    });
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
                        border: Border.all(width: 1, color: AppColors.textField),
                        image: DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                    },
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
                      if(index==0){
                        Get.to(const AllIncident(), transition: Transition.rightToLeft);
                      }
                      else if(index==1){
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
                                    buttonText: "Non",
                                    fixedSize: const Size(100, 35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  AppButton(
                                    onPressed: () async{
                                      Navigator.pop(context);
                                      EasyLoading.instance.backgroundColor = Colors.black;
                                      EasyLoading.show(status: 'Requête en cours...');
                                      await AccIncService.syncAllAlert();
                                      await AccIncService.syncAllFicheAccidents();
                                      EasyLoading.dismiss();
                                      Get.snackbar("Reussi", "Synchronisation effectuée  avec succés");
                                      Navigator.pop(context);
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
                      }
                      else if(index == 4){
                        Get.to(SyncLogPage(), transition: Transition.rightToLeft);
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
                            onPressed: () async{
                              Get.offAll(StartupScreen(), transition: Transition.circularReveal);
                              global.saveIsConnected(false);
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
                  Text(
                    'Numéro vert : 202 123',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body:StreamBuilder<ConnectivityResult>(
        stream: _connectivityStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
            _connectionStatus = snapshot.data!;
          }
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            child:  Column(
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
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(
                        builder: (context) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                  ),
                                  const Text(
                                    "Système d'Alerte BRT",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(50),
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
                              // Conteneur de signalement
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.warning_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    (_connectionStatus==ConnectivityResult.wifi || _connectionStatus==ConnectivityResult.mobile)?
                                    const Icon(
                                      Icons.cloud_queue_rounded,
                                      color: Colors.green,
                                      size: 24,
                                    ):const Icon(
                                      Icons.cloud_off,
                                      color: Colors.orange,
                                      size: 24,
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
                    padding: const EdgeInsets.all(16),
                    children: [
                      ElevatedButton(
                        onPressed: showReportTypeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_active),
                            SizedBox(width: 8),
                            Text(
                              'FAIRE UN SIGNALEMENT',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 130,
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.warning_amber, color: Colors.blue, size: 32),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Incidents Actifs',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: FutureBuilder<Map<String, dynamic>>(
                                    future: _fetchStructureData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(child: Text('Erreur de chargement'));
                                      } else if (!snapshot.hasData || snapshot.data == null) {
                                        return const Center(child: Text('Aucune structure disponible'));
                                      }
                                      // Données récupérées
                                      final structureData = snapshot.data!;
                                      final String structureName = structureData['nom_structure'] ?? 'Nom inconnu';
                                      final String? logoPath = structureData['logo'];

                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (logoPath != null && File(logoPath).existsSync())
                                            Image.file(
                                              File(logoPath),
                                              //width: 64,
                                              //height: 64,
                                              fit: BoxFit.cover,
                                            )
                                          else
                                            const Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
                                          const SizedBox(height: 8),
                                          Text(
                                            structureName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
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

                      // Affichage des deux premières alertes
                      _firstIncidents.isNotEmpty ?Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Incidents/Accidents Récents',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(const AllIncident(), transition: Transition.rightToLeft);
                            },
                            child: const Text(
                              'Voir Plus >',
                              style: TextStyle(color: AppColors.appColor),
                            ),
                          ),
                        ],
                      ):const Text(""),
                      _isLoading
                          ? const Padding(padding: EdgeInsets.symmetric(vertical: 50), child: Center(child: CircularProgressIndicator()),)
                          : _firstIncidents.isEmpty
                          ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              "Aucun signalement !",
                              style: TextStyle(fontSize: 20, color: Colors.grey),
                            ),
                          )
                      ) : Column(
                        children: _firstIncidents.map((incident) {
                          return FutureBuilder<String>(
                            future: (incident['position_lat'] != null && incident['position_long'] != null)
                                ? global.getAddressFromLatLong(incident['position_lat'], incident['position_long'], 2)
                                : Future.value("Coordonnées indisponibles"),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return IncidentCard(
                                  idficheAlert: incident['idfiche_alert'],
                                  title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                                  location: incident['voie'] == 1  ? "Corridor: Chargement..." : "Hors Corridor: Chargement...",
                                  time: formatDate(incident['date_alert']),
                                  userAffected: incident['prenom_nom'],
                                  isIncident: !(incident['type_alert'] == 41),
                                  isSynced: incident['id_user']!=null,
                                );
                              } else if (snapshot.hasError) {
                                return IncidentCard(
                                  idficheAlert: incident['idfiche_alert'],
                                  title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                                  location: incident['voie'] == 1 ? "Corridor: Adresse indisponible" : "Hors Corridor: Adresse indisponible",
                                  time: formatDate(incident['date_alert']),
                                  userAffected: incident['prenom_nom'],
                                  isIncident: !(incident['type_alert'] == 41),
                                  isSynced: incident['id_user']!=null,
                                );
                              } else {
                                return IncidentCard(
                                  idficheAlert: incident['idfiche_alert'],
                                  title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                                  location: incident['voie'] == 1
                                      ? "Corridor: : ${snapshot.data!}"
                                      : "Hors Corridor: ${snapshot.data!}",
                                  time: formatDate(incident['date_alert']),
                                  userAffected: incident['prenom_nom'],
                                  isIncident: !(incident['type_alert'] == 41),
                                  isSynced: incident['id_server']!=null,
                                );
                              }
                            },

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
      )
    );
  }
}
