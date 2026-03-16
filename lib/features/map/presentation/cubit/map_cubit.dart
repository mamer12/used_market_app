import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../data/models/shop_nearby_model.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class MapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<ShopNearbyModel> shops;
  final double lat;
  final double lng;

  MapLoaded(this.shops, {required this.lat, required this.lng});

  @override
  List<Object?> get props => [shops, lat, lng];
}

class MapError extends MapState {
  final String message;
  MapError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────────────────────

class MapCubit extends Cubit<MapState> {
  final String baseUrl;
  final String token;

  MapCubit({required this.baseUrl, required this.token}) : super(MapInitial());

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
      };

  /// Determine current location and load nearby shops.
  Future<void> loadNearbyShops({int radiusMeters = 5000}) async {
    emit(MapLoading());
    try {
      // Check & request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(MapError('يرجى السماح بالوصول إلى الموقع'));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        emit(MapError('الموقع مرفوض بشكل دائم. فعّله من الإعدادات.'));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      await fetchShops(
        lat: position.latitude,
        lng: position.longitude,
        radiusMeters: radiusMeters,
      );
    } catch (e) {
      if (isClosed) return;
      emit(MapError('تعذّر تحديد موقعك: $e'));
    }
  }

  /// Fetch shops for given coordinates.
  Future<void> fetchShops({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/v1/shops?lat=$lat&lng=$lng&radius=$radiusMeters',
      );
      final res = await http.get(uri, headers: _headers);

      if (isClosed) return;

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final data = (body['data'] as List?) ?? [];
        final shops =
            data.map((e) => ShopNearbyModel.fromJson(e as Map<String, dynamic>)).toList();
        emit(MapLoaded(shops, lat: lat, lng: lng));
      } else {
        emit(MapError('فشل تحميل المحلات'));
      }
    } catch (e) {
      if (!isClosed) emit(MapError(e.toString()));
    }
  }
}
