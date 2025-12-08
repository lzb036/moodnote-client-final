import 'package:flutter/material.dart';

class DiaryListPage extends StatelessWidget {
  const DiaryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("列表视图"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("这里是日记列表视图 (空白)"),
      ),
    );
  }
}