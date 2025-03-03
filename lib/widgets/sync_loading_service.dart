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
  static final RxMap<String, int> _syncStats = <String, int>{}.obs;
  static final RxBool _hasErrors = false.obs;
  static final RxList<String> _errors = <String>[].obs;

  static void initialize(int totalSteps) {
    _progress.value = 0.0;
    _currentOperation.value = '';
    _completedSteps.value = 0;
    _totalSteps.value = totalSteps;
    _completedOperations.clear();
    _syncStats.clear();
    _hasErrors.value = false;
    _errors.clear();

    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
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

  static void completeStep(String operationSummary, {bool hasError = false, String errorMessage = '', Map<String, int> stats = const {}}) {
    _completedSteps.value++;
    _progress.value = _completedSteps.value / _totalSteps.value;

    if (hasError) {
      _hasErrors.value = true;
      _errors.add('$operationSummary: $errorMessage');
      _completedOperations.add('❌ $operationSummary');
    } else {
      _completedOperations.add('✅ $operationSummary');
    }

    // Mettre à jour les statistiques de synchronisation
    stats.forEach((key, value) {
      if (_syncStats.containsKey(key)) {
        _syncStats[key] = (_syncStats[key] ?? 0) + value;
      } else {
        _syncStats[key] = value;
      }
    });

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

  static Future<void> showSummary({Map<String, int> stats = const {}}) async {
    EasyLoading.dismiss();

    // Mettre à jour les statistiques avec celles fournies en paramètre
    stats.forEach((key, value) {
      if (_syncStats.containsKey(key)) {
        _syncStats[key] = (_syncStats[key] ?? 0) + value;
      } else {
        _syncStats[key] = value;
      }
    });
    
    // Filtrer pour ne garder que les opérations avec éléments synchronisés
    final filteredOperations = _completedOperations
        .where((operation) => !operation.contains("Aucun") && operation.contains("✅"))
        .toList();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          children: [
            Icon(
              _hasErrors.value ? Icons.warning_amber_rounded : Icons.check_circle,
              color: _hasErrors.value ? Colors.orange : Colors.green,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              _hasErrors.value
                  ? 'Synchronisation terminée avec des alertes'
                  : 'Synchronisation réussie',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              Text(
                'Étapes complétées: ${_completedSteps.value}/${_totalSteps.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // Vérifier si des éléments ont été synchronisés
              _hasSyncedItems() 
                ? _buildStatsCard()
                : Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info_outline, size: 30, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Aucune donnée n'a été synchronisée",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 15),
              if (filteredOperations.isNotEmpty) ...[
                const Text('Détails:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...List.generate(
                  filteredOperations.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filteredOperations[index].substring(0, 2)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            filteredOperations[index].substring(2),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_hasErrors.value) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Erreurs rencontrées:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        _errors.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _errors[index],
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Fonction pour vérifier si des éléments ont été synchronisés
  static bool _hasSyncedItems() {
    return _syncStats.entries
        .where((entry) => entry.value > 0 && !entry.key.toLowerCase().contains('responsable'))
        .isNotEmpty;
  }

  static Widget _buildStatsCard() {
    // Liste des entrées filtrées pour le résumé
    final filteredEntries = _syncStats.entries
        .where((entry) => entry.value > 0 && !entry.key.toLowerCase().contains('responsable'))
        .toList();
        
    if (filteredEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.info_outline, size: 30, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Aucune donnée n'a été synchronisée",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé de la synchronisation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...filteredEntries.map((entry) {
            final IconData icon = _getIconForCategory(entry.key);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  static IconData _getIconForCategory(String category) {
    if (category.toLowerCase().contains('alert')) {
      return Icons.notifications;
    } else if (category.toLowerCase().contains('accident')) {
      return Icons.car_crash;
    } else if (category.toLowerCase().contains('incident')) {
      return Icons.warning;
    } else if (category.toLowerCase().contains('degat')) {
      return Icons.broken_image;
    } else if (category.toLowerCase().contains('vehicule')) {
      return Icons.directions_car;
    } else if (category.toLowerCase().contains('victime')) {
      return Icons.person;
    } else {
      return Icons.sync;
    }
  }
}
