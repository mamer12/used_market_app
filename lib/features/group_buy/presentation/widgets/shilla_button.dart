import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../cubit/group_buy_cubit.dart';
import '../pages/group_buy_page.dart';

class ShillaButton extends StatelessWidget {
  final String productId;

  const ShillaButton({super.key, required this.productId});

  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _onTap(context),
      icon: const Icon(Icons.group_rounded),
      label: Text(
        'ابدأ شلة 👥',
        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final cubit = getIt<GroupBuyCubit>();
    final model = await cubit.createGroupBuy(productId);

    if (!context.mounted) return;
    cubit.close();

    if (model != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GroupBuyPage(groupBuyId: model.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل إنشاء الشلة، حاول مجدداً',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
