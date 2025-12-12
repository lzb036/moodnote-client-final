import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入
import '../main.dart';
import '../http/service.dart';
import '../http/utils.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _currentImageIndex = 0;
  Timer? _timer;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // [新增] 用于管理当前的顶部弹窗，防止重叠
  OverlayEntry? _overlayEntry;

  // [新增] 记住密码的状态，默认为 false
  bool _rememberPassword = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex == 0) ? 1 : 0;
        });
      }
    });
    // 2. [新增] 加载保存的账号密码
    _loadSavedCredentials();
  }

  // --- [新增] 读取本地存储的账号密码 ---
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 读取记住密码的开关状态
      _rememberPassword = prefs.getBool('remember_me') ?? false;

      // 如果之前勾选了记住密码，则回填输入框
      if (_rememberPassword) {
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    // 页面销毁时，如果弹窗还在，记得移除
    _overlayEntry?.remove();
    super.dispose();
  }

  // --- [新增] 核心方法：显示顶部弹窗 ---
  void _showTopMessage(String message, {bool isError = false}) {
    // 1. 如果已有弹窗，先移除，防止堆叠
    _overlayEntry?.remove();

    // 2. 创建新的 OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // 距离顶部安全区往下一点
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            // 添加一个下滑动画
            tween: Tween(begin: -100.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError ? Colors.redAccent : const Color(0xFF2DC3C8), // 成功青色，失败红色
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

    // 3. 插入到屏幕最上层
    Overlay.of(context).insert(_overlayEntry!);

    // 4. 2秒后自动消失
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  // --- 辅助方法：打印所有本地存储内容 ---
  Future<void> _printAllPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("=========================================");
    print("      [DEBUG] 当前 SharedPreferences 内容      ");
    print("=========================================");
    Set<String> keys = prefs.getKeys();
    if (keys.isEmpty) {
      print("  (空)");
    } else {
      for (String key in keys) {
        print("  Key: $key  |  Value: ${prefs.get(key)}");
      }
    }
    print("=========================================");
  }

  // --- 核心：处理登录点击 ---
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // ▼▼▼ 修改点：使用顶部弹窗 ▼▼▼
      _showTopMessage("请输入用户名和密码", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      // 1. 调用登录 API
      await ApiService.login(username, password);

      if (!mounted) return;

      // 2. [新增] 登录成功后，处理“记住密码”逻辑
      final prefs = await SharedPreferences.getInstance();
      if (_rememberPassword) {
        // 如果勾选了，保存账号密码和状态
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_username', username);
        await prefs.setString('saved_password', password);
      } else {
        // 如果没勾选，清除保存的密码 (为了体验好，用户名可以保留，或者也清除，这里选择全部清除)
        await prefs.remove('remember_me');
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }

      // 2. 登录成功后，打印查看本地存了什么
      await _printAllPrefs();

      // 3. ▼▼▼ 修改点：成功提示（顶部） ▼▼▼
      _showTopMessage("登录成功，欢迎回来！", isError: false);

      // 4. 跳转主页
      // 这里稍微延迟一点点，让用户看到成功的弹窗再跳转，体验更好
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      String errorMsg = DataUtils.getErrorMsg(e);

      // 7. ▼▼▼ 修改点：失败提示（顶部） ▼▼▼
      _showTopMessage("登录失败: $errorMsg", isError: true);

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏图标为深色，背景透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 动态插画
                  Transform.translate(
                    offset: const Offset(-10, 0),
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
                  const Text(
                    '欢迎回来，',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A2226)),
                  ),
                  const Text(
                    '很高兴再次见到你。',
                    style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '用户名',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
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
                  Row(
                    children: [
                      // 记住密码复选框
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberPassword,
                          activeColor: const Color(0xFF1A2226), // 选中时的颜色，配合主题
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (value) {
                            setState(() {
                              _rememberPassword = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rememberPassword = !_rememberPassword;
                          });
                        },
                        child: const Text(
                          "记住密码",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),

                      const Spacer(), // 撑开中间空间

                      // 忘记密码
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text('忘记密码?', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2226),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
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
      ),
    );
  }
}