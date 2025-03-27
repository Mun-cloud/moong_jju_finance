// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/settings/profile_section.dart';
import '../widgets/settings/appearance_section.dart';
import '../widgets/settings/notification_section.dart';
import '../widgets/settings/budget_section.dart';
import '../widgets/settings/data_section.dart';
import '../widgets/settings/about_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 프로필 섹션
          ProfileSection(),
          SizedBox(height: 16),
          
          // 앱 디자인 섹션
          AppearanceSection(),
          SizedBox(height: 16),
          
          // 알림 설정 섹션
          NotificationSection(),
          SizedBox(height: 16),
          
          // 예산 설정 섹션
          BudgetSection(),
          SizedBox(height: 16),
          
          // 데이터 관리 섹션
          DataSection(),
          SizedBox(height: 16),
          
          // 앱 정보 섹션
          AboutSection(),
        ],
      ),
    );
  }
}