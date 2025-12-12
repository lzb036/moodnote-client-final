import 'dart:async';

import 'package:flutter/material.dart';

class ToastUtils {
  // 单例 OverlayEntry，确保全局只有一个弹窗
  static OverlayEntry? _overlayEntry;
  static Timer? _dismissTimer;

  /// 显示顶部弹窗
  /// [context] 上下文
  /// [message] 提示信息
  /// [isError] 是否为错误提示 (红色)，默认为 false (青色)
  static void showTopMessage(BuildContext context, String message, {bool isError = false}) {
    // 1. 如果已有弹窗，先移除
    _removeCurrentToast();

    // 2. 创建新的 OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // 距离顶部安全区往下一点 (刘海屏适配)
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _TopToastWidget(
            message: message,
            isError: isError,
          ),
        ),
      ),
    );

    // 3. 插入到屏幕最上层
    // 使用 try-catch 防止页面销毁时 context 失效报错
    try {
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      print("Toast 显示失败: $e");
      return;
    }

    // 4. 定时消失
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      _removeCurrentToast();
    });
  }

  // 移除当前弹窗
  static void _removeCurrentToast() {
    _dismissTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

// 内部使用的动画组件
class _TopToastWidget extends StatelessWidget {
  final String message;
  final bool isError;

  const _TopToastWidget({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // 下滑动画
      tween: Tween(begin: -100.0, end: 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError ? Colors.redAccent : const Color(0xFF2DC3C8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}