import 'package:flutter/material.dart';
import 'game_2048.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late Game2048 game;

  @override
  void initState() {
    super.initState();
    game = Game2048.newGame();
  }

  void _move(MoveDirection direction) {
    if (game.isGameOver()) return;

    setState(() {
      game.move(direction);
    });
  }

  void _restart() {
    setState(() {
      game = Game2048.newGame();
    });
  }

  Color _tileColor(int? value, BuildContext context) {
    if (value == null) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    const colors = {
      2: Color(0xFFEEE4DA),
      4: Color(0xFFEDE0C8),
      8: Color(0xFFF2B179),
      16: Color(0xFFF59563),
      32: Color(0xFFF67C5F),
      64: Color(0xFFF65E3B),
      128: Color(0xFFEDCF72),
      256: Color(0xFFEDCC61),
      512: Color(0xFFEDC850),
      1024: Color(0xFFEDC53F),
      2048: Color(0xFFEDC22E),
    };

    return colors[value] ?? const Color(0xFF3C3A32);
  }

  Widget _buildBoard() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _move(MoveDirection.up);
        } else if (velocity > 0) {
          _move(MoveDirection.down);
        }
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < 0) {
          _move(MoveDirection.left);
        } else if (velocity > 0) {
          _move(MoveDirection.right);
        }
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: Game2048.gridSize * Game2048.gridSize,
            itemBuilder: (context, index) {
              final row = index ~/ Game2048.gridSize;
              final column = index % Game2048.gridSize;
              final value = game.grid[row][column];

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tileColor(value, context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: value == null
                    ? const SizedBox.shrink()
                    : FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: value <= 4
                                  ? const Color(0xFF776E65)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final won = game.isWin();
    final over = game.isGameOver();

    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Puzzle'),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '2048',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Column(
                            children: [
                              const Text('SCORE'),
                              Text(
                                '${game.score}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Swipe to move tiles and combine equal numbers.'),
                  const SizedBox(height: 24),
                  _buildBoard(),
                  const SizedBox(height: 20),
                  if (won || over)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        won ? 'You reached 2048!' : 'Game over!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
