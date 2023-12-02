// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../utils/index.dart';

class Day02 extends GenericDay {
  Day02() : super(2);

  @override
  List<Game> parseInput() {
    return input.getPerLine().map(Game.fromInputLine).toList();
  }

  @override
  int solvePart1() {
    const maxReveal = Reveal(red: 12, green: 13, blue: 14);
    return parseInput().map((game) {
      if (game.isPossibleWithMaxCubes(maxReveal: maxReveal)) {
        return game.id;
      }
      return 0;
    }).reduce((a, b) => a + b);
  }

  @override
  int solvePart2() {
    return parseInput()
        .map((game) => game.getPowerOfFewestCubes())
        .reduce((a, b) => a + b);
  }
}

class Game {
  const Game({
    required this.id,
    required this.reveals,
  });

  factory Game.fromInputLine(String line) {
    final gameIdString = RegExp(r'Game (\d+)').firstMatch(line)!.group(1);
    assert(gameIdString != null, 'Game id not found in line: $line');

    final gameId = int.parse(gameIdString!);
    final revealRounds =
        line.split(':').last.split(';').map(Reveal.fromInputLine).toList();

    return Game(
      id: gameId,
      reveals: revealRounds,
    );
  }

  final int id;
  final List<Reveal> reveals;

  @override
  String toString() => 'Game(id: $id, reveals: $reveals)';

  bool isPossibleWithMaxCubes({
    required Reveal maxReveal,
  }) {
    return reveals.every((reveal) => reveal.isPossible(maxReveal: maxReveal));
  }

  int getPowerOfFewestCubes() {
    var maxRed = 0;
    var maxGreen = 0;
    var maxBlue = 0;

    for (final reveal in reveals) {
      if (reveal.red > maxRed) {
        maxRed = reveal.red;
      }
      if (reveal.green > maxGreen) {
        maxGreen = reveal.green;
      }
      if (reveal.blue > maxBlue) {
        maxBlue = reveal.blue;
      }
    }

    return maxRed * maxGreen * maxBlue;
  }
}

class Reveal {
  const Reveal({
    this.red = 0,
    this.green = 0,
    this.blue = 0,
  });

  factory Reveal.fromInputLine(String line) {
    final allCubes = line.split(',');
    final red = getCountForColor('red', allCubes);
    final green = getCountForColor('green', allCubes);
    final blue = getCountForColor('blue', allCubes);
    return Reveal(
      red: red,
      green: green,
      blue: blue,
    );
  }

  static int getCountForColor(String color, List<String> allCubes) {
    final fullString = allCubes.firstWhere(
      (cube) => cube.contains(color),
      orElse: () => '',
    );
    final count = RegExp(r'\d+').firstMatch(fullString)?.group(0) ?? '0';

    return int.parse(count);
  }

  final int red;
  final int green;
  final int blue;

  @override
  String toString() => 'Reveal(red: $red, green: $green, blue: $blue)';

  bool isPossible({
    required Reveal maxReveal,
  }) {
    // print('Checking if $this is possible with $maxReveal');
    return red <= maxReveal.red &&
        green <= maxReveal.green &&
        blue <= maxReveal.blue;
  }
}
