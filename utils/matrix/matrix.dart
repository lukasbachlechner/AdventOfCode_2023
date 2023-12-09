import '../index.dart';
import 'matrix_field.dart';

typedef MatrixRow = List<MatrixField>;

extension MatrixRowExtension on MatrixRow {
  int get rowLength {
    return fold<int>(
      0,
      (previousValue, element) => previousValue + element.width,
    );
  }

  List<String> get coordinates {
    return map((field) => '(${field.x},${field.y})').toList();
  }

  List<MatrixField> whereNotNull() {
    return where((element) => element.value != null).toList();
  }
}

class Matrix {
  const Matrix({
    required this.rows,
  });

  factory Matrix.fromDistinctIntegerFields(List<String> input) {
    final rows = input.mapIndexed((y, row) {
      final initialRow = row
          .split('')
          .mapIndexed(
            (x, item) =>
                MatrixField(x: x, y: y, value: item, width: item.length),
          )
          .toList();
      final newRow = initialRow;
      final numbersInRow = RegExp(r'\d+').allMatches(row);
      for (final match in numbersInRow) {
        if (match.group(0)!.length == 1) {
          continue;
        }

        final x = match.start;
        final number = match.group(0)!;
        final width = number.length;
        final numberField = MatrixField(
          x: x,
          y: y,
          value: number,
          width: width,
        );

        newRow.replaceRange(x, x + width, [
          numberField,
          ...List.filled(
            width - 1,
            MatrixField.empty(
              x: x,
              y: y,
            ),
          ),
        ]);
      }
      return newRow.whereNotNull().toList();
    }).toList();

    return Matrix(rows: rows);
  }

  int get width => rows.first.rowLength;
  int get height => rows.length;

  final List<MatrixRow> rows;

  MatrixField getFieldByValue(String value) {
    return flatRows.firstWhere((element) => element.value == value);
  }

  List<MatrixField> getFieldsByValue(String value) {
    return flatRows.where((element) => element.value == value).toList();
  }

  List<MatrixField> getIntegerFields() {
    return flatRows
        .where(
          (element) =>
              element.value != null && int.tryParse(element.safeValue) != null,
        )
        .toList();
  }

  List<MatrixField> getNeighbors(MatrixField target) {
    // get all adjacent fields for field with width fieldWidth, also diagonally
    final neighbors = <MatrixField?>[];

    // get left neighbor
    if (target.x > 0) {
      neighbors.add(
        rows[target.y].firstWhereOrNull(
          // subtract width because we always save the start x coordinate
          (element) => element.x == target.x - element.width,
        ),
      );
    }

    // get right neighbor
    if (target.endX < width - 1) {
      neighbors.add(
        rows[target.y].firstWhereOrNull(
          (element) => element.x == target.endX + 1,
        ),
      );
    }

    // get top neighbors
    if (target.y > 0) {
      final topRow = rows[target.y - 1];

      final topRowNeighbors = getVerticalNeighbors(target, topRow);
      neighbors.addAll(topRowNeighbors);
    }

    // get bottom neighbors
    if (target.y < height - 1) {
      final bottomRow = rows[target.y + 1];

      final bottomRowNeighbors = getVerticalNeighbors(target, bottomRow);
      neighbors.addAll(bottomRowNeighbors);
    }

    return neighbors.whereNotNull().toList();
  }

  MatrixRow getVerticalNeighbors(MatrixField target, MatrixRow targetRow) {
    final neighbors = <MatrixField?>[];

    final topRowStart = targetRow.first.x;
    final topRowEnd = targetRow.last.endX;

    final targetRowNeighbors = targetRow.where(
      (element) {
        final elementStart = element.x;
        final elementEnd = element.endX;

        if (elementStart < topRowStart && elementEnd > topRowEnd) {
          return false;
        }

        final leftBoundary = target.x - 1;
        final rightBoundary = target.endX + 1;

        final startsWithinBounds =
            elementStart >= leftBoundary && elementStart <= rightBoundary;
        final endsWithinBounds =
            elementEnd >= leftBoundary && elementEnd <= rightBoundary;

        return startsWithinBounds || endsWithinBounds;
      },
    );

    neighbors.addAll(targetRowNeighbors);

    return neighbors.whereNotNull().toList();
  }

  MatrixRow get flatRows {
    return rows.flattened.toList();
  }

  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln('  | ${List.generate(width, (index) => index).join(' | ')} |')
      ..writeln('--+-${List.generate(width, (_) => '-').join('-+-')}-+-');

    for (final row in rows) {
      final lineNumber = rows.indexOf(row);
      final rowString = row.map((field) {
        final span = field.width;
        int getPadding({required bool isRight}) {
          if (span == 1) {
            return 1;
          }

          if (isRight && span.isEven) {
            return span;
          }

          return span + 1;
        }

        final leftPadding =
            List.generate(getPadding(isRight: false), (_) => ' ').join();
        final rightPadding =
            List.generate(getPadding(isRight: true), (_) => ' ').join();

        return '$leftPadding${field.value}$rightPadding';
      }).join('|');
      buffer.writeln('$lineNumber |$rowString| (${row.rowLength})');
    }

    return buffer.toString();
  }
}
