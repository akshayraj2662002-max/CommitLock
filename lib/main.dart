import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/datasources/hive_datasource.dart';
import 'data/datasources/prefs_datasource.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/session_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/new_commitment_screen.dart';
import 'presentation/screens/active_session_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveDataSource = HiveDataSource();
  await hiveDataSource.init();

  final prefsDataSource = PrefsDataSource();
  await prefsDataSource.init();

  runApp(CommitLockApp(
    hiveDataSource: hiveDataSource,
    prefsDataSource: prefsDataSource,
  ));
}

class CommitLockApp extends StatelessWidget {
  final HiveDataSource hiveDataSource;
  final PrefsDataSource prefsDataSource;

  const CommitLockApp({
    super.key,
    required this.hiveDataSource,
    required this.prefsDataSource,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(prefsDataSource),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(hiveDataSource, prefsDataSource),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(hiveDataSource),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefsDataSource),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'CommitLock',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.currentThemeMode,
            initialRoute: prefsDataSource.isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/new-commitment': (context) => const NewCommitmentScreen(),
              '/active-session': (context) => const ActiveSessionScreen(),
              '/result': (context) => const ResultScreen(),
              '/history': (context) {
                // Refresh history data when navigating to history screen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<HistoryProvider>().loadSessions();
                });
                return const HistoryScreen();
              },
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
