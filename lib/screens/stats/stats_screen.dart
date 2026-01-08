import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/stats_provider.dart';
import '../../config/theme.dart';
import '../settings/study_goals_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StatsProvider>().loadStats(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Study Goals',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyGoalsScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, _) {
          if (statsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () => statsProvider.loadStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreakCard(statsProvider),
                    const SizedBox(height: 20),
                    _buildTimeCards(statsProvider),
                    const SizedBox(height: 20),
                    _buildProgressSection(statsProvider),
                    const SizedBox(height: 20),
                    _buildCalendarHeatmap(statsProvider),
                    const SizedBox(height: 20),
                    _buildBadgesSection(statsProvider),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(StatsProvider stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stats.currentStreak > 0 ? Colors.orange : Colors.grey,
            stats.currentStreak > 0 ? Colors.deepOrange : Colors.grey.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (stats.currentStreak > 0 ? Colors.orange : Colors.grey).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Text(
                  stats.currentStreak > 0 ? '🔥' : '💤',
                  style: const TextStyle(fontSize: 60),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreak} Day Streak',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Longest: ${stats.longestStreak} days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCards(StatsProvider stats) {
    return Row(
      children: [
        Expanded(child: _buildTimeCard('Today', stats.dailyMinutes, Icons.today, AppTheme.primaryColor)),
        const SizedBox(width: 12),
        Expanded(child: _buildTimeCard('This Week', stats.weeklyMinutes, Icons.date_range, AppTheme.secondaryColor)),
      ],
    );
  }

  Widget _buildTimeCard(String title, int minutes, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: minutes.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _formatMinutes(value.toInt()),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(StatsProvider stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildProgressRing('Daily', stats.getDailyProgress(), stats.dailyMinutes, stats.dailyGoal, AppTheme.primaryColor)),
            const SizedBox(width: 20),
            Expanded(child: _buildProgressRing('Weekly', stats.getWeeklyProgress(), stats.weeklyMinutes, stats.weeklyGoal, AppTheme.secondaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressRing(String label, double progress, int current, int goal, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(
            '${_formatMinutes(current)} / ${_formatMinutes(goal)}',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap(StatsProvider stats) {
    final now = DateTime.now();

    // Use calendar data from API directly, or generate if empty
    List<Map<String, dynamic>> calendarData;

    if (stats.calendar.isNotEmpty) {
      // Use API data directly - cast to correct type
      calendarData = stats.calendar.map((day) => {
        'date': day['date']?.toString() ?? '',
        'minutes': (day['minutes'] ?? 0) as int,
      }).toList();
    } else {
      // Generate empty calendar if no API data
      calendarData = [];
      DateTime startDate = now.subtract(const Duration(days: 364));
      while (startDate.weekday != DateTime.sunday) {
        startDate = startDate.subtract(const Duration(days: 1));
      }
      DateTime endDate = now;
      while (endDate.weekday != DateTime.saturday) {
        endDate = endDate.add(const Duration(days: 1));
      }
      for (DateTime date = startDate; !date.isAfter(endDate); date = date.add(const Duration(days: 1))) {
        calendarData.add({
          'date': date.toIso8601String().split('T')[0],
          'minutes': 0,
        });
      }
    }

    // Calculate dimensions
    final totalWeeks = (calendarData.length / 7).ceil();
    const double cellSize = 10;
    const double cellSpacing = 2;
    const double gridHeight = (cellSize + cellSpacing) * 7;

    // Count active days
    final activeDays = calendarData.where((d) => (d['minutes'] ?? 0) > 0).length;

    // Calculate total study time
    final totalMinutes = calendarData.fold<int>(0, (sum, d) => sum + ((d['minutes'] ?? 0) as int));
    final totalHours = totalMinutes ~/ 60;

    // Use actual streak from stats
    final currentStreak = stats.currentStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Study Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '$totalHours hrs total • $activeDays active days',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: currentStreak > 0
                    ? AppTheme.successColor.withOpacity(0.15)
                    : AppTheme.textMuted.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: currentStreak > 0 ? AppTheme.successColor : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '$currentStreak day streak',
                    style: TextStyle(
                      fontSize: 12,
                      color: currentStreak > 0 ? AppTheme.successColor : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Calendar Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scrollable calendar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        width: totalWeeks * (cellSize + cellSpacing),
                        height: 14,
                        child: _buildMonthLabels(calendarData, cellSize + cellSpacing),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Grid with day labels
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Day labels
                        Column(
                          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].asMap().entries.map((entry) {
                            final show = entry.key == 1 || entry.key == 3 || entry.key == 5;
                            return SizedBox(
                              height: cellSize + cellSpacing,
                              width: 16,
                              child: Center(
                                child: Text(
                                  show ? entry.value : '',
                                  style: TextStyle(fontSize: 8, color: AppTheme.textMuted),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Heatmap grid
                        SizedBox(
                          width: totalWeeks * (cellSize + cellSpacing),
                          height: gridHeight,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: cellSpacing,
                              mainAxisSpacing: cellSpacing,
                            ),
                            itemCount: calendarData.length,
                            itemBuilder: (context, index) {
                              final day = calendarData[index];
                              final minutes = day['minutes'] ?? 0;
                              final dateStr = day['date'] ?? '';
                              final date = DateTime.tryParse(dateStr);
                              final isFuture = date != null && date.isAfter(now);

                              Color cellColor;
                              if (isFuture) {
                                return const SizedBox();
                              } else if (minutes == 0) {
                                cellColor = const Color(0xFF161B22);
                              } else if (minutes < 30) {
                                cellColor = const Color(0xFF0E4429);
                              } else if (minutes < 60) {
                                cellColor = const Color(0xFF006D32);
                              } else if (minutes < 120) {
                                cellColor = const Color(0xFF26A641);
                              } else {
                                cellColor = const Color(0xFF39D353);
                              }

                              return Tooltip(
                                message: '${_formatFullDate(dateStr)}\n${minutes > 0 ? "${_formatMinutes(minutes)} studied" : "No activity"}',
                                preferBelow: false,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Less', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  const SizedBox(width: 3),
                  ...[
                    const Color(0xFF161B22),
                    const Color(0xFF0E4429),
                    const Color(0xFF006D32),
                    const Color(0xFF26A641),
                    const Color(0xFF39D353),
                  ].map((color) => Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(width: 3),
                  Text('More', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthLabels(List<Map<String, dynamic>> data, double weekWidth) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<Widget> labels = [];
    int? lastMonth;

    for (int week = 0; week < (data.length / 7).ceil(); week++) {
      final dayIndex = week * 7;
      if (dayIndex < data.length) {
        final dateStr = data[dayIndex]['date'];
        if (dateStr != null) {
          final date = DateTime.tryParse(dateStr);
          if (date != null && date.month != lastMonth) {
            labels.add(
              SizedBox(
                width: weekWidth,
                child: Text(
                  monthNames[date.month - 1],
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ),
            );
            lastMonth = date.month;
          } else {
            labels.add(SizedBox(width: weekWidth));
          }
        } else {
          labels.add(SizedBox(width: weekWidth));
        }
      }
    }

    return Row(children: labels);
  }

  String _formatFullDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }



  Widget _buildBadgesSection(StatsProvider stats) {
    final badges = stats.badges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${stats.earnedBadgeCount}/${stats.totalBadgeCount}',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final earned = badge['earned'] == true;
            return GestureDetector(
              onTap: () => _showBadgeDetails(badge),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: earned
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: earned ? AppTheme.primaryColor : Colors.grey.shade300,
                    width: earned ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge['icon'] ?? '🏆',
                      style: TextStyle(
                        fontSize: 28,
                        color: earned ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge['name'] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: earned ? AppTheme.textPrimary : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showBadgeDetails(Map<String, dynamic> badge) {
    final earned = badge['earned'] == true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge['icon'] ?? '🏆', style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              badge['name'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              badge['description'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: earned ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                earned ? '✓ Earned' : 'Locked',
                style: TextStyle(
                  color: earned ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return '${date.day}/${date.month}';
  }
}
