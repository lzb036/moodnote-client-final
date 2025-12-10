import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Quill 11.5.0 Test',
      theme: ThemeData(
        fontFamily: '黑体', // 对应 pubspec.yaml 里的 family 名字
        useMaterial3: true,
      ),
      // 必须添加本地化代理，否则会报错
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  // 定义控制器
  final QuillController _controller = QuillController.basic();
  // [文档破坏性变更 #3] 定义 FocusNode
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在界面构建完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 强制设置当前光标的字体属性为 '黑体'
      // 这样工具栏检测到光标属性是 黑体，就会去 items 里找对应的名字（'黑体'）并显示出来
      _controller.formatSelection(Attribute.fromKeyValue('font', '黑体'));
      // Quill 默认支持的字号值有：'small', 'large', 'huge'
      _controller.formatSelection(Attribute.fromKeyValue('size', 'large'));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quill 11.5.0 编辑器测试'),
        backgroundColor: Colors.grey[100],
      ),
      body: Column(
        children: [
          // 1. 工具栏区域
          // [文档第8点] QuillToolbar 已移除，使用 QuillSimpleToolbar
          // [文档第2点] controller 直接传递，不再包裹在 config 中
          QuillSimpleToolbar(
            controller: _controller,
            config: const QuillSimpleToolbarConfig(
              // 1. 【核心代码】关闭全部分隔符
              showDividers: false,
              // 1. 【核心修改】删除“删除线”按钮 (文字中间有横线)
              showStrikeThrough: false,
              // 1. 【新增】删除“清除格式”按钮 (带斜杠的T)
              showClearFormat: false,
              showCodeBlock: false,  // 隐藏代码块
              // 1. 禁用 撤销 (Undo) 和 重做 (Redo) [左上角红圈]
              showUndo: false,
              showRedo: false,

              // 2. 禁用 上标 (Superscript) 和 下标 (Subscript) [X² 和 X₂]
              showSubscript: false,
              showSuperscript: false,

              // 3. 禁用 背景颜色 (Background Color) [油漆桶图标]
              showBackgroundColorButton: false,

              // 4. 禁用 搜索按钮 (Search) [放大镜图标]
              showSearchButton: false,

              // 5. 禁用 剪贴板操作 (Cut, Copy, Paste) [右下角剪刀、复制、粘贴图标]
              showClipboardCut: false,
              showClipboardCopy: false,
              showClipboardPaste: false,
              //自定义字体
              buttonOptions: QuillSimpleToolbarButtonOptions(
                //字体配置
                fontFamily: QuillToolbarFontFamilyButtonOptions(
                  // renderFontFamily: true, // 可选：如果你希望下拉菜单里的“宋体”两个字本身就用宋体显示，开启此项
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

          const Divider(height: 1, thickness: 1, color: Colors.grey),

          // 2. 编辑器区域
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                // [文档第2点] controller 直接传递
                controller: _controller,
                // [文档第5点] Configurations 改名为 Config
                config: const QuillEditorConfig(
                  placeholder: r'来自日渐话痨的心情记：\n\n我很喜欢认真记录的你，告诉我今天过得怎么样吧！\n\n你可以用图片/文字和语音记录今天。\n\n点击编辑菜单展开更多功能，支持背景/字体/排版修改。',
                  padding: EdgeInsets.zero,
                ),
                // [文档破坏性变更 #3] 显式传递 FocusNode 和 ScrollController
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
              ),
            ),
          ),
        ],
      ),
      // 添加一个浮动按钮来测试获取内容
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 获取纯文本内容
          final text = _controller.document.toPlainText();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('当前字数: ${text.length - 1}')),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}