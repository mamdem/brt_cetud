class FicheAccident {
  int? idficheAccident;
  int? idServer;
  int? signalemenId;
  int? signalemenIdServer;
  DateTime? dateHeure;
  double? positionLat;
  double? positionLong;
  int? corridorHorCo;
  int? sectionId;
  int? busOperateurImpliOuiNon;
  String? collisionEntre;
  double? pointReferenceLat;
  double? pointReferenceLong;
  int? blesseOuiNon;
  int? nbBlesse;
  int? nbVehiculeImplique;
  int? condiAtmospherique;
  int? typeJour;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? agentAssistant;
  int? conditionAtmospherique;
  int? visibilite;
  int? chaussee;
  int? largeurEclairageVoie;
  String? traceFreinage;
  String? traceFreinagePhoto;
  String? traceSang;
  String? traceSangPhoto;
  String? tracePneue;
  String? tracePneuePhoto;

  FicheAccident({
    this.idficheAccident,
    this.idServer,
    this.signalemenId,
    this.signalemenIdServer,
    this.dateHeure,
    this.positionLat,
    this.positionLong,
    this.corridorHorCo,
    this.sectionId,
    this.busOperateurImpliOuiNon,
    this.collisionEntre,
    this.pointReferenceLat,
    this.pointReferenceLong,
    this.blesseOuiNon,
    this.nbBlesse,
    this.nbVehiculeImplique,
    this.condiAtmospherique,
    this.typeJour,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.agentAssistant,
    this.conditionAtmospherique,
    this.visibilite,
    this.chaussee,
    this.largeurEclairageVoie,
    this.traceFreinage,
    this.traceFreinagePhoto,
    this.traceSang,
    this.traceSangPhoto,
    this.tracePneue,
    this.tracePneuePhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'idfiche_accident': idficheAccident,
      'id_server': idServer,
      'signalement_id': signalemenId,
      'signalement_id_server': signalemenIdServer,
      'date_heure': dateHeure?.toIso8601String(),
      'position_lat': positionLat,
      'position_long': positionLong,
      'corridor_hor_co': corridorHorCo,
      'section_id': sectionId,
      'bus_operateur_impli_oui_non': busOperateurImpliOuiNon,
      'collision_entre': collisionEntre,
      'point_reference_lat': pointReferenceLat,
      'point_reference_long': pointReferenceLong,
      'blesse_oui_non': blesseOuiNon,
      'nb_blesse': nbBlesse,
      'nb_vehicule_implique': nbVehiculeImplique,
      'type_jour': typeJour,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'agent_assistant': agentAssistant,
      'condition_atmospherique': conditionAtmospherique,
      'visibilite': visibilite,
      'chaussee': chaussee,
      'largeur_eclairage_voie': largeurEclairageVoie,
      'trace_freinage': traceFreinage,
      'trace_freinage_photo': traceFreinagePhoto,
      'trace_sang': traceSang,
      'trace_sang_photo': traceSangPhoto,
      'trace_pneue': tracePneue,
      'trace_pneue_photo': tracePneuePhoto,
    };
  }

  factory FicheAccident.fromMap(Map<String, dynamic> map) {
    return FicheAccident(
      idficheAccident: map['idfiche_accident'],
      idServer: map['id_server'],
      signalemenId: map['signalement_id'],
      signalemenIdServer: map['signalement_id_server'],
      dateHeure: map['date_heure'] != null ? DateTime.parse(map['date_heure']) : null,
      positionLat: (map['position_lat'] as num?)?.toDouble(),
      positionLong: (map['position_long'] as num?)?.toDouble(),
      corridorHorCo: map['corridor_hor_co'],
      sectionId: map['section_id'],
      busOperateurImpliOuiNon: map['bus_operateur_impli_oui_non'],
      collisionEntre: map['collision_entre'],
      pointReferenceLat: (map['point_reference_lat'] as num?)?.toDouble(),
      pointReferenceLong: (map['point_reference_long'] as num?)?.toDouble(),
      blesseOuiNon: map['blesse_oui_non'],
      nbBlesse: map['nb_blesse'],
      nbVehiculeImplique: map['nb_vehicule_implique'],
      condiAtmospherique: map['condition_atmospherique'],
      typeJour: map['type_jour'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      agentAssistant: map['agent_assistant'],
      conditionAtmospherique: map['condition_atmospherique'],
      visibilite: map['visibilite'],
      chaussee: map['chaussee'],
      largeurEclairageVoie: map['largeur_eclairage_voie'],
      traceFreinage: map['trace_freinage'],
      traceFreinagePhoto: map['trace_freinage_photo'],
      traceSang: map['trace_sang'],
      traceSangPhoto: map['trace_sang_photo'],
      tracePneue: map['trace_pneue'],
      tracePneuePhoto: map['trace_pneue_photo'],
    );
  }
}
