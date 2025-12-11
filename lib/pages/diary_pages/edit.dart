import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:record/record.dart'; // 录音
import 'package:path_provider/path_provider.dart'; // 路径
import 'package:permission_handler/permission_handler.dart'; // 权限
import '../../http/service.dart';
import '../../http/utils.dart';

class DiaryEditPage extends StatefulWidget {
  const DiaryEditPage({super.key});

  @override
  State<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> with WidgetsBindingObserver {
  // --- 基础控制器 ---
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _pageScrollController = ScrollController();
  final GlobalKey _editorAreaKey = GlobalKey();

  // --- 状态变量 ---
  int _charCount = 0;
  bool _hasTitle = false;
  int _selectedToolIndex = -1; // -1: 无, 0: 富文本工具, 1: 语音工具
  bool _isKeyboardVisible = false;
  bool _isDefaultStyleApplied = false;

  // --- 语音识别相关变量 ---
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false; // 是否正在录音
  bool _isRecognizing = false; // 是否正在识别中
  String _voiceTip = "按住说话"; // 提示文字

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioRecorder = AudioRecorder();

    _titleController.addListener(_checkInput);
    _quillController.addListener(_checkInput);
    _editorFocusNode.addListener(_handleEditorFocusChange);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.removeListener(_handleEditorFocusChange);
    _editorFocusNode.dispose();
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final newValue = bottomInset > 0.0;

    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
        // 键盘弹起时，收起自定义工具栏
        if (_isKeyboardVisible) {
          _selectedToolIndex = -1;
        }
      });

      if (_isKeyboardVisible && _editorFocusNode.hasFocus) {
        _scrollToEditor();
      }
    }
  }

  // 语音识别核心逻辑
  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        await Permission.microphone.request();
        if (!await _audioRecorder.hasPermission()) {
          _showSnack("请授予麦克风权限");
          return;
        }
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/speech_input.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(config, path: path);

      setState(() {
        _isRecording = true;
        _voiceTip = "松开 结束";
      });
    } catch (e) {
      debugPrint("录音启动失败: $e");
      _showSnack("录音启动失败");
    }
  }

  Future<void> _stopAndRecognize() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _voiceTip = "正在识别...";
        _isRecognizing = true;
      });

      if (path != null) {
        await _uploadAndInsertText(path);
      }
    } catch (e) {
      debugPrint("停止录音失败: $e");
      setState(() {
        _isRecognizing = false;
        _voiceTip = "按住说话";
      });
    }
  }

  Future<void> _uploadAndInsertText(String filePath) async {
    try {
      // 直接调用一句话即可！
      String text = await ApiService.recognizeSpeech(filePath);

      if (text.isNotEmpty) {
        _insertTextToEditor(text);
        setState(() => _voiceTip = "识别成功");
      }
    } catch (e) {
      // 使用工具类获取友好的错误提示
      String msg = DataUtils.getErrorMsg(e);
      _showSnack("失败: $msg");
      setState(() => _voiceTip = "按住说话");
      debugPrint("错误详情: $e");
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_isRecording) {
          setState(() {
            _isRecognizing = false;
            _voiceTip = "按住说话";
          });
        }
      });
    }
  }

  // 插入文字后，强制夺回光标焦点
  void _insertTextToEditor(String text) {
    if (text.isEmpty) return;

    // 获取插入位置：优先用光标位置，如果光标丢失(-1)则追加到末尾
    int index = _quillController.document.length - 1;
    if (_quillController.selection.baseOffset >= 0) {
      index = _quillController.selection.baseOffset;
    }

    // 插入文字
    _quillController.document.insert(index, text);

    // 移动光标到文字后面
    _quillController.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );

    // 强制让编辑器重新获得焦点，键盘会重新弹起，光标出现
    if (!_editorFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
      // 如果你想保持键盘不弹起只显示光标，Flutter 做不到，
      // 因为获得焦点必然伴随键盘弹起。
      // 所以这里的逻辑是：说完话 -> 自动切回键盘模式 -> 用户可以继续打字
    }
  }

  // 辅助逻辑
  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1A2226),
    ));
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
    // 获得焦点时（如键盘弹起），收起语音面板
    if (_editorFocusNode.hasFocus && _selectedToolIndex != -1) {
      setState(() {
        _selectedToolIndex = -1;
      });
    }
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
      _showSnack("请输入标题");
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

  // UI
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
        resizeToAvoidBottomInset: false,
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
                      scrollable: false,
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

  Widget _buildBottomBar() {
    // 获取键盘高度
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 核心修改：如果面板被选中（_selectedToolIndex != -1），则不再添加键盘高度的 Padding。
    // 这样避免了 "键盘高度 + 面板高度" 同时存在导致溢出。
    final double bottomPadding = _selectedToolIndex != -1 ? 0 : keyboardHeight;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 字数统计与工具栏
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
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
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

          // 扩展面板
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            // 当选中工具时显示高度，否则为0
            height: _selectedToolIndex != -1 ? 200 : 0,
            child: _selectedToolIndex != -1
                ? _buildPanelContent()
                : const SizedBox(),
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
        color: Colors.white,
      ),
      child: _selectedToolIndex == 0
          ? Column(
        children: [
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
              buttonOptions: QuillSimpleToolbarButtonOptions(
                fontFamily: QuillToolbarFontFamilyButtonOptions(
                  items: {
                    '黑体': '黑体',
                    '宋体': '宋体',
                    '楷体': '楷体',
                    '手写体': '手写体'
                  },
                ),
                fontSize: QuillToolbarFontSizeButtonOptions(
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
        // 语音录制面板
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _voiceTip,
              style: TextStyle(
                color: _isRecording ? Colors.redAccent : Colors.grey,
                fontSize: 16,
                fontWeight:
                _isRecording ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopAndRecognize(),
              onLongPressCancel: () => _stopAndRecognize(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isRecording ? 100 : 80,
                height: _isRecording ? 100 : 80,
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.redAccent.withOpacity(0.1)
                      : const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _isRecording
                          ? Colors.redAccent
                          : Colors.transparent,
                      width: 2),
                  boxShadow: _isRecording
                      ? [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                      : [],
                ),
                child: _isRecognizing
                    ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2DC3C8),
                  ),
                )
                    : Icon(
                  Icons.mic,
                  size: _isRecording ? 40 : 32,
                  color: _isRecording
                      ? Colors.redAccent
                      : const Color(0xFF2DC3C8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, int index) {
    final bool isSelected = _selectedToolIndex == index;
    return IconButton(
      icon: Icon(icon,
          color: isSelected ? const Color(0xFF2DC3C8) : Colors.grey, size: 26),
      onPressed: () {
        setState(() {
          if (_selectedToolIndex == index) {
            _selectedToolIndex = -1;
          } else {
            _selectedToolIndex = index;
            // 点击工具栏时，收起键盘，导致失去焦点是正常的
            // 我们在语音识别完成后会自动 requestFocus 拿回焦点
            FocusScope.of(context).unfocus();
          }
        });
      },
    );
  }
}