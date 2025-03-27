// lib/widgets/settings/notification_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 알림 설정을 위한 간단한 프로바이더들
final budgetAlertProvider = StateProvider<bool>((ref) => true);
final dailyReminderProvider = StateProvider<bool>((ref) => false);
final weeklyReportProvider = StateProvider<bool>((ref) => true);
final promotionProvider = StateProvider<bool>((ref) => false);

class NotificationSection extends ConsumerWidget {
  const NotificationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 알림 설정 상태
    final budgetAlert = ref.watch(budgetAlertProvider);
    final dailyReminder = ref.watch(dailyReminderProvider);
    final weeklyReport = ref.watch(weeklyReportProvider);
    final promotion = ref.watch(promotionProvider);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('예산 알림'),
              subtitle: Text('예산의 80% 이상 사용 시 알림'),
              value: budgetAlert,
              onChanged: (bool value) {
                ref.read(budgetAlertProvider.notifier).state = value;
              },
              secondary: Icon(Icons.money_off),
            ),
            Divider(),
            SwitchListTile(
              title: Text('일일 지출 기록 알림'),
              subtitle: Text('매일 저녁 지출 내역 입력 리마인더'),
              value: dailyReminder,
              onChanged: (bool value) {
                ref.read(dailyReminderProvider.notifier).state = value;
              },
              secondary: Icon(Icons.access_time),
            ),
            Divider(),
            SwitchListTile(
              title: Text('주간 보고서'),
              subtitle: Text('일주일 재정 요약 보고서 알림'),
              value: weeklyReport,
              onChanged: (bool value) {
                ref.read(weeklyReportProvider.notifier).state = value;
              },
              secondary: Icon(Icons.analytics),
            ),
            Divider(),
            SwitchListTile(
              title: Text('프로모션 알림'),
              subtitle: Text('새로운 기능 및 업데이트 알림'),
              value: promotion,
              onChanged: (bool value) {
                ref.read(promotionProvider.notifier).state = value;
              },
              secondary: Icon(Icons.campaign),
            ),
            Divider(),
            ListTile(
              title: Text('알림 시간 설정'),
              subtitle: Text('매일 저녁 9시'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.schedule),
              onTap: () {
                // 알림 시간 설정 다이얼로그 표시
                _showTimePickerDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTimePickerDialog(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 21, minute: 0), // 기본값은 저녁 9시
    ).then((time) {
      if (time != null) {
        // 선택한 시간 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알림 시간이 ${time.format(context)}로 설정되었습니다')),
        );
      }
    });
  }
}