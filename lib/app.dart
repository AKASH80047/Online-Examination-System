import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/app_router.dart';
import 'package:exam_paper/app_theme.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/user_entity.dart';

class ExamApp extends ConsumerWidget {
  const ExamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    final isAdmin = user?.role == UserRole.admin;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: isAdmin ? AppTheme.adminLightTheme : AppTheme.studentLightTheme,
      darkTheme: isAdmin ? AppTheme.adminDarkTheme : AppTheme.studentDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
