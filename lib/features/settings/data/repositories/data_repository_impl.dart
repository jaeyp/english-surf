import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../features/sentences/data/providers/sentence_providers.dart';
import '../../../../features/sentences/domain/enums/difficulty.dart';
import '../../../../features/sentences/domain/value_objects/sentence_text.dart';
import '../../domain/repositories/data_repository.dart';

final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepositoryImpl(ref.read(appDatabaseProvider));
});

class DataRepositoryImpl implements DataRepository {
  final AppDatabase _db;

  DataRepositoryImpl(this._db);

  @override
  Future<void> exportData() async {
    // 1. Fetch All Folders
    final folders = await _db.getAllFolders();
    final List<XFile> filesToShare = [];
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

    // 2. Iterate and Create File per Folder
    for (var folder in folders) {
      final sentences = await _db.getSentencesInFolder(folder.id);

      final Map<String, dynamic> data = {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'folder': {
          'id': folder.id,
          'name': folder.name,
          'created_at': folder.createdAt.toIso8601String(),
          'flag_color': folder.flagColor,
        },
        'sentences': sentences
            .map(
              (s) => {
                'id': s.id,
                'order': s.order,
                'original': s.original.toJson(),
                'translation': s.translation,
                'difficulty': s.difficulty.toJson(),
                'paraphrases': s.paraphrases,
                'notes': s.notes,
                'is_favorite': s.isFavorite,
                'folder_id': s.folderId,
              },
            )
            .toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Sanitize folder name for filename
      final safeFolderName = folder.name
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');
      final fileName = 'backup_${safeFolderName}_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);
      filesToShare.add(XFile(file.path));
    }

    // 3. Share All Files
    if (filesToShare.isNotEmpty) {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        filesToShare,
        text: 'LingoPocket Backups ($timestamp)',
      );
    }
  }

  @override
  Future<void> importData() async {
    // 1. Pick Multiple Files
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    // 2. Iterate and Restore
    for (var pickedFile in result.files) {
      if (pickedFile.path == null) continue;

      final file = File(pickedFile.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 3. Parse & Insert Folder
      if (data.containsKey('folder')) {
        final f = data['folder'];
        final folderEntry = FoldersCompanion(
          id: Value(f['id']),
          name: Value(f['name']),
          createdAt: Value(DateTime.parse(f['created_at'])),
          flagColor: f['flag_color'] != null
              ? Value(f['flag_color'])
              : const Value.absent(),
        );

        // Insert folder first
        await _db.insertAllFolders([folderEntry]);
      } else if (data.containsKey('folders')) {
        // Fallback for legacy format with list
        final List<dynamic> folderList = data['folders'];
        final List<FoldersCompanion> folderEntries = folderList
            .map(
              (f) => FoldersCompanion(
                id: Value(f['id']),
                name: Value(f['name']),
                createdAt: Value(DateTime.parse(f['created_at'])),
                flagColor: f['flag_color'] != null
                    ? Value(f['flag_color'])
                    : const Value.absent(),
              ),
            )
            .toList();
        await _db.insertAllFolders(folderEntries);
      }

      // 4. Parse & Insert Sentences
      if (data.containsKey('sentences')) {
        final List<dynamic> sentenceList = data['sentences'];
        final List<SentencesCompanion> sentenceEntries = sentenceList.map((s) {
          return SentencesCompanion(
            order: Value(s['order']),
            original: Value(SentenceText.fromJson(s['original'])),
            translation: Value(s['translation']),
            difficulty: Value(Difficulty.fromJson(s['difficulty'])),
            paraphrases: Value(List<String>.from(s['paraphrases'])),
            notes: Value(s['notes']),
            isFavorite: Value(s['is_favorite']),
            folderId: s['folder_id'] != null
                ? Value(s['folder_id'])
                : const Value.absent(),
          );
        }).toList();

        await _db.insertAllSentences(sentenceEntries);
      }
    }
  }
}
