// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, FolderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagColorMeta = const VerificationMeta(
    'flagColor',
  );
  @override
  late final GeneratedColumn<String> flagColor = GeneratedColumn<String>(
    'flag_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppLanguage, String>
  originalLanguage = GeneratedColumn<String>(
    'original_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  ).withConverter<AppLanguage>($FoldersTable.$converteroriginalLanguage);
  @override
  late final GeneratedColumnWithTypeConverter<AppLanguage, String>
  translationLanguage = GeneratedColumn<String>(
    'translation_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ko'),
  ).withConverter<AppLanguage>($FoldersTable.$convertertranslationLanguage);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    flagColor,
    originalLanguage,
    translationLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('flag_color')) {
      context.handle(
        _flagColorMeta,
        flagColor.isAcceptableOrUnknown(data['flag_color']!, _flagColorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      flagColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flag_color'],
      ),
      originalLanguage: $FoldersTable.$converteroriginalLanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original_language'],
        )!,
      ),
      translationLanguage: $FoldersTable.$convertertranslationLanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}translation_language'],
        )!,
      ),
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }

  static TypeConverter<AppLanguage, String> $converteroriginalLanguage =
      const AppLanguageConverter();
  static TypeConverter<AppLanguage, String> $convertertranslationLanguage =
      const AppLanguageConverter();
}

class FolderEntry extends DataClass implements Insertable<FolderEntry> {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? flagColor;
  final AppLanguage originalLanguage;
  final AppLanguage translationLanguage;
  const FolderEntry({
    required this.id,
    required this.name,
    required this.createdAt,
    this.flagColor,
    required this.originalLanguage,
    required this.translationLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || flagColor != null) {
      map['flag_color'] = Variable<String>(flagColor);
    }
    {
      map['original_language'] = Variable<String>(
        $FoldersTable.$converteroriginalLanguage.toSql(originalLanguage),
      );
    }
    {
      map['translation_language'] = Variable<String>(
        $FoldersTable.$convertertranslationLanguage.toSql(translationLanguage),
      );
    }
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      flagColor: flagColor == null && nullToAbsent
          ? const Value.absent()
          : Value(flagColor),
      originalLanguage: Value(originalLanguage),
      translationLanguage: Value(translationLanguage),
    );
  }

  factory FolderEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      flagColor: serializer.fromJson<String?>(json['flagColor']),
      originalLanguage: serializer.fromJson<AppLanguage>(
        json['originalLanguage'],
      ),
      translationLanguage: serializer.fromJson<AppLanguage>(
        json['translationLanguage'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'flagColor': serializer.toJson<String?>(flagColor),
      'originalLanguage': serializer.toJson<AppLanguage>(originalLanguage),
      'translationLanguage': serializer.toJson<AppLanguage>(
        translationLanguage,
      ),
    };
  }

  FolderEntry copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Value<String?> flagColor = const Value.absent(),
    AppLanguage? originalLanguage,
    AppLanguage? translationLanguage,
  }) => FolderEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    flagColor: flagColor.present ? flagColor.value : this.flagColor,
    originalLanguage: originalLanguage ?? this.originalLanguage,
    translationLanguage: translationLanguage ?? this.translationLanguage,
  );
  FolderEntry copyWithCompanion(FoldersCompanion data) {
    return FolderEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      flagColor: data.flagColor.present ? data.flagColor.value : this.flagColor,
      originalLanguage: data.originalLanguage.present
          ? data.originalLanguage.value
          : this.originalLanguage,
      translationLanguage: data.translationLanguage.present
          ? data.translationLanguage.value
          : this.translationLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('flagColor: $flagColor, ')
          ..write('originalLanguage: $originalLanguage, ')
          ..write('translationLanguage: $translationLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    flagColor,
    originalLanguage,
    translationLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.flagColor == this.flagColor &&
          other.originalLanguage == this.originalLanguage &&
          other.translationLanguage == this.translationLanguage);
}

class FoldersCompanion extends UpdateCompanion<FolderEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<String?> flagColor;
  final Value<AppLanguage> originalLanguage;
  final Value<AppLanguage> translationLanguage;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.flagColor = const Value.absent(),
    this.originalLanguage = const Value.absent(),
    this.translationLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.flagColor = const Value.absent(),
    this.originalLanguage = const Value.absent(),
    this.translationLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<FolderEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<String>? flagColor,
    Expression<String>? originalLanguage,
    Expression<String>? translationLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (flagColor != null) 'flag_color': flagColor,
      if (originalLanguage != null) 'original_language': originalLanguage,
      if (translationLanguage != null)
        'translation_language': translationLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<String?>? flagColor,
    Value<AppLanguage>? originalLanguage,
    Value<AppLanguage>? translationLanguage,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      flagColor: flagColor ?? this.flagColor,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (flagColor.present) {
      map['flag_color'] = Variable<String>(flagColor.value);
    }
    if (originalLanguage.present) {
      map['original_language'] = Variable<String>(
        $FoldersTable.$converteroriginalLanguage.toSql(originalLanguage.value),
      );
    }
    if (translationLanguage.present) {
      map['translation_language'] = Variable<String>(
        $FoldersTable.$convertertranslationLanguage.toSql(
          translationLanguage.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('flagColor: $flagColor, ')
          ..write('originalLanguage: $originalLanguage, ')
          ..write('translationLanguage: $translationLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SentencesTable extends Sentences
    with TableInfo<$SentencesTable, SentenceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SentenceText, String> original =
      GeneratedColumn<String>(
        'original',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SentenceText>($SentencesTable.$converteroriginal);
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Difficulty, String> difficulty =
      GeneratedColumn<String>(
        'difficulty',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Difficulty>($SentencesTable.$converterdifficulty);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  paraphrases = GeneratedColumn<String>(
    'paraphrases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($SentencesTable.$converterparaphrases);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    order,
    original,
    translation,
    difficulty,
    paraphrases,
    notes,
    isFavorite,
    folderId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sentences';
  @override
  VerificationContext validateIntegrity(
    Insertable<SentenceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SentenceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentenceEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      original: $SentencesTable.$converteroriginal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}original'],
        )!,
      ),
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      difficulty: $SentencesTable.$converterdifficulty.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}difficulty'],
        )!,
      ),
      paraphrases: $SentencesTable.$converterparaphrases.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}paraphrases'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
    );
  }

  @override
  $SentencesTable createAlias(String alias) {
    return $SentencesTable(attachedDatabase, alias);
  }

  static TypeConverter<SentenceText, String> $converteroriginal =
      const SentenceTextConverter();
  static TypeConverter<Difficulty, String> $converterdifficulty =
      const DifficultyConverter();
  static TypeConverter<List<String>, String> $converterparaphrases =
      const StringListConverter();
}

class SentenceEntry extends DataClass implements Insertable<SentenceEntry> {
  final int id;
  final int order;
  final SentenceText original;
  final String translation;
  final Difficulty difficulty;
  final List<String> paraphrases;
  final String notes;
  final bool isFavorite;
  final String? folderId;
  const SentenceEntry({
    required this.id,
    required this.order,
    required this.original,
    required this.translation,
    required this.difficulty,
    required this.paraphrases,
    required this.notes,
    required this.isFavorite,
    this.folderId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order'] = Variable<int>(order);
    {
      map['original'] = Variable<String>(
        $SentencesTable.$converteroriginal.toSql(original),
      );
    }
    map['translation'] = Variable<String>(translation);
    {
      map['difficulty'] = Variable<String>(
        $SentencesTable.$converterdifficulty.toSql(difficulty),
      );
    }
    {
      map['paraphrases'] = Variable<String>(
        $SentencesTable.$converterparaphrases.toSql(paraphrases),
      );
    }
    map['notes'] = Variable<String>(notes);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      id: Value(id),
      order: Value(order),
      original: Value(original),
      translation: Value(translation),
      difficulty: Value(difficulty),
      paraphrases: Value(paraphrases),
      notes: Value(notes),
      isFavorite: Value(isFavorite),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
    );
  }

  factory SentenceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentenceEntry(
      id: serializer.fromJson<int>(json['id']),
      order: serializer.fromJson<int>(json['order']),
      original: serializer.fromJson<SentenceText>(json['original']),
      translation: serializer.fromJson<String>(json['translation']),
      difficulty: serializer.fromJson<Difficulty>(json['difficulty']),
      paraphrases: serializer.fromJson<List<String>>(json['paraphrases']),
      notes: serializer.fromJson<String>(json['notes']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      folderId: serializer.fromJson<String?>(json['folderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'order': serializer.toJson<int>(order),
      'original': serializer.toJson<SentenceText>(original),
      'translation': serializer.toJson<String>(translation),
      'difficulty': serializer.toJson<Difficulty>(difficulty),
      'paraphrases': serializer.toJson<List<String>>(paraphrases),
      'notes': serializer.toJson<String>(notes),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'folderId': serializer.toJson<String?>(folderId),
    };
  }

  SentenceEntry copyWith({
    int? id,
    int? order,
    SentenceText? original,
    String? translation,
    Difficulty? difficulty,
    List<String>? paraphrases,
    String? notes,
    bool? isFavorite,
    Value<String?> folderId = const Value.absent(),
  }) => SentenceEntry(
    id: id ?? this.id,
    order: order ?? this.order,
    original: original ?? this.original,
    translation: translation ?? this.translation,
    difficulty: difficulty ?? this.difficulty,
    paraphrases: paraphrases ?? this.paraphrases,
    notes: notes ?? this.notes,
    isFavorite: isFavorite ?? this.isFavorite,
    folderId: folderId.present ? folderId.value : this.folderId,
  );
  SentenceEntry copyWithCompanion(SentencesCompanion data) {
    return SentenceEntry(
      id: data.id.present ? data.id.value : this.id,
      order: data.order.present ? data.order.value : this.order,
      original: data.original.present ? data.original.value : this.original,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      paraphrases: data.paraphrases.present
          ? data.paraphrases.value
          : this.paraphrases,
      notes: data.notes.present ? data.notes.value : this.notes,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SentenceEntry(')
          ..write('id: $id, ')
          ..write('order: $order, ')
          ..write('original: $original, ')
          ..write('translation: $translation, ')
          ..write('difficulty: $difficulty, ')
          ..write('paraphrases: $paraphrases, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('folderId: $folderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    order,
    original,
    translation,
    difficulty,
    paraphrases,
    notes,
    isFavorite,
    folderId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentenceEntry &&
          other.id == this.id &&
          other.order == this.order &&
          other.original == this.original &&
          other.translation == this.translation &&
          other.difficulty == this.difficulty &&
          other.paraphrases == this.paraphrases &&
          other.notes == this.notes &&
          other.isFavorite == this.isFavorite &&
          other.folderId == this.folderId);
}

class SentencesCompanion extends UpdateCompanion<SentenceEntry> {
  final Value<int> id;
  final Value<int> order;
  final Value<SentenceText> original;
  final Value<String> translation;
  final Value<Difficulty> difficulty;
  final Value<List<String>> paraphrases;
  final Value<String> notes;
  final Value<bool> isFavorite;
  final Value<String?> folderId;
  const SentencesCompanion({
    this.id = const Value.absent(),
    this.order = const Value.absent(),
    this.original = const Value.absent(),
    this.translation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.paraphrases = const Value.absent(),
    this.notes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.folderId = const Value.absent(),
  });
  SentencesCompanion.insert({
    this.id = const Value.absent(),
    required int order,
    required SentenceText original,
    required String translation,
    required Difficulty difficulty,
    required List<String> paraphrases,
    required String notes,
    this.isFavorite = const Value.absent(),
    this.folderId = const Value.absent(),
  }) : order = Value(order),
       original = Value(original),
       translation = Value(translation),
       difficulty = Value(difficulty),
       paraphrases = Value(paraphrases),
       notes = Value(notes);
  static Insertable<SentenceEntry> custom({
    Expression<int>? id,
    Expression<int>? order,
    Expression<String>? original,
    Expression<String>? translation,
    Expression<String>? difficulty,
    Expression<String>? paraphrases,
    Expression<String>? notes,
    Expression<bool>? isFavorite,
    Expression<String>? folderId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (order != null) 'order': order,
      if (original != null) 'original': original,
      if (translation != null) 'translation': translation,
      if (difficulty != null) 'difficulty': difficulty,
      if (paraphrases != null) 'paraphrases': paraphrases,
      if (notes != null) 'notes': notes,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (folderId != null) 'folder_id': folderId,
    });
  }

  SentencesCompanion copyWith({
    Value<int>? id,
    Value<int>? order,
    Value<SentenceText>? original,
    Value<String>? translation,
    Value<Difficulty>? difficulty,
    Value<List<String>>? paraphrases,
    Value<String>? notes,
    Value<bool>? isFavorite,
    Value<String?>? folderId,
  }) {
    return SentencesCompanion(
      id: id ?? this.id,
      order: order ?? this.order,
      original: original ?? this.original,
      translation: translation ?? this.translation,
      difficulty: difficulty ?? this.difficulty,
      paraphrases: paraphrases ?? this.paraphrases,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (original.present) {
      map['original'] = Variable<String>(
        $SentencesTable.$converteroriginal.toSql(original.value),
      );
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(
        $SentencesTable.$converterdifficulty.toSql(difficulty.value),
      );
    }
    if (paraphrases.present) {
      map['paraphrases'] = Variable<String>(
        $SentencesTable.$converterparaphrases.toSql(paraphrases.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentencesCompanion(')
          ..write('id: $id, ')
          ..write('order: $order, ')
          ..write('original: $original, ')
          ..write('translation: $translation, ')
          ..write('difficulty: $difficulty, ')
          ..write('paraphrases: $paraphrases, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('folderId: $folderId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [folders, sentences];
}

typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<String?> flagColor,
      Value<AppLanguage> originalLanguage,
      Value<AppLanguage> translationLanguage,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<String?> flagColor,
      Value<AppLanguage> originalLanguage,
      Value<AppLanguage> translationLanguage,
      Value<int> rowid,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, FolderEntry> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SentencesTable, List<SentenceEntry>>
  _sentencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sentences,
    aliasName: $_aliasNameGenerator(db.folders.id, db.sentences.folderId),
  );

  $$SentencesTableProcessedTableManager get sentencesRefs {
    final manager = $$SentencesTableTableManager(
      $_db,
      $_db.sentences,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sentencesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagColor => $composableBuilder(
    column: $table.flagColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppLanguage, AppLanguage, String>
  get originalLanguage => $composableBuilder(
    column: $table.originalLanguage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AppLanguage, AppLanguage, String>
  get translationLanguage => $composableBuilder(
    column: $table.translationLanguage,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> sentencesRefs(
    Expression<bool> Function($$SentencesTableFilterComposer f) f,
  ) {
    final $$SentencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableFilterComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagColor => $composableBuilder(
    column: $table.flagColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalLanguage => $composableBuilder(
    column: $table.originalLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationLanguage => $composableBuilder(
    column: $table.translationLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get flagColor =>
      $composableBuilder(column: $table.flagColor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppLanguage, String> get originalLanguage =>
      $composableBuilder(
        column: $table.originalLanguage,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<AppLanguage, String>
  get translationLanguage => $composableBuilder(
    column: $table.translationLanguage,
    builder: (column) => column,
  );

  Expression<T> sentencesRefs<T extends Object>(
    Expression<T> Function($$SentencesTableAnnotationComposer a) f,
  ) {
    final $$SentencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sentences,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SentencesTableAnnotationComposer(
            $db: $db,
            $table: $db.sentences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          FolderEntry,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (FolderEntry, $$FoldersTableReferences),
          FolderEntry,
          PrefetchHooks Function({bool sentencesRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> flagColor = const Value.absent(),
                Value<AppLanguage> originalLanguage = const Value.absent(),
                Value<AppLanguage> translationLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                flagColor: flagColor,
                originalLanguage: originalLanguage,
                translationLanguage: translationLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<String?> flagColor = const Value.absent(),
                Value<AppLanguage> originalLanguage = const Value.absent(),
                Value<AppLanguage> translationLanguage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                flagColor: flagColor,
                originalLanguage: originalLanguage,
                translationLanguage: translationLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sentencesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sentencesRefs) db.sentences],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sentencesRefs)
                    await $_getPrefetchedData<
                      FolderEntry,
                      $FoldersTable,
                      SentenceEntry
                    >(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._sentencesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).sentencesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      FolderEntry,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (FolderEntry, $$FoldersTableReferences),
      FolderEntry,
      PrefetchHooks Function({bool sentencesRefs})
    >;
typedef $$SentencesTableCreateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      required int order,
      required SentenceText original,
      required String translation,
      required Difficulty difficulty,
      required List<String> paraphrases,
      required String notes,
      Value<bool> isFavorite,
      Value<String?> folderId,
    });
typedef $$SentencesTableUpdateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      Value<int> order,
      Value<SentenceText> original,
      Value<String> translation,
      Value<Difficulty> difficulty,
      Value<List<String>> paraphrases,
      Value<String> notes,
      Value<bool> isFavorite,
      Value<String?> folderId,
    });

final class $$SentencesTableReferences
    extends BaseReferences<_$AppDatabase, $SentencesTable, SentenceEntry> {
  $$SentencesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) => db.folders
      .createAlias($_aliasNameGenerator(db.sentences.folderId, db.folders.id));

  $$FoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SentencesTableFilterComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SentenceText, SentenceText, String>
  get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Difficulty, Difficulty, String>
  get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get paraphrases => $composableBuilder(
    column: $table.paraphrases,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get original => $composableBuilder(
    column: $table.original,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paraphrases => $composableBuilder(
    column: $table.paraphrases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentencesTable> {
  $$SentencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SentenceText, String> get original =>
      $composableBuilder(column: $table.original, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Difficulty, String> get difficulty =>
      $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<String>, String> get paraphrases =>
      $composableBuilder(
        column: $table.paraphrases,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SentencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentencesTable,
          SentenceEntry,
          $$SentencesTableFilterComposer,
          $$SentencesTableOrderingComposer,
          $$SentencesTableAnnotationComposer,
          $$SentencesTableCreateCompanionBuilder,
          $$SentencesTableUpdateCompanionBuilder,
          (SentenceEntry, $$SentencesTableReferences),
          SentenceEntry,
          PrefetchHooks Function({bool folderId})
        > {
  $$SentencesTableTableManager(_$AppDatabase db, $SentencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<SentenceText> original = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<Difficulty> difficulty = const Value.absent(),
                Value<List<String>> paraphrases = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
              }) => SentencesCompanion(
                id: id,
                order: order,
                original: original,
                translation: translation,
                difficulty: difficulty,
                paraphrases: paraphrases,
                notes: notes,
                isFavorite: isFavorite,
                folderId: folderId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int order,
                required SentenceText original,
                required String translation,
                required Difficulty difficulty,
                required List<String> paraphrases,
                required String notes,
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
              }) => SentencesCompanion.insert(
                id: id,
                order: order,
                original: original,
                translation: translation,
                difficulty: difficulty,
                paraphrases: paraphrases,
                notes: notes,
                isFavorite: isFavorite,
                folderId: folderId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SentencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$SentencesTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$SentencesTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SentencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentencesTable,
      SentenceEntry,
      $$SentencesTableFilterComposer,
      $$SentencesTableOrderingComposer,
      $$SentencesTableAnnotationComposer,
      $$SentencesTableCreateCompanionBuilder,
      $$SentencesTableUpdateCompanionBuilder,
      (SentenceEntry, $$SentencesTableReferences),
      SentenceEntry,
      PrefetchHooks Function({bool folderId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
}
