import 'package:exam_paper/result_entity.dart'; // Corrected import

abstract class ResultRepository {
  Future<void> submitResult(ResultEntity result);
  Future<List<ResultEntity>> getUserResults(String userId);
  Future<List<ResultEntity>> getTopResultsForExam(
    String examId, {
    int limit = 10,
  });
}
