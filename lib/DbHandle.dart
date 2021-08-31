import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHandler {
  Future<Database> openDb(String table) async {
    // 데이터베이스를 열고 참조 값을 얻습니다.
    final Future<Database> database = openDatabase(
      // 데이터베이스 경로를 지정합니다. 참고: `path` 패키지의 `join` 함수를 사용하는 것이
      // 각 플랫폼 별로 경로가 제대로 생성됐는지 보장할 수 있는 가장 좋은 방법입니다.
      join(await getDatabasesPath(), 'company_database.db'),
      onCreate: (db, version) {
        // 데이터베이스에 CREATE TABLE 수행
        return db.execute(
          "CREATE TABLE ${createTableText(table)}",
        );
      },
      version: 1,
    );

    return database;
  }

  String createTableText(String table) {
    if (table == dbTableList.sign) {
      return "$table(id INTEGER PRIMARY KEY AUTOINCREMENT, sign TEXT NOT NULL UNIQUE, date TEXT, floor INTEGER, workState INTEGER)";
    }
    return "";
  }

  // 데이터베이스에 dog를 추가하는 함수를 정의합니다.
  Future<int> insetDb(String table, Map<String, Object?> item) async {
    // 데이터베이스 reference를 얻습니다.
    final Database db = await openDb(table);

    // Dog를 올바른 테이블에 추가합니다. 동일한 dog가 두번 추가되는 경우를 처리하기 위해
    // `conflictAlgorithm`을 명시할 수 있습니다.
    //
    // 본 예제에서는, 이전 데이터를 갱신하도록 하겠습니다.
    int id = await db.insert(
      table,
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.close();
    return id;
  }

  Future<List> readDb(String table, {String searchStr = ''}) async {
    // dogs 테이블의 모든 dog를 얻는 메서드
    // 데이터베이스 reference를 얻습니다.
    final Database db = await openDb(table);

    try {
      // 모든 Dog를 얻기 위해 테이블에 질의합니다.
      final List<Map<String, dynamic>> maps = await db
          .rawQuery("SELECT * FROM $table WHERE date LIKE '%$searchStr%'");

      // List<Map<String, dynamic>를 List<Dog>으로 변환합니다.
      return List.generate(maps.length, (i) {
        return Sign(
            id: maps[i]['id'],
            sign: maps[i]['sign'],
            date: maps[i]['date'],
            floor: maps[i]['floor'],
            workState: WorkState.values[maps[i]['workState']]);
      });
    } catch (err) {
      return List.empty();
    }
  }

  Future<void> deleteData(String table, int id) async {
    final Database db = await openDb(table);
    db.rawDelete("DELETE FROM $table WHERE id = $id");
  }

  Future<void> dropTable(String table) async {
    final Database db = await openDb(table);
    db.rawDelete("DROP TABLE IF EXISTS $table");
  }

  Future<void> updateData(String table, Sign sign) async {
    final Database db = await openDb(table);

    await db.update(
      table,
      sign.toMap(),
      where: "id = ?",
      whereArgs: [sign.id],
    );
  }
}

// Dog 클래스에 `toMap` 메서드를 추가하세요
class Sign {
  int id;
  String sign;
  String date;
  int floor;
  WorkState workState;

  Sign(
      {required this.sign,
      required this.date,
      required this.floor,
      this.workState = WorkState.weekend,
      this.id = 0});

  // dog를 Map으로 변환합니다. key는 데이터베이스 컬럼 명과 동일해야 합니다.
  Map<String, dynamic> toMap() {
    return {
      'sign': sign,
      'date': date,
      'floor': floor,
      'workState': workState.index
    };
  }
}

enum WorkState { work, offWork, weekend }

class DbTableList {
  final String sign = "sign";
}

final DbHandler dbHandler = DbHandler();
final DbTableList dbTableList = DbTableList();
