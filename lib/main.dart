import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isDark = true;

  try {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('dark_mode') ?? true;
  } catch (e) {
    debugPrint('Theme preference error: $e');
  }

  runApp(Save40App(initialDarkMode: isDark));
}

class Save40App extends StatefulWidget {
  final bool initialDarkMode;
  const Save40App({super.key, required this.initialDarkMode});

  @override
  State<Save40App> createState() => Save40AppState();
}

class Save40AppState extends State<Save40App> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.initialDarkMode;
  }

  Future<void> toggleTheme() async {
    setState(() => isDark = !isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }

  
  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF16A36A);

    return MaterialApp(
      title: 'Pockiva',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101713),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      ),

      home: PockivaSplashScreen(
        nextScreen: HomeScreen(
          isDark: isDark,
          onToggleTheme: toggleTheme,
        ),
      ),
    );
  }

}
