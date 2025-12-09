import 'package:flutter/material.dart';

class DiaryEditPage extends StatefulWidget {
  const DiaryEditPage({super.key});

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {
  // 控制输入框
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // 状态变量
  int _charCount = 0;
  bool _hasTitle = false; // 用于控制右上角按钮颜色 (绿色/灰色)

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkInput);
    _contentController.addListener(_checkInput);
  }

  // 检查输入逻辑
  void _checkInput() {
    setState(() {
      _charCount = _contentController.text.length;
      // 只要标题有内容（去除空格后），就算“有效”，按钮变绿
      _hasTitle = _titleController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // --- 逻辑 1：处理左上角返回 (保持原样：不保留则返回上一页，保留则回主页) ---
  void _handleBackPress() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("保留记忆"),
          content: const Text("是否保存当前的日记草稿？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // 关闭弹窗
                Navigator.pop(context); // 返回上一页 (EventSelectPage)
              },
              child: const Text("不保留", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // TODO: 保存逻辑
                Navigator.pop(ctx); // 关闭弹窗
                Navigator.of(context).popUntil((route) => route.isFirst); // 回到主页
              },
              child: const Text("保留", style: TextStyle(color: Color(0xFF2DC3C8))),
            ),
          ],
        );
      },
    );
  }

  // --- 逻辑 2：处理右上角保存 (返回主页) ---
  void _handleSavePress() {
    if (!_hasTitle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("请输入标题"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1A2226),
        ),
      );
      return;
    }
    // 保存逻辑...
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // --- 逻辑 3：[新增] 处理系统返回手势 (侧滑/物理键) ---
  // 要求：无论保留还是不保留，都直接返回 Diary 主页
  void _handleSystemBack() {
    // 1. 如果没有内容，直接回主页
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    // 2. 有内容，显示弹窗
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("保留记忆"),
          content: const Text("是否保存当前的日记草稿？"),
          actions: [
            // 选项 A：不保留
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // 关闭弹窗
                // 【修改点】系统返回手势下，不保留也直接回主页
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("不保留", style: TextStyle(color: Colors.grey)),
            ),
            // 选项 B：保留
            TextButton(
              onPressed: () {
                // TODO: 保存逻辑
                Navigator.pop(ctx); // 关闭弹窗
                // 保留并回主页
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("保留", style: TextStyle(color: Color(0xFF2DC3C8))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ▼▼▼ 使用 PopScope 包裹 Scaffold 来拦截系统返回手势 ▼▼▼
    return PopScope(
      canPop: false, // 禁止直接退出，必须经过 onPopInvokedWithResult 处理
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // 触发自定义的系统返回逻辑
        _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // --- 1. 顶部导航栏 ---
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // 左上角返回
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 28),
            onPressed: _handleBackPress, // 点击左上角依旧执行原来的逻辑
          ),
          // 中间日期
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "09",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 6),
              Text(
                "2025年12月",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // 右上角完成按钮
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: _hasTitle ? const Color(0xFF2DC3C8) : Colors.black54,
                size: 28,
              ),
              onPressed: _handleSavePress,
            ),
            const SizedBox(width: 10),
          ],
        ),

        // --- 2. 主体内容区域 ---
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // (1) 图片上传占位符
              GestureDetector(
                onTap: () {
                  // TODO: 调用相册
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30),
                      SizedBox(height: 8),
                      Text(
                        "上传照片",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // (2) 标题输入框
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Courier',
                ),
                decoration: const InputDecoration(
                  hintText: "给这篇日记起个标题吧...",
                  hintStyle: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 15),
              Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
              const SizedBox(height: 15),

              // (3) 正文输入框
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF666666),
                  fontFamily: 'Courier',
                ),
                decoration: const InputDecoration(
                  hintText: "来自日渐话痨的心情记：\n\n我很喜欢认真记录的你，告诉我今天过得怎么样吧！\n\n你可以用图片/文字和语音记录今天。\n\n点击编辑菜单展开更多功能，支持背景/字体/排版修改。",
                  hintStyle: TextStyle(
                    color: Color(0xFFDDDDDD),
                    height: 1.6,
                    fontFamily: 'Courier',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        // --- 3. 底部工具栏 ---
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 10,
              )
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 字数统计
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "共 $_charCount 字",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),

                // 工具栏
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildToolIcon(Icons.text_format),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Color(0xFF2DC3C8)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey, size: 26),
      onPressed: () {},
    );
  }
}