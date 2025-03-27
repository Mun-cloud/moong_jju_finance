// lib/screens/edit_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final String expenseId;
  
  const EditExpenseScreen({
    Key? key,
    required this.expenseId,
  }) : super(key: key);

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  
  String? _selectedCategoryId;
  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Expense? _expense;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenseData();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  Future<void> _loadExpenseData() async {
    final expensesState = ref.read(expenseProvider);
    
    if (expensesState is AsyncData) {
      final expenses = expensesState.value;
      final expense = expenses.firstWhere(
        (e) => e.id == widget.expenseId,
        orElse: () => null as Expense,
      );
      
      if (expense != null) {
        setState(() {
          _expense = expense;
          _descriptionController.text = expense.description;
          _amountController.text = expense.amount.toString();
          _selectedCategoryId = expense.categoryId;
          _selectedDate = expense.date;
          _isLoading = false;
        });
      } else {
        // 지출을 찾지 못한 경우
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지출 정보를 찾을 수 없습니다')),
        );
        
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리 목록 가져오기
    final categoriesState = ref.watch(categoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('지출 수정'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : categoriesState.when(
              data: (categories) => _buildForm(categories),
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('카테고리를 불러오는 중 오류가 발생했습니다: $error'),
              ),
            ),
    );
  }

  Widget _buildForm(List<Category> categories) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 금액 입력 필드
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: '금액',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '금액을 입력해주세요';
                }
                if (double.tryParse(value) == null) {
                  return '유효한 숫자를 입력해주세요';
                }
                if (double.parse(value) <= 0) {
                  return '0보다 큰 금액을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // 설명 입력 필드
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '설명',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '설명을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            
            // 날짜 선택
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '날짜',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate!),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // 카테고리 선택
            Text(
              '카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildCategorySelector(categories),
            SizedBox(height: 24),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _updateExpense(context),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('변경사항 저장', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == _selectedCategoryId;
          final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = category.id;
              });
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? categoryColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? categoryColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor,
                    radius: 22,
                    child: Icon(
                      IconData(
                        int.parse('0xe${category.icon}', radix: 16),
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
      locale: Locale('ko', 'KR'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateExpense(BuildContext context) async {
    if (_formKey.currentState!.validate() &&
        _selectedCategoryId != null &&
        _expense != null) {
      try {
        setState(() {
          _isSubmitting = true;
        });
        
        // 수정된 지출 생성
        final updatedExpense = Expense(
          id: _expense!.id,
          amount: double.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          date: _selectedDate!,
          categoryId: _selectedCategoryId!,
          userId: _expense!.userId,
          createdAt: _expense!.createdAt,
        );
        
        // 지출 업데이트
        await ref.read(expenseProvider.notifier).updateExpense(updatedExpense);
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('지출이 수정되었습니다')),
        );
        
        // 이전 화면으로 돌아가기
        Navigator.pop(context, true);
      } catch (e) {
        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}