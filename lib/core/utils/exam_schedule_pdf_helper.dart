import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExamSchedulePdfHelper {
  static Future<void> generateAndPrint({
    required String examName,
    required String examType,
    required String semester,
    required String classLevel,
    required List<String> dates,
    required List<String> rooms,
    required List<Map<String, String>> sessions,
    required Map<String, Map<String, String>> schedule,
  }) async {
    final pdf = pw.Document();

    for (var date in dates) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(examName.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                          pw.Text('Tingkat: Kelas $classLevel | Semester: $semester', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('Hari/Tanggal: $date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('SISTEM INFORMASI MADRASAH', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                          pw.Text(DateTime.now().toString().split('.')[0], style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Sesi / Waktu', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ),
                        ...rooms.map((room) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(room, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                        )),
                      ],
                    ),
                    // Data Rows
                    ...List.generate(sessions.length, (sessionIdx) {
                      final session = sessions[sessionIdx];
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(session['sesi']!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                pw.Text(session['waktu']!, style: const pw.TextStyle(fontSize: 8)),
                              ],
                            ),
                          ),
                          ...rooms.map((room) {
                            String key = '${date}_${sessionIdx}_$room';
                            final assigned = schedule[key];
                            return pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: assigned != null
                                ? pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(assigned['mapel']!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                                      pw.SizedBox(height: 4),
                                      pw.Text('Pws: ${assigned['pengawas']}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                                    ],
                                  )
                                : pw.Text('-', textAlign: pw.TextAlign.center),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('* Harap hadir 15 menit sebelum ujian dimulai', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                    pw.Column(
                      children: [
                        pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 40),
                        pw.Text('Wakil Kurikulum', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Jadwal_Ujian_${examType.replaceAll(' ', '_')}.pdf',
    );
  }
}
