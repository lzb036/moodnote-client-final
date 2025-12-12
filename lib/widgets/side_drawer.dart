import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/diary_pages/search.dart';
import '../pages/diary_pages/list.dart';
import '../pages/diary_pages/calendar.dart';
import '../pages/diary_pages/tag.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  // 辅助函数：根据当前时间生成问候语
  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 6) return '凌晨好';
    if (hour < 11) return '上午好';
    if (hour < 13) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前时间
    final DateTime now = DateTime.now();
    final String dateStr = DateFormat('yyyy年MM月dd日').format(now);
    final String greeting = _getGreeting();

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部头部区域
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 30, right: 20, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：标题 + 搜索按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "心情记",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF1A2226),
                        ),
                      ),
                      // 增强搜索按钮点击动效
                      Material(
                        color: Colors.transparent, // 保持背景透明
                        shape: const CircleBorder(), // 确保水波纹是圆形的
                        clipBehavior: Clip.hardEdge, // 裁剪溢出的水波纹
                        child: IconButton(
                          icon: const Icon(Icons.search, size: 35, color: Colors.black87),
                          // 设置明显的点击颜色 (淡青色)
                          splashColor: const Color(0xFF2DC3C8).withOpacity(0.2),
                          highlightColor: const Color(0xFF2DC3C8).withOpacity(0.1),
                          onPressed: () {
                            //关闭抽屉
                            Navigator.pop(context);
                            // 跳转搜索页
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SearchPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 第二行：日期 + 问候语
                  Text(
                    "$dateStr   $greeting",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // 空白间隔
            const SizedBox(height: 60),

            // 功能列表区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10), // 给列表两边加点空隙，让点击效果不贴边
                children: [
                  _buildMenuItem(
                      context,
                      icon: Icons.format_list_bulleted_rounded,
                      title: "列表视图",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DiaryListPage()),
                        );
                      }
                  ),
                  _buildMenuItem(
                      context,
                      icon: Icons.calendar_month_outlined,
                      title: "日历视图",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DiaryCalendarPage()),
                        );
                      }
                  ),
                  _buildMenuItem(
                      context,
                      icon: Icons.style_outlined,
                      title: "标签视图",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DiaryTagPage()),
                        );
                      }
                  ),
                  _buildMenuItem(
                      context,
                      icon: Icons.inbox_outlined, // 使用收件箱图标，很适合表示草稿箱
                      title: "草稿箱",
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: 跳转到草稿箱页面
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 使用 InkWell 实现圆角点击效果
  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // 增加垂直间距
      child: Material(
        color: Colors.transparent, // 必须要有 Material 包裹才能显示水波纹
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15), // 设置点击时的圆角矩形效果
          // 自定义水波纹颜色 (淡青色，符合主题)
          splashColor: const Color(0xFF2DC3C8).withOpacity(0.15),
          highlightColor: const Color(0xFF2DC3C8).withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 内部内边距
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 30),
                const SizedBox(width: 20), // 图标和文字的间距
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 2.0,
                    color: Color(0xFF1A2226),
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