import 'package:flutter/material.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.pie_chart, size: 64, color: Colors.orange),
          SizedBox(height: 20),
          Text(
            '【情绪洞察】',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('TODO: 情绪日历 (GitHub风格)', style: TextStyle(color: Colors.grey)),
          Text('TODO: 情绪变化趋势折线图', style: TextStyle(color: Colors.grey)),
          Text('TODO: 高频关键词云', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}