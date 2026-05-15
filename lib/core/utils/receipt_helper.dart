import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ReceiptHelper {
  static Future<void> printReceipt({
    required String title,
    required String studentName,
    required String nis,
    required String amount,
    required String description,
    required String transactionId,
    String? schoolName,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Ukuran struk thermal
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(schoolName ?? 'MADRASAH ALIYAH AL-FALAH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text('Kwitansi Pembayaran Digital', style: pw.TextStyle(fontSize: 10)),
                    pw.Divider(),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('ID Transaksi: $transactionId', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              pw.Text('Waktu: $dateStr', style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 10),
              pw.Text('NAMA SISWA:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.Text(studentName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('NIS: $nis', style: pw.TextStyle(fontSize: 10)),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Text(description, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(amount, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Simpan kwitansi ini sebagai bukti sah.', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                    pw.Text('Terima Kasih atas Pembayaran Anda', style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kwitansi-$transactionId.pdf',
    );
  }

  static Future<void> printSavingsHistory({
    required String studentName,
    required String nis,
    required List<dynamic> transactions, // List of Savings objects
    required double currentBalance,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BUKU TABUNGAN SISWA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text('MADRASAH ALIYAH AL-FALAH', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('NIS: $nis', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(studentName, style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              headers: ['Tanggal', 'Jenis', 'Debit (Setor)', 'Kredit (Tarik)', 'Nominal'],
              data: transactions.map((t) {
                final date = t.savedAt is DateTime ? t.savedAt as DateTime : DateTime.parse(t.savedAt.toString());
                final isSetor = t.type == 'setor';
                return [
                  DateFormat('dd/MM/yyyy').format(date),
                  isSetor ? 'Setoran' : 'Penarikan',
                  isSetor ? 'Rp ${t.amount.toStringAsFixed(0)}' : '-',
                  !isSetor ? 'Rp ${t.amount.toStringAsFixed(0)}' : '-',
                  'Rp ${t.amount.toStringAsFixed(0)}',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('SALDO AKHIR SAAT INI', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Rp ${currentBalance.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Orang Tua/Wali', style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 50),
                    pw.Text('(___________________)', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Petugas Keuangan', style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 50),
                    pw.Text('(___________________)', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.Footer(
              margin: const pw.EdgeInsets.only(top: 20),
              trailing: pw.Text('Halaman dicetak pada: $dateStr', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Buku_Tabungan_$nis.pdf',
    );
  }
}
