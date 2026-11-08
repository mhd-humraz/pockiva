import 'package:flutter/material.dart';

import '../placeholder_game_screen.dart';
import '../games/2048/game_2048_screen.dart';

class _GameCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;

  const _GameCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });
}

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = <_GameCardData>[
      _GameCardData(
        title: '2048 Puzzle',
        subtitle: 'Slide tiles to combine numbers',
        icon: Icons.grid_view,
        builder: (_) => const Game2048Screen(),
      ),
      _GameCardData(
        title: 'Snake',
        subtitle: 'Classic snake game',
        icon: Icons.sports_esports,
        builder: (_) => const PlaceholderGameScreen(title: 'Snake'),
      ),
      _GameCardData(
        title: 'Tic Tac Toe',
        subtitle: 'Two-player X/O',
        icon: Icons.crop_square,
        builder: (_) => const PlaceholderGameScreen(title: 'Tic Tac Toe'),
      ),
      _GameCardData(
        title: 'Memory Match',
        subtitle: 'Find matching pairs',
        icon: Icons.dashboard,
        builder: (_) => const PlaceholderGameScreen(title: 'Memory Match'),
      ),
    ];

    final crossAxisCount =
        MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take a break, play a little.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enjoy a few offline games.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
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
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: game.builder,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              game.icon,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              game.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
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
