import 'package:flutter/material.dart';

class DiaryTagPage extends StatelessWidget {
  const DiaryTagPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("标签视图"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("这里是标签视图 (空白)"),
      ),
    );
  }
}