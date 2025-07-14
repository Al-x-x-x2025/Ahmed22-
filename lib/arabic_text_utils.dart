
class ArabicTextUtils {
  // Arabic to English app name mapping
  static const Map<String, String> _arabicToEnglishApps = {
    'واتساب': 'whatsapp',
    'واتس اب': 'whatsapp',
    'واتس آب': 'whatsapp',
    'فيسبوك': 'facebook',
    'فيس بوك': 'facebook',
    'انستغرام': 'instagram',
    'انستجرام': 'instagram',
    'تويتر': 'twitter',
    'يوتيوب': 'youtube',
    'تلغرام': 'telegram',
    'تيليغرام': 'telegram',
    'تليجرام': 'telegram',
    'المعرض': 'gallery',
    'معرض': 'gallery',
    'الصور': 'photos',
    'صور': 'photos',
    'الكاميرا': 'camera',
    'كاميرا': 'camera',
    'الإعدادات': 'settings',
    'اعدادات': 'settings',
    'الخرائط': 'maps',
    'خرائط': 'maps',
    'الخريطة': 'maps',
    'خريطة': 'maps',
    'الهاتف': 'phone',
    'هاتف': 'phone',
    'الرسائل': 'messages',
    'رسائل': 'messages',
    'الرسائل القصيرة': 'messages',
    'البريد': 'gmail',
    'بريد': 'gmail',
    'الايميل': 'gmail',
    'ايميل': 'gmail',
    'المتصفح': 'chrome',
    'متصفح': 'chrome',
    'كروم': 'chrome',
    'سفاري': 'safari',
    'المتجر': 'play store',
    'متجر': 'play store',
    'متجر التطبيقات': 'app store',
    'بلاي ستور': 'play store',
    'اب ستور': 'app store',
    'سناب شات': 'snapchat',
    'سناب': 'snapchat',
    'تيك توك': 'tiktok',
    'تكتوك': 'tiktok',
    'نتفليكس': 'netflix',
    'سبوتيفاي': 'spotify',
    'اوبر': 'uber',
    'كريم': 'careem',
    'الكلاسيكيات': 'calculator',
    'الحاسبة': 'calculator',
    'حاسبة': 'calculator',
    'الساعة': 'clock',
    'ساعة': 'clock',
    'التقويم': 'calendar',
    'تقويم': 'calendar',
    'الملفات': 'files',
    'ملفات': 'files',
    'الملاحظات': 'notes',
    'ملاحظات': 'notes',
    'المذكرات': 'notes',
    'مذكرات': 'notes',
    'الطقس': 'weather',
    'طقس': 'weather',
    'الأخبار': 'news',
    'اخبار': 'news',
    'المحفظة': 'wallet',
    'محفظة': 'wallet',
    'الأمان': 'security',
    'امان': 'security',
    'الصحة': 'health',
    'صحة': 'health',
    'الرياضة': 'sports',
    'رياضة': 'sports',
    'الألعاب': 'games',
    'العاب': 'games',
    'ألعاب': 'games',
    'الموسيقى': 'music',
    'موسيقى': 'music',
    'الفيديو': 'video',
    'فيديو': 'video',
    'الكتب': 'books',
    'كتب': 'books',
    'التسوق': 'shopping',
    'تسوق': 'shopping',
    'الطعام': 'food',
    'طعام': 'food',
    'السفر': 'travel',
    'سفر': 'travel',
    'التعليم': 'education',
    'تعليم': 'education',
    'الأعمال': 'business',
    'اعمال': 'business',
    'العمل': 'work',
    'عمل': 'work',
  };
  
  // English app name variations
  static const Map<String, String> _englishAppVariations = {
    'whatsapp': 'WhatsApp',
    'facebook': 'Facebook',
    'instagram': 'Instagram',
    'twitter': 'Twitter',
    'youtube': 'YouTube',
    'telegram': 'Telegram',
    'gallery': 'Gallery',
    'photos': 'Photos',
    'camera': 'Camera',
    'settings': 'Settings',
    'maps': 'Maps',
    'phone': 'Phone',
    'messages': 'Messages',
    'gmail': 'Gmail',
    'chrome': 'Chrome',
    'safari': 'Safari',
    'play store': 'Play Store',
    'app store': 'App Store',
    'snapchat': 'Snapchat',
    'tiktok': 'TikTok',
    'netflix': 'Netflix',
    'spotify': 'Spotify',
    'uber': 'Uber',
    'careem': 'Careem',
    'calculator': 'Calculator',
    'clock': 'Clock',
    'calendar': 'Calendar',
    'files': 'Files',
    'notes': 'Notes',
    'weather': 'Weather',
    'news': 'News',
    'wallet': 'Wallet',
    'security': 'Security',
    'health': 'Health',
    'sports': 'Sports',
    'games': 'Games',
    'music': 'Music',
    'video': 'Video',
    'books': 'Books',
    'shopping': 'Shopping',
    'food': 'Food',
    'travel': 'Travel',
    'education': 'Education',
    'business': 'Business',
    'work': 'Work',
  };
  
  /// Converts Arabic app name to English equivalent
  static String getEnglishAppName(String arabicName) {
    // Clean and normalize the input
    final cleanName = normalizeAppName(arabicName);
    
    // Check direct mapping
    if (_arabicToEnglishApps.containsKey(cleanName)) {
      return _arabicToEnglishApps[cleanName]!;
    }
    
    // Check partial matches
    for (final entry in _arabicToEnglishApps.entries) {
      if (cleanName.contains(entry.key) || entry.key.contains(cleanName)) {
        return entry.value;
      }
    }
    
    // If it's already English, return proper case
    final lowerName = cleanName.toLowerCase();
    if (_englishAppVariations.containsKey(lowerName)) {
      return _englishAppVariations[lowerName]!;
    }
    
    // Return original if no mapping found
    return arabicName;
  }
  
  /// Normalizes app name by removing diacritics and extra spaces
  static String normalizeAppName(String name) {
    String normalized = name.trim().toLowerCase();
    
    // Remove Arabic diacritics
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    
    // Replace alternative Arabic characters
    normalized = normalized.replaceAll('أ', 'ا');
    normalized = normalized.replaceAll('إ', 'ا');
    normalized = normalized.replaceAll('آ', 'ا');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll('ى', 'ي');
    
    // Remove extra spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
    
    return normalized;
  }
  
  /// Checks if text contains Arabic characters
  static bool isArabicText(String text) {
    return RegExp(r'[\؀-\u06FF]').hasMatch(text);
  }
  
  /// Calculates similarity between two strings (for fuzzy matching)
  static double calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final normalizedA = normalizeAppName(a);
    final normalizedB = normalizeAppName(b);
    
    if (normalizedA == normalizedB) return 1.0;
    
    // Simple similarity calculation based on common characters
    final lengthA = normalizedA.length;
    final lengthB = normalizedB.length;
    final maxLength = lengthA > lengthB ? lengthA : lengthB;
    
    int commonChars = 0;
    for (int i = 0; i < lengthA && i < lengthB; i++) {
      if (normalizedA[i] == normalizedB[i]) {
        commonChars++;
      }
    }
    
    return commonChars / maxLength;
  }
  
  /// Gets all known app names (both Arabic and English)
  static List<String> getAllKnownAppNames() {
    final List<String> allNames = [];
    
    // Add Arabic names
    allNames.addAll(_arabicToEnglishApps.keys);
    
    // Add English names
    allNames.addAll(_englishAppVariations.keys);
    allNames.addAll(_englishAppVariations.values);
    
    return allNames;
  }
  
  /// Checks if the given name is a known app name
  static bool isKnownAppName(String name) {
    final normalizedName = normalizeAppName(name);
    return _arabicToEnglishApps.containsKey(normalizedName) ||
           _englishAppVariations.containsKey(normalizedName.toLowerCase());
  }
  
  /// Gets suggested app names based on partial input
  static List<String> getSuggestedAppNames(String partialName) {
    final List<String> suggestions = [];
    final normalizedInput = normalizeAppName(partialName);
    
    // Check Arabic names
    for (final arabicName in _arabicToEnglishApps.keys) {
      if (arabicName.contains(normalizedInput) || normalizedInput.contains(arabicName)) {
        suggestions.add(arabicName);
      }
    }
    
    // Check English names
    for (final englishName in _englishAppVariations.keys) {
      if (englishName.contains(normalizedInput.toLowerCase()) || 
          normalizedInput.toLowerCase().contains(englishName)) {
        suggestions.add(_englishAppVariations[englishName]!);
      }
    }
    
    return suggestions;
  }
}