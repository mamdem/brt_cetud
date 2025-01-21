class AccidentDegatsMateriels {
  int? id;
  int? idServer;
  String libelleMateriels;
  String? photos;
  int accidentId;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  AccidentDegatsMateriels({
    this.id,
    this.idServer,
    required this.libelleMateriels,
    this.photos,
    required this.accidentId,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Conversion de l'objet en Map
  Map<String, dynamic> toMap() {
    return {
      'idaccident_degats_materiels': id,
      'id_server': idServer,
      'libelle_materiels': libelleMateriels,
      'photos': photos,
      'accident_id': accidentId,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }

  // Conversion d'un Map en objet
  factory AccidentDegatsMateriels.fromMap(Map<String, dynamic> map) {
    return AccidentDegatsMateriels(
      id: map['idaccident_degats_materiels'],
      idServer: map['id_server'],
      libelleMateriels: map['libelle_materiels'],
      photos: map['photos'],
      accidentId: map['accident_id'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      deletedAt: map['deleted_at'],
    );
  }
}
