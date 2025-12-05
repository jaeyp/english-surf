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

 int get id; String get sentence; String get translation; String get difficulty; List<String> get examples; String get notes;
/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SentenceCopyWith<Sentence> get copyWith => _$SentenceCopyWithImpl<Sentence>(this as Sentence, _$identity);

  /// Serializes this Sentence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sentence&&(identical(other.id, id) || other.id == id)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.examples, examples)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sentence,translation,difficulty,const DeepCollectionEquality().hash(examples),notes);

@override
String toString() {
  return 'Sentence(id: $id, sentence: $sentence, translation: $translation, difficulty: $difficulty, examples: $examples, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $SentenceCopyWith<$Res>  {
  factory $SentenceCopyWith(Sentence value, $Res Function(Sentence) _then) = _$SentenceCopyWithImpl;
@useResult
$Res call({
 int id, String sentence, String translation, String difficulty, List<String> examples, String notes
});




}
/// @nodoc
class _$SentenceCopyWithImpl<$Res>
    implements $SentenceCopyWith<$Res> {
  _$SentenceCopyWithImpl(this._self, this._then);

  final Sentence _self;
  final $Res Function(Sentence) _then;

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sentence = null,Object? translation = null,Object? difficulty = null,Object? examples = null,Object? notes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String sentence,  String translation,  String difficulty,  List<String> examples,  String notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that.id,_that.sentence,_that.translation,_that.difficulty,_that.examples,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String sentence,  String translation,  String difficulty,  List<String> examples,  String notes)  $default,) {final _that = this;
switch (_that) {
case _Sentence():
return $default(_that.id,_that.sentence,_that.translation,_that.difficulty,_that.examples,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String sentence,  String translation,  String difficulty,  List<String> examples,  String notes)?  $default,) {final _that = this;
switch (_that) {
case _Sentence() when $default != null:
return $default(_that.id,_that.sentence,_that.translation,_that.difficulty,_that.examples,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sentence implements Sentence {
  const _Sentence({required this.id, required this.sentence, required this.translation, required this.difficulty, final  List<String> examples = const [], this.notes = ''}): _examples = examples;
  factory _Sentence.fromJson(Map<String, dynamic> json) => _$SentenceFromJson(json);

@override final  int id;
@override final  String sentence;
@override final  String translation;
@override final  String difficulty;
 final  List<String> _examples;
@override@JsonKey() List<String> get examples {
  if (_examples is EqualUnmodifiableListView) return _examples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_examples);
}

@override@JsonKey() final  String notes;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sentence&&(identical(other.id, id) || other.id == id)&&(identical(other.sentence, sentence) || other.sentence == sentence)&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._examples, _examples)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sentence,translation,difficulty,const DeepCollectionEquality().hash(_examples),notes);

@override
String toString() {
  return 'Sentence(id: $id, sentence: $sentence, translation: $translation, difficulty: $difficulty, examples: $examples, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$SentenceCopyWith<$Res> implements $SentenceCopyWith<$Res> {
  factory _$SentenceCopyWith(_Sentence value, $Res Function(_Sentence) _then) = __$SentenceCopyWithImpl;
@override @useResult
$Res call({
 int id, String sentence, String translation, String difficulty, List<String> examples, String notes
});




}
/// @nodoc
class __$SentenceCopyWithImpl<$Res>
    implements _$SentenceCopyWith<$Res> {
  __$SentenceCopyWithImpl(this._self, this._then);

  final _Sentence _self;
  final $Res Function(_Sentence) _then;

/// Create a copy of Sentence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sentence = null,Object? translation = null,Object? difficulty = null,Object? examples = null,Object? notes = null,}) {
  return _then(_Sentence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,sentence: null == sentence ? _self.sentence : sentence // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self._examples : examples // ignore: cast_nullable_to_non_nullable
as List<String>,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
