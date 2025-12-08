import 'dart:math'; // 用于随机数
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于状态栏控制
import 'package:intl/intl.dart'; // 用于日期格式化
import 'diary_pages/weather.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {

  // --- 1. 随机欢迎语数据 ---
  final List<String> _welcomeMessages = [
    "初次见面，你好鸭\n那么现在，让我们写下第一篇日记吧",
    "今天发生了什么有趣的事吗？\n别让生活的小确幸溜走，快记下来吧",
    "记录此刻的心情\n这是留给未来自己最好的礼物",
    "无论是晴天还是雨天\n心晴记都愿意倾听你的故事",
    "也就是现在\n给今天的自己一个大大的拥抱吧"
  ];

  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = _welcomeMessages[Random().nextInt(_welcomeMessages.length)];
  }

  // 跳转到写日记页面的通用方法
  void _goToWeather() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WeatherPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前日期
    final DateTime now = DateTime.now();
    final String dayStr = DateFormat('dd').format(now);
    final String yearMonthStr = DateFormat('yyyy年MM月').format(now);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F8),

        body: SafeArea(
          child: Column(
            children: [
              // --- 顶部导航栏 (包含菜单和写日记按钮) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Row(
                  // 【修改点 3】设置对齐方式，让两个按钮分别靠左和靠右
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- 左侧：菜单按钮 ---
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ]
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),

                    // ---右侧：写日记按钮---
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ]
                      ),
                      child: IconButton(
                        // 使用编辑图标
                        icon: const Icon(Icons.edit_rounded, color: Colors.black87, size: 26),
                        onPressed: _goToWeather, // 点击跳转
                      ),
                    ),
                  ],
                ),
              ),

              //中间卡片
              Expanded(
                child: Align(
                  // alignment: Alignment(水平, 垂直)
                  // 0.0 表示水平居中
                  // -0.2 表示垂直方向向上偏移 (范围是 -1.0 到 1.0)
                  alignment: const Alignment(0.0, -1.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 日期
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              dayStr,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2DC3C8),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              yearMonthStr,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Container(width: 20, height: 3, color: Colors.black87),
                        const SizedBox(height: 30),

                        // 欢迎语
                        Text(
                          _currentMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: Color(0xFF1A2226),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // 图片
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              height: 200,
                              child: Image.asset(
                                'assets/images/主页标志.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // 按钮
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            // 底部的按钮也可以加上跳转逻辑，提升体验
                            onPressed: _goToWeather,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A2226),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              '好 的 这 就 开 始',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}