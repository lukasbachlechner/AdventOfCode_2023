import '../utils/index.dart';

class Day01 extends GenericDay {
  Day01() : super(1);

  @override
  List<String> parseInput() {
    return input.getPerLine();
  }

  @override
  int solvePart1() {
    return parseInput()
        .map((line) {
          final numbersInLine = RegExp('[0-9]{1}')
              .allMatches(line)
              .map((match) => match.group(0));

          return [
            numbersInLine.firstOrNull,
            numbersInLine.lastOrNull,
          ].whereNotNull().join();
        })
        .map(int.parse)
        .reduce((a, b) => a + b);
  }

  @override
  int solvePart2() {
    return 0;
  }
}
