import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_surf/features/tts/utils/memory_audio_source.dart';

void main() {
  test(
    'MemoryAudioSource should prepend valid WAV header to PCM data',
    () async {
      // Arrange
      final pcmData = Uint8List.fromList([
        0x01,
        0x02,
        0x03,
        0x04,
      ]); // 4 bytes of PCM
      const sampleRate = 22050;
      const channels = 1;
      const bitDepth = 16;

      final source = MemoryAudioSource(
        pcmData,
        sampleRate: sampleRate,
        channels: channels,
        bitDepth: bitDepth,
      );

      // Act
      final response = await source.request(); // Request entire source
      final stream = response.stream;

      final bytes = <int>[];
      await for (final chunk in stream) {
        bytes.addAll(chunk);
      }

      // Assert
      // Total size = 44 (header) + 4 (data) = 48 bytes
      expect(bytes.length, 48);

      // Check RIFF header
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      // File size - 8 = 40 (0x28)
      final fileSizeFunc = Uint8List.fromList(
        bytes.sublist(4, 8),
      ).buffer.asByteData().getUint32(0, Endian.little);
      expect(fileSizeFunc, 40);

      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
      expect(String.fromCharCodes(bytes.sublist(12, 16)), 'fmt ');

      // Chunk size 16
      expect(
        Uint8List.fromList(
          bytes.sublist(16, 20),
        ).buffer.asByteData().getUint32(0, Endian.little),
        16,
      );
      // AudioFormat 1 (PCM)
      expect(
        Uint8List.fromList(
          bytes.sublist(20, 22),
        ).buffer.asByteData().getUint16(0, Endian.little),
        1,
      );
      // Channels
      expect(
        Uint8List.fromList(
          bytes.sublist(22, 24),
        ).buffer.asByteData().getUint16(0, Endian.little),
        channels,
      );
      // Sample Rate
      expect(
        Uint8List.fromList(
          bytes.sublist(24, 28),
        ).buffer.asByteData().getUint32(0, Endian.little),
        sampleRate,
      );

      // Byte Rate = SampleRate * Channels * Bits/8 = 22050 * 1 * 2 = 44100
      expect(
        Uint8List.fromList(
          bytes.sublist(28, 32),
        ).buffer.asByteData().getUint32(0, Endian.little),
        44100,
      );

      // Block Align = Channels * Bits/8 = 2
      expect(
        Uint8List.fromList(
          bytes.sublist(32, 34),
        ).buffer.asByteData().getUint16(0, Endian.little),
        2,
      );

      // BitsPerSample
      expect(
        Uint8List.fromList(
          bytes.sublist(34, 36),
        ).buffer.asByteData().getUint16(0, Endian.little),
        16,
      );

      // Data chunk
      expect(String.fromCharCodes(bytes.sublist(36, 40)), 'data');
      // Data size = 4
      expect(
        Uint8List.fromList(
          bytes.sublist(40, 44),
        ).buffer.asByteData().getUint32(0, Endian.little),
        4,
      );

      // Content
      expect(bytes.sublist(44, 48), pcmData);
    },
  );
}
