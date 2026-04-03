import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

// ── Mazadat Dark Palette ──────────────────────────────────────────────────────
const _bg       = Color(0xFF0A0A0F);
const _surface  = Color(0xFF12121A);
const _border   = Color(0xFF1E1E2A);
const _primary  = Color(0xFFFF3D5A);
const _cyan     = Color(0xFF3CD2EB);
const _textSec  = Color(0xFF9CA3AF);
const _textTert = Color(0xFF6B7280);

/// Model for a single auction clip returned by GET /auctions/:id/clips.
class AuctionClipModel {
  final String id;
  final String auctionId;
  final String uploaderId;
  final String videoUrl;
  final String thumbUrl;
  final int durationS;

  const AuctionClipModel({
    required this.id,
    required this.auctionId,
    required this.uploaderId,
    required this.videoUrl,
    this.thumbUrl = '',
    this.durationS = 0,
  });

  factory AuctionClipModel.fromJson(Map<String, dynamic> json) {
    return AuctionClipModel(
      id: json['id'] as String? ?? '',
      auctionId: json['auction_id'] as String? ?? '',
      uploaderId: json['uploader_id'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      thumbUrl: json['thumb_url'] as String? ?? '',
      durationS: json['duration_s'] as int? ?? 0,
    );
  }
}

/// Horizontal scrollable row of auction video clip thumbnails.
///
/// Tapping any thumbnail opens a full-screen video player overlay.
/// RTL layout; uses Mazadat dark theme.
class AuctionClipsRow extends StatelessWidget {
  final List<AuctionClipModel> clips;

  const AuctionClipsRow({super.key, required this.clips});

  @override
  Widget build(BuildContext context) {
    if (clips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 0, end: 0, top: 4.h, bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'مقاطع الفيديو',
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 110.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: clips.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                return _ClipThumbnail(
                  clip: clips[index],
                  onTap: () => _openFullScreen(context, clips, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(
    BuildContext context,
    List<AuctionClipModel> clips,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => _FullScreenVideoPlayer(
          clips: clips,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ── Clip Thumbnail ────────────────────────────────────────────────────────────

class _ClipThumbnail extends StatelessWidget {
  final AuctionClipModel clip;
  final VoidCallback onTap;

  const _ClipThumbnail({required this.clip, required this.onTap});

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 90.w,
          height: 110.h,
          color: _surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail image or placeholder
              if (clip.thumbUrl.isNotEmpty)
                Image.network(
                  clip.thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              else
                _placeholder(),

              // Semi-transparent overlay + play icon
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withValues(alpha: 0.85),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),

              // Duration badge (bottom-start)
              if (clip.durationS > 0)
                PositionedDirectional(
                  bottom: 6.h,
                  start: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _formatDuration(clip.durationS),
                      style: GoogleFonts.cairo(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _placeholder() {
    return Container(
      color: _border,
      child: Icon(
        Icons.play_circle_outline_rounded,
        color: _textTert,
        size: 32.sp,
      ),
    );
  }
}

// ── Full-Screen Video Player ──────────────────────────────────────────────────

class _FullScreenVideoPlayer extends StatefulWidget {
  final List<AuctionClipModel> clips;
  final int initialIndex;

  const _FullScreenVideoPlayer({
    required this.clips,
    required this.initialIndex,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late int _currentIndex;
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer(_currentIndex);
  }

  Future<void> _initPlayer(int index) async {
    final clip = widget.clips[index];
    final uri = Uri.tryParse(clip.videoUrl);
    if (uri == null) {
      setState(() => _hasError = true);
      return;
    }

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    final oldController = _controller;
    final newController = VideoPlayerController.networkUrl(uri);
    _controller = newController;

    try {
      await newController.initialize();
      if (!mounted) return;
      setState(() => _isInitializing = false);
      unawaited(newController.play());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    } finally {
      await oldController?.dispose();
    }
  }

  void _switchClip(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    _initPlayer(index);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _surface,
                        border: Border.all(color: _border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} / ${widget.clips.length}',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: _textSec,
                    ),
                  ),
                ],
              ),
            ),

            // ── Video area ──
            Expanded(
              child: Center(
                child: _buildVideoArea(),
              ),
            ),

            // ── Controls ──
            if (_controller != null && !_isInitializing && !_hasError)
              _buildControls(),

            SizedBox(height: 8.h),

            // ── Clip strip ──
            if (widget.clips.length > 1) _buildClipStrip(),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_rounded, color: _textTert, size: 48.sp),
          SizedBox(height: 8.h),
          Text(
            'تعذّر تحميل الفيديو',
            style: GoogleFonts.cairo(fontSize: 14.sp, color: _textSec),
          ),
        ],
      );
    }

    if (_isInitializing || _controller == null) {
      return const CircularProgressIndicator(color: _cyan);
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }

  Widget _buildControls() {
    final ctrl = _controller!;
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: ctrl,
      builder: (_, value, _) {
        final isPlaying = value.isPlaying;
        final position = value.position;
        final duration = value.duration;
        final progress =
            duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _primary,
                  inactiveTrackColor: _border,
                  thumbColor: _primary,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.r),
                  overlayShape: SliderComponentShape.noOverlay,
                  trackHeight: 3.h,
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    ctrl.seekTo(duration * v);
                  },
                ),
              ),
              // Play/pause + time
              Row(
                children: [
                  Text(
                    _formatMs(position.inMilliseconds),
                    style: GoogleFonts.cairo(fontSize: 11.sp, color: _textSec),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      isPlaying ? ctrl.pause() : ctrl.play();
                    },
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _primary,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatMs(duration.inMilliseconds),
                    style: GoogleFonts.cairo(fontSize: 11.sp, color: _textSec),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClipStrip() {
    return SizedBox(
      height: 60.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: widget.clips.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isActive = index == _currentIndex;
          final clip = widget.clips[index];
          return GestureDetector(
            onTap: () => _switchClip(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                width: 50.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: _surface,
                  border: Border.all(
                    color: isActive ? _primary : _border,
                    width: isActive ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: clip.thumbUrl.isNotEmpty
                    ? Image.network(clip.thumbUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(Icons.play_circle_outline_rounded, color: _textTert, size: 20.sp))
                    : Icon(Icons.play_circle_outline_rounded, color: _textTert, size: 20.sp),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatMs(int ms) {
    final totalSeconds = ms ~/ 1000;
    final m = totalSeconds ~/ 60;
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
