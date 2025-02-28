import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:brt_mobile/core/utils/app_colors.dart';
import '../../../sqflite/database_helper.dart';
import '../../home/home.dart';
import '../../../widgets/success_alert.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;

class CollectIncidentDegatMaterielsScreen extends StatefulWidget {
  final int incidentId;
  const CollectIncidentDegatMaterielsScreen({Key? key, required this.incidentId}) : super(key: key);

  @override
  _CollectIncidentDegatMaterielsScreenState createState() =>
      _CollectIncidentDegatMaterielsScreenState();
}

class _CollectIncidentDegatMaterielsScreenState extends State<CollectIncidentDegatMaterielsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _libelleController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _imagePicker = ImagePicker();

  void openDialogSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BeautifulSuccessAlert(
          message: "Dégâts matériels enregistrés avec succès !",
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

  Future<void> saveDegatsMateriels() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter une photo des dégâts.")),
      );
      return;
    }

    // Création de l'objet pour les dégâts matériels
    final degatsMateriels = {
      "incident_id": widget.incidentId,
      "libelle_materiels": _libelleController.text,
      "photos": _selectedImage!.path,
      "user_saisie": global.user['idusers'],
      "created_at": DateTime.now().toIso8601String(),
    };

    final db = DatabaseHelper();
    await db.insertIncidentDegatsMateriels(degatsMateriels);

    openDialogSuccess();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo des Dégâts',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Prendre une photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choisir depuis la galerie'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : const Center(
              child: Text(
                'Appuyez pour ajouter une photo',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDegatMaterielForm() {
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
                    Icon(Icons.car_crash, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text('Dégâts Matériels',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Libellé Matériel',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _libelleController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le libellé du matériel',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le libellé du matériel';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
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
        title: const Text("Incident Dégâts Matériels"),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDegatMaterielForm(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      saveDegatsMateriels();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: AppColors.appColor,
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
