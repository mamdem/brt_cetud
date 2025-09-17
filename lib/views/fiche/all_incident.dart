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
  List<Map<String, dynamic>> _filteredIncidents = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  String _typeFilter = 'tous';
  String _syncFilter = 'tous';

  String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return Jiffy.parseFromDateTime(dateTime)
          .format(pattern: "dd MMM yyyy 'à' HH:mm");
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
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredIncidents = _incidents.where((incident) {
      bool matchesType = _typeFilter == 'tous' ||
          (_typeFilter == 'accident' && incident['type_alert'] == 41) ||
          (_typeFilter == 'incident' && incident['type_alert'] != 41);

      bool matchesSync = _syncFilter == 'tous' ||
          (_syncFilter == 'sync' && incident['id_server'] != null) ||
          (_syncFilter == 'nonsync' && incident['id_server'] == null);

      return matchesType && matchesSync;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    'Tous',
                    _typeFilter == 'tous',
                    Icons.all_inclusive,
                    () {
                      setModalState(() {
                        setState(() {
                          _typeFilter = 'tous';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                  _buildFilterChip(
                    'Accidents',
                    _typeFilter == 'accident',
                    Icons.warning_rounded,
                    () {
                      setModalState(() {
                        setState(() {
                          _typeFilter = 'accident';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                  _buildFilterChip(
                    'Incidents',
                    _typeFilter == 'incident',
                    Icons.info_rounded,
                    () {
                      setModalState(() {
                        setState(() {
                          _typeFilter = 'incident';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Synchronisation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip(
                    'Tous',
                    _syncFilter == 'tous',
                    Icons.all_inclusive,
                    () {
                      setModalState(() {
                        setState(() {
                          _syncFilter = 'tous';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                  _buildFilterChip(
                    'Synchronisés',
                    _syncFilter == 'sync',
                    Icons.sync,
                    () {
                      setModalState(() {
                        setState(() {
                          _syncFilter = 'sync';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                  _buildFilterChip(
                    'Non synchronisés',
                    _syncFilter == 'nonsync',
                    Icons.sync_disabled,
                    () {
                      setModalState(() {
                        setState(() {
                          _syncFilter = 'nonsync';
                          _applyFilters();
                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool selected, IconData icon, VoidCallback onTap) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (bool _) => onTap(),
      selectedColor: AppColors.appColor,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      elevation: 0,
      pressElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? AppColors.appColor : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.appColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        "Tous les Incidents",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _fetchIncidents,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      _incidents.length.toString(),
                      Icons.dashboard_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Accidents',
                      _incidents
                          .where((i) => i['type_alert'] == 41)
                          .length
                          .toString(),
                      Icons.warning_rounded,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Incidents',
                      _incidents
                          .where((i) => i['type_alert'] != 41)
                          .length
                          .toString(),
                      Icons.info_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              // Pour gérer l'espace disponible
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1, // Limiter à une ligne
                    overflow: TextOverflow
                        .ellipsis, // Ajouter des ellipses si le texte dépasse
                  ),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Aucun incident correspondant\naux filtres sélectionnés.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildCustomAppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterBottomSheet,
        backgroundColor: AppColors.appColor,
        child: const Icon(Icons.filter_list),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _filteredIncidents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: _filteredIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = _filteredIncidents[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: FutureBuilder<String>(
                        future: (incident['position_lat'] != null &&
                                incident['position_long'] != null)
                            ? global.getAddressFromLatLong(
                                incident['position_lat'],
                                incident['position_long'],
                                2)
                            : Future.value("Coordonnées indisponibles"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return IncidentCard(
                              idficheAlert: incident['idfiche_alert'],
                              title: incident['type_alert'] == 41
                                  ? 'Accident'
                                  : 'Incident',
                              location: incident['voie'] == 1
                                  ? "Corridor: Chargement..."
                                  : "Hors Corridor: Chargement...",
                              time: formatDate(incident['date_alert']),
                              userAffected: incident['prenom_nom'],
                              isIncident: !(incident['type_alert'] == 41),
                              isSynced: incident['id_server'] != null,
                            );
                          } else if (snapshot.hasError) {
                            return IncidentCard(
                              idficheAlert: incident['idfiche_alert'],
                              title: incident['type_alert'] == 41
                                  ? 'Accident'
                                  : 'Incident',
                              location: incident['voie'] == 1
                                  ? "Corridor: Adresse indisponible"
                                  : "Hors Corridor: Adresse indisponible",
                              time: formatDate(incident['date_alert']),
                              userAffected: incident['prenom_nom'],
                              isIncident: !(incident['type_alert'] == 41),
                              isSynced: incident['id_server'] != null,
                            );
                          } else {
                            return IncidentCard(
                              idficheAlert: incident['idfiche_alert'],
                              title: incident['type_alert'] == 41
                                  ? 'Accident'
                                  : 'Incident',
                              location: incident['voie'] == 1
                                  ? "Corridor: ${snapshot.data!}"
                                  : "Hors Corridor: ${snapshot.data!}",
                              time: formatDate(incident['date_alert']),
                              userAffected: incident['prenom_nom'],
                              isIncident: !(incident['type_alert'] == 41),
                              isSynced: incident['id_server'] != null,
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
