import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:exam_paper/result_entity.dart';
import 'package:exam_paper/exam_entity.dart';
import 'package:intl/intl.dart';

class CertificateService {
  Future<Uint8List> generateCertificate({
    required String userName,
    required ResultEntity result,
    required ExamEntity exam,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber, width: 5),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICATE OF COMPLETION',
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  userName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 36,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'has successfully cleared the examination for',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  exam.title,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'Final Score: ${result.score}/${result.totalMarks}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                        pw.Text(
                          'Issued on: ${DateFormat('MMMM dd, yyyy').format(result.timestamp)}',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 150,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Examination Controller',
                          style: const pw.TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
