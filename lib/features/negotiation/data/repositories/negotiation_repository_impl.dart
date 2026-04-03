import 'package:injectable/injectable.dart';

import '../../domain/repositories/negotiation_repository.dart';
import '../datasources/negotiation_remote_data_source.dart';
import '../models/negotiation_model.dart';

@LazySingleton(as: NegotiationRepository)
class NegotiationRepositoryImpl implements NegotiationRepository {
  final NegotiationRemoteDataSource _remoteDataSource;

  NegotiationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NegotiationModel>> getNegotiations() =>
      _remoteDataSource.getNegotiations();

  @override
  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  }) =>
      _remoteDataSource.submitOffer(
          productId: productId, offeredPrice: offeredPrice);

  @override
  Future<bool> acceptNegotiation(String id) =>
      _remoteDataSource.acceptNegotiation(id);

  @override
  Future<bool> counterNegotiation(String id, int counterPrice) =>
      _remoteDataSource.counterNegotiation(id, counterPrice);

  @override
  Future<bool> rejectNegotiation(String id) =>
      _remoteDataSource.rejectNegotiation(id);

  @override
  Future<Map<String, String>> initiatePayment(String negotiationId) =>
      _remoteDataSource.initiatePayment(negotiationId);
}
