import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart' as geocodingLocation;
import 'package:brt_mobile/core/constants/global.dart' as global;

const String baseUrl = "https://cetud.saytu.pro/api";
//const String baseUrl = "http://sicacetud.groupesoterco.com/api";

late String phoneIdentifier;

late String token;

Map<String, dynamic> user={};

Future<void> saveIsConnected(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isConnected", value);
}

Future<void> savePassword(String pwd) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("pwd", pwd);
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
  try{
    List<geocodingLocation.Placemark> placemarks = await geocodingLocation.placemarkFromCoordinates(latitude, longitude);
    String address = "";
    if (placemarks.isNotEmpty) {
      geocodingLocation.Placemark place = placemarks[0];

      if (n==1) {
        address = "${place.subLocality}";
      } else {
        address = "${place.subLocality}, ${place.locality}";
      }
      print("##########ADRESS#############$address");
      return address;
    }

    return "No address available";
  }catch(e){
    print("##########ADRESS#############$e");
    return "No address";
  }

}