import 'package:flutter/material.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.explore, size: 64, color: Colors.indigo),
          SizedBox(height: 20),
          Text(
            '【主题星球】',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('TODO: 情感星图 (相似内容聚类)', style: TextStyle(color: Colors.grey)),
          Text('TODO: 星球漫游交互', style: TextStyle(color: Colors.grey)),
          Text('TODO: 匿名共鸣与互动', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}