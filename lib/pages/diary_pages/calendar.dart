import 'package:flutter/material.dart';

class DiaryCalendarPage extends StatelessWidget {
  const DiaryCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("日历视图"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("这里是日历视图 (空白)"),
      ),
    );
  }
}