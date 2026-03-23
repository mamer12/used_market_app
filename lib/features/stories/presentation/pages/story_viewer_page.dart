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
import '../../data/models/story_model.dart';
import '../bloc/story_cubit.dart';

/// Full-screen story viewer page (Instagram-like).
///
/// Features:
///   - Progress bar per story
///   - Auto-advance after 5 seconds
///   - Tap left/right to navigate
///   - Swipe down to close
///   - Shop name + avatar + time ago
///   - Price tag CTA overlay
class StoryViewerPage extends StatefulWidget {
  final String shopId;

  const StoryViewerPage({super.key, required this.shopId});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  int _groupIndex = 0;
  int _storyIndex = 0;
  Timer? _timer;
  double _progress = 0;
  static const _durationSeconds = 5;

  late final StoryCubit _cubit;
  List<StoryGroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<StoryCubit>()..fetchFeed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _onStoriesLoaded(List<StoryGroupModel> groups) {
    _groups = groups;
    // Find the group that matches shopId
    final idx = groups.indexWhere((g) => g.shopId == widget.shopId);
    _groupIndex = idx >= 0 ? idx : 0;
    _storyIndex = 0;
    _startTimer();
    _markCurrentViewed();
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
    if (_groupIndex < _groups.length) {
      final stories = _groups[_groupIndex].stories;
      if (_storyIndex < stories.length) {
        _cubit.markViewed(stories[_storyIndex].id);
      }
    }
  }

  void _advance() {
    final group = _groups[_groupIndex];
    if (_storyIndex < group.stories.length - 1) {
      setState(() => _storyIndex++);
      _startTimer();
      _markCurrentViewed();
    } else if (_groupIndex < _groups.length - 1) {
      // Move to next shop group
      setState(() {
        _groupIndex++;
        _storyIndex = 0;
      });
      _startTimer();
      _markCurrentViewed();
    } else {
      _close();
    }
  }

  void _retreat() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _startTimer();
      _markCurrentViewed();
    } else if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _storyIndex = _groups[_groupIndex].stories.length - 1;
      });
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<StoryCubit, StoryState>(
        listener: (context, state) {
          if (state is StoriesLoaded) {
            _onStoriesLoaded(state.groups);
          }
        },
        builder: (context, state) {
          if (state is StoryLoading || state is StoryInitial) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is StoryError || _groups.isEmpty) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _close());
            return const SizedBox.shrink();
          }

          final group = _groups[_groupIndex];
          final stories = group.stories;
          if (stories.isEmpty) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _close());
            return const SizedBox.shrink();
          }

          final story = stories[_storyIndex];

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
                    // Full-screen media
                    _buildMedia(story),

                    // Header overlay
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
                                children:
                                    List.generate(stories.length, (i) {
                                  double value;
                                  if (i < _storyIndex) {
                                    value = 1.0;
                                  } else if (i == _storyIndex) {
                                    value = _progress.clamp(0.0, 1.0);
                                  } else {
                                    value = 0.0;
                                  }
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.35),
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
                                    child: group.shopLogoUrl.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: group.shopLogoUrl,
                                              width: 32.w,
                                              height: 32.w,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, _, _) =>
                                                  Text(
                                                group.shopName.isNotEmpty
                                                    ? group.shopName[0]
                                                    : 'م',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14.sp,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            group.shopName.isNotEmpty
                                                ? group.shopName[0]
                                                : 'م',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Shop name
                                  Text(
                                    group.shopName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  // Time ago
                                  Text(
                                    _timeAgo(story.expiresAt.subtract(
                                        const Duration(hours: 24))),
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      color: Colors.white
                                          .withValues(alpha: 0.7),
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

                    // Price tag overlay
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
                              color:
                                  Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        IqdFormatter.format(
                                            story.priceTag!),
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
                                    backgroundColor:
                                        AppTheme.matajirBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 12.h),
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
        },
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

    return CachedNetworkImage(
      imageUrl: story.mediaUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      errorWidget: (_, _, _) => Container(
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
