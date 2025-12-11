import 'dart:async'; // 引入 Timer 用于轮播
import 'package:flutter/material.dart';
import 'event.dart';

// 定义心情数据模型
class MoodItem {
  final String name;             // 心情名称 (如：钦佩)
  final String illustrationPath; // 对应的插画路径

  MoodItem({
    required this.name,
    required this.illustrationPath,
  });
}

class MoodSelectPage extends StatefulWidget {
  const MoodSelectPage({super.key});

  @override
  State<MoodSelectPage> createState() => _MoodSelectPageState();
}

class _MoodSelectPageState extends State<MoodSelectPage> {
  // 状态管理
  // 使用 Set 存储选中的索引，支持多选，自动去重
  // 默认选中第0个 (钦佩)
  final Set<int> _selectedIndices = {0};

  // 当前页码
  int _currentPage = 0;

  // 轮播控制
  Timer? _carouselTimer;
  int _currentDisplayIndex = 0; // 当前展示的是“选中列表”中的第几个

  // 配置 27 种心情数据
  final List<MoodItem> _moodItems = [
    // 第 1 页
    MoodItem(name: "钦佩", illustrationPath: "assets/images/mood/钦佩赞赏.png"),
    MoodItem(name: "爱慕", illustrationPath: "assets/images/mood/爱慕崇拜.png"),
    MoodItem(name: "欣赏", illustrationPath: "assets/images/mood/审美欣赏.png"),
    MoodItem(name: "娱乐", illustrationPath: "assets/images/mood/有趣娱乐.png"),
    MoodItem(name: "愤怒", illustrationPath: "assets/images/mood/愤怒生气.png"),
    MoodItem(name: "焦虑", illustrationPath: "assets/images/mood/焦虑不安.png"),
    MoodItem(name: "敬畏", illustrationPath: "assets/images/mood/敬畏震撼.png"),
    MoodItem(name: "尴尬", illustrationPath: "assets/images/mood/尴尬局促.png"),
    MoodItem(name: "无聊", illustrationPath: "assets/images/mood/无聊厌倦.png"),

    // 第 2 页
    MoodItem(name: "冷静", illustrationPath: "assets/images/mood/冷静平静.png"),
    MoodItem(name: "困惑", illustrationPath: "assets/images/mood/困惑迷茫.png"),
    MoodItem(name: "渴望", illustrationPath: "assets/images/mood/激情渴望.png"),
    MoodItem(name: "厌恶", illustrationPath: "assets/images/mood/厌恶反感.png"),
    MoodItem(name: "同情", illustrationPath: "assets/images/mood/同情之病怜悯.png"),
    MoodItem(name: "着迷", illustrationPath: "assets/images/mood/着迷出神.png"),
    MoodItem(name: "兴奋", illustrationPath: "assets/images/mood/兴奋激动.png"),
    MoodItem(name: "恐惧", illustrationPath: "assets/images/mood/恐惧害怕.png"),
    MoodItem(name: "惊骇", illustrationPath: "assets/images/mood/惊骇恐怖.png"),

    // 第 3 页
    MoodItem(name: "兴趣", illustrationPath: "assets/images/mood/好奇兴趣.png"),
    MoodItem(name: "快乐", illustrationPath: "assets/images/mood/快乐喜悦.png"),
    MoodItem(name: "怀旧", illustrationPath: "assets/images/mood/怀旧追忆.png"),
    MoodItem(name: "轻松", illustrationPath: "assets/images/mood/如释重负宽慰.png"),
    MoodItem(name: "浪漫", illustrationPath: "assets/images/mood/烂漫甜蜜.png"),
    MoodItem(name: "悲伤", illustrationPath: "assets/images/mood/悲伤难过.png"),
    MoodItem(name: "满足", illustrationPath: "assets/images/mood/满足惬意.png"),
    MoodItem(name: "激情", illustrationPath: "assets/images/mood/激情渴望.png"),
    MoodItem(name: "惊讶", illustrationPath: "assets/images/mood/惊讶意外.png"),
  ];

  @override
  void initState() {
    super.initState();
    _checkCarousel();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  // 逻辑控制

  // 检查是否需要开启或关闭轮播
  void _checkCarousel() {
    _carouselTimer?.cancel();

    if (_selectedIndices.length > 1) {
      _carouselTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (mounted) {
          setState(() {
            _currentDisplayIndex = (_currentDisplayIndex + 1) % _selectedIndices.length;
          });
        }
      });
    } else {
      // 只有一个或没选（理论上不会没选），重置显示索引
      setState(() {
        _currentDisplayIndex = 0;
      });
    }
  }

  // 获取当前应该显示的插画路径
  String _getCurrentIllustration() {
    if (_selectedIndices.isEmpty) {
      return _moodItems[0].illustrationPath;
    }

    List<int> list = _selectedIndices.toList();
    // 防止索引越界
    if (_currentDisplayIndex >= list.length) _currentDisplayIndex = 0;

    int moodIndex = list[_currentDisplayIndex];
    return _moodItems[moodIndex].illustrationPath;
  }

  // 获取底部按钮文字
  String _getButtonText() {
    if (_selectedIndices.isEmpty) return "请选择心情";
    if (_selectedIndices.length == 1) {
      return "是${_moodItems[_selectedIndices.first].name}呀";
    } else {
      return "是复杂的呀";
    }
  }

  // 核心修改区域：点击某个心情
  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        // 如果已经选中，准备取消
        // 只有当选中数量大于 1 时，才允许取消
        // 这样就保证了至少有一个被选中
        if (_selectedIndices.length > 1) {
          _selectedIndices.remove(index);
        }
      } else {
        // 如果没选中，直接添加
        _selectedIndices.add(index);
        // 为了体验，点击新的时，立即展示这个新的图片
        _currentDisplayIndex = _selectedIndices.toList().indexOf(index);
      }

      // 重新检查是否需要轮播
      _checkCarousel();
    });
  }

  @override
  Widget build(BuildContext context) {
    const int itemsPerPage = 9;
    final int pageCount = (_moodItems.length / itemsPerPage).ceil();

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
          // 顶部展示区域
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            height: 270,
            child: Column(
              children: [
                // 提问文案
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "那么 匿名兔322",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "这一天的心情是怎样的呢",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 动态插画区域
                SizedBox(
                  height: 180,
                  width: 180,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Image.asset(
                      key: ValueKey(_getCurrentIllustration()),
                      _getCurrentIllustration(),
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 中间分页选择区域
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
                final int endIndex = (startIndex + itemsPerPage > _moodItems.length)
                    ? _moodItems.length
                    : startIndex + itemsPerPage;
                final List<MoodItem> pageItems = _moodItems.sublist(startIndex, endIndex);

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: pageItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 2.2,
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
                          color: isSelected ? const Color(0xFF1A2226) : const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1A2226),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 分页指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
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

          const SizedBox(height: 40),

          // 底部按钮
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40, top: 10),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedIndices.isNotEmpty) {
                    // 跳转到事件选择界面
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventSelectPage()),
                    );
                  }
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
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
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