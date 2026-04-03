import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_context.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/order_models.dart';
import '../../data/models/shop_models.dart';
import '../bloc/checkout_cubit.dart';

// ── Matajir design tokens ──────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAFA);
const _kSurface = Colors.white;
const _kBorder = Color(0xFFEDE6DC);
const _kPrimary = Color(0xFF1B4FD8);
const _kGreen = Color(0xFF00B37E);
const _kEscrow = Color(0xFF059669);
const _kTextPrimary = Color(0xFF1C1713);
const _kTextSecondary = Color(0xFF6B5E52);

class CheckoutPage extends StatefulWidget {
  final List<ProductModel> products;
  final CartCubit? cartCubit;

  const CheckoutPage({super.key, required this.products, this.cartCubit});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // ── Address fields ────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // ── Local state ───────────────────────────────────────────────────────
  String _selectedPayment = 'ZAIN_CASH';
  String _fulfillmentType = 'delivery';
  final _promoCtrl = TextEditingController();
  bool _showEscrowSuccess = false;

  // ── Cart quantities (product.id → qty) ───────────────────────────────
  late final Map<String, int> _quantities;

  @override
  void initState() {
    super.initState();
    _quantities = {for (final p in widget.products) p.id: 1};
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _phoneCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  // ── Computed totals ───────────────────────────────────────────────────

  double get _subtotal => widget.products.fold(
        0,
        (sum, p) => sum + p.price * (_quantities[p.id] ?? 1),
      );

  double get _deliveryFee => _fulfillmentType == 'delivery' ? 5000 : 0;

  double get _escrowFee => _subtotal * 0.02;

  double get _total => _subtotal + _deliveryFee + _escrowFee;

  // ── Order submission ──────────────────────────────────────────────────

  void _processPayment(BuildContext context) {
    if (_fulfillmentType == 'delivery' && !_formKey.currentState!.validate()) {
      return;
    }

    final shippingAddress = ShippingAddress(
      city: _cityCtrl.text,
      district: _districtCtrl.text,
      street: _streetCtrl.text,
      building: _buildingCtrl.text,
      phone: _phoneCtrl.text,
    );

    final targetCubit = widget.cartCubit ?? context.read<CartCubit>();
    final appContext = targetCubit is ScopedCartCubit
        ? targetCubit.appContext.apiValue
        : null;

    // Map UI payment selection to API payment_method value
    final paymentMethod = _selectedPayment == 'COD' ? 'cod' : 'zaincash';

    final request = BuyProductRequest(
      productId: widget.products.first.id,
      quantity: _quantities[widget.products.first.id] ?? 1,
      shippingAddress: shippingAddress,
      fulfillmentType: _fulfillmentType,
      appContext: appContext,
      paymentMethod: paymentMethod,
    );

    unawaited(
      context.read<CheckoutCubit>().placeOrder(
            request,
            paymentMethod: paymentMethod,
          ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartCount = widget.products.length;

    return BlocProvider(
      create: (_) => getIt<CheckoutCubit>(),
      child: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state.status == CheckoutProcessStatus.success) {
            final targetCubit =
                widget.cartCubit ?? context.read<CartCubit>();
            targetCubit.clearCart();

            if (state.paymentMethod == 'cod') {
              // COD: show escrow success badge, then navigate to tracking
              setState(() => _showEscrowSuccess = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  context.go('/orders/${state.orderId}/tracking');
                }
              });
            } else {
              // ZainCash: navigate to payment WebView
              if (state.paymentUrl != null &&
                  state.paymentUrl!.isNotEmpty) {
                context.push(
                  '/payment/zaincash',
                  extra: {
                    'orderId': state.orderId,
                    'paymentUrl': state.paymentUrl,
                  },
                );
              } else {
                // Fallback: go directly to order tracking
                context.go('/orders/${state.orderId}/tracking');
              }
            }
          } else if (state.status == CheckoutProcessStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error ?? l10n.checkoutErrorGeneral,
                  style: GoogleFonts.cairo(),
                ),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            final isLoading =
                state.status == CheckoutProcessStatus.loading;

            if (widget.products.isEmpty) {
              return Scaffold(
                backgroundColor: _kBg,
                appBar: _buildAppBar(cartCount, l10n),
                body: _buildEmptyCart(context, l10n),
              );
            }

            return Scaffold(
              backgroundColor: _kBg,
              appBar: _buildAppBar(cartCount, l10n),
              body: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: ListView(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                        children: [
                          _buildCartItemsList(l10n),
                          SizedBox(height: 16.h),
                          _buildPromoSection(l10n),
                          SizedBox(height: 16.h),
                          _buildOrderSummaryCard(l10n),
                          SizedBox(height: 16.h),
                          _buildEscrowBanner(l10n),
                          SizedBox(height: 16.h),
                          _buildDeliverySection(l10n),
                          SizedBox(height: 16.h),
                          _buildPaymentSection(l10n),
                        ],
                      ),
                    ),
                    // Escrow success overlay
                    if (_showEscrowSuccess) _buildEscrowSuccessOverlay(l10n),
                  ],
                ),
              ),
              bottomNavigationBar:
                  _buildStickyCheckoutButton(context, isLoading, l10n),
            );
          },
        ),
      ),
    );
  }

  // ── Escrow success overlay ──────────────────────────────────────────────

  Widget _buildEscrowSuccessOverlay(AppLocalizations l10n) {
    return Container(
      color: _kBg.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _kEscrow.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_rounded, color: _kEscrow, size: 40.sp),
            ),
            SizedBox(height: 24.h),
            Container(
              margin: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _kEscrow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: _kEscrow.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: _kEscrow, size: 20.sp),
                  SizedBox(width: 10.w),
                  Flexible(
                    child: Text(
                      l10n.checkoutEscrowSuccessBadge,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _kEscrow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.checkoutOrderSuccess,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: _kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────

  AppBar _buildAppBar(int cartCount, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _kTextPrimary, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        '${l10n.checkoutCartTitle} ($cartCount)',
        style: GoogleFonts.cairo(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: _kTextPrimary,
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────

  Widget _buildEmptyCart(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 72.sp,
            color: _kTextSecondary.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.cartEmpty,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.cartEmptySub,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: _kTextSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                l10n.checkoutBrowseProducts,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart items list ───────────────────────────────────────────────────

  Widget _buildCartItemsList(AppLocalizations l10n) {
    return Column(
      children: widget.products.map((product) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _CartItemRow(
            product: product,
            quantity: _quantities[product.id] ?? 1,
            onQuantityChanged: (qty) {
              setState(() => _quantities[product.id] = qty);
            },
            onDelete: () {
              setState(() {
                _quantities.remove(product.id);
                widget.products.remove(product);
              });
            },
          ),
        );
      }).toList(),
    );
  }

  // ── Promo code ────────────────────────────────────────────────────────

  Widget _buildPromoSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoCtrl,
              style: GoogleFonts.cairo(fontSize: 14.sp, color: _kTextPrimary),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: l10n.checkoutPromoHint,
                hintStyle: GoogleFonts.cairo(
                    fontSize: 14.sp, color: _kTextSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              if (_promoCtrl.text.isNotEmpty) {
                setState(() {});
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                l10n.checkoutPromoApply,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order summary card ────────────────────────────────────────────────

  Widget _buildOrderSummaryCard(AppLocalizations l10n) {
    final deliveryText = _deliveryFee == 0
        ? l10n.checkoutFreeDelivery
        : IqdFormatter.format(_deliveryFee);

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.checkoutOrderSummary,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          _SummaryRow(
            label: l10n.checkoutSubtotal,
            value: IqdFormatter.format(_subtotal),
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            label: l10n.checkoutDeliveryFee,
            value: deliveryText,
          ),
          SizedBox(height: 10.h),
          _SummaryRow(
            label: l10n.checkoutEscrowFee,
            value: IqdFormatter.format(_escrowFee),
            valueColor: _kGreen,
          ),
          SizedBox(height: 14.h),
          const Divider(color: _kBorder, height: 1),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.checkoutTotal,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              Text(
                IqdFormatter.format(_total),
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: _kPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Escrow notice ─────────────────────────────────────────────────────

  Widget _buildEscrowBanner(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: _kEscrow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _kEscrow.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: _kEscrow, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.checkoutEscrowNotice,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: _kEscrow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delivery section ──────────────────────────────────────────────────

  Widget _buildDeliverySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _FulfillmentOption(
                value: 'delivery',
                label: l10n.checkoutDeliveryHome,
                icon: Icons.local_shipping_outlined,
                selected: _fulfillmentType == 'delivery',
                onTap: () => setState(() => _fulfillmentType = 'delivery'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _FulfillmentOption(
                value: 'pickup',
                label: l10n.checkoutPickupStore,
                icon: Icons.storefront_outlined,
                selected: _fulfillmentType == 'pickup',
                onTap: () => setState(() => _fulfillmentType = 'pickup'),
              ),
            ),
          ],
        ),
        if (_fulfillmentType == 'delivery') ...[
          SizedBox(height: 14.h),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _kBorder),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: _kPrimary, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.checkoutDeliveryAddress,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityCtrl,
                        label: l10n.checkoutCity,
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _districtCtrl,
                        label: l10n.checkoutDistrict,
                        icon: Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _streetCtrl,
                        label: l10n.checkoutStreet,
                        icon: Icons.add_road_outlined,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTextField(
                        controller: _buildingCtrl,
                        label: l10n.checkoutBuilding,
                        icon: Icons.apartment_outlined,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _phoneCtrl,
                  label: l10n.checkoutPhone,
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _kPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _kPrimary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    color: _kPrimary, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    l10n.checkoutPickupEscrowNote,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Payment section ───────────────────────────────────────────────────

  Widget _buildPaymentSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.checkoutPaymentMethod,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildPaymentOption(
          'ZAIN_CASH',
          'ZainCash',
          Icons.account_balance_wallet_rounded,
          const Color(0xFFD81B60),
        ),
        SizedBox(height: 10.h),
        _buildPaymentOption(
          'COD',
          l10n.checkoutCOD,
          Icons.local_shipping_outlined,
          _kGreen,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? _kPrimary : _kBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _kPrimary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      validator: (v) =>
          (v == null || v.isEmpty) ? l10n.checkoutFieldRequired : null,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(fontSize: 14.sp, color: _kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.cairo(fontSize: 13.sp, color: _kTextSecondary),
        prefixIcon: Icon(icon, color: _kTextSecondary, size: 18.sp),
        filled: true,
        fillColor: _kBg,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _kPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
      ),
    );
  }

  // ── Sticky checkout button ────────────────────────────────────────────

  Widget _buildStickyCheckoutButton(
    BuildContext context,
    bool isLoading,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      top: false,
      child: Container(
        color: _kSurface,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: GestureDetector(
          onTap: isLoading ? null : () => _processPayment(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 52.h,
            decoration: BoxDecoration(
              color: isLoading
                  ? _kPrimary.withValues(alpha: 0.5)
                  : _kPrimary,
              borderRadius: BorderRadius.circular(999.r),
              boxShadow: isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: _kPrimary.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.checkoutBtn,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Cart Item Row ─────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const _CartItemRow({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsetsDirectional.only(start: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: AppTheme.error, size: 24.sp),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppTheme.shimmerBase,
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppTheme.shimmerBase,
                          child: Icon(Icons.image_outlined,
                              color: _kTextSecondary, size: 24.sp),
                        ),
                      )
                    : Container(
                        color: AppTheme.shimmerBase,
                        child: Icon(Icons.image_outlined,
                            color: _kTextSecondary, size: 24.sp),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    product.salesUnit == 'piece' ? 'قطعة' : product.salesUnit,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: _kTextSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: _kGreen, size: 11.sp),
                      SizedBox(width: 3.w),
                      Text(
                        'مضمون',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: _kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        IqdFormatter.format(product.price),
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                      _QuantityStepper(
                        quantity: quantity,
                        onDecrement: () {
                          if (quantity > 1) onQuantityChanged(quantity - 1);
                        },
                        onIncrement: () => onQuantityChanged(quantity + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded,
                  color: _kTextSecondary, size: 20.sp),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quantity Stepper ──────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              '$quantity',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
          ),
          _StepperBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: const BoxDecoration(
          color: _kSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.sp, color: _kPrimary),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: _kTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Fulfillment Option ────────────────────────────────────────────────────────

class _FulfillmentOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FulfillmentOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? _kPrimary : _kBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: selected ? _kPrimary : _kTextSecondary,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _kTextPrimary : _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
