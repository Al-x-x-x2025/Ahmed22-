import 'dart:typed_data';

class AppInfo {
  final String name;
  final String packageName;
  final Uint8List? appIcon;
  final bool isSystemApp;
  
  AppInfo({
    required this.name,
    required this.packageName,
    this.appIcon,
    this.isSystemApp = false,
  });
  
  @override
  String toString() {
    return 'AppInfo(name: $name, packageName: $packageName, isSystemApp: $isSystemApp)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppInfo &&
        other.name == name &&
        other.packageName == packageName;
  }
  
  @override
  int get hashCode {
    return name.hashCode ^ packageName.hashCode;
  }
  
  // Helper method to get display name
  String get displayName {
    // Clean up app name for display
    return name.replaceAll(RegExp(r'[^\w\s\؀-\u06FF]'), '').trim();
  }
  
  // Helper method to check if app is commonly used
  bool get isCommonApp {
    final commonApps = [
      'whatsapp',
      'telegram',
      'instagram',
      'facebook',
      'twitter',
      'youtube',
      'chrome',
      'gmail',
      'maps',
      'camera',
      'gallery',
      'photos',
      'phone',
      'messages',
      'settings',
    ];
    
    return commonApps.any((app) => 
      packageName.toLowerCase().contains(app) || 
      name.toLowerCase().contains(app)
    );
  }
}