class AppConstants {
  static const String appName = 'CommitLock';
  static const String hiveSessionBox = 'sessions';
  static const String hiveSettingsBox = 'settings';

  static const List<String> habitCategories = [
    'Reading',
    'Exercise',
    'Language Study',
    'Coding Practice',
    'Meditation',
    'Custom',
  ];

  static const List<int> durationPresets = [15, 30, 45, 60, 90];

  static const List<String> blockedAppCategories = [
    'Social Media',
    'Video Streaming',
    'Games',
    'News',
  ];

  static const List<String> motivationalQuotes = [
    "Stay focused. Every second counts!",
    "You're building something great.",
    "Discipline is choosing what you want most over what you want now.",
    "The pain of discipline weighs ounces, regret weighs tons.",
    "Your future self will thank you.",
    "Don't break the chain. Keep going!",
    "Small steps every day lead to big results.",
    "Commitment is what transforms a promise into reality.",
    "Push through. You're stronger than you think.",
    "Success is the sum of small efforts repeated daily.",
  ];

  static const String breakCommitmentText = 'I am breaking my commitment';
}

enum SessionStatus { active, completed, broken }

enum RestrictionLevel { normal, strict, extreme }
