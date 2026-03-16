import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../pages/omla_offer_sheet.dart';

class OmlaButton extends StatelessWidget {
  final String productId;
  final int originalPrice;

  const OmlaButton({
    super.key,
    required this.productId,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => OmlaOfferSheet(
          productId: productId,
          originalPrice: originalPrice,
        ),
      ),
      icon: const Icon(Icons.handshake_outlined),
      label: Text(
        'عملة 🤝',
        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFEA580C),
        side: const BorderSide(color: Color(0xFFEA580C)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }
}
