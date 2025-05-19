import 'package:flutter/material.dart';
import 'package:rtm/Model/VisitStats.dart';
import 'package:rtm/Services/ApiService.dart';
import 'package:rtm/Services/auth_service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;

  VisitStats? _visitStats;
  // List<RepPerformance> _repPerformance = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _fetchVisitStats();

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load statistics: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVisitStats() async {
    try {
      final stats = await _apiService.fetchVisitStats();
      setState(() {
        _visitStats = stats;
      });
    } catch (e) {
      throw Exception('Failed to fetch visit stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Visit Statistics'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVisitStatsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStats,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Statistics',
      ),
    );
  }

  Widget _buildVisitStatsTab() {
    if (_visitStats == null) {
      return const Center(child: Text('No statistics available'));
    }

    final total = _visitStats!.totalVisits;
    final double completedPercentage = total > 0 ? (_visitStats!.completedVisits / total) * 100 : 0;
    final double pendingPercentage = total > 0 ? (_visitStats!.pendingVisits / total) * 100 : 0;
    final double cancelledPercentage = total > 0 ? (_visitStats!.cancelledVisits / total) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insert_chart, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Visit Overview',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive layout - show stats in a row if enough space, otherwise column
                      if (constraints.maxWidth > 600) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Total', _visitStats!.totalVisits.toString(),
                                Colors.blue, Icons.calendar_today),
                            _buildStatCard('Completed', _visitStats!.completedVisits.toString(),
                                Colors.green, Icons.check_circle),
                            _buildStatCard('Pending', _visitStats!.pendingVisits.toString(),
                                Colors.orange, Icons.pending),
                            _buildStatCard('Cancelled', _visitStats!.cancelledVisits.toString(),
                                Colors.red, Icons.cancel),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard('Total', _visitStats!.totalVisits.toString(),
                                    Colors.blue, Icons.calendar_today),
                                _buildStatCard('Completed', _visitStats!.completedVisits.toString(),
                                    Colors.green, Icons.check_circle),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard('Pending', _visitStats!.pendingVisits.toString(),
                                    Colors.orange, Icons.pending),
                                _buildStatCard('Cancelled', _visitStats!.cancelledVisits.toString(),
                                    Colors.red, Icons.cancel),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Visit Status Distribution',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _visitStats!.totalVisits > 0
                        ? PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: _visitStats!.completedVisits.toDouble(),
                            title: '${completedPercentage.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: _visitStats!.pendingVisits.toDouble(),
                            title: '${pendingPercentage.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: _visitStats!.cancelledVisits.toDouble(),
                            title: '${cancelledPercentage.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                      ),
                    )
                        : const Center(child: Text('No visit data available')),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Completed', Colors.green),
                      const SizedBox(width: 20),
                      _buildLegendItem('Pending', Colors.orange),
                      const SizedBox(width: 20),
                      _buildLegendItem('Cancelled', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_visitStats!.visitsByCustomer.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Top Customers by Visits',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    ...(_visitStats!.visitsByCustomer.entries
                        .toList()
                      ..sort((a, b) => b.value.compareTo(a.value))
                    ).take(5).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              child: Text(
                                entry.key.substring(entry.key.length - 1),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value} visits',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildRepPerformanceTab() {
  //   if (_repPerformance.isEmpty) {
  //     return const Center(child: Text('No performance data available'));
  //   }
  //
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: _repPerformance.length,
  //     itemBuilder: (context, index) {
  //       final rep = _repPerformance[index];
  //       final completionRate = rep.totalVisits > 0
  //           ? (rep.completedVisits / rep.totalVisits) * 100
  //           : 0;
  //
  //       return Card(
  //         margin: const EdgeInsets.only(bottom: 16),
  //         elevation: 4,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   CircleAvatar(
  //                     backgroundColor: Theme.of(context).primaryColor,
  //                     child: const Icon(Icons.person, color: Colors.white),
  //                   ),
  //                   const SizedBox(width: 16),
  //                   Expanded(
  //                     child: Text(
  //                       rep.name,
  //                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                     decoration: BoxDecoration(
  //                       color: completionRate > 75
  //                           ? Colors.green.withOpacity(0.2)
  //                           : completionRate > 50
  //                           ? Colors.orange.withOpacity(0.2)
  //                           : Colors.red.withOpacity(0.2),
  //                       borderRadius: BorderRadius.circular(16),
  //                     ),
  //                     child: Text(
  //                       '${completionRate.toStringAsFixed(1)}%',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: completionRate > 75
  //                             ? Colors.green
  //                             : completionRate > 50
  //                             ? Colors.orange
  //                             : Colors.red,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               Container(
  //                 height: 10,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(5),
  //                   color: Colors.grey.shade200,
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Flexible(
  //                       flex: rep.completedVisits,
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(5),
  //                           color: Colors.green,
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       flex: rep.pendingVisits,
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           color: Colors.orange,
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       flex: rep.cancelledVisits,
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.circular(5),
  //                           color: Colors.red,
  //                         ),
  //                       ),
  //                     ),
  //                     Flexible(
  //                       flex: rep.totalVisits - (rep.completedVisits + rep.pendingVisits + rep.cancelledVisits),
  //                       child: Container(),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade100,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     _buildPerformanceStat('Total', rep.totalVisits.toString()),
  //                     _buildPerformanceStat('Completed', rep.completedVisits.toString()),
  //                     _buildPerformanceStat('Pending', rep.pendingVisits.toString()),
  //                     _buildPerformanceStat('Cancelled', rep.cancelledVisits.toString()),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget _buildPerformanceStat(String label, String value) {
  //   return Column(
  //     children: [
  //       Text(
  //         value,
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       Text(
  //         label,
  //         style: const TextStyle(fontSize: 12, color: Colors.grey),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}