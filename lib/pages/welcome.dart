import 'dart:async';
import 'package:flutter/material.dart';
import '../http/service.dart'; // 引入 ApiService
import '../main.dart'; // 引入主页

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // 图片轮播相关
  int _currentImageIndex = 0;
  Timer? _animTimer;

  // 控制页面是否显示（防止 Token 检查期间画面闪烁）
  // 初始设为 false，等检查完 Token 如果需要留在这里再设为 true
  // 或者：你可以让它初始就显示，作为一种“加载中”的背景
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // 1. 启动图片轮播定时器
    _animTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
        });
      }
    });

    // 2. 执行 Token 检查逻辑
    _checkAuth();
  }

  // --- 核心：Token 检查逻辑 ---
  Future<void> _checkAuth() async {
    // 调用之前写好的静态方法
    // 这个过程可能需要几百毫秒 (读取本地 -> 发请求 -> 等响应)
    bool isValid = await ApiService.tryRefreshToken();

    if (!mounted) return;

    if (isValid) {
      // Token 有效 -> 直接跳转主页 (替换掉当前页)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else {
      // Token 无效 -> 留在欢迎页，显示内容
      setState(() {
        _showContent = true;
      });
    }
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果正在检查 Token，且还没有结果，可以显示一个空白或加载圈
    // 这里的策略是：先不显示按钮，等检查失败了再把按钮显示出来
    // 这样用户就不会在还没检查完的时候误触“登录”

    // 或者简单点：始终显示背景图，只控制按钮的可交互性。
    // 这里我们用 _showContent 控制整个 Scaffold 的 body
    if (!_showContent) {
      // 检查期间：显示一个纯白背景 + 加载圈 (或者只显示背景图不显示按钮)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1A2226)),
        ),
      );
    }

    // 检查完毕且未登录 -> 显示正常的欢迎页
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 动态插画
              SizedBox(
                height: 200,
                child: Image.asset(
                  _currentImageIndex == 0
                      ? 'assets/images/登录注册选择1.png'
                      : 'assets/images/登录注册选择2.png',
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Hi',
                style: TextStyle(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '我是心情记',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                '初来乍到\n要给我讲讲你的故事吗',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.8
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                '......',
                style: TextStyle(fontSize: 20, color: Colors.black26),
              ),

              const Spacer(flex: 1),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2226),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '登 录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 注册按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '注 册 账 号',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}