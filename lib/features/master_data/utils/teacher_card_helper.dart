import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/master_models.dart';

class TeacherCardHelper {
  static Future<void> generateAndPrint(List<Teacher> teachers) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Kartu Akses Login Pendidik & Tenaga Kependidikan', 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 15,
              runSpacing: 15,
              children: teachers.map((t) => _buildCard(t)).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildCard(Teacher t) {
    final username = (t.nip != null && t.nip!.isNotEmpty) 
        ? t.nip! 
        : t.name.replaceAll(' ', '').toLowerCase();

    return pw.Container(
      width: 250,
      height: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 30,
                height: 30,
                decoration: const pw.BoxDecoration(color: PdfColors.brown600, shape: pw.BoxShape.circle),
                child: pw.Center(child: pw.Text('M', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SI MADRASAH', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.brown800)),
                    pw.Text('Kartu Akses Sistem', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 5),
          pw.Text(t.name.toUpperCase(), 
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
          pw.SizedBox(height: 10),
          _rowInfo('Username', username),
          _rowInfo('Password', 'madrasah123'),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.bottomRight,
            child: pw.Text('Mohon segera ubah password Anda demi keamanan.', 
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _rowInfo(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 50, child: pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
        ],
      ),
    );
  }
}
