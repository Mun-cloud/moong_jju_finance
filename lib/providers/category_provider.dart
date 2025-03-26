import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moong_jju_finance/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:async';

// Category 모델 클래스는 이미 정의됨

// Supabase 클라이언트 프로바이더
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// 카테고리 상태를 위한 StateNotifier 클래스
class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final supabase.SupabaseClient _supabaseClient;
  StreamSubscription? _subscription;

  CategoryNotifier(this._supabaseClient) : super(const AsyncValue.loading()) {
    // 초기 데이터 로드
    loadCategories();

    // 실시간 업데이트 구독
    _subscription = _supabaseClient
        .from('categories')
        .stream(primaryKey: ['id']).listen((data) {
      final categories = data.map((json) => Category.fromJson(json)).toList();
      state = AsyncValue.data(categories);
    }, onError: (error) {
      state = AsyncValue.error(error, StackTrace.current);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // 카테고리 목록 로드
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final response =
          await _supabaseClient.from('categories').select().order('created_at');

      final categories =
          (response as List).map((json) => Category.fromJson(json)).toList();

      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 카테고리 추가
  Future<void> addCategory(Category category) async {
    try {
      await _supabaseClient.from('categories').insert(category.toJson());
      // 실시간 구독으로 상태가 자동 업데이트됨
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 카테고리 업데이트
  Future<void> updateCategory(Category category) async {
    try {
      await _supabaseClient
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id);
      // 실시간 구독으로 상태가 자동 업데이트됨
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 카테고리 삭제
  Future<void> deleteCategory(String id) async {
    try {
      await _supabaseClient.from('categories').delete().eq('id', id);
      // 실시간 구독으로 상태가 자동 업데이트됨
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // 사용자별 카테고리 로드
  Future<void> loadUserCategories(String userId) async {
    try {
      state = const AsyncValue.loading();
      final response = await _supabaseClient
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      final categories =
          (response as List).map((json) => Category.fromJson(json)).toList();

      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// CategoryNotifier 프로바이더
final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return CategoryNotifier(supabaseClient);
});

// 단일 카테고리 프로바이더 (ID로 조회)
final categoryProvider =
    Provider.family<AsyncValue<Category?>, String>((ref, id) {
  final categoriesState = ref.watch(categoryNotifierProvider);

  return categoriesState.when(
    data: (categories) {
      final category = categories.firstWhere(
        (category) => category.id == id,
        orElse: () => null as Category, // null을 반환하도록 orElse 설정
      );
      return AsyncValue.data(category);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// 카테고리 컬러 유틸리티
class CategoryColorUtil {
  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static String getHexFromColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}

// 카테고리 아이콘 유틸리티
class CategoryIconUtil {
  static IconData getIconData(String iconName) {
    // 아이콘 이름에 따라 IconData 반환하는 로직
    // 예: 'home' => Icons.home
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'shopping':
        return Icons.shopping_cart;
      case 'health':
        return Icons.health_and_safety;
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.travel_explore;
      case 'education':
        return Icons.school;
      // 더 많은 아이콘 매핑 추가 가능
      default:
        return Icons.category;
    }
  }
}
