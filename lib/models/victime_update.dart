class VictimeUpdate {
  int id;
  String code;
  String structureEvacuation;

  VictimeUpdate({
    required this.id,
    required this.code,
    required this.structureEvacuation,
  });

  // Conversion d'une ligne de la base de données en un objet
  factory VictimeUpdate.fromMap(Map<String, dynamic> map) {
    return VictimeUpdate(
      id: map['id'],
      code: map['code'],
      structureEvacuation: map['structure_evacuation'],
    );
  }

  // Conversion d'un objet en une ligne pour l'insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'structure_evacuation': structureEvacuation,
    };
  }
}
