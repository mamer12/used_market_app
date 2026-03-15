import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';

/// Winner Payment Flow — deducts from Wallet and shifts to Escrow.
class MazadatPaymentPage extends StatefulWidget {
  final String auctionId;
  final String itemTitle;
  final int winningBid;
  final String imageUrl;

  const MazadatPaymentPage({
    super.key,
    required this.auctionId,
    required this.itemTitle,
    required this.winningBid,
    required this.imageUrl,
  });

  @override
  State<MazadatPaymentPage> createState() => _MazadatPaymentPageState();
}

class _MazadatPaymentPageState extends State<MazadatPaymentPage> {
  bool _isProcessing = false;

  Future<void> _handlePayment(BuildContext context) async {
    final walletCubit = context.read<WalletCubit>();
    
    setState(() => _isProcessing = true);
    
    final success = await walletCubit.deductBalance(widget.winningBid);
    
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        context.pushReplacement('/mazadat/payment-success', extra: {
          'auctionId': widget.auctionId,
          'itemTitle': widget.itemTitle,
          'finalPrice': widget.winningBid.toDouble(),
          'imageUrl': widget.imageUrl,
          'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        });
      }
    } else {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء الدفع، تأكد من رصيدك',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        primaryColor: AppTheme.mazadGreen,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'إتمام الدفع',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        body: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final balance = state is WalletLoaded ? state.balanceIqd : 0;
            final canAfford = balance >= widget.winningBid;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item summary
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المطلوب سداده',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            IqdFormatter.format(widget.winningBid.toDouble()),
                            style: GoogleFonts.cairo(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.mazadGreen,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.itemTitle,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Wallet box
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121A),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: canAfford ? AppTheme.success.withValues(alpha: 0.5) : AppTheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, 
                                color: canAfford ? AppTheme.success : AppTheme.error,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.mazadatWalletBalance,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    IqdFormatter.format(balance.toDouble()),
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!canAfford)
                            Text(
                              'رصيد غير كاف',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.error,
                              ),
                            )
                          else
                            Icon(Icons.check_circle_rounded, color: AppTheme.success),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action button
                    if (canAfford)
                      ElevatedButton(
                        onPressed: _isProcessing ? null : () => _handlePayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mazadGreen,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                l10n.mazadatPayFromWallet,
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push('/wallet');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceAlt, // or some dark color
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            side: const BorderSide(color: AppTheme.mazadGreen),
                          ),
                        ),
                        child: Text(
                          l10n.mazadatTopUpWallet,
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mazadGreen,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
