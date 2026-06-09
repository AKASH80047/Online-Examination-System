import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:exam_paper/result_entity.dart';
import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<Uint8List> generateResultPdf(
    ResultEntity result,
    ExamEntity exam,
    List<QuestionEntity> questions,
    Map<String, List<int>> userAnswers,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'Exam Result: ${exam.title}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            _buildSummarySection(result, exam),
            pw.SizedBox(height: 30),
            pw.Text(
              'Detailed Breakdown:',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionDetail(
                index + 1,
                question,
                userAnswers[question.id] ?? [],
              );
            }), // Removed unnecessary .toList()
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSummarySection(ResultEntity result, ExamEntity exam) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Student ID: ${result.userId}'),
        pw.Text(
          'Exam Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(result.timestamp)}',
        ),
        pw.SizedBox(height: 10),
        pw.Text('Total Questions: ${result.totalMarks}'),
        pw.Text('Attempted: ${result.attemptedCount}'),
        pw.Text('Correct Answers: ${result.correctCount}'),
        pw.Text('Incorrect Answers: ${result.incorrectCount}'),
        pw.Text('Score: ${result.score} / ${result.totalMarks}'),
        pw.Text(
          'Result: ${result.isPassed ? 'PASSED' : 'FAILED'}',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: result.isPassed ? PdfColors.green800 : PdfColors.red800,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildQuestionDetail(
    int qNum,
    QuestionEntity question,
    List<int> userSelectedOptions,
  ) {
    final isCorrect =
        userSelectedOptions.length == question.correctOptionIndices.length &&
        userSelectedOptions.every(
          (index) => question.correctOptionIndices.contains(index),
        );

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: isCorrect ? PdfColors.green200 : PdfColors.red200,
        ),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$qNum. ${question.text}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final isUserSelected = userSelectedOptions.contains(optionIndex);
            final isCorrectOption = question.correctOptionIndices.contains(
              optionIndex,
            );

            PdfColor textColor = PdfColors.black;
            if (isUserSelected && !isCorrectOption) {
              textColor = PdfColors.red; // User selected, but incorrect
            } else if (isCorrectOption) {
              textColor = PdfColors.green; // Correct option
            }

            return pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, top: 2),
              child: pw.Text(
                '${_getOptionLetter(optionIndex)}. $optionText',
                style: pw.TextStyle(color: textColor),
              ),
            );
          }), // Removed unnecessary .toList()
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Explanation:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(question.explanation!),
          ],
          pw.SizedBox(height: 10),
          pw.Text(
            'Status: ${isCorrect ? 'Correct' : 'Incorrect'}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: isCorrect ? PdfColors.green : PdfColors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _getOptionLetter(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }
}
