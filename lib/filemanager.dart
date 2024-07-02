import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class FileManager {
  /// Deletes all files in the temporary directory.
  static Future<void> deleteAllFilesInDirectory() async {
    try {
      final Directory dir = await getTemporaryDirectory();
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (final FileSystemEntity entity in entities) {
        if (entity is File) {
          // Check if it is a file
          await entity.delete();
          print('Deleted file: ${entity.path}');
        }
      }
      print('All files in the directory have been deleted.');
    } catch (e) {
      print('Error occurred while deleting files: $e');
    }
  }
}
