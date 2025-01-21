class FicheAccidentVictime {
  int? idficheAccidentVictime;
  int? idServer;
  int accidentId;
  int? vehicleId;
  String? prenom;
  String? nom;
  int? age;
  String? tel;
  String? etatVictime; // 'b' ou 'm'
  String? structureSanitaireEvac;
  String? statutGuerison; // 'e', 'g', ou autre
  DateTime? dateGuerison;
  String? numPv;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? natureBlessure;
  int? conscientInconscient; // 35 (conscient), 36 (inconscient), etc.
  int? positionVictime;
  String? filiationPrenomPere;
  String? filiationPrenomNomMere;
  String? accompagnantPrenom;
  String? accompagnantNom;
  String? accompagnantTel;

  FicheAccidentVictime({
    this.idficheAccidentVictime,
    this.idServer,
    required this.accidentId,
    this.vehicleId,
    this.prenom,
    this.nom,
    this.age,
    this.tel,
    this.etatVictime,
    this.structureSanitaireEvac,
    this.statutGuerison,
    this.dateGuerison,
    this.numPv,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.natureBlessure,
    this.conscientInconscient,
    this.positionVictime,
    this.filiationPrenomPere,
    this.filiationPrenomNomMere,
    this.accompagnantPrenom,
    this.accompagnantNom,
    this.accompagnantTel,
  });

  // Méthode pour convertir une Map (issue de SQLite) en objet Dart
  factory FicheAccidentVictime.fromMap(Map<String, dynamic> map) {
    return FicheAccidentVictime(
      idficheAccidentVictime: map['idfiche_accident_victime'],
      idServer: map['id_server'],
      accidentId: map['accident_id'],
      vehicleId: map['vehicle_id'],
      prenom: map['prenom'],
      nom: map['nom'],
      age: map['age'],
      tel: map['tel'],
      etatVictime: map['etat_victime'],
      structureSanitaireEvac: map['structure_sanitaire_evac'],
      statutGuerison: map['statut_guerison'],
      dateGuerison: map['date_guerison'] != null
          ? DateTime.parse(map['date_guerison'])
          : null,
      numPv: map['num_pv'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'])
          : null,
      natureBlessure: map['nature_blessure'],
      conscientInconscient: map['conscient_inconscient'],
      positionVictime: map['position_victime'],
      filiationPrenomPere: map['filiation_prenom_pere'],
      filiationPrenomNomMere: map['filiation_prenom_nom_mere'],
      accompagnantPrenom: map['accompagnant_prenom'],
      accompagnantNom: map['accompagnant_nom'],
      accompagnantTel: map['accompagnant_tel'],
    );
  }

  // Méthode pour convertir un objet Dart en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'idfiche_accident_victime': idficheAccidentVictime,
      'id_server': idServer,
      'accident_id': accidentId,
      'vehicle_id': vehicleId,
      'prenom': prenom,
      'nom': nom,
      'age': age,
      'tel': tel,
      'etat_victime': etatVictime,
      'structure_sanitaire_evac': structureSanitaireEvac,
      'statut_guerison': statutGuerison,
      'date_guerison': dateGuerison?.toIso8601String(),
      'num_pv': numPv,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'nature_blessure': natureBlessure,
      'conscient_inconscient': conscientInconscient,
      'position_victime': positionVictime,
      'filiation_prenom_pere': filiationPrenomPere,
      'filiation_prenom_nom_mere': filiationPrenomNomMere,
      'accompagnant_prenom': accompagnantPrenom,
      'accompagnant_nom': accompagnantNom,
      'accompagnant_tel': accompagnantTel,
    };
  }
}
