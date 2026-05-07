import 'package:flutter/material.dart';

class AppConfig {
  // Singleton pattern for simplicity in this demo/dashboard
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  String schoolName = "SI Madrasah";
  String headmasterName = "H. Ahmad Syaifuddin, M.Pd";
  
  // In a real app, these would be URLs or local file paths from Cloudflare R2
  String logoPath = ""; 
  String iconPath = "";

  // Note: For a real Flutter app, we would use ValueNotifier or a State Management library
  // but since we are focusing on UI/Layout as a pair programmer, we will keep it simple.
}

final appConfig = AppConfig();
