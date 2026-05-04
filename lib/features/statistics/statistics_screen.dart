import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/statistics_service.dart';
import '../../../models/stats.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedPeriod = 'weekly';
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final statisticsService = ref.read(statisticsServiceProvider);
    await statisticsService.init();
    final summary = await statisticsService.getSummary(_selectedPeriod);
    if (mounted) {
      setState(() {
        _summary = summary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.statistics),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.light
                ? [
                    AppTheme.lightBackground,
                    AppTheme.primaryColor.withOpacity(0.05),
                  ]
                : [
                    AppTheme.darkBackground,
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: 24),

            // Summary Cards
            _buildSummaryCards(),
            const SizedBox(height: 24),

            // Screen Time Chart
            _buildScreenTimeChart(),
            const SizedBox(height: 24),

            // Break Compliance Chart
            _buildBreakComplianceChart(),
            const SizedBox(height: 24),

            // Detailed Stats
            _buildDetailedStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildPeriodButton(AppStrings.daily, 'daily'),
          const SizedBox(width: 8),
          _buildPeriodButton(AppStrings.weekly, 'weekly'),
          const SizedBox(width: 8),
          _buildPeriodButton(AppStrings.monthly, 'monthly'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
            _loadSummary();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final avgScreenTime = _summary['avgScreenTime'] ?? 0;
    final hours = avgScreenTime ~/ 60;
    final minutes = avgScreenTime % 60;
    final screenTimeText = hours > 0 ? '$hours soat $minutes daqiqa' : '$minutes daqiqa';
    
    final compliance = (_summary['breakCompliance'] ?? 0.0) * 100;
    final complianceText = '${compliance.toInt()}%';
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            screenTimeText,
            AppStrings.screenTime,
            Icons.access_time,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            complianceText,
            AppStrings.breakCompliance,
            Icons.check_circle,
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.screenTime,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 120),
                      const FlSpot(1, 180),
                      const FlSpot(2, 150),
                      const FlSpot(3, 200),
                      const FlSpot(4, 160),
                      const FlSpot(5, 90),
                      const FlSpot(6, 140),
                    ],
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakComplianceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.breakCompliance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['D', 'S', 'C', 'P', 'J', 'S', 'Y'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: AppTheme.successColor)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 90, color: AppTheme.successColor)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 70, color: AppTheme.warningColor)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 85, color: AppTheme.successColor)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 95, color: AppTheme.successColor)]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 60, color: AppTheme.errorColor)]),
                  BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 85, color: AppTheme.successColor)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    final totalScreenTime = _summary['totalScreenTime'] ?? 0;
    final totalHours = totalScreenTime ~/ 60;
    final totalMinutes = totalScreenTime % 60;
    final totalScreenTimeText = totalHours > 0 ? '$totalHours soat $totalMinutes daqiqa' : '$totalMinutes daqiqa';
    
    final avgScreenTime = _summary['avgScreenTime'] ?? 0;
    final avgHours = avgScreenTime ~/ 60;
    final avgMinutes = avgScreenTime % 60;
    final avgScreenTimeText = avgHours > 0 ? '$avgHours soat' : '$avgMinutes daqiqa';
    
    final totalBreaks = _summary['totalBreaks'] ?? 0;
    final exerciseScore = _summary['totalExerciseScore'] ?? 0;
    final distanceAlerts = _summary['totalDistanceAlerts'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(AppTheme.glassOpacity),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Batafsil statistika',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Jami ekran vaqti', totalScreenTimeText),
          _buildStatRow('O\'rtacha kunlik', avgScreenTimeText),
          _buildStatRow('Tanaffuslar soni', '$totalBreaks ta'),
          _buildStatRow('Mashqlar balli', '$exerciseScore ball'),
          _buildStatRow('Masofa ogohlantirishlari', '$distanceAlerts ta'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
