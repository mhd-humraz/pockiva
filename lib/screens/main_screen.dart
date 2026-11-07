import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'games_screen.dart';

/// MainScreen hosts the bottom navigation bar and switches between
/// the existing HomeScreen and the new GamesScreen using an IndexedStack.
/// It preserves the state of each tab (e.g., scroll position, loaded data).
class MainScreen extends StatefulWidget {
  final bool isDark;
  final Future<void> Function() onToggleTheme;

  const MainScreen({Key? key, required this.isDark, required this.onToggleTheme})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Both pages are instantiated once so their internal state is kept.
    _pages = [
      HomeScreen(isDark: widget.isDark, onToggleTheme: widget.onToggleTheme),
      const GamesScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
        ],
      ),
    );
  }
}
