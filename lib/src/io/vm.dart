// Copyright 2016 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io' as io;

import 'package:dart2_constant/convert.dart' as convert;
import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';

import '../exception.dart';

export 'dart:io' show exitCode, FileSystemException;

io.Stdout get stderr => io.stderr;

bool get isWindows => io.Platform.isWindows;

bool get hasTerminal => io.stdout.hasTerminal;

bool get isNode => false;

String get currentPath => io.Directory.current.path;

String readFile(String path) {
  var bytes = new io.File(path).readAsBytesSync();

  try {
    return convert.utf8.decode(bytes);
  } on FormatException catch (error) {
    var decodedUntilError = convert.utf8
        .decode(bytes.sublist(0, error.offset), allowMalformed: true);
    var stringOffset = decodedUntilError.length;
    if (decodedUntilError.endsWith("�")) stringOffset--;

    var decoded = convert.utf8.decode(bytes, allowMalformed: true);
    var sourceFile = new SourceFile.fromString(decoded, url: p.toUri(path));
    throw new SassException(
        "Invalid UTF-8.", sourceFile.location(stringOffset).pointSpan());
  }
}

void writeFile(String path, String contents) =>
    new io.File(path).writeAsStringSync(contents);

void deleteFile(String path) => new io.File(path).deleteSync();

Future<String> readStdin() async {
  var completer = new Completer<String>();
  completer.complete(await io.SYSTEM_ENCODING.decodeStream(io.stdin));
  return completer.future;
}

bool fileExists(String path) => new io.File(path).existsSync();

bool dirExists(String path) => new io.Directory(path).existsSync();

void ensureDir(String path) =>
    new io.Directory(path).createSync(recursive: true);

Iterable<String> listDir(String path) => new io.Directory(path)
    .listSync(recursive: true)
    .where((entity) => entity is io.File)
    .map((entity) => entity.path);

DateTime modificationTime(String path) {
  var stat = io.FileStat.statSync(path);
  if (stat.type == io.FileSystemEntityType.NOT_FOUND) {
    throw new io.FileSystemException("File not found.", path);
  }
  return stat.modified;
}
