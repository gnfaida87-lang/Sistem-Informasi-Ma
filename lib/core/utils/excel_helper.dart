import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ExcelHelper {
  static Future<void> exportToExcel({
    required String fileName,
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);

    // Add headers
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // Add rows
    for (var row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    final bytes = excel.encode();
    if (bytes == null) return;

    if (kIsWeb) {
      final content = base64Encode(bytes);
      final anchor = html.AnchorElement(
          href: "data:application/octet-stream;charset=utf-16le;base64,$content")
        ..setAttribute("download", fileName)
        ..click();
      return;
    }

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Simpan File Excel',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(bytes);
    }
  }

  static Future<List<List<dynamic>>?> importFromExcel() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null) return null;

    Uint8List? bytes;
    if (kIsWeb) {
      bytes = result.files.single.bytes;
    } else if (result.files.single.path != null) {
      bytes = await File(result.files.single.path!).readAsBytes();
    }

    if (bytes == null) return null;

    final excel = Excel.decodeBytes(bytes);
    final table = excel.tables[excel.tables.keys.first];
    if (table == null) return null;

    final rows = <List<dynamic>>[];
    for (var row in table.rows) {
      rows.add(row.map((e) => e?.value).toList());
    }
    return rows;
  }
}
