// In a new file named sync_loading_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SyncLoadingService {
  // Simplification: on garde seulement les éléments essentiels
  static bool _isInitialized = false;

  // Initialise le service de loading de façon simple
  static void initialize() {
    // Configuration simplifiée de l'indicateur de chargement
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black87
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;

    _isInitialized = true;

    // Afficher le loading
    _showLoading();
  }

  // Affiche le message de loading simple
  static Future<void> _showLoading() async {
    if (!_isInitialized) {
      initialize();
    }

    if (!EasyLoading.isShow) {
      await EasyLoading.show(
        status: 'Synchronisation en cours...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
        indicator: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      );
    }
  }

  // Mise à jour du message (méthode simplifiée)
  static void updateOperation(String operation) {
    if (!EasyLoading.isShow) {
      _showLoading();
    } else {
      EasyLoading.show(status: 'Synchronisation en cours...');
    }
  }

  // Fermer le loading
  static void dismiss() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    _isInitialized = false;
  }

  // Afficher un dialogue simple de succès
  static Future<void> showSummary() async {
    // S'assurer que le loading est fermé
    if (EasyLoading.isShow) {
      await EasyLoading.dismiss();
    }

    // Double vérification que le loading est bien fermé
    await Future.delayed(Duration(milliseconds: 100));
    if (EasyLoading.isShow) {
      await EasyLoading.dismiss();
    }

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        title: const Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 70,
            ),
            SizedBox(height: 15),
            Text(
              'Succès',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Text(
                  "Synchronisation effectuée avec succès.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Méthode de compatibilité pour l'ancien code
  static void completeStep(String operationSummary,
      {bool hasError = false,
      String errorMessage = '',
      Map<String, dynamic> stats = const {}}) {
    // Simplement rediriger vers updateOperation
    updateOperation(operationSummary);
  }
}
