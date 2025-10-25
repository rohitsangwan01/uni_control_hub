// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'input_handler.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaptureRequest {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CaptureRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CaptureRequest()';
  }
}

/// @nodoc
class $CaptureRequestCopyWith<$Res> {
  $CaptureRequestCopyWith(CaptureRequest _, $Res Function(CaptureRequest) __);
}

/// Adds pattern-matching-related methods to [CaptureRequest].
extension CaptureRequestPatterns on CaptureRequest {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CaptureRequest_Release value)? release,
    TResult Function(CaptureRequest_Create value)? create,
    TResult Function(CaptureRequest_Destroy value)? destroy,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release() when release != null:
        return release(_that);
      case CaptureRequest_Create() when create != null:
        return create(_that);
      case CaptureRequest_Destroy() when destroy != null:
        return destroy(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CaptureRequest_Release value) release,
    required TResult Function(CaptureRequest_Create value) create,
    required TResult Function(CaptureRequest_Destroy value) destroy,
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release():
        return release(_that);
      case CaptureRequest_Create():
        return create(_that);
      case CaptureRequest_Destroy():
        return destroy(_that);
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CaptureRequest_Release value)? release,
    TResult? Function(CaptureRequest_Create value)? create,
    TResult? Function(CaptureRequest_Destroy value)? destroy,
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release() when release != null:
        return release(_that);
      case CaptureRequest_Create() when create != null:
        return create(_that);
      case CaptureRequest_Destroy() when destroy != null:
        return destroy(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? release,
    TResult Function(Position field0)? create,
    TResult Function(Position field0)? destroy,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release() when release != null:
        return release();
      case CaptureRequest_Create() when create != null:
        return create(_that.field0);
      case CaptureRequest_Destroy() when destroy != null:
        return destroy(_that.field0);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() release,
    required TResult Function(Position field0) create,
    required TResult Function(Position field0) destroy,
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release():
        return release();
      case CaptureRequest_Create():
        return create(_that.field0);
      case CaptureRequest_Destroy():
        return destroy(_that.field0);
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? release,
    TResult? Function(Position field0)? create,
    TResult? Function(Position field0)? destroy,
  }) {
    final _that = this;
    switch (_that) {
      case CaptureRequest_Release() when release != null:
        return release();
      case CaptureRequest_Create() when create != null:
        return create(_that.field0);
      case CaptureRequest_Destroy() when destroy != null:
        return destroy(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class CaptureRequest_Release extends CaptureRequest {
  const CaptureRequest_Release() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CaptureRequest_Release);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CaptureRequest.release()';
  }
}

/// @nodoc

class CaptureRequest_Create extends CaptureRequest {
  const CaptureRequest_Create(this.field0) : super._();

  final Position field0;

  /// Create a copy of CaptureRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CaptureRequest_CreateCopyWith<CaptureRequest_Create> get copyWith =>
      _$CaptureRequest_CreateCopyWithImpl<CaptureRequest_Create>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CaptureRequest_Create &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'CaptureRequest.create(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $CaptureRequest_CreateCopyWith<$Res>
    implements $CaptureRequestCopyWith<$Res> {
  factory $CaptureRequest_CreateCopyWith(CaptureRequest_Create value,
          $Res Function(CaptureRequest_Create) _then) =
      _$CaptureRequest_CreateCopyWithImpl;
  @useResult
  $Res call({Position field0});
}

/// @nodoc
class _$CaptureRequest_CreateCopyWithImpl<$Res>
    implements $CaptureRequest_CreateCopyWith<$Res> {
  _$CaptureRequest_CreateCopyWithImpl(this._self, this._then);

  final CaptureRequest_Create _self;
  final $Res Function(CaptureRequest_Create) _then;

  /// Create a copy of CaptureRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(CaptureRequest_Create(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Position,
    ));
  }
}

/// @nodoc

class CaptureRequest_Destroy extends CaptureRequest {
  const CaptureRequest_Destroy(this.field0) : super._();

  final Position field0;

  /// Create a copy of CaptureRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CaptureRequest_DestroyCopyWith<CaptureRequest_Destroy> get copyWith =>
      _$CaptureRequest_DestroyCopyWithImpl<CaptureRequest_Destroy>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CaptureRequest_Destroy &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'CaptureRequest.destroy(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $CaptureRequest_DestroyCopyWith<$Res>
    implements $CaptureRequestCopyWith<$Res> {
  factory $CaptureRequest_DestroyCopyWith(CaptureRequest_Destroy value,
          $Res Function(CaptureRequest_Destroy) _then) =
      _$CaptureRequest_DestroyCopyWithImpl;
  @useResult
  $Res call({Position field0});
}

/// @nodoc
class _$CaptureRequest_DestroyCopyWithImpl<$Res>
    implements $CaptureRequest_DestroyCopyWith<$Res> {
  _$CaptureRequest_DestroyCopyWithImpl(this._self, this._then);

  final CaptureRequest_Destroy _self;
  final $Res Function(CaptureRequest_Destroy) _then;

  /// Create a copy of CaptureRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(CaptureRequest_Destroy(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Position,
    ));
  }
}

// dart format on
