import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/follow_repository.dart';

/// Animated follow/unfollow button for shop pages.
///
/// Calls POST/DELETE /api/v1/shops/:id/follow via [FollowRepository].
/// Displays a heart icon with follow/following state and smooth animation.
class FollowButton extends StatefulWidget {
  final String shopId;
  final bool initiallyFollowing;
  final VoidCallback? onFollowChanged;

  const FollowButton({
    super.key,
    required this.shopId,
    this.initiallyFollowing = false,
    this.onFollowChanged,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with SingleTickerProviderStateMixin {
  late bool _isFollowing;
  bool _isLoading = false;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final FollowRepository _repo;

  static const _matajirBlue = AppTheme.matajirBlue;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initiallyFollowing;
    _repo = getIt<FollowRepository>();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    // Check actual follow status from API
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    final status = await _repo.isFollowing(widget.shopId);
    if (mounted && status != _isFollowing) {
      setState(() => _isFollowing = status);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final success = _isFollowing
        ? await _repo.unfollowShop(widget.shopId)
        : await _repo.followShop(widget.shopId);

    if (!mounted) return;

    if (success) {
      setState(() => _isFollowing = !_isFollowing);
      unawaited(_animController.forward(from: 0));
      widget.onFollowChanged?.call();

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFollowing ? l10n.followSuccess : l10n.unfollowSuccess,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          ),
          backgroundColor:
              _isFollowing ? _matajirBlue : AppTheme.textSecondary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _isFollowing
            ? OutlinedButton.icon(
                onPressed: _isLoading ? null : _toggleFollow,
                icon: _isLoading
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _matajirBlue,
                        ),
                      )
                    : Icon(Icons.favorite_rounded, size: 16.sp),
                label: Text(
                  l10n.followingBtn,
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _matajirBlue,
                  side: const BorderSide(color: _matajirBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            : ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleFollow,
                icon: _isLoading
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.favorite_border_rounded, size: 16.sp),
                label: Text(
                  l10n.followBtn,
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _matajirBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                ),
              ),
      ),
    );
  }
}
