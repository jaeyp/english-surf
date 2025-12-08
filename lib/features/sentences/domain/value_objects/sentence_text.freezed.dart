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

/// Original text with markup syntax (e.g., "|**give and go**|")
 String get rawText;/// Plain text with all markup removed (e.g., "give and go")
 String get plainText;/// List of text ranges that should be rendered in bold
 List<TextRange> get boldRanges;/// List of text ranges that should be highlighted
 List<TextRange> get highlightRanges;
/// Create a copy of SentenceText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SentenceTextCopyWith<SentenceText> get copyWith => _$SentenceTextCopyWithImpl<SentenceText>(this as SentenceText, _$identity);

  /// Serializes this SentenceText to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SentenceText&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.plainText, plainText) || other.plainText == plainText)&&const DeepCollectionEquality().equals(other.boldRanges, boldRanges)&&const DeepCollectionEquality().equals(other.highlightRanges, highlightRanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawText,plainText,const DeepCollectionEquality().hash(boldRanges),const DeepCollectionEquality().hash(highlightRanges));

@override
String toString() {
  return 'SentenceText(rawText: $rawText, plainText: $plainText, boldRanges: $boldRanges, highlightRanges: $highlightRanges)';
}


}

/// @nodoc
abstract mixin class $SentenceTextCopyWith<$Res>  {
  factory $SentenceTextCopyWith(SentenceText value, $Res Function(SentenceText) _then) = _$SentenceTextCopyWithImpl;
@useResult
$Res call({
 String rawText, String plainText, List<TextRange> boldRanges, List<TextRange> highlightRanges
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
@pragma('vm:prefer-inline') @override $Res call({Object? rawText = null,Object? plainText = null,Object? boldRanges = null,Object? highlightRanges = null,}) {
  return _then(_self.copyWith(
rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,plainText: null == plainText ? _self.plainText : plainText // ignore: cast_nullable_to_non_nullable
as String,boldRanges: null == boldRanges ? _self.boldRanges : boldRanges // ignore: cast_nullable_to_non_nullable
as List<TextRange>,highlightRanges: null == highlightRanges ? _self.highlightRanges : highlightRanges // ignore: cast_nullable_to_non_nullable
as List<TextRange>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawText,  String plainText,  List<TextRange> boldRanges,  List<TextRange> highlightRanges)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
return $default(_that.rawText,_that.plainText,_that.boldRanges,_that.highlightRanges);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawText,  String plainText,  List<TextRange> boldRanges,  List<TextRange> highlightRanges)  $default,) {final _that = this;
switch (_that) {
case _SentenceText():
return $default(_that.rawText,_that.plainText,_that.boldRanges,_that.highlightRanges);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawText,  String plainText,  List<TextRange> boldRanges,  List<TextRange> highlightRanges)?  $default,) {final _that = this;
switch (_that) {
case _SentenceText() when $default != null:
return $default(_that.rawText,_that.plainText,_that.boldRanges,_that.highlightRanges);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SentenceText implements SentenceText {
  const _SentenceText({required this.rawText, required this.plainText, final  List<TextRange> boldRanges = const [], final  List<TextRange> highlightRanges = const []}): _boldRanges = boldRanges,_highlightRanges = highlightRanges;
  factory _SentenceText.fromJson(Map<String, dynamic> json) => _$SentenceTextFromJson(json);

/// Original text with markup syntax (e.g., "|**give and go**|")
@override final  String rawText;
/// Plain text with all markup removed (e.g., "give and go")
@override final  String plainText;
/// List of text ranges that should be rendered in bold
 final  List<TextRange> _boldRanges;
/// List of text ranges that should be rendered in bold
@override@JsonKey() List<TextRange> get boldRanges {
  if (_boldRanges is EqualUnmodifiableListView) return _boldRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_boldRanges);
}

/// List of text ranges that should be highlighted
 final  List<TextRange> _highlightRanges;
/// List of text ranges that should be highlighted
@override@JsonKey() List<TextRange> get highlightRanges {
  if (_highlightRanges is EqualUnmodifiableListView) return _highlightRanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_highlightRanges);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SentenceText&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.plainText, plainText) || other.plainText == plainText)&&const DeepCollectionEquality().equals(other._boldRanges, _boldRanges)&&const DeepCollectionEquality().equals(other._highlightRanges, _highlightRanges));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawText,plainText,const DeepCollectionEquality().hash(_boldRanges),const DeepCollectionEquality().hash(_highlightRanges));

@override
String toString() {
  return 'SentenceText(rawText: $rawText, plainText: $plainText, boldRanges: $boldRanges, highlightRanges: $highlightRanges)';
}


}

/// @nodoc
abstract mixin class _$SentenceTextCopyWith<$Res> implements $SentenceTextCopyWith<$Res> {
  factory _$SentenceTextCopyWith(_SentenceText value, $Res Function(_SentenceText) _then) = __$SentenceTextCopyWithImpl;
@override @useResult
$Res call({
 String rawText, String plainText, List<TextRange> boldRanges, List<TextRange> highlightRanges
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
@override @pragma('vm:prefer-inline') $Res call({Object? rawText = null,Object? plainText = null,Object? boldRanges = null,Object? highlightRanges = null,}) {
  return _then(_SentenceText(
rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,plainText: null == plainText ? _self.plainText : plainText // ignore: cast_nullable_to_non_nullable
as String,boldRanges: null == boldRanges ? _self._boldRanges : boldRanges // ignore: cast_nullable_to_non_nullable
as List<TextRange>,highlightRanges: null == highlightRanges ? _self._highlightRanges : highlightRanges // ignore: cast_nullable_to_non_nullable
as List<TextRange>,
  ));
}


}

// dart format on
