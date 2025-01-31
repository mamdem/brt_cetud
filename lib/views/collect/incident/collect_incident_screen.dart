import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../sqflite/database_helper.dart';
import '../../../widgets/success_alert.dart';
import 'package:intl/intl.dart';

class CollectIncidentScreen extends StatefulWidget {
  final int alertId;
  const CollectIncidentScreen({Key? key, required this.alertId}) : super(key: key);

  @override
  _CollectIncidentScreenState createState() => _CollectIncidentScreenState();
}

class _CollectIncidentScreenState extends State<CollectIncidentScreen> {
  int currentStep = 1;
  final int nbStep = 3;

  final _formKey = GlobalKey<FormState>();

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Nouvelles variables pour "État des lieux"
  TextEditingController traceFreinageController = TextEditingController();
  String? traceFreinagePhoto;

  TextEditingController traceSangController = TextEditingController();
  String? traceSangPhoto;

  TextEditingController tracePneueController = TextEditingController();
  String? tracePneuePhoto;

  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> condAtmospheriques = [];
  List<Map<String, dynamic>> typeJours = [];
  List<Map<String, dynamic>> visibilites = [];
  List<Map<String, dynamic>> chaussees = [];
  List<Map<String, dynamic>> collisions_entre = [];
  List<Map<String, dynamic>> typesIncident = [];
  List<Map<String, dynamic>> ouinons = [];

  Map<String, dynamic>? _alertDetails;

  String selectedCollisions = "";
  String? mortHommeSelection;
  bool blesseSelection=false;
  bool interruptionService=false;

  TextEditingController dateController = TextEditingController();

  int? _selectedCondition;
  int? _selectedTypeJour;
  int? _selectedVisibilite;
  int? _selectedTypeChaussee;
  int? _selectedSection;
  int? _selectedTypeIncident;

  final collisionEntreController = TextEditingController();
  final agentAssistantController = TextEditingController();
  final nombreVehiculeImplique = TextEditingController();
  final largeurVoieEclairage = TextEditingController();
  final nombreBlesse = TextEditingController();
  final dateRepriseController = TextEditingController();
  final dateIncidentController = TextEditingController();
  final libelleIncident = TextEditingController();


  Future<void> selectPhoto(String type) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      if (type == "traceFreinage") {
                        traceFreinagePhoto = pickedFile.path;
                      } else if (type == "traceSang") {
                        traceSangPhoto = pickedFile.path;
                      } else if (type == "tracePneue") {
                        tracePneuePhoto = pickedFile.path;
                      }
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      if (type == "traceFreinage") {
                        traceFreinagePhoto = pickedFile.path;
                      } else if (type == "traceSang") {
                        traceSangPhoto = pickedFile.path;
                      } else if (type == "tracePneue") {
                        tracePneuePhoto = pickedFile.path;
                      }
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchAlertDetails() async {
    final db = DatabaseHelper();
    final alert = await db.getAlertById(widget.alertId);
    setState(() {
      _alertDetails = alert;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAlertDetails();
    _fetchDatas();
    loadDraft();
  }

  @override
  void dispose() {
    saveDraft();
    super.dispose();
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();

    // Supprimer uniquement les données liées à l'alerte en cours
    await prefs.remove('currentStep${widget.alertId}');
    await prefs.remove('traceFreinage${widget.alertId}');
    await prefs.remove('traceFreinagePhoto${widget.alertId}');
    await prefs.remove('traceSang${widget.alertId}');
    await prefs.remove('traceSangPhoto${widget.alertId}');
    await prefs.remove('tracePneue${widget.alertId}');
    await prefs.remove('tracePneuePhoto${widget.alertId}');
    await prefs.remove('selectedCollisions${widget.alertId}');
    await prefs.remove('blesseSelection${widget.alertId}');
    await prefs.remove('nombreVehiculeImplique${widget.alertId}');
    await prefs.remove('largeurVoieEclairage${widget.alertId}');
    await prefs.remove('nombreBlesse${widget.alertId}');
    await prefs.remove('dateController${widget.alertId}');
    await prefs.remove('selectedCondition${widget.alertId}');
    await prefs.remove('selectedTypeJour${widget.alertId}');
    await prefs.remove('selectedVisibilite${widget.alertId}');
    await prefs.remove('selectedChaussee${widget.alertId}');
    await prefs.remove('selectedSection${widget.alertId}');

    setState(() {
      currentStep = 1;
      traceFreinageController.clear();
      traceFreinagePhoto = null;
      traceSangController.clear();
      traceSangPhoto = null;
      tracePneueController.clear();
      tracePneuePhoto = null;
      selectedCollisions = "";
      blesseSelection = false;
      nombreVehiculeImplique.clear();
      largeurVoieEclairage.clear();
      nombreBlesse.clear();
      dateController.clear();
      _selectedCondition = null;
      _selectedTypeJour = null;
      _selectedVisibilite = null;
      _selectedTypeChaussee = null;
      _selectedSection = null;
    });

    print("Draft for alert ID ${widget.alertId} cleared.");
  }

  Future<void> saveDraft() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('currentStep${widget.alertId}', currentStep);

    await prefs.setString('traceFreinage${widget.alertId}', traceFreinageController.text);
    await prefs.setString('traceFreinagePhoto${widget.alertId}', traceFreinagePhoto ?? "");
    await prefs.setString('traceSang${widget.alertId}', traceSangController.text);
    await prefs.setString('traceSangPhoto${widget.alertId}', traceSangPhoto ?? "");
    await prefs.setString('tracePneue${widget.alertId}', tracePneueController.text);
    await prefs.setString('tracePneuePhoto${widget.alertId}', tracePneuePhoto ?? "");
    await prefs.setString('selectedCollisions${widget.alertId}', selectedCollisions);
    await prefs.setBool('blesseSelection${widget.alertId}', blesseSelection);
    await prefs.setString('nombreVehiculeImplique${widget.alertId}', nombreVehiculeImplique.text);
    await prefs.setString('largeurVoieEclairage${widget.alertId}', largeurVoieEclairage.text);
    await prefs.setString('nombreBlesse${widget.alertId}', nombreBlesse.text);
    await prefs.setString('dateController${widget.alertId}', dateController.text);

    await prefs.setInt('selectedCondition${widget.alertId}', _selectedCondition ?? -1);
    await prefs.setInt('selectedTypeJour${widget.alertId}', _selectedTypeJour ?? -1);
    await prefs.setInt('selectedVisibilite${widget.alertId}', _selectedVisibilite ?? -1);
    await prefs.setInt('selectedChaussee${widget.alertId}', _selectedTypeChaussee ?? -1);
    await prefs.setInt('selectedSection${widget.alertId}', _selectedSection ?? -1);

    print("Draft saved successfully.");
  }

  Future<void> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Restaurer l'étape actuelle
      currentStep = prefs.getInt('currentStep${widget.alertId}') ?? 1;

      // Restaurer les données des champs
      traceFreinageController.text = prefs.getString('traceFreinage${widget.alertId}') ?? "";
      traceFreinagePhoto = prefs.getString('traceFreinagePhoto${widget.alertId}');
      traceSangController.text = prefs.getString('traceSang${widget.alertId}') ?? "";
      traceSangPhoto = prefs.getString('traceSangPhoto${widget.alertId}');
      tracePneueController.text = prefs.getString('tracePneue${widget.alertId}') ?? "";
      tracePneuePhoto = prefs.getString('tracePneuePhoto${widget.alertId}');
      selectedCollisions = prefs.getString('selectedCollisions${widget.alertId}') ?? "";
      blesseSelection = prefs.getBool('blesseSelection${widget.alertId}') ?? false;
      nombreVehiculeImplique.text = prefs.getString('nombreVehiculeImplique${widget.alertId}') ?? "";
      largeurVoieEclairage.text = prefs.getString('largeurVoieEclairage${widget.alertId}') ?? "";
      nombreBlesse.text = prefs.getString('nombreBlesse${widget.alertId}') ?? "";
      dateController.text = prefs.getString('dateController${widget.alertId}') ?? "";

      // Restaurer les sélections
      _selectedCondition = prefs.getInt('selectedCondition${widget.alertId}') == -1 ? null : prefs.getInt('selectedCondition${widget.alertId}');
      _selectedTypeJour = prefs.getInt('selectedTypeJour${widget.alertId}') == -1 ? null : prefs.getInt('selectedTypeJour${widget.alertId}');
      _selectedVisibilite = prefs.getInt('selectedVisibilite${widget.alertId}') == -1 ? null : prefs.getInt('selectedVisibilite${widget.alertId}');
      _selectedTypeChaussee = prefs.getInt('selectedChaussee${widget.alertId}') == -1 ? null : prefs.getInt('selectedChaussee${widget.alertId}');
      _selectedSection = prefs.getInt('selectedSection${widget.alertId}') == -1 ? null : prefs.getInt('selectedSection${widget.alertId}');
    });

    print("Draft loaded successfully.");
  }

  List<List<Map<String, dynamic>>> _chunk(List<Map<String, dynamic>> list, int chunkSize) {
    List<List<Map<String, dynamic>>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  Future<void> _fetchDatas() async {
    final db = DatabaseHelper();
    final dataSections = await db.fetchTableDatas("sections");
    final dataTypeJours = await db.fetchTableDatas("type_jour");
    final dataCondAts = await db.fetchTableDatas("conditon_atmostpherique");
    final dataVisibilites = await db.fetchTableDatas("visibilite");
    final dataChaussees = await db.fetchTableDatas("chausse");
    final dataCollisions_entre = await db.fetchTableDatas("collision_entre");
    final dataTypeIncident = await db.fetchTableDatas("type_incident");
    final dataOuiNons = await db.fetchTableDatas("oui_non");

    setState(() {
      sections = dataSections;
      typeJours = dataTypeJours;
      condAtmospheriques = dataCondAts;
      visibilites = dataVisibilites;
      chaussees = dataChaussees;
      sections = dataSections;
      collisions_entre = dataCollisions_entre;
      typesIncident = dataTypeIncident;
      ouinons = dataOuiNons;
    });
  }

  bool validateCurrentStep() {
    switch (currentStep) {
      case 1: // Validation de l'étape _buildInfosIncident
        if (_selectedTypeIncident == null) {
          showError("Veuillez sélectionner un type d'incident.");
          return false;
        }
        if (libelleIncident.text.isEmpty) {
          showError("Le libellé de l'incident est obligatoire.");
          return false;
        }
        if (dateIncidentController.text.isEmpty) {
          showError("La date et l'heure de l'incident sont obligatoires.");
          return false;
        }
        return true;

      case 2: // Validation de l'étape _buildCondition
        if (_selectedSection == null) {
          showError("Veuillez sélectionner une section.");
          return false;
        }
        if (_selectedTypeJour == null) {
          showError("Veuillez sélectionner un type de jour.");
          return false;
        }
        return true;

      case 3: // Validation de l'étape _buildDetailsCritique
        if (blesseSelection && (nombreBlesse.text.isEmpty || int.tryParse(nombreBlesse.text) == null)) {
          showError("Veuillez renseigner un nombre valide de victimes.");
          return false;
        }
        if (interruptionService && dateRepriseController.text.isEmpty) {
          showError("Veuillez sélectionner une date de reprise si le service est interrompu.");
          return false;
        }
        return true;

      default:
        return true;
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

  void updateValue(TextEditingController controller, bool increment) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (increment) {
      controller.text = (currentValue + 1).toString();
    } else if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
    setState(() {});  // Pour mettre à jour le total
  }

  void showSuccess(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Fiche accident enregistrée avec succès !",
          onPressed: () {
            Get.offAll(const HomeScreen(), transition: Transition.leftToRight);
          },
          onClose: () {
            Get.offAll(const HomeScreen(), transition: Transition.leftToRight);
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

  Widget _buildInfosIncident() {
    final rowsTI = _chunk(typesIncident, 2);
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
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Informations incident",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    //Type incident
                    const Text(
                      "Type Incident :",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    Column(
                      children: rowsTI
                          .map(
                            (rowTypesIncident) => Row(
                              children: rowTypesIncident
                              .map(
                              (typeIncident) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _selectedTypeIncident = typeIncident['id'];
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedTypeIncident == typeIncident['id']
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    typeIncident['libelle'],
                                    style: TextStyle(
                                      color: _selectedTypeIncident == typeIncident['id']
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ).toList(),
                    ),
                    const SizedBox(height: 12,),

                    //Libellé
                    const Text(
                      "Libellé incident:",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      cursorColor: AppColors.appColor,
                      controller: libelleIncident,
                      decoration: InputDecoration(
                        hintText: 'Libellé incident',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                    ),
                    const SizedBox(height: 14,),

                    //Date et heure
                    const Text(
                      "Date et heure de l'incident:",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      cursorColor: AppColors.appColor,
                      readOnly: true,
                      controller: dateIncidentController,
                      decoration: InputDecoration(
                        hintText: 'jj/mm/aaaa HH:mm',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        if (_alertDetails != null && _alertDetails!['date_alert'] != null) {
                          final DateTime? alertDate = DateTime.tryParse(_alertDetails!['date_alert']);
                          if (alertDate != null) {
                            final DateTime now = DateTime.now();

                            // Sélectionner la date
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: now.isAfter(alertDate) ? now : alertDate,
                              firstDate: alertDate,
                              lastDate: DateTime(2100),
                              locale: const Locale('fr'),
                            );

                            if (pickedDate != null) {
                              // Sélectionner l'heure
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(now),
                              );

                              if (pickedTime != null) {
                                final DateTime finalDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                dateIncidentController.text = dateTimeFormat.format(finalDateTime);
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Date d\'alerte invalide.')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Les détails de l\'alerte sont indisponibles.')),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 8,),
                    const Text(
                      "Sélection entre la date d'alerte et la date d'aujourd'hui",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 14,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCondition() {
    final rowsTj = _chunk(typeJours, 2);
    final rowsSect = _chunk(sections, 2);
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
                    Icon(Icons.wb_sunny, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Section & Type jour",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                    //Section
                    const Text(
                      "Section :",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedSection, // La valeur sélectionnée
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
                      hint: const Text('Sélectionnez une section'),
                      items: rowsSect
                          .expand((rowSections) => rowSections)
                          .map<DropdownMenuItem<int>>((section) {
                        return DropdownMenuItem<int>(
                          value: section['id'],
                          child: Text(section['libelle']),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedSection = newValue!; // Met à jour la section sélectionnée
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    //Type jour
                    const Text(
                      "Type de jour :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: rowsTj
                          .map(
                            (rowTypeJours) => Row(
                          children: rowTypeJours
                              .map(
                                (typeJour) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _selectedTypeJour = typeJour['id'];
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedTypeJour == typeJour['id']
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    typeJour['libelle'],
                                    style: TextStyle(
                                      color: _selectedTypeJour == typeJour['id']
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                      )
                          .toList(),
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

  Widget _buildDetailsCritique() {
    final rowsON = _chunk(ouinons, 2);
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
                    Icon(Icons.warning_amber, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Détails critiques ?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12,),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            "Existence victime",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => blesseSelection = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blesseSelection
                                        ? Colors.orange
                                        : Colors.white,
                                    elevation: 0,
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Oui",
                                    style: TextStyle(
                                      color: blesseSelection
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => blesseSelection = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !blesseSelection
                                        ? Colors.blue
                                        : Colors.white,
                                    elevation: 0,
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Non",
                                    style: TextStyle(
                                      color: !blesseSelection
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if(blesseSelection)...[
                      const SizedBox(height: 8),
                      const Text(
                        "Nombre de victime:",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        cursorColor: AppColors.appColor,
                        controller: nombreBlesse,
                        decoration: InputDecoration(
                          hintText: 'Nombre de victime',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                      ),
                    ],
                    const SizedBox(height: 12,),
                    const Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    const SizedBox(height: 12,),

                    //Interruption service
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            "Interruption Service",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => interruptionService = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: interruptionService
                                        ? Colors.orange
                                        : Colors.white,
                                    elevation: 0,
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Oui",
                                    style: TextStyle(
                                      color: interruptionService
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      setState(() => interruptionService = false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: !interruptionService
                                        ? Colors.blue
                                        : Colors.white,
                                    elevation: 0,
                                    side: BorderSide(color: Colors.grey[300]!),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Non",
                                    style: TextStyle(
                                      color: !interruptionService
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12,),
                    //Date Reprise
                    if(interruptionService)...[
                      const Text(
                        "Date reprise :",
                        style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        cursorColor: AppColors.appColor,
                        readOnly: true,
                        controller: dateRepriseController,
                        decoration: InputDecoration(
                          hintText: 'jj/mm/aaaa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          if (_alertDetails != null && _alertDetails!['date_alert'] != null) {
                            final DateTime? alertDate = DateTime.tryParse(_alertDetails!['date_alert']);
                            if (alertDate != null) {
                              final DateTime now = DateTime.now();

                              // Sélectionner la date
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: now.isAfter(alertDate) ? now : alertDate,
                                firstDate: alertDate,
                                lastDate: DateTime(2100),
                                locale: const Locale('fr'),
                              );

                              if (pickedDate != null) {
                                dateRepriseController.text = dateFormat.format(pickedDate);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Date d\'alerte invalide.')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Les détails de l\'alerte sont indisponibles.')),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 14,),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> saveFicheIncidentUpdated() async {
    if (!validateCurrentStep()) return;
    int result = await DatabaseHelper().insertIncident({
      "signalement_id": widget.alertId,
      "type_incident_id": _selectedTypeIncident,
      "libelle": libelleIncident.text,
      "date_heure": dateIncidentController.text.isEmpty
          ? null
          : dateTimeFormat.format(dateTimeFormat.parse(dateIncidentController.text)),
      "section_id": _selectedSection,
      "position_lat": _alertDetails!["position_lat"],
      "position_long": _alertDetails!["position_long"],
      "blesse":  blesseSelection?1:0,
      "nb_blesse": (nombreBlesse.text=="" || nombreBlesse.text==null)?0 : int.parse(nombreBlesse.text),
      "type_jour": _selectedTypeJour,
      "interruption_service": interruptionService?1:0,
      "date_reprise": dateRepriseController.text.isEmpty
          ? null
          : dateFormat.format(dateFormat.parse(dateRepriseController.text)),
      "user_id": global.user['idusers'],
      "user_saisie": global.user['idusers'],
      "user_update": null,
      "user_delete": null,
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": null,
      "voie_corridor_oui_non": _alertDetails!["voie"],
      "deleted_at": null,
      "bus_operateur_implique": _alertDetails!["bus_operateur_implique"],
      "id_server": null,
      "signalement_id_server": _alertDetails!["id_server"],
    });

    if (result > 0) {
      showSuccess();
      clearDraft();
    } else {
      print("Aucune ligne n'a été modifiée.");
    }
  }

  void proceedToNextStep() {
    if (validateCurrentStep()) {
      setState(() {
        if (currentStep < nbStep) {
          currentStep++;
        } else {
          saveFicheIncidentUpdated();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collecte Incident"),
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
                  child: currentStep == 1 ? _buildInfosIncident()
                       : currentStep == 2 ? _buildCondition()
                       :                    _buildDetailsCritique()
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