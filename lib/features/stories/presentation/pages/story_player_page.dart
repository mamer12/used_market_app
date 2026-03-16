import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../data/models/story_model.dart';
import '../bloc/story_cubit.dart';

class StoryPlayerPage extends StatefulWidget {
  final StoryGroupModel group;

  const StoryPlayerPage({super.key, required this.group});

  @override
  State<StoryPlayerPage> createState() => _StoryPlayerPageState();
}

class _StoryPlayerPageState extends State<StoryPlayerPage> {
  int _currentIndex = 0;
  Timer? _timer;
  double _progress = 0;
  static const _durationSeconds = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _markCurrentViewed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0;
    const tickMs = 50;
    _timer = Timer.periodic(const Duration(milliseconds: tickMs), (_) {
      if (!mounted) return;
      setState(() {
        _progress += tickMs / (_durationSeconds * 1000);
        if (_progress >= 1.0) {
          _advance();
        }
      });
    });
  }

  void _markCurrentViewed() {
    final stories = widget.group.stories;
    if (_currentIndex < stories.length) {
      context.read<StoryCubit>().markViewed(stories[_currentIndex].id);
    }
  }

  void _advance() {
    final total = widget.group.stories.length;
    if (_currentIndex < total - 1) {
      setState(() => _currentIndex++);
      _startTimer();
      _markCurrentViewed();
    } else {
      _close();
    }
  }

  void _retreat() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startTimer();
      _markCurrentViewed();
    } else {
      _startTimer();
    }
  }

  void _close() {
    _timer?.cancel();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final stories = widget.group.stories;
    if (stories.isEmpty) {
      _close();
      return const SizedBox.shrink();
    }

    final story = stories[_currentIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapUp: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth * 0.3) {
              _retreat();
            } else {
              _advance();
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 200) {
              _close();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Full screen media ──────────────────────────────────────
              _buildMedia(story),

              // ── Header overlay ─────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Column(
                    children: [
                      // Progress bars
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 8.h),
                        child: Row(
                          children: List.generate(stories.length, (i) {
                            double value;
                            if (i < _currentIndex) {
                              value = 1.0;
                            } else if (i == _currentIndex) {
                              value = _progress.clamp(0.0, 1.0);
                            } else {
                              value = 0.0;
                            }
                            return Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 2.w),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.35),
                                  color: Colors.white,
                                  minHeight: 2.5,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Shop info row
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withValues(alpha: 0.2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.group.shopName.isNotEmpty
                                    ? widget.group.shopName[0]
                                    : 'م',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              widget.group.shopName,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            // Close button
                            GestureDetector(
                              onTap: _close,
                              child: Container(
                                width: 32.w,
                                height: 32.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black
                                      .withValues(alpha: 0.35),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Price tag overlay ──────────────────────────────────────
              if (story.priceTag != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Container(
                      margin: EdgeInsets.all(16.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'السعر',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: Colors.white
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  IqdFormatter.format(story.priceTag!),
                                  style: GoogleFonts.cairo(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 12.h),
                            ),
                            child: Text(
                              'اشتري الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(StoryItemModel story) {
    if (story.mediaType == 'video') {
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(
            Icons.play_circle_outline_rounded,
            size: 64.sp,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Image.network(
      story.mediaUrl,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        color: Colors.black87,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 48.sp,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
