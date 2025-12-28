// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_generated_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiGeneratedContent {

 String get translation; String get notes; String get examples;
/// Create a copy of AiGeneratedContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiGeneratedContentCopyWith<AiGeneratedContent> get copyWith => _$AiGeneratedContentCopyWithImpl<AiGeneratedContent>(this as AiGeneratedContent, _$identity);

  /// Serializes this AiGeneratedContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiGeneratedContent&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.examples, examples) || other.examples == examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,translation,notes,examples);

@override
String toString() {
  return 'AiGeneratedContent(translation: $translation, notes: $notes, examples: $examples)';
}


}

/// @nodoc
abstract mixin class $AiGeneratedContentCopyWith<$Res>  {
  factory $AiGeneratedContentCopyWith(AiGeneratedContent value, $Res Function(AiGeneratedContent) _then) = _$AiGeneratedContentCopyWithImpl;
@useResult
$Res call({
 String translation, String notes, String examples
});




}
/// @nodoc
class _$AiGeneratedContentCopyWithImpl<$Res>
    implements $AiGeneratedContentCopyWith<$Res> {
  _$AiGeneratedContentCopyWithImpl(this._self, this._then);

  final AiGeneratedContent _self;
  final $Res Function(AiGeneratedContent) _then;

/// Create a copy of AiGeneratedContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? translation = null,Object? notes = null,Object? examples = null,}) {
  return _then(_self.copyWith(
translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiGeneratedContent].
extension AiGeneratedContentPatterns on AiGeneratedContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiGeneratedContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiGeneratedContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiGeneratedContent value)  $default,){
final _that = this;
switch (_that) {
case _AiGeneratedContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiGeneratedContent value)?  $default,){
final _that = this;
switch (_that) {
case _AiGeneratedContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String translation,  String notes,  String examples)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiGeneratedContent() when $default != null:
return $default(_that.translation,_that.notes,_that.examples);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String translation,  String notes,  String examples)  $default,) {final _that = this;
switch (_that) {
case _AiGeneratedContent():
return $default(_that.translation,_that.notes,_that.examples);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String translation,  String notes,  String examples)?  $default,) {final _that = this;
switch (_that) {
case _AiGeneratedContent() when $default != null:
return $default(_that.translation,_that.notes,_that.examples);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiGeneratedContent implements AiGeneratedContent {
  const _AiGeneratedContent({required this.translation, required this.notes, required this.examples});
  factory _AiGeneratedContent.fromJson(Map<String, dynamic> json) => _$AiGeneratedContentFromJson(json);

@override final  String translation;
@override final  String notes;
@override final  String examples;

/// Create a copy of AiGeneratedContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiGeneratedContentCopyWith<_AiGeneratedContent> get copyWith => __$AiGeneratedContentCopyWithImpl<_AiGeneratedContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiGeneratedContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiGeneratedContent&&(identical(other.translation, translation) || other.translation == translation)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.examples, examples) || other.examples == examples));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,translation,notes,examples);

@override
String toString() {
  return 'AiGeneratedContent(translation: $translation, notes: $notes, examples: $examples)';
}


}

/// @nodoc
abstract mixin class _$AiGeneratedContentCopyWith<$Res> implements $AiGeneratedContentCopyWith<$Res> {
  factory _$AiGeneratedContentCopyWith(_AiGeneratedContent value, $Res Function(_AiGeneratedContent) _then) = __$AiGeneratedContentCopyWithImpl;
@override @useResult
$Res call({
 String translation, String notes, String examples
});




}
/// @nodoc
class __$AiGeneratedContentCopyWithImpl<$Res>
    implements _$AiGeneratedContentCopyWith<$Res> {
  __$AiGeneratedContentCopyWithImpl(this._self, this._then);

  final _AiGeneratedContent _self;
  final $Res Function(_AiGeneratedContent) _then;

/// Create a copy of AiGeneratedContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? translation = null,Object? notes = null,Object? examples = null,}) {
  return _then(_AiGeneratedContent(
translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,examples: null == examples ? _self.examples : examples // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
