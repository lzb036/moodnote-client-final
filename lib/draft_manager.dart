
//负责在内存中临时拿着数据，直到你回到主页才清空。

class DiaryDraftManager {
  // 单例模式：确保全局只有一个实例，数据共享
  static final DiaryDraftManager _instance = DiaryDraftManager._internal();
  factory DiaryDraftManager() => _instance;
  DiaryDraftManager._internal();

  // 暂存的数据字段
  int weatherIndex = 0; // 默认选中第0个天气
  Set<int> moodIndices = {0}; // 默认选中第0个心情
  Set<int> eventIndices = {0}; // 默认选中第0个事件

  // 清空数据的方法 (回到主页和进入weather界面时都调用)
  void clear() {
    weatherIndex = 0;
    moodIndices = {0};
    eventIndices = {0};
  }
}