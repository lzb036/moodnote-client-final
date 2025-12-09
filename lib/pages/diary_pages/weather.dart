import 'package:flutter/material.dart';
import 'mood.dart';

// 1. 定义天气数据模型
class WeatherItem {
  final String name;
  final String description;
  final String buttonText;
  final String iconPath;
  final String illustrationPath;

  WeatherItem({
    required this.name,
    required this.description,
    required this.buttonText,
    required this.iconPath,
    required this.illustrationPath,
  });
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // 默认选中第 8 个 (晴天)
  int _selectedIndex = 0;

  // 当前滑动到了第几页（用于控制底部小圆点）
  int _currentPage = 0;

  // --- 2. 配置 13 种天气数据 ---
  final List<WeatherItem> _weatherItems = [
    WeatherItem(
      name: "晴天",
      description: "朝阳光尽情拔足狂奔",
      buttonText: "原来是晴天",
      iconPath: "assets/images/weather/晴天.png",
      illustrationPath: "assets/images/weather/pkq晴天.png",
    ),
    WeatherItem(
      name: "下雨",
      description: "听见雨滴落在青石板",
      buttonText: "原来是下雨",
      iconPath: "assets/images/weather/下雨.png",
      illustrationPath: "assets/images/weather/pkq下雨.png",
    ),
    WeatherItem(
      name: "下雪",
      description: "世界变得安静又纯白",
      buttonText: "原来是下雪",
      iconPath: "assets/images/weather/下雪.png",
      illustrationPath: "assets/images/weather/pkq下雪.png",
    ),
    WeatherItem(
      name: "冰雹",
      description: "噼里啪啦的交响曲",
      buttonText: "原来是冰雹",
      iconPath: "assets/images/weather/冰雹.png",
      illustrationPath: "assets/images/weather/pkq冰雹.png",
    ),
    WeatherItem(
      name: "多云",
      description: "云朵是天空的信笺",
      buttonText: "原来是多云",
      iconPath: "assets/images/weather/多云.png",
      illustrationPath: "assets/images/weather/pkq多云.png",
    ),
    WeatherItem(
      name: "多云转晴",
      description: "阴霾终将散去",
      buttonText: "原来是多云转晴",
      iconPath: "assets/images/weather/多云转晴.png",
      illustrationPath: "assets/images/weather/pkq多云转晴.png",
    ),
    WeatherItem(
      name: "太阳雨",
      description: "天空在笑也在哭",
      buttonText: "原来是太阳雨",
      iconPath: "assets/images/weather/太阳雨.png",
      illustrationPath: "assets/images/weather/pkq太阳雨.png",
    ),
    WeatherItem(
      name: "彩虹",
      description: "这是幸运的象征",
      buttonText: "原来是彩虹",
      iconPath: "assets/images/weather/彩虹.png",
      illustrationPath: "assets/images/weather/pkq彩虹.png",
    ),
    WeatherItem(
      name: "打雷",
      description: "轰隆隆的也是一种节奏",
      buttonText: "原来是打雷",
      iconPath: "assets/images/weather/打雷.png",
      illustrationPath: "assets/images/weather/pkq打雷.png",
    ),
    WeatherItem(
      name: "末日",
      description: "爱你直到世界尽头",
      buttonText: "原来是末日",
      iconPath: "assets/images/weather/末日.png",
      illustrationPath: "assets/images/weather/pkq末日.png",
    ),
    WeatherItem(
      name: "流星",
      description: "向着星空许个愿",
      buttonText: "原来是流星",
      iconPath: "assets/images/weather/流星.png",
      illustrationPath: "assets/images/weather/pkq流星.png",
    ),
    WeatherItem(
      name: "起风",
      description: "风会带走所有的叹息",
      buttonText: "原来是起风",
      iconPath: "assets/images/weather/起风.png",
      illustrationPath: "assets/images/weather/pkq起风.png",
    ),
    WeatherItem(
      name: "雾霾",
      description: "迷雾终将散去",
      buttonText: "原来是雾霾",
      iconPath: "assets/images/weather/雾霾.png",
      illustrationPath: "assets/images/weather/pkq雾霾.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentItem = _weatherItems[_selectedIndex];
    // 计算总页数：每页 6 个 (13 / 6 向上取整 = 3页)
    final int pageCount = (_weatherItems.length / 6).ceil();

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
          // --- 1. 顶部展示区域 ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: AnimatedSwitcher(
                    // 1. 动画持续时间，500毫秒比较柔和
                    duration: const Duration(milliseconds: 500),
                    // 2. 动画曲线，使用 easeInOut 让过渡更自然
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    // 3. 自定义过渡效果（默认是渐变 Fade，这里我们显式写出来，也可以加上缩放）
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    // 4. 图片组件
                    child: Image.asset(
                      // 关键点！必须设置 key，否则 AnimatedSwitcher 认为组件没变，不会做动画
                      key: ValueKey(currentItem.illustrationPath),

                      currentItem.illustrationPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "晚上好 匿名兔322",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "不知道你那里天气如何？",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "“ ${currentItem.description} ”",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- 2. 中间分页区域 (PageView) ---
          Expanded(
            child: PageView.builder(
              itemCount: pageCount,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, pageIndex) {
                // 计算当前页数据的起始索引
                final int startIndex = pageIndex * 6;
                // 截取当前页需要的 6 个数据 (或者更少)
                final int endIndex = (startIndex + 6 > _weatherItems.length)
                    ? _weatherItems.length
                    : startIndex + 6;
                final List<WeatherItem> pageItems = _weatherItems.sublist(startIndex, endIndex);

                // 在 PageView 内部使用 GridView 构建 3x2 网格
                return GridView.builder(
                  // 禁止 GridView 自身滚动，完全交给 PageView
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 35, // <--- 这里增加了顶部内边距，图标会整体下移
                      bottom: 10 // 可选：如果底部也觉得紧，可以加一点
                  ),
                  itemCount: pageItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 一行3个
                    mainAxisSpacing: 20, // 增加垂直间距，让两排分得开一点
                    crossAxisSpacing: 15, // 增加水平间距
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, gridIndex) {
                    // 计算这个 item 在原始大列表中的真实索引
                    final int realIndex = startIndex + gridIndex;
                    final item = pageItems[gridIndex];
                    final isSelected = realIndex == _selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = realIndex;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.all(isSelected ? 0 : 8), // 选中时撑满，未选中时留白，产生大小变化
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : Colors.transparent,
                          // 关键点：不使用 border，而是使用两层阴影模拟光晕
                          boxShadow: isSelected
                              ? [
                            // 第一层：内部的微光
                            BoxShadow(
                              color: const Color(0xFF1A2226).withOpacity(0.1),
                              blurRadius: 0,
                              spreadRadius: 4, // 模拟一个半透明的边框环
                            ),
                            // 第二层：外部的柔和投影
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ]
                              : [],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            item.iconPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- 3. 分页指示器 (小圆点) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 当前页是黑色，其他页是浅灰色
                  color: _currentPage == index
                      ? const Color(0xFF1A2226)
                      : Colors.grey.withOpacity(0.3),
                ),
              );
            }),
          ),

          const SizedBox(height: 50),

          // --- 4. 底部按钮 ---
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40, top: 20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // 跳转到情绪选择界面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MoodSelectPage()),
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
                child: Text(
                  currentItem.buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
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