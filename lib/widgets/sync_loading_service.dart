// In a new file named sync_loading_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SyncLoadingService {
  static final RxString _currentOperation = ''.obs;
  static final RxDouble _progress = 0.0.obs;
  static final RxInt _completedSteps = 0.obs;
  static final RxInt _totalSteps = 0.obs;
  static final RxList<String> _completedOperations = <String>[].obs;
  static final RxBool _hasErrors = false.obs;
  static final RxList<String> _errors = <String>[].obs;

  static void initialize(int totalSteps) {
    _progress.value = 0.0;
    _currentOperation.value = '';
    _completedSteps.value = 0;
    _totalSteps.value = totalSteps;
    _completedOperations.clear();
    _hasErrors.value = false;
    _errors.clear();

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

    _showCustomProgress();
  }

  static void updateOperation(String operation) {
    _currentOperation.value = operation;
    _showCustomProgress();
  }

  static void completeStep(String operationSummary, {bool hasError = false, String errorMessage = ''}) {
    _completedSteps.value++;
    _progress.value = _completedSteps.value / _totalSteps.value;

    if (hasError) {
      _hasErrors.value = true;
      _errors.add('$operationSummary: $errorMessage');
      _completedOperations.add('❌ $operationSummary');
    } else {
      _completedOperations.add('✅ $operationSummary');
    }

    _showCustomProgress();
  }

  static Future<void> _showCustomProgress() async {
    if (!EasyLoading.isShow) {
      EasyLoading.show(status: 'Initialisation...');
    }

    EasyLoading.showProgress(
        _progress.value,
        status: '${(_progress.value * 100).toInt()}% - ${_currentOperation.value}\n'
            'Étape ${_completedSteps.value}/${_totalSteps.value}'
    );
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  static Future<void> showSummary() async {
    EasyLoading.dismiss();

    await Get.dialog(
      AlertDialog(
        title: Text(_hasErrors.value
            ? 'Synchronisation terminée avec des erreurs'
            : 'Synchronisation réussie'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Étapes complétées: ${_completedSteps.value}/${_totalSteps.value}'),
              const SizedBox(height: 10),
              const Text('Récapitulatif:'),
              const SizedBox(height: 5),
              ...List.generate(
                  _completedOperations.length,
                      (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(_completedOperations[index]),
                  )
              ),
              if (_hasErrors.value) ...[
                const SizedBox(height: 10),
                const Text('Erreurs rencontrées:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 5),
                ...List.generate(
                    _errors.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(_errors[index], style: const TextStyle(color: Colors.red)),
                    )
                ),
              ]
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Fermer'),
          ),
          if (_hasErrors.value)
            TextButton(
              onPressed: () {
                Get.back();
                // Vous pourriez ajouter ici la logique pour réessayer les étapes échouées
              },
              child: const Text('Réessayer les étapes échouées'),
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
