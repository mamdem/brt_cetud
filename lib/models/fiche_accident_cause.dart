class FicheAccidentCause {
  final int? idFicheAccidentsCauses;
  final int accidentId;
  final String causes;
  final String numPv;
  final String? commentaire;
  final int? userSaisie;
  final int? userUpdate;
  final int? userDelete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  FicheAccidentCause({
    this.idFicheAccidentsCauses,
    required this.accidentId,
    required this.causes,
    required this.numPv,
    this.commentaire,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Convertir une Map (provenant de la base de données) en objet FicheAccidentCause
  factory FicheAccidentCause.fromMap(Map<String, dynamic> map) {
    return FicheAccidentCause(
      idFicheAccidentsCauses: map['idfiche_accidents_causes'],
      accidentId: map['accident_id'],
      causes: map['causes'],
      numPv: map['num_pv'],
      commentaire: map['commentaire'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  // Convertir un objet FicheAccidentCause en Map (pour insertion dans la base de données)
  Map<String, dynamic> toMap() {
    return {
      'idfiche_accidents_causes': idFicheAccidentsCauses,
      'accident_id': accidentId,
      'causes': causes,
      'num_pv': numPv,
      'commentaire': commentaire,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
