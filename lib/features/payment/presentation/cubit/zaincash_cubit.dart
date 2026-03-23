import 'package:flutter_bloc/flutter_bloc.dart';

// ── States ────────────────────────────────────────────────────────────────────

enum ZainCashStatus { loading, redirecting, success, failed }

class ZainCashState {
  final ZainCashStatus status;
  final String? error;

  const ZainCashState({
    this.status = ZainCashStatus.loading,
    this.error,
  });

  ZainCashState copyWith({
    ZainCashStatus? status,
    String? error,
  }) {
    return ZainCashState(
      status: status ?? this.status,
      error: error,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ZainCashCubit extends Cubit<ZainCashState> {
  final String orderId;
  final String paymentUrl;

  ZainCashCubit({
    required this.orderId,
    required this.paymentUrl,
  }) : super(const ZainCashState());

  /// Called when the WebView starts loading the payment URL.
  void onPageStarted() {
    emit(state.copyWith(status: ZainCashStatus.redirecting));
  }

  /// Called when the WebView finishes loading a page.
  void onPageFinished() {
    // Stay in redirecting until we detect success or failure
    if (state.status == ZainCashStatus.loading) {
      emit(state.copyWith(status: ZainCashStatus.redirecting));
    }
  }

  /// Called when we detect the success callback URL.
  void onPaymentSuccess() {
    emit(state.copyWith(status: ZainCashStatus.success));
  }

  /// Called when we detect the failure callback URL or a timeout.
  void onPaymentFailed([String? error]) {
    emit(state.copyWith(
      status: ZainCashStatus.failed,
      error: error,
    ));
  }

  /// Resets to loading state for retry.
  void retry() {
    emit(const ZainCashState(status: ZainCashStatus.loading));
  }
}
