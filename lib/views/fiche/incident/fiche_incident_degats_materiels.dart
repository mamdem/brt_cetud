import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:brt_mobile/core/utils/app_colors.dart';
import '../../../sqflite/database_helper.dart';
import '../../collect/accident/collect_accident_degats_materiels_screen.dart';
import '../../collect/incident/collect_incident_degats_materiels_screen.dart';
import '../../../services/auth_service.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

class DetailsFicheIncidentDegatsMateriels extends StatefulWidget {
  final List<Map<String, dynamic>> degatDetails;
  final int accidentID;
  final int alertId;

  const DetailsFicheIncidentDegatsMateriels({
    Key? key,
    required this.degatDetails,
    required this.accidentID,
    required this.alertId,
  }) : super(key: key);

  @override
  State<DetailsFicheIncidentDegatsMateriels> createState() =>
      _DetailsFicheIncidentDegatsMaterielsState();
}

class _DetailsFicheIncidentDegatsMaterielsState
    extends State<DetailsFicheIncidentDegatsMateriels> {
  DatabaseHelper db = DatabaseHelper();
  bool _isProcessingImages = true;

  @override
  void initState() {
    super.initState();
    _checkImageProcessing();
  }

  Future<void> _checkImageProcessing() async {
    setState(() {
      _isProcessingImages = true;
    });

    try {
      await AuthService.waitForImageProcessing();
    } catch (e) {
      print('Erreur lors de la vérification du traitement des images: $e');
    } finally {
      setState(() {
        _isProcessingImages = false;
      });
    }
  }

  Future<bool> _checkImageExists(String path) async {
    if (path.startsWith('http')) return false;

    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      print('Erreur lors de la vérification du fichier: $e');
      return false;
    }
  }

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
                FutureBuilder<bool>(
                  future: _checkImageExists(imagePath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == true) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              '${global.baseUrlImage}/storage/$imagePath',
                              fit: BoxFit.cover,
                              height: 300,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child:
                                      Text('Erreur de chargement de l\'image'),
                                );
                              },
                            );
                          },
                        ),
                      );
                    } else {
                      return Image.network(
                        '${global.baseUrlImage}/storage/$imagePath',
                        fit: BoxFit.cover,
                        height: 300,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Erreur de chargement de l\'image'),
                          );
                        },
                      );
                    }
                  },
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
                ? FutureBuilder<bool>(
                    future: _checkImageExists(degat['photos']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey[300],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.data == true) {
                        return Image.file(
                          File(degat['photos']),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              '${global.baseUrlImage}/storage/${degat['photos']}',
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return Image.network(
                          '${global.baseUrlImage}/storage/${degat['photos']}',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 50,
                              width: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        );
                      }
                    },
                  )
                : Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.image, size: 30, color: Colors.grey),
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

    if (_isProcessingImages) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Chargement des images...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        height: screenHeight - 280,
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: widget.degatDetails.isNotEmpty
            ? ListView.builder(
                itemCount: widget.degatDetails.length,
                itemBuilder: (context, index) {
                  final degat = widget.degatDetails[index];
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
      floatingActionButton: global.addIncident
          ? FloatingActionButton(
              onPressed: () async {
                if (widget.accidentID != -1) {
                  final result = await Get.to(
                    CollectIncidentDegatMaterielsScreen(
                      incidentId: widget.accidentID,
                      alertId: widget.alertId,
                    ),
                    transition: Transition.rightToLeft,
                  );
                  if (result == true) {
                    // Rafraîchir la page
                    Get.forceAppUpdate();
                  }
                } else {
                  Get.snackbar("Impossible",
                      "Vous devez d'abord renseigner la fiche incident");
                }
              },
              backgroundColor: AppColors.appColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
