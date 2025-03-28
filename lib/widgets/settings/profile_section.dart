// lib/widgets/settings/profile_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moong_jju_finance/providers/member_provider.dart';
import 'package:moong_jju_finance/providers/auth_provider.dart';
import 'package:moong_jju_finance/screens/auth_screen.dart';

class ProfileSection extends ConsumerWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 로그인한 사용자 가져오기
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 프로필',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                title: const Text('로그인이 필요합니다'),
                subtitle: const Text('로그인하여 나만의 재정을 관리하세요'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                    );
                  },
                  child: const Text('로그인'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 현재 로그인한 사용자 정보 가져오기
    final currentMemberAsync = ref.watch(currentMemberProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내 프로필',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            currentMemberAsync.when(
              data: (member) {
                // 사용자 정보가 없는 경우
                if (member == null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    title: const Text('로그인이 필요합니다'),
                    subtitle: const Text('로그인하여 나만의 재정을 관리하세요'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      },
                      child: const Text('로그인'),
                    ),
                  );
                }

                // 사용자 정보가 있는 경우
                return ListTile(
                  leading: member.profileImage != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(member.profileImage!),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // 프로필 편집 화면으로 이동
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ProfileEditScreen(member: member),
                      //   ),
                      // );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Text('사용자 정보를 불러오는 중 오류가 발생했습니다.'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('비밀번호 변경'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 로그아웃 확인 다이얼로그 표시
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('정말 로그아웃하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // 로그아웃 처리
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            Navigator.pop(context); // 다이얼로그 닫기
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthScreen()),
                            );
                          }
                        },
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
