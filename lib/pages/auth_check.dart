import 'package:flutter/material.dart';
import '../main.dart';
import 'welcome.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {

  // ============================================
  // 【测试开关】修改这里来测试不同流程
  // true  -> 直接进主页 (MainPage)
  // false -> 进欢迎页 (WelcomePage)
  // ============================================
  final bool isUserLoggedIn = true;

  @override
  void initState() {
    super.initState();
    // 执行检查逻辑
    _checkAuthStatus();
  }

  // 模拟一个检查过程
  void _checkAuthStatus() async {
    // 这里加一个微小的延迟（比如 0 毫秒或几百毫秒）
    // 作用：防止页面还没渲染完就跳转导致报错，同时也预留了读取本地存储的时间
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return; // 确保页面还在

    // 根据布尔值决定去哪里
    if (isUserLoggedIn) {
      // 如果是真：跳转到主页 (MainPage)
      // 使用 pushReplacement 删除当前页，防止用户按返回键回到这个空白页
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      // 如果是假：跳转到欢迎页 (WelcomePage)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 在检查期间，显示一个白屏，或者一个加载圈
    // 这里我们保持白屏，用户体感就是一点开APP直接到了目标页面
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // 如果你需要，可以在这里放一个 CircularProgressIndicator()
      ),
    );
  }
}