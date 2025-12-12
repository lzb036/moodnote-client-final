import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 定义三种refresh状态，用于welcome界面中的判断
enum AuthStatus {
  valid,        // 有效 -> 进主页
  invalid,      // 身份失效 (401等) -> 欢迎页 + 弹窗 (需清除Token)
  networkError, // 网络错误 (超时/断网) -> 欢迎页 + 弹窗 (保留Token)
  none          // 无记录 -> 欢迎页
}

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

  /// [用户登录接口]
  static Future<void> login(String username, String password) async {
    try {
      // 1. 发起请求
      // 后端主路由定义的是 path('api/token/', ...)，BaseUrl 包含了 /api
      // 所以这里只需要写 '/token/'
      Response response = await _dio.post('/token/', data: {
        'username': username,
        'password': password,
      });

      // 2. 使用你的 DataUtils 处理响应 (它会校验 code==200 并返回 data)
      var data = DataUtils.handleResponse(response);

      // 3. 保存 Token 和用户信息到本地
      // 你的 Serializer 返回的数据结构是：
      // { 'user_id': ..., 'username': ..., 'access': ..., 'refresh': ... }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      await prefs.setInt('user_id', data['user_id']);
      await prefs.setString('username', data['username']);

      // 设置登录状态标记
      await prefs.setBool('is_logged_in', true);

    } catch (e) {
      rethrow; // 抛出错误给 UI 显示
    }
  }

  /// [启动检查：尝试使用refresh刷新 Token，用于判断登录信息是否过期，由于token的存在时间非常短，所以不使用token来判断]
  static Future<AuthStatus> tryRefreshToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refresh_token');

      // 检查本地是否存在refresh
      if (refreshToken == null || refreshToken.isEmpty) {
        return AuthStatus.none;
      }

      // 存在的话去后端验证有效性
      Response response = await _dio.post('/token/refresh/', data: {
        'refresh': refreshToken,
      });

      var data = DataUtils.handleResponse(response);

      // 验证成功返回valid
      if (data['access'] != null) {
        await prefs.setString('access_token', data['access']);
      }
      // 如果后端配置了旋转 refresh，也要更新 refresh
      if (data['refresh'] != null) {
        await prefs.setString('refresh_token', data['refresh']);
      }
      return AuthStatus.valid;
    } catch (e) {
      //验证失败比如说过期，或者网络问题
      if (e is DioException) {
        // 如果是超时 或 网络连接中断
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          //直接返回，等用户网络好了还可以自动登录，不会删除数据给用户造成不好的体验
          return AuthStatus.networkError;
        }
      }

      // 其他情况，视为身份失效
      //清除脏数据，防止死循环
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return AuthStatus.invalid;
    }
  }



}