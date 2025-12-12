import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart'; // 引入欢迎页(或登录页)

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  // --- 退出登录逻辑 ---
  Future<void> _handleLogout(BuildContext context) async {
    // 1. 获取实例
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ▼▼▼ 修改点：不要用 clear()，而是精准移除 Session 数据 ▼▼▼

    // 移除当前的会话 Token 和状态
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('is_logged_in');

    // 如果你之前存了当前登录的 username (不是 saved_username)，也要移除
    // 注意区分：'username' 是当前登录的，'saved_username' 是记住密码用的
    await prefs.remove('username');

    // ★★★ 关键：下面这些 key 不要删，保留下来供下次自动填充 ★★★
    // 'remember_me'
    // 'saved_username'
    // 'saved_password'

    print("用户已退出，Token已清除，但保留了记住的账号密码");

    if (!context.mounted) return;

    // 3. 跳转回欢迎页/登录页，并清空路由栈
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text(
            '【个人中心】',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('TODO: 用户信息与头像', style: TextStyle(color: Colors.grey)),
          const Text('TODO: 个人成就馆 (高光时刻)', style: TextStyle(color: Colors.grey)),
          const Text('TODO: 系统设置', style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 50),

          // 退出登录按钮
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '退出登录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}