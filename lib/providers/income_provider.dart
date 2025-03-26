// lib/viewmodels/income_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/income.dart';

// Supabase 클라이언트 프로바이더 (다른 뷰모델과 동일한 프로바이더 사용)
final supabaseProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// Income 상태를 관리하는 StateNotifier
class IncomeNotifier extends StateNotifier<AsyncValue<List<Income>>> {
  final supabase.SupabaseClient _supabaseClient;

  IncomeNotifier(this._supabaseClient) : super(const AsyncValue.loading()) {
    // 생성자에서 수입 목록 초기 로드
    loadIncomes();
  }

  // 수입 목록 불러오기
  Future<void> loadIncomes() async {
    try {
      // 로딩 상태로 변경
      state = const AsyncValue.loading();

      // Supabase에서 수입 데이터 조회
      final data = await _supabaseClient
          .from('incomes')
          .select()
          .order('date', ascending: false);

      // 조회된 데이터를 Income 객체 리스트로 변환
      final incomes = data.map((json) => Income.fromJson(json)).toList();

      // 데이터를 상태에 저장
      state = AsyncValue.data(List<Income>.from(incomes));
    } catch (e, stackTrace) {
      // 오류 발생 시 에러 상태로 변경
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 새 수입 추가
  Future<void> addIncome(Income income) async {
    try {
      // Supabase에 수입 추가
      await _supabaseClient.from('incomes').insert(income.toJson());

      // 수입 목록 다시 로드
      await loadIncomes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 수입 수정
  Future<void> updateIncome(Income income) async {
    try {
      // Supabase에서 수입 업데이트
      await _supabaseClient
          .from('incomes')
          .update(income.toJson())
          .eq('id', income.id);

      // 수입 목록 다시 로드
      await loadIncomes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 수입 삭제
  Future<void> deleteIncome(String id) async {
    try {
      // Supabase에서 수입 삭제
      await _supabaseClient.from('incomes').delete().eq('id', id);

      // 수입 목록 다시 로드
      await loadIncomes();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 사용자 ID로 수입 필터링
  List<Income> getIncomesByUserId(String userId) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return [];

    return incomesValue.where((income) => income.userId == userId).toList();
  }

  // 수입원(source)별 필터링
  List<Income> getIncomesBySource(String source) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return [];

    return incomesValue.where((income) => income.source == source).toList();
  }

  // 날짜 범위로 수입 필터링
  List<Income> getIncomesByDateRange(DateTime start, DateTime end) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return [];

    return incomesValue.where((income) {
      return income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // 월별 수입 합계 계산
  Map<String, double> getMonthlyIncomeTotals(String userId) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return {};

    final userIncomes =
        incomesValue.where((income) => income.userId == userId).toList();
    final Map<String, double> monthlyTotals = {};

    for (var income in userIncomes) {
      final monthKey =
          '${income.date.year}-${income.date.month.toString().padLeft(2, '0')}';
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = monthlyTotals[monthKey]! + income.amount;
      } else {
        monthlyTotals[monthKey] = income.amount;
      }
    }

    return monthlyTotals;
  }

  // 수입원별 수입 합계 계산
  Map<String, double> getSourceIncomeTotals(
      String userId, DateTime start, DateTime end) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return {};

    final filteredIncomes = incomesValue.where((income) {
      return income.userId == userId &&
          income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    final Map<String, double> sourceTotals = {};

    for (var income in filteredIncomes) {
      if (sourceTotals.containsKey(income.source)) {
        sourceTotals[income.source] =
            sourceTotals[income.source]! + income.amount;
      } else {
        sourceTotals[income.source] = income.amount;
      }
    }

    return sourceTotals;
  }

  // 특정 기간의 총 수입 계산
  double getTotalIncome(String userId, DateTime start, DateTime end) {
    final incomesValue = state.valueOrNull;
    if (incomesValue == null) return 0.0;

    final filteredIncomes = incomesValue.where((income) {
      return income.userId == userId &&
          income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    return filteredIncomes.fold(0.0, (sum, income) => sum + income.amount);
  }
}

// 전역 상태로 관리되는 수입 제공자
final incomeProvider =
    StateNotifierProvider<IncomeNotifier, AsyncValue<List<Income>>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return IncomeNotifier(supabase);
});

// 사용자 ID로 필터링된 수입 목록을 제공하는 Provider
final userIncomesProvider =
    Provider.family<List<Income>, String>((ref, userId) {
  final incomesState = ref.watch(incomeProvider);
  return incomesState.whenOrNull(
        data: (incomes) =>
            incomes.where((income) => income.userId == userId).toList(),
      ) ??
      [];
});

// 수입원별로 필터링된 수입 목록을 제공하는 Provider
final sourceIncomesProvider =
    Provider.family<List<Income>, ({String source, String userId})>(
        (ref, params) {
  final incomesState = ref.watch(incomeProvider);
  return incomesState.whenOrNull(
        data: (incomes) => incomes
            .where((income) =>
                income.source == params.source &&
                income.userId == params.userId)
            .toList(),
      ) ??
      [];
});

// 날짜 범위로 필터링된 수입 목록을 제공하는 Provider
final dateRangeIncomesProvider = Provider.family<List<Income>,
    ({DateTime start, DateTime end, String userId})>((ref, params) {
  final incomesState = ref.watch(incomeProvider);
  return incomesState.whenOrNull(
        data: (incomes) => incomes
            .where((income) =>
                income.userId == params.userId &&
                income.date
                    .isAfter(params.start.subtract(const Duration(days: 1))) &&
                income.date.isBefore(params.end.add(const Duration(days: 1))))
            .toList(),
      ) ??
      [];
});

// 월별 수입 합계를 제공하는 Provider
final monthlyIncomeTotalsProvider =
    Provider.family<Map<String, double>, String>((ref, userId) {
  final notifier = ref.watch(incomeProvider.notifier);
  return notifier.getMonthlyIncomeTotals(userId);
});

// 수입원별 수입 합계를 제공하는 Provider
final sourceIncomeTotalsProvider = Provider.family<Map<String, double>,
    ({String userId, DateTime start, DateTime end})>((ref, params) {
  final notifier = ref.watch(incomeProvider.notifier);
  return notifier.getSourceIncomeTotals(
      params.userId, params.start, params.end);
});

// 특정 기간의 총 수입을 제공하는 Provider
final totalIncomeProvider =
    Provider.family<double, ({String userId, DateTime start, DateTime end})>(
        (ref, params) {
  final notifier = ref.watch(incomeProvider.notifier);
  return notifier.getTotalIncome(params.userId, params.start, params.end);
});
