import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/collect/accident/collect_accident_victime.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import '../../../core/dialog/accident/victime_details_dialog.dart';
import '../../../core/dialog/incident/incident_victime_details_dialog.dart';
import '../../../sqflite/database_helper.dart';
import '../../../widgets/update_evacuation_dialog.dart';

class DetailsFicheAccidentVictime extends StatelessWidget {
  final List<Map<String, dynamic>> victimeDetails;
  final int accidentID;
  final int alertId;

  DetailsFicheAccidentVictime(
      {super.key,
      required this.victimeDetails,
      required this.accidentID,
      required this.alertId});

  DatabaseHelper db = DatabaseHelper();

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Non défini';
    try {
      final dateTime = DateTime.parse(isoDate);
      return Jiffy(dateTime).format("dd MMM yyyy 'à' HH:mm");
    } catch (e) {
      return 'Non défini';
    }
  }

  Future<String> getLibelleFromDb(String tableName, int id) async {
    final db = DatabaseHelper();
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
  }

  void showVictimDetails(
      BuildContext context, Map<String, dynamic> victimInfo) {
    showDialog(
      context: context,
      builder: (context) => VictimDetailsDialog(
        victimInfo: victimInfo,
        getLibelleFromDb: getLibelleFromDb,
      ),
    );
  }

  // Méthode pour ouvrir le dialogue de modification du lieu d'évacuation
  Future<void> _showUpdateEvacuationDialog(
      BuildContext context, Map<String, dynamic> victim) async {
    // Récupérer les informations actuelles
    final victimeId = victim['idfiche_accident_victime'];
    final String nomComplet = "${victim['prenom']} ${victim['nom']}";
    final String currentLocation =
        victim['structure_sanitaire_evac'] ?? 'Non spécifié';

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateEvacuationDialog(
          code: "victime",
          currentLocation: currentLocation,
          victimeId: victimeId,
          victimeName: nomComplet,
        );
      },
    );

    // Si un résultat est retourné, on peut gérer la mise à jour ici
    // Mais comme demandé, vous gérerez la partie envoi plus tard
    if (result != null) {
      // Afficher juste un toast pour confirmer
      Get.snackbar(
        "Information",
        "Lieu d'évacuation mis à jour pour $nomComplet",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 3),
      );

      // Vous pouvez ajouter votre logique de mise à jour ici plus tard
    }
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String title,
      required Map<String, dynamic> victim,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.appColor, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${victim['prenom']} ${victim['nom']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Âge: ${victim['age'] ?? 'Non défini'} ans",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.local_hospital,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Lieu d'évacuation: ${victim['structure_sanitaire_evac'] ?? 'Non spécifié'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showUpdateEvacuationDialog(context, victim);
                  },
                  icon: const Icon(Icons.edit_location_alt, size: 18),
                  label: const Text("Modifier lieu"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.appColor,
                    side: BorderSide(color: AppColors.appColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => IncidentVictimeDetailsDialog(
                        victimInfo: victim,
                        getLibelleFromDb: getLibelleFromDb,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text("Voir détails"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight - 280,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: victimeDetails.isNotEmpty
            ? ListView.builder(
                itemCount: victimeDetails.length,
                itemBuilder: (context, index) {
                  final vehicule = victimeDetails[index];
                  return _buildInfoTile(
                      icon: Icons.personal_injury,
                      title: "Nom complet",
                      victim: vehicule,
                      context: context);
                },
              )
            : const Center(
                child: Text(
                  "Aucune donnée enregistrée",
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (accidentID != -1) {
            final result = await Get.to(
              CollectAccidentVictimeScreen(
                accidentId: accidentID,
                alertId: alertId,
              ),
              transition: Transition.rightToLeft,
            );
            if (result == true) {
              // Rafraîchir la page
              Get.forceAppUpdate();
            }
          } else {
            Get.snackbar("Impossible",
                "Vous devez d'abord renseigner la fiche accident");
          }
        },
        backgroundColor: AppColors.appColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
