import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/presentation/chords_controller.dart';
import 'package:l_key/features/chords/presentation/widgets/chord_diagram.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// One chord: its diagram, its notes, and the other ways to play it.
///
/// DESIGN.md §23 makes the chord name dominant and puts the diagram directly
/// under it. Nothing is calculated here — the engine has already decided every
/// fret and finger (CLAUDE.md §8).
class ChordDetailPage extends ConsumerStatefulWidget {
  /// Creates the chord detail screen for the catalogue entry [chordId].
  const ChordDetailPage({required this.chordId, super.key});

  /// The catalogue id from the route, such as `c-major`.
  final String chordId;

  @override
  ConsumerState<ChordDetailPage> createState() => _ChordDetailPageState();
}

class _ChordDetailPageState extends ConsumerState<ChordDetailPage> {
  int _voicing = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(chordDetailProvider(widget.chordId));

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkAsyncView<ChordDetail?>(
          value: detail,
          onRetry: () => ref.invalidate(chordDetailProvider(widget.chordId)),
          isEmpty: (data) => data == null,
          empty: (context) => LkEmptyState(
            headline: l10n.chordsNotFound,
            body: l10n.chordsNotFoundBody,
          ),
          data: (context, data) => _ChordDetail(
            detail: data!,
            selected: _voicing,
            onSelect: (index) => setState(() => _voicing = index),
          ),
        ),
      ],
    );
  }
}

class _ChordDetail extends ConsumerWidget {
  const _ChordDetail({
    required this.detail,
    required this.selected,
    required this.onSelect,
  });

  final ChordDetail detail;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final chord = detail.chord;
    final audio = ref.watch(chordAudioPlayerProvider);

    if (detail.voicings.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LkScreenHeader(
            title: chord.displaySymbol,
            subtitle: qualityName(l10n, chord.quality),
          ),
          const SizedBox(height: LkSpacing.s6),
          _Facts(chord: chord),
          const SizedBox(height: LkSpacing.s6),
          LkEmptyState(
            headline: l10n.chordsNoVoicing,
            body: l10n.chordsNoVoicingBody,
          ),
        ],
      );
    }

    // A stale index survives a hot reload or a repository swap; clamping beats
    // throwing at the player.
    final index = selected.clamp(0, detail.voicings.length - 1);
    final voicing = detail.voicings[index].voicing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LkScreenHeader(
          title: chord.displaySymbol,
          subtitle: qualityName(l10n, chord.quality),
        ),
        const SizedBox(height: LkSpacing.s6),

        Center(
          child: LkChordDiagram(
            chord: chord,
            voicing: voicing,
            shapeLabel: _shapeLabel(l10n, index),
          ),
        ),
        const SizedBox(height: LkSpacing.s6),

        // CLAUDE.md §47 — the control is visibly disabled and the reason is
        // written down, rather than a button that silently does nothing.
        LkButton(
          label: l10n.chordPlay,
          icon: const Icon(Icons.play_arrow),
          block: true,
          variant: LkButtonVariant.accent,
          onPressed: audio.isAvailable ? () => audio.play(voicing) : null,
        ),
        if (!audio.isAvailable) ...<Widget>[
          const SizedBox(height: LkSpacing.s2),
          Text(
            l10n.chordPlayUnavailable,
            textAlign: TextAlign.center,
            style: context.lkType.bodySmall.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
        const SizedBox(height: LkSpacing.s6),

        _Facts(chord: chord),

        if (detail.voicings.length > 1) ...<Widget>[
          const SizedBox(height: LkSpacing.s6),
          LkSectionHeader(title: l10n.chordVoicings),
          const SizedBox(height: LkSpacing.s3),
          LkSegmentedControl<int>(
            segments: <int, String>{
              for (var i = 0; i < detail.voicings.length; i++)
                i: _shapeLabel(l10n, i),
            },
            selected: index,
            onChanged: onSelect,
          ),
        ],
      ],
    );
  }

  /// How a shape is named: the nut, or the fret its grid starts at.
  String _shapeLabel(AppLocalizations l10n, int index) {
    final voicing = detail.voicings[index].voicing;
    return voicing.baseFret == 0
        ? l10n.chordVoicingOpen
        : l10n.chordVoicingAtFret(voicing.baseFret);
  }
}

/// The chord's notes, formula and root.
class _Facts extends StatelessWidget {
  const _Facts({required this.chord});

  final Chord chord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      spacing: LkSpacing.s4,
      children: <Widget>[
        Expanded(
          child: LkStatChip(
            label: l10n.chordFormula,
            value: chord.intervalFormula,
          ),
        ),
        Expanded(
          child: LkStatChip(
            label: l10n.chordRootNote,
            value: chord.root.displayName,
          ),
        ),
        Expanded(
          child: LkStatChip(
            label: l10n.chordNotes,
            value: chord.notes.map((note) => note.displayName).join(' '),
          ),
        ),
      ],
    );
  }
}
