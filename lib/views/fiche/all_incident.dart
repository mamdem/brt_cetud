import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/widgets/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:brt_mobile/core/constants/global.dart' as global;
import '../../sqflite/database_helper.dart';


class AllIncident extends StatefulWidget {
  const AllIncident({Key? key}) : super(key: key);

  @override
  _AllIncidentState createState() => _AllIncidentState();
}

class _AllIncidentState extends State<AllIncident> {
  List<Map<String, dynamic>> _incidents = [];
  bool _isLoading = true;

  String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return Jiffy(dateTime).format("dd MMM yyyy 'à' HH:mm");
    } catch (e) {
      return 'Date invalide';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    final db = DatabaseHelper();
    final incidents = await db.getAlertsWithFiches();

    setState(() {
      _incidents = incidents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tous les Incidents"),
        centerTitle: true,
        backgroundColor: AppColors.appColor,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _incidents.isEmpty
          ? const Center(
        child: Text(
          "Aucun incident enregistré.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];

          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
            child: FutureBuilder<String>(
              future: (incident['position_lat'] != null && incident['position_long'] != null)
                  ? global.getAddressFromLatLong(incident['position_lat'], incident['position_long'], 2)
                  : Future.value("Coordonnées indisponibles"),
              builder: (context, snapshot) {
                print("################## ${incident['position_lat']}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IncidentCard(
                    idficheAlert: incident['idfiche_alert'],
                    title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                    location: incident['voie'] == 43  ? "Corridor: Chargement..." : "Hors Corridor: Chargement...",
                    time: formatDate(incident['date_alert']),
                    isAffected: incident['user_update'] != null,
                    isIncident: !(incident['type_alert'] == 41),
                    isSynced: incident['id_server']!=null,
                  );
                } else if (snapshot.hasError) {
                  return IncidentCard(
                    idficheAlert: incident['idfiche_alert'],
                    title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                    location: incident['voie'] == 43 ? "Corridor: Adresse indisponible" : "Hors Corridor: Adresse indisponible",
                    time: formatDate(incident['date_alert']),
                    isAffected: incident['user_update'] != null,
                    isIncident: !(incident['type_alert'] == 41),
                    isSynced: incident['id_server']!=null,
                  );
                } else {
                  return IncidentCard(
                    idficheAlert: incident['idfiche_alert'],
                    title: incident['type_alert'] == 41 ? 'Accident' : 'Incident',
                    location: incident['voie'] == 43
                        ? "Corridor: : ${snapshot.data!}"
                        : "Hors Corridor: ${snapshot.data!}",
                    time: formatDate(incident['date_alert']),
                    isAffected: incident['user_update'] != null,
                    isIncident: !(incident['type_alert'] == 41),
                    isSynced: incident['id_server']!=null,
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
