import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/master_models.dart';

class StudentCardHelper {
  static Future<void> generateAndPrint(List<Student> students) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Kartu Akses Login Wali Murid (Orang Tua)', 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 15,
              runSpacing: 15,
              children: students.map((s) => _buildCard(s)).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildCard(Student s) {
    return pw.Container(
      width: 250,
      height: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueGrey400, width: 1),
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
                decoration: const pw.BoxDecoration(color: PdfColors.blue800, shape: pw.BoxShape.circle),
                child: pw.Center(child: pw.Text('S', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SI MADRASAH', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text('Portal Orang Tua & Siswa', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  ],
                ),
              ),
            ],
          ),
          pw.Divider(color: PdfColors.blueGrey100, thickness: 0.5),
          pw.SizedBox(height: 5),
          pw.Text(s.name.toUpperCase(), 
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
          pw.Text('Wali: ${s.parentName ?? "-"}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 8),
          _rowInfo('Username', s.nis),
          _rowInfo('Password', 'madrasah123'),
          pw.Spacer(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Akses: Siswa & Orang Tua', style: const pw.TextStyle(fontSize: 6, color: PdfColors.blue700)),
              pw.Text('Simpan kartu ini dengan baik.', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
            ],
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
