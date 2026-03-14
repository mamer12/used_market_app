import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// ZainCash WebView payment screen.
///
/// Opens [paymentUrl] in a WebView. Pops with `true` when the redirect URL
/// contains both "zaincash" and "success". Shows a confirm dialog when the
/// user tries to go back mid-payment.
class ZainCashPaymentPage extends StatefulWidget {
  final String orderId;
  final String paymentUrl;

  const ZainCashPaymentPage({
    super.key,
    required this.orderId,
    required this.paymentUrl,
  });

  @override
  State<ZainCashPaymentPage> createState() => _ZainCashPaymentPageState();
}

class _ZainCashPaymentPageState extends State<ZainCashPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();
            if (url.contains('zaincash') && url.contains('success')) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<bool> _onWillPop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'إلغاء الدفع؟',
          style: GoogleFonts.cairo(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'هل تريد الخروج من صفحة الدفع؟ لن يتم تأكيد طلبك.',
          style: GoogleFonts.cairo(
            color: AppTheme.textSecondary,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'متابعة الدفع',
              style: GoogleFonts.cairo(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'خروج',
              style: GoogleFonts.cairo(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop(false);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            'الدفع عبر ZainCash',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textPrimary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
