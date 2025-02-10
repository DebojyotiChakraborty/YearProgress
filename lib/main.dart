import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

void main() {
  runApp(const YearProgressApp());
}

class YearProgressApp extends StatelessWidget {
  const YearProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Year Progress',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemGreen,
        brightness: Brightness.light,
      ),
      home: const YearProgressPage(),
    );
  }
}

class YearProgressPage extends StatelessWidget {
  const YearProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Year Progress'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: YearProgressCard(),
        ),
      ),
    );
  }
}

class YearProgressCard extends StatelessWidget {
  YearProgressCard({super.key});

  final DateTime now = DateTime.now();
  static const platform = MethodChannel('com.debojyoti.year_progress/widget');

  Future<void> _updateWidgetData() async {
    try {
      await platform.invokeMethod('updateWidgetData');
    } on PlatformException catch (e) {
      print("Failed to update widget data: '${e.message}'.");
    }
  }

  double calculateYearProgress() {
    final startOfYear = DateTime(now.year);
    final endOfYear = DateTime(now.year + 1);
    final totalDays = endOfYear.difference(startOfYear).inSeconds;
    final daysPassed = now.difference(startOfYear).inSeconds;
    return (daysPassed / totalDays) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final progress = calculateYearProgress();
    final progressInt = progress.round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  Text(
                    'Date    ${DateFormat('dd\'th\' MMMM yyyy').format(now)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.systemGrey6,
                ),
                child: Center(
                  child: Text(
                    '$progressInt%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProgressBar(progress: progress / 100),
          const SizedBox(height: 10),
          Text(
            '${now.year} is ${progress.toStringAsFixed(3)}% complete',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _updateWidgetData,
              child: const Text('Add to Homescreen'),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final itemCount = 35;
        final itemWidth = totalWidth / itemCount;
        final completedItems = (progress * itemCount).floor();

        return SizedBox(
          height: 8,
          child: Row(
            children: List.generate(itemCount, (index) {
              return Container(
                width: itemWidth - 2,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: index < completedItems
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final strokeWidth = 4.0;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
