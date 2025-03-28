// lib/widgets/settings/about_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutSection extends ConsumerStatefulWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  ConsumerState<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends ConsumerState<AboutSection> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0'; // 기본값
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '앱 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('버전'),
              subtitle: Text(_appVersion),
              leading: const Icon(Icons.info_outline),
            ),
            const Divider(),
            ListTile(
              title: const Text('개인정보 처리방침'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.privacy_tip),
              onTap: () {
                // 개인정보 처리방침 화면으로 이동
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('이용약관'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.description),
              onTap: () {
                // 이용약관 화면으로 이동
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('오픈소스 라이선스'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.code),
              onTap: () {
                // 오픈소스 라이선스 화면으로 이동
                showLicensePage(
                  context: context,
                  applicationName: '재정 관리',
                  applicationVersion: _appVersion,
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('피드백 보내기'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.feedback),
              onTap: () {
                // 피드백 보내기 다이얼로그 표시
                _showFeedbackDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('평가하기'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.star),
              onTap: () {
                // 스토어 평가 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('앱 스토어로 이동합니다')),
                );
              },
            ),
            const Divider(),
            const Center(
              child: Column(
                children: [
                  Text(
                    '재정 관리',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '© 2025 All Rights Reserved',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 피드백 보내기 다이얼로그
  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('피드백 보내기'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('앱 사용 중 불편하신 점이나 개선 사항을 알려주세요.'),
            SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '피드백 내용을 입력하세요',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 피드백 보내기 기능 실행
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('소중한 의견 감사합니다')),
              );
            },
            child: const Text('보내기'),
          ),
        ],
      ),
    );
  }
}
