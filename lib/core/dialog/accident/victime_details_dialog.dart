import 'package:flutter/material.dart';

class VictimDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> victimInfo;
  final Future<String> Function(String tableName, int id) getLibelleFromDb;

  VictimDetailsDialog({
    Key? key,
    required this.victimInfo,
    required this.getLibelleFromDb,
  }) : super(key: key);

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
                          child: const Icon(Icons.person, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Détails Victime",
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Informations Générales"),
                      _buildInfoRow("Nom", "${victimInfo['prenom'] ?? ''} ${victimInfo['nom'] ?? ''}".trim()),
                      _buildInfoRow("Âge", "${victimInfo['age']} ans"),
                      _buildInfoRow("Téléphone", victimInfo['tel']),

                      const SizedBox(height: 16),
                      _buildInfoRow("Statut", victimInfo['etat_victime']=='b'?"Blessé":"Mort"),
                      _buildInfoRow("Structure sanitaire", victimInfo['structure_sanitaire_evac']),

                      const SizedBox(height: 16),
                      _buildInfoRow("Guérison", victimInfo['statut_guerison']=='e'?"En traitement":"Guéri"),
                      _buildInfoRow("Date de guérison", victimInfo['date_guerison']),

                      const SizedBox(height: 16),
                      _buildSectionTitle("Conscient/Inconscient"),
                      FutureBuilder<String>(
                        future: getLibelleFromDb("conscient_incoscient", victimInfo['conscient_inconscient']),
                        builder: (context, snapshot) {
                          return _buildInfoRow("Conscient ?", snapshot.data);
                        },
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle("Accompagnant"),
                      _buildInfoRow("Nom", "${victimInfo['accompagnant_prenom'] ?? ''} ${victimInfo['accompagnant_nom'] ?? ''}".trim()),
                      _buildInfoRow("Téléphone", victimInfo['accompagnant_tel']),
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
}
