class Alerte {
  int? idficheAlert;
  int? idServer;
  String? codeAlert;
  int? typeAlert;
  String? autresAlert;
  DateTime? dateAlert;
  int? alerteNiveauId;
  double? positionLat;
  double? positionLong;
  int? busOperateurImplique;
  String? matriculeBus;
  int? voie;
  int? userAlert;
  String? ficheAlertecol;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  int? existenceVictime;
  int? nbVictime;
  int? victimeCons;
  int? victimeIncons;

  Alerte({
    this.idficheAlert,
    this.idServer,
    this.codeAlert,
    this.typeAlert,
    this.autresAlert,
    this.dateAlert,
    this.alerteNiveauId,
    this.positionLat,
    this.positionLong,
    this.busOperateurImplique,
    this.matriculeBus,
    this.voie,
    this.userAlert,
    this.ficheAlertecol,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.existenceVictime,
    this.nbVictime,
    this.victimeCons,
    this.victimeIncons,
  });

  // Conversion en Map
  Map<String, dynamic> toMap() {
    return {
      'idfiche_alert': idficheAlert,
      'id_server': idServer,
      'code_alert': codeAlert,
      'type_alert': typeAlert,
      'autres_alert': autresAlert,
      'date_alert': dateAlert?.toIso8601String(),
      'alerte_niveau_id': alerteNiveauId,
      'position_lat': positionLat,
      'position_long': positionLong,
      'bus_operateur_implique': busOperateurImplique,
      'matricule_bus': matriculeBus,
      'voie': voie,
      'user_alert': userAlert,
      'fiche_alertecol': ficheAlertecol,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'existence_victime': existenceVictime,
      'nb_victime': nbVictime,
      'victime_cons': victimeCons,
      'victime_incons': victimeIncons,
    };
  }

  // Construction depuis Map
  factory Alerte.fromMap(Map<String, dynamic> map) {
    return Alerte(
      idficheAlert: map['idfiche_alert'],
      idServer: map['id_server'],
      codeAlert: map['code_alert'],
      typeAlert: map['type_alert'],
      autresAlert: map['autres_alert'],
      dateAlert: map['date_alert'] != null ? DateTime.parse(map['date_alert']) : null,
      alerteNiveauId: map['alerte_niveau_id'],
      positionLat: map['position_lat'],
      positionLong: map['position_long'],
      busOperateurImplique: map['bus_oparateur_implique'],
      matriculeBus: map['matricule_bus'],
      voie: map['voie'],
      userAlert: map['user_alert'],
      ficheAlertecol: map['fiche_alertecol'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      existenceVictime: map['existence_victime'],
      nbVictime: map['nb_victime'],
      victimeCons: map['victime_cons'],
      victimeIncons: map['victime_incons'],
    );
  }
}