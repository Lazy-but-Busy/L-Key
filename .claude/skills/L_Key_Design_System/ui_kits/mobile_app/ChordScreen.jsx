const { ChordDiagram, AppButton, AppChip } = window.LKeyDesignSystem_355d7c;
const { PlayGlyph } = window.LKGlyphs;

function ChordScreen() {
  return (
    <div style={{ padding: "24px 24px 100px", display: "flex", flexDirection: "column", alignItems: "center", gap: 48 }}>
      <div style={{ paddingTop: 8 }}>
        <ChordDiagram
          name="C MAJOR"
          width={278}
          strings={6}
          frets={4}
          mutedStrings={[0]}
          openStrings={[2, 5]}
          positions={[{ string: 1, fret: 3, finger: 3 }, { string: 2, fret: 2, finger: 2 }, { string: 4, fret: 1, finger: 1, root: true }]}
          fingers={["", "C", "E", "G", "C", "E"]} />
      </div>
      <AppButton variant="accent" size="hero" icon={<PlayGlyph />} style={{ width: 252.63 }}>Play Chord</AppButton>
      <div style={{ display: "flex", gap: 16, width: "100%", justifyContent: "center" }}>
        <AppChip variant="bento" label="FORMULA" style={{ flex: 1 }}>1 3 5</AppChip>
        <AppChip variant="bento" label="ROOT NOTE" style={{ flex: 1 }}>C</AppChip>
      </div>
    </div>
  );
}

Object.assign(window, { LKMobileChord: ChordScreen });
