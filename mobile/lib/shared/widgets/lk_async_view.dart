import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/shared/widgets/lk_error_state.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

/// Renders the four states CLAUDE.md §55 requires from an [AsyncValue].
///
/// `AsyncValue` models loading, success and error natively. Empty is not one
/// of them — it is a fact about the data rather than about the request — so it
/// is layered on top here via [isEmpty], which is where ADR-0002 says it
/// belongs.
///
/// An error that is not a [Failure] is still shown as an unexpected failure
/// rather than surfaced raw, so no exception text can reach the screen.
class LkAsyncView<T> extends StatelessWidget {
  /// Creates a four-state view over [value].
  const LkAsyncView({
    required this.value,
    required this.data,
    super.key,
    this.isEmpty,
    this.empty,
    this.loading,
    this.onRetry,
  });

  /// The state being rendered.
  final AsyncValue<T> value;

  /// Builds the success state.
  final Widget Function(BuildContext context, T data) data;

  /// Decides whether loaded data should show the empty state instead.
  final bool Function(T data)? isEmpty;

  /// Builds the empty state. Required in practice whenever [isEmpty] is given.
  final WidgetBuilder? empty;

  /// Builds the loading state. Defaults to a skeleton list.
  final WidgetBuilder? loading;

  /// Re-runs the failed operation.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: false,
      loading: () => loading?.call(context) ?? const LkSkeletonList(),
      error: (error, stackTrace) => LkErrorState(
        failure: error is Failure
            ? error
            : UnexpectedFailure(technicalDetail: error.toString()),
        onRetry: onRetry,
      ),
      data: (value) {
        final showEmpty = isEmpty?.call(value) ?? false;
        if (showEmpty && empty != null) return empty!(context);
        return data(context, value);
      },
    );
  }
}
