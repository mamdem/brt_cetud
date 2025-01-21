import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:location/location.dart' as deviceLocation;
import '../../models/alert.dart';
import '../../models/fiche_accident.dart';
import '../../res/common/app_text_field.dart';
import '../../res/constant/app_assets.dart';
import '../../sqflite/database_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/damage_item.dart';
import '../../widgets/success_alert.dart';

class SignalementIncidentScreen extends StatefulWidget {
  const SignalementIncidentScreen({Key? key}) : super(key: key);

  @override
  _SignalementIncidentScreenState createState() => _SignalementIncidentScreenState();
}

class _SignalementIncidentScreenState extends State<SignalementIncidentScreen> {
  int currentStep = 1;

  bool _isLoading=false;
  late double _latitude;
  late double _longitude;


  late bool _serviceEnabled;
  final int nbStep=3;

  String? selectedIncidentType;
  String? _selectedAlertLevel;

  String? mortHommeSelection;
  String? blesseSelection;

  String? _selectedRoadType;
  String currentAddress="";
  bool _busImplique = false;

  String _selectedCondition = 'Soleil';
  String _selectedDayType = 'Jour';
  deviceLocation.Location location = deviceLocation.Location();
  late deviceLocation.LocationData _locationData;
  late deviceLocation.PermissionStatus _permissionGranted;

  final TextEditingController _consciousController = TextEditingController(text: '0');
  final TextEditingController _unconsciousController = TextEditingController(text: '0');
  final TextEditingController agentAssistantController = TextEditingController();
  final TextEditingController matriculeBusController = TextEditingController();

  bool _hasMaterialDamage = false;
  bool _hasVictime = false;
  List<DamageItem> _damages = [];

  bool isLocationAvailable = false;
  int numberOfVehicles = 0;
  TextEditingController vehicleController = TextEditingController(text: '0');
  TextEditingController collisionController = TextEditingController();

  Future<void> getLocationData() async{
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == deviceLocation.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != deviceLocation.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  void _updateVehicleCount(int change) {
    numberOfVehicles += change;
    if (numberOfVehicles < 0) numberOfVehicles = 0;
    vehicleController.text = numberOfVehicles.toString();
  }

  void openDialogSuccess(){
    showDialog(
      context: context,
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

  void saveAlertWithFiche() async {
    final db = DatabaseHelper();

    // Préparer les données de l'alerte
    final alert = Alerte(
      codeAlert: selectedIncidentType,
      typeAlert: 2,
      dateAlert: DateTime.now(),
      alerteNiveauId: _selectedAlertLevel == "NIVEAU_1"
          ? 1
          : _selectedAlertLevel == "NIVEAU_2"
          ? 2
          : 3,
      positionLat: _locationData.latitude,
      positionLong: _locationData.longitude,
      busOperateurImplique: _busImplique ? 1 : 0,
      matriculeBus: _busImplique ? matriculeBusController.text : null,
      voie: _selectedRoadType == "Corridor" ? 1 : 2,
      createdAt: DateTime.now(),
    );

    // Insérer l'alerte
    final alertMap = alert.toMap();
    final alertId = await db.insertAlert(alertMap);

    if (alertId > 0) {
        openDialogSuccess();
    } else {
      Get.snackbar("Erreur", "Échec de l'enregistrement de l'alerte.");
    }
  }

  void _addNewDamage() {
    setState(() {
      _damages.add(DamageItem(
        onRemove: (damage) {
          setState(() {
            _damages.remove(damage);
          });
        },
      ));
    });
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

  int get totalVictims {
    int conscious = int.tryParse(_consciousController.text) ?? 0;
    int unconscious = int.tryParse(_unconsciousController.text) ?? 0;
    return conscious + unconscious;
  }

  TextEditingController dateController = TextEditingController();

  /*bool _isStepValid() {
    switch (currentStep) {
      case 1:
        if (_selectedAlertLevel == null) {
          return false;
        }
        break;

      case 2:
        if (mortHommeSelection == null || blesseSelection == null) {
          return false;
        }
        break;

      case 3:
        if (_selectedRoadType == null) {
          return false;
        }
        break;

      case 4:
        if (_selectedAlertLevel == null) {
          return false;
        }
        break;

      case 6:
        if (_busImplique && (dateController.text.isEmpty || dateController.text == '')) {
          return false;
        }
        break;
    }
    return true;
  }*/

  Widget _buildSelectionButton(String text, bool isSelected, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => updateValue(controller, false),
            color: Colors.red,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Pour mettre à jour le total
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => updateValue(controller, true),
            color: Colors.green,
          ),
        ],
      ),
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

  Widget _buildIncidentTypeStep() {
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
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[400]),
                    const SizedBox(width: 8),
                    const Text(
                      "Type d'Incident",
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
                    _buildIncidentTypeButton(
                      "Accident",
                      Colors.red[50]!,
                      Icons.warning,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildIncidentTypeButton(
                      "Incident",
                      Colors.yellow[50]!,
                      Icons.info_outline,
                      Colors.orange,
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

  Widget _buildCriticalDetailsStep() {
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
                      "Détails Critiques",
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
                    const Text(
                      "Situation Critique",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            "Mort d'Homme",
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
                                      setState(() => mortHommeSelection = "Oui"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mortHommeSelection == "Oui"
                                        ? Colors.red
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
                                      color: mortHommeSelection == "Oui"
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
                                      setState(() => mortHommeSelection = "Non"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mortHommeSelection == "Non"
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
                                      color: mortHommeSelection == "Non"
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            "Blessé",
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
                                      setState(() => blesseSelection = "Oui"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blesseSelection == "Oui"
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
                                      color: blesseSelection == "Oui"
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
                                      setState(() => blesseSelection = "Non"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blesseSelection == "Non"
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
                                      color: blesseSelection == "Non"
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
                    const SizedBox(height: 20),
                    const Text(
                      "Date et Heure de l'Incident",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      cursorColor: AppColors.appColor,
                      readOnly: true,
                      controller: dateController,
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
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          String formattedDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          // You can also add time selection if needed
                          // String formattedDateTime = '$formattedDate --:--';
                          // controller.text = formattedDateTime;
                          dateController.text = formattedDate;
                        }
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

  Widget _buildAlertLevelStep() {
    return  Column(
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
                child: Row(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber, color: Colors.deepOrange, size: 24),
                        SizedBox(width: 8),
                        Text('Niveau alert', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildAlertOption(
                      context,
                      setState,
                      "Situation d'urgence",
                      Colors.yellow,
                      "NIVEAU_1",
                    ),
                    const SizedBox(height: 8),
                    _buildAlertOption(
                      context,
                      setState,
                      "Situation d'urgence pouvant évoluer en crise",
                      Color(0xFFFFA500), // Orange
                      "NIVEAU_2",
                    ),
                    const SizedBox(height: 8),
                    _buildAlertOption(
                      context,
                      setState,
                      "Situation Catastrophique",
                      Colors.red,
                      "NIVEAU_3",
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

  Widget _buildAlertOption(BuildContext context, StateSetter setState, String text, Color color, String value) {
    bool isSelected = _selectedAlertLevel == value;

    return InkWell(
      onTap: () => setState(() => _selectedAlertLevel = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected? Colors.blue[50]: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
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
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    const Text('Localisation',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text('Détails de Localisation',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Type de Voie',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedRoadType = 'Corridor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedRoadType == 'Corridor'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Corridor',
                                style: TextStyle(
                                  color: _selectedRoadType == 'Corridor'
                                      ? Colors.white
                                      : Colors.black87,
                                )),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedRoadType = 'Hors Corridor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedRoadType == 'Hors Corridor'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Hors Corridor',
                                style: TextStyle(
                                  color: _selectedRoadType == 'Hors Corridor'
                                      ? Colors.white
                                      : Colors.black87,
                                )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Lieu Précis',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 12),
                    /*if(isLocationAvailable)
                      Center(
                        child: FutureBuilder<String>(
                          future: getAddressFromLatLong(_locationData.latitude!, _locationData.longitude!, 1), // Exemple de latitude, longitude et paramètre `n`
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Affiche un indicateur de chargement pendant que la donnée est en cours de récupération
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // Affiche un message en cas d'erreur
                              return Text(
                                "Erreur: ${snapshot.error}",
                                style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w500),
                              );
                            } else if (snapshot.hasData) {
                              // Affiche l'adresse une fois récupérée
                              return Text(
                                snapshot.data!,
                                style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
                              );
                            } else {
                              // Cas par défaut si aucune donnée n'est disponible
                              return Text(
                                "Adresse non disponible",
                                style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                              );
                            }
                          },
                        ),
                      ),*/
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null // Désactiver le bouton pendant le chargement
                          : () async {
                        setState(() {
                          _isLoading = true; // Commencer le chargement
                        });

                        try {
                          await getLocationData();

                          // Récupérer les données de localisation
                          _latitude = _locationData.latitude!;
                          _longitude = _locationData.longitude!;

                          // Obtenir l'adresse
                          currentAddress = await global.getAddressFromLatLong(
                            _latitude,
                            _longitude,
                            2,
                          );

                          setState(() {
                            isLocationAvailable = true; // Marquer la position comme disponible
                          });
                        } catch (e) {
                          print("Erreur : $e");
                        } finally {
                          setState(() {
                            _isLoading = false; // Arrêter le chargement
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.black87,
                        ),
                      )
                          : Text(
                        isLocationAvailable ? currentAddress : 'Cliquer pour prendre votre position',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    if (isLocationAvailable && _latitude != null && _longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Latitude: $_latitude\nLongitude: $_longitude',
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
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

  Widget _buildBusDetailsStep() {
    return  Column(
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
                child: Row(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.directions_bus, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text('Détails du Bus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.directions_bus_outlined, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Implication du Bus', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Bus DKM Impliqué', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _busImplique = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _busImplique ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Oui', style: TextStyle(color: _busImplique ? Colors.white : Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _busImplique = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_busImplique ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Non', style: TextStyle(color: !_busImplique ? Colors.white : Colors.black87)),
                          ),
                        ),
                      ],
                    ),
                    if (_busImplique) ...[
                      const SizedBox(height: 16),
                      const Text('Matricule du Bus', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: matriculeBusController,
                        decoration: InputDecoration(
                          hintText: "Numéro d'identification du bus",
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
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentAssistantStep() {
    return  Column(
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
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text('Agent assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entrer l\'agent assistant; s\'il y en a ?', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 18),
                    TextField(
                      controller: agentAssistantController,
                      decoration: const InputDecoration(
                        labelText: 'Agent assistant',
                        hintText: 'Saisissez ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.appColor, // Couleur de la bordure
                            width: 2.0, // Épaisseur de la bordure
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.appColor, // Bordure pour l'état non sélectionné
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          borderSide: BorderSide(
                            color: Colors.yellow, // Bordure pour l'état sélectionné
                            width: 2.5,
                          ),
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

  Widget _buildIncidentTypeButton(String title, Color backgroundColor, IconData icon, Color? iconColor) {
    bool isSelected = selectedIncidentType == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIncidentType = title;
        });
        print(selectedIncidentType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : iconColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMortStep() {
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

                    Icon(Icons.personal_injury, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      "Victimes ?",
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
                    const Text('Y a t-il un victime ?', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _hasVictime = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasVictime ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Oui', style: TextStyle(color: _hasVictime ? Colors.white : Colors.black87)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _hasVictime = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !_hasVictime ? Colors.blue : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Non', style: TextStyle(color: !_hasVictime ? Colors.white : Colors.black87)),
                          ),
                        ),
                      ],
                    ),
                    if(_hasVictime)...[
                      const SizedBox(height: 10,),
                      const Divider(height: 10),
                      _buildCounterRow('Victimes conscientes', _consciousController),
                      _buildCounterRow('Victimes inconscientes', _unconsciousController),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Total: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              totalVictims.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildVehicleImplAndCollisionEntreStep() {

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
                    Icon(Icons.bus_alert, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Véhicules impliqués ?",
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
                    // Nombre de véhicules impliqués
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nombre de véhicules impliqués :",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => _updateVehicleCount(-1),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                            ),
                            Expanded(
                              //width: 100,
                              child: TextFormField(
                                controller: vehicleController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                readOnly: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  setState(() {}); // Pour mettre à jour le total
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _updateVehicleCount(1),
                              icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Collision entre
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Collision entre :",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: TextFormField(
                            controller: collisionController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(),
                                isDense: true,
                                hintText: "Exemple : Véhicule et Moto"
                            ),
                            onChanged: (value) {
                              setState(() {}); // Pour mettre à jour le total
                            },
                          ),
                        )
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

  Widget _buildConditionAtmospheriqueStep() {
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
                      "Condition Atmosphérique",
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
                    const Text(
                      "Condition Atmosphérique :",
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedCondition = 'Soleil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCondition == 'Soleil'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Soleil',
                              style: TextStyle(
                                color: _selectedCondition == 'Soleil'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedCondition = 'Pluie'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCondition == 'Pluie'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Pluie',
                              style: TextStyle(
                                color: _selectedCondition == 'Pluie'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedCondition = 'Brouillard'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCondition == 'Brouillard'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Brouillard',
                              style: TextStyle(
                                color: _selectedCondition == 'Brouillard'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    Divider(
                      color: Colors.grey, // Couleur de la ligne
                      thickness: 0.5,       // Épaisseur de la ligne
                    ),
                    SizedBox(height: 12,),
                    const Text(
                      "Type de jour :",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedDayType = 'Jour'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedDayType == 'Jour'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Jour',
                              style: TextStyle(
                                color: _selectedDayType == 'Jour'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _selectedDayType = 'Nuit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedDayType == 'Nuit'
                                  ? Colors.blue
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Nuit',
                              style: TextStyle(
                                color: _selectedDayType == 'Nuit'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
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



  @override
  void dispose() {
    _consciousController.dispose();
    _unconsciousController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signalement Incident"),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              child: currentStep == 1 ? _buildAlertLevelStep() //NIveau alerte
                  //: currentStep == 2 ? _buildCriticalDetailsStep() //
                  : currentStep == 2 ? _buildLocationStep()
                  //: currentStep == 3 ? _buildConditionAtmospheriqueStep()
                  //: currentStep == 5 ? _buildVehicleImplAndCollisionEntreStep()
                  //: currentStep == 6 ? _buildMortStep()
                  //: currentStep == 7 ? _buildAgentAssistantStep()
                  :                    _buildBusDetailsStep(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 1)
                  ElevatedButton(
                    onPressed: () {{
                      setState(() {
                        currentStep--;
                      });
                    }
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
                    /*if (!_isStepValid()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez remplir toutes les informations requises avant de continuer.")),
                      );
                      return;
                    }*/

                    if (currentStep < nbStep) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      saveAlertWithFiche();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: AppColors.appColor,
                  ),
                  child: currentStep < nbStep ? const Text('Suivant') : const Text('Soumettre'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}