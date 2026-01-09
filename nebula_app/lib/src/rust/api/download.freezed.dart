// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BilibiliLoginStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BilibiliLoginStatus()';
}


}

/// @nodoc
class $BilibiliLoginStatusCopyWith<$Res>  {
$BilibiliLoginStatusCopyWith(BilibiliLoginStatus _, $Res Function(BilibiliLoginStatus) __);
}


/// Adds pattern-matching-related methods to [BilibiliLoginStatus].
extension BilibiliLoginStatusPatterns on BilibiliLoginStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BilibiliLoginStatus_WaitingScan value)?  waitingScan,TResult Function( BilibiliLoginStatus_WaitingConfirm value)?  waitingConfirm,TResult Function( BilibiliLoginStatus_Success value)?  success,TResult Function( BilibiliLoginStatus_Expired value)?  expired,TResult Function( BilibiliLoginStatus_Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan() when waitingScan != null:
return waitingScan(_that);case BilibiliLoginStatus_WaitingConfirm() when waitingConfirm != null:
return waitingConfirm(_that);case BilibiliLoginStatus_Success() when success != null:
return success(_that);case BilibiliLoginStatus_Expired() when expired != null:
return expired(_that);case BilibiliLoginStatus_Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BilibiliLoginStatus_WaitingScan value)  waitingScan,required TResult Function( BilibiliLoginStatus_WaitingConfirm value)  waitingConfirm,required TResult Function( BilibiliLoginStatus_Success value)  success,required TResult Function( BilibiliLoginStatus_Expired value)  expired,required TResult Function( BilibiliLoginStatus_Failed value)  failed,}){
final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan():
return waitingScan(_that);case BilibiliLoginStatus_WaitingConfirm():
return waitingConfirm(_that);case BilibiliLoginStatus_Success():
return success(_that);case BilibiliLoginStatus_Expired():
return expired(_that);case BilibiliLoginStatus_Failed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BilibiliLoginStatus_WaitingScan value)?  waitingScan,TResult? Function( BilibiliLoginStatus_WaitingConfirm value)?  waitingConfirm,TResult? Function( BilibiliLoginStatus_Success value)?  success,TResult? Function( BilibiliLoginStatus_Expired value)?  expired,TResult? Function( BilibiliLoginStatus_Failed value)?  failed,}){
final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan() when waitingScan != null:
return waitingScan(_that);case BilibiliLoginStatus_WaitingConfirm() when waitingConfirm != null:
return waitingConfirm(_that);case BilibiliLoginStatus_Success() when success != null:
return success(_that);case BilibiliLoginStatus_Expired() when expired != null:
return expired(_that);case BilibiliLoginStatus_Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  waitingScan,TResult Function()?  waitingConfirm,TResult Function()?  success,TResult Function()?  expired,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan() when waitingScan != null:
return waitingScan();case BilibiliLoginStatus_WaitingConfirm() when waitingConfirm != null:
return waitingConfirm();case BilibiliLoginStatus_Success() when success != null:
return success();case BilibiliLoginStatus_Expired() when expired != null:
return expired();case BilibiliLoginStatus_Failed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  waitingScan,required TResult Function()  waitingConfirm,required TResult Function()  success,required TResult Function()  expired,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan():
return waitingScan();case BilibiliLoginStatus_WaitingConfirm():
return waitingConfirm();case BilibiliLoginStatus_Success():
return success();case BilibiliLoginStatus_Expired():
return expired();case BilibiliLoginStatus_Failed():
return failed(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  waitingScan,TResult? Function()?  waitingConfirm,TResult? Function()?  success,TResult? Function()?  expired,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case BilibiliLoginStatus_WaitingScan() when waitingScan != null:
return waitingScan();case BilibiliLoginStatus_WaitingConfirm() when waitingConfirm != null:
return waitingConfirm();case BilibiliLoginStatus_Success() when success != null:
return success();case BilibiliLoginStatus_Expired() when expired != null:
return expired();case BilibiliLoginStatus_Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class BilibiliLoginStatus_WaitingScan extends BilibiliLoginStatus {
  const BilibiliLoginStatus_WaitingScan(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus_WaitingScan);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BilibiliLoginStatus.waitingScan()';
}


}




/// @nodoc


class BilibiliLoginStatus_WaitingConfirm extends BilibiliLoginStatus {
  const BilibiliLoginStatus_WaitingConfirm(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus_WaitingConfirm);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BilibiliLoginStatus.waitingConfirm()';
}


}




/// @nodoc


class BilibiliLoginStatus_Success extends BilibiliLoginStatus {
  const BilibiliLoginStatus_Success(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus_Success);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BilibiliLoginStatus.success()';
}


}




/// @nodoc


class BilibiliLoginStatus_Expired extends BilibiliLoginStatus {
  const BilibiliLoginStatus_Expired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus_Expired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BilibiliLoginStatus.expired()';
}


}




/// @nodoc


class BilibiliLoginStatus_Failed extends BilibiliLoginStatus {
  const BilibiliLoginStatus_Failed({required this.error}): super._();
  

 final  String error;

/// Create a copy of BilibiliLoginStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BilibiliLoginStatus_FailedCopyWith<BilibiliLoginStatus_Failed> get copyWith => _$BilibiliLoginStatus_FailedCopyWithImpl<BilibiliLoginStatus_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliLoginStatus_Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'BilibiliLoginStatus.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $BilibiliLoginStatus_FailedCopyWith<$Res> implements $BilibiliLoginStatusCopyWith<$Res> {
  factory $BilibiliLoginStatus_FailedCopyWith(BilibiliLoginStatus_Failed value, $Res Function(BilibiliLoginStatus_Failed) _then) = _$BilibiliLoginStatus_FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$BilibiliLoginStatus_FailedCopyWithImpl<$Res>
    implements $BilibiliLoginStatus_FailedCopyWith<$Res> {
  _$BilibiliLoginStatus_FailedCopyWithImpl(this._self, this._then);

  final BilibiliLoginStatus_Failed _self;
  final $Res Function(BilibiliLoginStatus_Failed) _then;

/// Create a copy of BilibiliLoginStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(BilibiliLoginStatus_Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BilibiliQrCode {

 String get url; String get qrcodeKey;
/// Create a copy of BilibiliQrCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BilibiliQrCodeCopyWith<BilibiliQrCode> get copyWith => _$BilibiliQrCodeCopyWithImpl<BilibiliQrCode>(this as BilibiliQrCode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilibiliQrCode&&(identical(other.url, url) || other.url == url)&&(identical(other.qrcodeKey, qrcodeKey) || other.qrcodeKey == qrcodeKey));
}


@override
int get hashCode => Object.hash(runtimeType,url,qrcodeKey);

@override
String toString() {
  return 'BilibiliQrCode(url: $url, qrcodeKey: $qrcodeKey)';
}


}

/// @nodoc
abstract mixin class $BilibiliQrCodeCopyWith<$Res>  {
  factory $BilibiliQrCodeCopyWith(BilibiliQrCode value, $Res Function(BilibiliQrCode) _then) = _$BilibiliQrCodeCopyWithImpl;
@useResult
$Res call({
 String url, String qrcodeKey
});




}
/// @nodoc
class _$BilibiliQrCodeCopyWithImpl<$Res>
    implements $BilibiliQrCodeCopyWith<$Res> {
  _$BilibiliQrCodeCopyWithImpl(this._self, this._then);

  final BilibiliQrCode _self;
  final $Res Function(BilibiliQrCode) _then;

/// Create a copy of BilibiliQrCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? qrcodeKey = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,qrcodeKey: null == qrcodeKey ? _self.qrcodeKey : qrcodeKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BilibiliQrCode].
extension BilibiliQrCodePatterns on BilibiliQrCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BilibiliQrCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BilibiliQrCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BilibiliQrCode value)  $default,){
final _that = this;
switch (_that) {
case _BilibiliQrCode():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BilibiliQrCode value)?  $default,){
final _that = this;
switch (_that) {
case _BilibiliQrCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String qrcodeKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BilibiliQrCode() when $default != null:
return $default(_that.url,_that.qrcodeKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String qrcodeKey)  $default,) {final _that = this;
switch (_that) {
case _BilibiliQrCode():
return $default(_that.url,_that.qrcodeKey);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String qrcodeKey)?  $default,) {final _that = this;
switch (_that) {
case _BilibiliQrCode() when $default != null:
return $default(_that.url,_that.qrcodeKey);case _:
  return null;

}
}

}

/// @nodoc


class _BilibiliQrCode implements BilibiliQrCode {
  const _BilibiliQrCode({required this.url, required this.qrcodeKey});
  

@override final  String url;
@override final  String qrcodeKey;

/// Create a copy of BilibiliQrCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BilibiliQrCodeCopyWith<_BilibiliQrCode> get copyWith => __$BilibiliQrCodeCopyWithImpl<_BilibiliQrCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BilibiliQrCode&&(identical(other.url, url) || other.url == url)&&(identical(other.qrcodeKey, qrcodeKey) || other.qrcodeKey == qrcodeKey));
}


@override
int get hashCode => Object.hash(runtimeType,url,qrcodeKey);

@override
String toString() {
  return 'BilibiliQrCode(url: $url, qrcodeKey: $qrcodeKey)';
}


}

/// @nodoc
abstract mixin class _$BilibiliQrCodeCopyWith<$Res> implements $BilibiliQrCodeCopyWith<$Res> {
  factory _$BilibiliQrCodeCopyWith(_BilibiliQrCode value, $Res Function(_BilibiliQrCode) _then) = __$BilibiliQrCodeCopyWithImpl;
@override @useResult
$Res call({
 String url, String qrcodeKey
});




}
/// @nodoc
class __$BilibiliQrCodeCopyWithImpl<$Res>
    implements _$BilibiliQrCodeCopyWith<$Res> {
  __$BilibiliQrCodeCopyWithImpl(this._self, this._then);

  final _BilibiliQrCode _self;
  final $Res Function(_BilibiliQrCode) _then;

/// Create a copy of BilibiliQrCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? qrcodeKey = null,}) {
  return _then(_BilibiliQrCode(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,qrcodeKey: null == qrcodeKey ? _self.qrcodeKey : qrcodeKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$NebulaEvent {

 String get taskId;
/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEventCopyWith<NebulaEvent> get copyWith => _$NebulaEventCopyWithImpl<NebulaEvent>(this as NebulaEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEventCopyWith<$Res>  {
  factory $NebulaEventCopyWith(NebulaEvent value, $Res Function(NebulaEvent) _then) = _$NebulaEventCopyWithImpl;
@useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEventCopyWithImpl<$Res>
    implements $NebulaEventCopyWith<$Res> {
  _$NebulaEventCopyWithImpl(this._self, this._then);

  final NebulaEvent _self;
  final $Res Function(NebulaEvent) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [NebulaEvent].
extension NebulaEventPatterns on NebulaEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NebulaEvent_TaskAdded value)?  taskAdded,TResult Function( NebulaEvent_TaskStarted value)?  taskStarted,TResult Function( NebulaEvent_ProgressUpdated value)?  progressUpdated,TResult Function( NebulaEvent_TaskCompleted value)?  taskCompleted,TResult Function( NebulaEvent_TaskFailed value)?  taskFailed,TResult Function( NebulaEvent_TaskPaused value)?  taskPaused,TResult Function( NebulaEvent_TaskResumed value)?  taskResumed,TResult Function( NebulaEvent_TaskRemoved value)?  taskRemoved,TResult Function( NebulaEvent_MetadataReceived value)?  metadataReceived,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded() when taskAdded != null:
return taskAdded(_that);case NebulaEvent_TaskStarted() when taskStarted != null:
return taskStarted(_that);case NebulaEvent_ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that);case NebulaEvent_TaskCompleted() when taskCompleted != null:
return taskCompleted(_that);case NebulaEvent_TaskFailed() when taskFailed != null:
return taskFailed(_that);case NebulaEvent_TaskPaused() when taskPaused != null:
return taskPaused(_that);case NebulaEvent_TaskResumed() when taskResumed != null:
return taskResumed(_that);case NebulaEvent_TaskRemoved() when taskRemoved != null:
return taskRemoved(_that);case NebulaEvent_MetadataReceived() when metadataReceived != null:
return metadataReceived(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NebulaEvent_TaskAdded value)  taskAdded,required TResult Function( NebulaEvent_TaskStarted value)  taskStarted,required TResult Function( NebulaEvent_ProgressUpdated value)  progressUpdated,required TResult Function( NebulaEvent_TaskCompleted value)  taskCompleted,required TResult Function( NebulaEvent_TaskFailed value)  taskFailed,required TResult Function( NebulaEvent_TaskPaused value)  taskPaused,required TResult Function( NebulaEvent_TaskResumed value)  taskResumed,required TResult Function( NebulaEvent_TaskRemoved value)  taskRemoved,required TResult Function( NebulaEvent_MetadataReceived value)  metadataReceived,}){
final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded():
return taskAdded(_that);case NebulaEvent_TaskStarted():
return taskStarted(_that);case NebulaEvent_ProgressUpdated():
return progressUpdated(_that);case NebulaEvent_TaskCompleted():
return taskCompleted(_that);case NebulaEvent_TaskFailed():
return taskFailed(_that);case NebulaEvent_TaskPaused():
return taskPaused(_that);case NebulaEvent_TaskResumed():
return taskResumed(_that);case NebulaEvent_TaskRemoved():
return taskRemoved(_that);case NebulaEvent_MetadataReceived():
return metadataReceived(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NebulaEvent_TaskAdded value)?  taskAdded,TResult? Function( NebulaEvent_TaskStarted value)?  taskStarted,TResult? Function( NebulaEvent_ProgressUpdated value)?  progressUpdated,TResult? Function( NebulaEvent_TaskCompleted value)?  taskCompleted,TResult? Function( NebulaEvent_TaskFailed value)?  taskFailed,TResult? Function( NebulaEvent_TaskPaused value)?  taskPaused,TResult? Function( NebulaEvent_TaskResumed value)?  taskResumed,TResult? Function( NebulaEvent_TaskRemoved value)?  taskRemoved,TResult? Function( NebulaEvent_MetadataReceived value)?  metadataReceived,}){
final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded() when taskAdded != null:
return taskAdded(_that);case NebulaEvent_TaskStarted() when taskStarted != null:
return taskStarted(_that);case NebulaEvent_ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that);case NebulaEvent_TaskCompleted() when taskCompleted != null:
return taskCompleted(_that);case NebulaEvent_TaskFailed() when taskFailed != null:
return taskFailed(_that);case NebulaEvent_TaskPaused() when taskPaused != null:
return taskPaused(_that);case NebulaEvent_TaskResumed() when taskResumed != null:
return taskResumed(_that);case NebulaEvent_TaskRemoved() when taskRemoved != null:
return taskRemoved(_that);case NebulaEvent_MetadataReceived() when metadataReceived != null:
return metadataReceived(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String taskId,  String name)?  taskAdded,TResult Function( String taskId)?  taskStarted,TResult Function( String taskId,  ProgressEvent progress)?  progressUpdated,TResult Function( String taskId)?  taskCompleted,TResult Function( String taskId,  String error)?  taskFailed,TResult Function( String taskId)?  taskPaused,TResult Function( String taskId)?  taskResumed,TResult Function( String taskId)?  taskRemoved,TResult Function( String taskId,  String name,  BigInt totalSize,  BigInt fileCount)?  metadataReceived,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded() when taskAdded != null:
return taskAdded(_that.taskId,_that.name);case NebulaEvent_TaskStarted() when taskStarted != null:
return taskStarted(_that.taskId);case NebulaEvent_ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that.taskId,_that.progress);case NebulaEvent_TaskCompleted() when taskCompleted != null:
return taskCompleted(_that.taskId);case NebulaEvent_TaskFailed() when taskFailed != null:
return taskFailed(_that.taskId,_that.error);case NebulaEvent_TaskPaused() when taskPaused != null:
return taskPaused(_that.taskId);case NebulaEvent_TaskResumed() when taskResumed != null:
return taskResumed(_that.taskId);case NebulaEvent_TaskRemoved() when taskRemoved != null:
return taskRemoved(_that.taskId);case NebulaEvent_MetadataReceived() when metadataReceived != null:
return metadataReceived(_that.taskId,_that.name,_that.totalSize,_that.fileCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String taskId,  String name)  taskAdded,required TResult Function( String taskId)  taskStarted,required TResult Function( String taskId,  ProgressEvent progress)  progressUpdated,required TResult Function( String taskId)  taskCompleted,required TResult Function( String taskId,  String error)  taskFailed,required TResult Function( String taskId)  taskPaused,required TResult Function( String taskId)  taskResumed,required TResult Function( String taskId)  taskRemoved,required TResult Function( String taskId,  String name,  BigInt totalSize,  BigInt fileCount)  metadataReceived,}) {final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded():
return taskAdded(_that.taskId,_that.name);case NebulaEvent_TaskStarted():
return taskStarted(_that.taskId);case NebulaEvent_ProgressUpdated():
return progressUpdated(_that.taskId,_that.progress);case NebulaEvent_TaskCompleted():
return taskCompleted(_that.taskId);case NebulaEvent_TaskFailed():
return taskFailed(_that.taskId,_that.error);case NebulaEvent_TaskPaused():
return taskPaused(_that.taskId);case NebulaEvent_TaskResumed():
return taskResumed(_that.taskId);case NebulaEvent_TaskRemoved():
return taskRemoved(_that.taskId);case NebulaEvent_MetadataReceived():
return metadataReceived(_that.taskId,_that.name,_that.totalSize,_that.fileCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String taskId,  String name)?  taskAdded,TResult? Function( String taskId)?  taskStarted,TResult? Function( String taskId,  ProgressEvent progress)?  progressUpdated,TResult? Function( String taskId)?  taskCompleted,TResult? Function( String taskId,  String error)?  taskFailed,TResult? Function( String taskId)?  taskPaused,TResult? Function( String taskId)?  taskResumed,TResult? Function( String taskId)?  taskRemoved,TResult? Function( String taskId,  String name,  BigInt totalSize,  BigInt fileCount)?  metadataReceived,}) {final _that = this;
switch (_that) {
case NebulaEvent_TaskAdded() when taskAdded != null:
return taskAdded(_that.taskId,_that.name);case NebulaEvent_TaskStarted() when taskStarted != null:
return taskStarted(_that.taskId);case NebulaEvent_ProgressUpdated() when progressUpdated != null:
return progressUpdated(_that.taskId,_that.progress);case NebulaEvent_TaskCompleted() when taskCompleted != null:
return taskCompleted(_that.taskId);case NebulaEvent_TaskFailed() when taskFailed != null:
return taskFailed(_that.taskId,_that.error);case NebulaEvent_TaskPaused() when taskPaused != null:
return taskPaused(_that.taskId);case NebulaEvent_TaskResumed() when taskResumed != null:
return taskResumed(_that.taskId);case NebulaEvent_TaskRemoved() when taskRemoved != null:
return taskRemoved(_that.taskId);case NebulaEvent_MetadataReceived() when metadataReceived != null:
return metadataReceived(_that.taskId,_that.name,_that.totalSize,_that.fileCount);case _:
  return null;

}
}

}

/// @nodoc


class NebulaEvent_TaskAdded extends NebulaEvent {
  const NebulaEvent_TaskAdded({required this.taskId, required this.name}): super._();
  

@override final  String taskId;
 final  String name;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskAddedCopyWith<NebulaEvent_TaskAdded> get copyWith => _$NebulaEvent_TaskAddedCopyWithImpl<NebulaEvent_TaskAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskAdded&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,name);

@override
String toString() {
  return 'NebulaEvent.taskAdded(taskId: $taskId, name: $name)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskAddedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskAddedCopyWith(NebulaEvent_TaskAdded value, $Res Function(NebulaEvent_TaskAdded) _then) = _$NebulaEvent_TaskAddedCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String name
});




}
/// @nodoc
class _$NebulaEvent_TaskAddedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskAddedCopyWith<$Res> {
  _$NebulaEvent_TaskAddedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskAdded _self;
  final $Res Function(NebulaEvent_TaskAdded) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? name = null,}) {
  return _then(NebulaEvent_TaskAdded(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_TaskStarted extends NebulaEvent {
  const NebulaEvent_TaskStarted({required this.taskId}): super._();
  

@override final  String taskId;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskStartedCopyWith<NebulaEvent_TaskStarted> get copyWith => _$NebulaEvent_TaskStartedCopyWithImpl<NebulaEvent_TaskStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskStarted&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent.taskStarted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskStartedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskStartedCopyWith(NebulaEvent_TaskStarted value, $Res Function(NebulaEvent_TaskStarted) _then) = _$NebulaEvent_TaskStartedCopyWithImpl;
@override @useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEvent_TaskStartedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskStartedCopyWith<$Res> {
  _$NebulaEvent_TaskStartedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskStarted _self;
  final $Res Function(NebulaEvent_TaskStarted) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(NebulaEvent_TaskStarted(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_ProgressUpdated extends NebulaEvent {
  const NebulaEvent_ProgressUpdated({required this.taskId, required this.progress}): super._();
  

@override final  String taskId;
 final  ProgressEvent progress;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_ProgressUpdatedCopyWith<NebulaEvent_ProgressUpdated> get copyWith => _$NebulaEvent_ProgressUpdatedCopyWithImpl<NebulaEvent_ProgressUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_ProgressUpdated&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,progress);

@override
String toString() {
  return 'NebulaEvent.progressUpdated(taskId: $taskId, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_ProgressUpdatedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_ProgressUpdatedCopyWith(NebulaEvent_ProgressUpdated value, $Res Function(NebulaEvent_ProgressUpdated) _then) = _$NebulaEvent_ProgressUpdatedCopyWithImpl;
@override @useResult
$Res call({
 String taskId, ProgressEvent progress
});


$ProgressEventCopyWith<$Res> get progress;

}
/// @nodoc
class _$NebulaEvent_ProgressUpdatedCopyWithImpl<$Res>
    implements $NebulaEvent_ProgressUpdatedCopyWith<$Res> {
  _$NebulaEvent_ProgressUpdatedCopyWithImpl(this._self, this._then);

  final NebulaEvent_ProgressUpdated _self;
  final $Res Function(NebulaEvent_ProgressUpdated) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? progress = null,}) {
  return _then(NebulaEvent_ProgressUpdated(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as ProgressEvent,
  ));
}

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProgressEventCopyWith<$Res> get progress {
  
  return $ProgressEventCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

/// @nodoc


class NebulaEvent_TaskCompleted extends NebulaEvent {
  const NebulaEvent_TaskCompleted({required this.taskId}): super._();
  

@override final  String taskId;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskCompletedCopyWith<NebulaEvent_TaskCompleted> get copyWith => _$NebulaEvent_TaskCompletedCopyWithImpl<NebulaEvent_TaskCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskCompleted&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent.taskCompleted(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskCompletedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskCompletedCopyWith(NebulaEvent_TaskCompleted value, $Res Function(NebulaEvent_TaskCompleted) _then) = _$NebulaEvent_TaskCompletedCopyWithImpl;
@override @useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEvent_TaskCompletedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskCompletedCopyWith<$Res> {
  _$NebulaEvent_TaskCompletedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskCompleted _self;
  final $Res Function(NebulaEvent_TaskCompleted) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(NebulaEvent_TaskCompleted(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_TaskFailed extends NebulaEvent {
  const NebulaEvent_TaskFailed({required this.taskId, required this.error}): super._();
  

@override final  String taskId;
 final  String error;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskFailedCopyWith<NebulaEvent_TaskFailed> get copyWith => _$NebulaEvent_TaskFailedCopyWithImpl<NebulaEvent_TaskFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskFailed&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,error);

@override
String toString() {
  return 'NebulaEvent.taskFailed(taskId: $taskId, error: $error)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskFailedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskFailedCopyWith(NebulaEvent_TaskFailed value, $Res Function(NebulaEvent_TaskFailed) _then) = _$NebulaEvent_TaskFailedCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String error
});




}
/// @nodoc
class _$NebulaEvent_TaskFailedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskFailedCopyWith<$Res> {
  _$NebulaEvent_TaskFailedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskFailed _self;
  final $Res Function(NebulaEvent_TaskFailed) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? error = null,}) {
  return _then(NebulaEvent_TaskFailed(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_TaskPaused extends NebulaEvent {
  const NebulaEvent_TaskPaused({required this.taskId}): super._();
  

@override final  String taskId;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskPausedCopyWith<NebulaEvent_TaskPaused> get copyWith => _$NebulaEvent_TaskPausedCopyWithImpl<NebulaEvent_TaskPaused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskPaused&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent.taskPaused(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskPausedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskPausedCopyWith(NebulaEvent_TaskPaused value, $Res Function(NebulaEvent_TaskPaused) _then) = _$NebulaEvent_TaskPausedCopyWithImpl;
@override @useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEvent_TaskPausedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskPausedCopyWith<$Res> {
  _$NebulaEvent_TaskPausedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskPaused _self;
  final $Res Function(NebulaEvent_TaskPaused) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(NebulaEvent_TaskPaused(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_TaskResumed extends NebulaEvent {
  const NebulaEvent_TaskResumed({required this.taskId}): super._();
  

@override final  String taskId;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskResumedCopyWith<NebulaEvent_TaskResumed> get copyWith => _$NebulaEvent_TaskResumedCopyWithImpl<NebulaEvent_TaskResumed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskResumed&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent.taskResumed(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskResumedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskResumedCopyWith(NebulaEvent_TaskResumed value, $Res Function(NebulaEvent_TaskResumed) _then) = _$NebulaEvent_TaskResumedCopyWithImpl;
@override @useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEvent_TaskResumedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskResumedCopyWith<$Res> {
  _$NebulaEvent_TaskResumedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskResumed _self;
  final $Res Function(NebulaEvent_TaskResumed) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(NebulaEvent_TaskResumed(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_TaskRemoved extends NebulaEvent {
  const NebulaEvent_TaskRemoved({required this.taskId}): super._();
  

@override final  String taskId;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_TaskRemovedCopyWith<NebulaEvent_TaskRemoved> get copyWith => _$NebulaEvent_TaskRemovedCopyWithImpl<NebulaEvent_TaskRemoved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_TaskRemoved&&(identical(other.taskId, taskId) || other.taskId == taskId));
}


@override
int get hashCode => Object.hash(runtimeType,taskId);

@override
String toString() {
  return 'NebulaEvent.taskRemoved(taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_TaskRemovedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_TaskRemovedCopyWith(NebulaEvent_TaskRemoved value, $Res Function(NebulaEvent_TaskRemoved) _then) = _$NebulaEvent_TaskRemovedCopyWithImpl;
@override @useResult
$Res call({
 String taskId
});




}
/// @nodoc
class _$NebulaEvent_TaskRemovedCopyWithImpl<$Res>
    implements $NebulaEvent_TaskRemovedCopyWith<$Res> {
  _$NebulaEvent_TaskRemovedCopyWithImpl(this._self, this._then);

  final NebulaEvent_TaskRemoved _self;
  final $Res Function(NebulaEvent_TaskRemoved) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,}) {
  return _then(NebulaEvent_TaskRemoved(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NebulaEvent_MetadataReceived extends NebulaEvent {
  const NebulaEvent_MetadataReceived({required this.taskId, required this.name, required this.totalSize, required this.fileCount}): super._();
  

@override final  String taskId;
 final  String name;
 final  BigInt totalSize;
 final  BigInt fileCount;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NebulaEvent_MetadataReceivedCopyWith<NebulaEvent_MetadataReceived> get copyWith => _$NebulaEvent_MetadataReceivedCopyWithImpl<NebulaEvent_MetadataReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NebulaEvent_MetadataReceived&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.name, name) || other.name == name)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.fileCount, fileCount) || other.fileCount == fileCount));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,name,totalSize,fileCount);

@override
String toString() {
  return 'NebulaEvent.metadataReceived(taskId: $taskId, name: $name, totalSize: $totalSize, fileCount: $fileCount)';
}


}

/// @nodoc
abstract mixin class $NebulaEvent_MetadataReceivedCopyWith<$Res> implements $NebulaEventCopyWith<$Res> {
  factory $NebulaEvent_MetadataReceivedCopyWith(NebulaEvent_MetadataReceived value, $Res Function(NebulaEvent_MetadataReceived) _then) = _$NebulaEvent_MetadataReceivedCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String name, BigInt totalSize, BigInt fileCount
});




}
/// @nodoc
class _$NebulaEvent_MetadataReceivedCopyWithImpl<$Res>
    implements $NebulaEvent_MetadataReceivedCopyWith<$Res> {
  _$NebulaEvent_MetadataReceivedCopyWithImpl(this._self, this._then);

  final NebulaEvent_MetadataReceived _self;
  final $Res Function(NebulaEvent_MetadataReceived) _then;

/// Create a copy of NebulaEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? name = null,Object? totalSize = null,Object? fileCount = null,}) {
  return _then(NebulaEvent_MetadataReceived(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,fileCount: null == fileCount ? _self.fileCount : fileCount // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc
mixin _$ProgressEvent {

 String get taskId; BigInt get totalSize; BigInt get downloadedSize; BigInt get downloadSpeed; double get percentage; BigInt? get etaSecs;
/// Create a copy of ProgressEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressEventCopyWith<ProgressEvent> get copyWith => _$ProgressEventCopyWithImpl<ProgressEvent>(this as ProgressEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.downloadedSize, downloadedSize) || other.downloadedSize == downloadedSize)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.etaSecs, etaSecs) || other.etaSecs == etaSecs));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,totalSize,downloadedSize,downloadSpeed,percentage,etaSecs);

@override
String toString() {
  return 'ProgressEvent(taskId: $taskId, totalSize: $totalSize, downloadedSize: $downloadedSize, downloadSpeed: $downloadSpeed, percentage: $percentage, etaSecs: $etaSecs)';
}


}

/// @nodoc
abstract mixin class $ProgressEventCopyWith<$Res>  {
  factory $ProgressEventCopyWith(ProgressEvent value, $Res Function(ProgressEvent) _then) = _$ProgressEventCopyWithImpl;
@useResult
$Res call({
 String taskId, BigInt totalSize, BigInt downloadedSize, BigInt downloadSpeed, double percentage, BigInt? etaSecs
});




}
/// @nodoc
class _$ProgressEventCopyWithImpl<$Res>
    implements $ProgressEventCopyWith<$Res> {
  _$ProgressEventCopyWithImpl(this._self, this._then);

  final ProgressEvent _self;
  final $Res Function(ProgressEvent) _then;

/// Create a copy of ProgressEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? totalSize = null,Object? downloadedSize = null,Object? downloadSpeed = null,Object? percentage = null,Object? etaSecs = freezed,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,downloadedSize: null == downloadedSize ? _self.downloadedSize : downloadedSize // ignore: cast_nullable_to_non_nullable
as BigInt,downloadSpeed: null == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as BigInt,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,etaSecs: freezed == etaSecs ? _self.etaSecs : etaSecs // ignore: cast_nullable_to_non_nullable
as BigInt?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressEvent].
extension ProgressEventPatterns on ProgressEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProgressEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressEvent value)  $default,){
final _that = this;
switch (_that) {
case _ProgressEvent():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ProgressEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  BigInt totalSize,  BigInt downloadedSize,  BigInt downloadSpeed,  double percentage,  BigInt? etaSecs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProgressEvent() when $default != null:
return $default(_that.taskId,_that.totalSize,_that.downloadedSize,_that.downloadSpeed,_that.percentage,_that.etaSecs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  BigInt totalSize,  BigInt downloadedSize,  BigInt downloadSpeed,  double percentage,  BigInt? etaSecs)  $default,) {final _that = this;
switch (_that) {
case _ProgressEvent():
return $default(_that.taskId,_that.totalSize,_that.downloadedSize,_that.downloadSpeed,_that.percentage,_that.etaSecs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  BigInt totalSize,  BigInt downloadedSize,  BigInt downloadSpeed,  double percentage,  BigInt? etaSecs)?  $default,) {final _that = this;
switch (_that) {
case _ProgressEvent() when $default != null:
return $default(_that.taskId,_that.totalSize,_that.downloadedSize,_that.downloadSpeed,_that.percentage,_that.etaSecs);case _:
  return null;

}
}

}

/// @nodoc


class _ProgressEvent implements ProgressEvent {
  const _ProgressEvent({required this.taskId, required this.totalSize, required this.downloadedSize, required this.downloadSpeed, required this.percentage, this.etaSecs});
  

@override final  String taskId;
@override final  BigInt totalSize;
@override final  BigInt downloadedSize;
@override final  BigInt downloadSpeed;
@override final  double percentage;
@override final  BigInt? etaSecs;

/// Create a copy of ProgressEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressEventCopyWith<_ProgressEvent> get copyWith => __$ProgressEventCopyWithImpl<_ProgressEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressEvent&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.totalSize, totalSize) || other.totalSize == totalSize)&&(identical(other.downloadedSize, downloadedSize) || other.downloadedSize == downloadedSize)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.percentage, percentage) || other.percentage == percentage)&&(identical(other.etaSecs, etaSecs) || other.etaSecs == etaSecs));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,totalSize,downloadedSize,downloadSpeed,percentage,etaSecs);

@override
String toString() {
  return 'ProgressEvent(taskId: $taskId, totalSize: $totalSize, downloadedSize: $downloadedSize, downloadSpeed: $downloadSpeed, percentage: $percentage, etaSecs: $etaSecs)';
}


}

/// @nodoc
abstract mixin class _$ProgressEventCopyWith<$Res> implements $ProgressEventCopyWith<$Res> {
  factory _$ProgressEventCopyWith(_ProgressEvent value, $Res Function(_ProgressEvent) _then) = __$ProgressEventCopyWithImpl;
@override @useResult
$Res call({
 String taskId, BigInt totalSize, BigInt downloadedSize, BigInt downloadSpeed, double percentage, BigInt? etaSecs
});




}
/// @nodoc
class __$ProgressEventCopyWithImpl<$Res>
    implements _$ProgressEventCopyWith<$Res> {
  __$ProgressEventCopyWithImpl(this._self, this._then);

  final _ProgressEvent _self;
  final $Res Function(_ProgressEvent) _then;

/// Create a copy of ProgressEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? totalSize = null,Object? downloadedSize = null,Object? downloadSpeed = null,Object? percentage = null,Object? etaSecs = freezed,}) {
  return _then(_ProgressEvent(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,totalSize: null == totalSize ? _self.totalSize : totalSize // ignore: cast_nullable_to_non_nullable
as BigInt,downloadedSize: null == downloadedSize ? _self.downloadedSize : downloadedSize // ignore: cast_nullable_to_non_nullable
as BigInt,downloadSpeed: null == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as BigInt,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,etaSecs: freezed == etaSecs ? _self.etaSecs : etaSecs // ignore: cast_nullable_to_non_nullable
as BigInt?,
  ));
}


}

/// @nodoc
mixin _$VideoFormat {

 String get formatId; String get ext; String? get resolution; BigInt? get filesize; String? get formatNote; double? get fps; String? get vcodec; String? get acodec;
/// Create a copy of VideoFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoFormatCopyWith<VideoFormat> get copyWith => _$VideoFormatCopyWithImpl<VideoFormat>(this as VideoFormat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoFormat&&(identical(other.formatId, formatId) || other.formatId == formatId)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.filesize, filesize) || other.filesize == filesize)&&(identical(other.formatNote, formatNote) || other.formatNote == formatNote)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.vcodec, vcodec) || other.vcodec == vcodec)&&(identical(other.acodec, acodec) || other.acodec == acodec));
}


@override
int get hashCode => Object.hash(runtimeType,formatId,ext,resolution,filesize,formatNote,fps,vcodec,acodec);

@override
String toString() {
  return 'VideoFormat(formatId: $formatId, ext: $ext, resolution: $resolution, filesize: $filesize, formatNote: $formatNote, fps: $fps, vcodec: $vcodec, acodec: $acodec)';
}


}

/// @nodoc
abstract mixin class $VideoFormatCopyWith<$Res>  {
  factory $VideoFormatCopyWith(VideoFormat value, $Res Function(VideoFormat) _then) = _$VideoFormatCopyWithImpl;
@useResult
$Res call({
 String formatId, String ext, String? resolution, BigInt? filesize, String? formatNote, double? fps, String? vcodec, String? acodec
});




}
/// @nodoc
class _$VideoFormatCopyWithImpl<$Res>
    implements $VideoFormatCopyWith<$Res> {
  _$VideoFormatCopyWithImpl(this._self, this._then);

  final VideoFormat _self;
  final $Res Function(VideoFormat) _then;

/// Create a copy of VideoFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formatId = null,Object? ext = null,Object? resolution = freezed,Object? filesize = freezed,Object? formatNote = freezed,Object? fps = freezed,Object? vcodec = freezed,Object? acodec = freezed,}) {
  return _then(_self.copyWith(
formatId: null == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,filesize: freezed == filesize ? _self.filesize : filesize // ignore: cast_nullable_to_non_nullable
as BigInt?,formatNote: freezed == formatNote ? _self.formatNote : formatNote // ignore: cast_nullable_to_non_nullable
as String?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double?,vcodec: freezed == vcodec ? _self.vcodec : vcodec // ignore: cast_nullable_to_non_nullable
as String?,acodec: freezed == acodec ? _self.acodec : acodec // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoFormat].
extension VideoFormatPatterns on VideoFormat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoFormat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoFormat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoFormat value)  $default,){
final _that = this;
switch (_that) {
case _VideoFormat():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoFormat value)?  $default,){
final _that = this;
switch (_that) {
case _VideoFormat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String formatId,  String ext,  String? resolution,  BigInt? filesize,  String? formatNote,  double? fps,  String? vcodec,  String? acodec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoFormat() when $default != null:
return $default(_that.formatId,_that.ext,_that.resolution,_that.filesize,_that.formatNote,_that.fps,_that.vcodec,_that.acodec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String formatId,  String ext,  String? resolution,  BigInt? filesize,  String? formatNote,  double? fps,  String? vcodec,  String? acodec)  $default,) {final _that = this;
switch (_that) {
case _VideoFormat():
return $default(_that.formatId,_that.ext,_that.resolution,_that.filesize,_that.formatNote,_that.fps,_that.vcodec,_that.acodec);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String formatId,  String ext,  String? resolution,  BigInt? filesize,  String? formatNote,  double? fps,  String? vcodec,  String? acodec)?  $default,) {final _that = this;
switch (_that) {
case _VideoFormat() when $default != null:
return $default(_that.formatId,_that.ext,_that.resolution,_that.filesize,_that.formatNote,_that.fps,_that.vcodec,_that.acodec);case _:
  return null;

}
}

}

/// @nodoc


class _VideoFormat implements VideoFormat {
  const _VideoFormat({required this.formatId, required this.ext, this.resolution, this.filesize, this.formatNote, this.fps, this.vcodec, this.acodec});
  

@override final  String formatId;
@override final  String ext;
@override final  String? resolution;
@override final  BigInt? filesize;
@override final  String? formatNote;
@override final  double? fps;
@override final  String? vcodec;
@override final  String? acodec;

/// Create a copy of VideoFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoFormatCopyWith<_VideoFormat> get copyWith => __$VideoFormatCopyWithImpl<_VideoFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoFormat&&(identical(other.formatId, formatId) || other.formatId == formatId)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.filesize, filesize) || other.filesize == filesize)&&(identical(other.formatNote, formatNote) || other.formatNote == formatNote)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.vcodec, vcodec) || other.vcodec == vcodec)&&(identical(other.acodec, acodec) || other.acodec == acodec));
}


@override
int get hashCode => Object.hash(runtimeType,formatId,ext,resolution,filesize,formatNote,fps,vcodec,acodec);

@override
String toString() {
  return 'VideoFormat(formatId: $formatId, ext: $ext, resolution: $resolution, filesize: $filesize, formatNote: $formatNote, fps: $fps, vcodec: $vcodec, acodec: $acodec)';
}


}

/// @nodoc
abstract mixin class _$VideoFormatCopyWith<$Res> implements $VideoFormatCopyWith<$Res> {
  factory _$VideoFormatCopyWith(_VideoFormat value, $Res Function(_VideoFormat) _then) = __$VideoFormatCopyWithImpl;
@override @useResult
$Res call({
 String formatId, String ext, String? resolution, BigInt? filesize, String? formatNote, double? fps, String? vcodec, String? acodec
});




}
/// @nodoc
class __$VideoFormatCopyWithImpl<$Res>
    implements _$VideoFormatCopyWith<$Res> {
  __$VideoFormatCopyWithImpl(this._self, this._then);

  final _VideoFormat _self;
  final $Res Function(_VideoFormat) _then;

/// Create a copy of VideoFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formatId = null,Object? ext = null,Object? resolution = freezed,Object? filesize = freezed,Object? formatNote = freezed,Object? fps = freezed,Object? vcodec = freezed,Object? acodec = freezed,}) {
  return _then(_VideoFormat(
formatId: null == formatId ? _self.formatId : formatId // ignore: cast_nullable_to_non_nullable
as String,ext: null == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,filesize: freezed == filesize ? _self.filesize : filesize // ignore: cast_nullable_to_non_nullable
as BigInt?,formatNote: freezed == formatNote ? _self.formatNote : formatNote // ignore: cast_nullable_to_non_nullable
as String?,fps: freezed == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double?,vcodec: freezed == vcodec ? _self.vcodec : vcodec // ignore: cast_nullable_to_non_nullable
as String?,acodec: freezed == acodec ? _self.acodec : acodec // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VideoInfo {

 String get id; String get title; String? get thumbnail; BigInt? get duration; String? get uploader; List<VideoFormat> get formats;
/// Create a copy of VideoInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoInfoCopyWith<VideoInfo> get copyWith => _$VideoInfoCopyWithImpl<VideoInfo>(this as VideoInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.uploader, uploader) || other.uploader == uploader)&&const DeepCollectionEquality().equals(other.formats, formats));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,thumbnail,duration,uploader,const DeepCollectionEquality().hash(formats));

@override
String toString() {
  return 'VideoInfo(id: $id, title: $title, thumbnail: $thumbnail, duration: $duration, uploader: $uploader, formats: $formats)';
}


}

/// @nodoc
abstract mixin class $VideoInfoCopyWith<$Res>  {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) _then) = _$VideoInfoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? thumbnail, BigInt? duration, String? uploader, List<VideoFormat> formats
});




}
/// @nodoc
class _$VideoInfoCopyWithImpl<$Res>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._self, this._then);

  final VideoInfo _self;
  final $Res Function(VideoInfo) _then;

/// Create a copy of VideoInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? thumbnail = freezed,Object? duration = freezed,Object? uploader = freezed,Object? formats = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as BigInt?,uploader: freezed == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as String?,formats: null == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as List<VideoFormat>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoInfo].
extension VideoInfoPatterns on VideoInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoInfo value)  $default,){
final _that = this;
switch (_that) {
case _VideoInfo():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VideoInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? thumbnail,  BigInt? duration,  String? uploader,  List<VideoFormat> formats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoInfo() when $default != null:
return $default(_that.id,_that.title,_that.thumbnail,_that.duration,_that.uploader,_that.formats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? thumbnail,  BigInt? duration,  String? uploader,  List<VideoFormat> formats)  $default,) {final _that = this;
switch (_that) {
case _VideoInfo():
return $default(_that.id,_that.title,_that.thumbnail,_that.duration,_that.uploader,_that.formats);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? thumbnail,  BigInt? duration,  String? uploader,  List<VideoFormat> formats)?  $default,) {final _that = this;
switch (_that) {
case _VideoInfo() when $default != null:
return $default(_that.id,_that.title,_that.thumbnail,_that.duration,_that.uploader,_that.formats);case _:
  return null;

}
}

}

/// @nodoc


class _VideoInfo implements VideoInfo {
  const _VideoInfo({required this.id, required this.title, this.thumbnail, this.duration, this.uploader, required final  List<VideoFormat> formats}): _formats = formats;
  

@override final  String id;
@override final  String title;
@override final  String? thumbnail;
@override final  BigInt? duration;
@override final  String? uploader;
 final  List<VideoFormat> _formats;
@override List<VideoFormat> get formats {
  if (_formats is EqualUnmodifiableListView) return _formats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_formats);
}


/// Create a copy of VideoInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoInfoCopyWith<_VideoInfo> get copyWith => __$VideoInfoCopyWithImpl<_VideoInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.uploader, uploader) || other.uploader == uploader)&&const DeepCollectionEquality().equals(other._formats, _formats));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,thumbnail,duration,uploader,const DeepCollectionEquality().hash(_formats));

@override
String toString() {
  return 'VideoInfo(id: $id, title: $title, thumbnail: $thumbnail, duration: $duration, uploader: $uploader, formats: $formats)';
}


}

/// @nodoc
abstract mixin class _$VideoInfoCopyWith<$Res> implements $VideoInfoCopyWith<$Res> {
  factory _$VideoInfoCopyWith(_VideoInfo value, $Res Function(_VideoInfo) _then) = __$VideoInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? thumbnail, BigInt? duration, String? uploader, List<VideoFormat> formats
});




}
/// @nodoc
class __$VideoInfoCopyWithImpl<$Res>
    implements _$VideoInfoCopyWith<$Res> {
  __$VideoInfoCopyWithImpl(this._self, this._then);

  final _VideoInfo _self;
  final $Res Function(_VideoInfo) _then;

/// Create a copy of VideoInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? thumbnail = freezed,Object? duration = freezed,Object? uploader = freezed,Object? formats = null,}) {
  return _then(_VideoInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as BigInt?,uploader: freezed == uploader ? _self.uploader : uploader // ignore: cast_nullable_to_non_nullable
as String?,formats: null == formats ? _self._formats : formats // ignore: cast_nullable_to_non_nullable
as List<VideoFormat>,
  ));
}


}

// dart format on
