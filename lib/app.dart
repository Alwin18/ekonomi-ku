import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/view/login_page.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/bloc/dashboard_event.dart';
import 'features/dashboard/view/dashboard_page.dart';
import 'features/expense/view/expense_page.dart';
import 'features/income/view/income_page.dart';
import 'features/loan/view/loan_page.dart';

/// Root widget that wraps everything in MaterialApp with auth gate.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekonomi-Ku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const _MainShell();
          }
          // Show login for initial, unauthenticated, loading, and error states
          return const LoginPage();
        },
      ),
    );
  }
}

/// The main navigation shell shown after login.
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    IncomePage(),
    ExpensePage(),
    LoanPage(),
  ];

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);

    // Refresh dashboard when navigating back to it
    if (index == 0) {
      context.read<DashboardBloc>().add(const RefreshDashboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward_outlined),
            activeIcon: Icon(Icons.arrow_downward),
            label: 'Pemasukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward_outlined),
            activeIcon: Icon(Icons.arrow_upward),
            label: 'Pengeluaran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_outlined),
            activeIcon: Icon(Icons.handshake),
            label: 'Pinjaman',
          ),
        ],
      ),
    );
  }
}
