import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:location/location.dart' as deviceLocation;
import '../../../core/utils/google_fonts.dart';
import '../../../models/alert.dart';
import '../../../models/fiche_incident_victime.dart';
import '../../../res/constant/app_assets.dart';
import '../../../sqflite/database_helper.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/damage_item.dart';
import '../../../widgets/success_alert.dart';

class CollectIncidentVictimeScreen extends StatefulWidget {
  final int incidentId;
  const CollectIncidentVictimeScreen({Key? key, required this.incidentId}) : super(key: key);

  @override
  _CollectIncidentVictimeScreenState createState() => _CollectIncidentVictimeScreenState();
}

class _CollectIncidentVictimeScreenState extends State<CollectIncidentVictimeScreen> {
  int currentStep = 1;
  final int nbStep = 2;

  String? _selectedSexe;

  String? _ageErrorText;
  bool isValidNumber=false;
  bool isValidNumberAccompagnantTel=false;

  List<Map<String, dynamic>> consIncons = [];
  List<Map<String, dynamic>> vehicules = [];
  List<Map<String, dynamic>> posVictime = [];

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _telController = TextEditingController();

  final TextEditingController _structureSanitaireController = TextEditingController();
  final TextEditingController _traumatismeController = TextEditingController();

  String? statutGuerison;

  final _formKey = GlobalKey<FormState>();

  void showError(String message) {
    Get.snackbar(
      "Validation",
      message,
      colorText: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  bool validateCurrentStep() {
    switch (currentStep) {
      case 1:
        if (_prenomController.text.isEmpty) {
          showError("Veuillez entrer le prénom de la victime.");
          return false;
        }
        if (_nomController.text.isEmpty) {
          showError("Veuillez entrer le nom de la victime.");
          return false;
        }
        if (_ageController.text.isEmpty || int.tryParse(_ageController.text) == null) {
          showError("Veuillez entrer un âge valide.");
          return false;
        }else if(int.parse(_ageController.text) < 1 || int.parse(_ageController.text) > 120){
          showError("L'âge doit être entre 1 et 120");
        }
        if (_telController.text.isEmpty || !isValidNumber) {
          showError("Veuillez entrer un numéro de téléphone.");
          return false;
        }
        break;

      case 2: // Validation de l'état et de la structure sanitaire
        if (_structureSanitaireController.text.isEmpty) {
          showError("Veuillez entrer une structure sanitaire.");
          return false;
        }
        if (_traumatismeController.text.isEmpty) {
          showError("Veuillez décrire la nature des blessures.");
          return false;
        }
        break;

      default:
        break;
    }
    return true;
  }

  void openDialogSuccess(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Fiche victime enregistré avec succès !",
          onPressed: () {
            Get.off(const HomeScreen(), transition: Transition.leftToRight);
          },
          onClose: () {
            Get.off(const HomeScreen(), transition: Transition.leftToRight);
          },
        );
      },
    );
  }

  Future<void> _fetchDatas() async {
    final db = DatabaseHelper();
    final dataConsIncons = await db.fetchTableDatas("conscient_incocient");
    final dataPosVictime = await db.fetchTableDatas("position_victime");

    setState(() {
      consIncons = dataConsIncons;
      posVictime = dataPosVictime;
    });
  }

  Future<void> saveVictime() async {
    // Récupération des données des steps
    final fiche = FicheIncidentVictime(
        incidentId: widget.incidentId,
        prenom: _prenomController.text,
        sexe: _selectedSexe,
        nom: _nomController.text,
        age: int.tryParse(_ageController.text),
        tel: _telController.text,
        structureEvacuation: _structureSanitaireController.text,
        userSaisie: global.user['idusers'],
        createdAt: DateTime.now(),
      traumatisme: _traumatismeController.text
    );

    // Insérer dans la base de données locale
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

  Widget _buildEtatEtStructureStep() {
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
                    Text('État et structure sanitaire',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Structure sanitaire d\'évacuation',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _structureSanitaireController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le nom de la structure sanitaire',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Traumatisme',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _traumatismeController,
                      decoration: InputDecoration(
                        hintText: 'Traumatisme',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVictimeStep() {
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
                    Text('Information victime',
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
                        hintText: 'Entrez le prénom du victime',
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
                        hintText: 'Entrez le nom du victime',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 8,),
                    DropdownButtonFormField<String>(
                      value: _selectedSexe,
                      decoration: InputDecoration(
                        labelText: "Sexe",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: const Text("Sélectionnez un sexe"),
                      items: const [
                        DropdownMenuItem(value: "M", child: Text("Masculin")),
                        DropdownMenuItem(value: "F", child: Text("Féminin")),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSexe = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12,),

                    const Text('Âge', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: "Age",
                        border: const OutlineInputBorder(),
                        errorText: _ageErrorText,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            final width = double.tryParse(value);
                            if (width == null || width < 1 || width > 120) {
                              _ageErrorText = "L'âge doit être entre 1 et 120";
                            } else {
                              _ageErrorText = null;
                            }
                          } else {
                            _ageErrorText = "L'âge est obligatoire";
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Téléphone', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      controller: _telController,
                      style: safeGoogleFont(
                        'Poppins',
                        color: AppColors.black,
                      ),
                      dropdownTextStyle: safeGoogleFont(
                        'Poppins',
                        color: AppColors.black,  // Change la couleur des textes des pays
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Téléphone',
                        prefixIcon: const Icon(Icons.phone_android, color: AppColors.appColor),
                        hintStyle: TextStyle(color: Colors.blue.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: AppColors.appColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: AppColors.appColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue.shade900, width: 2.0),
                        ),
                      ),
                      initialCountryCode: 'SN',
                      keyboardType: TextInputType.phone,
                      onChanged: (phone) {
                        isValidNumber = phone.isValidNumber();
                      },
                    ),
                    const SizedBox(height: 8),
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
  void initState() {
    super.initState();
    _fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fiche Incident Victime"),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                  child: currentStep == 1 ? _buildVictimeStep()
                      :                    _buildEtatEtStructureStep()
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
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: AppColors.appColor
                      ),
                      child: const Text('Précédent'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep < nbStep) {
                        if (validateCurrentStep()) {
                          setState(() {
                            currentStep++;
                          });
                        }
                      } else {
                        if (validateCurrentStep()) {
                          saveVictime();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: AppColors.appColor,
                    ),
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