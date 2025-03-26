// lib/viewmodels/expense_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/expense.dart';

// Supabase 클라이언트 프로바이더 (다른 뷰모델과 동일한 프로바이더 사용)
final supabaseProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

// Expense 상태를 관리하는 StateNotifier
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final supabase.SupabaseClient _supabaseClient;

  ExpenseNotifier(this._supabaseClient) : super(const AsyncValue.loading()) {
    // 생성자에서 지출 목록 초기 로드
    loadExpenses();
  }

  // 지출 목록 불러오기
  Future<void> loadExpenses() async {
    try {
      // 로딩 상태로 변경
      state = const AsyncValue.loading();

      // Supabase에서 지출 데이터 조회
      final data = await _supabaseClient
          .from('expenses')
          .select()
          .order('date', ascending: false);

      // 조회된 데이터를 Expense 객체 리스트로 변환
      final expenses = data.map((json) => Expense.fromJson(json)).toList();

      // 데이터를 상태에 저장
      state = AsyncValue.data(List<Expense>.from(expenses));
    } catch (e, stackTrace) {
      // 오류 발생 시 에러 상태로 변경
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 새 지출 추가
  Future<void> addExpense(Expense expense) async {
    try {
      // Supabase에 지출 추가
      await _supabaseClient.from('expenses').insert(expense.toJson());

      // 지출 목록 다시 로드
      await loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 지출 수정
  Future<void> updateExpense(Expense expense) async {
    try {
      // Supabase에서 지출 업데이트
      await _supabaseClient
          .from('expenses')
          .update(expense.toJson())
          .eq('id', expense.id);

      // 지출 목록 다시 로드
      await loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 지출 삭제
  Future<void> deleteExpense(String id) async {
    try {
      // Supabase에서 지출 삭제
      await _supabaseClient.from('expenses').delete().eq('id', id);

      // 지출 목록 다시 로드
      await loadExpenses();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // 사용자 ID로 지출 필터링
  List<Expense> getExpensesByUserId(String userId) {
    final expensesValue = state.valueOrNull;
    if (expensesValue == null) return [];

    return expensesValue.where((expense) => expense.userId == userId).toList();
  }

  // 카테고리 ID로 지출 필터링
  List<Expense> getExpensesByCategoryId(String categoryId) {
    final expensesValue = state.valueOrNull;
    if (expensesValue == null) return [];

    return expensesValue
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  // 날짜 범위로 지출 필터링
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    final expensesValue = state.valueOrNull;
    if (expensesValue == null) return [];

    return expensesValue.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // 월별 지출 합계 계산
  Map<String, double> getMonthlyExpenseTotals(String userId) {
    final expensesValue = state.valueOrNull;
    if (expensesValue == null) return {};

    final userExpenses =
        expensesValue.where((expense) => expense.userId == userId).toList();
    final Map<String, double> monthlyTotals = {};

    for (var expense in userExpenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] = monthlyTotals[monthKey]! + expense.amount;
      } else {
        monthlyTotals[monthKey] = expense.amount;
      }
    }

    return monthlyTotals;
  }

  // 카테고리별 지출 합계 계산
  Map<String, double> getCategoryExpenseTotals(
      String userId, DateTime start, DateTime end) {
    final expensesValue = state.valueOrNull;
    if (expensesValue == null) return {};

    final filteredExpenses = expensesValue.where((expense) {
      return expense.userId == userId &&
          expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    final Map<String, double> categoryTotals = {};

    for (var expense in filteredExpenses) {
      if (categoryTotals.containsKey(expense.categoryId)) {
        categoryTotals[expense.categoryId] =
            categoryTotals[expense.categoryId]! + expense.amount;
      } else {
        categoryTotals[expense.categoryId] = expense.amount;
      }
    }

    return categoryTotals;
  }
}

// 전역 상태로 관리되는 지출 제공자
final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ExpenseNotifier(supabase);
});

// 사용자 ID로 필터링된 지출 목록을 제공하는 Provider
final userExpensesProvider =
    Provider.family<List<Expense>, String>((ref, userId) {
  final expensesState = ref.watch(expenseProvider);
  return expensesState.whenOrNull(
        data: (expenses) =>
            expenses.where((expense) => expense.userId == userId).toList(),
      ) ??
      [];
});

// 카테고리 ID로 필터링된 지출 목록을 제공하는 Provider
final categoryExpensesProvider =
    Provider.family<List<Expense>, String>((ref, categoryId) {
  final expensesState = ref.watch(expenseProvider);
  return expensesState.whenOrNull(
        data: (expenses) => expenses
            .where((expense) => expense.categoryId == categoryId)
            .toList(),
      ) ??
      [];
});

// 날짜 범위로 필터링된 지출 목록을 제공하는 Provider
final dateRangeExpensesProvider = Provider.family<List<Expense>,
    ({DateTime start, DateTime end, String userId})>((ref, params) {
  final expensesState = ref.watch(expenseProvider);
  return expensesState.whenOrNull(
        data: (expenses) => expenses
            .where((expense) =>
                expense.userId == params.userId &&
                expense.date
                    .isAfter(params.start.subtract(const Duration(days: 1))) &&
                expense.date.isBefore(params.end.add(const Duration(days: 1))))
            .toList(),
      ) ??
      [];
});

// 월별 지출 합계를 제공하는 Provider
final monthlyExpenseTotalsProvider =
    Provider.family<Map<String, double>, String>((ref, userId) {
  final notifier = ref.watch(expenseProvider.notifier);
  return notifier.getMonthlyExpenseTotals(userId);
});

// 카테고리별 지출 합계를 제공하는 Provider
final categoryExpenseTotalsProvider = Provider.family<Map<String, double>,
    ({String userId, DateTime start, DateTime end})>((ref, params) {
  final notifier = ref.watch(expenseProvider.notifier);
  return notifier.getCategoryExpenseTotals(
      params.userId, params.start, params.end);
});
