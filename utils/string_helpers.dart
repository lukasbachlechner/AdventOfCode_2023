extension ExtractNumbers on String {
  List<int> extractNumbers() {
    return RegExp(r'\d+').allMatches(this).map((m) {
      return int.parse(m.group(0)!);
    }).toList();
  }
}
