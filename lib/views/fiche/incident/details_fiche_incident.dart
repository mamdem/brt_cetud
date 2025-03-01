import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/services/auth_service.dart';
import 'package:brt_mobile/views/collect/incident/collect_incident_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jiffy/jiffy.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

import '../../../sqflite/database_helper.dart';
import 'package:get/get.dart';

import '../../collect/accident/collect_accident_screen.dart';

class DetailsFicheIncident extends StatefulWidget {
  final Map<String, dynamic> alertDetails;
  final Map<String, dynamic>? ficheIncidentDetails;
  final bool haveDraft;


  const DetailsFicheIncident({
    Key? key,
    required this.alertDetails,
    this.ficheIncidentDetails,
    required this.haveDraft,
  }) : super(key: key);

  @override
  _DetailsFicheIncidentState createState() => _DetailsFicheIncidentState();
}

class _DetailsFicheIncidentState extends State<DetailsFicheIncident> {
  DatabaseHelper db = DatabaseHelper();
  bool _isLoading = true;
  late bool bRespSaisi;
  late bool bRensFichAcc;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        bRespSaisi = (widget.alertDetails["responsable_saisie"] == null);
        bRensFichAcc = (widget.ficheIncidentDetails==null && widget.alertDetails["responsable_saisie"] != null && widget.alertDetails["responsable_saisie"] == global.user['idusers']);
      });
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

  void showError(String message) {
    Get.snackbar(
      "Validation",
      message,
      //backgroundColor: Colors.grey.shade100,
      colorText: Colors.red,
      snackPosition: SnackPosition.TOP,
    );
  }

  String getAlertNiveauValueString(int value) {
    switch (value) {
      case 1:
        return "Situation d'urgence";
      case 2:
        return "Situation d'urgence pouvant évoluer en crise";
      case 3:
        return "Situation catastrophique";
      default:
        return "Non défini";
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.appColor, size: 27),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getLibelleFromDb(String tableName, int id) async {
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
  }

  Widget _buildVictimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTile(
          icon: Icons.people,
          title: "Victimes "+ widget.ficheIncidentDetails!['blesse']==1?"(Oui)":"(Non)",
          content: Column(
            children: [
              _buildVictimeDetail("Nb blessé", widget.alertDetails['nb_blesse']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFutureInfoTile(
      String dbTable,
      dynamic value,
      IconData icon,
      String title,
      ) {
    return FutureBuilder<String>(
      future: getLibelleFromDb(dbTable, value),
      builder: (context, snapshot) {
        return _buildInfoTile(
          icon: icon,
          title: title,
          content: Text(
            snapshot.data ?? "Chargement...",
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  Widget _buildConditionsSection() {
    return Column(
      children: [
        const Divider(height: 30),
        if (widget.ficheIncidentDetails!['condition_atmospherique'] != null)
          _buildFutureInfoTile(
            "conditon_atmostpherique",
            widget.ficheIncidentDetails!['condition_atmospherique'],
            Icons.cloud,
            "Condition atmosphérique",
          ),
        if (widget.ficheIncidentDetails!['type_jour'] != null)
          _buildFutureInfoTile(
            "type_jour",
            widget.ficheIncidentDetails!['type_jour'],
            Icons.today,
            "Type jour",
          ),
        if (widget.ficheIncidentDetails!['section_id'] != null)
          _buildFutureInfoTile(
            "sections",
            widget.ficheIncidentDetails!['section_id'],
            Icons.assignment,
            "Section",
          ),
        if (widget.ficheIncidentDetails!['visibilite'] != null)
          _buildFutureInfoTile(
            "visibilite",
            widget.ficheIncidentDetails!['visibilite'],
            Icons.visibility,
            "Visibilité",
          ),
        if (widget.ficheIncidentDetails!['chaussee'] != null)
          _buildFutureInfoTile(
            "chausse",
            widget.ficheIncidentDetails!['chaussee'],
            Icons.add_road,
            "Chaussée",
          ),
      ],
    );
  }

  Widget _buildVictimeDetail(String type, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Victime $type:",
          style: const TextStyle(
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return _isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: AppColors.appColor,
      ),
    )
        : Container(
      height: screenHeight - 280,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
      child: ListView(
        children: [
          _buildInfoTile(
            icon: Icons.numbers,
            title: "Code alerte",
            content: Text(
              (widget.alertDetails['code_alert']),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          _buildInfoTile(
            icon: Icons.location_on,
            title: "Localisation",
            content: FutureBuilder<String>(
              future: (widget. alertDetails['position_lat'] != null &&
                  widget.alertDetails['position_long'] != null)
                  ? global.getAddressFromLatLong(
                  widget.alertDetails['position_lat'],
                  widget.alertDetails['position_long'],
                  2)
                  : Future.value("Coordonnées indisponibles"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Chargement...");
                }
                return Text(
                  widget.alertDetails['voie'] == 1
                      ? "Corridor: ${snapshot.data}"
                      : "Hors Corridor: ${snapshot.data}",
                  style: const TextStyle(fontSize: 18),
                );
              },
            ),
          ),
          _buildInfoTile(
            icon: Icons.calendar_today,
            title: "Date",
            content: Text(
              formatDate(widget.alertDetails['date_alert']),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          _buildInfoTile(
            icon: Icons.directions_bus,
            title: "Matricule Bus",
            content: Text(
              widget.alertDetails['matricule_bus']??"N/A",
              style: const TextStyle(fontSize: 18),
            ),
          ),
          _buildInfoTile(
            icon: Icons.warning,
            title: "Niveau alerte",
            content: Text(
              getAlertNiveauValueString(widget.alertDetails['alerte_niveau_id']),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          if(widget.ficheIncidentDetails != null)...[
            if (widget.ficheIncidentDetails!['blesse']==true) _buildVictimesSection(),
            if (widget.ficheIncidentDetails!['interruption_service'] != null)...[
              _buildInfoTile(
                icon: Icons.electrical_services_rounded,
                title: "Interruption service",
                content: Text(
                  widget.ficheIncidentDetails!['interruption_service']==1?"Oui":"Non",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              if(widget.ficheIncidentDetails!['interruption_service']==1)
                _buildInfoTile(
                  icon: Icons.date_range,
                  title: "Date reprise service",
                  content: Text(
                    "",
                    //formatDate(widget.ficheIncidentDetails!['date_reprise']).substring(0, 13),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
            ],

            _buildConditionsSection(),
            const SizedBox(height: 20),
          ],
          if(bRespSaisi)...[
            ElevatedButton.icon(
              onPressed: () async {
                final Map<String, dynamic> dataFichResp = {
                  'code_alert': widget.alertDetails["code_alert"],
                  'responsable_saisie': global.user["idusers"],
                  'prenom_nom': "${global.user['prenom_user']} ${global.user["nom_user"]}",
                  'created_at': DateTime.now().toIso8601String(),
                };
                if(widget.alertDetails['id_server']!=null){
                  try{
                    await AuthService.saveResponsable(
                        codeAlert: widget.alertDetails["code_alert"],
                        responsableSaisie: (global.user["idusers"]),
                        prenomNom: "${global.user['prenom_user']} ${global.user["nom_user"]}",
                        createdAt: DateTime.now().toIso8601String().toString(),
                        mp: global.user['mp'],
                        deviceInfo: global.phoneIdentifier
                    );
                    setState(() {
                      bRensFichAcc = true;
                      bRespSaisi = false;
                    });
                  }catch(e){
                    print("Erreur lors de l'insertion : $e");
                  }
                  final int insertedId = await DatabaseHelper().insertResponsableSaisi(dataFichResp);
                  Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
                  print("Insertion réussie, ID inséré : $insertedId");
                }else{
                  showError("Veuillez d'abord synchroniser !");
                  Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
                }

              },
              style: ElevatedButton.styleFrom(
                primary: AppColors.appColor,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.person, size: 24), // Icône de gauche
              label: const Text(
                "S'affecter à l'incident",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          if (bRensFichAcc) ...[
            ElevatedButton.icon(
              onPressed: () {
                Get.off(CollectIncidentScreen(alertId: widget.alertDetails["idfiche_alert"]));
              },
              style: ElevatedButton.styleFrom(
                primary: AppColors.appColor,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              icon: const Icon(Icons.car_crash, size: 24),
              label: Text(
                widget.haveDraft
                    ? "Continuer la fiche incident"
                    : "Renseigner la fiche incident",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.haveDraft)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  "Un brouillon existe pour cette fiche accident. Cliquez sur le bouton pour continuer.",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ]
        ],
      ),
    );
  }
}
