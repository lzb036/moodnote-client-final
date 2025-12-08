import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart'; // 用于跳转回主页
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. 动画相关变量
  int _currentImageIndex = 0;
  Timer? _timer;

  // 2. 表单相关变量
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // 控制密码是否显示明文

  @override
  void initState() {
    super.initState();
    // 启动左上角的动画定时器
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 使用 SingleChildScrollView 防止键盘弹出时遮挡输入框
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. 顶部返回按钮 ---
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                  onPressed: () => Navigator.pop(context), // 返回上一页
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),

                const SizedBox(height: 20),

                // --- 2. 左上角动态插画 ---
                Transform.translate(
                  // Offset(x, y) -> x 是水平方向，y 是垂直方向
                  // 负数表示向左，正数表示向右。这里 -20 表示向左挪 20 像素
                  offset: const Offset(-20, 0),
                  child: SizedBox(
                    height: 220, // 这里是你刚才调大的高度
                    child: Image.asset(
                      _currentImageIndex == 0
                          ? 'assets/images/登录注册信息填写1.png'
                          : 'assets/images/登录注册信息填写2.png',
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      // 确保图片内容也是靠左对齐的（防止图片容器变大后居中）
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. 大标题 ---
                const Text(
                  '欢迎回来，',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2226),
                  ),
                ),
                const Text(
                  '很高兴再次见到你。',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // --- 4. 用户名输入框 ---
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: '用户名 / 邮箱',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5), // 浅灰背景
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none, // 去掉默认边框
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 5. 密码输入框 ---
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // 控制是否隐藏密码
                  decoration: InputDecoration(
                    labelText: '密码',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 10),

                // 忘记密码链接
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text('忘记密码?', style: TextStyle(color: Colors.grey)),
                  ),
                ),

                const SizedBox(height: 30),

                // --- 6. 登录按钮 ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // 这里写登录逻辑
                      // 暂时直接跳转到主页
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainPage()),
                            (route) => false, // 清除之前的路由堆栈，防止按返回键回到登录页
                      );
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}