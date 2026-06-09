class AppConstants {
  static const String appName = 'Online Examination System';
  static const String appVersion = '1.0.0';
}

class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String adminExamList = '/admin/exams';
  static const String adminCreateExam = '/admin/exams/create';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminUserList = '/admin/users';
  static const String adminEditExam = '/admin/exams/edit/:examId';
  static const String adminQuestionList = '/admin/exams/:examId/questions';
  static const String adminAddQuestion = '/admin/exams/:examId/questions/add';
  static const String adminEditQuestion = '/admin/exams/:examId/questions/edit';
  static const String adminDashboard = '/admin';
  static const String userDashboard = '/user';
  static const String userExamInstructions = '/user/exams/:examId/instructions';
  static const String userExamScreen = '/user/exams/:examId/take';
  static const String userResultSummary = '/user/exams/:examId/result';
  static const String adminLeaderboard = '/admin/leaderboard/:examId';
  static const String userHistory = '/user/history';

  // New admin route paths
  static const String adminExamDetails = '/admin/exams/details/:examId';
  static const String adminUserDetails = '/admin/users/details/:uid';
  static const String adminUserPerformance = '/admin/users/performance/:uid';
  static const String adminExamAnalytics = '/admin/analytics/exam/:examId';
  static const String adminSubjectReport = '/admin/analytics/subject';
  static const String adminResults = '/admin/results';
  static const String adminResultDetails = '/admin/results/details/:resultId';
  static const String adminExportResults = '/admin/results/export';
  static const String adminSendNotification = '/admin/notifications/send';
  static const String adminNotificationHistory = '/admin/notifications/history';
  static const String adminSettings = '/admin/settings';
  static const String adminRolesPermission = '/admin/settings/roles';
  static const String adminAppConfig = '/admin/settings/config';
}