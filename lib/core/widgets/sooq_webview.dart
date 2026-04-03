import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../di/injection.dart';
import '../services/web_session_service.dart';
import '../theme/app_theme.dart';
import '../network/web_constants.dart';

/// Pull-to-refresh indicator color
const _kRefreshIndicatorColor = AppTheme.primary;

/// A full-screen WebView that loads a Madhmoon React sooq page.
///
/// Lifecycle:
/// 1. Calls [WebSessionService.initSession] to set the session cookie.
/// 2. Navigates the WebView to [WebConstants.sooqUrl] for [sooq].
/// 3. Listens to the `MadhmoonBridge` JS channel for cross-boundary commands.
///
/// Supported bridge message types:
/// - `navigate:wallet`  → `context.go('/wallet')`
/// - `navigate:profile` → `context.go('/profile')`
/// - `navigate:back`    → `context.pop()`
/// - `auth:expired`     → re-auth via AuthBloc
/// - `openCamera`       → image_picker → base64 back to JS
/// - `share`            → share_plus
class SooqWebView extends StatefulWidget {
  const SooqWebView({super.key, required this.sooq});

  /// Sooq slug: mazadat | matajir | balla | mustamal | chat | activity | feed
  final String sooq;

  @override
  State<SooqWebView> createState() => _SooqWebViewState();
}

class _SooqWebViewState extends State<SooqWebView>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  final WebSessionService _sessionService = getIt<WebSessionService>();
  final ImagePicker _picker = ImagePicker();

  _LoadState _loadState = _LoadState.loading;
  String? _errorMessage;

  // Shimmer animation
  late final AnimationController _shimmerAnim;
  late final Animation<double> _shimmerFade;

  @override
  void initState() {
    super.initState();
    _shimmerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _shimmerFade = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _shimmerAnim, curve: Curves.easeInOut),
    );
    _buildController();
    _initAndLoad();
  }

  @override
  void dispose() {
    _shimmerAnim.dispose();
    super.dispose();
  }

  // ── Controller setup ─────────────────────────────────────────────────────

  void _buildController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => _setLoadState(_LoadState.loading),
        onPageFinished: (_) => _setLoadState(_LoadState.loaded),
        onNavigationRequest: (request) {
          // Security: Validate URLs to prevent navigation to malicious sites
          final url = request.url;
          if (!_isAllowedUrl(url)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (error) {
          _setLoadState(_LoadState.error);
          if (mounted) setState(() => _errorMessage = error.description);
        },
      ))
      ..addJavaScriptChannel(
        'MadhmoonBridge',
        onMessageReceived: _onBridgeMessage,
      );
  }

  /// Security validation: Only allow navigation to trusted domains
  bool _isAllowedUrl(String url) {
    final allowedPrefixes = [
      WebConstants.baseWebUrl,
      'https://api.zaincash.iq',
      'https://wa.me/', // WhatsApp links from Mustamal
    ];
    return allowedPrefixes.any((prefix) => url.startsWith(prefix));
  }

  // ── Session + navigation ─────────────────────────────────────────────────

  Future<void> _initAndLoad() async {
    _setLoadState(_LoadState.loading);
    try {
      await _sessionService.initSession();
      if (!mounted) return;
      final url = WebConstants.sooqUrl(widget.sooq);
      await _controller.loadRequest(Uri.parse(url));
    } catch (_) {
      if (mounted) _setLoadState(_LoadState.error);
    }
  }

  Future<void> _reload({bool forceSession = false}) async {
    _setLoadState(_LoadState.loading);
    if (mounted) setState(() => _errorMessage = null);
    try {
      await _sessionService.initSession(force: forceSession);
      if (!mounted) return;
      await _controller.reload();
    } catch (_) {
      if (mounted) _setLoadState(_LoadState.error);
    }
  }

  void _setLoadState(_LoadState state) {
    if (mounted) setState(() => _loadState = state);
  }

  // ── JS bridge ────────────────────────────────────────────────────────────

  void _onBridgeMessage(JavaScriptMessage message) {
    final Map<String, dynamic> payload;
    try {
      payload = json.decode(message.message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = payload['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'navigate:wallet':
        if (mounted) context.go('/wallet');
      case 'navigate:profile':
        if (mounted) context.go('/profile');
      case 'navigate:back':
        if (mounted && context.canPop()) context.pop();
      case 'auth:expired':
        _handleAuthExpired();
      case 'openCamera':
        _handleOpenCamera(payload);
      case 'share':
        _handleShare(payload);
    }
  }

  void _handleAuthExpired() {
    if (!mounted) return;
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    // The router's redirect will navigate to /login automatically.
  }

  Future<void> _handleOpenCamera(Map<String, dynamic> payload) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
      );
      // ← mounted check after every await (HIGH fix)
      if (!mounted) return;
      if (file == null) {
        await _controller.runJavaScript(
          'window.dispatchEvent(new CustomEvent("madhmoon_camera_cancelled"))',
        );
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      final base64Image = base64Encode(bytes);
      final mimeType = file.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mimeType;base64,$base64Image';
      await _controller.runJavaScript(
        'window.dispatchEvent(new CustomEvent("madhmoon_camera_result", '
        '{ detail: { dataUrl: ${json.encode(dataUrl)} } }))',
      );
    } catch (_) {
      if (!mounted) return;
      await _controller.runJavaScript(
        'window.dispatchEvent(new CustomEvent("madhmoon_camera_error"))',
      );
    }
  }

  Future<void> _handleShare(Map<String, dynamic> payload) async {
    final inner = payload['payload'] as Map<String, dynamic>? ?? {};
    final text = inner['text'] as String? ?? '';
    final url = inner['url'] as String? ?? '';
    final combined = [text, url].where((s) => s.isNotEmpty).join('\n');
    if (combined.isNotEmpty) {
      await SharePlus.instance.share(ShareParams(text: combined));
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canGoBack = await _controller.canGoBack();
        if (canGoBack) {
          await _controller.goBack();
        } else if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: _kRefreshIndicatorColor,
        backgroundColor: Colors.white,
        displacement: 40,
        child: Stack(
          children: [
            // Use a ScrollConfiguration to enable pull-to-refresh
            ScrollConfiguration(
              behavior: const _WebViewScrollBehavior(),
              child: WebViewWidget(controller: _controller),
            ),
            if (_loadState == _LoadState.loading)
              RepaintBoundary(
                child: _LoadingSkeleton(shimmerFade: _shimmerFade),
              ),
            if (_loadState == _LoadState.error)
              _ErrorOverlay(
                message: _errorMessage,
                onRetry: () => _reload(forceSession: true),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom scroll behavior to enable pull-to-refresh on WebView
class _WebViewScrollBehavior extends ScrollBehavior {
  const _WebViewScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ── Load state enum ──────────────────────────────────────────────────────────

enum _LoadState { loading, loaded, error }

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.shimmerFade});

  final Animation<double> shimmerFade;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 24),
      child: FadeTransition(
        // FadeTransition uses the existing animation without extra compositing
        opacity: shimmerFade,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: double.infinity, height: 200),
            SizedBox(height: 16),
            _ShimmerBox(width: 240, height: 20),
            SizedBox(height: 8),
            _ShimmerBox(width: double.infinity, height: 14),
            SizedBox(height: 6),
            _ShimmerBox(width: 200, height: 14),
            SizedBox(height: 24),
            Row(
              children: [
                _ShimmerBox(width: 80, height: 80),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(width: double.infinity, height: 14),
                      SizedBox(height: 6),
                      _ShimmerBox(width: 120, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.shimmerBase,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ── Error overlay ─────────────────────────────────────────────────────────────

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      alignment: Alignment.center,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'تعذّر تحميل الصفحة',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'تحقق من اتصالك بالإنترنت ثم حاول مجدداً',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
