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

class CollectAccidentScreen extends StatefulWidget {
  final int alertId;
  const CollectAccidentScreen({Key? key, required this.alertId}) : super(key: key);

  @override
  _CollectAccidentScreenState createState() => _CollectAccidentScreenState();
}

class _CollectAccidentScreenState extends State<CollectAccidentScreen> {
  int currentStep = 1;
  final int nbStep = 4;

  String? errorText;

  final _formKey = GlobalKey<FormState>();

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

  Map<String, dynamic>? _alertDetails;

  String selectedCollisions = "";
  String? mortHommeSelection;
  bool blesseSelection=false;

  TextEditingController dateController = TextEditingController();

  int? _selectedCondition;
  int? _selectedTypeJour;
  int? _selectedVisibilite;
  int? _selectedTypeChaussee;
  int? _selectedSection;

  final collisionEntreController = TextEditingController();
  final agentAssistantController = TextEditingController();
  final nombreVehiculeImplique = TextEditingController();
  final largeurVoieEclairage = TextEditingController();
  final nombreBlesse = TextEditingController();

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

  Widget _buildPhotoField(String label, TextEditingController controller, String? photoPath, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w300)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Description...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        photoPath != null
            ? Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photoPath), // Affiche l'image sélectionnée
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
          ],
        )
            : const SizedBox(),
        ElevatedButton.icon(
          onPressed: () => selectPhoto(type),
          icon: const Icon(Icons.camera_alt),
          label: const Text("Ajouter une photo"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEtatDesLieuxStep() {
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
                    Icon(Icons.add_card_outlined, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Etat des lieux",
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
                  children: [
                    _buildPhotoField(
                      "Trace de freinage :",
                      traceFreinageController,
                      traceFreinagePhoto,
                      "traceFreinage",
                    ),
                    const SizedBox(height: 16),
                    _buildPhotoField(
                      "Trace de sang :",
                      traceSangController,
                      traceSangPhoto,
                      "traceSang",
                    ),
                    const SizedBox(height: 16),
                    _buildPhotoField(
                      "Trace de pneu :",
                      tracePneueController,
                      tracePneuePhoto,
                      "tracePneue",
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

    setState(() {
      sections = dataSections;
      typeJours = dataTypeJours;
      condAtmospheriques = dataCondAts;
      visibilites = dataVisibilites;
      chaussees = dataChaussees;
      sections = dataSections;
      collisions_entre = dataCollisions_entre;
    });
  }

  bool validateCurrentStep() {
    switch (currentStep) {
      case 1:
        if (dateController.text.isEmpty) {
          showError("La date et l'heure de l'accident sont obligatoires.");
          return false;
        }
        if (blesseSelection && (nombreBlesse.text.isEmpty || int.tryParse(nombreBlesse.text) == null)) {
          showError("Veuillez renseigner un nombre valide de victimes.");
          return false;
        }
        if(nombreVehiculeImplique.text.isEmpty){
          showError("Nombre de véhicule est obligatoire.");
          return false;
        }
        if (_selectedTypeJour == null) {
          showError("Veuillez sélectionner un type de jour.");
          return false;
        }
        return true;
      case 2:
        if (_selectedSection == null) {
          showError("Veuillez sélectionner une section.");
          return false;
        }
        if (selectedCollisions.isEmpty) {
          showError("Veuillez sélectionner au moins une collision.");
          return false;
        }
        return true;
      case 3:
        if (_selectedCondition == null) {
          showError("Veuillez sélectionner une condition atmosphérique.");
          return false;
        }
        if (_selectedVisibilite == null) {
          showError("Veuillez sélectionner une visibilité.");
          return false;
        }
        if (_selectedTypeChaussee == null) {
          showError("Veuillez sélectionner un type de chaussée.");
          return false;
        }
        if(largeurVoieEclairage.text.isEmpty){
          showError("Largeur voie éclairage est obligatoire.");
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
      barrierDismissible: false,
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

  Widget _buildCriticalDetailsStep() {
    final rowsTj = _chunk(typeJours, 2);
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
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Informations générales",
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

                    const SizedBox(height: 12,),
                    const Text(
                      "Date et Heure de l'accident :",
                        style: TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      cursorColor: AppColors.appColor,
                      readOnly: true,
                      controller: dateController,
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

                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: now.isAfter(alertDate) ? now : alertDate,
                              firstDate: alertDate,
                              lastDate: now,
                              locale: const Locale('fr'),
                            );

                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(now),
                              );

                              if (pickedTime != null) {
                                final DateTime pickedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );

                                String formattedDateTime = pickedDateTime.toIso8601String();
                                dateController.text = formattedDateTime;
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
                    SizedBox(height: 8,),
                    const Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    SizedBox(height: 8,),

                    //Agent assistant
                    const Text('Agent assistant :',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      //maxLines: 3,
                      controller: agentAssistantController,
                      decoration: InputDecoration(
                        hintText: 'Nom complet ?',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),

                    //Existance et nombre de victimes
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
                            borderSide: errorText == null
                                ? BorderSide(color: Colors.grey) // Bordure normale
                                : BorderSide(color: Colors.red), // Bordure rouge si erreur
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: errorText == null
                                ? BorderSide(color: AppColors.appColor) // Bordure normale quand sélectionné
                                : BorderSide(color: Colors.yellow), // Bordure rouge si erreur
                          ),
                          helperText: errorText, // Affichage du message d'erreur
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              if (_alertDetails!['nb_victime'] < int.parse(value)) {
                                errorText = "Attention! ${(_alertDetails!['nb_victime'])} victime(s) a été signalée dans cette alerte";
                              } else {
                                errorText = null; // Supprime l'erreur si la valeur est correcte
                              }
                            } else {
                              errorText = null; // Supprime l'erreur si le champ est vide
                            }
                          });
                        },
                      )
                    ],
                    const SizedBox(height: 12,),

                    //Nombre de véhicule impliqué
                    SizedBox(height: 8,),
                    const Text(
                      "Nombre de véhicule impliquée :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: AppColors.appColor,
                      controller: nombreVehiculeImplique,
                      decoration: InputDecoration(
                        hintText: 'Nombre ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      
                    ),
                    const SizedBox(height: 12,),

                    Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    SizedBox(height: 12,),
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

  Widget _buildSectionCollisionStep() {
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
                    Icon(Icons.warning_amber, color: Colors.deepOrange, size: 24),
                    SizedBox(width: 8),
                    Text('Collision ?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  const Text(
                    'Collision entre :',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: collisions_entre.map((collision) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 50) / 2, // Largeur pour 2 colonnes
                        child: CheckboxListTile(
                          title: Text(collision['libelle'] ?? 'Inconnu'),
                          value: selectedCollisions.split(', ').contains(collision['id'].toString()),
                          onChanged: (isChecked) {
                            setState(() {
                              List<String> collisions = selectedCollisions.isNotEmpty
                                  ? selectedCollisions.split(', ')
                                  : [];

                              if (isChecked == true) {
                                // Ajouter l'ID s'il n'est pas déjà dans la liste
                                if (!collisions.contains(collision['id'].toString())) {
                                  collisions.add(collision['id'].toString());
                                }
                              } else {
                                // Supprimer l'ID de la liste
                                collisions.remove(collision['id'].toString());
                              }

                              // Mettre à jour la chaîne `selectedCollisions`
                              selectedCollisions = collisions.join(', ');
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }).toList(),
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

  Widget _buildConditionAtmospheriqueStep() {
    final rowsAtm = _chunk(condAtmospheriques, 2);
    final rowsVis = _chunk(visibilites, 2);
    final rowsChau = _chunk(chaussees, 2);
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
                    Icon(Icons.add_card_outlined, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Etat des lieux",
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
                    //Conditions atmosphériques
                    const Text(
                      "Condition Atmosphérique :",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: rowsAtm
                          .map(
                            (rowConditions) => Row(
                          children: rowConditions
                              .map(
                                (condition) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _selectedCondition = condition['id'];
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedCondition == condition['id']
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    condition['libelle'],
                                    style: TextStyle(
                                      color: _selectedCondition == condition['id']
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

                    SizedBox(height: 8,),
                    Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    const SizedBox(height: 8),

                    //Visibilité
                    const Text(
                      "Visibilité :",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: rowsVis
                          .map(
                            (rowVisibilites) => Row(
                          children: rowVisibilites
                              .map(
                                (visibilite) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _selectedVisibilite = visibilite['id'];
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedVisibilite == visibilite['id']
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    visibilite['libelle'],
                                    style: TextStyle(
                                      color: _selectedVisibilite == visibilite['id']
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

                    SizedBox(height: 8,),
                    Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    SizedBox(height: 8,),

                    //Chaussée
                    const Text(
                      "Chaussée :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: rowsChau
                          .map(
                            (rowChaussees) => Row(
                          children: rowChaussees
                              .map(
                                (chaussee) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _selectedTypeChaussee = chaussee['id'];
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedTypeChaussee == chaussee['id']
                                        ? Colors.blue
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    chaussee['libelle'],
                                    style: TextStyle(
                                      color: _selectedTypeChaussee == chaussee['id']
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

                    const Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    const SizedBox(height: 8,),

                    //Largeur eclairage voie
                    const Text (
                      "Largeur voie éclairage :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      cursorColor: AppColors.appColor,
                      controller: largeurVoieEclairage,
                      decoration: InputDecoration(
                        hintText: 'Largeur voie éclairage',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                    ),
                    const SizedBox(height: 12,),

                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> saveFicheAccidentUpdated() async {
    if (!validateCurrentStep()) return;
    int result = await DatabaseHelper().insertAccident({
      "signalement_id": widget.alertId,
      "date_heure": DateTime.now().toIso8601String(),
      "section_id": _selectedSection,
      "largeur_eclairage_voie":  int.parse(largeurVoieEclairage.text),
      "collision_entre": selectedCollisions,
      "position_lat": _alertDetails!["position_lat"],
      "position_long": _alertDetails!["position_long"],
      "point_reference_lat": _alertDetails!["position_lat"],
      "point_reference_long": _alertDetails!["position_long"],
      "blesse_oui_non":  blesseSelection?1:0,
      "nb_blesse": (nombreBlesse.text=="" || nombreBlesse.text==null)?0 : int.parse(nombreBlesse.text),
      "nb_vehicule_implique": int.parse(nombreVehiculeImplique.text),
      "condition_atmospherique": _selectedCondition,
      "agent_assistant": agentAssistantController.text,
      "type_jour": _selectedTypeJour,
      "user_saisie": global.user['idusers'],
      "user_update": null,
      "user_delete": null,
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": null,
      "corridor_hor_co": _alertDetails!["voie"],
      "deleted_at": null,
      "visibilite": _selectedVisibilite,
      "chaussee": _selectedTypeChaussee,
      "bus_operateur_impli_oui_non": _alertDetails!["bus_operateur_implique"],
      "id_server": null,
      "signalement_id_server": _alertDetails!["id_server"],
      // Nouveaux champs pour "État des lieux"
      "trace_freinage": traceFreinageController.text,
      "trace_freinage_photo": traceFreinagePhoto,
      "trace_sang": traceSangController.text,
      "trace_sang_photo": traceSangPhoto,
      "trace_pneue": tracePneueController.text,
      "trace_pneue_photo": tracePneuePhoto,
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
          saveFicheAccidentUpdated();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collecte Accident"),
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
                child: currentStep == 1 ? _buildCriticalDetailsStep()
                     : currentStep == 2 ? _buildSectionCollisionStep()
                     : currentStep == 3 ? _buildConditionAtmospheriqueStep()
                     :                    _buildEtatDesLieuxStep()
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