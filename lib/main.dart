import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于设置状态栏颜色


//引入主要的四个界面
import 'pages/diary.dart';
import 'pages/community.dart';
import 'pages/chart.dart';
import 'pages/mine.dart';

//引入其他界面
import 'pages/auth_check.dart';
import 'pages/welcome.dart';
import 'pages/login.dart';
import 'pages/register.dart';

//引入组件
import 'widgets/side_drawer.dart';
//引入国际化包
import 'package:flutter_localizations/flutter_localizations.dart';

// ▼▼▼ 1. 引入 flutter_quill 包 (必须) ▼▼▼
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置沉浸式状态栏（让状态栏背景透明，图标变黑）
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // 透明背景
    statusBarIconBrightness: Brightness.dark, // 黑色图标
  ));

  runApp(const MoodNoteApp());
}

class MoodNoteApp extends StatelessWidget {
  const MoodNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '心晴记',
      debugShowCheckedModeBanner: false, // 去掉右上角Debug标签
      theme: ThemeData(
        //设置全局字体
        fontFamily: '手写体',
        // 设置主色调
        primarySwatch: Colors.teal,
        useMaterial3: true,
        // 设置背景色为柔和的白色
        scaffoldBackgroundColor: Colors.white,
        // 设置AppBar默认样式
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0, // 去掉阴影
          scrolledUnderElevation: 0, // 滚动时不改变颜色
          titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600
          ),
        ),
      ),
      // 设置支持的语言：中文
      supportedLocales: const [
        Locale('zh', 'CN'), // 中文 (简体)
      ],

      // 设置本地化代理（翻译器）
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // Material 组件库的翻译 (DatePicker 就在这里)
        GlobalWidgetsLocalizations.delegate,  // 基础 Widget 的翻译
        GlobalCupertinoLocalizations.delegate, // iOS 风格组件的翻译
        FlutterQuillLocalizations.delegate,// ▼▼▼ 3. 添加 Quill 本地化代理 (解决崩溃的关键) ▼▼▼
      ],

      // 强制 APP 始终使用中文，不管手机系统语言是什么
      locale: const Locale('zh', 'CN'),
      home: const AuthCheckPage(), //一进入应用时的界面
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 当前选中的索引
  int _currentIndex = 0;

  // 四个主要界面
  final List<Widget> _pages = [
    const DiaryPage(),     // 日记页
    const CommunityPage(), // 社区页
    const ChartPage(),     // 图表页
    const MinePage(),      // 我的页
  ];

  // 底部导航栏点击事件
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 一个辅助函数：用来构建图标，减少重复代码
  Widget _buildIcon(String assetName, bool isSelected) {
    return Image.asset(
      'assets/icons/$assetName', // 拼接路径
      width: 24,
      height: 24,
      color: isSelected ? const Color(0xFF2D2D2D) : const Color(0xFFBDBDBD),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      body: IndexedStack(
        index: _currentIndex, // 控制显示哪一张“牌”
        children: _pages,     // 将四个页面一次性叠在这里
      ),

      // 底部导航栏
      bottomNavigationBar: Container(
        // 添加顶部边框，区分内容和导航栏
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        ),
        child: BottomNavigationBar(
          // 超过3个项目必须设置 type 为 fixed
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onTabTapped,

          // 整体样式设置
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF2D2D2D), // 选中文字颜色（深黑）
          unselectedItemColor: const Color(0xFFBDBDBD), // 未选中文字颜色（浅灰）
          selectedFontSize: 12, // 选中字体大小
          unselectedFontSize: 12, // 未选中字体大小

          items: [
            // 1. 日记
            BottomNavigationBarItem(
              icon: _buildIcon('日记line.png', false), // 未选中图标
              activeIcon: _buildIcon('日记fill.png', true), // 选中图标
              label: '日记',
            ),
            // 2. 社区
            BottomNavigationBarItem(
              icon: _buildIcon('社区line.png', false),
              activeIcon: _buildIcon('社区fill.png', true),
              label: '社区',
            ),
            // 3. 图表
            BottomNavigationBarItem(
              icon: _buildIcon('可视化图表line.png', false),
              activeIcon: _buildIcon('可视化图表fill.png', true),
              label: '图表',
            ),
            // 4. 我的
            BottomNavigationBarItem(
              icon: _buildIcon('用户line.png', false),
              activeIcon: _buildIcon('用户fill.png', true),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}