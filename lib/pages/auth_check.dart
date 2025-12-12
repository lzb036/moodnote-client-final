import 'package:flutter/material.dart';
import '../main.dart';
import 'welcome.dart';
import '../http/service.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // 执行真正的 Token 检查逻辑
  void _checkAuthStatus() async {
    // 1. 调用 Service 方法，尝试用 Refresh Token 换取新门票
    // 这个过程是异步的，可能会花几百毫秒网络请求时间
    bool isValid = await ApiService.tryRefreshToken();

    if (!mounted) return;

    if (isValid) {
      // 2. 有效 -> 进主页 (MainPage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      // 3. 无效 -> 进欢迎页 (WelcomePage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查期间显示白屏，或者你可以放一个 Logo
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // 可选：加个小菊花，告诉用户正在连接服务器
        // child: CircularProgressIndicator(color: Color(0xFF1A2226)),
      ),
    );
  }
}