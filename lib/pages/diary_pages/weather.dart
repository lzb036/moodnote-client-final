import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("写日记")), // 简单的占位
      body: const Center(child: Text("这里是编辑界面")),
    );
  }
}