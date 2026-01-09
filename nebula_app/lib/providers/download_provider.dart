import 'package:flutter/material.dart';
import '../src/rust/api/download.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;

/// 任务状态
enum TaskStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

/// 下载任务信息
class DownloadTaskInfo {
  String id;
  String name;
  TaskStatus status;
  ProgressEvent? progress;
  String? error;
  int? totalSize;
  int? fileCount;
  DateTime? completedAt;
  String? savePath; // 添加保存路径，用于打开文件
  String? thumbnail;

  DownloadTaskInfo({
    required this.id,
    required this.name,
    required this.status,
    this.progress,
    this.error,
    this.totalSize,
    this.fileCount,
    this.completedAt,
    this.savePath,
    this.thumbnail,
  });
}

class DownloadProvider extends ChangeNotifier {
  final Map<String, DownloadTaskInfo> _tasks = {};
  StreamSubscription? _subscription;

  // 获取所有任务
  List<DownloadTaskInfo> get tasks => _tasks.values.toList();

  // 获取正在进行的任务
  List<DownloadTaskInfo> get activeTasks => _tasks.values
      .where((t) => t.status != TaskStatus.completed)
      .toList();

  // 获取已完成的任务
  List<DownloadTaskInfo> get completedTasks => _tasks.values
      .where((t) => t.status == TaskStatus.completed)
      .toList();

  // 初始化订阅
  void init() {
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() async {
    final stream = await subscribeEvents();
    _subscription = stream.listen((event) {
      _handleEvent(event);
    });
  }

  void _handleEvent(NebulaEvent event) {
    switch (event) {
      case NebulaEvent_TaskAdded(:final taskId, :final name, :final thumbnail):
        _tasks[taskId] = DownloadTaskInfo(
          id: taskId,
          name: name,
          status: TaskStatus.pending,
          thumbnail: thumbnail,
        );
        notifyListeners();
        
      case NebulaEvent_TaskStarted(:final taskId):
        if (_tasks.containsKey(taskId)) {
          _tasks[taskId]!.status = TaskStatus.downloading;
          notifyListeners();
        }

      case NebulaEvent_ProgressUpdated(:final taskId, :final progress):
        if (_tasks.containsKey(taskId)) {
          _tasks[taskId]!.progress = progress;
          // 如果还没有总大小，尝试从进度中获取
          if (_tasks[taskId]!.totalSize == null || _tasks[taskId]!.totalSize == 0) {
             _tasks[taskId]!.totalSize = progress.totalSize.toInt();
          }
          notifyListeners();
        }

      case NebulaEvent_TaskCompleted(:final taskId):
        if (_tasks.containsKey(taskId)) {
          _tasks[taskId]!.status = TaskStatus.completed;
          _tasks[taskId]!.completedAt = DateTime.now();
          notifyListeners();
        }

      case NebulaEvent_TaskFailed(:final taskId, :final error):
        if (_tasks.containsKey(taskId)) {
          _tasks[taskId]!.status = TaskStatus.failed;
          _tasks[taskId]!.error = error;
          notifyListeners();
        }

      case NebulaEvent_MetadataReceived(:final taskId, :final name, :final totalSize, :final fileCount):
        if (_tasks.containsKey(taskId)) {
          _tasks[taskId]!.name = name;
          _tasks[taskId]!.totalSize = totalSize.toInt();
          _tasks[taskId]!.fileCount = fileCount.toInt();
          notifyListeners();
        }
        
      case NebulaEvent_TaskPaused(:final taskId):
        if (_tasks.containsKey(taskId)) {
           _tasks[taskId]!.status = TaskStatus.paused;
           notifyListeners();
        }
        
      case NebulaEvent_TaskResumed(:final taskId):
        if (_tasks.containsKey(taskId)) {
           _tasks[taskId]!.status = TaskStatus.downloading;
           notifyListeners();
        }
        
      case NebulaEvent_TaskRemoved(:final taskId):
        if (_tasks.containsKey(taskId)) {
           _tasks.remove(taskId);
           notifyListeners();
        }
    }
  }

  // 操作方法代理
  Future<void> addDownload(String url) async {
     // 实际添加逻辑通常在 UI 层处理（因为需要 context 显示 dialog）
     // 这里主要负责状态同步，但 add_download API 调用后会通过 Event 触发状态更新
     // 所以不需要手动在这里添加 _tasks
  }

  Future<void> openTaskFile(String taskId) async {
    try {
      // ignore: prefer_const_constructors
      await openFile(taskId: taskId);
    } catch (e) {
      debugPrint('打开文件失败: $e');
    }
  }

  Future<void> openTaskFolder(String taskId) async {
    try {
      await openFolder(taskId: taskId);
    } catch (e) {
       debugPrint('打开文件夹失败: $e');
    }
  }
  
  Future<void> removeTask(String taskId, {bool deleteFile = false}) async {
    await cancelDownload(taskId: taskId, deleteFiles: deleteFile);
  }
}
