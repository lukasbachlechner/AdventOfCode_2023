import 'dart:collection';

import '../utils/index.dart';

class Day01 extends GenericDay {
  Day01() : super(1);

  @override
  List<String> parseInput() {
    return input.getPerLine();
  }

  @override
  int solvePart1() {
    return sumFirstAndLastNumbersInEachLine(parseInput());
  }

  @override
  int solvePart2() {
    final normalizedInput = parseInput().map(replaceWordsWithNumbers).toList();
    return sumFirstAndLastNumbersInEachLine(
      normalizedInput,
    );
  }

  /// Creates a two digit number from the first and last number in each line and
  /// sums them up.
  int sumFirstAndLastNumbersInEachLine(List<String> normalizedInput) {
    return normalizedInput
        .map((line) {
          // Find all single digits in the line
          final numbersInLine = RegExp('[0-9]{1}')
              .allMatches(line)
              .map((match) => match.group(0));

          // Create a two digit number from the first and last number in the
          // line. If there is only one number in the line, the second number
          // will be null and therefore ignored by the whereNotNull() call.
          return [
            numbersInLine.firstOrNull,
            numbersInLine.lastOrNull,
          ].whereNotNull().join();
        })
        .map(int.parse)
        .reduce((a, b) => a + b);
  }

  /// Returns a map that maps the number words to their corresponding number.
  Map<String, int> get numberMap => {
        'one': 1,
        'two': 2,
        'three': 3,
        'four': 4,
        'five': 5,
        'six': 6,
        'seven': 7,
        'eight': 8,
        'nine': 9,
      };

  /// Replaces all words in the line with their corresponding number and returns
  /// the resulting string.
  String replaceWordsWithNumbers(String line) {
    // Keep a record of the original index of each word/number in the line.
    // Using a SplayTreeMap allows us to have the indices sorted in ascending
    // order.
    final indexToValueMap = SplayTreeMap<int, int>();

    // Iterate over all words and numbers in the line
    for (final entry in numberMap.entries) {
      // Create a regex that matches either the word or the number
      final regex = RegExp('${entry.key}|${entry.value}');

      // Iterate over all matches and add them to the result map with the
      // original index as key
      for (final match in regex.allMatches(line)) {
        // We can be sure that we only have one match per index, because there
        // can be no overlapping matches (like e. g. 'nine' and 'ninety')
        indexToValueMap[match.start] = entry.value;
      }
    }

    // Return the resulting string by joining the values of the map
    return indexToValueMap.values.join();
  }
}
