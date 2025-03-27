// lib/widgets/settings/appearance_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 테마 모드를 위한 간단한 프로바이더
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system; // 기본값은 시스템 설정
});

// 언어 설정을 위한 프로바이더
final localeProvider = StateProvider<Locale>((ref) {
  return Locale('ko', 'KR'); // 기본값은 한국어
});

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 테마 모드
    final themeMode = ref.watch(themeModeProvider);
    
    // 현재 선택된 언어
    final locale = ref.watch(localeProvider);
    
    // 언어 목록
    final languages = [
      {'code': 'ko_KR', 'name': '한국어'},
      {'code': 'en_US', 'name': 'English'},
      {'code': 'ja_JP', 'name': '日本語'},
      {'code': 'zh_CN', 'name': '中文(简体)'},
    ];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱 디자인',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('다크 모드'),
              subtitle: Text(
                themeMode == ThemeMode.light
                    ? '사용 안함'
                    : themeMode == ThemeMode.dark
                        ? '사용함'
                        : '시스템 설정에 따름',
              ),
              trailing: DropdownButton<ThemeMode>(
                value: themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    ref.read(themeModeProvider.notifier).state = newValue;
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('시스템 설정'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('라이트 모드'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('다크 모드'),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text('언어'),
              subtitle: Text(
                languages.firstWhere(
                  (lang) => lang['code'] == '${locale.languageCode}_${locale.countryCode}',
                  orElse: () => {'code': 'unknown', 'name': '알 수 없음'},
                )['name']!,
              ),
              trailing: DropdownButton<String>(
                value: '${locale.languageCode}_${locale.countryCode}',
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final parts = newValue.split('_');
                    if (parts.length == 2) {
                      ref.read(localeProvider.notifier).state = Locale(parts[0], parts[1]);
                    }
                  }
                },
                items: languages.map<DropdownMenuItem<String>>((Map<String, String> lang) {
                  return DropdownMenuItem<String>(
                    value: lang['code'],
                    child: Text(lang['name']!),
                  );
                }).toList(),
              ),
            ),
            Divider(),
            ListTile(
              title: Text('글꼴 크기'),
              subtitle: Text('보통'),
              trailing: DropdownButton<String>(
                value: '보통',
                onChanged: (String? newValue) {
                  // 글꼴 크기 변경 로직
                },
                items: ['작게', '보통', '크게', '매우 크게']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}