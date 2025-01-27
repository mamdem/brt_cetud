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

class AuthService {

  static final db = DatabaseHelper();

  static Future<void> fetchAndSaveData() async {
    final url =
        "${global.baseUrl}/getDataAccident?mp=${global.user['mp']}&device_info=${global.phoneIdentifier}";
    // Étape 1 : Effectuer une requête GET
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
    final alerts = jsonData['data']['ACCIDENT'] ?? [];
    final responsableSaisis = jsonData['data']['responsable_saisi'];

    for (var alert in alerts) {
      final idFicheAlert = alert['idfiche_alert'];

      // Vérifier si l'alerte existe déjà
      final existingAlert = await dbase.query(
        'alerte',
        where: 'idfiche_alert = ?',
        whereArgs: [idFicheAlert],
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
          });
        }

        // Gérer les véhicules associés
        final vehicules = alert['fiche_acident_vehicucle'] ?? [];
        for (var vehicule in vehicules) {
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
      }


    }
    for(var resp in responsableSaisis){
      final respSaisiId = resp['id'];
      final existingRespSaisi = await dbase.query(
        'responsable_saisi',
        where: 'id = ?',
        whereArgs: [respSaisiId],
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

      print("######## ENREGISTREMENTS RESP SAISIS OKKKKKKK");
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
    required String codeAlert,
    required int responsableSaisie,
    required String prenomNom,
    required String createdAt,
    required String mp,
    required String deviceInfo
  }) async {
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

    //print(params);

    final Uri uri = Uri.parse("${global.baseUrl}/saveDataAccident").replace(
      queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
    );

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if(jsonResponse["succes"]==true){
          if(id!=null){ //Si l'alerte est dejà en local, on update id_server
            await DatabaseHelper().updateResponsableSaisiIdServerById(id, jsonResponse['id']);
            EasyLoading.dismiss();
            Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
            print('responsable saisi enregistré en local');
            return true;
          }
          else{
            final Map<String, dynamic> data = {
              'id_server': jsonResponse["data"]["id"],
              'code_alert': codeAlert,
              'responsable_saisie': (global.user["idusers"]),
              'prenom_nom': "${global.user['prenom']} ${global.user["nom"]}",
              'created_at': DateTime.now().toIso8601String(),
            };

            try {
              final int insertedId = await DatabaseHelper().insertResponsableSaisi(data);
              print("Insertion réussie, ID inséré : $insertedId");
              EasyLoading.dismiss();
              Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
              return true;
            } catch (e) {
              print("Erreur lors de l'insertion : $e");
              EasyLoading.dismiss();
              Get.snackbar("Reussi", "Vous êtes responsable de cet alerte");
              return false;
            }
          }


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
    } catch (e) {
      print("Erreur de save responsable:$e");
      EasyLoading.instance.backgroundColor = Colors.red;
      EasyLoading.showError("Erreur de traitement");
      return false;
    }
  }

}
