import 'package:injectable/injectable.dart';

import '../../data/datasources/cart_remote_data_source.dart';
import '../bloc/cart_context.dart';

/// The isolated cart instance for the Balla (Bulk Goods) Mini-App.
///
/// Injected as a singleton (or scoped instance) and provided securely to the
/// Balla shell route. All additions via this cubit are tagged with
/// `app_context = balla`.
@injectable
class BallaCartCubit extends ScopedCartCubit {
  BallaCartCubit(CartRemoteDataSource remote)
    : super(CartAppContext.balla, remote);
}
