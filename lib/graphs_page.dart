import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import './auth.dart';
import './settings_service.dart';
import 'package:intl/intl.dart';

class GraphsPage extends StatefulWidget {
  const GraphsPage({super.key, required this.user});

  final GoogleSignInAccount user;

  @override
  State<GraphsPage> createState() => _GraphsPageState();
}

class _GraphsPageState extends State<GraphsPage> {
  List<List<dynamic>> _workoutData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

  Future<void> _fetchWorkoutData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiUrl = await SettingsService().getApiUrl();
      if (apiUrl.isEmpty) {
        throw Exception('API URL not configured. Please set it in Settings.');
      }

      final authorization = await _getAccessToken(widget.user);
      final Uri uri = Uri.parse(apiUrl);
      var headers = {
        if (authorization != null) 'Authorization': "Bearer $authorization",
        'Content-Type': 'application/json',
      };
      var body = json.encode({
        "function": "getAllBodyCompositionEntries",
        "parameters": [],
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['done'] == true && data['response'] != null) {
          setState(() {
            List<String> inter = data['response']['result'].toString().split(
              "@#@",
            );
            _workoutData = List<List<dynamic>>.from(
              inter.map((e) => e.split("|&")),
            );
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to parse workout data');
        }
      } else {
        throw Exception(
          'Failed to fetch workout data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<String?> _getAccessToken(
    GoogleSignInAccount? googleSignInAccount,
  ) async {
    if (googleSignInAccount == null) {
      return null;
    }
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    return googleSignInAuthentication.accessToken;
  }

  List<FlSpot> _createDataPoints(int dataIndex, String label) {
    final spots = <FlSpot>[];
    for (int i = 0; i < _workoutData.length; i++) {
      final row = _workoutData[i];
      if (row.isEmpty || row[0] == null || row[0] == "") continue;
      if (row.length > dataIndex && row[dataIndex] != null) {
        final value = double.tryParse(row[dataIndex].toString());
        if (value != null) {
          double x = _workoutData.length == 1
              ? 0
              : i / (_workoutData.length - 1);
          spots.add(FlSpot(x, value));
        }
      }
    }
    return spots;
  }

  List<String> _getDateLabels() {
    return _workoutData.map((row) {
      if (row.isNotEmpty && row[0] != null) {
        return row[0].toString();
      }
      return '';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Progress Charts'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: scheme.onSurfaceVariant),
            onPressed: _fetchWorkoutData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _workoutData.isEmpty
          ? _buildEmptyWidget()
          : _buildCharts(),
    );
  }

  Widget _buildErrorWidget() {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: scheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: scheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchWorkoutData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some workout entries to see your progress charts',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            'Body Weight Progress',
            'Weight (kg)',
            _createDataPoints(1, 'Bodyweight'),
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Skeletal Muscle Mass',
            'Mass (kg)',
            _createDataPoints(2, 'SkeletalMass'),
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Fat Mass Progress',
            'Mass (kg)',
            _createDataPoints(3, 'FatMass'),
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Body Water',
            'Water (kg)',
            _createDataPoints(4, 'BodyWater'),
            Colors.cyan,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Fat Percentage',
            'Percentage (%)',
            _createDataPoints(5, 'FatPercent'),
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'BMR Progress',
            'BMR (kcal)',
            _createDataPoints(6, 'BMR'),
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Energy Expenditure',
            'Energy (kcal)',
            _createDataPoints(7, 'Energy'),
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Average Heart Rate',
            'Heart Rate (bpm)',
            _createDataPoints(8, 'AvgHeartRate'),
            Colors.pink,
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Maximum Heart Rate',
            'Heart Rate (bpm)',
            _createDataPoints(9, 'MaxHeartRate'),
            Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    String title,
    String yAxisLabel,
    List<FlSpot> dataPoints,
    Color color,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (dataPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 5,
                    verticalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: scheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: scheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = (_workoutData.length == 1)
                              ? 0
                              : (value * (_workoutData.length - 1)).round();
                          if (index < _getDateLabels().length) {
                            final date = _getDateLabels()[value.toInt()];
                            String formattedDate = "";
                            if (date != "") {
                              DateTime dateTime = DateFormat(
                                "EEE MMM dd yyyy HH:mm:ss 'GMT'Z",
                                "en_US",
                              ).parse(date.split(' (').first).toLocal();
                              formattedDate =
                                  "${dateTime.day.toString()}-${dateTime.month.toString()}";
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 7,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  minX: 0,
                  maxX: 1,
                  minY:
                      dataPoints
                          .map((e) => e.y)
                          .reduce((a, b) => a < b ? a : b) *
                      0.95,
                  maxY:
                      dataPoints
                          .map((e) => e.y)
                          .reduce((a, b) => a > b ? a : b) *
                      1.05,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.8), color],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: scheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              yAxisLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
