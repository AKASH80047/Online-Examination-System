import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/login_screen.dart';
import 'package:exam_paper/signup_screen.dart';
import 'package:exam_paper/exam_history_screen.dart';
import 'package:exam_paper/exam_instruction_screen.dart';
import 'package:exam_paper/exam_screen.dart';
import 'package:exam_paper/result_summary_screen.dart';
import 'package:exam_paper/user_dashboard_screen.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/user_main_layout.dart';
import 'package:exam_paper/user_profile_screen.dart';

// Reorganized admin screens
import 'package:exam_paper/presentation/admin/dashboard/admin_dashboard_screen.dart';
import 'package:exam_paper/presentation/admin/exams/create_exam_screen.dart';
import 'package:exam_paper/presentation/admin/exams/edit_exam_screen.dart';
import 'package:exam_paper/presentation/admin/exams/exam_details_screen.dart';
import 'package:exam_paper/presentation/admin/exams/add_question_screen.dart';
import 'package:exam_paper/presentation/admin/exams/edit_question_screen.dart';
import 'package:exam_paper/presentation/admin/exams/question_bank_screen.dart';
import 'package:exam_paper/presentation/admin/exams/exam_list_screen.dart';
import 'package:exam_paper/presentation/admin/users/user_list_screen.dart';
import 'package:exam_paper/presentation/admin/users/user_details_screen.dart';
import 'package:exam_paper/presentation/admin/users/user_performance_screen.dart';
import 'package:exam_paper/presentation/admin/analytics/analytics_screen.dart';
import 'package:exam_paper/presentation/admin/analytics/exam_analytics_screen.dart';
import 'package:exam_paper/presentation/admin/analytics/subject_report_screen.dart';
import 'package:exam_paper/presentation/admin/analytics/leaderboard_screen.dart';
import 'package:exam_paper/presentation/admin/results/results_screen.dart';
import 'package:exam_paper/presentation/admin/results/result_details_screen.dart';
import 'package:exam_paper/presentation/admin/results/export_results_screen.dart';
import 'package:exam_paper/presentation/admin/notifications/send_notification_screen.dart';
import 'package:exam_paper/presentation/admin/notifications/notification_history_screen.dart';
import 'package:exam_paper/presentation/admin/settings/admin_settings_screen.dart';
import 'package:exam_paper/presentation/admin/settings/roles_permission_screen.dart';
import 'package:exam_paper/presentation/admin/settings/app_config_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.login, // Starting at Login for now
    redirect: (context, state) {
      final user = authState.valueOrNull;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isSigningUp = state.matchedLocation == RoutePaths.signup;

      // If not logged in and not on login/signup page, go to login
      if (user == null) {
        return (isLoggingIn || isSigningUp) ? null : RoutePaths.login;
      }

      // If logged in and on login/signup page, go to appropriate dashboard
      if (isLoggingIn || isSigningUp) {
        return user.role == UserRole.admin
            ? RoutePaths.adminDashboard
            : RoutePaths.userDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminExamList,
        builder: (context, state) => const ExamListScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminCreateExam,
        builder: (context, state) => const CreateExamScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminEditExam,
        builder: (context, state) =>
            EditExamScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminExamDetails,
        builder: (context, state) =>
            ExamDetailsScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminQuestionList,
        builder: (context, state) =>
            QuestionBankScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminAddQuestion,
        builder: (context, state) =>
            AddQuestionScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminEditQuestion,
        builder: (context, state) {
          return EditQuestionScreen(
            examId: state.pathParameters['examId']!,
            question: state.extra as QuestionEntity,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.adminUserList,
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminUserDetails,
        builder: (context, state) =>
            UserDetailsScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: RoutePaths.adminUserPerformance,
        builder: (context, state) =>
            UserPerformanceScreen(uid: state.pathParameters['uid']!),
      ),
      GoRoute(
        path: RoutePaths.adminExamAnalytics,
        builder: (context, state) =>
            ExamAnalyticsScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminSubjectReport,
        builder: (context, state) => const SubjectReportScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => UserMainLayout(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.userDashboard,
            builder: (context, state) => const UserDashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.userHistory,
            builder: (context, state) => const ExamHistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.userExamInstructions,
        builder: (context, state) =>
            ExamInstructionScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.userExamScreen,
        builder: (context, state) =>
            ExamScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.userResultSummary,
        builder: (context, state) =>
            ResultSummaryScreen(examId: state.pathParameters['examId']!),
      ),

      GoRoute(
        path: RoutePaths.adminLeaderboard,
        builder: (context, state) =>
            LeaderboardScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: RoutePaths.adminAnalytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminResults,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminResultDetails,
        builder: (context, state) =>
            ResultDetailsScreen(resultId: state.pathParameters['resultId']!),
      ),
      GoRoute(
        path: RoutePaths.adminExportResults,
        builder: (context, state) => const ExportResultsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminSendNotification,
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminNotificationHistory,
        builder: (context, state) => const NotificationHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminSettings,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminRolesPermission,
        builder: (context, state) => const RolesPermissionScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminAppConfig,
        builder: (context, state) => const AppConfigScreen(),
      ),
      // Placeholder Splash
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
