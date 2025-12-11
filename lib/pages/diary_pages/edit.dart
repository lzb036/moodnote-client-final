import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DiaryEditPage extends StatefulWidget {
  const DiaryEditPage({super.key});

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();

  // 页面整体滚动控制器
  final ScrollController _pageScrollController = ScrollController();
  // 用于定位编辑器位置的Key
  final GlobalKey _editorAreaKey = GlobalKey();

  int _charCount = 0;
  bool _hasTitle = false;

  // -1: 无, 0: 富文本工具, 1: 语音工具
  int _selectedToolIndex = -1;

  // 记录键盘状态
  bool _isKeyboardVisible = false;

  //标记用户第一次唤醒富文本编辑器
  bool _isDefaultStyleApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _titleController.addListener(_checkInput);
    // QuillController 的监听器会在文字变化 或 光标移动 时触发
    _quillController.addListener(_checkInput);
    _editorFocusNode.addListener(_handleEditorFocusChange);


  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.removeListener(_handleEditorFocusChange);
    _editorFocusNode.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  // 监听键盘高度变化
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newValue = bottomInset > 0.0;

    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;

        // 如果键盘弹起了，强制收起我们的自定义工具栏
        if (_isKeyboardVisible) {
          _selectedToolIndex = -1;
        }
      });

      if (_isKeyboardVisible) {
        if (_editorFocusNode.hasFocus) {
          _scrollToEditor();
        }
      }
    }
  }

  void _scrollToEditor() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final context = _editorAreaKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleEditorFocusChange() {
    // 如果编辑器获得了焦点（意味着键盘要弹起），收起自定义工具栏
    if (_editorFocusNode.hasFocus && _selectedToolIndex != -1) {
      setState(() {
        _selectedToolIndex = -1;
      });
    }

    // 在用户第一次点击编辑器时，才设置默认格式
    if (_editorFocusNode.hasFocus && !_isDefaultStyleApplied) {
      _isDefaultStyleApplied = true;
      _quillController.formatSelection(Attribute.fromKeyValue('font', '黑体'));
      _quillController.formatSelection(Attribute.fromKeyValue('size', 'large'));
    }
  }

  void _checkInput() {
    if (!mounted) return;

    setState(() {
      var textLength = _quillController.document.toPlainText().length;
      _charCount = textLength > 1 ? textLength - 1 : 0;
      _hasTitle = _titleController.text.trim().isNotEmpty;
    });

    // 光标跟随逻辑
    if (_isKeyboardVisible && _editorFocusNode.hasFocus) {
      final selection = _quillController.selection;
      final docLength = _quillController.document.length;
      bool isAtBottom = selection.baseOffset >= docLength - 10;

      if (isAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageScrollController.hasClients) {
            _pageScrollController.animateTo(
              _pageScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _handleBackPress() {
    bool isContentEmpty = _quillController.document.toPlainText().trim().isEmpty;
    if (_titleController.text.isEmpty && isContentEmpty) {
      Navigator.pop(context);
      return;
    }
    _showExitDialog();
  }

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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleSystemBack() {
    bool isContentEmpty = _quillController.document.toPlainText().trim().isEmpty;
    if (_titleController.text.isEmpty && isContentEmpty) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    _showExitDialog();
  }

  void _showExitDialog() {
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
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("不保留", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true, // 允许Body随底部高度调整

        // 移除 Stack，Body 只是一个 ScrollView
        body: CustomScrollView(
          controller: _pageScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePlaceholder(),
                    const SizedBox(height: 20),
                    _buildTitleField(),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: GestureDetector(
                onTap: () {
                  // 点击内容区域空白处：收起键盘，也收起工具栏
                  FocusScope.of(context).unfocus();
                  if (_selectedToolIndex != -1) {
                    setState(() {
                      _selectedToolIndex = -1;
                    });
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  key: _editorAreaKey,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    focusNode: _editorFocusNode,
                    config: QuillEditorConfig(
                      scrollable: false, // 禁用编辑器内部滚动，交由外层CustomScrollView处理
                      expands: false,
                      autoFocus: false,
                      placeholder: r'来自日渐话痨的心情记：\n\n我很喜欢认真记录的你，告诉我今天过得怎么样吧！\n\n你可以用图片/文字和语音记录今天。\n\n点击编辑菜单展开更多功能，支持背景/字体/排版修改。',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // 所有底部交互移入 BottomNavigationBar
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 28),
        onPressed: _handleBackPress,
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text("09", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: '楷体', color: Colors.black87)),
          SizedBox(width: 6),
          Text("2025年12月", style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: '楷体')),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.check_circle_outline, color: _hasTitle ? const Color(0xFF2DC3C8) : Colors.black54, size: 28),
          onPressed: _handleSavePress,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: () {},
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
            Text("上传照片", style: TextStyle(fontSize: 12, color: Colors.grey))
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      decoration: const InputDecoration(
        hintText: "给这篇日记起个标题吧...",
        hintStyle: TextStyle(color: Color(0xFFCCCCCC), fontWeight: FontWeight.bold),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // 重构底部栏
  Widget _buildBottomBar() {
    // 获取当前系统的键盘高度
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // 给底部添加 padding，其高度等于键盘高度。
      // 这样当系统键盘弹起时，我们的工具栏图标会被顶在键盘上方。
      // 当自定义面板开启时，keyboardHeight 为 0，padding 为 0。
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              offset: const Offset(0, -2),
              blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 包裹内容高度
        children: [
          // 字数统计与工具栏图标 (始终显示)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 20, top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text("共 $_charCount 字",
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildToolIcon(Icons.text_format, 0),
                    _buildToolIcon(Icons.mic, 1),
                  ],
                ),
              ),
            ],
          ),

          // 扩展功能面板 (动画显示)
          // 当 _selectedToolIndex 有值时，高度设为 200，Scaffold 会感知到这个高度变化
          // 并自动将 Body 向上推 200，实现“顶起”效果。
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: _selectedToolIndex != -1 ? 200 : 0,
            child: _selectedToolIndex != -1
                ? _buildPanelContent()
                : const SizedBox(), // 不显示时放个空盒子
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    if (_selectedToolIndex == -1) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: _selectedToolIndex == 0
          ? Column(
        children: [
          // flutter_quill 的工具栏
          QuillSimpleToolbar(
            controller: _quillController,
            config: const QuillSimpleToolbarConfig(
              showDividers: false,
              showStrikeThrough: false,
              showClearFormat: false,
              showCodeBlock: false,
              showUndo: false,
              showRedo: false,
              showSubscript: false,
              showSuperscript: false,
              showBackgroundColorButton: false,
              showSearchButton: false,
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: true,
              toolbarSectionSpacing: 0,
              //自定义字体
              buttonOptions: QuillSimpleToolbarButtonOptions(
                //字体配置
                fontFamily: QuillToolbarFontFamilyButtonOptions(
                  items: {
                    // '显示在菜单的名字': 'pubspec.yaml中配置的family名字'
                    '黑体':'黑体',
                    '宋体': '宋体',
                    '楷体': '楷体',
                    '手写体': '手写体'
                  },
                ),
                // 字号配置
                fontSize: QuillToolbarFontSizeButtonOptions(
                  // 自定义列表：只写你想显示的选项，不写'Clear'它就消失了
                  items: {
                    '小字号': 'small',
                    '大字号': 'large',
                    '超大号': 'huge',
                  },
                ),
              ),
            ),
          ),
        ],
      )
          : Center(
        // 语音录制面板占位 (Index 1)
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.mic, size: 48, color: Color(0xFF2DC3C8)),
            SizedBox(height: 10),
            Text("按住说话", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, int index) {
    final bool isSelected = _selectedToolIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF2DC3C8) : Colors.grey, size: 26),
      onPressed: () {
        setState(() {
          if (_selectedToolIndex == index) {
            // 如果点击的是当前已选中的图标，则关闭面板
            _selectedToolIndex = -1;
          } else {
            // 选中新的图标，并强制收起系统键盘
            _selectedToolIndex = index;
            FocusScope.of(context).unfocus();
          }
        });
      },
    );
  }
}