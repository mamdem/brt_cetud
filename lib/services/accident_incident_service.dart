import 'dart:convert';
import 'dart:io';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:brt_mobile/models/incident_degats_materiels.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../error/sync_logger.dart';
import '../models/accident_degats_materiels.dart';
import '../models/alert.dart';
import '../models/fiche_accident.dart';
import '../models/fiche_accident_vehicule.dart';
import '../models/fiche_accident_victime.dart';
import '../models/fiche_incident.dart';
import '../models/fiche_incident_victime.dart';
import '../models/responsable_saisi.dart';
import '../sqflite/database_helper.dart';
import 'auth_service.dart';

class AccIncService {
  static final db = DatabaseHelper();

  static Future<void> saveAlerte(Alerte alerte) async {
    final Map<String, dynamic> params = {
      'code_alert': global.generateAlertCode(),
      'mp': global.user['mp'],
      'code': 'alert',
      'device_info': global.phoneIdentifier,
      'type_alert': alerte.typeAlert,
      'autres_alert': alerte.autresAlert,
      'date_alert': alerte.dateAlert?.toIso8601String(),
      'alerte_niveau_id': alerte.alerteNiveauId,
      'position_lat': alerte.positionLat,
      'position_long': alerte.positionLong,
      'bus_oparateur_implique': 1,
      'matricule_bus': alerte.matriculeBus,
      'voie': alerte.voie,
      'user_alert': global.user['idusers'],
      'fiche_alertecol': alerte.ficheAlertecol,
      'user_saisie': global.user['idusers'],
      'user_update': alerte.userUpdate,
      'user_delete': alerte.userDelete,
      'created_at': alerte.createdAt?.toIso8601String(),
      'updated_at': alerte.updatedAt?.toIso8601String(),
      'deleted_at': alerte.deletedAt?.toIso8601String(),
      'existence_victime': alerte.existenceVictime,
      'nb_victime': alerte.nbVictime,
      'victime_cons': alerte.victimeCons,
      'victime_incons': alerte.victimeIncons,
    };

    final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
      queryParameters: params.map((key, value) => MapEntry(key, value?.toString())),
    );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['succes'] == true) {
          final int idServer = jsonResponse['data']['idfiche_alert'];
          final int idficheAlert = alerte.idficheAlert!;

          final int updatedRows = await db.updateAlertIdServer(
            idFicheAlert: idficheAlert,
            idServer: idServer,
          );

          final int updateRows1 = await db.updateSignalementIdServer(
            tablename: alerte.typeAlert == 40 ? "fiche_incident":"fiche_accident",
            signalementID: idficheAlert,
            signalementIdServer: idServer,
          );

            final responsables = await DatabaseHelper().getResponsablesNonSync();
            for (Map<String, dynamic> resp in responsables){
              ResponsableSaisi responsableSaisi = ResponsableSaisi.fromMap(resp);
              await AuthService.saveResponsable( //On save a distance
                  id: responsableSaisi.id,
                  codeAlert: responsableSaisi.codeAlert,
                  responsableSaisie: (global.user["idusers"]),
                  prenomNom: "${global.user['prenom_user']} ${global.user["nom_user"]}",
                  createdAt: DateTime.now().toIso8601String().toString(),
                  mp: global.user['mp'],
                  deviceInfo: global.phoneIdentifier
              );
            }
            SyncLogger.addLog(
              "Mise à jour de id_server réussie pour l'alerte ID: $idficheAlert.",
              status: "success",
            );

        } else {
          SyncLogger.addLog(
            "Erreur API lors de la synchronisation de l'alerte ID: ${alerte.idficheAlert} - Message: ${jsonResponse['message']}.",
            status: "error",
          );
        }
      } else {
        SyncLogger.addLog(
          "Erreur HTTP lors de la synchronisation de l'alerte ID: ${alerte.idficheAlert} - Code: ${response.statusCode}, Réponse: ${response.body}.",
          status: "error",
        );
      }

  }

  static Future<void> syncAllAlert() async {
    print("################\n"
        "Début de la synchronisation des alertes.");
    SyncLogger.addLog("################\n"
        "Début de la synchronisation des alertes.", status: "info");

    try{
      final alertes = await DatabaseHelper().getAllAlertesNonSync();

      if (alertes.isEmpty) {
        SyncLogger.addLog("Aucune alerte à synchroniser.", status: "info");
        print("Aucune alerte à synchroniser.");
        return;
      }

      for (Alerte alerte in alertes) {
        await saveAlerte(alerte);
      }

      print("Enregistrement des ${alertes.length} alertes terminé.");
    }catch(e){
      print("################\n"
          "Erreur de la synchronisation des alertes.");
      SyncLogger.addLog("################\n"
          "Erreur de la synchronisation des alertes $e", status: "warning");
    }

  }

  static Future<void> saveFicheIncident(FicheIncident ficheIncident) async {
    print(ficheIncident.toMap());
    SyncLogger.addLog(
      "Début de la synchronisation de l'incident ID: ${ficheIncident.idficheIncident}.",
      status: "info",
    );

    try {
      if (ficheIncident.idServer == null) {
        final Map<String, dynamic> params = {
          'signalement_id': ficheIncident.signalementId,
          'device_info': global.phoneIdentifier,
          'code': 'incident',
          'mp': global.user['mp'],
          'libelle': ficheIncident.libelle,
          'type_incident_id': ficheIncident.typeIncidentId,
          'user_id': ficheIncident.userId,
          'position_lat': ficheIncident.positionLat,
          'position_long': ficheIncident.positionLong,
          'voie_corridor_oui_non': ficheIncident.voieCorridorOuiNon,
          'lieu_corridor': ficheIncident.lieuCorridor,
          'section_id': ficheIncident.sectionId,
          'date_heure': ficheIncident.dateHeure?.toIso8601String(),
          'interruption_service': ficheIncident.interruptionService,
          'date_reprise': ficheIncident.dateReprise?.toIso8601String(),
          'bus_operateur_implique': ficheIncident.busOperateurImplique,
          'matricule_bus': ficheIncident.matriculeBus,
          'autres_vehicule_oui_non': 0,
          'mortel': ficheIncident.mortel,
          'nb_mort': ficheIncident.nbMort,
          'blesse': ficheIncident.blesse,
          'nb_blesse': ficheIncident.nbBlesse,
          'type_jour': ficheIncident.typeJour,
          'user_saisie': global.user['idusers'],
          'user_update': ficheIncident.userUpdate,
          'user_delete': ficheIncident.userDelete,
          'created_at': ficheIncident.createdAt?.toIso8601String(),
          'updated_at': ficheIncident.updatedAt?.toIso8601String(),
          'deleted_at': ficheIncident.deletedAt?.toIso8601String(),
        };

        final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
          queryParameters: params.map((key, value) => MapEntry(key, value?.toString())),
        );

        final response = await http.post(uri);


        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

          if (jsonResponse['succes'] == true) {
            SyncLogger.addLog(
              "Incident ID: ${ficheIncident.idficheIncident} synchronisé avec succès.",
              status: "success",
            );

            int idServer = jsonResponse['data']['idfiche_incident'];
            final int idficheIncident = ficheIncident.idficheIncident!;

            // Mise à jour de la colonne id_server dans la table incident
            final int updatedRows = await db.updateFicheIncidentIdServer(
              idFicheIncident: idficheIncident,
              idServer: idServer,
            );

            if (updatedRows > 0) {
              SyncLogger.addLog(
                "Mise à jour locale réussie pour l'incident ID: $idficheIncident.",
                status: "success",
              );
              await saveFicheIncidentVictime(idficheIncident, idServer);
              await saveIncidentDegatsMateriels(idficheIncident, idServer);
            } else {
              SyncLogger.addLog(
                "Aucune ligne mise à jour pour l'incident ID: $idficheIncident.",
                status: "warning",
              );
            }
          } else {
            SyncLogger.addLog(
              "Erreur API pour l'incident ID: ${ficheIncident.idficheIncident} - Message: ${jsonResponse['message']}.",
              status: "error",
            );
          }
        } else {
          SyncLogger.addLog(
            "Erreur HTTP pour l'incident ID: ${ficheIncident.idficheIncident} - Code: ${response.statusCode}}.",
            status: "error",
          );
          print("Erreur HTTP pour l'incident ID: ${ficheIncident.idficheIncident} - Code: ${response.statusCode}");
        }
      } else {
        SyncLogger.addLog(
          "L'incident ID: ${ficheIncident.idficheIncident} est déjà synchronisé avec le serveur.",
          status: "info",
        );
        await saveFicheIncidentVictime(ficheIncident.idficheIncident!, ficheIncident.idServer!);
        await saveIncidentDegatsMateriels(ficheIncident.idficheIncident!, ficheIncident.idServer!);
      }
    } catch (e) {
      SyncLogger.addLog(
        "Exception lors de la synchronisation de l'incident ID: ${ficheIncident.idficheIncident} - Erreur: $e.",
        status: "error",
      );
    }
  }

  static Future<void> _addFileToRequest(http.MultipartRequest request, String fieldName, String? filePath) async {
    if (filePath != null && filePath.isNotEmpty) {
      final file = File(filePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      } else {
      }
    }
  }

  static Future<void> saveFicheAccident(FicheAccident ficheAccident) async {
    SyncLogger.addLog("Début de la synchronisation de l'accident ID: ${ficheAccident.idficheAccident}.", status: "info");

    try {
      if (ficheAccident.idServer == null) {
        final Map<String, dynamic> params = {
          'signalemen_id': ficheAccident.signalemenIdServer ?? ficheAccident.signalemenId,
          'device_info': global.phoneIdentifier,
          'mp': global.user['mp'],
          'code': 'accident',
          'date_heure': ficheAccident.dateHeure?.toIso8601String(),
          'position_lat': ficheAccident.positionLat,
          'position_long': ficheAccident.positionLong,
          'corridor_hor_co': ficheAccident.corridorHorCo,
          'section_id': ficheAccident.sectionId,
          'bus_operateur_impli_oui_non': ficheAccident.busOperateurImpliOuiNon,
          'collision_entre': ficheAccident.collisionEntre,
          'point_reference_lat': ficheAccident.pointReferenceLat,
          'point_reference_long': ficheAccident.pointReferenceLong,
          'blesse_oui_non': ficheAccident.blesseOuiNon,
          'nb_blesse': ficheAccident.nbBlesse,
          'nb_vehicule_implique': ficheAccident.nbVehiculeImplique,
          'mortel_oui_non': 0,
          'type_jour': ficheAccident.typeJour,
          'user_saisie': global.user['idusers'],
          'user_update': ficheAccident.userUpdate,
          'user_delete': ficheAccident.userDelete,
          'created_at': ficheAccident.createdAt?.toIso8601String(),
          'updated_at': ficheAccident.updatedAt?.toIso8601String(),
          'deleted_at': ficheAccident.deletedAt?.toIso8601String(),
          'agent_assistant': ficheAccident.agentAssistant,
          'conditon_atmospherique': ficheAccident.conditionAtmospherique,
          'condi_atmospherique': ficheAccident.condiAtmospherique,
          'visibilite': ficheAccident.visibilite,
          'chaussee': ficheAccident.chaussee,
          'largeur_eclairage_voie': ficheAccident.largeurEclairageVoie,
          'trace_freinage': ficheAccident.traceFreinage,
          'trace_sang': ficheAccident.traceSang,
          'trace_pneue': ficheAccident.tracePneue
        };

        var request = http.MultipartRequest('POST', Uri.parse("${global.baseUrl}/saveDataAccident"));

        params.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        // Ajout des fichiers avec vérification
        await _addFileToRequest(request, 'trace_pneue_photo', ficheAccident.tracePneuePhoto);
        await _addFileToRequest(request, 'trace_freinage_photo', ficheAccident.traceFreinagePhoto);
        await _addFileToRequest(request, 'trace_sang_photo', ficheAccident.traceSangPhoto);

        SyncLogger.addLog("Accident ID: trace_freinage_photo : ${ficheAccident.traceFreinagePhoto!}"
            "\ntrace_sang_photo: ${ficheAccident.traceSangPhoto!}"
            "\ntrace_pneue_photo: ${ficheAccident.tracePneuePhoto}", status: "success");

        // Envoi de la requête
        var response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

          if (jsonResponse['succes'] == true) {
            SyncLogger.addLog("Accident ID: ${ficheAccident.idficheAccident} synchronisé avec succès.", status: "success");

            int idServer = jsonResponse['data']['idfiche_accident'];
            final int idficheAccident = ficheAccident.idficheAccident!;

            // Mise à jour de la colonne id_server dans la table accident
            final int updatedRows = await db.updateFicheAccidentIdServer(
              idFicheAccident: idficheAccident,
              idServer: idServer,
            );

            if (updatedRows > 0) {
              SyncLogger.addLog(
                "Mise à jour locale réussie pour l'accident ID: $idficheAccident.",
                status: "success",
              );
              await saveFicheAccidentVehicules(idficheAccident, idServer);
              await saveFicheAccidentVictime(idficheAccident, idServer);
              await saveAccidentDegatsMateriels(idficheAccident, idServer);
            } else {
              SyncLogger.addLog(
                "Aucune ligne mise à jour pour l'accident ID: $idficheAccident.",
                status: "warning",
              );
            }
          } else {
            SyncLogger.addLog(
              "Erreur API pour l'accident ID: ${ficheAccident.idficheAccident} - Message: ${jsonResponse['message']}.",
              status: "error",
            );
          }
        } else {
          SyncLogger.addLog(
            "Erreur HTTP pour l'accident ID: ${ficheAccident.idficheAccident} - Code: ${response.statusCode}, Réponse: ${await response.stream.bytesToString()}.",
            status: "error",
          );
        }
      } else {
        SyncLogger.addLog(
          "L'accident ID: ${ficheAccident.idficheAccident} est déjà synchronisé avec le serveur.",
          status: "info",
        );
        await saveFicheAccidentVehicules(ficheAccident.idficheAccident!, ficheAccident.idServer!);
        await saveFicheAccidentVictime(ficheAccident.idficheAccident!, ficheAccident.idServer!);
        await saveAccidentDegatsMateriels(ficheAccident.idficheAccident!, ficheAccident.idServer!);
      }
    } catch (e) {
      SyncLogger.addLog(
        "Exception lors de la synchronisation de l'accident ID: ${ficheAccident.idficheAccident} - Erreur: $e.",
        status: "error",
      );
    }
  }

  static Future<void> syncAllFicheAccidents() async {
    print("Enregistrement des Accidents & Incidents -------------------------------------------\n\n");
    final fichesAccident = await DatabaseHelper().getAllFicheAccidents();
    final fichesIncident = await DatabaseHelper().getAllFicheIncidents();
    if (fichesAccident.isEmpty && fichesIncident.isEmpty) {
      Get.snackbar("Impossible", "Aucun accident et incident à synchroniser");
      return;
    }else if(fichesAccident.isEmpty){
      Get.snackbar("Impossible", "Aucun accident à synchroniser");
      for (FicheIncident fiche in fichesIncident) {
        await saveFicheIncident(fiche);
      }
      return;
    }else if(fichesIncident.isEmpty){
      Get.snackbar("Impossible", "Aucun incident à synchroniser");
      for (FicheAccident fiche in fichesAccident) {
        await saveFicheAccident(fiche);
      }
      return;
    }
    print("LES DEUX SONT SYNC");
    for (FicheIncident fiche in fichesIncident) {
      await saveFicheIncident(fiche);
    }
    for (FicheAccident fiche in fichesAccident) {
      await saveFicheAccident(fiche);
    }

    print("Enregistrement des Accident & Incident OKKKKKK -------------------------------------------\n\n");
  }

  static Future<void> saveFicheAccidentVehicules(int accidentId, int accidentIdServer) async {
    SyncLogger.addLog(
      "## Début de la synchronisation des véhicules pour l'accident ID: $accidentId.",
      status: "info",
    );

    try {
      List<Map<String, dynamic>> vehicules = await DatabaseHelper.getVehiculesByAccidentId(accidentId);

      if (vehicules.isEmpty) {
        SyncLogger.addLog(
          "Aucun véhicule trouvé pour l'accident ID: $accidentId.",
          status: "info",
        );
        return;
      }

      for (Map<String, dynamic> vehi in vehicules) {
        FicheAccidentVehicule vehicule = FicheAccidentVehicule.fromMap(vehi);

        if (vehicule.idServer == null) {
          final Map<String, dynamic> params = {
            'code': 'vechicule',
            'mp': global.user['mp'],
            'device_info': global.phoneIdentifier,
            'acccident_id': accidentIdServer,
            'matricule': vehicule.matricule,
            'num_carte_grise': vehicule.numCarteGrise,
            'categorie_vehicule': vehicule.categorieVehicule,
            'autre_vehicule': vehicule.autreVehicule ?? '',
            'autre_information_add': vehicule.autreInformationAdd ?? '',
            'prenom_chauffeur': vehicule.prenomChauffeur,
            'nom_chauffeur': vehicule.nomChauffeur,
            'age': vehicule.age,
            'sexe': 'f',
            'tel_chauffeur': vehicule.telChauffeur,
            'profession_conducteur': vehicule.professionConducteur ?? '',
            'filiation_prenom_pere': vehicule.filiationPrenomPere ?? '',
            'filiation_prenom_nom_mere': vehicule.filiationPrenomNomMere ?? '',
            'domicile_conducteur': vehicule.domicileConducteur ?? '',
            'numero_permis': vehicule.numeroPermis ?? '',
            'date_delivrance_permis': vehicule.dateDelivrancePermis?.toIso8601String(),
            'categorie_permis': 1,
            'date_imatriculation_vehicule': vehicule.dateImmatriculationVehicule?.toIso8601String(),
            'comportement_conducteur': vehicule.comportementConducteur ?? '',
            'autres_comportement': vehicule.autresComportement ?? '',
            'prenom_nom_proprietaire': vehicule.prenomNomProprietaire ?? '',
            'numero_assurance': vehicule.numeroAssurance ?? '',
            'assureur': vehicule.assureur ?? '',
            'puissance_vehicule': vehicule.puissanceVehicule,
            'date_expiration_assurance': vehicule.dateExpirationAssurance?.toIso8601String(),
            'largeur_veh': vehicule.largeurVeh,
            'hauteur_veh': vehicule.hauteurVeh,
            'longeur_veh': vehicule.longueurVeh,
            'date_derniere_visite': vehicule.dateDerniereVisite?.toIso8601String(),
            'date_mise_criculation': vehicule.dateMiseCirculation?.toIso8601String(),
            'date_expiration_visite': vehicule.dateExpirationVisite?.toIso8601String(),
            'kilometrage': vehicule.kilometrage,
            'etat_generale': vehicule.etatGenerale ?? '',
            'user_saisie': global.user['idusers'],
            'eclairage': vehicule.eclairage,
            'avertisseur': vehicule.avertisseur,
            'indicateur_direction': vehicule.indicateurDirection,
            'indicateur_vitesse': vehicule.indicateurVitesse,
            'essuie_glace': vehicule.essuieGlace,
            'retroviseur': vehicule.retroviseur,
            'etat_pneue_avant': vehicule.etatPneueAvant,
            'etat_pneue_arriere': vehicule.etatPneueArriere,
            'etat_parebrise': vehicule.etatParebrise,
            'position_levier_vitesse': vehicule.positionLevierVitesse,
            'presence_poste_radio': vehicule.presencePosteRadio,
            'position_volume': vehicule.positionVolume,
          };

          final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
            queryParameters: params.map((key, value) => MapEntry(key, value?.toString())),
          );

          final response = await http.post(uri);

          if (response.statusCode == 200) {
            final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

            if (jsonResponse['succes'] == true) {
              final int idServer = jsonResponse['data']['idfiche_acident_vehucle'];
              final int idLocal = vehicule.idficheAccidentVehicule!;

              final int updateRows = await DatabaseHelper().updateVehiculeIdServer(
                idFicheAccidentVehicule: idLocal,
                idServer: idServer,
              );

              if (updateRows > 0) {
                SyncLogger.addLog(
                  "Véhicule ID local: $idLocal synchronisé avec succès pour l'accident ID: $accidentId.",
                  status: "success",
                );
              } else {
                SyncLogger.addLog(
                  "Aucune mise à jour locale effectuée pour le véhicule ID local: $idLocal.",
                  status: "warning",
                );
              }
            } else {
              SyncLogger.addLog(
                "Erreur API lors de la synchronisation du véhicule pour l'accident ID: $accidentId - Message: ${jsonResponse['message']}.",
                status: "error",
              );
            }
          } else {
            SyncLogger.addLog(
              "Erreur HTTP lors de la synchronisation du véhicule pour l'accident ID: $accidentId - Code: ${response.statusCode}, Réponse: ${response.body}.",
              status: "error",
            );
          }
        } else {
          SyncLogger.addLog(
            "Le véhicule ID local: ${vehicule.idficheAccidentVehicule} est déjà synchronisé avec le serveur.",
            status: "info",
          );
        }
      }
    } catch (e) {
      SyncLogger.addLog(
        "Exception lors de la synchronisation des véhicules pour l'accident ID: $accidentId - Erreur: $e.",
        status: "error",
      );
    }
  }

  static Future<void> saveFicheAccidentVictime(int accidentId, int accidentIdServer) async {
    print("\n\n\n\n\n\n");
    SyncLogger.addLog(
      "Début de la synchronisation des victimes pour l'accident ID: $accidentId.",
      status: "info",
    );

    try {
      List<Map<String, dynamic>> victimes = await DatabaseHelper.getVictimeByAccidentId(accidentId);

      if (victimes.isEmpty) {
        SyncLogger.addLog(
          "Aucune victime trouvée pour l'accident ID: $accidentId.",
          status: "info",
        );
        return;
      }

      for (Map<String, dynamic> victimeData in victimes) {
        FicheAccidentVictime victime = FicheAccidentVictime.fromMap(victimeData);
        final vehicule = await DatabaseHelper().getVehiculeByIdLocal(victime.vehicleId!);

        print(victimeData);

        if (victime.idServer == null) {
          print(" ENREGISTREMENT DE CETTE VICTIME------------:");
          print(victime);
          final Map<String, dynamic> params = {
            'code': 'victime',
            'mp': global.user['mp'],
            'device_info': global.phoneIdentifier,
            'accident_id': accidentIdServer,
            'vehicule_id': victime.vehicleId,
            'prenom': victime.prenom,
            'nom': victime.nom,
            'age': victime.age,
            'tel': victime.tel,
            'sexe': 'M',
            'etat_victime': victime.etatVictime,
            'structure_sanitaire_evac': victime.structureSanitaireEvac ?? '',
            'statut_guerison': victime.statutGuerison,
            'date_guerison': victime.dateGuerison?.toIso8601String(),
            'num_pv': victime.numPv ?? '',
            'nature_blessure': victime.natureBlessure ?? '',
            'conscient_inconscient': victime.conscientInconscient ?? '',
            'position_victime': victime.positionVictime ?? 0,
            'filiation_prenom_pere': victime.filiationPrenomPere ?? '',
            'filiation_prenom_nom_mere': victime.filiationPrenomNomMere ?? '',
            'accompagnant_prenom': victime.accompagnantPrenom ?? '',
            'accompagnant_nom': victime.accompagnantNom ?? '',
            'accompagnant_tel': victime.accompagnantTel ?? '',
            'user_saisie': global.user['idusers'],
          };

          final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
            queryParameters: params.map((key, value) => MapEntry(key, value?.toString())),
          );

          try {
            final response = await http.post(uri);

            if (response.statusCode == 200) {
              final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

              if (jsonResponse['succes'] == true) {
                final int idServer = jsonResponse['data']['idfiche_accident_victime'];
                final int idLocal = victime.idficheAccidentVictime!;

                final int updateRows = await DatabaseHelper().updateFicheVictimeIdServer(
                  idFicheAccidentVictime: idLocal,
                  idServer: idServer,
                );

                if (updateRows > 0) {
                  SyncLogger.addLog(
                    "Victime ID local: $idLocal synchronisée avec succès pour l'accident ID: $accidentId.",
                    status: "success",
                  );
                } else {
                  SyncLogger.addLog(
                    "Aucune mise à jour locale effectuée pour la victime ID local: $idLocal.",
                    status: "warning",
                  );
                }
              } else {
                SyncLogger.addLog(
                  "Erreur API lors de la synchronisation de la victime pour l'accident ID: $accidentId - Message: ${jsonResponse['message']}.",
                  status: "error",
                );
              }
            } else {
              SyncLogger.addLog(
                "Erreur HTTP lors de la synchronisation de la victime pour l'accident ID: $accidentId - Code: ${response.statusCode}, Réponse: ${response.body}.",
                status: "error",
              );
            }
          } catch (e) {
            SyncLogger.addLog(
              "Erreur réseau ou serveur lors de la synchronisation de la victime ID: ${victime.idficheAccidentVictime} pour l'accident ID: $accidentId - Erreur: $e.",
              status: "error",
            );
          }
        } else {
          SyncLogger.addLog(
            "La victime ID local: ${victime.idficheAccidentVictime} est déjà synchronisée avec le serveur.",
            status: "info",
          );
        }
      }
    } catch (e) {
      SyncLogger.addLog(
        "Exception lors de la synchronisation des victimes pour l'accident ID: $accidentId - Erreur: $e.",
        status: "error",
      );
    }
  }

  static Future<void> saveAccidentDegatsMateriels(int accidentId, int accidentIdServer) async {
    print("Enregistrement des dégâts matériels -------------------------------------------\n\n");
    List<Map<String, dynamic>> degatsMateriels = await DatabaseHelper.getDegatsMaterielsByAccidentId(accidentId);

    for (Map<String, dynamic> degatData in degatsMateriels) {
      AccidentDegatsMateriels degat = AccidentDegatsMateriels.fromMap(degatData);

      print("Données du dégât matériel :");
      print(degat.toMap());

      if (degat.idServer == null) {
        try {
          final Map<String, dynamic> params ={
            'code': 'accident_degats_materiels',
            'mp': global.user['mp'],
            'device_info': global.phoneIdentifier,
            'accident_id': accidentIdServer.toString(),
            'libelle_materiels': degat.libelleMateriels ?? '',
            'user_saisie': global.user['idusers'].toString(),
            'created_at': DateTime.now().toIso8601String()
          };

          var request = http.MultipartRequest('POST', Uri.parse("${global.baseUrl}/saveDataAccident"));

          params.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });

          //IMAGESSSSSSSS
          if (degat.photos != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'photos',
              degat.photos!,
            ));
          }

          // Envoyer la requête
          final response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

            if (jsonResponse['succes'] == true) {
              final int idServer = jsonResponse['data']['idaccident_degats_materiels'];
              final int idLocal = degat.id!;

              final int updateRows = await DatabaseHelper().updateDegatsMaterielsIdServer(
                idAccidentDM: idLocal,
                idServer: idServer,
              );

              if (updateRows > 0) {
                print("Enregistrement du dégât matériel réussi pour ID local : $idLocal");
              } else {
                print("Aucune ligne mise à jour pour ID local : $idLocal");
              }
            } else {
              print("Erreur API : ${jsonResponse['message']}");
            }
          } else {
            print("Erreur HTTP : ${response.statusCode}");
          }
        } catch (e) {
          print("Erreur réseau ou serveur : $e");
        }
      }
    }
  }

  static Future<void> saveFicheIncidentVictime(int incidentId, int incidentIdServer) async {
    SyncLogger.addLog(
      "Début de la synchronisation des victimes pour l'incident ID: $incidentId.",
      status: "info",
    );

    try {
      List<Map<String, dynamic>> victimes = await DatabaseHelper.getVictimeByIncidentId(incidentId);

      if (victimes.isEmpty) {
        SyncLogger.addLog(
          "Aucune victime trouvée pour l'incident ID: $incidentId.",
          status: "info",
        );
        return;
      }

      for (Map<String, dynamic> victimeData in victimes) {
        FicheIncidentVictime victime = FicheIncidentVictime.fromMap(victimeData);

        print(victime.toMap());

        if (victime.idServer == null) {
          final Map<String, dynamic> params = {
            'code': 'incident_victime',
            'mp': global.user['mp'],
            'device_info': global.phoneIdentifier,
            'incident_id': incidentIdServer,
            'prenom': victime.prenom,
            'traumatisme': victime.traumatisme,
            'nom': victime.nom,
            'age': victime.age,
            'tel': victime.tel,
            'structure_evacuation': victime.structureEvacuation,
            'sexe': victime.sexe,
            'user_saisie': global.user['idusers'],
          };

          final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
            queryParameters: params.map((key, value) => MapEntry(key, value?.toString())),
          );

          try {
            final response = await http.post(uri);

            if (response.statusCode == 200) {
              final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
              print(jsonResponse['data']);
              if (jsonResponse['succes'] == true) {
                final int idServer = jsonResponse['data']['idfiche_incident_victime'];

                final int idLocal = victime.idIncidentVictime!;

                final int updateRows = await DatabaseHelper().updateFicheVictimeIdServer(
                  idFicheAccidentVictime: idLocal,
                  idServer: idServer,
                );

                if (updateRows > 0) {
                  SyncLogger.addLog(
                    "Victime ID local: $idLocal synchronisée avec succès pour l'incident ID: $incidentId.",
                    status: "success",
                  );
                } else {
                  SyncLogger.addLog(
                    "Aucune mise à jour locale effectuée pour la victime ID local: $idLocal.",
                    status: "warning",
                  );
                }
              } else {
                SyncLogger.addLog(
                  "Erreur API lors de la synchronisation de la victime pour l'incident ID: $incidentId - Message: ${jsonResponse['message']}.",
                  status: "error",
                );
              }
            } else {
              SyncLogger.addLog(
                "Erreur HTTP lors de la synchronisation de la victime pour l'incident ID: $incidentId - Code: ${response.statusCode}, Réponse: ${response.body}.",
                status: "error",
              );
            }
          } catch (e) {
            SyncLogger.addLog(
              "Erreur réseau ou serveur lors de la synchronisation de la victime ID: ${victime.idIncidentVictime} pour l'incident ID: $incidentId - Erreur: $e.",
              status: "error",
            );
          }
        } else {
          SyncLogger.addLog(
            "La victime ID local: ${victime.idIncidentVictime} est déjà synchronisée avec le serveur.",
            status: "info",
          );
        }
      }
    } catch (e) {
      SyncLogger.addLog(
        "Exception lors de la synchronisation des victimes pour l'incident ID: $incidentId - Erreur: $e.",
        status: "error",
      );
    }
  }

  static Future<void> saveIncidentDegatsMateriels(int incidentId, int incidentIdServer) async {
    print("Enregistrement des incidents dégâts matériels -------------------------------------------\n");
    List<Map<String, dynamic>> degatsMateriels = await DatabaseHelper.getDegatsMaterielsByIncidentId(incidentId);

    for (Map<String, dynamic> degatData in degatsMateriels) {
      IncidentDegatsMateriels degat = IncidentDegatsMateriels.fromMap(degatData);
      print(degat.toMap());

      if (degat.idServer == null) {
        try {
          final Map<String, dynamic> params ={
            'code': 'incident_degats_materiels',
            'mp': global.user['mp'],
            'device_info': global.phoneIdentifier,
            'incident_id': incidentIdServer.toString(),
            'libelle_materiels': degat.libelleMateriels ?? '',
            'user_saisie': global.user['idusers'].toString(),
            'created_at': DateTime.now().toIso8601String()
          };

          var request = http.MultipartRequest('POST', Uri.parse("${global.baseUrl}/saveDataAccident"));

          params.forEach((key, value) {
            if (value != null) {
              request.fields[key] = value.toString();
            }
          });

          //IMAGESSSSSSSS
          if (degat.photos != null) {
            request.files.add(await http.MultipartFile.fromPath(
              'photos',
              degat.photos!,
            ));
          }

          // Envoyer la requête
          final response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

            if (jsonResponse['succes'] == true) {
              final int idServer = jsonResponse['data']['idincident_degats_materiels'];
              final int idLocal = degat.id!;

              final int updateRows = await DatabaseHelper().updateDegatsMaterielsIdServer(
                idAccidentDM: idLocal,
                idServer: idServer,
              );

              if (updateRows > 0) {
                print("Enregistrement du dégât matériel réussi pour ID local : $idLocal");
              } else {
                print("Aucune ligne mise à jour pour ID local : $idLocal");
              }
            } else {
              print("Erreur API : ${jsonResponse['message']}");
            }
          } else {
            print("Erreur HTTP : ${response.statusCode}");
          }
        } catch (e) {
          print("Erreur réseau ou serveur : $e");
        }
      }
    }
  }
}
