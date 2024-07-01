import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:watcher/watcher.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:path/path.dart' as path;
import 'package:zymixx_todo_list/presentation/app.dart';

class ServiceImagePluginWork {
  final String drawingAppPath =
      'D:\\myApps\\plugins\\plugin_todo_draw\\plugin_todo_draw.exe';
  final String viewingAppPath =
      'D:\\myApps\\plugins\\plugin_todo_image_viewer\\plugin_todo_image_viewer.exe';

  List<File> filesList = [];

  loadImageData() {
    filesList.clear();
    final directory = Directory(App.directoryPath);
    if (!directory.existsSync()) {
      Log.e('Directory does not exist');
      return;
    }
    filesList = directory.listSync().whereType<File>().where((file) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      return validFileNameFormat(fileName);
    }).toList();
    for (var file in filesList) {
    }
  }

  File? checkFileExist(TodoItem todoItem) {
    String validName = validFileName(title: todoItem.title, id: todoItem.id);
    for (var file in filesList) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      if (validFileNameFormat(validName)) {
        if (fileName.contains(validName)) {
          StackTrace.current;
          Log.i('validFileName $validFileName');

          return file;
        }
      }
    }
    return null;
  }

  openImage(File imageFile) {
    final command = '$viewingAppPath "${imageFile.path}"';
    Process.run(command, []).then((result) {
      Log.i('Viewing app output: ${result.stdout}');
      Log.i('Viewing app error: ${result.stderr}');
    });
  }

  drawImage({required String title, required int id, required Function updateCallBack}) {
    final fileName = validFileName(title: title, id: id);
    final command = '"$drawingAppPath" $fileName';
    Process.run(command, []).then((result) {
      Log.i('Drawing app output: ${result.stdout}');
      Log.i('Drawing app error: ${result.stderr}');
    });
    watchDirectory(updateCallBack);
  }

  String validFileName({required String title, required int id}) {
    String sanitizedTitle = title.replaceAll(RegExp(r'[^\w\sА-Яа-я]'), '').replaceAll(' ', '_');
    String validTitle = '${sanitizedTitle}_$id.png';
    return validTitle;
  }

  bool validFileNameFormat(String fileName) {
    final regex = RegExp(r'^[\w\sА-Яа-я]+_\d+\.png$');
    return regex.hasMatch(fileName);
  }

  Future<void> selectAndSetTodoImage(
      {required TodoItem todoItem, required Function updateCallBack}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      File originalFile = File(result.files.single.path!);
      String newFileName = validFileName(title: todoItem.title, id: todoItem.id);
      String newPath = path.join(App.directoryPath, newFileName);

      try {
        if (File(newPath).existsSync()) {
          File(newPath).deleteSync();
        }
        originalFile.copySync(newPath);
        Log.i('File copied to: $newPath');
        loadImageData();
        updateCallBack.call();
      } catch (e) {
        Log.i('Failed to copy file: $e');
      }
    } else {
      Log.i('No file selected');
    }
  }

  deleteImage({required TodoItem todoItem, required Function updateCallBack}) {
    String fileName = validFileName(title: todoItem.title, id: todoItem.id);
    String filePath = path.join(App.directoryPath, fileName);

    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        Log.i('File deleted: $filePath');
        loadImageData();
        updateCallBack.call();
      } else {
        Log.i('File does not exist: $filePath');
      }
    } catch (e) {
      Log.i('Failed to delete file: $e');
    }
  }

  // Следит за новыми файлами в директории и вызывает колбэк
  void watchDirectory(callback) {
    final directoryWatcher = DirectoryWatcher(App.directoryPath);
    StreamSubscription? watcherSub;
    watcherSub = directoryWatcher.events.listen((event) {
      if (event.type == ChangeType.ADD) {
        loadImageData();
        callback.call();
        watcherSub?.cancel();
      }
    });
    Future.delayed(Duration(seconds: 560)).then((_) {
      watcherSub?.cancel();
    });
  }
}
