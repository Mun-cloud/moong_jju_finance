// lib/widgets/settings/profile_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/member_viewmodel.dart';
import '../../screens/profile_edit_screen.dart'; // 아직 만들지 않은 화면

class ProfileSection extends ConsumerWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 ID (실제로는 인증 상태에서 가져와야 함)
    final userId = "51be03ed-22aa-4ea9-9064-328252867430"; // 임시 사용자 ID
    
    // 현재 로그인한 사용자 정보 가져오기
    final currentMemberAsync = ref.watch(currentMemberProvider);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내 프로필',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            currentMemberAsync.when(
              data: (member) {
                // 사용자 정보가 없는 경우
                if (member == null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                    title: Text('로그인이 필요합니다'),
                    subtitle: Text('로그인하여 나만의 재정을 관리하세요'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // 로그인 화면으로 이동
                      },
                      child: Text('로그인'),
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
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // 프로필 편집 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(member: member),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('사용자 정보를 불러오는 중 오류가 발생했습니다.'),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('비밀번호 변경'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 로그아웃 확인 다이얼로그 표시
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('로그아웃'),
                    content: Text('정말 로그아웃하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          // 실제 로그아웃 처리
                          Navigator.pop(context);
                        },
                        child: Text('로그아웃'),
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