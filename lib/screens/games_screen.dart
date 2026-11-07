import 'package:flutter/material.dart';
import '../placeholder_game_screen.dart';
import '../games/2048/game_2048_screen.dart';

/// GamesScreen displays four cards for the mini‑games.
class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine number of columns for responsiveness.
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    // Configuration for each game card.
    final games = [
      {
        'title': '2048 Puzzle',
        'subtitle': 'Slide tiles to combine numbers',
        'icon': Icons.grid_view,
        'builder': (BuildContext ctx) => const Game2048Screen(),
      },
      {
        'title': 'Snake',
        'subtitle': 'Classic snake game',
        'icon': Icons.sports_esports,
        'builder': (BuildContext ctx) => const PlaceholderGameScreen(title: 'Snake'),
      },
      {
        'title': 'Tic Tac Toe',
        'subtitle': 'Two‑player X/O',
        'icon': Icons.crop_square,
        'builder': (BuildContext ctx) => const PlaceholderGameScreen(title: 'Tic Tac Toe'),
      },
      {
        'title': 'Memory Match',
        'subtitle': 'Find matching pairs',
        'icon': Icons.dashboard,
        'builder': (BuildContext ctx) => const PlaceholderGameScreen(title: 'Memory Match'),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Take a break, play a little.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Enjoy a few offline games.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => game['builder']!(context)),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(game['icon'] as IconData,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(game['title'] as String,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 4),
                            Text(game['subtitle'] as String,
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
