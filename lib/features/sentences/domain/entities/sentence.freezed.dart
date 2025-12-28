// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sentence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Sentence {

 int get id; int get order;@JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson) SentenceText get original; String get translation;@JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson) Difficulty get difficulty; List<String> get examples; String get notes; bool get isFavorite; String? get folderId;
/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SentenceCopyWith<Sentence> get copyWith => _$SentenceCopyWithImpl<Sentence>(this as Sentence, _$identity);

  /// Serializes this Sentence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sentence&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.original, original) || other.original == original)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.examples, examples)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.folderId, folderId) || other.folderId == folderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,original,translation,difficulty,const DeepCollectionEquality().hash(examples),notes,isFavorite,folderId);

@override
String toString() {
  return 'Sentence(id: $id, order: $order, original: $original, translation: $translation, difficulty: $difficulty, examples: $examples, notes: $notes, isFavorite: $isFavorite, folderId: $folderId)';
}


}

/// @nodoc
abstract mixin class $SentenceCopyWith<$Res>  {
  factory $SentenceCopyWith(Sentence value, $Res Function(Sentence) _then) = _$SentenceCopyWithImpl;
@useResult
$Res call({
 int id, int order,@JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson) SentenceText original, String translation,@JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson) Difficulty difficulty, List<String> examples, String notes, bool isFavorite, String? folderId
});


$SentenceTextCopyWith<$Res> get original;

}
/// @nodoc
class _$SentenceCopyWithImpl<$Res>
    implements $SentenceCopyWith<$Res> {
  _$SentenceCopyWithImpl(this._self, this._then);

  final Sentence _self;
  final $Res Function(Sentence) _then;

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? order = null,Object? original = null,Object? translation = null,Object? difficulty = null,Object? examples = null,Object? notes = null,Object? isFavorite = null,Object? folderId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as SentenceText,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SentenceTextCopyWith<$Res> get original {
  
  return $SentenceTextCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [Sentence].
extension SentencePatterns on Sentence {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sentence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sentence value)  $default,){
final _that = this;
switch (_that) {
case _Sentence():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sentence value)?  $default,){
final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int order, @JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson)  SentenceText original,  String translation, @JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson)  Difficulty difficulty,  List<String> examples,  String notes,  bool isFavorite,  String? folderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that.id,_that.order,_that.original,_that.translation,_that.difficulty,_that.examples,_that.notes,_that.isFavorite,_that.folderId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int order, @JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson)  SentenceText original,  String translation, @JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson)  Difficulty difficulty,  List<String> examples,  String notes,  bool isFavorite,  String? folderId)  $default,) {final _that = this;
switch (_that) {
case _Sentence():
return $default(_that.id,_that.order,_that.original,_that.translation,_that.difficulty,_that.examples,_that.notes,_that.isFavorite,_that.folderId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int order, @JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson)  SentenceText original,  String translation, @JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson)  Difficulty difficulty,  List<String> examples,  String notes,  bool isFavorite,  String? folderId)?  $default,) {final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that.id,_that.order,_that.original,_that.translation,_that.difficulty,_that.examples,_that.notes,_that.isFavorite,_that.folderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sentence implements Sentence {
  const _Sentence({required this.id, required this.order, @JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson) required this.original, required this.translation, @JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson) required this.difficulty, final  List<String> examples = const [], this.notes = '', this.isFavorite = false, this.folderId}): _examples = examples;
  factory _Sentence.fromJson(Map<String, dynamic> json) => _$SentenceFromJson(json);

@override final  int id;
@override final  int order;
@override@JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson) final  SentenceText original;
@override final  String translation;
@override@JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson) final  Difficulty difficulty;
 final  List<String> _examples;
@override@JsonKey() List<String> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}

@override@JsonKey() final  String notes;
@override@JsonKey() final  bool isFavorite;
@override final  String? folderId;

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SentenceCopyWith<_Sentence> get copyWith => __$SentenceCopyWithImpl<_Sentence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SentenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sentence&&(identical(other.id, id) || other.id == id)&&(identical(other.order, order) || other.order == order)&&(identical(other.original, original) || other.original == original)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._examples, _examples)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.folderId, folderId) || other.folderId == folderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,order,original,translation,difficulty,const DeepCollectionEquality().hash(_examples),notes,isFavorite,folderId);

@override
String toString() {
  return 'Sentence(id: $id, order: $order, original: $original, translation: $translation, difficulty: $difficulty, examples: $examples, notes: $notes, isFavorite: $isFavorite, folderId: $folderId)';
}


}

/// @nodoc
abstract mixin class _$SentenceCopyWith<$Res> implements $SentenceCopyWith<$Res> {
  factory _$SentenceCopyWith(_Sentence value, $Res Function(_Sentence) _then) = __$SentenceCopyWithImpl;
@override @useResult
$Res call({
 int id, int order,@JsonKey(name: 'original', fromJson: _sentenceTextFromJson, toJson: _sentenceTextToJson) SentenceText original, String translation,@JsonKey(fromJson: Difficulty.fromJson, toJson: _difficultyToJson) Difficulty difficulty, List<String> examples, String notes, bool isFavorite, String? folderId
});


@override $SentenceTextCopyWith<$Res> get original;

}
/// @nodoc
class __$SentenceCopyWithImpl<$Res>
    implements _$SentenceCopyWith<$Res> {
  __$SentenceCopyWithImpl(this._self, this._then);

  final _Sentence _self;
  final $Res Function(_Sentence) _then;

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? order = null,Object? original = null,Object? translation = null,Object? difficulty = null,Object? examples = null,Object? notes = null,Object? isFavorite = null,Object? folderId = freezed,}) {
  return _then(_Sentence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,original: null == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as SentenceText,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as Difficulty,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SentenceTextCopyWith<$Res> get original {
  
  return $SentenceTextCopyWith<$Res>(_self.original, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
