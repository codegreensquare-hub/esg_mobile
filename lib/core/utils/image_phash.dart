import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// DCT-based perceptual hash computation.
///
/// Algorithm:
/// 1. Decode image and resize to 32×32
/// 2. Convert to grayscale
/// 3. Apply 2D DCT
/// 4. Take top-left 8×8 coefficients
/// 5. Median threshold → 64-bit hash → 16-char hex string
class ImagePhash {
  static const int _hashSize = 32;
  static const int _dctSize = 8;

  static List<List<double>>? _dctMatrix;

  /// Precompute DCT coefficient matrix.
  static List<List<double>> _buildDctMatrix(int n) {
    if (_dctMatrix != null && _dctMatrix!.length == n) return _dctMatrix!;
    final matrix = List.generate(n, (k) {
      return List.generate(n, (i) {
        return cos(pi * (2 * i + 1) * k / (2 * n));
      });
    });
    _dctMatrix = matrix;
    return matrix;
  }

  /// Compute perceptual hash from raw image bytes (JPEG/PNG).
  /// Returns a 16-character hex string (64-bit hash).
  static Future<String> compute(Uint8List imageBytes) async {
    // Decode image
    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: _hashSize,
      targetHeight: _hashSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Get pixel data
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to get image pixel data');
    }

    final pixels = byteData.buffer.asUint8List();

    // Convert to grayscale matrix
    final gray = List.generate(_hashSize, (y) {
      return List.generate(_hashSize, (x) {
        final i = (y * _hashSize + x) * 4;
        return 0.299 * pixels[i] + 0.587 * pixels[i + 1] + 0.114 * pixels[i + 2];
      });
    });

    // Apply 2D DCT, take top-left 8×8
    final dct = _dct2d(gray, _dctSize);

    // Flatten to 64 values (excluding DC component at [0][0])
    final values = <double>[];
    for (var y = 0; y < _dctSize; y++) {
      for (var x = 0; x < _dctSize; x++) {
        if (y == 0 && x == 0) continue;
        values.add(dct[y][x]);
      }
    }

    // Compute median
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    final median = sorted.length.isEven
        ? (sorted[mid - 1] + sorted[mid]) / 2
        : sorted[mid];

    // Build 64-bit hash
    final bits = StringBuffer();
    for (var y = 0; y < _dctSize; y++) {
      for (var x = 0; x < _dctSize; x++) {
        bits.write(dct[y][x] >= median ? '1' : '0');
      }
    }

    // Convert 64 bits to 16-char hex
    final bitStr = bits.toString();
    final hex = StringBuffer();
    for (var i = 0; i < 64; i += 4) {
      hex.write(int.parse(bitStr.substring(i, i + 4), radix: 2).toRadixString(16));
    }
    return hex.toString();
  }

  /// 2D DCT returning top-left [size] × [size] coefficients.
  static List<List<double>> _dct2d(
    List<List<double>> pixels,
    int size,
  ) {
    final n = pixels.length;
    final matrix = _buildDctMatrix(n);

    // Row-wise DCT
    final rowDct = List.generate(n, (y) {
      return List.generate(size, (k) {
        var sum = 0.0;
        for (var x = 0; x < n; x++) {
          sum += pixels[y][x] * matrix[k][x];
        }
        return sum;
      });
    });

    // Column-wise DCT
    return List.generate(size, (ky) {
      return List.generate(size, (kx) {
        var sum = 0.0;
        for (var y = 0; y < n; y++) {
          sum += rowDct[y][kx] * matrix[ky][y];
        }
        return sum;
      });
    });
  }

  /// Compute Hamming distance between two hex hash strings.
  static int hammingDistance(String hash1, String hash2) {
    if (hash1.length != hash2.length) return 64;
    var distance = 0;
    for (var i = 0; i < hash1.length; i++) {
      final xor = int.parse(hash1[i], radix: 16) ^ int.parse(hash2[i], radix: 16);
      distance += ((xor >> 3) & 1) + ((xor >> 2) & 1) + ((xor >> 1) & 1) + (xor & 1);
    }
    return distance;
  }
}
