import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brt_mobile/core/utils/app_colors.dart';
import 'package:brt_mobile/views/auth/login_screen.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../../res/constant/app_assets.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    //_uninstallLocalData();
    _startImageCarousel();
  }

  Future<void> _uninstallLocalData() async {
    await handleAppReinstallation();
  }

  void _startImageCarousel() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage =
              (_currentPage + 1) % 3; // 3 correspond au nombre total d'images
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startImageCarousel(); // Répéter l'animation
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Supprime les données locales si l'application a été réinstallée
  Future<void> handleAppReinstallation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifie si l'application a déjà été installée
    bool? isFirstInstall = prefs.getBool('is_first_install');

    if (isFirstInstall == null || isFirstInstall == false) {
      print(
          "🔴 Nouvelle installation détectée ! Suppression des données locales...");
      await clearLocalData(); // Supprime les données
      await prefs.setBool('is_first_install', true); // Marque l'installation
    } else {
      print("🟢 Application déjà installée, aucune suppression nécessaire.");
    }
  }

  /// Supprime toutes les données locales (SharedPreferences + SQLite)
  Future<void> clearLocalData() async {
    // Supprime les préférences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("✅ SharedPreferences supprimés.");

    // Supprime la base de données SQLite
    String dbPath = join(await getDatabasesPath(), 'my_database.db');
    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
      print("✅ Base de données SQLite supprimée.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(AppAssets.brt_logo),
                  width: 150.0,
                  height: 150.0,
                ),
              ],
            ),
          ),
          // Main Content Section
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: 3, // Nombre d'images dans le carrousel
                  itemBuilder: (context, index) {
                    // Définir les images à afficher
                    List<String> images = [
                      'assets/images/start_image.jpg',
                      'assets/images/cetud1.png',
                      'assets/images/start_image.jpg',
                    ];

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.appColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          images[
                              index], // Utiliser l'image correspondant à l'index
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                'Collectez vos',
                style: TextStyle(
                  color: AppColors.appColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'DONNÉES D’ACCIDENTS',
                style: TextStyle(
                  color: AppColors.appColor,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Fiable et sécurisé !',
                style: TextStyle(
                  color: AppColors.appColor,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3, // Nombre d'indicateurs
                  (index) => Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.appColor
                          : Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Buttons Section
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(LoginScreen(), transition: Transition.rightToLeft);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'CONNEXION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
            ],
          ),
          // Footer Section
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'confidentialité',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  '–',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                const Text(
                  'à propos',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
