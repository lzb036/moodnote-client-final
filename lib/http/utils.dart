
//处理网络请求后的数据

import 'package:dio/dio.dart';

class DataUtils {
  /// 统一处理响应数据
  /// 成功：返回 data 部分
  /// 失败：抛出 Exception
  static dynamic handleResponse(Response response) {
    // 1. 检查 HTTP 状态码
    if (response.statusCode == 200) {
      // 2. 检查业务状态码 (Django 返回的 code)
      // 注意：后端返回的是 int 类型的 200，还是字符串 '200'，这里做了兼容
      var code = response.data['code'];

      if (code == 200 || code == '200') {
        // 成功！只返回核心数据 data
        return response.data['data'];
      } else {
        // 业务失败 (比如 Token 过期、参数错误)
        throw Exception(response.data['message'] ?? "未知业务错误");
      }
    } else {
      // HTTP 失败 (404, 500 等)
      throw Exception("服务器异常: ${response.statusCode}");
    }
  }

  /// 统一处理错误信息 (给 UI 显示用)
  static String getErrorMsg(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return "连接超时，请检查网络";
        case DioExceptionType.receiveTimeout:
          return "服务器响应超时";
        case DioExceptionType.badResponse:
          return "服务器报错: ${e.response?.statusCode}";
        default:
          return "网络连接异常";
      }
    }
    // 如果是我们自己抛出的业务异常 (上面的 throw Exception)
    return e.toString().replaceAll("Exception: ", "");
  }
}