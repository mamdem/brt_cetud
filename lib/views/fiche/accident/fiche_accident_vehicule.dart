import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import '../../../sqflite/database_helper.dart';
import '../../collect/accident/collect_accident_vehicule.dart';
import '../../../core/dialog/accident/vehicle_details_dialog.dart';

class DetailsFicheVehicule extends StatelessWidget {
  final List<Map<String, dynamic>> vehiculeDetails;
  final int accidentID;
  final int alertId;

  DetailsFicheVehicule({super.key, required this.vehiculeDetails, required this.accidentID, required this.alertId});

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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required Map<String, dynamic> vehicle,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.appColor, size: 38),
          const SizedBox(width: 21),
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
                Text(
                  vehicle['matricule'],
                  style: const TextStyle(fontSize: 19),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => VehicleDetailsDialog(vehicleInfo: vehicle),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.appColor,
              side: BorderSide(color: AppColors.appColor, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text(
              "Détails",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void showVehicleDetailsDialog(BuildContext context, List<Map<String, dynamic>> vehiclesInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Véhicules impliqués",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 27),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ...vehiclesInfo.map((vehicle) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.directions_car, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    vehicle['matricule'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              _buildInfoRow("Carte grise", vehicle['num_carte_grise']),
                              _buildInfoRow("Catégorie", _getCategoryName(vehicle['categorie_vehicule'])),
                              const Divider(height: 16),
                              const Text(
                                "Information Chauffeur",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow("Nom", "${vehicle['prenom_chauffeur'] ?? ''} ${vehicle['nom_chauffeur'] ?? ''}"),
                              _buildInfoRow("Age", "${vehicle['age'] ?? 'N/A'} ans"),
                              _buildInfoRow("Sexe", vehicle['sexe'] ?? 'N/A'),
                              if (vehicle['tel_chauffeur'] != null)
                                _buildInfoRow("Téléphone", vehicle['tel_chauffeur']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 19,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 19,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(int? categoryId) {
    switch (categoryId) {
      case 1:
        return "Véhicule léger";
      case 2:
        return "Poids lourd";
      case 3:
        return "Deux roues";
      default:
        return "Non spécifié";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: screenHeight - 280,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: vehiculeDetails.isNotEmpty
            ? ListView.builder(
          itemCount: vehiculeDetails.length,
          itemBuilder: (context, index) {
            final vehicule = vehiculeDetails[index];
            return _buildInfoTile(
              icon: Icons.bus_alert_sharp,
              title: "Matricule",
              vehicle: vehicule,
              context: context,
            );
          },
        )
            : const Center(
          child: Text(
            "Aucune donnée enregistrée",
            style: TextStyle(fontSize: 21),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(accidentID!=-1){
            Get.to(
              CollectAccidentVehiculeScreen(
                accidentId: accidentID,
                alertId: alertId,
              ),
              transition: Transition.rightToLeft,
            );
          }else{
            Get.snackbar("Impossible", "Vous devez d'abord renseigner la fiche accident");
          }

        },
        backgroundColor: AppColors.appColor,
        child: const Icon(Icons.add, color: Colors.white, size: 27),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
