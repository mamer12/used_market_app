import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/wallet_repository_impl.dart';

// ── States ────────────────────────────────────────────────────────────────────
sealed class WalletState {
  const WalletState();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final int balanceIqd;
  const WalletLoaded(this.balanceIqd);
}

class WalletError extends WalletState {
  const WalletError();
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
@injectable
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(const WalletLoading());

  Future<void> loadBalance() async {
    emit(const WalletLoading());
    try {
      final balance = await _repository.getBalance();
      emit(WalletLoaded(balance));
    } catch (_) {
      emit(const WalletError());
    }
  }
}
