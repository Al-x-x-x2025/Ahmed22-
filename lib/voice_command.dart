
enum CommandAction {
  openApp,
  closeApp,
  searchApp,
  unknown,
}

class VoiceCommand {
  final String rawCommand;
  final String cleanCommand;
  final CommandAction action;
  final String appName;
  final bool isValid;
  final String? errorMessage;
  final DateTime timestamp;
  
  VoiceCommand({
    required this.rawCommand,
    required this.cleanCommand,
    required this.action,
    required this.appName,
    required this.isValid,
    this.errorMessage,
  }) : timestamp = DateTime.now();
  
  // Factory constructor for invalid commands
  factory VoiceCommand.invalid(String errorMessage) {
    return VoiceCommand(
      rawCommand: '',
      cleanCommand: '',
      action: CommandAction.unknown,
      appName: '',
      isValid: false,
      errorMessage: errorMessage,
    );
  }
  
  // Factory constructor for app opening commands
  factory VoiceCommand.openApp(String rawCommand, String appName) {
    return VoiceCommand(
      rawCommand: rawCommand,
      cleanCommand: rawCommand.trim().toLowerCase(),
      action: CommandAction.openApp,
      appName: appName,
      isValid: true,
    );
  }
  
  @override
  String toString() {
    return 'VoiceCommand(action: $action, appName: $appName, isValid: $isValid)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VoiceCommand &&
        other.rawCommand == rawCommand &&
        other.action == action &&
        other.appName == appName &&
        other.isValid == isValid;
  }
  
  @override
  int get hashCode {
    return rawCommand.hashCode ^ 
           action.hashCode ^ 
           appName.hashCode ^ 
           isValid.hashCode;
  }
  
  // Helper methods
  String get actionDisplayName {
    switch (action) {
      case CommandAction.openApp:
        return 'فتح التطبيق';
      case CommandAction.closeApp:
        return 'إغلاق التطبيق';
      case CommandAction.searchApp:
        return 'البحث عن التطبيق';
      case CommandAction.unknown:
        return 'أمر غير معروف';
    }
  }
  
  String get statusMessage {
    if (!isValid) {
      return errorMessage ?? 'أمر غير صحيح';
    }
    
    switch (action) {
      case CommandAction.openApp:
        return 'فتح تطبيق $appName';
      case CommandAction.closeApp:
        return 'إغلاق تطبيق $appName';
      case CommandAction.searchApp:
        return 'البحث عن تطبيق $appName';
      case CommandAction.unknown:
        return 'أمر غير معروف';
    }
  }
  
  // JSON serialization (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'rawCommand': rawCommand,
      'cleanCommand': cleanCommand,
      'action': action.toString(),
      'appName': appName,
      'isValid': isValid,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      rawCommand: json['rawCommand'] ?? '',
      cleanCommand: json['cleanCommand'] ?? '',
      action: CommandAction.values.firstWhere(
        (e) => e.toString() == json['action'],
        orElse: () => CommandAction.unknown,
      ),
      appName: json['appName'] ?? '',
      isValid: json['isValid'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }
}