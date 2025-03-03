import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:brt_mobile/core/utils/app_colors.dart';
import '../../../sqflite/database_helper.dart';
import '../../collect/accident/collect_accident_degats_materiels_screen.dart';
import '../../collect/incident/collect_incident_degats_materiels_screen.dart';

class DetailsFicheDegatsMateriels extends StatelessWidget {
  final List<Map<String, dynamic>> degatDetails;
  final int accidentID;

  DetailsFicheDegatsMateriels({super.key, required this.degatDetails, required this.accidentID});

  DatabaseHelper db = DatabaseHelper();

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Non défini';
    try {
      final dateTime = DateTime.parse(isoDate);
      return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    } catch (e) {
      return 'Non défini';
    }
  }

  void showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Voir l'image",
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required Map<String, dynamic> degat,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: degat['photos'] != null
                ? Image.file(
              File(degat['photos']),
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            )
                : Container(
              height: 50,
              width: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 30, color: Colors.grey),
            ),
          ),
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
                  degat['libelle_materiels'] ?? "Non défini",
                  style: const TextStyle(fontSize: 19),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (degat['photos'] != null) {
                showImageDialog(context, degat['photos']);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aucune image disponible")),
                );
              }
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
              "Voir image",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    print(degatDetails);
    return Scaffold(
      body: Container(
        height: screenHeight - 280,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: degatDetails.isNotEmpty
            ? ListView.builder(
          itemCount: degatDetails.length,
          itemBuilder: (context, index) {
            final degat = degatDetails[index];
            return _buildInfoTile(
              title: "Dégât matériel",
              degat: degat,
              context: context,
            );
          },
        )
            : const Center(
          child: Text(
            "Aucun dégât matériel enregistré",
            style: TextStyle(fontSize: 21),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(accidentID!=-1){
            Get.to(
              CollectAccidentDegatMaterielsScreen(accidentId: accidentID),
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
