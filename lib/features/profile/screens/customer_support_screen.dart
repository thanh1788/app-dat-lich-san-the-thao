import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SupportItem(Icons.phone, 'Hotline 1900 6868', 'Hỗ trợ 24/7'),
      _SupportItem(Icons.email, 'support@sport6h50.vn', 'Phản hồi trong 24h'),
      _SupportItem(Icons.chat_bubble_outline, 'Live chat', 'Chat trực tuyến'),
      _SupportItem(Icons.help_outline, 'Câu hỏi thường gặp', 'FAQ'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hỗ trợ khách hàng')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: Icon(it.icon, color: AppColors.primary),
              title: Text(
                it.title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                it.subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sẽ kết nối: ${it.title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SupportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  _SupportItem(this.icon, this.title, this.subtitle);
}