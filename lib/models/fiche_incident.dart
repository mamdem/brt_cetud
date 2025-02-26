import 'package:intl/intl.dart';


class FicheIncident {
    int? idficheIncident;
    int? idServer;
    String? libelle;
    int? typeIncidentId;
    int? userId;
    int? signalementId;
    double? positionLat;
    double? positionLong;
    int? voieCorridorOuiNon;
    String? lieuCorridor;
    int? sectionId;
    DateTime? dateHeure;
    int? interruptionService;
    DateTime? dateReprise;
    int? busOperateurImplique;
    String? matriculeBus;
    int? autresVehiculeOuiNon;
    int? mortel;
    int? nbMort;
    int? blesse;
    int? nbBlesse;
    int? typeJour;
    int? userSaisie;
    int? userUpdate;
    int? userDelete;
    DateTime? createdAt;
    DateTime? updatedAt;
    DateTime? deletedAt;

    FicheIncident({
      this.idficheIncident,
      this.idServer,
      this.libelle,
      this.typeIncidentId,
      this.userId,
      this.signalementId,
      this.positionLat,
      this.positionLong,
      this.voieCorridorOuiNon,
      this.lieuCorridor,
      this.sectionId,
      this.dateHeure,
      this.interruptionService,
      this.dateReprise,
      this.busOperateurImplique,
      this.matriculeBus,
      this.autresVehiculeOuiNon,
      this.mortel,
      this.nbMort,
      this.blesse,
      this.nbBlesse,
      this.typeJour,
      this.userSaisie,
      this.userUpdate,
      this.userDelete,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
    });

    Map<String, dynamic> toMap() {
      return {
        'idfiche_incident': idficheIncident,
        'id_server': idServer,
        'libelle': libelle,
        'type_incident_id': typeIncidentId,
        'user_id': userId,
        'signalement_id': signalementId,
        'position_lat': positionLat,
        'position_long': positionLong,
        'voie_corridor_oui_non': voieCorridorOuiNon,
        'lieu_corridor': lieuCorridor,
        'section_id': sectionId,
        'date_heure': dateHeure?.toIso8601String(),
        'interruption_service': interruptionService,
        'date_reprise': dateReprise?.toIso8601String(),
        'bus_operateur_implique': busOperateurImplique,
        'matricule_bus': matriculeBus,
        'autres_vehicule_oui_non': autresVehiculeOuiNon,
        'mortel': mortel,
        'nb_mort': nbMort,
        'blesse': blesse,
        'nb_blesse': nbBlesse,
        'type_jour': typeJour,
        'user_saisie': userSaisie,
        'user_update': userUpdate,
        'user_delete': userDelete,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };
    }

    factory FicheIncident.fromMap(Map<String, dynamic> map) {
      return FicheIncident(
        idficheIncident: map['idfiche_incident'],
        idServer: map['id_server'],
        libelle: map['libelle'],
        typeIncidentId: map['type_incident_id'],
        userId: map['user_id'],
        signalementId: map['signalement_id'],
        positionLat: map['position_lat'],
        positionLong: map['position_long'],
        voieCorridorOuiNon: map['voie_corridor_oui_non'],
        lieuCorridor: map['lieu_corridor'],
        sectionId: map['section_id'],
        dateHeure: map['date_heure'] != null ? DateTime.parse(map['date_heure']) : null,
        interruptionService: map['interruption_service'],
        dateReprise: map['date_reprise'] != null ? DateTime.parse(map['date_reprise']) : null,
        busOperateurImplique: map['bus_operateur_implique'],
        matriculeBus: map['matricule_bus'],
        autresVehiculeOuiNon: map['autres_vehicule_oui_non'],
        mortel: map['mortel'],
        nbMort: map['nb_mort'],
        blesse: map['blesse'],
        nbBlesse: map['nb_blesse'],
        typeJour: map['type_jour'],
        userSaisie: map['user_saisie'],
        userUpdate: map['user_update'],
        userDelete: map['user_delete'],
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
        deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      );
    }

    factory FicheIncident.fromMapSansDateConvert(Map<String, dynamic> map) {
      return FicheIncident(
        idficheIncident: map['idfiche_incident'],
        idServer: map['id_server'],
        libelle: map['libelle'],
        typeIncidentId: map['type_incident_id'],
        userId: map['user_id'],
        signalementId: map['signalement_id'],
        positionLat: map['position_lat'],
        positionLong: map['position_long'],
        voieCorridorOuiNon: map['voie_corridor_oui_non'],
        lieuCorridor: map['lieu_corridor'],
        sectionId: map['section_id'],
        dateHeure: map['date_heure'] != null ? DateTime.parse(map['date_heure']) : null,
        interruptionService: map['interruption_service'],
        dateReprise: map['date_reprise'] != null ? DateTime.parse(map['date_reprise']) : null,
        busOperateurImplique: map['bus_operateur_implique'],
        matriculeBus: map['matricule_bus'],
        autresVehiculeOuiNon: map['autres_vehicule_oui_non'],
        mortel: map['mortel'],
        nbMort: map['nb_mort'],
        blesse: map['blesse'],
        nbBlesse: map['nb_blesse'],
        typeJour: map['type_jour'],
        userSaisie: map['user_saisie'],
        userUpdate: map['user_update'],
        userDelete: map['user_delete'],
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
        updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
        deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      );
    }
  }