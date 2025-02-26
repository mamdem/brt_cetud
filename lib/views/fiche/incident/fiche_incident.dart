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
import 'details_fiche_incident.dart';
import 'fiche_incident_victime.dart';



class DetailsIncident extends StatefulWidget {
  final int alertId;

  const DetailsIncident({super.key, required this.alertId});

  @override
  _DetailsIncidentState createState() => _DetailsIncidentState();
}

class _DetailsIncidentState extends State<DetailsIncident> {
  int _selectedIndex = 0;
  int currentStepAcc = 1;
  final int initialTabIndex=0; // Index de l'onglet initial

  Map<String, dynamic>? _alertDetails;
  Map<String, dynamic>? _ficheIncidentDetails;
  List<Map<String, dynamic>> _ficheVictimeDetails=[];
  List<Map<String, dynamic>> _ficheDegatsDetails=[];

  late Future<void> _fetchFuture;

  DatabaseHelper db = DatabaseHelper();
  bool _isLoading1 = true;
  bool _isLoading2 = true;
  bool _isLoading3 = true;

  Future<void> initialize() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStepAcc = prefs.getInt('currentStep${widget.alertId}') ?? 1;
    });
    //await _fetchAllRespSaisiDetails();
    try{
      await _fetchAlertDetails();
    }catch(e){}
    try{
      await fetchVictimes();
    }catch(e){}try{
      await fetchDegatDetails();
    }catch(e){}
  }

  @override
  void initState() {
    super.initState();
    try{
      _fetchFuture = _fetchFicheIncidentDetails();
    }catch(e){}
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
    final victimesData = await db.getVictimesByIncidentId(_ficheIncidentDetails!['idfiche_incident']);
    setState(() {
      _ficheVictimeDetails = victimesData;
    });
  }

  Future<void> fetchDegatDetails() async {
    final db = await DatabaseHelper();
    final degatsData = await db.getIncidentDegatsMaterielsById(_ficheIncidentDetails!['idfiche_incident']);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Détails de l'incident",
        ),
        backgroundColor: AppColors.appColor,
      ),
      body: DefaultTabController(
        length: 3,
        initialIndex: initialTabIndex,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Incident",
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
                    margin: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: const Tab(
                      icon: Icon(Icons.warning_amber),
                      text: "Incident",
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: const Tab(
                      icon: Icon(Icons.people),
                      text: "Victime",
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 7.0),
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
              child: FutureBuilder<void>(
                future: _fetchFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erreur: ${snapshot.error}"));
                  }

                  // Une fois les données chargées
                  return TabBarView(
                    children: [
                      (_alertDetails != null && _ficheIncidentDetails != null)
                          ? DetailsFicheIncident(
                        alertDetails: _alertDetails!,
                        ficheIncidentDetails: _ficheIncidentDetails!,
                        haveDraft: currentStepAcc != 1,
                      ): _alertDetails!=null ? DetailsFicheIncident(
                        alertDetails: _alertDetails!,
                        haveDraft: currentStepAcc != 1,
                      ):Text(""),
                      DetailsFicheIncidentVictime(
                        victimeDetails: _ficheVictimeDetails,
                        accidentID: _ficheIncidentDetails != null
                            ? _ficheIncidentDetails!["idfiche_incident"]
                            : -1,
                      ),
                      DetailsFicheIncidentDegatsMateriels(
                        degatDetails: _ficheDegatsDetails,
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
    );
  }
}
