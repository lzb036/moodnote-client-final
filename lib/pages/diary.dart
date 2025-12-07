import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.book, size: 64, color: Colors.teal), // 临时图标
          SizedBox(height: 20),
          Text(
            '【日记模块】',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // 这里列出毕设文档中的功能点，作为提醒
          Text('TODO: 时间轴瀑布流展示', style: TextStyle(color: Colors.grey)),
          Text('TODO: 悬浮添加按钮 (Markdown编辑)', style: TextStyle(color: Colors.grey)),
          Text('TODO: 多条件搜索 (标签/情绪)', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}