import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/models/fiche_accident.dart';
import 'package:brt_mobile/models/fiche_accident_vehicule.dart';
import 'package:brt_mobile/views/fiche/accident/details_fiche_accident.dart';
import 'package:brt_mobile/views/fiche/accident/fiche_accident_vehicule.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../sqflite/database_helper.dart';
import 'package:get/get.dart';

import '../../../models/responsable_saisi.dart';
import 'fiche_accident_degats_materiels.dart';
import 'fiche_accident_victime.dart';
import 'package:brt_mobile/views/home/home.dart';

class DetailsAccident extends StatefulWidget {
  final int alertId;
  final int initialTab;

  const DetailsAccident({super.key, required this.alertId, this.initialTab = 0});

  @override
  _DetailsAccidentState createState() => _DetailsAccidentState();
}

class _DetailsAccidentState extends State<DetailsAccident> {
  int _selectedIndex = 0;
  int currentStepAcc = 1;
  late int initialTabIndex; // Index de l'onglet initial

  Map<String, dynamic>? _alertDetails;
  Map<String, dynamic>? _ficheAccidentDetails;
  List<Map<String, dynamic>> _ficheVehiculeDetails=[];
  List<Map<String, dynamic>> _ficheVictimeDetails=[];
  List<Map<String, dynamic>> _ficheDegatsDetails=[];

  late Future<bool> _loadAllDataFuture;
  DatabaseHelper db = DatabaseHelper();
  bool _isDataLoaded = false;

  Future<bool> _loadAllData() async {
    try {
      // Charger les préférences utilisateur
      final prefs = await SharedPreferences.getInstance();
      currentStepAcc = prefs.getInt('currentStep${widget.alertId}') ?? 1;
      
      // Charger les détails de l'alerte
      final alert = await db.getAlertById(widget.alertId);
      _alertDetails = alert;
      
      if (alert != null) {
        // Charger les détails de la fiche d'accident
        final ficheAccident = await db.getFicheAccidentByIdAlert(widget.alertId);
        _ficheAccidentDetails = ficheAccident;
        
        if (ficheAccident != null) {
          // Charger les véhicules associés
          final ficheAccidentVehicule = await db.getFicheVehiculeByAccidentId(ficheAccident["idfiche_accident"]);
          _ficheVehiculeDetails = ficheAccidentVehicule;
          
          // Charger les victimes associées
          final victimesData = await db.getVictimesByAccidentId(ficheAccident['idfiche_accident']);
          _ficheVictimeDetails = victimesData;
          
          // Charger les dégâts associés
          final degatsData = await db.getAccidentDegatsMaterielsById(ficheAccident['idfiche_accident']);
          _ficheDegatsDetails = degatsData;
        }
      }
      
      // Charger d'autres informations si nécessaire
      final responsables = await DatabaseHelper().getResponsablesNonSync();
      print("NOMBRE : ${responsables.length} pour alert ${_alertDetails != null ? _alertDetails!['code_alert'] : 'null'}");
      
      return true;
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    initialTabIndex = widget.initialTab; // Utiliser l'onglet initial fourni
    _loadAllDataFuture = _loadAllData();
  }

  Future<String> getLibelleFromDb(String tableName, int id) async {
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
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

  String getAlertNiveauValueString(int value){
    switch (value){
      case 1:
        return "Situation d'urgence";
      case 2:
        return "Situation d'urgence pouvant evoluer en crise";
      case 3:
        return "Situation catastrophique";
      default:
        return "Non défini";
    }
  }

  String getConditionAtVal(int value){
    switch (value){
      case 1:
        return "Soleil";
      case 2:
        return "Pluie";
      case 3:
        return "Brouillard";
      default:
        return "Non défini";
    }
  }

  String getTypeJourVal(int value){
    switch (value){
      case 1:
        return "Jour";
      case 2:
        return "Nuit";
      default:
        return "Non défini";
    }
  }

  String getSectionVal(int value){
    switch (value){
      case 1:
        return "Section 1";
      case 2:
        return "Section 2";
      case 3:
        return "Section 3";
      case 4:
        return "Section 4";
      default:
        return "Non défini";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Détails de l'accident",
          ),
          backgroundColor: AppColors.appColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Rediriger vers home.dart en utilisant Get.offAll()
              Get.offAll(() => const HomeScreen());
            },
          ),
        ),
        body: FutureBuilder<bool>(
          future: _loadAllDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      "Chargement des données...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 20),
                    Text(
                      "Erreur lors du chargement des données",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadAllDataFuture = _loadAllData();
                        });
                      },
                      child: Text("Réessayer"),
                    ),
                  ],
                ),
              );
            }
            
            // Les données sont chargées, afficher l'interface
            return DefaultTabController(
              length: 4,
              initialIndex: initialTabIndex,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Accident",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _alertDetails != null &&
                                _alertDetails!['blesse_oui_non'] == 1
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _alertDetails != null && _alertDetails!["prenom_nom"] != null
                                ? 'Responsable: ${_alertDetails!["prenom_nom"]}'
                                : 'Non affecté',
                            style: TextStyle(
                              color: _alertDetails != null && _alertDetails!["prenom_nom"] != null
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: TabBar(
                      physics: const BouncingScrollPhysics(),
                      isScrollable: true,
                      unselectedLabelColor: AppColors.appColor,
                      labelColor: AppColors.white,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.appColor.withOpacity(0.8),
                      ),
                      tabs: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: const Tab(
                            icon: Icon(Icons.warning_amber),
                            text: "Accident",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: const Tab(
                            icon: Icon(Icons.directions_car),
                            text: "Véhicule",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: const Tab(
                            icon: Icon(Icons.people),
                            text: "Victime",
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: const Tab(
                            icon: Icon(Icons.dangerous),
                            text: "Dégats",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Divider(thickness: 1),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        (_alertDetails != null)
                            ? DetailsFicheAccident(
                          alertDetails: _alertDetails!,
                          ficheAccidentDetails: _ficheAccidentDetails,
                          haveDraft: currentStepAcc != 1,
                        )
                            : const Center(
                          child: Text("Données d'alerte non disponibles"),
                        ),
                        DetailsFicheVehicule(
                          vehiculeDetails: _ficheVehiculeDetails,
                          accidentID: _ficheAccidentDetails != null
                              ? _ficheAccidentDetails!["idfiche_accident"]
                              : -1, alertId: widget.alertId,
                        ),
                        DetailsFicheAccidentVictime(
                          victimeDetails: _ficheVictimeDetails,
                          alertId: widget.alertId,
                          accidentID: _ficheAccidentDetails != null
                              ? _ficheAccidentDetails!["idfiche_accident"]
                              : -1,
                        ),
                        DetailsFicheDegatsMateriels(
                          degatDetails: _ficheDegatsDetails,
                          alertId: widget.alertId,
                          accidentID: _ficheAccidentDetails != null
                              ? _ficheAccidentDetails!["idfiche_accident"]
                              : -1,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
