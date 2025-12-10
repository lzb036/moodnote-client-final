import 'package:flutter/material.dart';

// 日历数据模型
class CalendarDay {
  final DateTime date;
  final String dayStr;
  final String lunar; // 农历或节日名称
  final bool isCurrentMonth;
  final bool isFestival; // 是否是节日（用于特殊颜色显示）

  CalendarDay({
    required this.date,
    required this.dayStr,
    required this.lunar,
    this.isCurrentMonth = true,
    this.isFestival = false,
  });
}

class DiaryCalendarPage extends StatefulWidget {
  const DiaryCalendarPage({super.key});

  @override
  State<DiaryCalendarPage> createState() => _DiaryCalendarPageState();
}

class _DiaryCalendarPageState extends State<DiaryCalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late PageController _pageController;
  static const int _initialPage = 10000;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _calculateMonthDifference(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now;
      _focusedDay = now;
    });
    _pageController.jumpToPage(_initialPage);
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A2226),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final int monthDiff = _calculateMonthDifference(now, picked);
      final int targetPage = _initialPage + monthDiff;

      setState(() {
        _focusedDay = DateTime(picked.year, picked.month, 1);
      });
      _pageController.jumpToPage(targetPage);
    }
  }

  List<CalendarDay> _generateCalendarDays(DateTime monthDate) {
    final List<CalendarDay> days = [];
    final int year = monthDate.year;
    final int month = monthDate.month;
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);

    int firstWeekdayOffset = firstDayOfMonth.weekday;
    if (firstWeekdayOffset == 7) firstWeekdayOffset = 0;

    for (int i = 0; i < firstWeekdayOffset; i++) {
      days.add(CalendarDay(
          date: DateTime(1900), dayStr: "", lunar: "", isCurrentMonth: false));
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final DateTime date = DateTime(year, month, i);
      // 获取节日或农历
      String label = _getFestivalOrLunar(month, i);
      // 判断是否是节日（如果不是初一/十二这种数字，通常就是节日）
      bool isFestival = !label.contains(RegExp(r'[一二三四五六七八九十]'));

      days.add(CalendarDay(
        date: date,
        dayStr: i.toString(),
        lunar: label,
        isFestival: isFestival, // 标记是否为节日
      ));
    }
    return days;
  }

  // 增加简单的公历节日判断
  String _getFestivalOrLunar(int month, int day) {
    // 先判断公历节日 (仅列举常见节日，可自行补充)
    if (month == 1 && day == 1) return "元旦";
    if (month == 2 && day == 14) return "情人节";
    if (month == 3 && day == 8) return "妇女节";
    if (month == 3 && day == 12) return "植树节";
    if (month == 4 && day == 1) return "愚人节";
    if (month == 5 && day == 1) return "劳动节";
    if (month == 5 && day == 4) return "青年节";
    if (month == 6 && day == 1) return "儿童节";
    if (month == 7 && day == 1) return "建党节";
    if (month == 8 && day == 1) return "建军节";
    if (month == 9 && day == 10) return "教师节";
    if (month == 10 && day == 1) return "国庆节";
    if (month == 11 && day == 1) return "万圣节";
    if (month == 12 && day == 24) return "平安夜";
    if (month == 12 && day == 25) return "圣诞节";

    // 如果不是节日，显示模拟的农历数字
    const chineseNumerals = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十", "三一"];
    if (day <= chineseNumerals.length) return chineseNumerals[day - 1];

    return "";
  }

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF2DC3C8);
    final DateTime baseDate = DateTime.now();
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.7,
              child: Column(
                children: [
                  // 顶部导航栏
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 28,),
                          onPressed: () => Navigator.pop(context),
                        ),
                        GestureDetector(
                          onTap: _selectMonth,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${_focusedDay.year}年 ${_focusedDay.month}月",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Courier', letterSpacing: 1.0),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: "回到今天",
                          icon: const Icon(Icons.calendar_today_outlined, color: Colors.black87, size: 25),
                          onPressed: _jumpToToday,
                        ),
                        IconButton(
                          tooltip: "写日记",
                          icon: const Icon(Icons.add, color: Colors.black87, size: 30),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // 星期表头
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["日", "一", "二", "三", "四", "五", "六"].map((day) {
                        final bool isWeekend = day == "日" || day == "六";
                        return Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isWeekend ? accentColor : Colors.black54,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // 日历网格
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        final int monthOffset = index - _initialPage;
                        final DateTime newMonth = DateTime(baseDate.year, baseDate.month + monthOffset, 1);
                        setState(() {
                          _focusedDay = newMonth;
                        });
                      },
                      itemBuilder: (context, index) {
                        final int monthOffset = index - _initialPage;
                        final DateTime pageDate = DateTime(baseDate.year, baseDate.month + monthOffset, 1);
                        final days = _generateCalendarDays(pageDate);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: days.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, gridIndex) {
                              final item = days[gridIndex];
                              if (!item.isCurrentMonth) return const SizedBox();

                              final bool isSelected = _selectedDay != null &&
                                  item.date.year == _selectedDay!.year &&
                                  item.date.month == _selectedDay!.month &&
                                  item.date.day == _selectedDay!.day;

                              final now = DateTime.now();
                              final bool isToday = item.date.year == now.year &&
                                  item.date.month == now.month &&
                                  item.date.day == now.day;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDay = item.date;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected ? accentColor : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: (!isSelected && isToday)
                                          ? Border.all(color: accentColor.withOpacity(0.5), width: 1)
                                          : null),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.dayStr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Courier',
                                          color: isSelected ? Colors.white : const Color(0xFF1A2226),
                                        ),
                                      ),
                                      const SizedBox(height: 2),

                                      // 节日显示逻辑
                                      Text(
                                        isToday ? "今天" : item.lunar, // 优先显示“今天”
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'Courier',
                                          // 颜色逻辑：
                                          // 1. 选中状态 -> 白色
                                          // 2. 没选中但今天是 -> 青色
                                          // 3. 没选中但这是个节日 -> 稍微深一点的灰色/青色 (可选)
                                          // 4. 普通日子 -> 浅灰色
                                          color: isSelected
                                              ? Colors.white
                                              : (isToday
                                              ? accentColor
                                              : (item.isFestival ? Colors.black54 : Colors.grey)),

                                          // 如果是节日，稍微加粗一点
                                          fontWeight: item.isFestival ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: Text(
                      "选中日期后点击右上角+，从所选日子开始写",
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Courier', letterSpacing: 1.0),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF7F9FC),
                child: Column(
                  children: [
                    if (_selectedDay != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [],
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Text("这里放 ${_selectedDay?.month}月${_selectedDay?.day}日 的日记列表",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
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
}