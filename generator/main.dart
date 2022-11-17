import 'dart:io';

import 'package:path/path.dart';

final source = join('app');
final destination = join('brick', '__brick__', '{{name}}');

void main() async {
  final target = Directory(destination);
  if (target.existsSync()) {
    await target.delete(recursive: true);
  }

  try {
    await Shell.copy(source, destination);
  } catch (e) {
    Shell.print(e.toString());
  }

  await Future.wait(
    Directory(join(destination))
        .listSync(recursive: true)
        .whereType<File>()
        .map((_) async {
      var file = _;
      try {
        final contents = await file.readAsString();
        file = await file.writeAsString(
          contents
              .replaceAll('flutter_app', '{{name}}')
              .replaceAll('A new Flutter project.', '{{desc}}')
              .replaceAll('com.example', '{{org}}'),
        );
      } catch (e) {
        Shell.print(e.toString());
      }
    }),
  );
}

class Shell {
  static Future<void> copy(String source, String destination) async {
    await Process.run(
      'cp',
      ['-rf', source, destination],
      runInShell: true,
    );
  }

  static Future<void> print(String message) async {
    await Process.run(
      'echo',
      [message],
      runInShell: true,
    );
  }
}
