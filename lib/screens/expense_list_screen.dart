// lib/screens/expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../widgets/expense_filter.dart';
import '../screens/expense_detail_screen.dart';
import '../screens/add_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedCategoryId;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // 사용자 ID (실제로는 인증 상태에서 가져와야 함)
    final userId = "51be03ed-22aa-4ea9-9064-328252867430"; // 임시 사용자 ID
    
    // 날짜 범위로 필터링된 지출 목록
    final filteredExpenses = ref.watch(dateRangeExpensesProvider((
      start: _startDate,
      end: _endDate,
      userId: userId,
    )));
    
    // 카테고리별 추가 필터링
    final finalExpenses = _selectedCategoryId != null
        ? filteredExpenses.where((expense) => expense.categoryId == _selectedCategoryId).toList()
        : filteredExpenses;
    
    // 카테고리 정보
    final categoriesState = ref.watch(categoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('지출 목록'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(finalExpenses),
          _buildDateRangeIndicator(),
          Expanded(
            child: categoriesState.when(
              data: (categories) => _buildExpenseList(finalExpenses, categories),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('카테고리 정보를 불러오는 중 오류가 발생했습니다: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        child: Icon(Icons.add),
        tooltip: '지출 추가',
      ),
    );
  }

  Widget _buildSummaryCard(List<Expense> expenses) {
    final totalAmount = expenses.fold<double>(
      0, (sum, expense) => sum + expense.amount);
    
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '총 지출 금액',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              currencyFormatter.format(totalAmount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${DateFormat('yyyy년 MM월 dd일').format(_startDate)} ~ ${DateFormat('yyyy년 MM월 dd일').format(_endDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_selectedCategoryId != null)
            Chip(
              label: Text(
                ref.read(categoryByIdProvider(_selectedCategoryId!))?.name ?? '선택된 카테고리',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
              deleteIcon: Icon(Icons.clear, color: Colors.white),
              onDeleted: () {
                setState(() {
                  _selectedCategoryId = null;
                });
              },
            ),
          Spacer(),
          TextButton.icon(
            icon: Icon(Icons.date_range),
            label: Text('기간 변경'),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses, List<Category> categories) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              '지출 내역이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 지출을 추가해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // 날짜별로 그룹화
    final Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (!groupedExpenses.containsKey(dateKey)) {
        groupedExpenses[dateKey] = [];
      }
      groupedExpenses[dateKey]!.add(expense);
    }

    // 날짜 키를 정렬 (최신 날짜가 먼저 오도록)
    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dayExpenses = groupedExpenses[dateKey]!;
        final date = DateFormat('yyyy-MM-dd').parse(dateKey);
        
        // 날짜별 총 지출액 계산
        final dailyTotal = dayExpenses.fold<double>(
          0, (sum, expense) => sum + expense.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(date),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(dailyTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            ...dayExpenses.map((expense) {
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
              
              return ExpenseListItem(
                expense: expense,
                category: category,
                currencyFormatter: currencyFormatter,
                onTap: () => _navigateToExpenseDetail(context, expense.id),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _navigateToAddExpense(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(),
      ),
    );
    
    if (result == true) {
      // 지출이 추가되면 목록 새로고침
      ref.read(expenseProvider.notifier).loadExpenses();
    }
  }

  void _navigateToExpenseDetail(BuildContext context, String expenseId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
      ),
    );
    
    if (result == true) {
      // 지출이 수정되거나 삭제되면 목록 새로고침
      ref.read(expenseProvider.notifier).loadExpenses();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ExpenseFilterWidget(
          startDate: _startDate,
          endDate: _endDate,
          selectedCategoryId: _selectedCategoryId,
          onFilterChanged: (start, end, categoryId) {
            setState(() {
              _startDate = start;
              _endDate = end;
              _selectedCategoryId = categoryId;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

// 지출 목록 아이템 위젯
class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Category category;
  final NumberFormat currencyFormatter;
  final VoidCallback onTap;

  const ExpenseListItem({
    Key? key,
    required this.expense,
    required this.category,
    required this.currencyFormatter,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카테고리 색상
    final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: categoryColor,
        child: Icon(
          IconData(
            int.parse('0xe${category.icon}', radix: 16),
            fontFamily: 'MaterialIcons',
          ),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        expense.description,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(category.name),
      trailing: Text(
        currencyFormatter.format(expense.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red[700],
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}