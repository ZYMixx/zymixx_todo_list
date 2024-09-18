import 'dart:io';

import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/presentation/app.dart';

class ServiceSystemTray{

  String _iconPath =
      'C:\\Users\\makc-\\AndroidStudioProjects\\zymixx_todo_list\\assets\\imready256х256.ico';
  String _debagIconPath =
      'C:\\Users\\makc-\\AndroidStudioProjects\\zymixx_todo_list\\assets\\app_icon.ico';

  Future<void> initSystemTray() async {
    final SystemTray systemTray = SystemTray();
    await systemTray.initSystemTray(
      iconPath: App.isRelease ? _iconPath : _debagIconPath,
    );
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => windowManager.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => windowManager.hide()),
      MenuItemLabel(label: 'Work Mod', onClicked: (menuItem) async => await App.changeAppWorkMod()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => windowManager.close()),
    ]);
    await systemTray.setContextMenu(menu);
    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
      }
    });
  }
}