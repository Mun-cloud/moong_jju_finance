// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../screens/expense_list_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_income_screen.dart'; // 이 파일은 별도로 구현 필요

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 현재 선택된 월
  late DateTime _selectedMonth;
  
  // 화면 탭 인덱스
  int _currentIndex = 0;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  // 월 시작일
  DateTime get _monthStart => DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  
  // 월 종료일
  DateTime get _monthEnd => DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

  @override
  Widget build(BuildContext context) {
    // 사용자 ID (실제로는 인증 상태에서 가져와야 함)
    final userId = "51be03ed-22aa-4ea9-9064-328252867430"; // 임시 사용자 ID
    
    // 현재 월의 지출 목록 가져오기
    final currentMonthExpenses = ref.watch(dateRangeExpensesProvider((
      start: _monthStart,
      end: _monthEnd,
      userId: userId,
    )));
    
    // 현재 월의 수입 목록 가져오기
    final currentMonthIncomes = ref.watch(dateRangeIncomesProvider((
      start: _monthStart,
      end: _monthEnd,
      userId: userId,
    )));
    
    // 카테고리 정보 가져오기
    final categoriesState = ref.watch(categoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildMonthSelector(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // 프로필 화면으로 이동
            },
          ),
        ],
      ),
      body: categoriesState.when(
        data: (categories) {
          return RefreshIndicator(
            onRefresh: () async {
              // 데이터 새로고침
              await ref.read(expenseProvider.notifier).loadExpenses();
              await ref.read(incomeProvider.notifier).loadIncomes();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFinancialSummary(currentMonthExpenses, currentMonthIncomes),
                    SizedBox(height: 20),
                    _buildExpenseIncomeChart(currentMonthExpenses, currentMonthIncomes),
                    SizedBox(height: 20),
                    _buildCategoryExpenseChart(currentMonthExpenses, categories),
                    SizedBox(height: 20),
                    _buildRecentTransactions(currentMonthExpenses, categories),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // 탭에 따른 화면 이동
          switch (index) {
            case 0:
              // 이미 홈 화면
              break;
            case 1:
              // 지출 목록 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenseListScreen()),
              );
              break;
            case 2:
              // 통계 화면으로 이동 (별도 구현 필요)
              break;
            case 3:
              // 설정 화면으로 이동 (별도 구현 필요)
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '지출 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: Icon(Icons.add),
        tooltip: '추가하기',
      ),
    );
  }

  Widget _buildMonthSelector() {
    return GestureDetector(
      onTap: () => _selectMonth(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('yyyy년 MM월').format(_selectedMonth),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary(List<Expense> expenses, List<Income> incomes) {
    final totalExpense = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalIncome = incomes.fold<double>(0, (sum, income) => sum + income.amount);
    final balance = totalIncome - totalExpense;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 달 재정 요약',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    label: '수입',
                    amount: totalIncome,
                    color: Colors.green,
                    icon: Icons.arrow_downward,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    label: '지출',
                    amount: totalExpense,
                    color: Colors.red,
                    icon: Icons.arrow_upward,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    label: '잔액',
                    amount: balance,
                    color: balance >= 0 ? Colors.blue : Colors.red,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          currencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseIncomeChart(List<Expense> expenses, List<Income> incomes) {
    // 일별 데이터 준비
    final Map<int, double> dailyExpenses = {};
    final Map<int, double> dailyIncomes = {};
    
    // 이번 달의 일수
    final daysInMonth = _monthEnd.day;
    
    // 초기화
    for (int i = 1; i <= daysInMonth; i++) {
      dailyExpenses[i] = 0;
      dailyIncomes[i] = 0;
    }
    
    // 일별 지출 합계
    for (var expense in expenses) {
      final day = expense.date.day;
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + expense.amount;
    }
    
    // 일별 수입 합계
    for (var income in incomes) {
      final day = income.date.day;
      dailyIncomes[day] = (dailyIncomes[day] ?? 0) + income.amount;
    }
    
    // 차트에 표시할 최대 일수 (화면 공간 제약으로 일부만 표시)
    final displayDays = 15;
    final startDay = max(1, daysInMonth - displayDays + 1);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '수입/지출 추이',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff68737d),
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        final day = value.toInt();
                        return day % 5 == 0 || day == 1 || day == daysInMonth ? '$day일' : '';
                      },
                      margin: 8,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTextStyles: (context, value) => const TextStyle(
                        color: Color(0xff68737d),
                        fontSize: 12,
                      ),
                      getTitles: (value) {
                        if (value == 0) return '0';
                        
                        // 단위 간소화 (예: 100000 -> 10만)
                        if (value >= 10000) {
                          return '${(value / 10000).toStringAsFixed(0)}만';
                        }
                        return value.toInt().toString();
                      },
                      margin: 8,
                    ),
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: startDay.toDouble(),
                  maxX: daysInMonth.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    // 지출 선
                    LineChartBarData(
                      spots: [
                        for (int i = startDay; i <= daysInMonth; i++)
                          FlSpot(i.toDouble(), dailyExpenses[i] ?? 0),
                      ],
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.red.withOpacity(0.2)],
                      ),
                    ),
                    // 수입 선
                    LineChartBarData(
                      spots: [
                        for (int i = startDay; i <= daysInMonth; i++)
                          FlSpot(i.toDouble(), dailyIncomes[i] ?? 0),
                      ],
                      isCurved: true,
                      colors: [Colors.green],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.green.withOpacity(0.2)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend(color: Colors.green, label: '수입'),
                SizedBox(width: 24),
                _buildChartLegend(color: Colors.red, label: '지출'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildCategoryExpenseChart(List<Expense> expenses, List<Category> categories) {
    // 카테고리별 지출 합계 계산
    final Map<String, double> categoryExpenses = {};
    double totalExpense = 0;
    
    for (var expense in expenses) {
      categoryExpenses[expense.categoryId] = (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
      totalExpense += expense.amount;
    }
    
    // 상위 5개 카테고리만 표시 (나머지는 '기타'로 통합)
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top5Categories = sortedCategories.take(5).toList();
    
    // 기타 카테고리 계산
    double otherCategoriesTotal = 0;
    if (sortedCategories.length > 5) {
      for (int i = 5; i < sortedCategories.length; i++) {
        otherCategoriesTotal += sortedCategories[i].value;
      }
    }
    
    // 파이 차트 데이터 생성
    final List<PieChartSectionData> pieChartData = [];
    
    for (var entry in top5Categories) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: 'unknown',
          name: '기타',
          icon: 'more_horiz',
          color: '#757575',
          userId: 'default',
          createdAt: DateTime.now(),
        ),
      );
      
      final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
      final percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
      
      pieChartData.add(PieChartSectionData(
        color: categoryColor,
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    // 기타 카테고리 추가
    if (otherCategoriesTotal > 0) {
      final percentage = (otherCategoriesTotal / totalExpense) * 100;
      pieChartData.add(PieChartSectionData(
        color: Colors.grey,
        value: otherCategoriesTotal,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 지출',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (totalExpense == 0)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '이번 달 지출 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieChartData,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildCategoryLegend(top5Categories, categories, otherCategoriesTotal),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(
    List<MapEntry<String, double>> topCategories,
    List<Category> categories,
    double otherCategoriesTotal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상위 카테고리 범례
        ...topCategories.map((entry) {
          final category = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => Category(
              id: 'unknown',
              name: '기타',
              icon: 'more_horiz',
              color: '#757575',
              userId: 'default',
              createdAt: DateTime.now(),
            ),
          );
          
          final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
          
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        // 기타 카테고리 범례
        if (otherCategoriesTotal > 0)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text('기타'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentTransactions(List<Expense> expenses, List<Category> categories) {
    // 최근 순으로 정렬
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    // 최대 5개까지만 표시
    final recentExpenses = sortedExpenses.take(5).toList();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 지출',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpenseListScreen()),
                    );
                  },
                  child: Text('더보기'),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (recentExpenses.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '이번 달 지출 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentExpenses.map((expense) {
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
                  title: Text(expense.description),
                  subtitle: Text(DateFormat('MM/dd').format(expense.date)),
                  trailing: Text(
                    currencyFormatter.format(expense.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  onTap: () {
                    // 지출 상세 화면으로 이동
                    Navigator.pushNamed(
                      context,
                      '/expense-detail',
                      arguments: expense.id,
                    );
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  void _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      locale: Locale('ko', 'KR'),
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '추가하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAddButton(
                    icon: Icons.arrow_upward,
                    label: '지출',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                      );
                    },
                  ),
                  _buildAddButton(
                    icon: Icons.arrow_downward,
                    label: '수입',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      // 수입 추가 화면으로 이동 (별도 구현 필요)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddIncomeScreen()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 두 수 중 큰 값 반환하는 헬퍼 함수
  int max(int a, int b) {
    return a > b ? a : b;
  }
}