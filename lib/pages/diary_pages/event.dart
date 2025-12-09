import 'package:flutter/material.dart';
import 'edit.dart';

// 1. 定义事件数据模型
class EventItem {
  final String name;      // 事件名称
  final String iconPath;  // 图标路径

  EventItem({
    required this.name,
    required this.iconPath,
  });
}

class EventSelectPage extends StatefulWidget {
  const EventSelectPage({super.key});

  @override
  State<EventSelectPage> createState() => _EventSelectPageState();
}

class _EventSelectPageState extends State<EventSelectPage> {
  // --- 状态管理 ---
  // 默认选中第0个 (冥想)
  final Set<int> _selectedIndices = {0};

  // 当前页码
  int _currentPage = 0;

  // 固定右上角的插画路径 (请准备这张图)
  final String _fixedIllustration = "assets/images/event/事件选择.png";

  // --- 2. 配置 36 种事件数据 ---
  // 假设图片都在 assets/images/event/ 下，且名为 "中文名.png"
  final List<EventItem> _eventItems = [
    // 第 1 页
    EventItem(name: "冥想", iconPath: "assets/images/event/冥想.png"),
    EventItem(name: "美甲", iconPath: "assets/images/event/美甲.png"),
    EventItem(name: "医疗", iconPath: "assets/images/event/医疗.png"),
    EventItem(name: "美食", iconPath: "assets/images/event/美食.png"),
    EventItem(name: "装修", iconPath: "assets/images/event/装修.png"),
    EventItem(name: "设计", iconPath: "assets/images/event/设计.png"),
    EventItem(name: "结婚", iconPath: "assets/images/event/结婚.png"),
    EventItem(name: "美容", iconPath: "assets/images/event/美容.png"),
    EventItem(name: "研磨", iconPath: "assets/images/event/研磨.png"),

    // 第 2 页
    EventItem(name: "派对", iconPath: "assets/images/event/派对.png"),
    EventItem(name: "面试", iconPath: "assets/images/event/面试.png"),
    EventItem(name: "试装", iconPath: "assets/images/event/试装.png"),
    EventItem(name: "喝茶", iconPath: "assets/images/event/喝茶.png"),
    EventItem(name: "喂鱼", iconPath: "assets/images/event/喂鱼.png"),
    EventItem(name: "体重", iconPath: "assets/images/event/体重.png"),
    EventItem(name: "记录", iconPath: "assets/images/event/记录.png"),
    EventItem(name: "种植", iconPath: "assets/images/event/种植.png"),
    EventItem(name: "日出", iconPath: "assets/images/event/日出.png"),

    // 第 3 页
    EventItem(name: "礼物", iconPath: "assets/images/event/礼物.png"),
    EventItem(name: "吃饭", iconPath: "assets/images/event/吃饭.png"),
    EventItem(name: "化妆", iconPath: "assets/images/event/化妆.png"),
    EventItem(name: "聊天", iconPath: "assets/images/event/聊天.png"),
    EventItem(name: "上班", iconPath: "assets/images/event/上班.png"),
    EventItem(name: "健身", iconPath: "assets/images/event/健身.png"),
    EventItem(name: "露营", iconPath: "assets/images/event/露营.png"),
    EventItem(name: "骑行", iconPath: "assets/images/event/骑行.png"),
    EventItem(name: "育儿", iconPath: "assets/images/event/育儿.png"),

    // 第 4 页
    EventItem(name: "煮饭", iconPath: "assets/images/event/煮饭.png"),
    EventItem(name: "恋爱", iconPath: "assets/images/event/恋爱.png"),
    EventItem(name: "研究", iconPath: "assets/images/event/研究.png"),
    EventItem(name: "音乐", iconPath: "assets/images/event/音乐.png"),
    EventItem(name: "上学", iconPath: "assets/images/event/上学.png"),
    EventItem(name: "存钱", iconPath: "assets/images/event/存钱.png"),
    EventItem(name: "生日", iconPath: "assets/images/event/生日.png"),
    EventItem(name: "购物", iconPath: "assets/images/event/购物.png"),
    EventItem(name: "宠物", iconPath: "assets/images/event/宠物.png"),
  ];

  // 获取底部按钮文案
  String _getButtonText() {
    int count = _selectedIndices.length;
    if (count <= 1) {
      return "因为这件事情"; // 0个(理论不会) 或 1个
    } else {
      return "因为这 $count 件事情";
    }
  }

  // 点击事件处理
  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        // 如果已经选中，且总数大于1，才允许取消 (保证至少选一个)
        if (_selectedIndices.length > 1) {
          _selectedIndices.remove(index);
        }
      } else {
        // 选中
        _selectedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 36个数据，每页9个，正好4页
    const int itemsPerPage = 9;
    final int pageCount = (_eventItems.length / itemsPerPage).ceil();

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
      body: Column(
        children: [
          // --- 1. 顶部展示区域 (左文案 + 右插画) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧：提问文案
                const Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "是什么事情呀",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "让我也听听呐",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier'
                        ),
                      ),
                    ],
                  ),
                ),

                // 右侧：固定插画
                Expanded(
                  flex: 5,
                  child: Image.asset(
                    _fixedIllustration,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                    // 还没放图时显示的占位符
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. 中间分页选择区域 ---
          Expanded(
            child: PageView.builder(
              itemCount: pageCount,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, pageIndex) {
                final int startIndex = pageIndex * itemsPerPage;
                final int endIndex = (startIndex + itemsPerPage > _eventItems.length)
                    ? _eventItems.length
                    : startIndex + itemsPerPage;
                final List<EventItem> pageItems = _eventItems.sublist(startIndex, endIndex);

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: pageItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 一行3个
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.0, // 正方形
                  ),
                  itemBuilder: (context, gridIndex) {
                    final int realIndex = startIndex + gridIndex;
                    final item = pageItems[gridIndex];
                    final isSelected = _selectedIndices.contains(realIndex);

                    return GestureDetector(
                      onTap: () => _onItemTapped(realIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          // 选中黑底，未选中浅灰底
                          color: isSelected ? const Color(0xFF1A2226) : const Color(0xFFF7F7F7),
                          // Moo日记风格的不规则圆角模拟 (稍微大一点的圆角)
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 图标 (如果你的图片是纯色的，可以加 color 属性做反色)
                            Image.asset(
                              item.iconPath,
                              width: 32,
                              height: 32,
                              // 选中变白，未选中变黑 (假设你的原图是黑色/深色)
                              color: isSelected ? Colors.white : Colors.black87,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.help_outline,
                                  size: 32,
                                  color: isSelected ? Colors.white : Colors.black87
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 文字
                            Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- 3. 分页指示器 ---
          Transform.translate(
            offset: const Offset(0, -20), // 【修改点】 0 表示水平不动，-20 表示垂直向上移动 20 像素
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pageCount, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  // 选中稍微长一点
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF1A2226)
                        : Colors.grey.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),

          // --- 4. 底部按钮 ---
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40, top: 20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到编辑日记界面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DiaryEditPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2226),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getButtonText(),
                    key: ValueKey(_getButtonText()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}