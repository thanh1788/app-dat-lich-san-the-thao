import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class VoucherScreen extends StatelessWidget {
  const VoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vouchers = [
      _Voucher(
        code: 'SPORT6H50',
        title: 'Giảm 10% giờ vàng',
        desc: 'Áp dụng cho khung giờ 14h - 17h',
        expiry: '30/12/2026',
        color: const Color(0xFF00C853),
      ),
      _Voucher(
        code: 'NEWBIE50K',
        title: 'Giảm 50.000đ',
        desc: 'Cho đơn đầu tiên từ 200.000đ',
        expiry: '31/12/2026',
        color: const Color(0xFF00B4D8),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Kho voucher')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, i) {
          final v = vouchers[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [v.color, v.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        v.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  v.desc,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mã: ${v.code}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HSD: ${v.expiry}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Voucher {
  final String code;
  final String title;
  final String desc;
  final String expiry;
  final Color color;
  _Voucher({
    required this.code,
    required this.title,
    required this.desc,
    required this.expiry,
    required this.color,
  });
}