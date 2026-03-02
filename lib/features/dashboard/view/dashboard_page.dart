import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../models/dashboard_model.dart';
import 'widgets/summary_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekonomi-Ku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardBloc>().add(const RefreshDashboard()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _onLogout,
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Text(
                    'Gagal memuat dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: () => context.read<DashboardBloc>().add(
                      const LoadDashboard(),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return _buildDashboard(state.summary);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(DashboardSummary summary) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboard());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withAlpha(77),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Saat Ini',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    CurrencyFormatter.formatRupiah(summary.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Per ${DateFormatter.formatDisplay(DateTime.now())}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Summary cards grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppConstants.spacingMd,
              mainAxisSpacing: AppConstants.spacingMd,
              childAspectRatio: 1.4,
              children: [
                SummaryCard(
                  title: 'Total Pemasukan',
                  value: CurrencyFormatter.formatRupiah(summary.totalIncome),
                  icon: Icons.arrow_downward,
                  color: AppConstants.incomeColor,
                ),
                SummaryCard(
                  title: 'Total Pengeluaran',
                  value: CurrencyFormatter.formatRupiah(summary.totalExpense),
                  icon: Icons.arrow_upward,
                  color: AppConstants.expenseColor,
                ),
                SummaryCard(
                  title: 'Pinjaman Aktif',
                  value: CurrencyFormatter.formatRupiah(
                    summary.totalActiveLoan,
                  ),
                  icon: Icons.schedule,
                  color: AppConstants.loanColor,
                  subtitle: '${summary.activeLoanCount} pinjaman',
                ),
                SummaryCard(
                  title: 'Saldo Bersih',
                  value: CurrencyFormatter.formatRupiah(summary.balance),
                  icon: Icons.account_balance_wallet,
                  color: AppConstants.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Chart section
            const Text(
              'Pemasukan vs Pengeluaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              '6 bulan terakhir',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            Container(
              height: 220,
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildBarChart(summary.monthlyData),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend('Pemasukan', AppConstants.incomeColor),
                const SizedBox(width: AppConstants.spacingLg),
                _buildLegend('Pengeluaran', AppConstants.expenseColor),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<MonthlyData> monthlyData) {
    final maxY = monthlyData.fold<double>(0, (max, d) {
      final localMax = d.totalIncome > d.totalExpense
          ? d.totalIncome
          : d.totalExpense;
      return localMax > max ? localMax : max;
    });

    final interval = maxY > 0 ? (maxY / 4).ceilToDouble() : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.2 : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = rodIndex == 0 ? 'Pemasukan' : 'Pengeluaran';
              return BarTooltipItem(
                '$label\n${CurrencyFormatter.formatRupiah(rod.toY)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < monthlyData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormatter.formatShortMonth(monthlyData[idx].month),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: interval,
              getTitlesWidget: (value, meta) {
                return Text(
                  CurrencyFormatter.formatCompact(value),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(monthlyData.length, (index) {
          final data = monthlyData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.totalIncome,
                color: AppConstants.incomeColor,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: data.totalExpense,
                color: AppConstants.expenseColor,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
