import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/fiche_incident_victime.dart';
import '../../../sqflite/database_helper.dart';
import '../../../widgets/success_alert.dart';

class FicheIncidentVictimeScreen extends StatefulWidget {
  final int incidentId; // ID de l'incident
  const FicheIncidentVictimeScreen({Key? key, required this.incidentId}) : super(key: key);

  @override
  _FicheIncidentVictimeScreenState createState() => _FicheIncidentVictimeScreenState();
}

class _FicheIncidentVictimeScreenState extends State<FicheIncidentVictimeScreen> {
  int currentStep = 1;
  final int nbStep = 4;

  // Champs de texte pour les données de la victime
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  String? _sexe; // 'M' ou 'F'
  String? _etatVictime; // 'Blessé' ou 'Mort'
  final TextEditingController _structureSanitaireController = TextEditingController();
  final TextEditingController _natureBlessureController = TextEditingController();
  final TextEditingController _dateGuerisonController = TextEditingController();
  String? _statutGuerison; // 'En traitement', 'Guéri'

  final _formKey = GlobalKey<FormState>();

  void openDialogSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Fiche incident victime enregistrée avec succès !",
          onPressed: () => Get.back(),
          onClose: () => Get.back(),
        );
      },
    );
  }

  Future<void> saveVictime() async {
    final fiche = FicheIncidentVictime(
      incidentId: widget.incidentId,
      prenom: _prenomController.text,
      nom: _nomController.text,
      age: int.tryParse(_ageController.text),
      sexe: _sexe,
      tel: _telController.text,
      etatVictime: _etatVictime,
      structureEvacuation: _structureSanitaireController.text,
      dateGuerison: _dateGuerisonController.text,
      createdAt: DateTime.now().toIso8601String().toString(),
    );

    final db = DatabaseHelper();
    await db.insertFicheIncidentVictime(fiche);

    openDialogSuccess();
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: currentStep / nbStep,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Étape $currentStep/$nbStep',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVictimeDetailsStep() {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Détails de la victime',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prénom', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _prenomController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le prénom',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nom', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le nom',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Âge', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Entrez l\'âge',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Sexe', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      items: ['Masculin', 'Féminin']
                          .map((sexe) => DropdownMenuItem(
                        value: sexe == 'Masculin' ? 'M' : 'F',
                        child: Text(sexe),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sexe = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBlessureDetailsStep() {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Blessures et guérison',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nature des blessures', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _natureBlessureController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Décrivez les blessures',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Statut de guérison', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      items: ['En traitement', 'Guéri']
                          .map((statut) => DropdownMenuItem(
                        value: statut == 'En traitement' ? 'e' : 'g',
                        child: Text(statut),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _statutGuerison = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Date de guérison', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dateGuerisonController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        hintText: 'Entrez la date (jj/mm/aaaa)',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fiche Incident Victime"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                child: currentStep == 1
                    ? _buildVictimeDetailsStep()
                    : currentStep == 2
                    ? _buildBlessureDetailsStep()
                    : Container(), // Ajoutez d'autres étapes si nécessaire
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep > 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: const Text('Précédent'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep < nbStep) {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            currentStep++;
                          });
                        }
                      } else {
                        saveVictime();
                      }
                    },
                    child: Text(currentStep < nbStep ? 'Suivant' : 'Soumettre'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
