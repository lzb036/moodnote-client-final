import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 引入 services 库以设置状态栏

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // --- 1. 动画相关变量 ---
  int _currentImageIndex = 0;
  Timer? _animTimer;

  // --- 2. 验证码倒计时变量 ---
  Timer? _codeTimer;
  int _countdownTime = 0;

  // --- 3. 表单控制器 ---
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  // --- 4. 密码可见性开关 ---
  bool _isPwdVisible = false;
  bool _isConfirmPwdVisible = false;

  @override
  void initState() {
    super.initState();
    // 启动左上角动画
    _animTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
      });
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    _codeTimer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  // 开始验证码倒计时
  void _startCodeCountdown() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('验证码已发送至您的邮箱'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _countdownTime = 60;
    });

    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownTime < 1) {
            _codeTimer?.cancel();
            _countdownTime = 0;
          } else {
            _countdownTime--;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 【关键点1】设置状态栏图标为深色（因为背景是白色），确保能看清时间
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      // 点击空白收起键盘
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        // 【关键点2】使用 SafeArea 包裹主要内容
        // 它可以自动识别刘海屏、动态岛、底部Home条，增加必要的 Padding
        child: SafeArea(
          child: SingleChildScrollView(
            // 防止滚动回弹卡顿
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. 顶部返回按钮 ---
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),

                  const SizedBox(height: 10),

                  // --- 2. 左上角动态插画 ---
                  Transform.translate(
                    offset: const Offset(-20, 0),
                    child: SizedBox(
                      height: 220,
                      child: Image.asset(
                        _currentImageIndex == 0
                            ? 'assets/images/登录注册信息填写1.png'
                            : 'assets/images/登录注册信息填写2.png',
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- 3. 大标题 ---
                  const Text(
                    '创建账号',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2226),
                    ),
                  ),
                  const Text(
                    '加入心晴记，开启情绪探索之旅。',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 4. 表单区域 ---

                  // 用户名
                  _buildTextField(
                    controller: _usernameController,
                    label: '用户名',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // 邮箱
                  _buildTextField(
                    controller: _emailController,
                    label: '邮箱',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // 验证码
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '验证码',
                      prefixIcon: const Icon(Icons.security, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        width: 80,
                        child: ElevatedButton(
                          onPressed: _countdownTime > 0 ? null : _startCodeCountdown,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A2226),
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            _countdownTime > 0 ? '${_countdownTime}s' : '发送',
                            style: TextStyle(
                              fontSize: 13,
                              color: _countdownTime > 0 ? null : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 密码
                  _buildPasswordField(
                    controller: _passwordController,
                    label: '设置密码',
                    isVisible: _isPwdVisible,
                    onToggle: () => setState(() => _isPwdVisible = !_isPwdVisible),
                  ),
                  const SizedBox(height: 20),

                  // 确认密码
                  _buildPasswordField(
                    controller: _confirmPwdController,
                    label: '再次确认密码',
                    isVisible: _isConfirmPwdVisible,
                    onToggle: () => setState(() => _isConfirmPwdVisible = !_isConfirmPwdVisible),
                  ),

                  const SizedBox(height: 15),

                  // --- 5. 注册按钮 ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 执行注册逻辑
                        Navigator.pop(context);
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
                        '立 即 注 册',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 通用输入框组件
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // 密码输入框组件
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}