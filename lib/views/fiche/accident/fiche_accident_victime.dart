import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/collect/accident/collect_accident_victime.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import '../../../core/dialog/accident/victime_details_dialog.dart';
import '../../../sqflite/database_helper.dart';

class DetailsFicheAccidentVictime extends StatelessWidget {
  final List<Map<String, dynamic>> victimeDetails;
  final int accidentID;

  DetailsFicheAccidentVictime({super.key, required this.victimeDetails, required this.accidentID});

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


  void showVictimDetails(BuildContext context, Map<String, dynamic> victimInfo) {
    showDialog(
      context: context,
      builder: (context) => VictimDetailsDialog(
        victimInfo: victimInfo,
        getLibelleFromDb: getLibelleFromDb,
      ),
    );
  }


  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required Map<String, dynamic> victim,
    required BuildContext context
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.appColor, size: 35),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text("${victim['prenom']} ${victim['nom']}"),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => VictimDetailsDialog(
                  victimInfo: victim,
                  getLibelleFromDb: getLibelleFromDb,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              onPrimary: AppColors.appColor,
              side: BorderSide(color: AppColors.appColor, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            ),
            child: const Text(
              "Détails",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
                icon: Icons.personal_injury ,
                title: "Nom complet",
                victim: vehicule,
                context: context
            );
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
        onPressed: () {
          if(accidentID!=-1){
            Get.off(
              FicheAccidentVictimeScreen(
                accidentId: accidentID,
              ),
              transition: Transition.rightToLeft,
            );
          }else{
            Get.snackbar("Impossible", "Vous devez d'abord renseigner la fiche accident");
          }
        },
        backgroundColor: AppColors.appColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
