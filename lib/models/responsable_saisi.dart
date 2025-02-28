class ResponsableSaisi {
  int? id;
  int? idServer;
  String codeAlert;
  int responsableSaisi;
  String prenomNom;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  ResponsableSaisi({
    this.id,
    required this.codeAlert,
    required this.responsableSaisi,
    required this.prenomNom,
    this.idServer,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Méthode pour convertir l'objet en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_server': idServer,
      'code_alert': codeAlert,
      'responsable_saisie': responsableSaisi,
      'prenom_nom': prenomNom,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Méthode pour créer un objet depuis un Map (SQLite ou API)
  factory ResponsableSaisi.fromMap(Map<String, dynamic> map) {
    return ResponsableSaisi(
      id: map['id'],
      idServer: map['id_server'],
      codeAlert: map['code_alert'],
      responsableSaisi: map['responsable_saisie'],
      prenomNom: map['prenom_nom'],
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
    );
  }

  // Méthode pour convertir l'objet en en-têtes pour API
  Map<String, String> toHeaders() {
    return {
      'code_alert': codeAlert,
      'responsable_saisi': responsableSaisi.toString(),
      'prenom_nom': prenomNom,
      'user_saisie': userSaisie?.toString() ?? '',
      'user_update': userUpdate?.toString() ?? '',
      'user_delete': userDelete?.toString() ?? '',
      'created_at': createdAt?.toIso8601String() ?? '',
      'updated_at': updatedAt?.toIso8601String() ?? '',
      'deleted_at': deletedAt?.toIso8601String() ?? '',
    };
  }
}
