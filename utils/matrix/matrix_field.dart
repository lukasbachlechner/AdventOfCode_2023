import 'package:meta/meta.dart';

@immutable
class MatrixField {
  const MatrixField({
    required this.x,
    required this.y,
    required this.value,
    required this.width,
  });

  factory MatrixField.empty({
    required int x,
    required int y,
  }) {
    return MatrixField(
      x: x,
      y: y,
      value: null,
      width: 1,
    );
  }

  final int x;
  final int y;
  final int width;
  final String? value;

  @override
  String toString() => value ?? ' ';

  String get coordinates => '($x,$y)';

  int get endX => width > 1 ? x + width - 1 : x;

  String get safeValue => value ?? ' ';

  @override
  bool operator ==(covariant MatrixField other) {
    if (identical(this, other)) return true;

    return other.x == x &&
        other.y == y &&
        other.width == width &&
        other.value == value;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode ^ width.hashCode ^ value.hashCode;
  }
}
