class FicheIncidentVictime {
  int? idIncidentVictime;
  int? idServer;
  String? prenom;
  String? nom;
  int? age;
  String? sexe;
  String? tel;
  String? etatVictime;
  int? incidentId;
  String? structureEvacuation;
  String? traumatisme;
  String? dateGuerison;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  FicheIncidentVictime({
    this.idIncidentVictime,
    this.idServer,
    this.prenom,
    this.nom,
    this.age,
    this.sexe,
    this.tel,
    this.etatVictime,
    this.incidentId,
    this.structureEvacuation,
    this.traumatisme,
    this.dateGuerison,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'idincident_victime': idIncidentVictime,
      'id_server': idServer,
      'prenom': prenom,
      'nom': nom,
      'age': age,
      'sexe': sexe,
      'tel': tel,
      'etat_victime': etatVictime,
      'incident_id': incidentId,
      'structure_evacuation': structureEvacuation,
      'traumatisme': traumatisme,
      'date_guerison': dateGuerison,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  factory FicheIncidentVictime.fromMap(Map<String, dynamic> map) {
    return FicheIncidentVictime(
      idIncidentVictime: map['idincident_victime'],
      idServer: map['id_server'],
      prenom: map['prenom'],
      nom: map['nom'],
      age: map['age'],
      sexe: map['sexe'],
      tel: map['tel'],
      etatVictime: map['etat_victime'],
      incidentId: map['incident_id'],
      structureEvacuation: map['structure_evacuation'],
      traumatisme: map['traumatisme'],
      dateGuerison: map['date_guerison'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      deletedAt: map['deleted_at'],
    );
  }
}
