import 'dart:math';

enum MoveDirection { up, down, left, right }

/// Core 2048 game logic. No UI, pure Dart.
class Game2048 {
  static const int gridSize = 4;

  List<List<int?>> grid;
  int score;

  Game2048._(this.grid, this.score);

  /// Creates a new empty game.
  factory Game2048.newGame() {
    final empty = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    final game = Game2048._(empty, 0);
    game._addRandomTile();
    game._addRandomTile();
    return game;
  }

  /// Creates a deep copy (used for undo).
  Game2048 copy() {
    final copiedGrid = List.generate(gridSize, (r) => List<int?>.from(grid[r]));
    return Game2048._(copiedGrid, score);
  }

  /// Returns true if any move can change the board.
  bool canMove() {
    if (_hasEmpty()) return true;
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        final v = grid[r][c];
        // Right neighbor
        if (c + 1 < gridSize && grid[r][c + 1] == v) return true;
        // Down neighbor
        if (r + 1 < gridSize && grid[r + 1][c] == v) return true;
      }
    }
    return false;
  }

  /// Returns true when a tile with value 2048 exists.
  bool isWin() => grid.expand((e) => e).any((v) => v == 2048);

  bool isGameOver() => !canMove();

  /// Perform a move. Returns true if the board changed.
  bool move(MoveDirection dir) {
    // Transform grid so we can always treat the move as "left".
    List<List<int?>> original = _cloneGrid(grid);
    List<List<int?>> transformed = _rotateForDirection(grid, dir);
    bool changed = false;

    for (var row in transformed) {
      final compressed = _compress(row);
      final merged = _merge(compressed);
      final finalRow = _compress(merged);
      if (!_listEquals(row, finalRow)) changed = true;
      row.setAll(0, finalRow);
    }

    // Rotate back to original orientation.
    grid = _rotateBackForDirection(transformed, dir);

    if (changed) {
      _addRandomTile();
    }
    return changed;
  }

  // ----- private helpers -----

  bool _hasEmpty() => grid.any((row) => row.contains(null));

  void _addRandomTile() {
    final empty = <Map<String, int>>[];
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        if (grid[r][c] == null) empty.add({'r': r, 'c': c});
      }
    }
    if (empty.isEmpty) return;
    final pos = empty[Random().nextInt(empty.length)];
    // 90% chance 2, 10% chance 4.
    grid[pos['r']!][pos['c']!] = Random().nextDouble() < 0.9 ? 2 : 4;
  }

  List<List<int?>> _cloneGrid(List<List<int?>> src) =>
      List.generate(gridSize, (r) => List<int?>.from(src[r]));

  // Rotates the grid so that a move in [dir] becomes a left move.
  List<List<int?>> _rotateForDirection(List<List<int?>> src, MoveDirection dir) {
    switch (dir) {
      case MoveDirection.left:
        return _cloneGrid(src);
      case MoveDirection.right:
        return src.map((row) => row.reversed.toList()).toList();
      case MoveDirection.up:
        return _transpose(src);
      case MoveDirection.down:
        return _transpose(src).map((row) => row.reversed.toList()).toList();
    }
  }

  List<List<int?>> _rotateBackForDirection(List<List<int?>> src, MoveDirection dir) {
    switch (dir) {
      case MoveDirection.left:
        return src;
      case MoveDirection.right:
        return src.map((row) => row.reversed.toList()).toList();
      case MoveDirection.up:
        return _transpose(src);
      case MoveDirection.down:
        return _transpose(src.map((row) => row.reversed.toList()).toList());
    }
  }

  List<List<int?>> _transpose(List<List<int?>> src) {
    final transposed = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    for (var r = 0; r < gridSize; r++) {
      for (var c = 0; c < gridSize; c++) {
        transposed[c][r] = src[r][c];
      }
    }
    return transposed;
  }

  // Slides non‑null values to the left, filling gaps with null.
  List<int?> _compress(List<int?> row) {
    final newRow = row.where((v) => v != null).toList();
    while (newRow.length < gridSize) newRow.add(null);
    return newRow;
  }

  // Merges equal adjacent tiles, adding to score.
  List<int?> _merge(List<int?> row) {
    for (var i = 0; i < gridSize - 1; i++) {
      final cur = row[i];
      final nxt = row[i + 1];
      if (cur != null && cur == nxt) {
        row[i] = cur * 2;
        row[i + 1] = null;
        score += row[i]!;
      }
    }
    return row;
  }

  bool _listEquals(List<int?> a, List<int?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
