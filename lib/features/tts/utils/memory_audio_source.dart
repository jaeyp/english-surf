import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

class MemoryAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  final int sampleRate;
  final int channels;
  final int bitDepth;

  MemoryAudioSource(
    this._bytes, {
    this.sampleRate = 22050,
    this.channels = 1,
    this.bitDepth = 16,
  });

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final header = _wavHeader();
    final totalSize = header.length + _bytes.length;

    start ??= 0;
    end ??= totalSize;

    // Correctly handle range requests if needed, but for simple streaming often JustAudio requests everything.
    // However, to be compliant, we should handle start/end.
    // StreamAudioSource documentation says: "The start and end offsets are optional. If not provided, the entire source is requested."

    // Construct the full byte array (header + data) conceptually
    // But for efficiency, we stream header then data.

    // Calculate content length
    final contentLength = end - start;

    return StreamAudioResponse(
      sourceLength: totalSize,
      contentLength: contentLength,
      offset: start,
      stream: Stream.value(
        Uint8List.fromList([...header, ..._bytes].sublist(start, end)),
      ),
      contentType: 'audio/wav',
    );
  }

  Uint8List _wavHeader() {
    final byteRate = sampleRate * channels * (bitDepth ~/ 8);
    final blockAlign = channels * (bitDepth ~/ 8);
    final dataSize = _bytes.length;
    final totalSize = 36 + dataSize;

    final header = ByteData(44);

    // RIFF chunk
    _writeString(header, 0, 'RIFF');
    header.setUint32(4, totalSize, Endian.little);
    _writeString(header, 8, 'WAVE');

    // fmt chunk
    _writeString(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // Chunk size
    header.setUint16(20, 1, Endian.little); // Audio format (PCM)
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitDepth, Endian.little);

    // data chunk
    _writeString(header, 36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    return header.buffer.asUint8List();
  }

  void _writeString(ByteData data, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}
