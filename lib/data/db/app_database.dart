import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

part '../../generated/data/db/app_database.g.dart';

@DriftDatabase(tables: [TodoItemDB])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor exec) : super(exec);

  @override
  int get schemaVersion => 1;
}

Future<AppDatabase> createDatabase() async {
  QueryExecutor executor = await _openConnection();
  return AppDatabase(executor);
}

Future<QueryExecutor> _openConnection() async {
  FileSystemEntity dbFolder;
  if (Platform.isWindows) {
    dbFolder = File((await getApplicationSupportDirectory()).path);
  } else {
    dbFolder = await getApplicationDocumentsDirectory();
  }
  final file = File(p.join(dbFolder.path, 'app_database.db'));
  return NativeDatabase(file);
}

class TodoItemDB extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();

  TextColumn get title => text().withLength(min: 6, max: 60)();

  TextColumn get content => text().named('body')();

  TextColumn get category => text().withDefault(const Constant('active'))();

  IntColumn get timerSeconds => integer().withDefault(const Constant(0))();

  IntColumn get stopwatchSeconds => integer().withDefault(const Constant(0))();

  IntColumn get secondsSpent => integer().nullable().withDefault(const Constant(0))();

  IntColumn get autoPauseSeconds => integer().nullable().withDefault(const Constant(0))();

  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  DateTimeColumn get targetDateTime => dateTime().nullable()();
}
