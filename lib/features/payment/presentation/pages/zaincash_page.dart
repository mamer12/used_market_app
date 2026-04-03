import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/zaincash_cubit.dart';

// ── Matajir design tokens ────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1B4FD8);
const _kBg = Color(0xFFFAFAFA);
const _kSurface = Colors.white;
const _kTextPrimary = Color(0xFF1C1713);
const _kTextSecondary = Color(0xFF6B5E52);

/// ZainCash WebView payment screen with cubit-driven state management.
///
/// Accepts [orderId] and [paymentUrl] as route parameters.
/// Navigates to order tracking on success, shows retry on failure.
class ZainCashPage extends StatefulWidget {
  final String orderId;
  final String paymentUrl;

  const ZainCashPage({
    super.key,
    required this.orderId,
    required this.paymentUrl,
  });

  @override
  State<ZainCashPage> createState() => _ZainCashPageState();
}

class _ZainCashPageState extends State<ZainCashPage> {
  late final ZainCashCubit _cubit;
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _cubit = ZainCashCubit(
      orderId: widget.orderId,
      paymentUrl: widget.paymentUrl,
    );
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _cubit.onPageStarted(),
          onPageFinished: (_) => _cubit.onPageFinished(),
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            // Detect success redirect
            if (url.contains('success') &&
                (url.contains('zaincash') || url.contains('payment'))) {
              _cubit.onPaymentSuccess();
              return NavigationDecision.prevent;
            }
            // Detect failure redirect
            if (url.contains('fail') || url.contains('cancel')) {
              _cubit.onPaymentFailed();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            _cubit.onPaymentFailed(error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.zaincashCancelTitle,
          style: GoogleFonts.cairo(
            color: _kTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10n.zaincashCancelMessage,
          style: GoogleFonts.cairo(
            color: _kTextSecondary,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.zaincashContinuePayment,
              style: GoogleFonts.cairo(color: _kPrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.zaincashExit,
              style: GoogleFonts.cairo(color: _kTextSecondary),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<ZainCashCubit, ZainCashState>(
        listener: (context, state) {
          if (state.status == ZainCashStatus.success) {
            // Navigate to order tracking
            context.go('/orders/${widget.orderId}/tracking');
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: _kBg,
            appBar: AppBar(
              title: Text(
                l10n.zaincashPageTitle,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                  fontSize: 18.sp,
                ),
              ),
              centerTitle: true,
              backgroundColor: _kSurface,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              iconTheme: const IconThemeData(color: _kTextPrimary),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () async {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) {
                    context.pop();
                  }
                },
              ),
            ),
            body: BlocBuilder<ZainCashCubit, ZainCashState>(
              builder: (context, state) {
                if (state.status == ZainCashStatus.failed) {
                  return _buildErrorState(context, state, l10n);
                }

                return Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (state.status == ZainCashStatus.loading)
                      _buildLoadingOverlay(l10n),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(AppLocalizations l10n) {
    return Container(
      color: _kBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _kPrimary),
            SizedBox(height: 16.h),
            Text(
              l10n.zaincashLoading,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ZainCashState state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment_rounded,
                color: AppTheme.error,
                size: 40.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.zaincashFailedTitle,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.error ?? l10n.zaincashFailedMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: _kTextSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            // Retry button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  _cubit.retry();
                  _initWebView();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.zaincashRetry,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Go back button
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                l10n.zaincashGoBack,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _kTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
