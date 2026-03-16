import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/di/injection.dart';
import '../../../../core/storage/token_storage.dart';
import '../cubit/negotiation_cubit.dart';

class OmlaOfferSheet extends StatefulWidget {
  final String productId;
  final int originalPrice;

  const OmlaOfferSheet({
    super.key,
    required this.productId,
    required this.originalPrice,
  });

  @override
  State<OmlaOfferSheet> createState() => _OmlaOfferSheetState();
}

class _OmlaOfferSheetState extends State<OmlaOfferSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const _baseUrl = 'https://api.madhmoon.iq';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(int amount) =>
      '${NumberFormat('#,###', 'ar_IQ').format(amount)} د.ع';

  Future<void> _submit(NegotiationCubit cubit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    final offeredPrice = int.tryParse(_controller.text.trim()) ?? 0;
    final success = await cubit.submitOffer(
      productId: widget.productId,
      offeredPrice: offeredPrice,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إرسال عرضك بنجاح',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل إرسال العرض، حاول مجدداً',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIt<TokenStorage>().getToken(),
      builder: (context, snapshot) {
        final token = snapshot.data ?? '';
        return BlocProvider(
          create: (_) => NegotiationCubit(baseUrl: _baseUrl, token: token),
          child: Builder(
            builder: (ctx) {
              final cubit = ctx.read<NegotiationCubit>();
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    padding:
                        EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Title
                          Text(
                            'أرسل عرضك',
                            style: GoogleFonts.cairo(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Original price chip
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'السعر الأصلي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  _formatPrice(widget.originalPrice),
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Offer label
                          Text(
                            'عرضك (بالدينار العراقي)',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6.h),

                          // Offer input
                          TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textDirection: TextDirection.ltr,
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: 'أدخل سعرك',
                              hintStyle: GoogleFonts.cairo(
                                color: Colors.grey.shade400,
                              ),
                              suffixText: 'د.ع',
                              suffixStyle: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEA580C), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide:
                                    const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'الرجاء إدخال سعر';
                              }
                              final price = int.tryParse(value.trim());
                              if (price == null || price <= 0) {
                                return 'سعر غير صالح';
                              }
                              if (price >= widget.originalPrice) {
                                return 'يجب أن يكون عرضك أقل من السعر الأصلي';
                              }
                              if (widget.originalPrice - price < 1000) {
                                return 'يجب أن يكون الفرق 1,000 د.ع على الأقل';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _submit(cubit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'إرسال العرض',
                                      style: GoogleFonts.cairo(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
