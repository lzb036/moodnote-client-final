import 'dart:async';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // 用来记录当前显示哪张图片 (0 或 1)
  int _currentImageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 启动定时器，每 800 毫秒切换一次图片
    // 你可以调整 Duration 的数值来改变动画速度
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
      });
    });
  }

  @override
  void dispose() {
    // 页面销毁时一定要把定时器关掉，防止内存泄漏
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2), // 顶部的弹性空白

              // 动态插画区域
              SizedBox(
                height: 200, // 给定固定高度，防止图片切换时页面抖动
                child: Image.asset(
                  _currentImageIndex == 0
                      ? 'assets/images/登录注册选择1.png'
                      : 'assets/images/登录注册选择2.png',
                  fit: BoxFit.contain,
                  // 加上这个可以让图片切换时有一个极其微小的过渡，不加也可以
                  gaplessPlayback: true,
                ),
              ),

              const SizedBox(height: 40),

              // 文字区域
              // "Hi" - 使用衬线体，斜体
              const Text(
                'Hi',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Times New Roman', // 英文衬线体
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // "我是心情记"
              const Text(
                '我是心情记',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // 稍微加粗
                  fontFamily: 'Songti SC', // 尝试使用宋体风格，如果没有则回退默认
                  color: Colors.black87,
                  letterSpacing: 1.2, // 字间距稍微拉开一点
                ),
              ),
              const SizedBox(height: 30),

              // 描述文字
              const Text(
                '初来乍到\n要给我讲讲你的故事吗',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54, // 灰色文字
                  height: 1.8, // 行高，让两行字不要挨太紧
                  fontFamily: 'Songti SC',
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                '...',
                style: TextStyle(fontSize: 20, color: Colors.black26),
              ),

              const Spacer(flex: 2), // 中间的弹性空白

              // 按钮区域

              // 黑色实心按钮：登录
              SizedBox(
                width: double.infinity, // 宽度撑满
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    //跳转到登录逻辑
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2226), // 深黑色背景
                    foregroundColor: Colors.white, // 白色文字
                    elevation: 0, // 去掉阴影，扁平化
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // 大圆角
                    ),
                  ),
                  child: const Text(
                    '登 录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 白色空心按钮：注册
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // 跳转到注册逻辑
                    Navigator.pushNamed(context, '/register');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey, width: 1), // 灰色边框
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // 大圆角
                    ),
                  ),
                  child: const Text(
                    '注 册 账 号',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey, // 灰色文字
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1), // 底部的弹性空白
            ],
          ),
        ),
      ),
    );
  }
}