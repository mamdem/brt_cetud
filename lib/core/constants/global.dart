import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as geocodingLocation;
import 'package:brt_mobile/core/constants/global.dart' as global;



//const String baseUrl = "https://cetud.saytu.pro/api";
//const String baseUrlImage = "https://cetud.saytu.pro";
//const String baseUrl = "http://sicacetud.groupesoterco.com/api";
//const String baseUrlImage = "http://sicacetud.groupesoterco.com";
const String baseUrl = "https://systemecartographie.cetud.sn/api";
const String baseUrlImage = "https://systemecartographie.cetud.sn";

late String phoneIdentifier;

late String token;

late bool viewIncident, addIncident, editVictimeIncident, viewVictimeIncident,
    viewAccident, addAccident, editVictimeAccident, viewVictimeAccident;

Map<String, dynamic> user={};

Future<void> saveIsConnected(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isConnected", value);
}

Future<void> savePassword(String pwd) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("pwd", pwd);
}

Future<void> saveServerPassword(String pwd) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("serverPwd", pwd);
}


Future<void> getPermissions() async{
  final prefs = await SharedPreferences.getInstance();
  global.viewIncident = await prefs.getBool("view_incident")??false;
  global.viewAccident = await prefs.getBool("view_accident")??false;
  global.addIncident = await prefs.getBool("add_incident")??false;
  global.addAccident = await prefs.getBool("add_accident")??false;
  global.editVictimeIncident = await prefs.getBool("edit_victime_incident")??false;
  global.editVictimeAccident = await prefs.getBool("edit_victime_accident")??false;
  global.viewVictimeIncident = await prefs.getBool("view_victime_incident")??false;
  global.viewVictimeAccident = await prefs.getBool("view_victime_accident")??false;
}

Future<void> saveIsFirstConnection(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isFirstConnection", value);
}

Future<bool?> isConnected() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isConnected")??false;
}


Future<String?> getPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("pwd")??null;
}

Future<bool?> isFirstConnection() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isFirstConnection")??false;
}

String generateAlertCode() {
  DateTime now = DateTime.now();

  String formattedDate = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  String formattedTime = "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  String code = "ALR${formattedDate}T${formattedTime}U${global.user['idusers']}";

  return code;
}


Future<String> getAddressFromLatLong(double latitude, double longitude, int n) async {
  try {
    List<geocodingLocation.Placemark> placemarks = await geocodingLocation.placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      geocodingLocation.Placemark place = placemarks[0];
      List<String> addressParts = [];

      if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
        addressParts.add(place.thoroughfare!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }

      return addressParts.length >= 3 ? addressParts.join(", ") : "No full address available";
    }

    return "No address available";
  } catch (e) {
    print("########## ADDRESS ERROR ########## $e");
    return "No address";
  }
}
