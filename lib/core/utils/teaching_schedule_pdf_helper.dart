import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/academic_config/models/scheduling_models.dart';
import '../../features/academic_config/models/school_models.dart';

class TeachingSchedulePdfHelper {
  static Future<void> generateAndPrint({
    required String semesterName,
    required String level,
    required String day,
    required List<Kelas> classes,
    required List<TimeSlot> timeSlots,
    required Map<String, ScheduleRow> scheduleData,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('JADWAL PELAJARAN MADRASAH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text('Level: Kelas $level | Hari: $day', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Semester: $semesterName', style: const pw.TextStyle(fontSize: 12)),
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
              pw.SizedBox(height: 20),

              // Table Grid
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  ...Map.fromIterable(
                    List.generate(classes.length, (i) => i + 1),
                    value: (_) => const pw.FlexColumnWidth(),
                  ),
                },
                children: [
                  // Table Header (Classes)
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.teal700),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('WAKTU', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                      ),
                      ...classes.map((c) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(c.nama, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                      )),
                    ],
                  ),

                  // Table Rows (Time Slots)
                  ...timeSlots.map((slot) {
                    return pw.TableRow(
                      children: [
                        // Time Column
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          color: slot.isBreak ? PdfColors.orange100 : PdfColors.grey100,
                          child: pw.Column(
                            children: [
                              pw.Text(slot.isBreak ? 'ISTIRAHAT' : 'Jam Ke-${slot.slotNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                              pw.Text(slot.timeRange, style: const pw.TextStyle(fontSize: 7)),
                            ],
                          ),
                        ),
                        
                        // Class Columns
                        ...classes.map((kelas) {
                          if (slot.isBreak) {
                            return pw.Container(
                              padding: const pw.EdgeInsets.all(6),
                              color: PdfColors.orange50,
                              child: pw.Center(child: pw.Text(slot.label ?? '-', style: const pw.TextStyle(fontSize: 8, color: PdfColors.orange800))),
                            );
                          }

                          final key = '${slot.id}_${kelas.id}';
                          final assigned = scheduleData[key];

                          return pw.Container(
                            padding: const pw.EdgeInsets.all(6),
                            child: assigned != null
                                ? pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(assigned.subjectName ?? '-', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                                      pw.Text(assigned.teacherName ?? '-', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                                    ],
                                  )
                                : pw.Center(child: pw.Text('-', style: const pw.TextStyle(color: PdfColors.grey300))),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),

              pw.Spacer(),
              // Footer / Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('* Jadwal sewaktu-waktu dapat berubah', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                      pw.Text('* Harap hadir tepat waktu', style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 40),
                      pw.Text('Wakil Kurikulum', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Container(width: 100, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Jadwal_Pelajaran_${level}_$day.pdf',
    );
  }
}
