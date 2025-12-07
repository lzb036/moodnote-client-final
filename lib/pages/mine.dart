import 'package:flutter/material.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person, size: 64, color: Colors.blueGrey),
          SizedBox(height: 20),
          Text(
            '【个人中心】',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('TODO: 用户信息与头像', style: TextStyle(color: Colors.grey)),
          Text('TODO: 个人成就馆 (高光时刻)', style: TextStyle(color: Colors.grey)),
          Text('TODO: 系统设置', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}