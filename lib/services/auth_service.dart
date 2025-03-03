import 'dart:convert';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:brt_mobile/models/fiche_incident.dart';
import 'package:brt_mobile/models/fiche_incident_victime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/accident_degats_materiels.dart';
import '../models/alert.dart';
import '../models/fiche_accident.dart';
import '../models/fiche_accident_vehicule.dart';
import '../models/fiche_accident_victime.dart';
import '../models/responsable_saisi.dart';
import '../sqflite/database_helper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class AuthService {

  static final db = DatabaseHelper();

  static Future<void> fetchAndSaveData() async {
    final url =
        "${global.baseUrl}/getDataAccident?mp=${global.user['mp']}&device_info=${global.phoneIdentifier}";
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print("JSON DATA $jsonData");
      await saveData(jsonData);
      print("Les données ont été sauvegardées avec succès !");
    } else {
      print("Erreur lors de la requête : ${response.statusCode}");
    }
  }

  static Future<void> saveData(Map<String, dynamic> jsonData) async {
    final dbase = await DatabaseHelper().database;
    await DatabaseHelper().deleteAllTableSynced();
    final alerts = jsonData['data']['ACCIDENT'] ?? [];
    final alertsIncident = jsonData['data']['INCIDENT'];
    final responsableSaisis = jsonData['data']['responsable_saisi'];

    // Liste pour stocker les informations de téléchargement des images
    List<Map<String, dynamic>> imageDownloadQueue = [];

    for (var alert in alerts) {
      final idFicheAlert = alert['idfiche_alert'];
      final codeAlert = alert['code_alert'];

      final existingAlert = await dbase.query(
        'alerte',
        where: 'code_alert = ?',
        whereArgs: [codeAlert],
      );

      if (existingAlert.isEmpty) {
        await dbase.insert('alerte', {
          'idfiche_alert': idFicheAlert,
          'code_alert': alert['code_alert'],
          'type_alert': alert['type_alert'],
          'autres_alert': alert['autres_alert'],
          'date_alert': alert['date_alert'],
          'alerte_niveau_id': alert['alerte_niveau_id'],
          'position_lat': alert['position_lat'],
          'position_long': alert['position_long'],
          'bus_operateur_implique': alert['bus_oparateur_implique'],
          'matricule_bus': alert['matricule_bus'],
          'voie': alert['voie'],
          'user_alert': alert['user_alert'],
          'fiche_alertecol': alert['fiche_alertecol'],
          'user_saisie': alert['user_saisie'],
          'user_update': alert['user_update'],
          'user_delete': alert['user_delete'],
          'created_at': alert['created_at'],
          'updated_at': alert['updated_at'],
          'deleted_at': alert['deleted_at'],
          'existence_victime': alert['existence_victime'],
          'nb_victime': alert['nb_victime'],
          'victime_cons': alert['victime_cons'],
          'victime_incons': alert['victime_incons'],
          'id_server': idFicheAlert,
        });
      }

      // Gérer les données d'accident
      if (alert['accident'] != null) {
        final accident = alert['accident'];
        final idFicheAccident = accident['idfiche_accident'];

        final existingAccident = await dbase.query(
          'fiche_accident',
          where: 'idfiche_accident = ?',
          whereArgs: [idFicheAccident],
        );

        if (existingAccident.isEmpty) {
          await dbase.insert('fiche_accident', {
            'idfiche_accident': idFicheAccident,
            'signalement_id': idFicheAlert,
            'date_heure': accident['date_heure'],
            'position_lat': accident['position_lat'],
            'position_long': accident['position_long'],
            'corridor_hor_co': accident['corridor_hor_co'],
            'section_id': accident['section_id'],
            'bus_operateur_impli_oui_non': accident['bus_operateur_impli_oui_non'],
            'collision_entre': accident['collision_entre'],
            'point_reference_lat': accident['point_reference_lat'],
            'point_reference_long': accident['point_reference_long'],
            'blesse_oui_non': accident['blesse_oui_non'],
            'nb_blesse': accident['nb_blesse'],
            'nb_vehicule_implique': accident['nb_vehicule_implique'],
            'condition_atmospherique': accident['condi_atmospherique'],
            'type_jour': accident['type_jour'],
            'user_saisie': accident['user_saisie'],
            'user_update': accident['user_update'],
            'user_delete': accident['user_delete'],
            'created_at': accident['created_at'],
            'updated_at': accident['updated_at'],
            'deleted_at': accident['deleted_at'],
            'condition_atmostpherique': accident['conditon_atmostpherique'],
            'visibilite': accident['visibilite'],
            'chaussee': accident['chaussee'],
            'largeur_eclairage_voie': accident['largeur_eclairage_voie'],
            'id_server': idFicheAccident,
            'signalement_id_server': idFicheAlert,
            'trace_freinage': accident['trace_freinage'],
            'trace_freinage_photo': null, // Sera mis à jour avec le chemin local
            'trace_sang': accident['trace_sang'],
            'trace_sang_photo': null, // Sera mis à jour avec le chemin local
            'trace_pneue': accident['trace_pneue'],
            'trace_pneue_photo': null, // Sera mis à jour avec le chemin local
          });
        }

        // Gérer les véhicules associés
        final vehicules = alert['fiche_acident_vehicucle'] ?? [];

        for (var vehicule in vehicules) {
          print("GET DATA ACCIDENT");
          print(vehicule);
          final idVehicule = vehicule['idfiche_acident_vehucle'];

          final existingVehicule = await dbase.query(
            'fiche_accident_vehicule',
            where: 'id_server = ?',
            whereArgs: [idVehicule],
          );

          if (existingVehicule.isEmpty) {
            await dbase.insert('fiche_accident_vehicule', {
              'idfiche_accident_vehicule': idVehicule,
              'id_server': idVehicule,
              'accident_id': idFicheAccident,
              'matricule': vehicule['matricule'],
              'num_carte_grise': vehicule['num_carte_grise'],
              'categorie_vehicule': vehicule['categorie_vehicule'],
              'autre_vehicule': vehicule['autre_vehicule'],
              'autre_information_add': vehicule['autre_information_add'],
              'prenom_chauffeur': vehicule['prenom_chauffeur'],
              'nom_chauffeur': vehicule['nom_chauffeur'],
              'age': vehicule['age'],
              'sexe': vehicule['sexe'],
              'tel_chauffeur': vehicule['tel_chauffeur'],
              'profession_conducteur': vehicule['profession_conducteur'],
              'filiation_prenom_pere': vehicule['filiation_prenom_pere'],
              'filiation_prenom_nom_mere': vehicule['filiation_prenom_nom_mere'],
              'domicile_conducteur': vehicule['domicile_conducteur'],
              'numero_permis': vehicule['numero_permis'],
              'date_delivrance_permis': vehicule['date_delivrance_permis'],
              'categorie_permis': vehicule['categorie_permis'],
              'date_immatriculation_vehicule': vehicule['date_imatriculation_vehicule'],
              'comportement_conducteur': vehicule['comportement_conducteur'],
              'autres_comportement': vehicule['autres_comportement'],
              'prenom_nom_proprietaire': vehicule['prenom_nom_proprietaire'],
              'numero_assurance': vehicule['numero_assurance'],
              'assureur': vehicule['assureur'],
              'puissance_vehicule': vehicule['puissance_vehicule'],
              'date_expiration_assurance': vehicule['date_expiration_assurance'],
              'largeur_veh': vehicule['largeur_veh'],
              'hauteur_veh': vehicule['hauteur_veh'],
              'longueur_veh': vehicule['longeur_veh'],
              'date_derniere_visite': vehicule['date_derniere_visite'],
              'date_mise_circulation': vehicule['date_mise_criculation'],
              'date_expiration_visite': vehicule['date_expiration_visite'],
              'kilometrage': vehicule['kilometrage'],
              'etat_generale': vehicule['etat_generale'],
              'created_at': vehicule['created_at'],
              'updated_at': vehicule['updated_at'],
              'deleted_at': vehicule['deleted_at'],
              'eclairage': vehicule['eclairage'],
              'avertisseur': vehicule['avertisseur'],
              'indicateur_direction': vehicule['indicateur_direction'],
              'indicateur_vitesse': vehicule['indicateur_vitesse'],
              'essuie_glace': vehicule['essuie_glace'],
              'retroviseur': vehicule['retroviseur'],
              'etat_pneue_avant': vehicule['etat_pneue_avant'],
              'etat_pneue_arriere': vehicule['etat_pneue_arriere'],
              'etat_parebrise': vehicule['etat_parebrise'],
              'position_levier_vitesse': vehicule['position_levier_vitesse'],
              'presence_poste_radio': vehicule['presence_poste_radio'],
              'position_volume': vehicule['position_volume'],
            });
          }
        }

        // Gérer les victimes associées
        final victimes = alert['fiche_accident_victimes'] ?? [];
        for (var victime in victimes) {
          final idVictime = victime['idfiche_accident_victime'];

          final existingVictime = await dbase.query(
            'fiche_accident_victime',
            where: 'id_server = ?',
            whereArgs: [idVictime],
          );

          if (existingVictime.isEmpty) {
            await dbase.insert('fiche_accident_victime', {
              'idfiche_accident_victime': idVictime,
              'id_server': idVictime,
              'accident_id': idFicheAccident,
              'vehicle_id': victime['vehicule_id'],
              'prenom': victime['prenom'],
              'nom': victime['nom'],
              'age': victime['age'],
              'tel': victime['tel'],
              'etat_victime': victime['etat_victime'],
              'structure_sanitaire_evac': victime['structure_sanitaire_evac'],
              'statut_guerison': victime['statut_guerison'],
              'date_guerison': victime['date_guerison'],
              'num_pv': victime['num_pv'],
              'user_saisie': victime['user_saisie'],
              'user_update': victime['user_update'],
              'user_delete': victime['user_delete'],
              'created_at': victime['created_at'],
              'updated_at': victime['updated_at'],
              'deleted_at': victime['deleted_at'],
              'nature_blessure': victime['nature_blesseure'],
              'conscient_inconscient': victime['conscient_inconscient'],
              'position_victime': victime['position_victime'],
              'filiation_prenom_pere': victime['filiation_prenom_pere'],
              'filiation_prenom_nom_mere': victime['filiation_prenom_nom_mere'],
              'accompagnant_prenom': victime['accompagnant_prenom'],
              'accompagnant_nom': victime['accompagnant_nom'],
              'accompagnant_tel': victime['accompagnant_tel'],
            });
          }
        }

        // Gérer les dégâts matériels
        final incidentDegats = alert['accident_degats_materiels'] ?? [];
        for (var degat in incidentDegats) {
          final idDegat = degat['idaccident_degats_materiels'];

          final existingDegat = await dbase.query(
            'accident_degats_materiels',
            where: 'idaccident_degats_materiels = ?',
            whereArgs: [idDegat],
          );

          // Au lieu de déclencher le téléchargement immédiatement, nous enregistrons les informations
          if (degat['photos'] != null && degat['photos'].isNotEmpty) {
            final String photoUrl = 'https://cetud.saytu.pro/storage/${degat['photos']}';

            // Ajouter à la file d'attente de téléchargement
            imageDownloadQueue.add({
              'url': photoUrl,
              'fileName': "degat_$idDegat.png",
              'type': 'accident_degats_materiels',
              'id': idDegat
            });
          }

          if (existingDegat.isEmpty) {
            // Insérer sans attendre la photo, avec l'URL originale
            await dbase.insert('accident_degats_materiels', {
              "idaccident_degats_materiels": idDegat,
              "id_server": idDegat,
              "libelle_materiels": degat['libelle_materiels'],
              "photos": degat['photos'], // URL originale, sera mise à jour plus tard
              "accident_id": degat['accident_id'],
              "user_saisie": degat['user_saisie'],
              "user_update": degat['user_update'],
              "user_delete": degat['user_delete'],
              "created_at": degat['created_at'],
              "updated_at": degat['updated_at'],
              "deleted_at": degat['deleted_at']
            });
          } else {
            print("⚠️ Le dégât idaccident_degats_materiels = $idDegat existe déjà, mise à jour ignorée.");
          }
        }

        // Ajouter les images de traces aux téléchargements
        // Trace de freinage
        if (accident['trace_freinage_photo'] != null && accident['trace_freinage_photo'].toString().isNotEmpty) {
          String photoUrl = 'https://cetud.saytu.pro/storage/${accident['trace_freinage_photo']}';
          String fileName = 'trace_freinage_${idFicheAccident}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageDownloadQueue.add({
            'url': photoUrl,
            'fileName': fileName,
            'id': idFicheAccident,
            'type': 'fiche_accident_trace_freinage'
          });
        }

        // Trace de sang
        if (accident['trace_sang_photo'] != null && accident['trace_sang_photo'].toString().isNotEmpty) {
          String photoUrl = 'https://cetud.saytu.pro/storage/${accident['trace_sang_photo']}';
          String fileName = 'trace_sang_${idFicheAccident}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageDownloadQueue.add({
            'url': photoUrl,
            'fileName': fileName,
            'id': idFicheAccident,
            'type': 'fiche_accident_trace_sang'
          });
        }

        // Trace de pneu
        if (accident['trace_pneue_photo'] != null && accident['trace_pneue_photo'].toString().isNotEmpty) {
          String photoUrl = 'https://cetud.saytu.pro/storage/${accident['trace_pneue_photo']}';
          String fileName = 'trace_pneue_${idFicheAccident}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageDownloadQueue.add({
            'url': photoUrl,
            'fileName': fileName,
            'id': idFicheAccident,
            'type': 'fiche_accident_trace_pneue'
          });
        }
      }

    }

    for (var alert in alertsIncident) {
      final idFicheAlert = alert['idfiche_alert'];

      // Gérer les données d'accident
      if (alert['incident'] != null) {
        final incident = alert['incident'];
        final idFicheIncident = incident['idfiche_incident'];

        final existingIncident = await dbase.query(
          'fiche_incident',
          where: 'idfiche_incident = ?',
          whereArgs: [idFicheIncident],
        );

        if (existingIncident.isEmpty) {
          FicheIncident ficheIncident = FicheIncident.fromMapSansDateConvert(incident);
          await dbase.insert('fiche_incident',{
            "idfiche_incident": ficheIncident.idficheIncident,
            "id_server": ficheIncident.idficheIncident,
            "libelle": ficheIncident.libelle,
            "type_incident_id": ficheIncident.typeIncidentId,
            "user_id": ficheIncident.userId,
            "signalement_id": idFicheAlert,
            "position_lat": ficheIncident.positionLat,
            "position_long": ficheIncident.positionLong,
            "voie_corridor_oui_non": ficheIncident.voieCorridorOuiNon,
            "lieu_corridor": ficheIncident.lieuCorridor,
            "section_id": ficheIncident.sectionId,
            "date_heure": incident['date_heure'],
            "interruption_service": ficheIncident.interruptionService,
            "date_reprise": incident['date_reprise'],
            "bus_operateur_implique": ficheIncident.busOperateurImplique,
            "matricule_bus": ficheIncident.matriculeBus,
            "autres_vehicule_oui_non": ficheIncident.autresVehiculeOuiNon,
            "mortel": ficheIncident.mortel,
            "nb_mort": ficheIncident.nbMort,
            "blesse": ficheIncident.blesse,
            "nb_blesse": ficheIncident.nbBlesse,
            "type_jour": ficheIncident.typeJour,
            "user_saisie": ficheIncident.userSaisie,
            "user_update": ficheIncident.userUpdate,
            "user_delete": ficheIncident.userDelete,
            "created_at": incident['created_at'],
            "updated_at": incident['updated_at'],
            "deleted_at": incident['deleted_at']

          });
        }

        // Gérer les victimes associées
        final victimes = alert['incident_victime'] ?? [];
        for (var victime in victimes) {
          final idVictime = victime['idincident_victime'];


          // Gérer les victimes associées
          final victimes = alert['incident_victime'] ?? [];
          for (var victime in victimes) {
            final idVictime = victime['idincident_victime'];

            // Vérifier si l'ID existe déjà dans la base de données
            final existingVictime = await dbase.query(
              'fiche_incident_victime',
              where: 'idincident_victime = ?',
              whereArgs: [idVictime],
            );

            FicheIncidentVictime ficheVictime = FicheIncidentVictime.fromMap(victime);

            Map<String, dynamic> data = {
              "idincident_victime": ficheVictime.idIncidentVictime,
              "id_server": ficheVictime.idIncidentVictime,
              "age": ficheVictime.age,
              "sexe": ficheVictime.sexe,
              "tel": ficheVictime.tel,
              "prenom": ficheVictime.prenom,
              "nom": ficheVictime.nom,
              "etat_victime": ficheVictime.etatVictime,
              "incident_id": ficheVictime.incidentId,
              "structure_evacuation": ficheVictime.structureEvacuation,
              "traumatisme": ficheVictime.traumatisme,
              "user_saisie": ficheVictime.userSaisie,
              "user_update": ficheVictime.userUpdate,
              "user_delete": ficheVictime.userDelete,
              "created_at": victime['created_at'],
              "updated_at": victime['updated_at'],
              "deleted_at": victime['deleted_at']
            };

            if (existingVictime.isEmpty) {
              await dbase.insert('fiche_incident_victime', data);
            } else {
              await dbase.update(
                'fiche_incident_victime',
                data,
                where: 'idincident_victime = ?',
                whereArgs: [idVictime],
              );
            }
          }

        }

        // Gérer les dégâts matériels
        final incidentDegats = alert['incident_degats_materiels'] ?? [];
        for (var degat in incidentDegats) {
          final idDegat = degat['idincident_degats_materiels'];

          // Vérifier si l'ID existe déjà dans la base de données
          final existingDegat = await dbase.query(
            'incident_degats_materiels',
            where: 'idincident_degats_materiels = ?',
            whereArgs: [idDegat],
          );

          // Au lieu de déclencher le téléchargement immédiatement, nous enregistrons les informations
          if (degat['photos'] != null && degat['photos'].isNotEmpty) {
            final String photoUrl = 'https://cetud.saytu.pro/storage/${degat['photos']}';

            // Ajouter à la file d'attente de téléchargement
            imageDownloadQueue.add({
              'url': photoUrl,
              'fileName': "degat_$idDegat.png",
              'type': 'incident_degats_materiels',
              'id': idDegat
            });
          }

          if (existingDegat.isEmpty) {
            // Insérer sans attendre la photo, avec l'URL originale
            await dbase.insert('incident_degats_materiels', {
              "idincident_degats_materiels": idDegat,
              "id_server": idDegat,
              "libelle_materiels": degat['libelle_materiels'],
              "photos": degat['photos'], // URL originale, sera mise à jour plus tard
              "incident_id": degat['incident_id'],
              "user_saisie": degat['user_saisie'],
              "user_update": degat['user_update'],
              "user_delete": degat['user_delete'],
              "created_at": degat['created_at'],
              "updated_at": degat['updated_at'],
              "deleted_at": degat['deleted_at']
            });
          } else {
            print("⚠️ Le dégât idincident_degats_materiels = $idDegat existe déjà, mise à jour ignorée.");
          }
        }
      }
    }

    for(var resp in responsableSaisis){
      final respSaisiId = resp['id'];
      final existingRespSaisi = await dbase.query(
        'responsable_saisi',
        where: 'id = ? OR id_server = ?',
        whereArgs: [respSaisiId, respSaisiId],
      );


      if(existingRespSaisi.isEmpty){
        await dbase.insert('responsable_saisi', {
          'id': resp['id'],
          'id_server': resp['id'],
          'code_alert': resp['code_alert'],
          'responsable_saisie': resp['responsable_saisie'],
          'prenom_nom': '${resp["prenom_user"]} ${resp["nom_user"]}',
          'created_at': resp['created_at']
        });
      }
    }

    // Démarrer le téléchargement des images en arrière-plan
    _processImagesInBackground(imageDownloadQueue);

    // La fonction se termine ici sans attendre le téléchargement des images
    print("Données textuelles chargées. Téléchargement des images en cours en arrière-plan.");
  }

  // Formater les bytes en unités lisibles (KB, MB)
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Version améliorée pour traiter les images en arrière-plan avec un système de traitement par lots
  static void _processImagesInBackground(List<Map<String, dynamic>> imageQueue) {
    if (imageQueue.isEmpty) return;
    
    // Utiliser une zone isolée pour éviter de bloquer le thread principal
    Future(() async {
      final dbase = await DatabaseHelper().database;
      int totalImages = imageQueue.length;
      int processedImages = 0;
      int failedImages = 0;
      
      // Configuration de traitement par lots
      const int batchSize = 3; // Nombre d'images à traiter simultanément
      const int maxRetries = 2; // Nombre maximum de tentatives en cas d'échec
      
      print("Démarrage du téléchargement de $totalImages images en arrière-plan");
      
      // Trier les images par priorité (les photos de traces d'accident en premier)
      List<Map<String, dynamic>> prioritizedQueue = List.from(imageQueue);
      prioritizedQueue.sort((a, b) {
        // Priorité aux images de traces d'accident
        bool isTraceA = a['type'].toString().contains('trace');
        bool isTraceB = b['type'].toString().contains('trace');
        
        if (isTraceA && !isTraceB) return -1;
        if (!isTraceA && isTraceB) return 1;
        return 0;
      });
      
      // Traiter les images par lots
      for (int i = 0; i < prioritizedQueue.length; i += batchSize) {
        final int end = (i + batchSize < prioritizedQueue.length) ? i + batchSize : prioritizedQueue.length;
        final batch = prioritizedQueue.sublist(i, end);
        
        // Traiter chaque lot en parallèle
        final results = await Future.wait(
          batch.map((imageInfo) => _processImageWithRetry(imageInfo, maxRetries))
        );
        
        // Mettre à jour la base de données pour chaque image traitée avec succès
        for (int j = 0; j < results.length; j++) {
          final result = results[j];
          final imageInfo = batch[j];
          
          if (result != null) {
            processedImages++;
            
            try {
              // Mettre à jour l'enregistrement dans la base de données avec le chemin local
              if (imageInfo['type'] == 'accident_degats_materiels') {
                await dbase.update(
                  'accident_degats_materiels',
                  {'photos': result},
                  where: 'idaccident_degats_materiels = ?',
                  whereArgs: [imageInfo['id']],
                );
              } else if (imageInfo['type'] == 'incident_degats_materiels') {
                await dbase.update(
                  'incident_degats_materiels',
                  {'photos': result},
                  where: 'idincident_degats_materiels = ?',
                  whereArgs: [imageInfo['id']],
                );
              } else if (imageInfo['type'] == 'fiche_accident_trace_freinage') {
                await dbase.update(
                  'fiche_accident',
                  {'trace_freinage_photo': result},
                  where: 'idfiche_accident = ?',
                  whereArgs: [imageInfo['id']],
                );
                print("Photo de trace de freinage mise à jour: ${imageInfo['id']} -> $result");
              } else if (imageInfo['type'] == 'fiche_accident_trace_sang') {
                await dbase.update(
                  'fiche_accident',
                  {'trace_sang_photo': result},
                  where: 'idfiche_accident = ?',
                  whereArgs: [imageInfo['id']],
                );
                print("Photo de trace de sang mise à jour: ${imageInfo['id']} -> $result");
              } else if (imageInfo['type'] == 'fiche_accident_trace_pneue') {
                await dbase.update(
                  'fiche_accident',
                  {'trace_pneue_photo': result},
                  where: 'idfiche_accident = ?',
                  whereArgs: [imageInfo['id']],
                );
                print("Photo de trace de pneu mise à jour: ${imageInfo['id']} -> $result");
              }
            } catch (e) {
              print("Erreur lors de la mise à jour de la BD pour l'image ${imageInfo['fileName']}: $e");
            }
          } else {
            failedImages++;
          }
          
          // Afficher la progression
          final progress = processedImages + failedImages;
          print("Progression: $progress/$totalImages (Réussies: $processedImages, Échouées: $failedImages)");
        }
        
        // Pause courte entre les lots pour éviter de surcharger les ressources
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      print("Téléchargement et traitement des images terminés. "
          "Total: $processedImages/$totalImages traitées avec succès, $failedImages échecs.");
    });
  }
  
  // Méthode pour traiter une image avec plusieurs tentatives en cas d'échec
  static Future<String?> _processImageWithRetry(Map<String, dynamic> imageInfo, int maxRetries) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        final stopwatch = Stopwatch()..start();
        final result = await _downloadAndSaveImage(imageInfo['url'], imageInfo['fileName']);
        
        stopwatch.stop();
        if (result != null) {
          print("Image ${imageInfo['fileName']} traitée en ${stopwatch.elapsedMilliseconds}ms (tentative ${attempts + 1})");
          return result;
        }
        
        attempts++;
        if (attempts <= maxRetries) {
          // Attente exponentielle entre les tentatives (500ms, puis 1000ms, etc.)
          final waitTime = 500 * (1 << attempts);
          print("Échec du traitement de l'image ${imageInfo['fileName']}, nouvelle tentative dans ${waitTime}ms...");
          await Future.delayed(Duration(milliseconds: waitTime));
        }
      } catch (e) {
        print("Erreur lors du traitement de l'image ${imageInfo['fileName']} (tentative ${attempts + 1}): $e");
        attempts++;
        
        if (attempts <= maxRetries) {
          // Attente exponentielle entre les tentatives
          final waitTime = 500 * (1 << attempts);
          await Future.delayed(Duration(milliseconds: waitTime));
        }
      }
    }
    
    print("Échec définitif du traitement de l'image ${imageInfo['fileName']} après ${maxRetries + 1} tentatives");
    return null;
  }

  static Future<String?> _downloadAndSaveImage(String imageUrl, String fileName) async {
    try {
      print('Téléchargement de l\'image: $imageUrl');
      final stopwatch = Stopwatch()..start();

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;
        final File localFile = File('$appDocPath/$fileName');

        // Obtenir les données de l'image
        final List<int> imageBytes = response.bodyBytes;
        final int originalSize = imageBytes.length;

        // Compresser l'image si sa taille est supérieure à 300Ko
        List<int> processedBytes = imageBytes;
        if (originalSize > 300 * 1024) { // Plus de 300Ko
          // Réduire la qualité de l'image pour économiser de l'espace
          // Utiliser une méthode simple de troncation pour les formats qui le supportent
          if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
            // Pour JPEG, on peut manipuler directement les données en modifiant certains marqueurs
            // Cette approche simplifiée réduit la taille mais peut affecter la qualité
            processedBytes = _reduceJpegQuality(imageBytes);
          }
        }

        // Sauvegarder l'image traitée
        await localFile.writeAsBytes(processedBytes);

        stopwatch.stop();
        final int finalSize = processedBytes.length;
        final double compressionRatio = originalSize > 0 ? (originalSize - finalSize) / originalSize * 100 : 0;

        print('Image traitée en ${stopwatch.elapsedMilliseconds}ms. Taille originale: ${_formatBytes(originalSize)}, '
            'taille finale: ${_formatBytes(finalSize)}, réduction: ${compressionRatio.toStringAsFixed(1)}%');

        return localFile.path;
      } else {
        print('Erreur lors du téléchargement de l\'image : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors du traitement de l\'image : $e');
      return null;
    }
  }

  // Méthode pour réduire la qualité d'une image JPEG
  static List<int> _reduceJpegQuality(List<int> jpegData) {
    try {
      // Cette méthode est une simplification et ne fonctionne que pour certains types de JPEG
      // Pour une solution complète, il faudrait utiliser une bibliothèque dédiée

      // Chercher les marqueurs de qualité JPEG (FF DB) et réduire les valeurs
      // Cela affectera la table de quantification, réduisant la qualité mais aussi la taille
      List<int> result = List.from(jpegData);

      for (int i = 0; i < result.length - 4; i++) {
        // Recherche du marqueur de qualité JPEG
        if (result[i] == 0xFF && result[i + 1] == 0xDB) {
          // Modifier les valeurs de la table de quantification
          // Augmenter ces valeurs réduit la qualité mais aussi la taille du fichier
          int length = (result[i + 2] << 8) | result[i + 3];
          if (length > 2) {
            for (int j = i + 4; j < i + 2 + length && j < result.length; j++) {
              // Augmenter chaque valeur de quantification (réduire la qualité)
              result[j] = (result[j] * 1.5).round().clamp(1, 255);
            }
          }
        }
      }

      return result;
    } catch (e) {
      print('Erreur lors de la réduction de qualité JPEG: $e');
      return jpegData; // En cas d'erreur, retourner les données originales
    }
  }

  static Future<bool> getFirstConnexion({
    required String numTel,
    required String prenom,
    required String nom,
    required String deviceInfo,
  }) async {
    final Uri url = Uri.parse(
        "${global.baseUrl}/getConnexion?num_tel=$numTel&prenom=$prenom&nom=$nom&device_info=$deviceInfo");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['succes'] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  static Future<void> fetchUser() async {
    final db = DatabaseHelper();
    final user = await db.getUser();

    if (user != null) {
      global.user = user;
    } else {
      print('Aucun utilisateur trouvé avec cet email.');
    }
  }

  static Future<Map<String, dynamic>?> getInfoUser({
    required String numTel,
    required String login,
    required String mp,
    required String code,
  }) async {
    final Uri url = Uri.parse(
        "${global.baseUrl}/getInfoUser?num_tel=$numTel&login=$login&mp=$mp&code=$code");
    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['succes'] == true) {
          final db = DatabaseHelper();
          db.saveJsonData(jsonData);
          global.saveIsConnected(true);
          global.saveIsFirstConnection(true);
          global.savePassword(mp);
          return jsonData;
        }else{
          return null;
        }
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<bool> saveResponsable({
    int? id,
    int? idServer,
    required String codeAlert,
    required int responsableSaisie,
    required String prenomNom,
    required String createdAt,
    required String mp,
    required String deviceInfo
  }) async {
    final dbase = await DatabaseHelper().database;
    EasyLoading.instance.backgroundColor = Colors.black;
    EasyLoading.show(status: 'Requête en cours...');

    final Map<String, dynamic> params = {
      'code': 'responsable_saisi',
      'code_alert': codeAlert,
      'responsable_saisie': global.user["idusers"],
      'prenom_nom': prenomNom,
      'created_at': createdAt,
      'user_id': global.user["idusers"],
      'user_saisie':  global.user["idusers"],
      'mp': mp,
      'device_info': deviceInfo
    };

    final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if(jsonResponse["succes"]==true){

            final Map<String, dynamic> data = {
              'id_server': jsonResponse["data"]["id"],
              'code_alert': codeAlert,
              'responsable_saisie': (global.user["idusers"]),
              'prenom_nom': "${global.user['prenom']} ${global.user["nom"]}",
              'created_at': DateTime.now().toIso8601String(),
            };

            final existinResp = await dbase.query(
              'alerte',
              where: 'code_alert = ?',
              whereArgs: [codeAlert],
            );

            if(existinResp.isEmpty){
              final int insertedId = await DatabaseHelper().insertResponsableSaisi(data);
              print("Insertion réussie, ID inséré : $insertedId");
              //Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
            }else{

              int updatedRows = await DatabaseHelper().updateResponsableSaisiIdServerById(
                  codeAlert, jsonResponse['data']['id']
              );

              if (updatedRows > 0) {
                print("RESPONSABLE UPDATEEEEEEEEEEEEEEED OKKKKKKKKKK!!!!!!!!!!!!!!!!!");
              } else {
                print("Échec de la mise à jour ou aucune ligne affectée.");
              }

            }
            EasyLoading.dismiss();

            return true;

        }else{
          EasyLoading.dismiss();
          Get.snackbar("Erreur", "Erreur de traitement", colorText: Colors.red);
          return false;
        }
      } else {
        EasyLoading.instance.backgroundColor = Colors.red;
        EasyLoading.showError("Erreur de traitement");
        return false;
      }
  }

  static Future<bool> saveResponsableEnLocal({
    required String codeAlert,
    required int responsableSaisie,
    required String prenomNom,
    required String createdAt,
    required String mp,
    required String deviceInfo
  }) async {
    final dbase = await DatabaseHelper().database;
    EasyLoading.instance.backgroundColor = Colors.black;
    EasyLoading.show(status: 'Requête en cours...');

    final Map<String, dynamic> data = {
      'code_alert': codeAlert,
      'responsable_saisie': (global.user["idusers"]),
      'prenom_nom': "${global.user['prenom']} ${global.user["nom"]}",
      'created_at': DateTime.now().toIso8601String(),
    };

    final existinResp = await dbase.query(
      'alerte',
      where: 'code_alert = ?',
      whereArgs: [codeAlert],
    );

    final int insertedId = await DatabaseHelper().insertResponsableSaisi(data);
    print("Insertion réussie, ID inséré : $insertedId");
    print(data);
    Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");

    EasyLoading.dismiss();

    return true;
  }

}
