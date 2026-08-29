import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_card.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_progress_bar.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';

/// A course as the Learn screen renders it.
@immutable
class _Course {
  const _Course({
    required this.title,
    required this.completed,
    required this.total,
    this.isPremium = false,
  });

  final String title;
  final int completed;
  final int total;
  final bool isPremium;
}

// Placeholder content standing in for the lesson API (PRD.md §53).
const List<_Course> _mockCourses = <_Course>[
  _Course(title: 'Guitar Fundamentals', completed: 7, total: 12),
  _Course(title: 'Open & Barre Chords', completed: 2, total: 9),
  _Course(title: 'Rhythm & Strumming', completed: 0, total: 8),
  _Course(title: 'CAGED System', completed: 0, total: 10, isPremium: true),
];

/// The Learn screen: course, module, lesson.
class LearnPage extends StatelessWidget {
  /// Creates the Learn screen.
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: lkScreenPadding,
      children: <Widget>[
        LkScreenHeader(title: l10n.navLearn, subtitle: l10n.learnSubtitle),
        const SizedBox(height: LkSpacing.s6),

        LkCard(
          tone: LkCardTone.accent,
          title: 'Barre Chord Basics',
          label: 'LESSON 8 / 12',
          child: LkButton(
            label: l10n.learnResumeLesson,
            block: true,
            onPressed: () => context.pushNamed(AppRoutes.practiceName),
          ),
        ),
        const SizedBox(height: LkSpacing.s6),

        for (final course in _mockCourses) ...<Widget>[
          _CourseCard(course: course),
          const SizedBox(height: LkSpacing.s4),
        ],
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final _Course course;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final progress = l10n.learnLessonProgress(course.completed, course.total);

    return LkCard(
      variant: LkCardVariant.ring,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s3,
        children: <Widget>[
          Row(
            spacing: LkSpacing.s2,
            children: <Widget>[
              Flexible(
                child: Text(
                  course.title,
                  style: context.lkType.h3.copyWith(color: colors.textPrimary),
                ),
              ),
              if (course.isPremium) LkPremiumBadge(label: l10n.commonPro),
            ],
          ),
          LkProgressBar(
            value: course.completed.toDouble(),
            max: course.total.toDouble(),
            semanticLabel: '${course.title}, $progress',
            height: LkSpacing.s4,
          ),
          Text(
            progress.toUpperCase(),
            style: context.lkType.label.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
