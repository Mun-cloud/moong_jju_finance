import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart' as riverpod;
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/expense_detail_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/edit_expense_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일에서 Supabase 키 로드
  await dotenv.load();

  // Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

// Supabase 클라이언트 전역 참조
final supabase = Supabase.instance.client;

// Supabase 클라이언트 Provider 정의
final supabaseProvider = riverpod.Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// 라우터 설정
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpenseListScreen(),
    ),
    GoRoute(
      path: '/expenses/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/expenses/:id',
      builder: (context, state) => ExpenseDetailScreen(
        expenseId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/expenses/:id/edit',
      builder: (context, state) => EditExpenseScreen(
        expenseId: state.pathParameters['id']!,
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '가계부 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
