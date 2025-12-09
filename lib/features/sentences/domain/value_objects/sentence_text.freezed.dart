// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sentence_text.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SentenceText {

/// Plain text with all markup removed
 String get text;/// List of styles applied to the text
 List<TextStyle> get styles;
/// Create a copy of SentenceText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SentenceTextCopyWith<SentenceText> get copyWith => _$SentenceTextCopyWithImpl<SentenceText>(this as SentenceText, _$identity);

  /// Serializes this SentenceText to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SentenceText&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.styles, styles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(styles));

@override
String toString() {
  return 'SentenceText(text: $text, styles: $styles)';
}


}

/// @nodoc
abstract mixin class $SentenceTextCopyWith<$Res>  {
  factory $SentenceTextCopyWith(SentenceText value, $Res Function(SentenceText) _then) = _$SentenceTextCopyWithImpl;
@useResult
$Res call({
 String text, List<TextStyle> styles
});




}
/// @nodoc
class _$SentenceTextCopyWithImpl<$Res>
    implements $SentenceTextCopyWith<$Res> {
  _$SentenceTextCopyWithImpl(this._self, this._then);

  final SentenceText _self;
  final $Res Function(SentenceText) _then;

/// Create a copy of SentenceText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? styles = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,styles: null == styles ? _self.styles : styles // ignore: cast_nullable_to_non_nullable
as List<TextStyle>,
  ));
}

}


/// Adds pattern-matching-related methods to [SentenceText].
extension SentenceTextPatterns on SentenceText {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SentenceText value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SentenceText value)  $default,){
final _that = this;
switch (_that) {
case _SentenceText():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SentenceText value)?  $default,){
final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<TextStyle> styles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
return $default(_that.text,_that.styles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<TextStyle> styles)  $default,) {final _that = this;
switch (_that) {
case _SentenceText():
return $default(_that.text,_that.styles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<TextStyle> styles)?  $default,) {final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
return $default(_that.text,_that.styles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SentenceText implements SentenceText {
  const _SentenceText({required this.text, final  List<TextStyle> styles = const []}): _styles = styles;
  factory _SentenceText.fromJson(Map<String, dynamic> json) => _$SentenceTextFromJson(json);

/// Plain text with all markup removed
@override final  String text;
/// List of styles applied to the text
 final  List<TextStyle> _styles;
/// List of styles applied to the text
@override@JsonKey() List<TextStyle> get styles {
  if (_styles is EqualUnmodifiableListView) return _styles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_styles);
}


/// Create a copy of SentenceText
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SentenceTextCopyWith<_SentenceText> get copyWith => __$SentenceTextCopyWithImpl<_SentenceText>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SentenceTextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SentenceText&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._styles, _styles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_styles));

@override
String toString() {
  return 'SentenceText(text: $text, styles: $styles)';
}


}

/// @nodoc
abstract mixin class _$SentenceTextCopyWith<$Res> implements $SentenceTextCopyWith<$Res> {
  factory _$SentenceTextCopyWith(_SentenceText value, $Res Function(_SentenceText) _then) = __$SentenceTextCopyWithImpl;
@override @useResult
$Res call({
 String text, List<TextStyle> styles
});




}
/// @nodoc
class __$SentenceTextCopyWithImpl<$Res>
    implements _$SentenceTextCopyWith<$Res> {
  __$SentenceTextCopyWithImpl(this._self, this._then);

  final _SentenceText _self;
  final $Res Function(_SentenceText) _then;

/// Create a copy of SentenceText
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? styles = null,}) {
  return _then(_SentenceText(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,styles: null == styles ? _self._styles : styles // ignore: cast_nullable_to_non_nullable
as List<TextStyle>,
  ));
}


}

// dart format on
