import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:location/location.dart' as deviceLocation;

import '../../../core/utils/google_fonts.dart';
import '../../../models/fiche_accident_vehicule.dart';
import '../../../sqflite/database_helper.dart';
import '../../../widgets/success_alert.dart';

class CollectAccidentVehiculeScreen extends StatefulWidget {
  final int accidentId;
  const CollectAccidentVehiculeScreen({Key? key, required this.accidentId}) : super(key: key);

  @override
  _CollectAccidentVehiculeScreenState createState() => _CollectAccidentVehiculeScreenState();
}

class _CollectAccidentVehiculeScreenState extends State<CollectAccidentVehiculeScreen> {
  int currentStep = 1;
  final int nbStep = 10;

  bool isValidNumber=false;
  String? _ageErrorText;
  String? _widthErrorText;
  String? _heightErrorText;
  String? _longErrorText;
  String? _puissanceErrorText;


  List<Map<String, dynamic>> catVehicules = [];
  List<Map<String, dynamic>> foncNonfonc = [];
  List<Map<String, dynamic>> sexes = [];
  List<Map<String, dynamic>> comportements = [];
  List<Map<String, dynamic>> ouinons = [];

  String? _selectedCategorie;
  int? _selectedCategorieId;
  String? _selectedComportement;
  int? _selectedComportementId;

  // Contrôleurs pour le véhicule
  final _matriculeController = TextEditingController();
  final _carteGriseController = TextEditingController();
  final _autreInfoController = TextEditingController();

  // Contrôleurs pour le chauffeur
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();
  final _telController = TextEditingController();

  final _largeurController = TextEditingController();
  final _longueurController = TextEditingController();
  final _hauteurController = TextEditingController();
  String ? _selectedSexe;


  final TextEditingController _numeroPermisController = TextEditingController();
  final TextEditingController _dateDelivrancePermisController = TextEditingController();
  int? _selectedCategoriePermisId;
  final TextEditingController _numeroAssuranceController = TextEditingController();
  final TextEditingController _assureurController = TextEditingController();
  final TextEditingController _dateExpirationAssuranceController = TextEditingController();
  final TextEditingController _etatGeneraleController = TextEditingController();
  final TextEditingController _dateMiseCirculationController = TextEditingController();
  final TextEditingController _dateDerniereVisiteController = TextEditingController();
  final TextEditingController _dateExpirationVisiteController = TextEditingController();
  final TextEditingController _professionConducteurController = TextEditingController();
  final TextEditingController _filiationPrenomNomMereController = TextEditingController();
  final TextEditingController _filiationPrenomPereController = TextEditingController();
  final TextEditingController _domicileConducteurController = TextEditingController();
  final TextEditingController _dateImmatriculationVehiculeController = TextEditingController();
  final TextEditingController _prenomNomProprietaireController = TextEditingController();
  final TextEditingController _autresComportementController = TextEditingController();
  final TextEditingController _etatParebriseController = TextEditingController();
  final TextEditingController _etatPneueAvantController = TextEditingController();
  final TextEditingController _etatPneueArriereController = TextEditingController();
  final TextEditingController _puissanceVehiculeController = TextEditingController();
  final TextEditingController _positionLevierVitessController = TextEditingController();
  final TextEditingController _kilometrageController = TextEditingController();
  final TextEditingController _positionVolumeController = TextEditingController();

  // Dropdown variables
  int? _selectedPresencePosteRadio;
  int? _selectedEclairage;
  int? _selectedAvertisseur;
  int? _selectedIndicateurDirection;
  int? _selectedIndicateurVitesse;
  int? _selectedEssuieGlace;
  int? _selectedRetroviseur;

  // Clé pour le formulaire
  final _formKey = GlobalKey<FormState>();

  Future<void> _fetchDatas() async {
    final db = DatabaseHelper();
    final dataCatVehicule = await db.fetchTableDatas("categorie_vehicule");
    final dataFoncNonFOnc = await db.fetchTableDatas("etat_equipment");
    final datasexes = await db.fetchTableDatas("GENRE");
    final dataComportements = await db.fetchTableDatas("comportement_conducteur");
    final dataOuinons = await db.fetchTableDatas("OUI_NON");

    setState(() {
      catVehicules = dataCatVehicule;
      foncNonfonc = dataFoncNonFOnc;
      sexes = datasexes;
      comportements = dataComportements;
      ouinons = dataOuinons;
    });
  }

  void showSuccess(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Fiche accident enregistrée avec succès !",
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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

  Widget _buildDriverInfoStep() {
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
                    Text('Conducteur',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(title: 'Prénom', controller: _prenomController),
                    _buildTextField(title: 'Nom', controller: _nomController),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "Âge",
                        border: const OutlineInputBorder(),
                        errorText: _ageErrorText, // Affiche le message d'erreur si nécessaire
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            final age = int.tryParse(value);
                            if (age == null || age < 1 || age > 120) {
                              _ageErrorText = "L'âge doit être entre 1 et 120";
                            } else {
                              _ageErrorText = null; // Pas d'erreur si l'âge est valide
                            }
                          } else {
                            _ageErrorText = "L'âge est obligatoire"; // Gestion si vide
                          }
                        });
                      },
                    ),
                    ),
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
                    _buildTextField(
                        title: 'Domicile du conducteur', controller: _domicileConducteurController),
                    _buildTextField(
                        title: 'Profession du conducteur', controller: _professionConducteurController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverFamilyInfoStep() {
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
                    Icon(Icons.family_restroom, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Informations familiales',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        title: 'Filiation (Prénom et nom du père)',
                        controller: _filiationPrenomPereController),
                    _buildTextField(
                        title: 'Filiation (Prénom et nom de la mère)',
                        controller: _filiationPrenomNomMereController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseInfoStep() {
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
                    Icon(Icons.card_membership, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Informations sur le permis',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(title: 'Numéro du permis', controller: _numeroPermisController),
                    const Text(
                      "Date délivrance permis:",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    _buildDatePickerField(controller: _dateDelivrancePermisController, ),
                    const SizedBox(height: 16),
                    const Text('date dernière visite', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    _buildDatePickerField(
                      controller: _dateDerniereVisiteController,
                    ),
                    const SizedBox(height: 16),
                    const Text('Date mise circulation', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    _buildDatePickerField(
                      controller: _dateMiseCirculationController,
                    ),
                    const SizedBox(height: 16),
                    const Text('Date d\'expiration visite', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      cursorColor: AppColors.appColor,
                      readOnly: true,
                      controller: _dateExpirationVisiteController,
                      decoration: InputDecoration(
                        hintText: 'jj/mm/aaaa --:--',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateDerniereVisiteController.text.isNotEmpty?DateTime.tryParse(_dateDerniereVisiteController.text)!:DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: _dateDerniereVisiteController.text.isNotEmpty?DateTime.tryParse(_dateDerniereVisiteController.text)!:DateTime.now(),
                          locale: const Locale('fr'),
                        );

                        if (pickedDate != null) {
                          final DateTime pickedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                          );

                          String formattedDateTime = pickedDateTime.toIso8601String();

                          _dateExpirationVisiteController.text = formattedDateTime;
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(height: 10,),
                    const Text(
                      "Catégorie permis:",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCategorie,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      hint: const Text('Sélectionnez la catégorie'),
                      items: catVehicules.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                        return DropdownMenuItem<String>(
                          value: item['libelle'], // Libellé affiché
                          child: Text(item['libelle']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategorie = newValue;
                          _selectedCategorieId = catVehicules
                              .firstWhere((item) => item['libelle'] == newValue)['id'];
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

  Widget _buildOwnerInfoStep() {
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
                    Icon(Icons.person_outline, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Propriétaire',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                        title: 'Prénom et nom du propriétaire',
                        controller: _prenomNomProprietaireController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoStep() {
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
                    Icon(Icons.car_repair, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Informations sur le véhicule',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(title: 'Matricule', controller: _matriculeController),
                    _buildTextField(title: 'Numéro de carte grise', controller: _carteGriseController),
                    DropdownButtonFormField<String>(
                      value: _selectedCategorie,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      hint: const Text('Sélectionnez la catégorie'),
                      items: catVehicules.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                        return DropdownMenuItem<String>(
                          value: item['libelle'], // Libellé affiché
                          child: Text(item['libelle']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategorie = newValue;
                          _selectedCategorieId = catVehicules
                              .firstWhere((item) => item['libelle'] == newValue)['id'];
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

  Widget _buildVehicleDimensionsStep() {
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
                    Icon(Icons.straighten, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Dimensions du véhicule',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _largeurController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Autorise jusqu'à deux décimales
                        ],
                        decoration: InputDecoration(
                          labelText: "Largeur (en m)",
                          border: const OutlineInputBorder(),
                          errorText: _puissanceErrorText, // Affiche le message d'erreur si nécessaire
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              final width = double.tryParse(value);
                              if (width == null || width < 1 || width > 4) {
                                _puissanceErrorText = "La largeur doit être entre 1 et 4 mètres";
                              } else {
                                _puissanceErrorText = null; // Pas d'erreur si la largeur est valide
                              }
                            } else {
                              _puissanceErrorText = "La largeur est obligatoire"; // Gestion si vide
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _hauteurController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Hauteur (en m)",
                          border: const OutlineInputBorder(),
                          errorText: _heightErrorText, // Affiche le message d'erreur si nécessaire
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              final width = double.tryParse(value);
                              if (width == null || width < 1 || width > 6) {
                                _heightErrorText = "La hauteur doit être entre 1 et 6 mètres";
                              } else {
                                _heightErrorText = null; // Pas d'erreur si la largeur est valide
                              }
                            } else {
                              _heightErrorText = "La heuteur est obligatoire"; // Gestion si vide
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _longueurController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Autorise jusqu'à deux décimales
                        ],
                        decoration: InputDecoration(
                          labelText: "Longueur (en m)",
                          border: const OutlineInputBorder(),
                          errorText: _longErrorText, // Affiche le message d'erreur si nécessaire
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              final width = double.tryParse(value);
                              if (width == null || width < 1 || width > 25) {
                                _longErrorText = "La longueur doit être entre 1 et 25 mètres";
                              } else {
                                _longErrorText = null; // Pas d'erreur si la largeur est valide
                              }
                            } else {
                              _longErrorText = "La longueur est obligatoire"; // Gestion si vide
                            }
                          });
                        },
                      ),
                    ),
                    _buildNumberField(title: 'Kilométrage (en km)', controller: _kilometrageController),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        controller: _puissanceVehiculeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')), // Autorise jusqu'à deux décimales
                        ],
                        decoration: InputDecoration(
                          labelText: "Puissance (en Ch)",
                          border: const OutlineInputBorder(),
                          errorText: _widthErrorText, // Affiche le message d'erreur si nécessaire
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              final width = double.tryParse(value);
                              if (width == null || width < 1 || width > 1000) {
                                _widthErrorText = "La puissance doit être entre 1 et 1000 Ch";
                              } else {
                                _widthErrorText = null;
                              }
                            } else {
                              _widthErrorText = "La puissance est obligatoire"; // Gestion si vide
                            }
                          });
                        },
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

  Widget _buildEquipmentStateStep() {
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
                    Icon(Icons.car_repair, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('État des équipements',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(title: 'État des pneus avant', controller: _etatPneueAvantController),
                    _buildTextField(title: 'État des pneus arrière', controller: _etatPneueArriereController),
                    _buildTextField(title: 'État du pare-brise', controller: _etatParebriseController),
                    _buildTextField(title: 'État général', controller: _etatGeneraleController),
                    _buildNumberField(title: 'Position levier de vitesse', controller: _positionLevierVitessController),
                    SizedBox(height: 8,),
                    const Text('Présence Poste Radio',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    DropdownButtonFormField<int>(
                      value: _selectedPresencePosteRadio,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      hint: const Text('Sélectionnez une option'),
                      items: ouinons
                          .map((item) => DropdownMenuItem<int>(
                        value: item['id'],
                        child: Text(item['libelle']),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPresencePosteRadio = value;
                        });
                      },
                    ),
                    SizedBox(height: 15,),
                    if(_selectedPresencePosteRadio==43)
                    _buildNumberField(title: 'Position volume', controller: _positionVolumeController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentFunctionalityStep() {
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
                    Icon(Icons.settings, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Fonctionnalités',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownField(
                      title: 'Avertisseur',
                      value: _selectedAvertisseur,
                      onChanged: (value) {
                        setState(() {
                          _selectedAvertisseur = value;
                        });
                      },
                    ),
                    _buildDropdownField(
                      title: 'Indicateur de direction',
                      value: _selectedIndicateurDirection,
                      onChanged: (value) {
                        setState(() {
                          _selectedIndicateurDirection = value;
                        });
                      },
                    ),
                    _buildDropdownField(
                      title: 'Indicateur de vitesse',
                      value: _selectedIndicateurVitesse,
                      onChanged: (value) {
                        setState(() {
                          _selectedIndicateurVitesse = value;
                        });
                      },
                    ),
                    _buildDropdownField(
                      title: 'Essuie-glace',
                      value: _selectedEssuieGlace,
                      onChanged: (value) {
                        setState(() {
                          _selectedEssuieGlace = value;
                        });
                      },
                    ),
                    _buildDropdownField(
                      title: 'Rétroviseur',
                      value: _selectedRetroviseur,
                      onChanged: (value) {
                        setState(() {
                          _selectedRetroviseur = value;
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

  Widget _buildInsuranceStep() {
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
                    Icon(Icons.security, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Informations sur l’assurance',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12,),
                    const Text('Numéro d\'assurance',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    _buildTextField(title: 'Numéro d’assurance', controller: _numeroAssuranceController),
                    SizedBox(height: 12,),
                    const Text('Assureur',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    _buildTextField(title: 'Assureur', controller: _assureurController),
                    SizedBox(height: 12,),
                    const Text('Date expiration assurance',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextField(
                      cursorColor: AppColors.appColor,
                      readOnly: true,
                      controller: _dateExpirationAssuranceController,
                      decoration: InputDecoration(
                        hintText: 'jj/mm/aaaa --:--',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2900),
                          locale: const Locale('fr'),
                        );

                        if (pickedDate != null) {
                          final DateTime pickedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                          );

                          String formattedDateTime = pickedDateTime.toIso8601String();

                          _dateExpirationAssuranceController.text = formattedDateTime;
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
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
                    Icon(Icons.info, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text('Infos supplémentaires',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comportement chauffeur',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedComportement,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      hint: const Text('Sélectionnez un comportement'),
                      items: comportements.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                        return DropdownMenuItem<String>(
                          value: item['libelle'], // Libellé affiché
                          child: Text(item['libelle']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedComportement = newValue;
                          _selectedComportementId = catVehicules
                              .firstWhere((item) => item['libelle'] == newValue)['id']; // Enregistre l'ID correspondant
                        });
                      },
                    ),
                    SizedBox(height: 16,),
                    const Text('Autres comportement',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    _buildTextField(title: 'Autres comportements', controller: _autresComportementController),
                    SizedBox(height: 16,),
                    const Text('Autres informations',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    _buildTextField(title: 'Autres informations', controller: _autreInfoController),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String title, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildNumberField({required String title, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required TextEditingController controller, bool useCurrentDateAsLast = true}) {
    return TextField(
      cursorColor: AppColors.appColor,
      readOnly: true,
      controller: controller,
      decoration: InputDecoration(
        hintText: 'jj/mm/aaaa --:--',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: useCurrentDateAsLast ? DateTime(1900) : DateTime.now(),
          lastDate: useCurrentDateAsLast ? DateTime.now():DateTime(2900),
          locale: const Locale('fr'),
        );

        if (pickedDate != null) {
          final DateTime pickedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
          );

          String formattedDateTime = pickedDateTime.toIso8601String();

          controller.text = formattedDateTime;
        }
      },
    );
  }

  Widget _buildDropdownField({
    required String title,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          hint: const Text('Sélectionnez une option'),
          items: foncNonfonc
              .map((item) => DropdownMenuItem<int>(
            value: item['id'],
            child: Text(item['libelle']),
          ))
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _saveFicheAccidentVehicule() async {
      final fiche = FicheAccidentVehicule(
        accidentId: widget.accidentId,
        matricule: _matriculeController.text,
        numCarteGrise: _carteGriseController.text.isEmpty ? null : _carteGriseController.text,
        categorieVehicule: _selectedCategorieId ?? 0,
        autreVehicule: _autreInfoController.text.isEmpty ? null : _autreInfoController.text,
        autreInformationAdd: _autreInfoController.text,

        prenomChauffeur: _prenomController.text,
        nomChauffeur: _nomController.text,
        age: _ageController.text.isEmpty ? 0 : int.parse(_ageController.text),
        sexe: _selectedSexe??'M',
        telChauffeur: _telController.text,
        etatParebrise: _etatParebriseController.text,
        numeroPermis: _numeroPermisController.text.isEmpty ? null : _numeroPermisController.text,
        dateDelivrancePermis: _dateDelivrancePermisController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateDelivrancePermisController.text),
        categoriePermis: _selectedCategoriePermisId,
        numeroAssurance: _numeroAssuranceController.text.isEmpty ? null : _numeroAssuranceController.text,
        assureur: _assureurController.text.isEmpty ? null : _assureurController.text,
        dateExpirationAssurance: _dateExpirationAssuranceController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateExpirationAssuranceController.text),
        etatGenerale: _etatGeneraleController.text,
        kilometrage: _kilometrageController.text!=""? int.parse(_kilometrageController.text):0,
        hauteurVeh: int.parse(_hauteurController.text),
        longueurVeh: int.parse(_longueurController.text),
        largeurVeh: int.parse(_largeurController.text),
        dateMiseCirculation: _dateMiseCirculationController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateMiseCirculationController.text),
        dateDerniereVisite: _dateDerniereVisiteController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateDerniereVisiteController.text),
        dateExpirationVisite: _dateExpirationVisiteController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateExpirationVisiteController.text),
        eclairage: _selectedEclairage.toString(),
        avertisseur: _selectedAvertisseur.toString(),
        indicateurDirection: _selectedIndicateurDirection.toString(),
        indicateurVitesse: _selectedIndicateurVitesse.toString(),
        essuieGlace: _selectedEssuieGlace.toString(),
        retroviseur: _selectedRetroviseur.toString(),
        etatPneueAvant: _etatPneueAvantController.text,
        etatPneueArriere: _etatPneueArriereController.text,
        positionLevierVitesse: _positionLevierVitessController.text,
        presencePosteRadio: _selectedPresencePosteRadio??44,
        positionVolume: (_positionVolumeController.text.isNotEmpty)
            ? int.tryParse(_positionVolumeController.text)
            : null,

        // Champs supplémentaires
        professionConducteur: _professionConducteurController.text,
        filiationPrenomNomMere: _filiationPrenomNomMereController.text,
        filiationPrenomPere: _filiationPrenomPereController.text,
        domicileConducteur: _domicileConducteurController.text,
        dateImmatriculationVehicule: _dateImmatriculationVehiculeController.text.isEmpty
            ? null
            : DateTime.tryParse(_dateImmatriculationVehiculeController.text),
        comportementConducteur: _selectedComportementId.toString(),
        prenomNomProprietaire: _prenomNomProprietaireController.text,
        puissanceVehicule: _puissanceVehiculeController.text.isEmpty
            ? 0
            : int.parse(_puissanceVehiculeController.text),
        autresComportement: _autresComportementController.text,
      );

      // Sauvegarder dans la base de données
      final db = DatabaseHelper();
      int result = await db.insertFicheAccidentVehicule(fiche);

      if (result > 0) {
        showSuccess();
      } else {
        print("Aucune ligne n'a été modifiée.");
      }

  }

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
      case 1: // Validation des informations du conducteur
        if (_prenomController.text.isEmpty) {
          showError("Veuillez entrer le prénom du conducteur.");
          return false;
        }
        if (_nomController.text.isEmpty) {
          showError("Veuillez entrer le nom du conducteur.");
          return false;
        }
        if(_selectedSexe==null){
          showError("Veuillez selectionner le sexe.");
          return false;
        }
        if (_ageController.text.isEmpty || int.tryParse(_ageController.text) == null) {
          showError("Veuillez entrer un âge valide.");
          return false;
        }
        if (_telController.text.isEmpty || !isValidNumber) {
          showError("Veuillez entrer un numéro de téléphone valide.");
          return false;
        }
        if (_domicileConducteurController.text.isEmpty) {
          showError("Veuillez entrer le domicile du conducteur.");
          return false;
        }
        if (_professionConducteurController.text.isEmpty) {
          showError("Veuillez entrer la profession du conducteur.");
          return false;
        }
        break;

      case 2: // Validation des informations familiales
        if (_filiationPrenomPereController.text.isEmpty) {
          showError("Veuillez entrer le prénom et le nom du père.");
          return false;
        }
        if (_filiationPrenomNomMereController.text.isEmpty) {
          showError("Veuillez entrer le prénom et le nom de la mère.");
          return false;
        }
        break;

      case 3: // Validation des informations du propriétaire
        if (_prenomNomProprietaireController.text.isEmpty) {
          showError("Veuillez entrer le prénom et le nom du propriétaire.");
          return false;
        }
        break;

      case 4: // Validation des informations sur le permis
        if (_numeroPermisController.text.isEmpty) {
          showError("Veuillez entrer le numéro de permis.");
          return false;
        }
        if (_selectedCategorie == null) {
          showError("Veuillez sélectionner une catégorie de permis.");
          return false;
        }
        break;

      case 5: // Validation des informations du véhicule
        if (_matriculeController.text.isEmpty) {
          showError("Veuillez entrer le matricule du véhicule.");
          return false;
        }
        if (_carteGriseController.text.isEmpty) {
          showError("Veuillez entrer le numéro de carte grise.");
          return false;
        }
        if (_selectedCategorie == null) {
          showError("Veuillez sélectionner une catégorie de véhicule.");
          return false;
        }
        break;

      case 6: // Validation des dimensions du véhicule
        if (_largeurController.text.isEmpty || double.tryParse(_largeurController.text) == null) {
          showError("Veuillez entrer une largeur valide.");
          return false;
        } else if ((double.parse(_largeurController.text)) < 1 || (double.parse(_largeurController.text)) > 4) {
          showError("La largeur doit etre entre 1 et 4 m.");
          return false;
        }
        if (_hauteurController.text.isEmpty || double.tryParse(_hauteurController.text) == null) {
          showError("Veuillez entrer une hauteur valide.");
          return false;
        }else if((double.parse(_hauteurController.text)) < 1 || (double.parse(_hauteurController.text)) > 6){
          showError("La hauteur doit etre entre 1 et 6m.");
          return false;
        }
        if (_longueurController.text.isEmpty || double.tryParse(_longueurController.text) == null) {
          showError("Veuillez entrer une longueur valide.");
          return false;
        } else if ((double.parse(_longueurController.text)) < 1 || (double.parse(_longueurController.text)) > 25) {
          showError("La longueur doit être entre 1 et 25m.");
          return false;
        }
        if (_kilometrageController.text.isEmpty || int.tryParse(_kilometrageController.text) == null) {
          showError("Veuillez entrer un kilométrage valide.");
          return false;
        }
        if (_puissanceVehiculeController.text.isEmpty || int.tryParse(_puissanceVehiculeController.text) == null) {
          showError("Veuillez entrer une puissance valide.");
          return false;
        }else if((double.parse(_puissanceVehiculeController.text)) < 1 || (double.parse(_puissanceVehiculeController.text)) > 1000){
          showError("La puissance doit etre entre 1 et 1000Ch.");
          return false;
        }
        break;

      case 7: // Validation de l'état des équipements
        if (_etatPneueAvantController.text.isEmpty) {
          showError("Veuillez indiquer l’état des pneus avant.");
          return false;
        }
        if (_etatPneueArriereController.text.isEmpty) {
          showError("Veuillez indiquer l’état des pneus arrière.");
          return false;
        }
        if (_etatParebriseController.text.isEmpty) {
          showError("Veuillez indiquer l’état du pare-brise.");
          return false;
        }
        if (_positionLevierVitessController.text.isEmpty || int.tryParse(_positionLevierVitessController.text) == null) {
          showError("Veuillez indiquer une position valide pour le levier de vitesse.");
          return false;
        }
        break;

      case 8: // Validation des fonctionnalités des équipements
        if (_selectedAvertisseur == null) {
          showError("Veuillez sélectionner un état pour l’avertisseur.");
          return false;
        }
        if (_selectedIndicateurDirection == null) {
          showError("Veuillez sélectionner un état pour l’indicateur de direction.");
          return false;
        }
        if (_selectedIndicateurVitesse == null) {
          showError("Veuillez sélectionner un état pour l’indicateur de vitesse.");
          return false;
        }
        if (_selectedEssuieGlace == null) {
          showError("Veuillez sélectionner un état pour l’essuie-glace.");
          return false;
        }
        if (_selectedRetroviseur == null) {
          showError("Veuillez sélectionner un état pour le rétroviseur.");
          return false;
        }
        break;

      case 9: // Validation des informations sur l’assurance
        if (_numeroAssuranceController.text.isEmpty) {
          showError("Veuillez entrer le numéro d’assurance.");
          return false;
        }
        if (_assureurController.text.isEmpty) {
          showError("Veuillez entrer le nom de l’assureur.");
          return false;
        }
        break;

      default:
        break;
    }
    return true;
  }

  void proceedToNextStep() {
    if (validateCurrentStep()) {
      setState(() {
        if (currentStep < nbStep) {
          currentStep++;
        } else {
          _saveFicheAccidentVehicule();
        }
      });
    }
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
        title: const Text("Fiche Accident Véhicule"),
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
                child: currentStep == 1 ? _buildDriverInfoStep()
                    : currentStep == 2 ? _buildDriverFamilyInfoStep()
                    : currentStep == 3 ? _buildOwnerInfoStep()
                    : currentStep == 4 ? _buildLicenseInfoStep()
                    : currentStep == 5 ? _buildVehicleInfoStep()
                    : currentStep == 6 ? _buildVehicleDimensionsStep()
                    : currentStep == 7 ? _buildEquipmentStateStep()
                    : currentStep == 8 ? _buildEquipmentFunctionalityStep()
                    : currentStep == 9 ? _buildInsuranceStep()
                    :                    _buildAdditionalInfoStep(),
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
                    onPressed: proceedToNextStep,
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