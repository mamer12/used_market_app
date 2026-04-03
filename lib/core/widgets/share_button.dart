import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable share icon button that generates a deep link URL.
/// Usage: ShareButton(type: 'auction', id: '123', title: 'عنوان المزاد')
class ShareButton extends StatelessWidget {
  final String type;  // 'auction' | 'product' | 'mustamal'
  final String id;
  final String title;

  const ShareButton({
    super.key,
    required this.type,
    required this.id,
    required this.title,
  });

  String get _url => 'https://madhmoon.iq/$type/$id';

  Future<void> _share(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(text: '$title\n$_url', subject: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _share(context),
      icon: Icon(Icons.share_outlined, size: 22.sp),
      tooltip: 'مشاركة',
    );
  }
}
