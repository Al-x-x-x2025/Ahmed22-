import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_info.dart';
import '../utils/arabic_text_utils.dart';

class AppLauncherService {
  final List<AppInfo> _installedApps = [];
  bool _isInitialized = false;
  
  List<AppInfo> get installedApps => _installedApps;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    try {
      await _loadInstalledApps();
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('App launcher service initialization error: $e');
      }
      rethrow;
    }
  }
  
  Future<void> _loadInstalledApps() async {
    _installedApps.clear();
    
    try {
      if (Platform.isAndroid) {
        final apps = await InstalledApps.getInstalledApps(
          true, // Include system apps
          true, // Include app info
        );
        
        for (final app in apps) {
          final appInfo = AppInfo(
            name: app.name,
            packageName: app.packageName,
            appIcon: app.icon,
            isSystemApp: false, // Set to false for now
          );
          _installedApps.add(appInfo);
        }
      } else if (Platform.isIOS) {
        // iOS has limitations on getting installed apps
        // We'll add common apps with their URL schemes
        _addCommonIOSApps();
      }
      
      // Sort apps alphabetically
      _installedApps.sort((a, b) => a.name.compareTo(b.name));
      
      if (kDebugMode) {
        print('Loaded ${_installedApps.length} installed apps');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading installed apps: $e');
      }
      
      // Fallback: Add common apps manually
      _addCommonApps();
    }
  }
  
  void _addCommonIOSApps() {
    final commonApps = [
      AppInfo(name: 'WhatsApp', packageName: 'whatsapp://', appIcon: null),
      AppInfo(name: 'Telegram', packageName: 'tg://', appIcon: null),
      AppInfo(name: 'Instagram', packageName: 'instagram://', appIcon: null),
      AppInfo(name: 'Facebook', packageName: 'fb://', appIcon: null),
      AppInfo(name: 'Twitter', packageName: 'twitter://', appIcon: null),
      AppInfo(name: 'YouTube', packageName: 'youtube://', appIcon: null),
      AppInfo(name: 'Photos', packageName: 'photos-redirect://', appIcon: null),
      AppInfo(name: 'Camera', packageName: 'camera://', appIcon: null),
      AppInfo(name: 'Settings', packageName: 'prefs://', appIcon: null),
      AppInfo(name: 'Maps', packageName: 'maps://', appIcon: null),
      AppInfo(name: 'Phone', packageName: 'tel://', appIcon: null),
      AppInfo(name: 'Messages', packageName: 'sms://', appIcon: null),
      AppInfo(name: 'Mail', packageName: 'mailto://', appIcon: null),
      AppInfo(name: 'Safari', packageName: 'http://', appIcon: null),
      AppInfo(name: 'App Store', packageName: 'itms-apps://', appIcon: null),
    ];
    
    _installedApps.addAll(commonApps);
  }
  
  void _addCommonApps() {
    final commonApps = [
      AppInfo(name: 'WhatsApp', packageName: 'com.whatsapp', appIcon: null),
      AppInfo(name: 'Telegram', packageName: 'org.telegram.messenger', appIcon: null),
      AppInfo(name: 'Instagram', packageName: 'com.instagram.android', appIcon: null),
      AppInfo(name: 'Facebook', packageName: 'com.facebook.katana', appIcon: null),
      AppInfo(name: 'Twitter', packageName: 'com.twitter.android', appIcon: null),
      AppInfo(name: 'YouTube', packageName: 'com.google.android.youtube', appIcon: null),
      AppInfo(name: 'Gallery', packageName: 'com.google.android.apps.photos', appIcon: null),
      AppInfo(name: 'Camera', packageName: 'com.android.camera', appIcon: null),
      AppInfo(name: 'Settings', packageName: 'com.android.settings', appIcon: null),
      AppInfo(name: 'Maps', packageName: 'com.google.android.apps.maps', appIcon: null),
      AppInfo(name: 'Phone', packageName: 'com.android.dialer', appIcon: null),
      AppInfo(name: 'Messages', packageName: 'com.android.messaging', appIcon: null),
      AppInfo(name: 'Gmail', packageName: 'com.google.android.gm', appIcon: null),
      AppInfo(name: 'Chrome', packageName: 'com.android.chrome', appIcon: null),
      AppInfo(name: 'Play Store', packageName: 'com.android.vending', appIcon: null),
    ];
    
    _installedApps.addAll(commonApps);
  }
  
  Future<bool> launchApp(String appName) async {
    if (!_isInitialized) {
      throw Exception('App launcher service not initialized');
    }
    
    try {
      // Normalize app name for searching
      final normalizedName = ArabicTextUtils.normalizeAppName(appName);
      
      // Find app by name (exact match first)
      AppInfo? targetApp = _findAppByName(normalizedName);
      
      if (targetApp == null) {
        // Try fuzzy search
        targetApp = _findAppByFuzzyMatch(normalizedName);
      }
      
      if (targetApp == null) {
        if (kDebugMode) {
          print('App not found: $appName');
        }
        return false;
      }
      
      // Launch the app
      return await _launchAppByPackage(targetApp);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error launching app: $e');
      }
      return false;
    }
  }
  
  AppInfo? _findAppByName(String appName) {
    // Check Arabic name mapping first
    final englishName = ArabicTextUtils.getEnglishAppName(appName);
    
    // Search by English name
    for (final app in _installedApps) {
      if (app.name.toLowerCase() == englishName.toLowerCase()) {
        return app;
      }
    }
    
    // Search by original name
    for (final app in _installedApps) {
      if (app.name.toLowerCase() == appName.toLowerCase()) {
        return app;
      }
    }
    
    return null;
  }
  
  AppInfo? _findAppByFuzzyMatch(String appName) {
    final englishName = ArabicTextUtils.getEnglishAppName(appName);
    
    // Fuzzy match with similarity threshold
    for (final app in _installedApps) {
      if (app.name.toLowerCase().contains(englishName.toLowerCase()) ||
          englishName.toLowerCase().contains(app.name.toLowerCase())) {
        return app;
      }
    }
    
    return null;
  }
  
  Future<bool> _launchAppByPackage(AppInfo app) async {
    try {
      if (Platform.isAndroid) {
        // Try to launch using Android Intent
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: app.packageName,
          category: 'android.intent.category.LAUNCHER',
        );
        
        await intent.launch();
        return true;
        
      } else if (Platform.isIOS) {
        // Try to launch using URL scheme
        final url = Uri.parse(app.packageName);
        final canLaunch = await canLaunchUrl(url);
        
        if (canLaunch) {
          return await launchUrl(url);
        }
      }
      
      return false;
      
    } catch (e) {
      if (kDebugMode) {
        print('Error launching app ${app.name}: $e');
      }
      
      // Fallback: try to launch using URL launcher
      try {
        if (Platform.isAndroid) {
          final url = Uri.parse('market://details?id=${app.packageName}');
          return await launchUrl(url);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Fallback launch failed: $e');
        }
      }
      
      return false;
    }
  }
  
  List<AppInfo> searchApps(String query) {
    if (query.isEmpty) return _installedApps;
    
    final normalizedQuery = ArabicTextUtils.normalizeAppName(query);
    final englishQuery = ArabicTextUtils.getEnglishAppName(normalizedQuery);
    
    return _installedApps.where((app) {
      return app.name.toLowerCase().contains(englishQuery.toLowerCase()) ||
             app.name.toLowerCase().contains(normalizedQuery.toLowerCase());
    }).toList();
  }
  
  Future<void> refreshInstalledApps() async {
    await _loadInstalledApps();
  }
}
