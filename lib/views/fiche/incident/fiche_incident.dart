import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/models/fiche_accident.dart';
import 'package:brt_mobile/models/fiche_accident_vehicule.dart';
import 'package:brt_mobile/views/fiche/accident/details_fiche_accident.dart';
import 'package:brt_mobile/views/fiche/accident/fiche_accident_vehicule.dart';
import 'package:brt_mobile/views/fiche/incident/fiche_incident_degats_materiels.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../sqflite/database_helper.dart';
import 'package:get/get.dart';

import '../../../models/fiche_incident.dart';
import '../../home/home.dart';
import 'details_fiche_incident.dart';
import 'fiche_incident_victime.dart';

class DetailsIncident extends StatefulWidget {
  final int alertId;
  final int initialTab;

  const DetailsIncident(
      {super.key, required this.alertId, this.initialTab = 0});

  @override
  _DetailsIncidentState createState() => _DetailsIncidentState();
}

class _DetailsIncidentState extends State<DetailsIncident> {
  int _selectedIndex = 0;
  int currentStepAcc = 1;
  late int initialTabIndex; // Index de l'onglet initial

  Map<String, dynamic>? _alertDetails;
  Map<String, dynamic>? _ficheIncidentDetails;
  List<Map<String, dynamic>> _ficheVictimeDetails = [];
  List<Map<String, dynamic>> _ficheDegatsDetails = [];

  late Future<void> _fetchFuture;

  DatabaseHelper db = DatabaseHelper();
  bool _isLoading1 = true;
  bool _isLoading2 = true;
  bool _isLoading3 = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStepAcc = prefs.getInt('currentStep${widget.alertId}') ?? 1;
    });
    //await _fetchAllRespSaisiDetails();
    try {
      await _fetchAlertDetails();
    } catch (e) {}
    try {
      await fetchVictimes();
    } catch (e) {}
    try {
      await fetchDegatDetails();
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    initialTabIndex = widget.initialTab; // Utiliser l'onglet initial fourni
    try {
      _fetchFuture = _fetchFicheIncidentDetails();
    } catch (e) {}
    initialize();
  }

  Future<void> _fetchAlertDetails() async {
    final db = DatabaseHelper();
    final alert = await db.getAlertById(widget.alertId);
    setState(() {
      _alertDetails = alert;
      _isLoading1 = false;
    });
  }

  Future<String> getLibelleFromDb(String tableName, int id) async {
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
  }

  Future<void> fetchVictimes() async {
    final db = await DatabaseHelper();
    final victimesData = await db
        .getVictimesByIncidentId(_ficheIncidentDetails!['idfiche_incident']);
    setState(() {
      _ficheVictimeDetails = victimesData;
    });
  }

  Future<void> fetchDegatDetails() async {
    final db = await DatabaseHelper();
    final degatsData = await db.getIncidentDegatsMaterielsById(
        _ficheIncidentDetails!['idfiche_incident']);
    setState(() {
      _ficheDegatsDetails = degatsData;
    });
  }

  Future<void> _fetchFicheIncidentDetails() async {
    final db = DatabaseHelper();
    final ficheIncident = await db.getFicheIncidentByIdAlert(widget.alertId);

    setState(() {
      _ficheIncidentDetails = ficheIncident;
      _isLoading2 = false;
    });

    print(ficheIncident);
  }

  Future<void> _fetch() async {
    final db = DatabaseHelper();
    final ficheIncident = await db.getAllFicheIncidents();
    setState(() {
      _isLoading2 = false;
    });
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Non défini';
    try {
      final dateTime = DateTime.parse(isoDate);
      return Jiffy.parseFromDateTime(dateTime)
          .format(pattern: "dd MMM yyyy 'à' HH:mm");
    } catch (e) {
      return 'Non défini';
    }
  }

  String getAlertNiveauValueString(int value) {
    switch (value) {
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

  String getConditionAtVal(int value) {
    switch (value) {
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

  String getTypeJourVal(int value) {
    switch (value) {
      case 1:
        return "Jour";
      case 2:
        return "Nuit";
      default:
        return "Non défini";
    }
  }

  String getSectionVal(int value) {
    switch (value) {
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
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const HomeScreen());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Fiche Incident",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: AppColors.appColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Get.offAll(() => const HomeScreen());
            },
          ),
        ),
        body: DefaultTabController(
          length: 3,
          initialIndex: initialTabIndex,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Incident",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _alertDetails != null &&
                                _alertDetails!['blesse_oui_non'] == 1
                            ? Colors.redAccent.withOpacity(0.2)
                            : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _alertDetails != null &&
                                _alertDetails!["prenom_nom"] != null
                            ? 'Responsable: ${_alertDetails!["prenom_nom"]}'
                            : 'Non affecté',
                        style: TextStyle(
                          color: _alertDetails != null &&
                                  _alertDetails!["prenom_nom"] != null
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TabBar(
                  physics: const BouncingScrollPhysics(),
                  isScrollable: false, // Centered
                  unselectedLabelColor: Colors.grey[600],
                  labelColor: AppColors.white,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.appColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.appColor.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 20),
                          SizedBox(height: 4),
                          Text("Incident",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 20),
                          SizedBox(height: 4),
                          Text("Victime",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.dangerous, size: 20),
                          SizedBox(height: 4),
                          Text("Dégâts",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.visible,
                              maxLines: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<void>(
                  future: _fetchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur: ${snapshot.error}"));
                    }

                    // Une fois les données chargées
                    return TabBarView(
                      children: [
                        (_alertDetails != null && _ficheIncidentDetails != null)
                            ? DetailsFicheIncident(
                                alertDetails: _alertDetails!,
                                ficheIncidentDetails: _ficheIncidentDetails!,
                                haveDraft: currentStepAcc != 1,
                              )
                            : _alertDetails != null
                                ? DetailsFicheIncident(
                                    alertDetails: _alertDetails!,
                                    haveDraft: currentStepAcc != 1,
                                  )
                                : Text(""),
                        global.viewVictimeIncident
                            ? DetailsFicheIncidentVictime(
                                victimeDetails: _ficheVictimeDetails,
                                alertId: widget.alertId,
                                accidentID: _ficheIncidentDetails != null
                                    ? _ficheIncidentDetails!["idfiche_incident"]
                                    : -1,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.no_accounts,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Accès non autorisé",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Vous n'avez pas la permission de\nvoir les victimes",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                        DetailsFicheIncidentDegatsMateriels(
                          degatDetails: _ficheDegatsDetails,
                          alertId: widget.alertId,
                          accidentID: _ficheIncidentDetails != null
                              ? _ficheIncidentDetails!["idfiche_incident"]
                              : -1,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
