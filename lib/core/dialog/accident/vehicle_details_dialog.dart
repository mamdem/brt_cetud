import 'dart:ui';

import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/sqflite/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> vehicleInfo;

  VehicleDetailsDialog({Key? key, required this.vehicleInfo}) : super(key: key);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Ajustez la largeur si nécessaire
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 600), // Largeur augmentée
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre fixe en haut
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_car, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Détails Véhicule",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            // Contenu défilable
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.appColor.withOpacity(0.1), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Informations Véhicule"),
                        _buildInfoRow("Matricule", vehicleInfo['matricule']),
                        _buildInfoRow("Numéro Carte Grise", vehicleInfo['num_carte_grise']),
                        FutureBuilder<String>(
                          future: getLibelleFromDb("categorie_vehicule", vehicleInfo['categorie_vehicule']),
                          builder: (context, snapshot) {
                            return _buildInfoRow("Catégorie", snapshot.data);
                          },
                        ),
                        _buildInfoRow("Autre Véhicule", vehicleInfo['autre_vehicule']),
                        _buildInfoRow("Autres Informations", vehicleInfo['autre_information_add']),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Informations Chauffeur"),
                        _buildInfoRow("Prénom", vehicleInfo['prenom_chauffeur']),
                        _buildInfoRow("Nom", vehicleInfo['nom_chauffeur']),
                        _buildInfoRow("Âge", vehicleInfo['age']?.toString()),
                        _buildInfoRow("Sexe", vehicleInfo['sexe']),
                        _buildInfoRow("Téléphone", vehicleInfo['tel_chauffeur']),
                        _buildInfoRow("Numéro Permis", vehicleInfo['numero_permis']),
                        _buildInfoRow("Date de Délivrance Permis", vehicleInfo['date_delivrance_permis']),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Informations Assurance"),
                        _buildInfoRow("Numéro Assurance", vehicleInfo['numero_assurance']),
                        _buildInfoRow("Assureur", vehicleInfo['assureur']),
                        _buildInfoRow("Date Expiration Assurance", vehicleInfo['date_expiration_assurance']),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Dimensions et État du Véhicule"),
                        _buildInfoRow("Hauteur", vehicleInfo['hauteur_veh']?.toString()),
                        _buildInfoRow("Largeur", vehicleInfo['largeur_veh']?.toString()),
                        _buildInfoRow("Longueur", vehicleInfo['longueur_veh']?.toString()),
                        _buildInfoRow("Kilométrage", vehicleInfo['kilometrage']?.toString()),
                        _buildInfoRow("État Général", vehicleInfo['etat_generale']),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Fonctionnalités et Équipements"),
                        _buildInfoRow("Eclairage", vehicleInfo['eclairage']),
                        FutureBuilder<String>(
                          future: getLibelleFromDb("etat_equipment", int.parse(vehicleInfo['avertisseur'])),
                          builder: (context, snapshot) {
                            return _buildInfoRow("Avertisseur", snapshot.data);
                          },
                        ),
                        FutureBuilder<String>(
                          future: getLibelleFromDb("etat_equipment", int.parse(vehicleInfo['indicateur_vitesse'])),
                          builder: (context, snapshot) {
                            return _buildInfoRow("Indicateur Vitesse", snapshot.data);
                          },
                        ),
                        FutureBuilder<String>(
                          future: getLibelleFromDb("etat_equipment", int.parse(vehicleInfo['essuie_glace'])),
                          builder: (context, snapshot) {
                            return _buildInfoRow("Essuie glace", snapshot.data);
                          },
                        ),
                        FutureBuilder<String>(
                          future: getLibelleFromDb("etat_equipment", int.parse(vehicleInfo['retroviseur'])),
                          builder: (context, snapshot) {
                            return _buildInfoRow("Rétroviseur", snapshot.data);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DatabaseHelper db = DatabaseHelper();

  Future<String> getLibelleFromDb(String tableName, int? id) async {
    if (id == null) return 'Non défini';
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
  }
}
