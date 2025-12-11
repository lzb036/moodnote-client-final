import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'utils.dart';

class ApiService {
  // 单例 Dio 实例
  static final Dio _dio = _createDio();

  // 私有方法：配置 Dio
  static Dio _createDio() {
    BaseOptions options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      responseType: ResponseType.json,
    );

    Dio dio = Dio(options);

    // 添加日志拦截器 (Debug 模式下才打印)
    if (kDebugMode) {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print("发起请求: ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("收到响应: ${response.data}");
          return handler.next(response);
        },
        onError: (e, handler) {
          print("请求出错: ${e.message}");
          return handler.next(e);
        },
      ));
    }
    return dio;
  }

  // ==========================================
  //                业务接口区域
  // ==========================================

  /// [语音识别接口]
  /// filePath: 录音文件的本地路径
  /// 返回: 识别出的文字字符串
  static Future<String> recognizeSpeech(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(filePath, filename: 'speech.wav'),
      });

      // 发送请求 (注意：这里只需要写相对路径)
      Response response = await _dio.post('/speech/recognize/', data: formData);

      // 交给工具类处理，我们拿到的一定是 data 部分
      var data = DataUtils.handleResponse(response);

      return data['text']; // 返回具体的文字
    } catch (e) {
      rethrow; // 抛给 UI 层去显示错误
    }
  }

  //以后的其他网络请求接口就写在这下面


}