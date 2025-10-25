// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientEvent {
  String get field0;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClientEventCopyWith<ClientEvent> get copyWith =>
      _$ClientEventCopyWithImpl<ClientEvent>(this as ClientEvent, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClientEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ClientEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ClientEventCopyWith<$Res> {
  factory $ClientEventCopyWith(
          ClientEvent value, $Res Function(ClientEvent) _then) =
      _$ClientEventCopyWithImpl;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$ClientEventCopyWithImpl<$Res> implements $ClientEventCopyWith<$Res> {
  _$ClientEventCopyWithImpl(this._self, this._then);

  final ClientEvent _self;
  final $Res Function(ClientEvent) _then;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_self.copyWith(
      field0: null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ClientEvent].
extension ClientEventPatterns on ClientEvent {
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
    TResult Function(ClientEvent_Added value)? added,
    TResult Function(ClientEvent_Removed value)? removed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added() when added != null:
        return added(_that);
      case ClientEvent_Removed() when removed != null:
        return removed(_that);
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
    required TResult Function(ClientEvent_Added value) added,
    required TResult Function(ClientEvent_Removed value) removed,
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added():
        return added(_that);
      case ClientEvent_Removed():
        return removed(_that);
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
    TResult? Function(ClientEvent_Added value)? added,
    TResult? Function(ClientEvent_Removed value)? removed,
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added() when added != null:
        return added(_that);
      case ClientEvent_Removed() when removed != null:
        return removed(_that);
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
    TResult Function(String field0)? added,
    TResult Function(String field0)? removed,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added() when added != null:
        return added(_that.field0);
      case ClientEvent_Removed() when removed != null:
        return removed(_that.field0);
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
    required TResult Function(String field0) added,
    required TResult Function(String field0) removed,
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added():
        return added(_that.field0);
      case ClientEvent_Removed():
        return removed(_that.field0);
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
    TResult? Function(String field0)? added,
    TResult? Function(String field0)? removed,
  }) {
    final _that = this;
    switch (_that) {
      case ClientEvent_Added() when added != null:
        return added(_that.field0);
      case ClientEvent_Removed() when removed != null:
        return removed(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class ClientEvent_Added extends ClientEvent {
  const ClientEvent_Added(this.field0) : super._();

  @override
  final String field0;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClientEvent_AddedCopyWith<ClientEvent_Added> get copyWith =>
      _$ClientEvent_AddedCopyWithImpl<ClientEvent_Added>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClientEvent_Added &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ClientEvent.added(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ClientEvent_AddedCopyWith<$Res>
    implements $ClientEventCopyWith<$Res> {
  factory $ClientEvent_AddedCopyWith(
          ClientEvent_Added value, $Res Function(ClientEvent_Added) _then) =
      _$ClientEvent_AddedCopyWithImpl;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$ClientEvent_AddedCopyWithImpl<$Res>
    implements $ClientEvent_AddedCopyWith<$Res> {
  _$ClientEvent_AddedCopyWithImpl(this._self, this._then);

  final ClientEvent_Added _self;
  final $Res Function(ClientEvent_Added) _then;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(ClientEvent_Added(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ClientEvent_Removed extends ClientEvent {
  const ClientEvent_Removed(this.field0) : super._();

  @override
  final String field0;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClientEvent_RemovedCopyWith<ClientEvent_Removed> get copyWith =>
      _$ClientEvent_RemovedCopyWithImpl<ClientEvent_Removed>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClientEvent_Removed &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'ClientEvent.removed(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $ClientEvent_RemovedCopyWith<$Res>
    implements $ClientEventCopyWith<$Res> {
  factory $ClientEvent_RemovedCopyWith(
          ClientEvent_Removed value, $Res Function(ClientEvent_Removed) _then) =
      _$ClientEvent_RemovedCopyWithImpl;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$ClientEvent_RemovedCopyWithImpl<$Res>
    implements $ClientEvent_RemovedCopyWith<$Res> {
  _$ClientEvent_RemovedCopyWithImpl(this._self, this._then);

  final ClientEvent_Removed _self;
  final $Res Function(ClientEvent_Removed) _then;

  /// Create a copy of ClientEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(ClientEvent_Removed(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
