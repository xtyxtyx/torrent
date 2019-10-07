class Range {
  Range(this.min, this.max);

  final int min;
  final int max;

  Iterable<int> get each  sync* {
    var current = min;
    while (current < max) {
      yield current;
      current++;
    }
  }
}