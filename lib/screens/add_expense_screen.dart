// lib/screens/expense_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../screens/edit_expense_screen.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;
  
  const ExpenseDetailScreen({
    Key? key,
    required this.expenseId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 지출 목록 가져오기
    final expensesState = ref.watch(expenseProvider);
    
    // 카테고리 목록 가져오기
    final categoriesState = ref.watch(categoryProvider);
    
    // 통화 포맷터
    final currencyFormatter = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('지출 상세'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _navigateToEditExpense(context, ref, expenseId),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmDialog(context, ref, expenseId),
          ),
        ],
      ),
      body: expensesState.when(
        data: (expenses) {
          // 현재 지출 찾기
          final expense = expenses.firstWhere(
            (e) => e.id == expenseId,
            orElse: () => null as Expense, // 찾지 못하면 null을 반환
          );
          
          if (expense == null) {
            return Center(
              child: Text('지출 정보를 찾을 수 없습니다.'),
            );
          }
          
          return categoriesState.when(
            data: (categories) {
              // 카테고리 찾기
              final category = categories.firstWhere(
                (c) => c.id == expense.categoryId,
                orElse: () => Category(
                  id: 'unknown',
                  name: '기타',
                  icon: 'more_horiz',
                  color: '#757575',
                  userId: 'default',
                  createdAt: DateTime.now(),
                ),
              );
              
              return _buildExpenseDetail(context, expense, category, currencyFormatter);
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('카테고리 정보를 불러오는 중 오류가 발생했습니다: $error'),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('지출 정보를 불러오는 중 오류가 발생했습니다: $error'),
        ),
      ),
    );
  }

  Widget _buildExpenseDetail(
    BuildContext context,
    Expense expense,
    Category category,
    NumberFormat currencyFormatter,
  ) {
    // 카테고리 색상
    final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지출 금액 카드
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '지출 금액',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(expense.amount),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text(
                      category.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: categoryColor,
                    avatar: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        IconData(
                          int.parse('0xe${category.icon}', radix: 16),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: categoryColor,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // 지출 세부 정보
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    '설명',
                    expense.description,
                    Icons.description,
                  ),
                  Divider(),
                  _buildDetailItem(
                    '날짜',
                    DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(expense.date),
                    Icons.calendar_today,
                  ),
                  Divider(),
                  _buildDetailItem(
                    '등록 일시',
                    DateFormat('yyyy-MM-dd HH:mm').format(expense.createdAt),
                    Icons.access_time,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // 추가 정보나 메모 (필요시)
          // ...
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToEditExpense(BuildContext context, WidgetRef ref, String expenseId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(expenseId: expenseId),
      ),
    );
    
    if (result == true) {
      // 수정이 완료되면 목록 새로고침
      ref.read(expenseProvider.notifier).loadExpenses();
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('지출 삭제'),
        content: Text('이 지출 내역을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(expenseProvider.notifier).deleteExpense(expenseId);
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context, true); // 상세 화면 닫고 결과 반환
            },
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}