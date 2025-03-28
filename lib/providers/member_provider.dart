// providers/member_provider.dart

import 'dart:io';

// Supabase 클라이언트 프로바이더 (main.dart에서 정의된 클라이언트를 사용)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moong_jju_finance/models/member.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// Member 상태를 관리하는 StateNotifier
class MemberNotifier extends StateNotifier<AsyncValue<List<Member>>> {
  final supabase.SupabaseClient _supabaseClient;
  static const String _tableName = 'members';

  MemberNotifier(this._supabaseClient) : super(const AsyncValue.loading()) {
    // 초기화 시 멤버 목록 로드
    loadMembers();
  }

  // 멤버 목록 로드
  Future<void> loadMembers() async {
    try {
      // 로딩 상태로 변경
      state = const AsyncValue.loading();

      // Supabase에서 멤버 목록 가져오기
      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      // JSON 데이터를 Member 객체 리스트로 변환
      final members = response.map((json) => Member.fromJson(json)).toList();

      // 성공 상태로 변경
      state = AsyncValue.data(members as List<Member>);
    } catch (e, stack) {
      // 오류 발생 시 오류 상태로 변경
      state = AsyncValue.error(e, stack);
    }
  }

  // 새 멤버 추가
  Future<void> addMember(Member member) async {
    try {
      // Supabase에 새 멤버 추가
      await _supabaseClient.from(_tableName).insert(member.toJson());

      // 멤버 목록 다시 로드
      await loadMembers();
    } catch (e) {
      // 오류 발생 시 오류 상태로 변경
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 멤버 업데이트
  Future<void> updateMember(Member member) async {
    try {
      // Supabase에서 멤버 업데이트
      await _supabaseClient
          .from(_tableName)
          .update(member.toJson())
          .eq('id', member.id);

      // 멤버 목록 다시 로드
      await loadMembers();
    } catch (e) {
      // 오류 발생 시 오류 상태로 변경
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 멤버 삭제
  Future<void> deleteMember(String memberId) async {
    try {
      // Supabase에서 멤버 삭제
      await _supabaseClient.from(_tableName).delete().eq('id', memberId);

      // 멤버 목록 다시 로드
      await loadMembers();
    } catch (e) {
      // 오류 발생 시 오류 상태로 변경
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 현재 로그인한 사용자의 멤버 정보 가져오기
  Future<Member?> getCurrentMember() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabaseClient
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      return Member.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // 특정 멤버 ID로 멤버 가져오기
  Member? getMemberById(String memberId) {
    final members = state.value;
    if (members != null) {
      try {
        return members.firstWhere((member) => member.id == memberId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // 사용자 프로필 이미지 업데이트
  Future<void> updateProfileImage(
      String memberId, String imagePath, File file) async {
    try {
      // 파일명 생성 (고유한 이름 생성)
      final fileName = 'profile_$memberId.jpg';

      // Storage에 이미지 업로드
      await _supabaseClient.storage.from('profiles').upload(
            fileName,
            file,
            fileOptions: const supabase.FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // 이미지 URL 가져오기
      final imageUrl =
          _supabaseClient.storage.from('profiles').getPublicUrl(fileName);

      // 멤버 정보에 이미지 URL 업데이트
      final member = getMemberById(memberId);
      if (member != null) {
        final updatedMember = Member(
          id: member.id,
          name: member.name,
          email: member.email,
          profileImage: imageUrl,
          createdAt: member.createdAt,
        );

        await updateMember(updatedMember);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Member 상태 관리를 위한 StateNotifierProvider
final memberProvider =
    StateNotifierProvider<MemberNotifier, AsyncValue<List<Member>>>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return MemberNotifier(supabaseClient);
});

// 단일 멤버 조회를 위한 Provider
final memberByIdProvider = Provider.family<Member?, String>((ref, memberId) {
  final membersState = ref.watch(memberProvider);
  return membersState.when(
    data: (members) {
      try {
        return members.firstWhere((member) => member.id == memberId);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// 현재 로그인한 사용자 멤버 정보를 위한 FutureProvider
final currentMemberProvider = FutureProvider<Member?>((ref) async {
  final memberNotifier = ref.watch(memberProvider.notifier);
  return memberNotifier.getCurrentMember();
});
