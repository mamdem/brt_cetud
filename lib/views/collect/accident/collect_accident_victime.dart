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
import '../../../models/fiche_accident.dart';
import '../../../models/fiche_accident_vehicule.dart';
import '../../../models/fiche_accident_victime.dart';
import '../../../res/constant/app_assets.dart';
import '../../../sqflite/database_helper.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/damage_item.dart';
import '../../../widgets/success_alert.dart';
import '../../fiche/accident/fiche_accident.dart';

class CollectAccidentVictimeScreen extends StatefulWidget {
  final int accidentId;
  final int alertId;
  const CollectAccidentVictimeScreen({Key? key, required this.accidentId, required this.alertId}) : super(key: key);

  @override
  _CollectAccidentVictimeScreenState createState() => _CollectAccidentVictimeScreenState();
}

class _CollectAccidentVictimeScreenState extends State<CollectAccidentVictimeScreen> {
  int currentStep = 1;
  final int nbStep = 4;
  int? _conscient;

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


  String? _etatVictime;
  final TextEditingController _structureSanitaireController = TextEditingController();

  int? _vehicule;


  final TextEditingController _natureBlessureController = TextEditingController();
  String? statutGuerison;
  int? _selectedPosVictime;
  final TextEditingController _dateGuerisonController = TextEditingController();

  final TextEditingController _numPvController = TextEditingController();
  final TextEditingController _filiationPrenomPereController = TextEditingController();
  final TextEditingController _filiationPrenomNomMereController = TextEditingController();
  final TextEditingController _accompagnantPrenomController = TextEditingController();
  final TextEditingController _accompagnantNomController = TextEditingController();
  final TextEditingController _accompagnantTelController = TextEditingController();


  final _formKey = GlobalKey<FormState>();

  void showError(String message) {
    Get.snackbar(
      "Validation",
      message,
      //backgroundColor: Colors.grey.shade100,
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
        if(_selectedSexe==null){
          showError("Veuillez selectionner le sexe.");
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
        if(_selectedPosVictime == null){
          showError("Veuillez entrer la position du victime.");
          return false;
        }
        break;

      case 2: // Validation de l'état et de la structure sanitaire
        if (_natureBlessureController.text.isEmpty) {
          showError("Veuillez décrire la nature des blessures.");
          return false;
        }
        /*if (_etatVictime == null) {
          showError("Veuillez sélectionner l'état de la victime.");
          return false;
        }*/
        if (_structureSanitaireController.text.isEmpty) {
          showError("Veuillez entrer une structure sanitaire.");
          return false;
        }
        if (_vehicule == null) {
          showError("Veuillez sélectionner un véhicule.");
          return false;
        }
        if (_conscient == null) {
          showError("Veuillez indiquer si la victime est consciente ou non.");
          return false;
        }
        break;

      case 3: // Validation des informations de l'accompagnant
        if (_accompagnantPrenomController.text.isEmpty) {
          showError("Veuillez entrer le prénom de l'accompagnant.");
          return false;
        }
        if (_accompagnantNomController.text.isEmpty) {
          showError("Veuillez entrer le nom de l'accompagnant.");
          return false;
        }
        if (_accompagnantTelController.text.isEmpty && !isValidNumberAccompagnantTel) {
          showError("Veuillez entrer le téléphone de l'accompagnant.");
          return false;
        }
        break;

      case 4: // Validation du numéro PV et des filiations
        if (_filiationPrenomPereController.text.isEmpty) {
          showError("Veuillez entrer le prénom du père.");
          return false;
        }
        if (_filiationPrenomNomMereController.text.isEmpty) {
          showError("Veuillez entrer le nom et prénom de la mère.");
          return false;
        }
        break;

      default:
        break;
    }
    return true;
  }

  void openDialogSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Victime enregistrée avec succès !",
          onPressed: () {
            Get.offAll(() => DetailsAccident(alertId: widget.alertId, initialTab: 2),
                transition: Transition.leftToRight
            );
          },
          onClose: () {
            Get.offAll(() => DetailsAccident(alertId: widget.alertId, initialTab: 2),
                transition: Transition.leftToRight
            );
          },
        );
      },
    );
  }

  Future<void> _fetchDatas() async {
    final db = DatabaseHelper();
    final dataConsIncons = await db.fetchTableDatas("conscient_incocient");
    final dataPosVictime = await db.fetchTableDatas("position_victime");
    final dataVehicules = await db.getVehiculeByAccidentId(widget.accidentId);

    setState(() {
      consIncons = dataConsIncons;
      vehicules = dataVehicules;
      posVictime = dataPosVictime;
    });
  }

  Future<void> saveVictime() async {
    print("Vehicle pour ce victime: $_vehicule");
    // Récupérer les données des steps
    final fiche = FicheAccidentVictime(
      accidentId: widget.accidentId,
      vehicleId: _vehicule,
      prenom: _prenomController.text,
      nom: _nomController.text,
      age: int.tryParse(_ageController.text),
      tel: _telController.text,
      etatVictime: _etatVictime,
      sexe: _selectedSexe,
      structureSanitaireEvac: _structureSanitaireController.text,
      statutGuerison: statutGuerison, // 'e', 'g' ou autre
      dateGuerison: _dateGuerisonController.text.isNotEmpty
          ? DateTime.tryParse(_dateGuerisonController.text)
          : null,
      numPv: _numPvController.text,
      userSaisie: null,
      createdAt: DateTime.now(),
      natureBlessure: _natureBlessureController.text,
      conscientInconscient: _conscient,
      filiationPrenomPere: _filiationPrenomPereController.text,
      filiationPrenomNomMere: _filiationPrenomNomMereController.text,
      accompagnantPrenom: _accompagnantPrenomController.text,
      accompagnantNom: _accompagnantNomController.text,
      accompagnantTel: _accompagnantTelController.text,
      positionVictime: _selectedPosVictime
    );

    // Insérer dans la base de données locale
    final db = DatabaseHelper();
    await db.insertFicheAccidentVictime(fiche);

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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //const Text('État de la victime', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    //const SizedBox(height: 8),
                    /*DropdownButtonFormField<String>(
                      items: ['Blessé', 'Mortel']
                          .map((etat) => DropdownMenuItem(
                        value: etat,
                        child: Text(etat),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _etatVictime = value=='Blessé'?'b':'m';
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),*/
                    //const SizedBox(height: 16),

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

                    const Text('Véhicule', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _vehicule,
                      items: vehicules
                          .map((vehicule) => DropdownMenuItem<int>(
                        value: vehicule['idfiche_accident_vehicule'],
                        child: Text(vehicule['matricule'] ?? 'Inconnu'),
                      ))
                          .toList(),
                      onChanged: (int? value) {
                        setState(() {
                          _vehicule = value; // Met à jour l'ID sélectionné
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Sélectionner un véhicule',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Le victime est-il conscient ?',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<int>(
                                title: const Text('Oui'), // Texte pour "Conscient"
                                value: 35, // Exemple : 35 correspond à "Conscient"
                                groupValue: _conscient,
                                onChanged: (value) {
                                  setState(() {
                                    _conscient = value; // Mettre à jour la valeur
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<int>(
                                title: const Text('Non'), // Texte pour "Inconscient"
                                value: 36, // Exemple : 36 correspond à "Inconscient"
                                groupValue: _conscient,
                                onChanged: (value) {
                                  setState(() {
                                    _conscient = value; // Mettre à jour la valeur
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildAccompagnantStep() {
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
                    Icon(Icons.group, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Accompagnant',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prénom de l\'accompagnant',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _accompagnantPrenomController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le prénom',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Nom de l\'accompagnant',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _accompagnantNomController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le nom',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Téléphone de l\'accompagnant', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      controller: _accompagnantTelController,
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
                        isValidNumberAccompagnantTel = phone.isValidNumber();
                      },
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
                    const Text('Position victime', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedPosVictime,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      hint: const Text('Sélectionnez une option'),
                      items: posVictime
                          .map((item) => DropdownMenuItem<int>(
                        value: item['id'],
                        child: Text(item['libelle']),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosVictime = value;
                        });
                      },
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

  Widget _buildNumPVEtFiliationStep() {
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
                    Icon(Icons.document_scanner, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Numéro PV et filiations',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prénom du père', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _filiationPrenomPereController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le prénom du père',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Nom et prénom de la mère', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _filiationPrenomNomMereController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le nom et prénom de la mère',
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
  void initState() {
    super.initState();
    _fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fiche Accident Victime"),
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
                     : currentStep == 2 ? _buildEtatEtStructureStep()
                     : currentStep == 3 ? _buildAccompagnantStep()
                     :                    _buildNumPVEtFiliationStep()
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