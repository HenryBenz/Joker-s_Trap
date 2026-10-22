/// Unsigned 32-bit xorshift generator from the product specification.
class XorShift32 {
  XorShift32(int seed) : state = seed & 0xFFFFFFFF;

  int state;

  int next() {
    var x = state & 0xFFFFFFFF;
    x ^= (x << 13) & 0xFFFFFFFF;
    x &= 0xFFFFFFFF;
    x ^= (x >> 17) & 0xFFFFFFFF;
    x &= 0xFFFFFFFF;
    x ^= (x << 5) & 0xFFFFFFFF;
    x &= 0xFFFFFFFF;
    state = x;
    return state;
  }

  /// Returns an integer in `0 .. maxExclusive - 1`.
  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) {
      throw ArgumentError.value(maxExclusive, 'maxExclusive');
    }
    return next() % maxExclusive;
  }
}
