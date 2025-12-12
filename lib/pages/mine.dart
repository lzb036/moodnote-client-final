import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于复制功能
import 'package:shared_preferences/shared_preferences.dart';
import './mine_pages/profile_detail.dart';
import '../pages/welcome.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  // 模拟用户数据
  String _username = "皮卡丘1";
  String _uid = "d96a0b5301f04871b...";
  int _diaryCount = 1;
  int _daysCount = 1;
  int _wordCount = 3;

  final List<String> _albumImages = [
    'assets/images/weather/pkq下雨.png'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // 读取本地存储的用户名
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('username')) {
        _username = prefs.getString('username')!;
      }
      // 这里后续可以加载真实的统计数据
    });
  }

  // --- 复制 UID ---
  void _copyUid() {
    Clipboard.setData(ClipboardData(text: _uid));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("UID 已复制"),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF2DC3C8),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // 获取实例
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 精准移除 Session 数据 (保留记住的账号密码)
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('is_logged_in');
    await prefs.remove('username');
    if (!context.mounted) return;
    // 跳转回欢迎页，并清空路由栈
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 1. 顶部用户信息区域 (重构版)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
                children: [
                  // --- 左侧：头像 ---
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2DC3C8), width: 3), // 青色边框
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/user.png', // 头像
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // --- 右侧：信息区域 (占据剩余宽度) ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一行：用户名 + 个人空间入口
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 用户名 (自适应宽度，防止过长溢出)
                            Flexible(
                              child: Text(
                                _username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2226)
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 个人空间入口 (移到这里)
                            GestureDetector(
                              onTap: () {
                                //跳转至个人空间
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProfileDetailPage()),
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min, // 紧缩包裹
                                children: [
                                  Text(
                                    "个人空间",
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 第二行：UID + 复制按钮
                        Row(
                          children: [
                            // UID (使用 Expanded 占据尽可能多的空间)
                            Expanded(
                              child: Text(
                                "UID: $_uid",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey
                                ),
                                overflow: TextOverflow.ellipsis, // 超出显示省略号
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 复制按钮
                            GestureDetector(
                              onTap: _copyUid,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                child: Text(
                                  "复制",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2DC3C8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. 数据统计栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem("日记数量", _diaryCount.toString()),
                  _buildStatItem("记录天数", _daysCount.toString()),
                  _buildStatItem("总字数", _wordCount.toString()),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 相册模块
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  // 给卡片加个阴影，显得有层次感
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFF5F5F5)),
                ),
                child: Column(
                  children: [
                    // 头部：标题 + 入口
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "相册",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2226)
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: 跳转到完整相册页
                          },
                          child: Row(
                            children: [
                              Text(
                                "${_albumImages.length}张照片",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 图片展示区 (Row)
                    Row(
                      children: [
                        // 左边图片位 (index 0)
                        Expanded(
                          child: _buildAlbumImage(0),
                        ),

                        const SizedBox(width: 12), // 中间间距

                        // 右边图片位 (index 1)
                        Expanded(
                          child: _buildAlbumImage(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
      ),
    );
  }

  // 构建单张图片的辅助方法
  Widget _buildAlbumImage(int index) {
    // 判断当前是否有这张图
    bool hasImage = index < _albumImages.length;

    return AspectRatio(
      aspectRatio: 1.0, // 强制正方形 (1:1)
      child: Container(
        decoration: BoxDecoration(
          // 如果没有图，显示浅灰色背景；有图显示白色(被图片遮盖)
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        // 裁剪圆角，防止图片溢出
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasImage
              ? Image.asset(
            _albumImages[index],
            fit: BoxFit.cover, // 充满容器，自动裁剪
            errorBuilder: (ctx, err, stack) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          )
              : const Center(
            // 占位状态：显示一个空的或者加号
            // 这里什么都不放就是纯色块，符合简约设计
          ),
        ),
      ),
    );
  }

  // 构建统计项的小组件
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2226)
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}