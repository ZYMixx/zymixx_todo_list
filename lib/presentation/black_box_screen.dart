import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/app.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/black_box_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_bottom_navigator_screen.dart';

class BlackBoxScreen extends StatelessWidget {
  const BlackBoxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Get.find<BlackBoxBloc>()..add(LoadNotesEvent()),
      child: BlackBoxFolderWidget(),
    );
  }
}

class BlackBoxFolderWidget extends StatefulWidget {
  @override
  _BlackBoxFolderWidgetState createState() => _BlackBoxFolderWidgetState();
}

class _BlackBoxFolderWidgetState extends State<BlackBoxFolderWidget> {
  double folderExtent = 140;

  @override
  Widget build(BuildContext context) {
    var foldersKeys =
        context.select((BlackBoxBloc bloc) => bloc.state.folders.keys.toList(growable: false));
    var foldersImage =
        context.select((BlackBoxBloc bloc) => bloc.state.folders.values.toList(growable: false));
    return Theme(
      data: ThemeData(canvasColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Gap(8),
            Text(
              'Чёрный Ящик',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Flexible(
              child: ReorderableGridView.extent(
                padding: EdgeInsets.all(8),
                maxCrossAxisExtent: folderExtent,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0,
                children: <Widget>[
                  for (int index = 0; index < foldersKeys.length; index++)
                    GestureDetector(
                      key: ValueKey(foldersKeys[index]),
                      onSecondaryTapDown: (details) {
                        _showContextMenu(
                            context, details.globalPosition, index, foldersImage[index]);
                      },
                      child: InkWell(
                        onTap: () {
                          ToolNavigator.push(screen: NotesScreen(folderName: foldersKeys[index]));
                        },
                        child: Stack(
                          children: [
                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/folder_icon.png'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: GridTile(
                                  child: Center(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0, right: 15, left: 15),
                              child: ClipPath(
                                clipper: HexagonClipper(),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: folderExtent / 2 + 10,
                                    child: DecoratedBox(
                                      decoration: foldersImage[index] != ''
                                          ? BoxDecoration(
                                              border: Border.all(width: 2),
                                              image: DecorationImage(
                                                  image: FileImage(File(foldersImage[index])),
                                                  fit: BoxFit.cover),
                                            )
                                          : BoxDecoration(),
                                      child: Center(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0, left: 10, top: 20),
                              child: Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ColoredBox(
                                        color: Colors.black87,
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0, top: 2),
                                          child: Text(
                                            foldersKeys[index],
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              letterSpacing: -0.2,
                                              wordSpacing: -0.5,
                                              height: 0.9,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                onReorder: (oldIndex, newIndex) {
                  Log.i('newIndex ${newIndex} - oldIndex ${oldIndex}');

                  if (newIndex < oldIndex) {
                    Get.find<BlackBoxBloc>().add(ReorderFolderEvent(oldIndex, newIndex));
                  } else {
                    Get.find<BlackBoxBloc>().add(ReorderFolderEvent(oldIndex, newIndex));
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addFolder,
          child: Icon(Icons.add),
          tooltip: 'Add Folder',
        ),
      ),
    );
  }

  void _addFolder() {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Folder"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Get.find<BlackBoxBloc>().add(AddFolderEvent(folderName: _controller.text));
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _renameFolder(int index) {
    TextEditingController _controller = TextEditingController();
    _controller.text = Get.find<BlackBoxBloc>().state.folders.keys.toList()[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rename Folder"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Folder name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteFolder(int index) {
    final folderName = Get.find<BlackBoxBloc>().state.folders.keys.toList()[index];
    Get.find<BlackBoxBloc>().add(DeleteFolderEvent(folderName: folderName));
  }

  void _addImageFolder(int index) {
    final folderName = Get.find<BlackBoxBloc>().state.folders.keys.toList()[index];
    Get.find<BlackBoxBloc>().add(AddImageFolderEvent(folderName: folderName));
  }

  void _delImageFolder(int index) {
    final folderName = Get.find<BlackBoxBloc>().state.folders.keys.toList()[index];
    Get.find<BlackBoxBloc>().add(DelImageFolderEvent(folderName: folderName));
  }

  void _showContextMenu(
      BuildContext context, Offset offset, int index, String folderImagePath) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        offset & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Text("Set Image"),
          value: "Set Image",
        ),
        if (folderImagePath != '')
          PopupMenuItem(
            child: Text("Del Image"),
            value: "Del Image",
          ),
        PopupMenuItem(
          child: Text("Del Folder"),
          value: "Del Folder",
        ),
      ],
    ).then((value) {
      if (value == "Rename") {
        _renameFolder(index);
      } else if (value == "Del Folder") {
        _deleteFolder(index);
      } else if (value == 'Set Image') {
        _addImageFolder(index);
      } else if (value == 'Del Image') {
        _delImageFolder(index);
      }
    });
  }
}

class NotesScreen extends StatefulWidget {
  final String folderName;

  NotesScreen({required this.folderName});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      child: BlocProvider(
        create: (_) => Get.find<BlackBoxBloc>(),
        child: MyScreenBoxDecorationWidget(
          child: Scaffold(
            appBar: AppBar(
              title: Text('${widget.folderName}'),
            ),
            body: Stack(
              children: [
                BlocBuilder<BlackBoxBloc, BlackBoxState>(builder: (context, state) {
                  Log.e('rebuild');
                  var notes = context
                      .select((BlackBoxBloc bloc) => bloc.state.notes.entries)
                      .where((entry) => entry.value['folderName'] == widget.folderName)
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ReorderableListView.builder(
                      onReorder: (int oldIndex, int newIndex) {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        Log.e('oldIndex $oldIndex - newIndex $newIndex');
                        Get.find<BlackBoxBloc>()
                            .add(ReorderNoteEvent(widget.folderName, oldIndex, newIndex));
                        Future.delayed(Duration.zero).then((_) {
                          setState(() {});
                        });
                      },
                      itemCount: notes.length,
                      itemBuilder: (context, itemId) {
                        return InkWell(
                          key: ValueKey(itemId),
                          onTap: () {
                            _navigateToNoteDetail(notes[itemId].key);
                          },
                          onLongPress: () {
                            _deleteNoteDialog(
                                context, notes[itemId].key, notes[itemId].value['folderName']);
                          },
                          child: Hero(
                            tag: 'note_${notes[itemId].key}',
                            child: Material(
                              textStyle: TextStyle(color: Colors.white),
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, bottom: 5.0, right: 6, left: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: ToolThemeData.itemBorderColor,
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 4.0, left: 6),
                                      child: Text(
                                        (notes[itemId].value['noteText']!).capStart()!,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Consolas',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    color: Colors.black,
                    child: MoveWindow(onDoubleTap: () => {}),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.find<BlackBoxBloc>()
                    .add(AddNoteEvent(folderName: widget.folderName, noteText: ''));
              },
              child: Icon(Icons.add),
              tooltip: 'Add Note',
            ),
          ),
        ),
      ),
    );
  }

  void _deleteNoteDialog(BuildContext context, String key, String? folderName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Get.find<BlackBoxBloc>().add(DeleteNoteEvent(key: key, folderName: folderName));
                Navigator.pop(context);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNoteDetail(String noteKey) {
    ToolNavigator.push(screen: EditNoteScreen(noteKey: noteKey));
  }
}

class EditNoteScreen extends StatelessWidget {
  final String noteKey;

  EditNoteScreen({required this.noteKey});

  @override
  Widget build(BuildContext context) {
    String textNote = Get.find<BlackBoxBloc>().state.notes[noteKey]?['noteText'] ?? 'no data';
    String folderName = Get.find<BlackBoxBloc>().state.notes[noteKey]?['folderName'] ?? 'no data';
    TextEditingController _controller = TextEditingController(text: textNote);
    return MyScreenBoxDecorationWidget(
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (textNote == _controller.text){
              ToolNavigator.pop();
            } else {
              bool? saveData = await _confirmSaveOnExit(
                  bContext: context, folderName: folderName, notedText: _controller.text);
              if (saveData == null) {
                return;
              }
              else if (saveData) {
                Get.find<BlackBoxBloc>().add(ChangeNoteEvent(
                    folderName: folderName, noteText: _controller.text, noteKey: noteKey));
              }
              ToolNavigator.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Edit Note'),
            ),
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    color: Colors.black,
                    child: MoveWindow(onDoubleTap: () => {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                  child: Hero(
                    tag: 'note_${noteKey}',
                    child: Material(
                      color: Colors.black,
                      textStyle: TextStyle(color: Colors.white),
                      child: Container(
                        child: TextSelectionTheme(
                          data: TextSelectionThemeData(
                            selectionColor: ToolThemeData.itemBorderColor,
                            cursorColor: ToolThemeData.highlightColor,
                          ),
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            maxLines: null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.red,
                              labelText: 'Note',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.find<BlackBoxBloc>().add(ChangeNoteEvent(
                    folderName: folderName, noteText: _controller.text, noteKey: noteKey));
                ToolNavigator.pop();
              },
              child: Icon(Icons.save),
              tooltip: 'Save Note',
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmSaveOnExit({
    required BuildContext bContext,
    required String folderName,
    required String notedText,
  }) async {
    return await showDialog<bool>(
      context: bContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Выйти без сохранения?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text("Save", style: TextStyle(color: ToolThemeData.mainGreenColor),),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text("Exit", style: TextStyle(color: ToolThemeData.highlightColor),),
            ),
          ],
        );
      },
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  //для png обложки
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, 53)
      ..lineTo(4, size.height)
      ..lineTo(size.width - 4, size.height)
      ..lineTo(size.width, 5)
      ..lineTo(85, 0)
      ..lineTo(50, 53)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
