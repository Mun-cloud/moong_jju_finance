import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

// 현재 사용자 상태 제공자
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(supabase.auth.currentUser) {
    // 인증 상태 변경 감지
    supabase.auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });
  }

  // 이메일/비밀번호로 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // 이메일/비밀번호로 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
