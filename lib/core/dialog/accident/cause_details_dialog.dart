import 'package:flutter/material.dart';
import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/sqflite/database_helper.dart';

class CauseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> causeInfo;

  CauseDetailsDialog({Key? key, required this.causeInfo}) : super(key: key);

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
            width: 100,
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dialog Header
                Row(
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
                          child: const Icon(Icons.warning, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Détails Cause",
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
                const Divider(height: 24),

                // Cause Information Section
                Container(
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
                      _buildSectionTitle("Information Cause"),
                      _buildInfoRow("Cause", causeInfo['causes']),
                      _buildInfoRow("Numéro PV", causeInfo['num_pv']),
                      _buildInfoRow("Commentaire", causeInfo['commentaire'] ?? "Non défini"),
                      const Divider(height: 16),

                      _buildSectionTitle("Métadonnées"),
                      FutureBuilder<String>(
                        future: getLibelleFromDb("users", causeInfo['user_saisie']),
                        builder: (context, snapshot) {
                          return _buildInfoRow("Saisie par", snapshot.data ?? "Non défini");
                        },
                      ),
                      _buildInfoRow("Créé le", causeInfo['created_at'] ?? "Non défini"),
                      _buildInfoRow("Mis à jour le", causeInfo['updated_at'] ?? "Non défini"),
                      _buildInfoRow("Supprimé le", causeInfo['deleted_at'] ?? "Non défini"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DatabaseHelper db = DatabaseHelper();

  Future<String> getLibelleFromDb(String tableName, int? id) async {
    if (id == null) return "Non défini";
    final data = await db.getLibelleDataById(tableName, id);
    return data?['libelle'] ?? 'Non défini';
  }
}
