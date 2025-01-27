import 'package:brt_mobile/views/fiche/incident/fiche_incident.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/fiche/accident/fiche_accident.dart';

class IncidentCard extends StatelessWidget {
  final int idficheAlert;
  final String title;
  final String location;
  final String time;
  final String? userAffected;
  final bool isIncident;
  final bool isSynced;

  IncidentCard({
    required this.idficheAlert,
    required this.title,
    required this.location,
    required this.time,
    required this.userAffected,
    required this.isIncident,
    this.isSynced = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(isIncident){
          Get.to(DetailsIncident(alertId: idficheAlert,), transition: Transition.rightToLeft);
        }else{
          Get.to(DetailsAccident(alertId: idficheAlert,), transition: Transition.rightToLeft);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isIncident ? Colors.orange : Colors.red,
                width: 3.0,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    if(!isSynced)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync_problem,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Non synchronisé',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if(isSynced)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.green.shade400,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'synchronisé',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 15.0),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16.0,
                    ),
                    SizedBox(width: 4.0),
                    Text(location),
                  ],
                ),
                SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                        (userAffected != null) ? Text(
                          'Resp: $userAffected',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          )
                        : const Text(
                      'Non affecté',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}