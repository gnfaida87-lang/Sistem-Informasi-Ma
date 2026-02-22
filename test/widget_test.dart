// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sistem_informasi_ma/app.dart';

void main() {
  testWidgets('Aplikasi Sistem Informasi berjalan dengan baik', (WidgetTester tester) async {
    // Bangun aplikasi dan picu frame pertama.
    await tester.pumpWidget(const MyApp());

    // Pastikan terdapat teks 'Informasi Akademik' di layar Login.
    expect(find.text('Selamat Datang di Informasi Akademik Sekolah'), findsOneWidget);
  });
}
