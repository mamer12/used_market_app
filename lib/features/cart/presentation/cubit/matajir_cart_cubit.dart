import 'package:injectable/injectable.dart';

import '../../data/datasources/cart_remote_data_source.dart';
import '../bloc/cart_context.dart';

/// The isolated cart instance for the Matajir (Official Stores) Mini-App.
///
/// Injected as a singleton (or scoped instance) and provided securely to the
/// Matajir shell route. All additions via this cubit are tagged with
/// `app_context = matajir`.
@injectable
class MatajirCartCubit extends ScopedCartCubit {
  MatajirCartCubit(CartRemoteDataSource remote)
    : super(CartAppContext.matajir, remote);
}
