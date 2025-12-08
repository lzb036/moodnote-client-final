import 'dart:async';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // --- 1. 动画变量 ---
  int _currentImageIndex = 0;
  Timer? _timer;

  // --- 2. 表单控制器 ---
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  // --- 3. 密码可见性开关 ---
  bool _isNewPwdVisible = false;
  bool _isConfirmPwdVisible = false;

  // 验证码倒计时相关变量
  Timer? _codeTimer;          // 专门用于验证码倒计时的定时器
  int _countdownTime = 0;     // 剩余秒数 (0代表没在倒计时)

  @override
  void initState() {
    super.initState();
    // 启动挠头动画 (稍微慢一点，看起来更憨憨的)
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    _codeTimer?.cancel();
    super.dispose();
  }

  // 开始倒计时的方法
  void _startCodeCountdown() {
    // 弹出 Toast (SnackBar) 提示发送成功
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('验证码已发送，请注意查收'),
        duration: Duration(seconds: 2), // 显示2秒后自动消失
        behavior: SnackBarBehavior.floating, // 悬浮样式
      ),
    );

    // 设置初始倒计时状态
    setState(() {
      _countdownTime = 60;
    });

    // 启动定时器，每隔1秒减1
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // 确保页面还在
        setState(() {
          if (_countdownTime < 1) {
            _codeTimer?.cancel(); // 倒计时结束，停止定时器
            _countdownTime = 0; // 重置为0
          } else {
            _countdownTime = _countdownTime - 1; // 秒数减1
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "找回密码",
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          child: Column(
            children: [
              // --- 1. 顶部挠头动画 (居中) ---
              SizedBox(
                height: 220,
                child: Image.asset(
                  _currentImageIndex == 0
                      ? 'assets/images/忘记密码1.png' // 记得改名！
                      : 'assets/images/忘记密码2.png',
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "别担心，我们帮你找回来。",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // --- 2. 邮箱输入框 ---
              _buildTextField(
                controller: _emailController,
                label: '注册邮箱',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // --- 3. 验证码输入框 (带发送按钮) ---
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
                  // 后缀按钮：发送验证码
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    width: 80, // 给个固定宽度，防止倒计时数字变化导致按钮忽大忽小
                    child: ElevatedButton(
                      // 逻辑：如果倒计时 > 0，onPressed 设为 null (按钮会自动变灰且不可点)
                      // 否则，绑定点击事件
                      onPressed: _countdownTime > 0
                          ? null
                          : () {
                        // 点击后执行倒计时逻辑
                        _startCodeCountdown();
                      },
                      style: ElevatedButton.styleFrom(
                        // 背景色逻辑：倒计时中用灰色，否则用黑色
                        // 注意：当 onPressed 为 null 时，Flutter 默认就是灰色，所以这里主要设置正常状态
                        backgroundColor: const Color(0xFF1A2226),
                        disabledBackgroundColor: Colors.grey[300], // 禁用时的背景色
                        disabledForegroundColor: Colors.grey[600], // 禁用时的文字色
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero, //以此确保文字居中
                      ),
                      // 文字逻辑：倒计时中显示 "59s"，否则显示 "发送"
                      child: Text(
                        _countdownTime > 0 ? '${_countdownTime}s' : '发送',
                        style: TextStyle(
                          fontSize: 13,
                          // 正常状态白色，禁用状态会自动使用 disabledForegroundColor
                          color: _countdownTime > 0 ? null : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- 4. 新密码 ---
              _buildPasswordField(
                controller: _newPwdController,
                label: '新密码',
                isVisible: _isNewPwdVisible,
                onToggle: () => setState(() => _isNewPwdVisible = !_isNewPwdVisible),
              ),
              const SizedBox(height: 20),

              // --- 5. 确认新密码 ---
              _buildPasswordField(
                controller: _confirmPwdController,
                label: '确认新密码',
                isVisible: _isConfirmPwdVisible,
                onToggle: () => setState(() => _isConfirmPwdVisible = !_isConfirmPwdVisible),
              ),

              const SizedBox(height: 40),

              // --- 6. 确认修改按钮 ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 提交修改逻辑
                    print("点击了确认修改");
                    // 模拟成功后返回登录页
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
                    '重 置 密 码',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30), // 底部留白
            ],
          ),
        ),
      ),
    );
  }

  // 封装通用文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
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

  // 封装密码输入框
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
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}