import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';

/// A song in a list.
///
/// Follows the DESIGN.md §17 card anatomy — artwork, title, then metadata as
/// `ARTIST • TAG`. The tempo badge is set in the technical face because a BPM
/// is a musical fact, and it always carries a boundary since it sits on the
/// accent colour.
class LkSongCard extends StatelessWidget {
  /// Creates a song card.
  const LkSongCard({
    required this.title,
    required this.artist,
    required this.tag,
    required this.bpm,
    super.key,
    this.onTap,
    this.highlightTempo = true,
  });

  /// Song title.
  final String title;

  /// Performing artist.
  final String artist;

  /// Short descriptor such as `RHYTHM`.
  final String tag;

  /// Tempo in beats per minute.
  final int bpm;

  /// Opens the song.
  final VoidCallback? onTap;

  /// Whether the tempo badge uses the accent colour. The design system uses a
  /// muted badge for songs that are not the primary suggestion.
  final bool highlightTempo;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return LkPressable(
      onTap: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: '$title, $artist, $bpm BPM',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Artwork is a flat placeholder until the song API supplies covers.
          Stack(
            children: <Widget>[
              Container(
                height: LkDimens.songArtworkHeight,
                width: double.infinity,
                color: colors.surfaceSunken,
                child: Icon(
                  Icons.music_note,
                  color: colors.textTertiary,
                  size: LkSpacing.s10,
                ),
              ),
              PositionedDirectional(
                end: LkSpacing.s2,
                bottom: LkSpacing.s2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: highlightTempo
                        ? colors.accent
                        : colors.surfaceSunken,
                    border: Border.all(
                      color: colors.border,
                      width: LkBorders.regular,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LkSpacing.s2,
                      vertical: LkSpacing.s1,
                    ),
                    child: Text(
                      '$bpm BPM',
                      style: LkTypeScale.label.copyWith(
                        color: highlightTempo
                            ? colors.accentOn
                            : colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(LkSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: LkSpacing.s2,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LkTypeScale.h4.copyWith(color: colors.textPrimary),
                ),
                Text(
                  '${artist.toUpperCase()} • ${tag.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LkTypeScale.label.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
