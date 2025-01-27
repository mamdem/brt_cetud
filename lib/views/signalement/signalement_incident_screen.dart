import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/home/home.dart';
import 'package:brt_mobile/widgets/success_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:location/location.dart' as deviceLocation;
import '../../models/alert.dart';
import '../../models/fiche_accident.dart';
import '../../res/constant/app_assets.dart';
import '../../sqflite/database_helper.dart';
import '../../widgets/app_button.dart';
import '../../widgets/damage_item.dart';

class SignalementIncidentScreen extends StatefulWidget {
  const SignalementIncidentScreen({Key? key}) : super(key: key);

  @override
  _SignalementIncidentScreenState createState() => _SignalementIncidentScreenState();
}

class _SignalementIncidentScreenState extends State<SignalementIncidentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int currentStep = 1;
  bool _isLoading = false;

  late double _latitude;
  late double _longitude;
  final int nbStep=3;

  String currentAddress="";

  String? selectedIncidentType;
  String? _selectedAlertLevel;

  String? _selectedRoadType;

  bool isLocationAvailable = false;
  bool _busImplique = false;

  deviceLocation.Location location = deviceLocation.Location();
  late deviceLocation.LocationData _locationData;
  late deviceLocation.PermissionStatus _permissionGranted;

  final TextEditingController agentAssistantController = TextEditingController();
  final TextEditingController matriculeBusController = TextEditingController();

  late bool _serviceEnabled;

  final TextEditingController _consciousController = TextEditingController(text: '0');
  final TextEditingController _unconsciousController = TextEditingController(text: '0');
  bool _hasVictime = false;

  int numberOfVehicles = 0;
  TextEditingController vehicleController = TextEditingController(text: '0');
  TextEditingController collisionController = TextEditingController();

  int get totalVictims {
    int conscious = int.tryParse(_consciousController.text) ?? 0;
    int unconscious = int.tryParse(_unconsciousController.text) ?? 0;
    return conscious + unconscious;
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

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 1:
        if (_selectedAlertLevel == null) {
          showError("Veuillez sélectionner un niveau d'alerte.");
          return false;
        }
        break;

      case 2: // Validation du step "Localisation"
        if (!isLocationAvailable) {
          showError("Veuillez récupérer votre localisation.");
          return false;
        }
        break;


      case 4: // Validation du step "Détails du Bus"
        if (_busImplique && matriculeBusController.text.isEmpty) {
          showError("Veuillez renseigner le matricule du bus.");
          return false;
        }
        break;

      default:
        break;
    }
    return true;
  }

  @override
  void dispose() {
    _consciousController.dispose();
    _unconsciousController.dispose();
    super.dispose();
  }

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
        codeAlert: global.generateAlertCode(),
        typeAlert: 40,
        dateAlert: DateTime.now(),
        userAlert: global.user["idusers"],
        alerteNiveauId: _selectedAlertLevel == "NIVEAU_1"
            ? 1
            : _selectedAlertLevel == "NIVEAU_2"
            ? 2
            : 3,
        positionLat: !_locationData.isNull?_locationData.latitude:null,
        positionLong: !_locationData.isNull?_locationData.longitude:null,
        busOperateurImplique: _busImplique ? 43 : 44,
        matriculeBus: _busImplique ? matriculeBusController.text : null,
        voie: _selectedRoadType == "Corridor" ? 1 : 0,
        existenceVictime: _hasVictime ? 43 : 44,
        nbVictime: _hasVictime ? totalVictims : 0,
        victimeCons: _hasVictime ? int.tryParse(_consciousController.text) ?? 0 : 0,
        victimeIncons: _hasVictime ? int.tryParse(_unconsciousController.text) ?? 0 : 0,
        createdAt: DateTime.now(),
        updatedAt: null
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

  void updateValue(TextEditingController controller, bool increment) {
    int currentValue = int.tryParse(controller.text) ?? 0;
    if (increment) {
      controller.text = (currentValue + 1).toString();
    } else if (currentValue > 0) {
      controller.text = (currentValue - 1).toString();
    }
    setState(() {});  // Pour mettre à jour le total
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
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text('Localisation',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: Colors.grey, size: 20),
                        SizedBox(width: 8),
                        Text('Détails de Localisation',
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
              child: currentStep == 1
                  ? _buildAlertLevelStep()
                  : currentStep == 2
                  ? _buildLocationStep()
                  : _buildBusDetailsStep(),
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
                      backgroundColor: AppColors.appColor,
                    ),
                    child: const Text('Précédent'),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_validateCurrentStep()) {
                      if (currentStep < nbStep) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        saveAlertWithFiche();
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
                  child: currentStep < nbStep
                      ? const Text('Suivant')
                      : const Text('Soumettre'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}