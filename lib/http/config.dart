
//存放网络请求相关的配置信息
class AppConfig {
  // 你的 Django 局域网地址
  // 可以使用电脑开热点给手机连让两者处于同一局域网
  //使用ipconfig中无线局域网适配器 WLAN的ipv4
  static const String baseUrl = "http://10.37.134.49:8000/api";

  // 连接超时时间 (毫秒)
  static const int connectTimeout = 10000;

  // 接收超时时间 (毫秒)
  static const int receiveTimeout = 10000;
}