import 'dart:convert';
import 'package:brt_mobile/core/constants/global.dart' as global;
import 'package:brt_mobile/models/fiche_accident.dart';
import 'package:brt_mobile/models/fiche_incident.dart';
import 'package:brt_mobile/models/victime_update.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/alert.dart';
import '../models/fiche_accident_vehicule.dart';
import '../models/fiche_accident_victime.dart';
import '../models/fiche_incident_victime.dart';
import '../models/incident_degats_materiels.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> deleteLocalDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'alerts.db');
    await deleteDatabase(dbPath);
    print('Base de données supprimée.');
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'alerts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<int> deleteVictime(String code, int id) async {
    final db = await database;
    return await db.delete(
      'victime_update',
      where: 'code = ? AND id = ?',
      whereArgs: [code, id],
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    //Victime update
    await db.execute('''
        CREATE TABLE victime_update (
          id INTEGER,
          code TEXT NOT NULL,
          structure_evacuation TEXT NOT NULL
        )
      ''');

    //Responsable saisi
    await db.execute('''
        CREATE TABLE responsable_saisi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_server INTEGER,
          code_alert TEXT NOT NULL,
          responsable_saisie INTEGER NOT NULL,
          prenom_nom TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');

    //Table alerte
    await db.execute('''
      CREATE TABLE alerte (
        idfiche_alert INTEGER PRIMARY KEY AUTOINCREMENT,
        code_alert TEXT,
        type_alert INTEGER,
        autres_alert TEXT,
        date_alert TEXT,
        alerte_niveau_id INTEGER,
        position_lat REAL,
        position_long REAL,
        lieu_corridor TEXT,
        bus_operateur_implique INTEGER,
        matricule_bus TEXT,
        voie INTEGER,
        user_alert INTEGER,
        fiche_alertecol TEXT,
        user_saisie INTEGER,
        user_update INTEGER,
        user_delete INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        existence_victime INTEGER,
        nb_victime INTEGER,
        victime_cons INTEGER,
        victime_incons INTEGER,
        id_server INTEGER
      )
    ''');

    //Table fiche_accident
    await db.execute('''
CREATE TABLE fiche_accident (
  idfiche_accident INTEGER PRIMARY KEY AUTOINCREMENT,
  signalement_id INTEGER,
  date_heure TEXT,
  position_lat REAL,
  position_long REAL,
  corridor_hor_co INTEGER,
  section_id INTEGER,
  bus_operateur_impli_oui_non INTEGER,
  collision_entre TEXT,
  point_reference_lat REAL,
  point_reference_long REAL,
  blesse_oui_non INTEGER,
  nb_blesse INTEGER,
  nb_vehicule_implique INTEGER,
  condition_atmospherique INTEGER,
  agent_assistant TEXT,
  type_jour INTEGER,
  user_saisie INTEGER,
  user_update INTEGER,
  user_delete INTEGER,
  created_at TEXT,
  updated_at TEXT,
  deleted_at TEXT,
  condition_atmostpherique INTEGER,
  visibilite INTEGER,
  chaussee INTEGER,
  largeur_eclairage_voie INTEGER,
  id_server INTEGER,
  signalement_id_server INTEGER,
  trace_freinage TEXT,
  trace_freinage_photo TEXT,
  trace_sang TEXT,
  trace_sang_photo TEXT,
  trace_pneue TEXT,
  trace_pneue_photo TEXT
)
''');

    //Table fiche incident
    await db.execute('''
    CREATE TABLE fiche_incident (
      idfiche_incident INTEGER PRIMARY KEY,
      id_server INTEGER,
      c INTEGER, 
      libelle TEXT,
      type_incident_id INTEGER,
      user_id INTEGER,
      signalement_id INTEGER,
      signalement_id_server INTEGER,
      position_lat DOUBLE,
      position_long DOUBLE,
      voie_corridor_oui_non TINYINT,
      lieu_corridor TEXT,
      section_id INTEGER,
      date_heure DATETIME,
      interruption_service TINYINT,
      date_reprise DATETIME,
      bus_operateur_implique TINYINT,
      matricule_bus TEXT,
      autres_vehicule_oui_non TINYINT,
      mortel TINYINT,
      nb_mort INTEGER,
      blesse TINYINT,
      nb_blesse INTEGER,
      type_jour INTEGER,
      user_saisie INTEGER,
      user_update INTEGER,
      user_delete INTEGER,
      created_at TIMESTAMP,
      updated_at TIMESTAMP,
      deleted_at TIMESTAMP
    );
  ''');

    //Fiche accident vehicule
    await db.execute('''
      CREATE TABLE fiche_accident_vehicule (
        idfiche_accident_vehicule INTEGER PRIMARY KEY AUTOINCREMENT,
        id_server INTEGER,
        accident_id INTEGER NOT NULL,
        matricule TEXT NOT NULL,
        num_carte_grise TEXT,
        categorie_vehicule INTEGER NOT NULL,
        autre_vehicule TEXT,
        autre_information_add TEXT,
        prenom_chauffeur TEXT NOT NULL,
        nom_chauffeur TEXT NOT NULL,
        age INTEGER NOT NULL,
        sexe varchar NOT NULL,
        tel_chauffeur TEXT NOT NULL,
        profession_conducteur TEXT,
        filiation_prenom_pere TEXT,
        filiation_prenom_nom_mere TEXT,
        domicile_conducteur TEXT,
        numero_permis TEXT,
        date_delivrance_permis DATE,
        categorie_permis INTEGER,
        date_immatriculation_vehicule DATE,
        comportement_conducteur TEXT,
        autres_comportement TEXT,
        prenom_nom_proprietaire TEXT,
        numero_assurance TEXT,
        assureur TEXT,
        puissance_vehicule INTEGER,
        date_expiration_assurance DATE,
        largeur_veh INTEGER,
        hauteur_veh INTEGER,
        longueur_veh INTEGER,
        date_derniere_visite DATE,
        date_mise_circulation DATE,
        date_expiration_visite DATE,
        kilometrage BIGINT,
        etat_generale TEXT,
        user_saisie INTEGER,
        user_update INTEGER,
        user_delete INTEGER,
        created_at TIMESTAMP,
        updated_at TIMESTAMP,
        deleted_at TIMESTAMP,
        eclairage VARCHAR,
        avertisseur VARCHAR,
        indicateur_direction VARCHAR,
        indicateur_vitesse VARCHAR,
        essuie_glace VARCHAR,
        retroviseur VARCHAR,
        etat_pneue_avant VARCHAR,
        etat_pneue_arriere VARCHAR,
        etat_parebrise VARCHAR,
        position_levier_vitesse VARCHAR,
        presence_poste_radio INTEGER,
        position_volume INTEGER
      )
    ''');

    //Fiche fiche_accident_victime
    await db.execute('''
          CREATE TABLE fiche_accident_victime (
              idfiche_accident_victime INTEGER PRIMARY KEY AUTOINCREMENT,
              id_server INTEGER,
              accident_id INTEGER NOT NULL,
              vehicle_id INTEGER,
              prenom TEXT,
              nom TEXT,
              age INTEGER,
              tel TEXT,
              sexe CHAR(1),
              etat_victime TEXT,
              structure_sanitaire_evac TEXT,
              statut_guerison TEXT,
              date_guerison TEXT,
              num_pv TEXT,
              user_saisie INTEGER,
              user_update INTEGER,
              user_delete INTEGER,
              created_at TEXT,
              updated_at TEXT,
              deleted_at TEXT,
              nature_blessure TEXT,
              conscient_inconscient INTEGER,
              position_victime INTEGER,
              filiation_prenom_pere TEXT,
              filiation_prenom_nom_mere TEXT,
              accompagnant_prenom TEXT,
              accompagnant_nom TEXT,
              accompagnant_tel TEXT
          )
        ''');

    //Fiche fiche_incident_victime
    await db.execute('''
    CREATE TABLE fiche_incident_victime (
      idincident_victime INTEGER PRIMARY KEY AUTOINCREMENT,
      id_server INTEGER,
      prenom varchar(80),
      nom varchar(50),
      age INTEGER,
      sexe CHAR(1),
      tel VARCHAR(45),
      position_victime INTEGER,
      conscient_inconscient INTEGER,
      etat_victime VARCHAR(45),
      incident_id INTEGER,
      structure_evacuation VARCHAR(45),
      traumatisme TEXT,
      date_guerison DATE,
      user_saisie INTEGER,
      user_update INTEGER,
      user_delete INTEGER,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      deleted_at TIMESTAMP
    )
  ''');

    //Fiche accident cause
    await db.execute('''
          CREATE TABLE fiche_accidents_causes (
            idfiche_accidents_causes INTEGER PRIMARY KEY AUTOINCREMENT,
            accident_id INTEGER NOT NULL,
            causes TEXT NOT NULL,
            num_pv TEXT NOT NULL,
            commentaire TEXT,
            user_saisie INTEGER,
            user_update INTEGER,
            user_delete INTEGER,
            created_at TEXT,
            updated_at TEXT,
            deleted_at TEXT
          )
        ''');

    //Table accident_degats_materiels
    await db.execute('''
  CREATE TABLE accident_degats_materiels (
    idaccident_degats_materiels INTEGER PRIMARY KEY AUTOINCREMENT,
    id_server INTEGER,
    libelle_materiels TEXT NOT NULL,
    photos TEXT,
    accident_id INTEGER NOT NULL,
    user_saisie INTEGER,
    user_update INTEGER,
    user_delete INTEGER,
    created_at TEXT,
    updated_at TEXT,
    deleted_at TEXT
  )
''');

    //Table incident_degats_materiels
    await db.execute('''
  CREATE TABLE incident_degats_materiels (
    idincident_degats_materiels INTEGER PRIMARY KEY AUTOINCREMENT,
    id_server INTEGER,
    libelle_materiels TEXT NOT NULL,
    photos TEXT,
    incident_id INTEGER NOT NULL,
    user_saisie INTEGER,
    user_update INTEGER,
    user_delete INTEGER,
    created_at TEXT,
    updated_at TEXT,
    deleted_at TEXT
  )
''');
  }

  Future<void> deleteTableWithServerId(tablename) async {
    final db = await database;
    try {
      await db.delete(
        tablename,
        where: 'id_server IS NOT NULL',
      );
    } catch (e) {
      print("Erreur lors de la suppression de $tablename : $e");
    }
  }

  Future<List<Map<String, dynamic>>> getResponsablesNonSync() async {
    final db = await database;
    return await db.query('responsable_saisi', where: 'id_server IS NULL ');
  }

  Future<void> deleteAllTableSynced() async {
    await deleteTableWithServerId("responsable_saisi");
    await deleteTableWithServerId("accident_degats_materiels");
    await deleteTableWithServerId("incident_degats_materiels");
    await deleteTableWithServerId("fiche_accident_victime");
    await deleteTableWithServerId("fiche_incident_victime");
    await deleteTableWithServerId("fiche_accident_vehicule");
    await deleteTableWithServerId("fiche_accident");
    await deleteTableWithServerId("fiche_incident");

    await deleteTableWithServerId("alerte");
  }

  Future<int> updateResponsableSaisiIdServerById(
      String codeAlert, int idServer) async {
    final db = await database;
    return await db.update(
      'responsable_saisi',
      {
        'id_server': idServer,
      },
      where: 'code_alert = ?',
      whereArgs: [codeAlert],
    );
  }

  Future<Map<String, dynamic>?> getUserStructure() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'structure',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> insertFicheIncidentVictime(FicheIncidentVictime victime) async {
    final db = await database;
    await db.insert('fiche_incident_victime', victime.toMap());
  }

  Future<void> insertVictimeUpdate(VictimeUpdate victimeUpdate) async {
    final db = await database;
    await db.insert('victime_update', victimeUpdate.toMap());
  }

  Future<List<VictimeUpdate>> getAllVictimesUpdate() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('victime_update');

    return List.generate(maps.length, (i) {
      return VictimeUpdate.fromMap(maps[i]);
    });
  }

  Future<List<FicheIncidentVictime>> getAllVictimes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('fiche_incident_victime');

    return List.generate(maps.length, (i) {
      return FicheIncidentVictime.fromMap(maps[i]);
    });
  }

  Future<int> insertAccidentDegatsMateriels(
      Map<String, dynamic> degatsMateriels) async {
    final db = await database;

    // Create a map with all the data including ID if provided
    Map<String, dynamic> dataToInsert = {
      'libelle_materiels': degatsMateriels['libelle_materiels'],
      'photos': degatsMateriels['photos'],
      'accident_id': degatsMateriels['accident_id'],
      'user_saisie': degatsMateriels['user_saisie'],
      'created_at': degatsMateriels['created_at'],
    };

    // Add ID to the map if it exists in the input data
    if (degatsMateriels.containsKey('idaccident_degats_materiels')) {
      dataToInsert['idaccident_degats_materiels'] =
          degatsMateriels['idaccident_degats_materiels'];
    }

    // Add id_server if it exists
    if (degatsMateriels.containsKey('id_server')) {
      dataToInsert['id_server'] = degatsMateriels['id_server'];
    }

    // Add updated_at if it exists
    if (degatsMateriels.containsKey('updated_at')) {
      dataToInsert['updated_at'] = degatsMateriels['updated_at'];
    }

    // Add user_update if it exists
    if (degatsMateriels.containsKey('user_update')) {
      dataToInsert['user_update'] = degatsMateriels['user_update'];
    }

    return await db.insert(
      'accident_degats_materiels',
      dataToInsert,
      conflictAlgorithm: ConflictAlgorithm
          .replace, // This will replace existing records with the same ID
    );
  }

  Future<List<Map<String, dynamic>>> getAllAccidentDegatsMateriels() async {
    final db = await database;
    return await db.query('accident_degats_materiels');
  }

  Future<List<Map<String, dynamic>>> getAccidentDegatsMaterielsById(
      int accidentId) async {
    final db = await database;
    return await db.query(
      'accident_degats_materiels',
      where: 'accident_id = ?',
      whereArgs: [accidentId],
    );
  }

  Future<List<Map<String, dynamic>>> getIncidentDegatsMaterielsByIncidentId(
      int incidentId) async {
    final db = await database;
    return await db.query(
      'incident_degats_materiels',
      where: 'incident_id = ?',
      whereArgs: [incidentId],
    );
  }

  // Alias method to maintain compatibility with existing code
  Future<List<Map<String, dynamic>>> getIncidentDegatsMaterielsById(
      int incidentId) async {
    return getIncidentDegatsMaterielsByIncidentId(incidentId);
  }

  Future<void> clearTables() async {
    final db = await database;
    await db.delete('fiche_accident_victime');
    await db.delete('fiche_accident_vehicule');
    await db.delete('fiche_accident');
    await db.delete('fiche_incident');
    await db.delete('alerte');
    await db.delete('responsable_saisi');
    await db.delete('victime_update');
  }

  Future<int> updateAccidentDegatsMateriels(
      int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'accident_degats_materiels',
      data,
      where: 'idaccident_degats_materiels = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAccidentDegatsMateriels(int id) async {
    final db = await database;
    return await db.delete(
      'accident_degats_materiels',
      where: 'idaccident_degats_materiels = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertIncidentDegatsMateriels(
      Map<String, dynamic> degatsMateriels) async {
    final db = await database;

    // Create a map with all the data including ID if provided
    Map<String, dynamic> dataToInsert = {
      'libelle_materiels': degatsMateriels['libelle_materiels'],
      'photos': degatsMateriels['photos'],
      'incident_id': degatsMateriels['incident_id'],
      'user_saisie': degatsMateriels['user_saisie'],
      'created_at': degatsMateriels['created_at'],
    };

    // Add ID to the map if it exists in the input data
    if (degatsMateriels.containsKey('idincident_degats_materiels')) {
      dataToInsert['idincident_degats_materiels'] =
          degatsMateriels['idincident_degats_materiels'];
    }

    // Add id_server if it exists
    if (degatsMateriels.containsKey('id_server')) {
      dataToInsert['id_server'] = degatsMateriels['id_server'];
    }

    // Add updated_at if it exists
    if (degatsMateriels.containsKey('updated_at')) {
      dataToInsert['updated_at'] = degatsMateriels['updated_at'];
    }

    // Add user_update if it exists
    if (degatsMateriels.containsKey('user_update')) {
      dataToInsert['user_update'] = degatsMateriels['user_update'];
    }

    return await db.insert(
      'incident_degats_materiels',
      dataToInsert,
      conflictAlgorithm: ConflictAlgorithm
          .replace, // This will replace existing records with the same ID
    );
  }

  Future<int> insertResponsableSaisi(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('responsable_saisi', data);
  }

  Future<List<Map<String, dynamic>>> getAllIncidentDegatsMateriels() async {
    final db = await database;
    return await db.query('incident_degats_materiels');
  }

  Future<int> updateIncidentDegatsMateriels(
      int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'incident_degats_materiels',
      data,
      where: 'idincident_degats_materiels = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIncidentDegatsMateriels(int id) async {
    final db = await database;
    return await db.delete(
      'incident_degats_materiels',
      where: 'idincident_degats_materiels = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertResponsable(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'responsable_saisi',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAlertIdServer({
    required int idFicheAlert,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'alerte',
      {'id_server': idServer},
      where: 'idfiche_alert = ?',
      whereArgs: [idFicheAlert],
    );

    return result;
  }

  static Future<List<Map<String, dynamic>>> getVehiculesByAccidentId(
      int accidentId) async {
    final db = await DatabaseHelper().database;

    return await db.query(
      'fiche_accident_vehicule',
      where: 'accident_id = ?',
      whereArgs: [accidentId],
    );
  }

  static Future<List<Map<String, dynamic>>> getVictimeByAccidentId(
      int accidentId) async {
    final db = await DatabaseHelper().database;

    return await db.query(
      'fiche_accident_victime',
      where: 'accident_id = ?',
      whereArgs: [accidentId],
    );
  }

  static Future<List<Map<String, dynamic>>> getVictimeByIncidentId(
      int incidentId) async {
    final db = await DatabaseHelper().database;

    return await db.query(
      'fiche_incident_victime',
      where: 'incident_id = ?',
      whereArgs: [incidentId],
    );
  }

  Future<Map<String, dynamic>?> getVehiculeByIdLocal(int idLocal) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      fiche_accident_vehicule
    where idfiche_accident_vehicule=? limit 1
    ''', [idLocal]);

    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> getDegatsMaterielsByAccidentId(
      int accidentId) async {
    final db = await DatabaseHelper().database;

    return await db.query(
      'accident_degats_materiels',
      where: 'accident_id = ?',
      whereArgs: [accidentId],
    );
  }

  static Future<List<Map<String, dynamic>>> getDegatsMaterielsByIncidentId(
      int incidentId) async {
    final db = await DatabaseHelper().database;

    return await db.query(
      'incident_degats_materiels',
      where: 'incident_id = ?',
      whereArgs: [incidentId],
    );
  }

  Future<int> updateVehiculeIdServer({
    required int idFicheAccidentVehicule,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_accident_vehicule',
      {'id_server': idServer},
      where: 'idfiche_accident_vehicule = ?',
      whereArgs: [idFicheAccidentVehicule],
    );

    return result;
  }

  Future<int> updateSignalementIdServer({
    required String tablename,
    required int signalementID,
    required int signalementIdServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      tablename,
      {'signalement_id_server': signalementIdServer},
      where: 'signalement_id = ?',
      whereArgs: [signalementID],
    );

    return result;
  }

  Future<int> updateResponsableSaisiIdServer({
    required int id,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      "responsable_saisi",
      {'id_server': idServer},
      where: 'id = ?',
      whereArgs: [id],
    );

    return result;
  }

  Future<int> updateFicheAccidentIdServer({
    required int idFicheAccident,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_accident',
      {'id_server': idServer},
      where: 'idfiche_accident = ?',
      whereArgs: [idFicheAccident],
    );

    return result;
  }

  Future<int> updateFicheAccidentSignalementIdServer({
    required int idFicheAccident,
    required int signalementIdServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_accident',
      {'signalement_id_server': signalementIdServer},
      where: 'idfiche_accident = ?',
      whereArgs: [idFicheAccident],
    );

    return result;
  }

  Future<int> updateFicheIncidentIdServer({
    required int idFicheIncident,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_incident',
      {'id_server': idServer},
      where: 'idfiche_incident = ?',
      whereArgs: [idFicheIncident],
    );

    return result;
  }

  Future<int> updateFicheIncidentSignalementIdServer({
    required int idFicheIncident,
    required int signalementIdServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_incident',
      {'signalement_id_server': signalementIdServer},
      where: 'idfiche_incident = ?',
      whereArgs: [idFicheIncident],
    );

    return result;
  }

  Future<int> updateFicheAccidentVictimeIdServer({
    required int idFicheAccidentVictime,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_accident_victime',
      {'id_server': idServer},
      where: 'idfiche_accident_victime = ?',
      whereArgs: [idFicheAccidentVictime],
    );

    return result;
  }

  Future<int> updateFicheIncidentVictimeIdServer({
    required int idFicheIncidentVictime,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'fiche_incident_victime',
      {'id_server': idServer},
      where: 'idincident_victime = ?',
      whereArgs: [idFicheIncidentVictime],
    );

    return result;
  }

  Future<int> updateAccidentDegatsMaterielsIdServer({
    required int idAccidentDM,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'accident_degats_materiels',
      {'id_server': idServer},
      where: 'idaccident_degats_materiels = ?',
      whereArgs: [idAccidentDM],
    );

    return result;
  }

  Future<int> updateIncidentDegatsMaterielsIdServer({
    required int idIncidentDM,
    required int idServer,
  }) async {
    final db = await DatabaseHelper().database;

    int result = await db.update(
      'incident_degats_materiels',
      {'id_server': idServer},
      where: 'idincident_degats_materiels = ?',
      whereArgs: [idIncidentDM],
    );

    return result;
  }

  // Méthode pour insérer une fiche cause dans la table
  Future<int> insertFicheCause(Map<String, dynamic> cause) async {
    final db = await database;
    return await db.insert('fiche_accidents_causes', cause);
  }

  // Méthode pour récupérer toutes les causes d'un accident
  Future<List<Map<String, dynamic>>> getCausesByAccidentId(
      int accidentId) async {
    final db = await database;
    return await db.query(
      'fiche_accidents_causes',
      where: 'accident_id = ?',
      whereArgs: [accidentId],
    );
  }

  Future<List<Alerte>> getAllAlertes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alerte');
    return List.generate(maps.length, (i) => Alerte.fromMap(maps[i]));
  }

  Future<List<Alerte>> getAllAlertesNonSync() async {
    final db = await database;

    // Requête pour récupérer toutes les alertes dont id_server est null
    final List<Map<String, dynamic>> maps = await db.query(
      'alerte',
      where:
          'id_server IS NULL', // Condition pour vérifier si id_server est null
    );

    // Générer une liste d'objets Alerte à partir des résultats
    return List.generate(maps.length, (i) => Alerte.fromMap(maps[i]));
  }

  Future<List<FicheAccident>> getAllFicheAccidents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fiche_accident');
    return List.generate(maps.length, (i) => FicheAccident.fromMap(maps[i]));
  }

  Future<List<FicheIncident>> getAllFicheIncidents() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('fiche_incident');

      List<FicheIncident> incidents = [];

      for (var i = 0; i < maps.length; i++) {
        try {
          print("✅ Traitement de l'entrée $i : ${maps[i]}");
          FicheIncident incident = FicheIncident.fromMap(maps[i]);
          incidents.add(incident);
        } catch (e) {
          print(
              "⚠️ Ignoré : erreur lors de la conversion de l'entrée $i : ${maps[i]}");
          print("Détail de l'erreur : $e");
          // Continue sans ajouter cet incident à la liste
        }
      }

      print("🔹 Nombre total d'incidents valides : ${incidents.length}");
      return incidents;
    } catch (e) {
      print(
          "🚨 Erreur générale lors de la récupération des fiches incidents : $e");
      return [];
    }
  }

  Future<List<FicheAccident>> getAllFicheAccidentsNonSync() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fiche_accident',
      where: 'id_server IS NULL',
    );
    return List.generate(maps.length, (i) => FicheAccident.fromMap(maps[i]));
  }

  Future<String?> _downloadAndSaveImage(
      String imageUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;

        final File localFile = File('$appDocPath/$fileName');

        await localFile.writeAsBytes(response.bodyBytes);

        return localFile.path;
      } else {
        print(
            'Erreur lors du téléchargement de l\'image : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur : $e');
      return null;
    }
  }

  static Future<void> savePermissions(Map<String, dynamic> permissions) async {
    final prefs = await SharedPreferences.getInstance();

    //Incident
    await prefs.setBool(
        "add_incident", permissions["incident"]["add_incident"]);
    await prefs.setBool(
        "view_incident", permissions["incident"]["view_incident"]);
    await prefs.setBool(
        "view_victime_incident", permissions["incident"]["view_victime"]);
    await prefs.setBool(
        "edit_victime_incident", permissions["incident"]["edit_victime"]);

    //Accident
    await prefs.setBool(
        "add_accident", permissions["accident"]["add_accident"]);
    await prefs.setBool(
        "view_accident", permissions["accident"]["view_accident"]);
    await prefs.setBool(
        "view_victime_accident", permissions["accident"]["view_victime"]);
    await prefs.setBool(
        "edit_victime_accident", permissions["accident"]["edit_victime"]);
  }

  Future<void> saveJsonData(Map<String, dynamic> jsonData) async {
    final db = await database;

    // Vérifiez que les données "user" existent dans le JSON
    if (!jsonData.containsKey('data') ||
        !jsonData['data'].containsKey('user')) {
      throw Exception("Les données JSON ne contiennent pas de clé 'user'.");
    }

    // Récupérez l'objet "user" du JSON
    Map<String, dynamic> user = jsonData['data']['user'];
    Map<String, dynamic> permissions = jsonData['data']['user_permission'];

    // Téléchargez et sauvegardez l'image de l'utilisateur localement si elle existe
    if (user['photo'] != null) {
      final String photoUrl = '${global.baseUrlImage}/storage/${user['photo']}';
      String? localPhotoPath =
          await _downloadAndSaveImage(photoUrl, user['prenom'] + ".png");
      if (localPhotoPath != null) {
        user['photo'] = localPhotoPath;
      }
    }

    // Création dynamique de la table "user"
    final userTableColumns = user.keys.map((key) {
      return "$key ${_getSQLiteType(user[key])}";
    }).join(',');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS user (
      $userTableColumns
    )
  ''');

    // Insérez les données dans la table "user"
    await db.insert('user', user, conflictAlgorithm: ConflictAlgorithm.replace);

    // Gestion de la table "structure"
    if (jsonData['data'].containsKey('structure')) {
      List<dynamic> structures = jsonData['data']['structure'];

      // Création dynamique de la table "structure"
      if (structures.isNotEmpty) {
        final structureTableColumns = structures.first.keys.map((key) {
          return "$key ${_getSQLiteType(structures.first[key])}";
        }).join(',');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS structure (
          $structureTableColumns
        )
      ''');

        // Insértion des données dans la table "structure"
        for (var structure in structures) {
          final String imageUrl =
              '${global.baseUrlImage}/storage/${structure['logo']}';
          String? localImagePath = await _downloadAndSaveImage(
              imageUrl, structure['nom_structure'] + ".png");
          if (localImagePath != null) {
            structure['logo'] = localImagePath;
          }
          await db.insert('structure', structure,
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    }

    // Gestion des autres tables dynamiques à partir de "table_config"
    if (jsonData['data'].containsKey('table_config')) {
      Map<String, dynamic> tableConfig = jsonData['data']['table_config'];
      for (var tableName in tableConfig.keys) {
        String tableNameLower = tableName.toLowerCase();
        if (tableName != 'responsable_saisi') {
          //On ne gère pas la table responsable_saisi ici
          List<dynamic> rows = tableConfig[tableName];
          if (rows.isNotEmpty) {
            // Création de la table
            final configTableColumns = rows.first.keys.map((key) {
              return "$key ${_getSQLiteType(rows.first[key])}";
            }).join(',');

            await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableNameLower (
            $configTableColumns
          )
        ''');

            // Insérez les données dans la table dynamique
            for (var row in rows) {
              await db.insert(tableNameLower, row,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
        }
      }
    }

    // Save permissions
    savePermissions(permissions);
  }

  String _getSQLiteType(dynamic value) {
    if (value is int) return "INTEGER";
    if (value is double) return "REAL";
    if (value is String) return "TEXT";
    if (value == null) return "TEXT"; // Par défaut si la valeur est nulle
    throw Exception("Type non supporté: ${value.runtimeType}");
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'user',
      limit: 1,
    );

    // Retourne l'utilisateur si trouvé, sinon null
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVehiculeByAccidentId(
      int accidentId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'fiche_accident_vehicule',
        where: 'accident_id = ?',
        whereArgs: [accidentId],
      );

      return result;
    } catch (e) {
      print('Erreur lors de la récupération des véhicules : $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVictimesByAccidentId(
      int accidentId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'fiche_accident_victime',
        where: 'accident_id = ?',
        whereArgs: [accidentId],
      );
      return result;
    } catch (e) {
      print('Erreur lors de la récupération des victimes : $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVictimesByIncidentId(
      int incidentId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'fiche_incident_victime',
        where: 'incident_id = ?',
        whereArgs: [incidentId],
      );
      return result;
    } catch (e) {
      print('Erreur lors de la récupération des victimes : $e');
      return [];
    }
  }

  Future<int> insertAlert(Map<String, dynamic> alert) async {
    final db = await database;
    return await db.insert('alerte', alert);
  }

  Future<List<Map<String, dynamic>>> fetchAllAlerts() async {
    final db = await database;
    return await db.query('alerte');
  }

  Future<int> updateAlert(int id, Map<String, dynamic> alert) async {
    final db = await database;
    return await db.update(
      'alerte',
      alert,
      where: 'idfiche_alert = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAlert(int id) async {
    final db = await database;
    return await db.delete(
      'alerte',
      where: 'idfiche_alert = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertAccident(Map<String, dynamic> accident) async {
    final db = await database;
    return await db.insert('fiche_accident', accident);
  }

  Future<int> insertIncident(Map<String, dynamic> accident) async {
    final db = await database;
    return await db.insert('fiche_incident', accident);
  }

  Future<List<Map<String, dynamic>>> fetchAllAccidents() async {
    final db = await database;
    return await db.query('fiche_accident');
  }

  Future<List<Map<String, dynamic>>> fetchAllRespSaisis() async {
    final db = await database;
    return await db.query('responsable_saisi');
  }

  Future<List<Map<String, dynamic>>> fetchTableDatas(String tablename) async {
    final db = await database;
    return await db.query(tablename);
  }

  Future<int> updateAccident(int id, Map<String, dynamic> accident) async {
    final db = await database;
    return await db.update(
      'fiche_accident',
      accident,
      where: 'idfiche_accident = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAccident(int id) async {
    final db = await database;
    return await db.delete(
      'fiche_accident',
      where: 'idfiche_accident = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFicheIncidents(Database db) async {
    return await db.query('fiche_incident');
  }

  Future<void> updateFicheIncident(Database db, int idfiche_incident,
      Map<String, dynamic> ficheIncident) async {
    await db.update(
      'fiche_incident',
      ficheIncident,
      where: 'idfiche_incident = ?',
      whereArgs: [idfiche_incident],
    );
  }

  Future<void> deleteFicheIncident(Database db, int idfiche_incident) async {
    await db.delete(
      'fiche_incident',
      where: 'idfiche_incident = ?',
      whereArgs: [idfiche_incident],
    );
  }

  Future<int> insertDegatsMateriels(IncidentDegatsMateriels degats) async {
    final db = await database;
    return await db.insert('incident_degats_materiels', degats.toMap());
  }

  Future<List<IncidentDegatsMateriels>> getAllDegatsMateriels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('incident_degats_materiels');

    return List.generate(maps.length, (i) {
      return IncidentDegatsMateriels.fromMap(maps[i]);
    });
  }

  Future<IncidentDegatsMateriels?> getDegatsMaterielsById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incident_degats_materiels',
      where: 'idincident_degats_materiels = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return IncidentDegatsMateriels.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDegatsMateriels(IncidentDegatsMateriels degats) async {
    final db = await database;
    return await db.update(
      'incident_degats_materiels',
      degats.toMap(),
      where: 'idincident_degats_materiels = ?',
      whereArgs: [degats.id],
    );
  }

  Future<int> deleteDegatsMateriels(int id) async {
    final db = await database;
    return await db.delete(
      'incident_degats_materiels',
      where: 'idincident_degats_materiels = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertFicheAccidentVehicule(
      FicheAccidentVehicule vehicule) async {
    final db = await database;
    return await db.insert('fiche_accident_vehicule', vehicule.toMap());
  }

  Future<List<FicheAccidentVehicule>> getAllFicheAccidentVehicule() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('fiche_accident_vehicule');

    return List.generate(maps.length, (i) {
      return FicheAccidentVehicule.fromMap(maps[i]);
    });
  }

  Future<FicheAccidentVehicule?> getFicheAccidentVehiculeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fiche_accident_vehicule',
      where: 'idfiche_accident_vehicule = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FicheAccidentVehicule.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFicheAccidentVehicule(
      FicheAccidentVehicule vehicule) async {
    final db = await database;
    return await db.update(
      'fiche_accident_vehicule',
      vehicule.toMap(),
      where: 'idfiche_accident_vehicule = ?',
      whereArgs: [vehicule.idficheAccidentVehicule],
    );
  }

  Future<int> deleteFicheAccidentVehicule(int id) async {
    final db = await database;
    return await db.delete(
      'fiche_accident_vehicule',
      where: 'idfiche_accident_vehicule = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertFicheAccidentVictime(FicheAccidentVictime victime) async {
    final db = await database;
    return await db.insert('fiche_accident_victime', victime.toMap());
  }

  Future<List<FicheAccidentVictime>> getAllFicheAccidentVictimes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('fiche_accident_victime');

    return List.generate(maps.length, (i) {
      return FicheAccidentVictime.fromMap(maps[i]);
    });
  }

  Future<FicheAccidentVictime?> getFicheAccidentVictimeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fiche_accident_victime',
      where: 'idfiche_accident_victime = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FicheAccidentVictime.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFicheAccidentVictime(FicheAccidentVictime victime) async {
    final db = await database;
    return await db.update(
      'fiche_accident_victime',
      victime.toMap(),
      where: 'idfiche_accident_victime = ?',
      whereArgs: [victime.idficheAccidentVictime],
    );
  }

  Future<int> deleteFicheAccidentVictime(int id) async {
    final db = await database;
    return await db.delete(
      'fiche_accident_victime',
      where: 'idfiche_accident_victime = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAlertsWithFiches() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        distinct a.*, r.code_alert  , r.prenom_nom
      FROM 
        alerte a left join responsable_saisi r 
      on a.code_alert = r.code_alert
      order by a.date_alert desc
    ''');
  }

  Future<Map<String, dynamic>?> getAlertById(int alertId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        al.*, r.responsable_saisie, r.prenom_nom
      FROM alerte al left join responsable_saisi r
      on al.code_alert = r.code_alert where al.idfiche_alert = ?
      ''', [alertId]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> get2firstsFiches() async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      distinct a.*,   r.prenom_nom
    FROM 
      alerte a left join responsable_saisi r on a.code_alert = r.code_alert
    order by a.date_alert desc limit 2
    ''');
  }

  Future<Map<String, dynamic>?> getFicheAccidentById(int accidentId) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      fiche_accident
    where idfiche_accident=? limit 1
    ''', [accidentId]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getFicheAccidentByIdAlert(
      int signalementID) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      fiche_accident
    where signalement_id=? or signalement_id_server=? limit 1
    ''', [signalementID, signalementID]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getRespSaisiByCodeAlert(
      String codeAlert) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      responsable_saisi
    where code_alert=? limit 1
    ''', [codeAlert]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getFicheVehiculeByAccidentId(
      int accidentId) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      fiche_accident_vehicule
    WHERE 
      accident_id = ?
  ''', [accidentId]);

    return results; // Retourne la liste complète des résultats
  }

  Future<Map<String, dynamic>?> getLibelleDataById(
      String tableName, int id) async {
    final db = await database;
    try {
      // Exécuter une requête pour obtenir la ligne correspondante
      List<Map<String, dynamic>> result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      // Vérifier si un résultat a été trouvé
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      return null;
    }
  }

  Future<int> getTotalAlertsCount() async {
    final db = await database;
    final count = await db.rawQuery('SELECT COUNT(*) as total FROM alerte');
    return count.isNotEmpty ? count.first['total'] as int : 0;
  }

  Future<int> updateFicheAccidentUserUpdate({
    required int idFicheAccident,
    required int userUpdate,
  }) async {
    final db = await database;

    Map<String, dynamic> dataToUpdate = {
      'user_update': userUpdate,
      'updated_at':
          DateTime.now().toIso8601String(), // Mettre aussi à jour updated_at
    };

    // Mettre à jour la table fiche_accident
    return await db.update(
      'fiche_accident', // Nom de la table
      dataToUpdate, // Map contenant les nouvelles valeurs
      where: 'idfiche_accident = ?', // Clause WHERE pour identifier la ligne
      whereArgs: [idFicheAccident], // Valeur de l'ID
    );
  }

  Future<int> updateFicheAccidentPartial(
      {required int idFicheAccident, // ID de la fiche à modifier
      required int idFicheAlert,
      String? collisionEntre,
      int? condiAtmospherique,
      int? typeJour,
      String? agentAssistant,
      int? sectionId,
      int? visibilite,
      int? chaussee}) async {
    final db = await database;

    // Créer un map dynamique avec les champs à modifier
    Map<String, dynamic> dataToUpdate = {};

    if (collisionEntre != null)
      dataToUpdate['collision_entre'] = collisionEntre;
    if (condiAtmospherique != null)
      dataToUpdate['condition_atmospherique'] = condiAtmospherique;
    if (typeJour != null) dataToUpdate['type_jour'] = typeJour;
    if (agentAssistant != null)
      dataToUpdate['agent_assistant'] = agentAssistant;
    if (sectionId != null) dataToUpdate['section_id'] = sectionId;
    if (visibilite != null) dataToUpdate['visibilite'] = visibilite;
    if (chaussee != null) dataToUpdate['chaussee'] = chaussee;

    if (dataToUpdate.isEmpty) {
      return 0;
    }

    return await db.update(
      'fiche_accident', // Nom de la table
      dataToUpdate, // Map contenant les champs à mettre à jour
      where: 'idfiche_accident = ?', // Clause WHERE
      whereArgs: [idFicheAccident], // Valeur de l'ID
    );
  }

  Future<Map<String, dynamic>?> getFicheIncidentByIdAlert(
      int signalementID) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
      *      
    FROM 
      fiche_incident
    where signalement_id=? or signalement_id_server=? limit 1
    ''', [signalementID, signalementID]);

    return results.isNotEmpty ? results.first : null;
  }

  // Récupérer une entrée de mise à jour de victime par code et id
  Future<VictimeUpdate?> getVictimeUpdateByCodeAndId(
      String code, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'victime_update',
      where: 'code = ? AND id = ?',
      whereArgs: [code, id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return VictimeUpdate.fromMap(result.first);
    }
    return null;
  }

  // Mettre à jour ou insérer une entrée de mise à jour de victime
  Future<int> updateVictimeUpdate(VictimeUpdate victimeUpdate) async {
    final db = await database;

    // Vérifier si l'entrée existe déjà
    final existingEntry =
        await getVictimeUpdateByCodeAndId(victimeUpdate.code, victimeUpdate.id);

    if (existingEntry != null) {
      // Mise à jour d'une entrée existante
      return await db.update(
        'victime_update',
        victimeUpdate.toMap(),
        where: 'code = ? AND id = ?',
        whereArgs: [victimeUpdate.code, victimeUpdate.id],
      );
    } else {
      // Insertion d'une nouvelle entrée
      return await db.insert('victime_update', victimeUpdate.toMap());
    }
  }

  // Mettre à jour le lieu d'évacuation d'une victime d'incident
  Future<int> updateIncidentVictimeEvacuation(
      int victimeId, String newLocation) async {
    final db = await database;
    return await db.update(
      'fiche_incident_victime',
      {'structure_evacuation': newLocation},
      where: 'idincident_victime = ?',
      whereArgs: [victimeId],
    );
  }

  // Mettre à jour le lieu d'évacuation d'une victime d'accident
  Future<int> updateAccidentVictimeEvacuation(
      int victimeId, String newLocation) async {
    final db = await database;
    return await db.update(
      'fiche_accident_victime',
      {
        'structure_sanitaire_evac': newLocation,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'idfiche_accident_victime = ?',
      whereArgs: [victimeId],
    );
  }

  Future<String?> getUpdatedEvacuationLocation(int victimeId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'victime_update',
      where: 'id = ?',
      whereArgs: [victimeId],
      columns: ['structure_evacuation'],
    );

    return result.isNotEmpty ? result.first['structure_evacuation'] : null;
  }
}
