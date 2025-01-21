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

import 'fiche_accident_degats_materiels.dart';
import 'fiche_accident_victime.dart';

class DetailsAccident extends StatefulWidget {
  final int alertId;

  const DetailsAccident({super.key, required this.alertId});

  @override
  _DetailsAccidentState createState() => _DetailsAccidentState();
}

class _DetailsAccidentState extends State<DetailsAccident> {
  int _selectedIndex = 0;
  int currentStepAcc = 1;
  final int initialTabIndex=0; // Index de l'onglet initial

  Map<String, dynamic>? _alertDetails;
  Map<String, dynamic>? _ficheAccidentDetails;
  Map<String, dynamic>? _ficheRespSaisi;
  List<Map<String, dynamic>> _ficheVehiculeDetails=[];
  List<Map<String, dynamic>> _ficheVictimeDetails=[];
  List<Map<String, dynamic>> _ficheDegatsDetails=[];

  DatabaseHelper db = DatabaseHelper();
  bool _isLoading1 = true;
  bool _isLoading2 = true;
  bool _isLoading3 = true;

  Future<void> initialize() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStepAcc = prefs.getInt('currentStep${widget.alertId}') ?? 1;
    });
    await _fetchAlertDetails();
    await _fetchFicheAccidentDetails();
    await _fetchFicheVehiculeDetails();
    await fetchVictimes();
    await fetchDegatDetails();
    //await _fetchRespSaisiDetails();
  }

  @override
  void initState() {
    super.initState();
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
    final victimesData = await db.getVictimesByAccidentId(_ficheAccidentDetails!['idfiche_accident']);
    setState(() {
      _ficheVictimeDetails = victimesData;
    });
  }

  Future<void> fetchDegatDetails() async {
    final db = await DatabaseHelper();
    final degatsData = await db.getAccidentDegatsMaterielsById(_ficheAccidentDetails!['idfiche_accident']);
    setState(() {
      _ficheDegatsDetails = degatsData;
    });
  }

  Future<void> _fetchFicheAccidentDetails() async {
    _fetch();
    final db = DatabaseHelper();
    final ficheAccident = await db.getFicheAccidentByIdAlert(widget.alertId);

    setState(() {
      _ficheAccidentDetails = ficheAccident;
      _isLoading2 = false;
    });
  }

  Future<void> _fetch() async {
    final db = DatabaseHelper();
    final ficheAccident = await db.getAllFicheAccidents();
    setState(() {
      for(FicheAccident f in ficheAccident){
        print(f.toMap());
        print("\n\n-----------------------");
      }
      _isLoading2 = false;
    });
  }

  Future<void> _fetchFicheVehiculeDetails() async {
    final db = DatabaseHelper();
    final ficheAccident = await db.getFicheVehiculeByAccidentId(_ficheAccidentDetails!["idfiche_accident"]);
    setState(() {
      _ficheVehiculeDetails = ficheAccident;
      _isLoading3 = false;
    });
  }

  Future<void> _fetchRespSaisiDetails() async {
    final db = DatabaseHelper();
    final resp = await db.getRespSaisiByCodeAlert(_alertDetails!['code_alert']);
    setState(() {
      _ficheRespSaisi = resp;
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
          "Détails de l'accident",
        ),
        backgroundColor: AppColors.appColor,
      ),
      body: _isLoading1 || _isLoading2
          ? const Center(child: CircularProgressIndicator())
          : false
          ? const Center(
        child: Text(
          "Aucune donnée disponible pour cet incident.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : DefaultTabController(
        length: 4,
        initialIndex: initialTabIndex,
        child: Column(
            children: [
              Padding(padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
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
                        color: _alertDetails!=null && _alertDetails!['blesse_oui_non'] == 1
                            ? Colors.redAccent.withOpacity(0.2)
                            : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _ficheAccidentDetails!=null && _ficheAccidentDetails!['user_update']!=null ? 'Affecté' : 'Non affecté',
                        style: TextStyle(
                          color: _ficheAccidentDetails!=null && _ficheAccidentDetails!['user_update']!=null ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
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
                      margin: const EdgeInsets.symmetric(horizontal: 0.0), // Ajoute une marge horizontale
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
              SizedBox(
                height: screenHeight-screenHeight/2.7,
                child: TabBarView(
                  children: [
                    if(_ficheAccidentDetails!=null)...[
                      _ficheRespSaisi!=null ? DetailsFicheAccident(alertDetails: _alertDetails!, ficheAccidentDetails: _ficheAccidentDetails!, ficheResponsableSaisi: _ficheRespSaisi, haveDraft: currentStepAcc!=1,)
                      :DetailsFicheAccident(alertDetails: _alertDetails!, ficheAccidentDetails: _ficheAccidentDetails!, haveDraft: currentStepAcc!=1)
                    ]else...[
                      _ficheRespSaisi!=null ? DetailsFicheAccident(alertDetails: _alertDetails!, ficheResponsableSaisi: _ficheRespSaisi,haveDraft: currentStepAcc!=1)
                      :DetailsFicheAccident(alertDetails: _alertDetails!, haveDraft: currentStepAcc!=1)
                    ],
                    DetailsFicheVehicule(vehiculeDetails: _ficheVehiculeDetails, accidentID:_ficheAccidentDetails!=null? _ficheAccidentDetails!["idfiche_accident"]:-1,),
                    DetailsFicheAccidentVictime(victimeDetails: _ficheVictimeDetails, accidentID:_ficheAccidentDetails!=null? _ficheAccidentDetails!["idfiche_accident"]:-1,),
                    DetailsFicheDegatsMateriels(degatDetails: _ficheDegatsDetails, accidentID:_ficheAccidentDetails!=null? _ficheAccidentDetails!["idfiche_accident"]:-1,),
                  ]
                ),
              )
            ],
          ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: MaterialButton(
          onPressed: onTap,
          padding: const EdgeInsets.symmetric(vertical: 16.0),

          //color: Colors.white,
          elevation: 0,
          hoverElevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.appColor, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.appColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
