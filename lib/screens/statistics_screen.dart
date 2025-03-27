// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../widgets/statistics/expense_analysis_tab.dart';
import '../widgets/statistics/income_analysis_tab.dart';
import '../widgets/statistics/budget_status_tab.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> with SingleTickerProviderStateMixin {
  // 탭 컨트롤러
  late TabController _tabController;
  
  // 선택된 기간 타입 (월간, 연간)
  String _periodType = '월간';
  
  // 선택된 날짜
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 선택된 기간의 시작일
  DateTime get _periodStart {
    if (_periodType == '월간') {
      return DateTime(_selectedDate.year, _selectedDate.month, 1);
    } else { // 연간
      return DateTime(_selectedDate.year, 1, 1);
    }
  }
  
  // 선택된 기간의 종료일
  DateTime get _periodEnd {
    if (_periodType == '월간') {
      return DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    } else { // 연간
      return DateTime(_selectedDate.year, 12, 31);
    }
  }

  void _selectPeriod(BuildContext context) async {
    if (_periodType == '월간') {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDatePickerMode: DatePickerMode.year,
      );
      
      if (picked != null) {
        setState(() {
          _selectedDate = DateTime(picked.year, picked.month);
        });
      }
    } else { // 연간
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('년도 선택'),
            content: Container(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                selectedDate: _selectedDate,
                onChanged: (DateTime dateTime) {
                  setState(() {
                    _selectedDate = dateTime;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 사용자 ID (실제로는 인증 상태에서 가져와야 함)
    final userId = "51be03ed-22aa-4ea9-9064-328252867430"; // 임시 사용자 ID
    
    // 선택된 기간의 지출 목록 가져오기
    final periodExpenses = ref.watch(dateRangeExpensesProvider((
      start: _periodStart,
      end: _periodEnd,
      userId: userId,
    )));
    
    // 선택된 기간의 수입 목록 가져오기
    final periodIncomes = ref.watch(dateRangeIncomesProvider((
      start: _periodStart,
      end: _periodEnd,
      userId: userId,
    )));
    
    // 카테고리 정보 가져오기
    final categoriesState = ref.watch(categoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('통계'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '지출 분석'),
            Tab(text: '수입 분석'),
            Tab(text: '예산 현황'),
          ],
        ),
        actions: [
          // 기간 타입 선택 드롭다운
          DropdownButton<String>(
            value: _periodType,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            style: TextStyle(color: Colors.white),
            dropdownColor: Theme.of(context).primaryColor,
            underline: Container(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _periodType = newValue;
                });
              }
            },
            items: <String>['월간', '연간']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: categoriesState.when(
        data: (categories) {
          return TabBarView(
            controller: _tabController,
            children: [
              // 지출 분석 탭
              ExpenseAnalysisTab(
                expenses: periodExpenses,
                categories: categories,
                periodType: _periodType,
                selectedDate: _selectedDate,
                onPrevPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year - 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onNextPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year + 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onSelectPeriod: () => _selectPeriod(context),
              ),
              
              // 수입 분석 탭
              IncomeAnalysisTab(
                incomes: periodIncomes,
                periodType: _periodType,
                selectedDate: _selectedDate,
                onPrevPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year - 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onNextPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year + 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onSelectPeriod: () => _selectPeriod(context),
              ),
              
              // 예산 현황 탭
              BudgetStatusTab(
                expenses: periodExpenses,
                categories: categories,
                periodType: _periodType,
                selectedDate: _selectedDate,
                onPrevPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year - 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onNextPeriod: () {
                  setState(() {
                    if (_periodType == '월간') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                      );
                    } else { // 연간
                      _selectedDate = DateTime(
                        _selectedDate.year + 1,
                        _selectedDate.month,
                      );
                    }
                  });
                },
                onSelectPeriod: () => _selectPeriod(context),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('데이터를 불러오는 중 오류가 발생했습니다: $error'),
        ),
      ),
    );
  }
}