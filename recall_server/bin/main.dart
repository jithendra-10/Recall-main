import 'package:recall_server/server.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> args) {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  run(args);
}
