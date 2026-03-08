// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryState()';
}


}

/// @nodoc
class $CategoryStateCopyWith<$Res>  {
$CategoryStateCopyWith(CategoryState _, $Res Function(CategoryState) __);
}


/// Adds pattern-matching-related methods to [CategoryState].
extension CategoryStatePatterns on CategoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CategoryStateInitial value)?  initial,TResult Function( CategoryStateLoading value)?  loading,TResult Function( CategoryStateLoaded value)?  loaded,TResult Function( CategoryStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CategoryStateInitial() when initial != null:
return initial(_that);case CategoryStateLoading() when loading != null:
return loading(_that);case CategoryStateLoaded() when loaded != null:
return loaded(_that);case CategoryStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CategoryStateInitial value)  initial,required TResult Function( CategoryStateLoading value)  loading,required TResult Function( CategoryStateLoaded value)  loaded,required TResult Function( CategoryStateError value)  error,}){
final _that = this;
switch (_that) {
case CategoryStateInitial():
return initial(_that);case CategoryStateLoading():
return loading(_that);case CategoryStateLoaded():
return loaded(_that);case CategoryStateError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CategoryStateInitial value)?  initial,TResult? Function( CategoryStateLoading value)?  loading,TResult? Function( CategoryStateLoaded value)?  loaded,TResult? Function( CategoryStateError value)?  error,}){
final _that = this;
switch (_that) {
case CategoryStateInitial() when initial != null:
return initial(_that);case CategoryStateLoading() when loading != null:
return loading(_that);case CategoryStateLoaded() when loaded != null:
return loaded(_that);case CategoryStateError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<CategoryModel> categories,  String? currentParentId,  List<String?> parentIdStack)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CategoryStateInitial() when initial != null:
return initial();case CategoryStateLoading() when loading != null:
return loading();case CategoryStateLoaded() when loaded != null:
return loaded(_that.categories,_that.currentParentId,_that.parentIdStack);case CategoryStateError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<CategoryModel> categories,  String? currentParentId,  List<String?> parentIdStack)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case CategoryStateInitial():
return initial();case CategoryStateLoading():
return loading();case CategoryStateLoaded():
return loaded(_that.categories,_that.currentParentId,_that.parentIdStack);case CategoryStateError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<CategoryModel> categories,  String? currentParentId,  List<String?> parentIdStack)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case CategoryStateInitial() when initial != null:
return initial();case CategoryStateLoading() when loading != null:
return loading();case CategoryStateLoaded() when loaded != null:
return loaded(_that.categories,_that.currentParentId,_that.parentIdStack);case CategoryStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CategoryStateInitial implements CategoryState {
  const CategoryStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryState.initial()';
}


}




/// @nodoc


class CategoryStateLoading implements CategoryState {
  const CategoryStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryState.loading()';
}


}




/// @nodoc


class CategoryStateLoaded implements CategoryState {
  const CategoryStateLoaded({required final  List<CategoryModel> categories, this.currentParentId, final  List<String?> parentIdStack = const []}): _categories = categories,_parentIdStack = parentIdStack;
  

 final  List<CategoryModel> _categories;
 List<CategoryModel> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  String? currentParentId;
 final  List<String?> _parentIdStack;
@JsonKey() List<String?> get parentIdStack {
  if (_parentIdStack is EqualUnmodifiableListView) return _parentIdStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parentIdStack);
}


/// Create a copy of CategoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryStateLoadedCopyWith<CategoryStateLoaded> get copyWith => _$CategoryStateLoadedCopyWithImpl<CategoryStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStateLoaded&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.currentParentId, currentParentId) || other.currentParentId == currentParentId)&&const DeepCollectionEquality().equals(other._parentIdStack, _parentIdStack));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),currentParentId,const DeepCollectionEquality().hash(_parentIdStack));

@override
String toString() {
  return 'CategoryState.loaded(categories: $categories, currentParentId: $currentParentId, parentIdStack: $parentIdStack)';
}


}

/// @nodoc
abstract mixin class $CategoryStateLoadedCopyWith<$Res> implements $CategoryStateCopyWith<$Res> {
  factory $CategoryStateLoadedCopyWith(CategoryStateLoaded value, $Res Function(CategoryStateLoaded) _then) = _$CategoryStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<CategoryModel> categories, String? currentParentId, List<String?> parentIdStack
});




}
/// @nodoc
class _$CategoryStateLoadedCopyWithImpl<$Res>
    implements $CategoryStateLoadedCopyWith<$Res> {
  _$CategoryStateLoadedCopyWithImpl(this._self, this._then);

  final CategoryStateLoaded _self;
  final $Res Function(CategoryStateLoaded) _then;

/// Create a copy of CategoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? currentParentId = freezed,Object? parentIdStack = null,}) {
  return _then(CategoryStateLoaded(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryModel>,currentParentId: freezed == currentParentId ? _self.currentParentId : currentParentId // ignore: cast_nullable_to_non_nullable
as String?,parentIdStack: null == parentIdStack ? _self._parentIdStack : parentIdStack // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}


}

/// @nodoc


class CategoryStateError implements CategoryState {
  const CategoryStateError(this.message);
  

 final  String message;

/// Create a copy of CategoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryStateErrorCopyWith<CategoryStateError> get copyWith => _$CategoryStateErrorCopyWithImpl<CategoryStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CategoryState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $CategoryStateErrorCopyWith<$Res> implements $CategoryStateCopyWith<$Res> {
  factory $CategoryStateErrorCopyWith(CategoryStateError value, $Res Function(CategoryStateError) _then) = _$CategoryStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CategoryStateErrorCopyWithImpl<$Res>
    implements $CategoryStateErrorCopyWith<$Res> {
  _$CategoryStateErrorCopyWithImpl(this._self, this._then);

  final CategoryStateError _self;
  final $Res Function(CategoryStateError) _then;

/// Create a copy of CategoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CategoryStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
