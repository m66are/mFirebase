import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mFirebase/utilities/server_response.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  DatabaseService({required String databaseUrl}) {
    _db.databaseURL = databaseUrl;
    print("✅ Database URL setted : ${_db.databaseURL}");
  }
  Future<ServerResponse> getData({
    required String nodePath,
    int limit = 10,
    int offset = 0,
  }) async {
    print(
        "🚀 Getting data from $nodePath with limit $limit and offset $offset ...");
    try {
      final DatabaseEvent data =
          await _db.ref(nodePath).limitToFirst(limit).once();
      if (data.snapshot.value != null) {
        return ServerResponse<dynamic>(
          ResponseStatus.Success,
          data: data.snapshot.value,
        );
      } else {
        return ServerResponse(
          ResponseStatus.Error,
          errorMessage: "Unknown Error",
        );
      }
    } on FirebaseException catch (e, stk) {
      print("🚨 Firebase exception $e");
      print("🚨 Firebase exception stacktrace $stk");
      return ServerResponse(
        ResponseStatus.Error,
        errorMessage: e.message,
      );
    } catch (e, stk) {
      print("🚨 Exception $e");
      print("🚨 Exception stacktrace $stk");
      return ServerResponse(
        ResponseStatus.Error,
        errorMessage: e.toString(),
      );
    }
  }

  Stream<DatabaseEvent> getDataAsStream({required String nodePath}) {
    final DatabaseReference streamData =
        FirebaseDatabase.instance.ref(nodePath);
    return streamData.onValue;
  }
}
