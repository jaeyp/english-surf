import 'dart:math';
import 'dart:typed_data';

class MathUtils {
  static final Random _random = Random();

  /// Generates a list of floats from a standard normal distribution (mean=0, std=1)
  /// using the Box-Muller transform.
  static Float32List randomNormal(int size) {
    final data = Float32List(size);
    for (int i = 0; i < size; i += 2) {
      double u1, u2;
      do {
        u1 = _random.nextDouble();
        u2 = _random.nextDouble();
      } while (u1 <= double.minPositive); // Avoid log(0)

      final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
      final z1 = sqrt(-2.0 * log(u1)) * sin(2.0 * pi * u2);

      data[i] = z0;
      if (i + 1 < size) {
        data[i + 1] = z1;
      }
    }
    return data;
  }

  /// Creates a mask tensor of shape [batch, 1, maxLen]
  /// lengths: [batch]
  static List<double> lengthToMask(List<int> lengths, int maxLen) {
    final batchSize = lengths.length;
    final mask = List<double>.filled(batchSize * maxLen, 0.0);

    for (int b = 0; b < batchSize; b++) {
      final len = lengths[b];
      for (int i = 0; i < maxLen; i++) {
        if (i < len) {
          mask[b * maxLen + i] = 1.0;
        }
      }
    }
    return mask;
  }

  /// Finds the maximum value in a list of integers
  static int maxInt(List<int> list) {
    return list.reduce(max);
  }
}
