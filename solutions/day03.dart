// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../utils/index.dart';
import '../utils/matrix/matrix.dart';

// 525181 - 5980

class Day03 extends GenericDay {
  Day03() : super(3);

  @override
  Matrix parseInput() {
    return Matrix.fromDistinctIntegerFields(input.getPerLine());
  }

  static const separator = '.';
  static const gear = '*';

  @override
  int solvePart1() {
    final matrix = parseInput();

    final integerFields = matrix.getIntegerFields();

    final parts = <String>[];

    for (final field in integerFields) {
      final neighbors = matrix.getNeighbors(field);

      final hasPart = neighbors.firstWhereOrNull(
            (field) => !RegExp(r'\.+|\d+').hasMatch(field.safeValue),
          ) !=
          null;

      if (hasPart) {
        parts.add(field.safeValue);
      }
    }

    return parts.map(int.parse).reduce((a, b) => a + b);
  }

  @override
  int solvePart2() {
    final matrix = parseInput();

    final targets = matrix.getFieldsByValue(gear);

    final gearRatios = <int>[];

    for (final target in targets) {
      final neighbors = matrix.getNeighbors(target).where((neighbor) {
        final hasNumber = RegExp(r'\d').hasMatch(neighbor.safeValue);

        return hasNumber;
      });
      if (neighbors.length != 2) {
        continue;
      }

      gearRatios.add(
        neighbors.map((e) => int.parse(e.safeValue)).reduce((a, b) => a * b),
      );
    }

    return gearRatios.reduce((a, b) => a + b);
  }
}
