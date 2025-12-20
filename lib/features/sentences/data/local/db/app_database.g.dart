// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
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
  late final GeneratedColumnWithTypeConverter<List<String>, String> examples =
      GeneratedColumn<String>(
        'examples',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($SentencesTable.$converterexamples);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    order,
    original,
    translation,
    difficulty,
    examples,
    notes,
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
      examples: $SentencesTable.$converterexamples.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}examples'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
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
  static TypeConverter<List<String>, String> $converterexamples =
      const StringListConverter();
}

class SentenceEntry extends DataClass implements Insertable<SentenceEntry> {
  final int id;
  final int order;
  final SentenceText original;
  final String translation;
  final Difficulty difficulty;
  final List<String> examples;
  final String notes;
  const SentenceEntry({
    required this.id,
    required this.order,
    required this.original,
    required this.translation,
    required this.difficulty,
    required this.examples,
    required this.notes,
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
      map['examples'] = Variable<String>(
        $SentencesTable.$converterexamples.toSql(examples),
      );
    }
    map['notes'] = Variable<String>(notes);
    return map;
  }

  SentencesCompanion toCompanion(bool nullToAbsent) {
    return SentencesCompanion(
      id: Value(id),
      order: Value(order),
      original: Value(original),
      translation: Value(translation),
      difficulty: Value(difficulty),
      examples: Value(examples),
      notes: Value(notes),
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
      examples: serializer.fromJson<List<String>>(json['examples']),
      notes: serializer.fromJson<String>(json['notes']),
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
      'examples': serializer.toJson<List<String>>(examples),
      'notes': serializer.toJson<String>(notes),
    };
  }

  SentenceEntry copyWith({
    int? id,
    int? order,
    SentenceText? original,
    String? translation,
    Difficulty? difficulty,
    List<String>? examples,
    String? notes,
  }) => SentenceEntry(
    id: id ?? this.id,
    order: order ?? this.order,
    original: original ?? this.original,
    translation: translation ?? this.translation,
    difficulty: difficulty ?? this.difficulty,
    examples: examples ?? this.examples,
    notes: notes ?? this.notes,
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
      examples: data.examples.present ? data.examples.value : this.examples,
      notes: data.notes.present ? data.notes.value : this.notes,
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
          ..write('examples: $examples, ')
          ..write('notes: $notes')
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
    examples,
    notes,
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
          other.examples == this.examples &&
          other.notes == this.notes);
}

class SentencesCompanion extends UpdateCompanion<SentenceEntry> {
  final Value<int> id;
  final Value<int> order;
  final Value<SentenceText> original;
  final Value<String> translation;
  final Value<Difficulty> difficulty;
  final Value<List<String>> examples;
  final Value<String> notes;
  const SentencesCompanion({
    this.id = const Value.absent(),
    this.order = const Value.absent(),
    this.original = const Value.absent(),
    this.translation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.examples = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SentencesCompanion.insert({
    this.id = const Value.absent(),
    required int order,
    required SentenceText original,
    required String translation,
    required Difficulty difficulty,
    required List<String> examples,
    required String notes,
  }) : order = Value(order),
       original = Value(original),
       translation = Value(translation),
       difficulty = Value(difficulty),
       examples = Value(examples),
       notes = Value(notes);
  static Insertable<SentenceEntry> custom({
    Expression<int>? id,
    Expression<int>? order,
    Expression<String>? original,
    Expression<String>? translation,
    Expression<String>? difficulty,
    Expression<String>? examples,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (order != null) 'order': order,
      if (original != null) 'original': original,
      if (translation != null) 'translation': translation,
      if (difficulty != null) 'difficulty': difficulty,
      if (examples != null) 'examples': examples,
      if (notes != null) 'notes': notes,
    });
  }

  SentencesCompanion copyWith({
    Value<int>? id,
    Value<int>? order,
    Value<SentenceText>? original,
    Value<String>? translation,
    Value<Difficulty>? difficulty,
    Value<List<String>>? examples,
    Value<String>? notes,
  }) {
    return SentencesCompanion(
      id: id ?? this.id,
      order: order ?? this.order,
      original: original ?? this.original,
      translation: translation ?? this.translation,
      difficulty: difficulty ?? this.difficulty,
      examples: examples ?? this.examples,
      notes: notes ?? this.notes,
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
    if (examples.present) {
      map['examples'] = Variable<String>(
        $SentencesTable.$converterexamples.toSql(examples.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
          ..write('examples: $examples, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SentencesTable sentences = $SentencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sentences];
}

typedef $$SentencesTableCreateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      required int order,
      required SentenceText original,
      required String translation,
      required Difficulty difficulty,
      required List<String> examples,
      required String notes,
    });
typedef $$SentencesTableUpdateCompanionBuilder =
    SentencesCompanion Function({
      Value<int> id,
      Value<int> order,
      Value<SentenceText> original,
      Value<String> translation,
      Value<Difficulty> difficulty,
      Value<List<String>> examples,
      Value<String> notes,
    });

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
  get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumnWithTypeConverter<List<String>, String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
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
          (
            SentenceEntry,
            BaseReferences<_$AppDatabase, $SentencesTable, SentenceEntry>,
          ),
          SentenceEntry,
          PrefetchHooks Function()
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
                Value<List<String>> examples = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SentencesCompanion(
                id: id,
                order: order,
                original: original,
                translation: translation,
                difficulty: difficulty,
                examples: examples,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int order,
                required SentenceText original,
                required String translation,
                required Difficulty difficulty,
                required List<String> examples,
                required String notes,
              }) => SentencesCompanion.insert(
                id: id,
                order: order,
                original: original,
                translation: translation,
                difficulty: difficulty,
                examples: examples,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        SentenceEntry,
        BaseReferences<_$AppDatabase, $SentencesTable, SentenceEntry>,
      ),
      SentenceEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SentencesTableTableManager get sentences =>
      $$SentencesTableTableManager(_db, _db.sentences);
}
