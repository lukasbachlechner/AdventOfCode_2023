import 'dart:math';

import '../utils/index.dart';

class Day04 extends GenericDay {
  Day04() : super(4);

  @override
  List<Card> parseInput() {
    return input.getPerLine().map(Card.fromInputLine).toList();
  }

  @override
  int solvePart1() {
    return parseInput().map((card) => card.score).sum;
  }

  @override
  int solvePart2() {
    final input = parseInput();
    final wonMap = {
      for (final card in input) card.id: 1,
    };

    for (final card in input) {
      final id = card.id;
      final matches = card.wonCount;
      final currentInstancesOfCurrentCard = wonMap[id]!;

      final copyIndexes = <int, int>{};
      for (var i = 1; i <= matches; i++) {
        final targetId = id + i;
        final currentInstancesOfTargetCard = wonMap[targetId]!;

        wonMap[targetId] =
            currentInstancesOfTargetCard + currentInstancesOfCurrentCard;

        copyIndexes[targetId] = currentInstancesOfCurrentCard;
      }
    }

    return wonMap.values.sum;
  }
}

class Card {
  const Card({
    required this.id,
    required this.winningNumbers,
    required this.numbers,
  });

  factory Card.fromInputLine(String line) {
    final [idPart, winningPart, numbersPart] = line.split(RegExp(r'\:|\|'));

    final cardId = int.parse(idPart.replaceAll('Card ', ''));
    final winningNumbers = winningPart.extractNumbers();
    final numbers = numbersPart.extractNumbers();

    return Card(
      id: cardId,
      winningNumbers: winningNumbers,
      numbers: numbers,
    );
  }

  final int id;
  final List<int> winningNumbers;
  final List<int> numbers;

  int get wonCount {
    return winningNumbers.where(numbers.contains).length;
  }

  int get score {
    return pow(2, wonCount - 1).floor();
  }

  @override
  String toString() {
    return 'Card[$id]($wonCount, $score)';
  }
}
