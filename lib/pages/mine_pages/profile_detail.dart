import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  // 模拟数据 (实际开发中从后端获取)
  String _username = "加载中...";
  String _avatarPath = 'assets/images/user.png'; // 默认头像
  String _ipLocation = "福建";
  int _guardDays = 1; // 守护天数
  String _motto = "生活原本沉闷，但跑起来就有风。";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "皮卡丘1";
      // 模拟计算守护天数 (例如从注册日期开始)
      // _guardDays = DateTime.now().difference(registerDate).inDays;
      _guardDays = 108; // 假数据
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 沉浸式顶部
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 28,),
          onPressed: () => Navigator.pop(context),
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100), // 顶出门头空间

            // 1. 头像区域
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2DC3C8), width: 4), // 青色边框
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2DC3C8).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipOval(
                        child: Image.asset(
                          _avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // 头像旁边的编辑小按钮
                  GestureDetector(
                    onTap: () { /* TODO: 修改头像 */ },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2226),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. 用户名
            Text(
              _username,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2226)
              ),
            ),

            const SizedBox(height: 16),

            // 3. 标签栏 (IP & 守护天数)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(Icons.location_on_outlined, "IP: $_ipLocation"),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.shield_outlined, "已守护 $_guardDays 天"),
              ],
            ),

            const SizedBox(height: 40),

            // 4. 名言卡片
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 40, color: Color(0xFFDDDDDD)),
                  const SizedBox(height: 10),
                  Text(
                    _motto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Color(0xFF555555)
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.format_quote_rounded, size: 40, color: Color(0xFFDDDDDD)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // 5. 编辑资料按钮 (大按钮)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 跳转编辑资料页面
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2226),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: const Color(0xFF1A2226).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '编 辑 资 料',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 封装一个小组件：胶囊标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2DC3C8)), // 青色图标
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}