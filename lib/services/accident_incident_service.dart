import 'dart:convert';
import 'package:brt_mobile/core/constants/global.dart' as global;
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
      'user_saisie': null,
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

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['succes'] == true) {
          final int idServer = jsonResponse['data']['idfiche_alert'];
          final int idficheAlert = alerte.idficheAlert!;

          final int updatedRows = await db.updateAlertIdServer(
              idFicheAlert: idficheAlert,
              idServer: idServer
          );

          final int updateRows1 = await db.updateSignalementIdServer(
              signalementID: idficheAlert,
              signalementIdServer: idServer
          );

          if (updatedRows > 0 && updateRows1 > 0) {
            print("Mise à jour de id_server réussie pour idfiche_alert: $idficheAlert");
          } else {
            print("Aucune ligne mise à jour pour idfiche_alert: $idficheAlert");
          }
        } else {
          print("Erreur API : ${jsonResponse['message']}");
        }
      } else {
        print("Erreur HTTP : ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception lors de l'enregistrement de l'alerte : $e");
    }
  }

  static Future<void> syncAllData() async {
    print("Enregistrement des Alert -------------------------------------------\n\n");
    final alertes = await DatabaseHelper().getAllAlertesNonSync();

    for (Alerte alerte in alertes) {
      await saveAlerte(alerte);
    }
    print("Enregistrement des ${alertes.length} alerts okkkkkkkkkk -------------------------------------------\n\n");
  }

  static Future<void> saveFicheAccident(FicheAccident ficheAccident) async {

    print(ficheAccident.toMap());

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
        'user_saisie': ficheAccident.userSaisie,
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

      //IMAGESSSSSSSS

      if (ficheAccident.traceFreinagePhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'trace_freinage_photo',
          ficheAccident.traceFreinagePhoto!,
        ));
      }

      if (ficheAccident.traceSangPhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'trace_sang_photo',
          ficheAccident.traceSangPhoto!,
        ));
      }
      if (ficheAccident.tracePneuePhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'trace_pneue_photo',
          ficheAccident.tracePneuePhoto!,
        ));
      }

      // Envoi de la requête
      var response = await request.send();

      // Vérification de la réponse
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        print("Enregistrement réussi : $responseBody");
        int idServer = jsonResponse['data']['idfiche_accident'];

        final int idficheAccident = ficheAccident.idficheAccident!;

        // Mise à jour de la colonne id_server dans la table alerte
        final int updatedRows = await db.updateFicheAccidentIdServer(
          idFicheAccident: idficheAccident,
          idServer: idServer,
        );
        if (updatedRows > 0) {
          print("Mise à jour de id_server réussie pour idfiche_alert: $idficheAccident");
          await saveFicheAccidentVehicules(idficheAccident, idServer);
          await saveFicheAccidentVictime(idficheAccident, idServer);
          await saveAccidentDegatsMateriels(idficheAccident, idServer);
        } else {
          print("Aucune ligne mise à jour pour idfiche_alert: $idficheAccident");
        }
      } else {
        print("Erreur HTTP : ${response.statusCode} - ${await response.stream.bytesToString()}");
      }
    } else {
      await saveFicheAccidentVehicules(ficheAccident.idficheAccident!, ficheAccident.idServer!);
      await saveFicheAccidentVictime(ficheAccident.idficheAccident!, ficheAccident.idServer!);
      await saveAccidentDegatsMateriels(ficheAccident.idficheAccident!, ficheAccident.idServer!);

    }
  }

  static Future<void> syncAllFicheAccidents() async {
    print("Enregistrement des Accident -------------------------------------------\n\n");
    final fichesAccident = await DatabaseHelper().getAllFicheAccidents();
    if (fichesAccident.isEmpty) {
      Get.snackbar("Impossible", "Aucun accident à synchroniser");
      return;
    }

    for (FicheAccident fiche in fichesAccident) {
      saveFicheAccident(fiche);
    }
    print("Enregistrement des Accident OKKKKKK -------------------------------------------\n\n");
  }

  static Future<void> saveFicheAccidentVehicules(int accidentId, int accidentIdServer) async {
    print("Enregistrement des vehicules -------------------------------------------\n\n");
    List<Map<String, dynamic>> vehicules = await DatabaseHelper.getVehiculesByAccidentId(accidentId);

    for (Map<String, dynamic> vehi in vehicules) {

      FicheAccidentVehicule vehicule = FicheAccidentVehicule.fromMap(vehi);

      print(vehicule.toMap());

      if(vehicule.idServer==null){
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
              print("Enregistrement du véhicule réussi pour ID local : $idLocal");
            } else {
              print("Aucune ligne mise à jour pour ID local : $idLocal");
            }
          } else {
            print("Erreur API : ${jsonResponse['message']}");
          }
        } else {
          print("Erreur HTTP : ${response.statusCode} - ${response.body}");
        }
      }
    }
  }

  static Future<void> saveFicheAccidentVictime(int accidentId, int accidentIdServer) async {
    print("Enregistrement des victimes -------------------------------------------\n\n");
    List<Map<String, dynamic>> victimes = await DatabaseHelper.getVictimeByAccidentId(accidentId);

    for (Map<String, dynamic> victimeData in victimes) {
      FicheAccidentVictime victime = FicheAccidentVictime.fromMap(victimeData);
      final vehicule = await DatabaseHelper().getVehiculeByIdLocal(victime.vehicleId!);

      print("Données de la victime :");
      print(victime.toMap());
      print("id vehicule: ${vehicule!['id_server']}");

      if (victime.idServer == null) {
        final Map<String, dynamic> params = {
          'code': 'victime',
          'mp': global.user['mp'],
          'device_info': global.phoneIdentifier,
          'accident_id': accidentIdServer,
          'vehicule_id': vehicule['id_server'],
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
                print("Enregistrement de la victime réussi pour ID local : $idLocal");
              } else {
                print("Aucune ligne mise à jour pour ID local : $idLocal");
              }
            } else {
              print("Erreur API : ${jsonResponse['message']}");
            }
          } else {
            print("Erreur HTTP : ${response.statusCode} - ${response.body}");
          }
        } catch (e) {
          print("Erreur réseau ou serveur : $e");
        }
      }
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

}
