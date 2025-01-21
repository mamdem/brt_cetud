class FicheAccidentVehicule {
  int? idficheAccidentVehicule;
  int? idServer;
  int accidentId;
  String matricule;
  String? numCarteGrise;
  int categorieVehicule;
  String? autreVehicule;
  String? autreInformationAdd;
  String prenomChauffeur;
  String nomChauffeur;
  int age;
  String sexe;
  String telChauffeur;
  String? professionConducteur;
  String? filiationPrenomPere;
  String? filiationPrenomNomMere;
  String? domicileConducteur;
  String? numeroPermis;
  DateTime? dateDelivrancePermis;
  int? categoriePermis;
  DateTime? dateImmatriculationVehicule;
  DateTime? dateMiseCirculation;
  String? comportementConducteur;
  String? autresComportement;
  String? prenomNomProprietaire;
  String? numeroAssurance;
  String? assureur;
  int? puissanceVehicule;
  DateTime? dateExpirationAssurance;
  int? largeurVeh;
  int? hauteurVeh;
  int? longueurVeh;
  DateTime? dateDerniereVisite;
  DateTime? dateExpirationVisite;
  int? kilometrage;
  String? etatGenerale;
  int? userSaisie;
  int? userUpdate;
  int? userDelete;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;
  String? eclairage;
  String? avertisseur;
  String? indicateurDirection;
  String? indicateurVitesse;
  String? essuieGlace;
  String? retroviseur;
  String? etatPneueAvant;
  String? etatPneueArriere;
  String? etatParebrise;
  String? positionLevierVitesse;
  int? presencePosteRadio;
  int? positionVolume;

  FicheAccidentVehicule({
    this.idficheAccidentVehicule,
    this.idServer,
    required this.accidentId,
    required this.matricule,
    this.numCarteGrise,
    required this.categorieVehicule,
    this.autreVehicule,
    this.autreInformationAdd,
    required this.prenomChauffeur,
    required this.nomChauffeur,
    required this.age,
    required this.sexe,
    required this.telChauffeur,
    this.professionConducteur,
    this.filiationPrenomPere,
    this.filiationPrenomNomMere,
    this.dateMiseCirculation,
    this.domicileConducteur,
    this.numeroPermis,
    this.dateDelivrancePermis,
    this.categoriePermis,
    this.dateImmatriculationVehicule,
    this.comportementConducteur,
    this.autresComportement,
    this.prenomNomProprietaire,
    this.numeroAssurance,
    this.assureur,
    this.puissanceVehicule,
    this.dateExpirationAssurance,
    this.largeurVeh,
    this.hauteurVeh,
    this.longueurVeh,
    this.dateDerniereVisite,
    this.dateExpirationVisite,
    this.kilometrage,
    this.etatGenerale,
    this.userSaisie,
    this.userUpdate,
    this.userDelete,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.eclairage,
    this.avertisseur,
    this.indicateurDirection,
    this.indicateurVitesse,
    this.essuieGlace,
    this.retroviseur,
    this.etatPneueAvant,
    this.etatPneueArriere,
    this.etatParebrise,
    this.positionLevierVitesse,
    this.presencePosteRadio,
    this.positionVolume,
  });

  // Méthode pour convertir une instance de la classe en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'idfiche_accident_vehicule': idficheAccidentVehicule,
      'id_server': idServer,
      'accident_id': accidentId,
      'matricule': matricule,
      'num_carte_grise': numCarteGrise,
      'categorie_vehicule': categorieVehicule,
      'autre_vehicule': autreVehicule,
      'autre_information_add': autreInformationAdd,
      'prenom_chauffeur': prenomChauffeur,
      'nom_chauffeur': nomChauffeur,
      'age': age,
      'sexe': sexe,
      'tel_chauffeur': telChauffeur,
      'profession_conducteur': professionConducteur,
      'filiation_prenom_pere': filiationPrenomPere,
      'filiation_prenom_nom_mere': filiationPrenomNomMere,
      'domicile_conducteur': domicileConducteur,
      'numero_permis': numeroPermis,
      'date_delivrance_permis': dateDelivrancePermis?.toIso8601String(),
      'date_mise_circulation': dateMiseCirculation?.toIso8601String(),
      'categorie_permis': categoriePermis,
      'date_immatriculation_vehicule': dateImmatriculationVehicule?.toIso8601String(),
      'comportement_conducteur': comportementConducteur,
      'autres_comportement': autresComportement,
      'prenom_nom_proprietaire': prenomNomProprietaire,
      'numero_assurance': numeroAssurance,
      'assureur': assureur,
      'puissance_vehicule': puissanceVehicule,
      'date_expiration_assurance': dateExpirationAssurance?.toIso8601String(),
      'largeur_veh': largeurVeh,
      'hauteur_veh': hauteurVeh,
      'longueur_veh': longueurVeh,
      'date_derniere_visite': dateDerniereVisite?.toIso8601String(),
      'date_expiration_visite': dateExpirationVisite?.toIso8601String(),
      'kilometrage': kilometrage,
      'etat_generale': etatGenerale,
      'user_saisie': userSaisie,
      'user_update': userUpdate,
      'user_delete': userDelete,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'eclairage': eclairage,
      'avertisseur': avertisseur,
      'indicateur_direction': indicateurDirection,
      'indicateur_vitesse': indicateurVitesse,
      'essuie_glace': essuieGlace,
      'retroviseur': retroviseur,
      'etat_pneue_avant': etatPneueAvant,
      'etat_pneue_arriere': etatPneueArriere,
      'etat_parebrise': etatParebrise,
      'position_levier_vitesse': positionLevierVitesse,
      'presence_poste_radio': presencePosteRadio,
      'position_volume': positionVolume,
    };
  }

  // Méthode pour convertir une Map (issue de SQLite) en instance de la classe
  factory FicheAccidentVehicule.fromMap(Map<String, dynamic> map) {
    return FicheAccidentVehicule(
      idficheAccidentVehicule: map['idfiche_accident_vehicule'],
      idServer: map['id_server'],
      accidentId: map['accident_id'],
      matricule: map['matricule'],
      numCarteGrise: map['num_carte_grise'],
      categorieVehicule: map['categorie_vehicule'],
      autreVehicule: map['autre_vehicule'],
      autreInformationAdd: map['autre_information_add'],
      prenomChauffeur: map['prenom_chauffeur'],
      nomChauffeur: map['nom_chauffeur'],
      age: map['age'],
      sexe: map['sexe'],
      telChauffeur: map['tel_chauffeur'],
      professionConducteur: map['profession_conducteur'],
      filiationPrenomPere: map['filiation_prenom_pere'],
      filiationPrenomNomMere: map['filiation_prenom_nom_mere'],
      domicileConducteur: map['domicile_conducteur'],
      numeroPermis: map['numero_permis'],
      dateDelivrancePermis: map['date_delivrance_permis'] != null
          ? DateTime.parse(map['date_delivrance_permis'])
          : null,
      categoriePermis: map['categorie_permis'],
      dateImmatriculationVehicule: map['date_immatriculation_vehicule'] != null
          ? DateTime.parse(map['date_immatriculation_vehicule'])
          : null,
      dateExpirationAssurance: map['date_expiration_assurance'] != null
          ? DateTime.parse(map['date_expiration_assurance'])
          : null,
      dateMiseCirculation: map['date_mise_circulation'] != null
          ? DateTime.parse(map['date_mise_circulation'])
          : null,
      comportementConducteur: map['comportement_conducteur'],
      autresComportement: map['autres_comportement'],
      prenomNomProprietaire: map['prenom_nom_proprietaire'],
      numeroAssurance: map['numero_assurance'],
      assureur: map['assureur'],
      puissanceVehicule: map['puissance_vehicule'],
      largeurVeh: map['largeur_veh'],
      hauteurVeh: map['hauteur_veh'],
      longueurVeh: map['longueur_veh'],
      dateDerniereVisite: map['date_derniere_visite'] != null
          ? DateTime.parse(map['date_derniere_visite'])
          : null,
      dateExpirationVisite: map['date_expiration_visite'] != null
          ? DateTime.parse(map['date_expiration_visite'])
          : null,
      kilometrage: map['kilometrage'],
      etatGenerale: map['etat_generale'],
      userSaisie: map['user_saisie'],
      userUpdate: map['user_update'],
      userDelete: map['user_delete'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      eclairage: map['eclairage'],
      avertisseur: map['avertisseur'],
      indicateurDirection: map['indicateur_direction'],
      indicateurVitesse: map['indicateur_vitesse'],
      essuieGlace: map['essuie_glace'],
      retroviseur: map['retroviseur'],
      etatPneueAvant: map['etat_pneue_avant'],
      etatPneueArriere: map['etat_pneue_arriere'],
      etatParebrise: map['etat_parebrise'],
      positionLevierVitesse: map['position_levier_vitesse'],
      presencePosteRadio: map['presence_poste_radio'],
      positionVolume: map['position_volume'],
    );
  }
}
