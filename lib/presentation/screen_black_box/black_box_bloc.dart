import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/presentation/app.dart';

import 'black_box_screen.dart';

const allFolderKey = 'all_folder_key';

class BlackBoxBloc extends Bloc<BlackBoxEvent, BlackBoxState> {
  BlackBoxBloc() : super(BlackBoxState(folders: {}, notes: {})) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<ChangeNoteEvent>(_onChangeNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<AddFolderEvent>(_onAddFolder);
    on<DelImageFolderEvent>(_onDelImageFolder);
    on<AddImageFolderEvent>(_onAddImageFolder);
    on<DeleteFolderEvent>(_onDeleteFolder);
    on<ReorderFolderEvent>(_onReorderFolderEvent);
    on<ReorderNoteEvent>(_onReorderNoteEvent);
  }

  @override
  Future<void> close() async {}

  void _onReorderNoteEvent(ReorderNoteEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final folderNotes = prefs.getStringList(event.folderName) ?? [];
    for (var item in folderNotes) {
      Log.d(prefs.getString(item));
    }

    final noteToMove = folderNotes.removeAt(event.oldIndex);
    folderNotes.insert(event.newIndex, noteToMove);

    await prefs.setStringList(event.folderName, folderNotes);

    this.add(LoadNotesEvent());
  }

  void _onReorderFolderEvent(ReorderFolderEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedFolders = Map<String, String>.from(state.folders);

    final foldersList = updatedFolders.entries.toSet().toList();
    final folderToMove = foldersList.removeAt(event.oldIndex);
    foldersList.insert(event.newIndex, folderToMove);

    final reorderedFolders = Map.fromEntries(foldersList);

    await prefs.setString(allFolderKey, jsonEncode(reorderedFolders));
    emit(state.copyWith(folders: reorderedFolders));
  }

  void _onLoadNotes(LoadNotesEvent event, Emitter<BlackBoxState> emit) async {
    Log.e('LOAD ALL NOTES');
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> decodedMap = jsonDecode(prefs.getString(allFolderKey) ?? '{}');
    Map<String, String> folders = decodedMap.map((key, value) => MapEntry(key, value.toString()));

    final notes = <String, Map<String, String>>{};
    for (var folderKey in folders.keys) {
      if (folders[folderKey] != '') {
        try {
          if (!await File(folders[folderKey]!).exists()) {
            final updatedFolders = Map<String, String>.from(state.folders);
            updatedFolders[folderKey] = '';
            await prefs.setString(allFolderKey, jsonEncode(updatedFolders));
          }
        } catch (e) {}
        ;
      }
    }

    for (final folder in folders.keys) {
      List<String> noteKeys = (prefs.getStringList(folder) ?? []);
      final noteSetKeys = noteKeys.toSet();
      if (noteKeys.length != noteSetKeys.length) {
        noteKeys = noteSetKeys.toList();
        prefs.setStringList(folder, noteKeys);
      }
      for (final key in noteKeys) {
        final noteData = prefs.getString(key);
        if (noteData != null) {
          final note = Map<String, String>.from(jsonDecode(noteData));
          notes[key] = note;
        } else {
          this.add(DeleteNoteEvent(key: key, folderName: folder));
        }
      }
    }

    emit(state.copyWith(folders: folders, notes: notes));
  }

  void _onAddNote(AddNoteEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = DateTime.now().toIso8601String();
    final noteData = jsonEncode({
      'folderName': event.folderName,
      'noteText': event.noteText,
    });

    await prefs.setString(key, noteData);

    final folderNotes = prefs.getStringList(event.folderName) ?? [];
    folderNotes.add(key);
    await prefs.setStringList(event.folderName, folderNotes);
    final updatedNotes = Map<String, Map<String, String>>.from(state.notes);
    updatedNotes[key] = {'folderName': event.folderName, 'noteText': event.noteText};
    emit(state.copyWith(notes: updatedNotes));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ToolNavigator.push(screen: EditNoteScreen(noteKey: key));
    });
  }

  Future<void> _onChangeNote(ChangeNoteEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final noteData = jsonEncode({
      'folderName': event.folderName,
      'noteText': event.noteText,
    });

    await prefs.setString(event.noteKey, noteData);

    final folderNotes = prefs.getStringList(event.folderName) ?? [];
    folderNotes.add(event.noteKey);
    await prefs.setStringList(event.folderName, folderNotes);

    final updatedNotes = Map<String, Map<String, String>>.from(state.notes);
    updatedNotes[event.noteKey] = {'folderName': event.folderName, 'noteText': event.noteText};

    emit(state.copyWith(notes: updatedNotes));
  }

  void _onDeleteNote(DeleteNoteEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(event.key);

    final updatedNotes = Map<String, Map<String, String>>.from(state.notes);
    if (updatedNotes[event.key]?['folderName'] != null && event.folderName != null) {
      final folderName = updatedNotes[event.key]!['folderName'];
      updatedNotes.remove(event.key);
      final folderNotes = prefs.getStringList(folderName!) ?? [];
      folderNotes.remove(event.key);
      await prefs.setStringList(folderName, folderNotes);
    } else {
      updatedNotes.remove(event.key);
      final folderNotes = prefs.getStringList(event.folderName!) ?? [];
      folderNotes.remove(event.key);
      await prefs.setStringList(event.folderName!, folderNotes);
    }
    emit(state.copyWith(notes: updatedNotes));
  }

  void _onAddFolder(AddFolderEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedFolders = Map<String, String>.from(state.folders);
    updatedFolders[event.folderName] = '';

    await prefs.setString(allFolderKey, jsonEncode(updatedFolders));
    emit(state.copyWith(folders: updatedFolders));
  }

  Future<void> _onDelImageFolder(DelImageFolderEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedFolders = Map<String, String>.from(state.folders);
    await File(updatedFolders[event.folderName]!).delete();
    updatedFolders[event.folderName] = '';

    await prefs.setString(allFolderKey, jsonEncode(updatedFolders));
    emit(state.copyWith(folders: updatedFolders));
  }

  void _onAddImageFolder(AddImageFolderEvent event, Emitter<BlackBoxState> emit) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final prefs = await SharedPreferences.getInstance();
      final updatedFolders = Map<String, String>.from(state.folders);
      if (updatedFolders[event.folderName] != '') {
        try {
          Log.i('start delete');
          await File(updatedFolders[event.folderName]!).delete();
        } catch (e) {
          print(e);
        }
      }
      File originalFile = File(result.files.single.path!);
      File newFile = await originalFile.copy('${App.directoryPath}/${basename(originalFile.path)}');
      updatedFolders[event.folderName] = newFile.path;
      await prefs.setString(allFolderKey, jsonEncode(updatedFolders));
      emit(state.copyWith(folders: updatedFolders));
    } else {
      Log.i('No file selected');
    }
  }

  void _onDeleteFolder(DeleteFolderEvent event, Emitter<BlackBoxState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedFolders = Map<String, String>.from(state.folders);
    final updatedNotes = Map<String, Map<String, String>>.from(state.notes);
    final folderNotes = prefs.getStringList(event.folderName) ?? [];
    for (final key in folderNotes) {
      updatedNotes.remove(key);
      await prefs.remove(key);
    }
    updatedFolders.remove(event.folderName);
    await prefs.remove(event.folderName);
    await prefs.setString(allFolderKey, jsonEncode(updatedFolders));
    emit(state.copyWith(folders: updatedFolders, notes: updatedNotes));
  }
}

class BlackBoxState {
  final Map<String, String> folders;
  final Map<String, Map<String, String>> notes;

  BlackBoxState({required this.folders, required this.notes});

  BlackBoxState copyWith({Map<String, String>? folders, Map<String, Map<String, String>>? notes}) {
    return BlackBoxState(
      folders: folders ?? this.folders,
      notes: notes ?? this.notes,
    );
  }
}

abstract class BlackBoxEvent {}

class LoadNotesEvent extends BlackBoxEvent {}

class AddNoteEvent extends BlackBoxEvent {
  final String folderName;
  final String noteText;

  AddNoteEvent({required this.folderName, required this.noteText});
}

class ChangeNoteEvent extends BlackBoxEvent {
  final String folderName;
  final String noteText;
  final String noteKey;

  ChangeNoteEvent({required this.folderName, required this.noteText, required this.noteKey});
}

class DeleteNoteEvent extends BlackBoxEvent {
  final String key;
  final String? folderName;

  DeleteNoteEvent({required this.key, required this.folderName});
}

class AddFolderEvent extends BlackBoxEvent {
  final String folderName;

  AddFolderEvent({required this.folderName});
}

class AddImageFolderEvent extends BlackBoxEvent {
  final String folderName;

  AddImageFolderEvent({required this.folderName});
}

class DelImageFolderEvent extends BlackBoxEvent {
  final String folderName;

  DelImageFolderEvent({required this.folderName});
}

class DeleteFolderEvent extends BlackBoxEvent {
  final String folderName;

  DeleteFolderEvent({required this.folderName});
}

class ReorderFolderEvent extends BlackBoxEvent {
  final int oldIndex;
  final int newIndex;

  ReorderFolderEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class ReorderNoteEvent extends BlackBoxEvent {
  final String folderName;
  final int oldIndex;
  final int newIndex;

  ReorderNoteEvent(this.folderName, this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [folderName, oldIndex, newIndex];
}
