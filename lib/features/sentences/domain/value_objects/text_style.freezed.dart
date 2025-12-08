// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_style.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TextStyle {

/// The type of style (bold, highlight, etc.)
@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) TextStyleType get type;/// The range of text this style applies to
 TextRange get range;/// Optional value for styles that need it (e.g., color: "#FF0000")
 String? get value;
/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextStyleCopyWith<TextStyle> get copyWith => _$TextStyleCopyWithImpl<TextStyle>(this as TextStyle, _$identity);

  /// Serializes this TextStyle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextStyle&&(identical(other.type, type) || other.type == type)&&(identical(other.range, range) || other.range == range)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,range,value);

@override
String toString() {
  return 'TextStyle(type: $type, range: $range, value: $value)';
}


}

/// @nodoc
abstract mixin class $TextStyleCopyWith<$Res>  {
  factory $TextStyleCopyWith(TextStyle value, $Res Function(TextStyle) _then) = _$TextStyleCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) TextStyleType type, TextRange range, String? value
});


$TextRangeCopyWith<$Res> get range;

}
/// @nodoc
class _$TextStyleCopyWithImpl<$Res>
    implements $TextStyleCopyWith<$Res> {
  _$TextStyleCopyWithImpl(this._self, this._then);

  final TextStyle _self;
  final $Res Function(TextStyle) _then;

/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? range = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TextStyleType,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextRangeCopyWith<$Res> get range {
  
  return $TextRangeCopyWith<$Res>(_self.range, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}


/// Adds pattern-matching-related methods to [TextStyle].
extension TextStylePatterns on TextStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextStyle value)  $default,){
final _that = this;
switch (_that) {
case _TextStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextStyle value)?  $default,){
final _that = this;
switch (_that) {
case _TextStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)  TextStyleType type,  TextRange range,  String? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextStyle() when $default != null:
return $default(_that.type,_that.range,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)  TextStyleType type,  TextRange range,  String? value)  $default,) {final _that = this;
switch (_that) {
case _TextStyle():
return $default(_that.type,_that.range,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)  TextStyleType type,  TextRange range,  String? value)?  $default,) {final _that = this;
switch (_that) {
case _TextStyle() when $default != null:
return $default(_that.type,_that.range,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextStyle implements TextStyle {
  const _TextStyle({@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) required this.type, required this.range, this.value});
  factory _TextStyle.fromJson(Map<String, dynamic> json) => _$TextStyleFromJson(json);

/// The type of style (bold, highlight, etc.)
@override@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) final  TextStyleType type;
/// The range of text this style applies to
@override final  TextRange range;
/// Optional value for styles that need it (e.g., color: "#FF0000")
@override final  String? value;

/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextStyleCopyWith<_TextStyle> get copyWith => __$TextStyleCopyWithImpl<_TextStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextStyleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextStyle&&(identical(other.type, type) || other.type == type)&&(identical(other.range, range) || other.range == range)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,range,value);

@override
String toString() {
  return 'TextStyle(type: $type, range: $range, value: $value)';
}


}

/// @nodoc
abstract mixin class _$TextStyleCopyWith<$Res> implements $TextStyleCopyWith<$Res> {
  factory _$TextStyleCopyWith(_TextStyle value, $Res Function(_TextStyle) _then) = __$TextStyleCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _typeFromJson, toJson: _typeToJson) TextStyleType type, TextRange range, String? value
});


@override $TextRangeCopyWith<$Res> get range;

}
/// @nodoc
class __$TextStyleCopyWithImpl<$Res>
    implements _$TextStyleCopyWith<$Res> {
  __$TextStyleCopyWithImpl(this._self, this._then);

  final _TextStyle _self;
  final $Res Function(_TextStyle) _then;

/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? range = null,Object? value = freezed,}) {
  return _then(_TextStyle(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TextStyleType,range: null == range ? _self.range : range // ignore: cast_nullable_to_non_nullable
as TextRange,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of TextStyle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextRangeCopyWith<$Res> get range {
  
  return $TextRangeCopyWith<$Res>(_self.range, (value) {
    return _then(_self.copyWith(range: value));
  });
}
}

// dart format on
