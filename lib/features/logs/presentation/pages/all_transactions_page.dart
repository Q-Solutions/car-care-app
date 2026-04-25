import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../injection.dart';
import '../bloc/dashboard_bloc.dart';
import 'transaction_detail_page.dart';

class AllTransactionsPage extends StatelessWidget {
  const AllTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.backgroundDark,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.loading) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
              }

              if (state.allLogs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: Colors.grey[800], size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No history yet',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Log your first expense to see it here.',
                          style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Grouping logic
              final Map<String, List<DashboardLogItem>> groupedLogs = {};
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final yesterday = today.subtract(const Duration(days: 1));

              for (var log in state.allLogs) {
                final logDate = DateTime(log.date.year, log.date.month, log.date.day);
                String label;
                if (logDate == today) {
                  label = 'Today';
                } else if (logDate == yesterday) {
                  label = 'Yesterday';
                } else {
                  label = DateFormat('MMMM yyyy').format(logDate);
                }

                if (!groupedLogs.containsKey(label)) {
                  groupedLogs[label] = [];
                }
                groupedLogs[label]!.add(log);
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final key = groupedLogs.keys.elementAt(index);
                      final logs = groupedLogs[key]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                            child: Text(
                              key,
                              style: GoogleFonts.outfit(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ...logs.map((log) => _buildTransactionCard(context, log)).toList(),
                        ],
                      );
                    },
                    childCount: groupedLogs.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, DashboardLogItem log) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailPage(logItem: log)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (log.type == LogType.fuel ? Colors.blue : Colors.orange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                log.type == LogType.fuel ? Icons.local_gas_station : Icons.build,
                color: log.type == LogType.fuel ? Colors.blue : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.title,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.subtitle,
                    style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: getIt<SettingsService>().currency, decimalDigits: 0).format(log.amount),
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(log.date),
                  style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
