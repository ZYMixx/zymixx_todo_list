import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

part '../../generated/data/db/app_database.g.dart';

@DriftDatabase(tables: [TodoItemDB])
class AppDatabase extends _$AppDatabase {
  static AppDatabase get instance => _instance ??= AppDatabase._crate(_openConnection());
  static AppDatabase? _instance;
  AppDatabase._crate(QueryExecutor exec) : super(exec);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      FileSystemEntity dbFolder;
      if (Platform.isWindows) {
        dbFolder = File((await getApplicationSupportDirectory()).path);
      } else {
        dbFolder = await getApplicationDocumentsDirectory();
      }
      final file = File(p.join(dbFolder.path, 'app_database.db'));
      return NativeDatabase(file);
    });
  }
}

class TodoItemDB extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
  IntColumn get secondsTimer => integer().nullable()();
  IntColumn get secondsStopwatch => integer().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
}

// dependencies:
// flutter pub add drift
// flutter pub add sqlite3_flutter_libs
// flutter pub add path_provider
// flutter pub add path
//
// dev_dependencies:
// flutter pub add dev:drift_dev
// flutter pub add dev:build_runner

// dart run build_runner build