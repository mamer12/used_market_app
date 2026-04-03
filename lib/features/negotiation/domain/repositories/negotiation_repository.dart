import '../../data/models/negotiation_model.dart';

abstract class NegotiationRepository {
  Future<List<NegotiationModel>> getNegotiations();
  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  });
  Future<bool> acceptNegotiation(String id);
  Future<bool> counterNegotiation(String id, int counterPrice);
  Future<bool> rejectNegotiation(String id);

  /// Initiates payment for a negotiated order and returns the payment URL.
  /// Returns a map containing orderId and paymentUrl.
  Future<Map<String, String>> initiatePayment(String negotiationId);
}
