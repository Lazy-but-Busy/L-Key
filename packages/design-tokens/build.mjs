#!/usr/bin/env node
/**
 * L Key design-token generator.
 *
 * tokens.json is the single source of truth. This script emits every consumer:
 *   - mobile/lib/app/theme/tokens.g.dart   (Flutter)
 *   - dist/tokens.css                      (admin + website)
 *   - dist/tokens.ts                       (typed TS access)
 *
 * It also gates on WCAG contrast: every pair in tokens.json `contrastPairs` is
 * measured in both themes and the build fails below its threshold. The design
 * review found real failures (3.37:1 and 2.05:1) shipped in the UI kits; this
 * check is what stops them coming back.
 *
 *   node build.mjs                   write the generated files
 *   node build.mjs --check           verify committed output; exit 1 on drift
 *   node build.mjs --targets=web     CSS + TS only; needs no `dart`
 *   node build.mjs --targets=dart    tokens.g.dart only; requires `dart`
 */

import { readFileSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "../..");
const CHECK = process.argv.includes("--check");

const T = JSON.parse(readFileSync(join(HERE, "tokens.json"), "utf8"));

const BANNER_LINES = [
  "L KEY DESIGN TOKENS — GENERATED FILE. DO NOT EDIT.",
  "",
  "Source:    packages/design-tokens/tokens.json",
  "Generator: packages/design-tokens/build.mjs",
  "Regenerate with `npm run tokens`. CI runs `npm run tokens:check`.",
];

/* ------------------------------------------------------------------ utils */

const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
const isToken = (k) => !k.startsWith("$");
const entries = (obj) => Object.entries(obj).filter(([k]) => isToken(k));

/** WCAG 2.1 relative luminance. */
function luminance(hex) {
  const h = hex.replace("#", "");
  const ch = [0, 2, 4].map((i) => {
    const c = parseInt(h.slice(i, i + 2), 16) / 255;
    return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2];
}

function contrast(a, b) {
  const [la, lb] = [luminance(a), luminance(b)];
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

const colorHex = (name) => {
  const c = T.color[name];
  if (!c) throw new Error(`Unknown color token: ${name}`);
  return c.value;
};

/** Resolve a semantic key to a raw hex for the given theme. */
const semanticHex = (theme, key) => {
  const ref = T.semantic[theme][key];
  if (!ref) throw new Error(`Unknown semantic key "${key}" in theme "${theme}"`);
  return colorHex(ref);
};

/* --------------------------------------------------------- contrast gate */

function checkContrast() {
  const failures = [];
  const report = [];
  for (const theme of ["light", "dark"]) {
    for (const p of T.contrastPairs.pairs) {
      const fg = semanticHex(theme, p.fg);
      const bg = semanticHex(theme, p.bg);
      const ratio = contrast(fg, bg);
      const ok = ratio >= p.min;
      report.push(
        `  ${ok ? "ok  " : "FAIL"} ${theme.padEnd(5)} ${String(ratio.toFixed(2)).padStart(6)}:1 ` +
          `(min ${p.min})  ${p.fg} on ${p.bg}`,
      );
      if (!ok) {
        failures.push(
          `${theme}: ${p.fg} (${fg}) on ${p.bg} (${bg}) = ${ratio.toFixed(2)}:1, needs ${p.min}:1`,
        );
      }
    }
  }
  console.log("Contrast gate:");
  console.log(report.join("\n"));
  if (failures.length) {
    console.error("\nContrast gate FAILED:\n" + failures.map((f) => "  - " + f).join("\n"));
    console.error("\nFix the semantic mapping in tokens.json. Do not lower the threshold.");
    process.exit(1);
  }
  console.log(`  ${T.contrastPairs.pairs.length * 2} pairs pass\n`);
}

/* ------------------------------------------------------------- Dart emit */

const dartBanner = () => "// " + BANNER_LINES.join("\n// ") + "\n";

const dartColor = (hex) => `Color(0xFF${hex.replace("#", "").toUpperCase()})`;

/** Whole numbers emit as int literals; Dart widens them to double. */
const dartNum = (v) => (Number.isInteger(v) ? String(v) : String(v));

/** Turns a camelCase token key into a readable doc sentence. */
const words = (k) => k.replace(/([a-z0-9])([A-Z])/g, "$1 $2").toLowerCase();

function emitDart() {
  const L = [];
  L.push(dartBanner());
  L.push("// Long lines come from token source citations; wrapping them would");
  L.push("// split the DESIGN.md references that make each value traceable.");
  L.push("// ignore_for_file: lines_longer_than_80_chars");
  L.push("");
  L.push("import 'package:flutter/animation.dart';");
  L.push("import 'package:flutter/foundation.dart';");
  L.push("import 'package:flutter/painting.dart';");
  L.push("");

  // --- raw palette
  L.push("/// Raw colour ramp from DESIGN.md §5-6.");
  L.push("///");
  L.push("/// Prefer [LkSemanticColors]; reach for the ramp only when defining a new");
  L.push("/// semantic role. Feature widgets must never reference this class directly.");
  L.push("abstract final class LkPalette {");
  for (const [name, tok] of entries(T.color)) {
    if (tok.source) L.push(`  /// ${tok.source}`);
    L.push(`  static const Color ${name} = ${dartColor(tok.value)};`);
  }
  L.push("}");
  L.push("");

  // --- semantic colours
  L.push("/// Theme-resolved colour roles. This is the layer feature code uses.");
  L.push("@immutable");
  L.push("final class LkSemanticColors {");
  L.push("  /// Creates a resolved set of semantic colour roles.");
  L.push("  const LkSemanticColors({");
  const semKeys = Object.keys(T.semantic.light).filter(isToken);
  for (const k of semKeys) L.push(`    required this.${k},`);
  L.push("  });");
  L.push("");
  for (const k of semKeys) {
    L.push(`  /// The ${words(k)} role.`);
    L.push(`  final Color ${k};`);
  }
  L.push("");
  for (const theme of ["light", "dark"]) {
    L.push(`  /// DESIGN.md §${theme === "light" ? "5" : "6"} — ${theme} theme.`);
    L.push(`  static const LkSemanticColors ${theme} = LkSemanticColors(`);
    for (const k of semKeys) L.push(`    ${k}: LkPalette.${T.semantic[theme][k]},`);
    L.push("  );");
    L.push("");
  }
  L.push("}");
  L.push("");

  // --- spacing
  L.push("/// 4px spacing scale from DESIGN.md §14.");
  L.push("abstract final class LkSpacing {");
  for (const [name, tok] of entries(T.spacing)) {
    L.push(`  /// ${tok.value}px.`);
    L.push(`  static const double ${name} = ${dartNum(tok.value)};`);
  }
  L.push("}");
  L.push("");

  // --- borders / radii
  L.push("/// Border widths from DESIGN.md §11.");
  L.push("abstract final class LkBorders {");
  for (const [name, tok] of entries(T.border)) {
    const n = name === "default" ? "regular" : name;
    L.push(`  /// ${tok.value}px — ${tok.source ?? words(name)}.`);
    L.push(`  static const double ${n} = ${dartNum(tok.value)};`);
  }
  L.push("}");
  L.push("");

  L.push("/// Corner radii from DESIGN.md §12. Zero is the default.");
  L.push("abstract final class LkRadii {");
  for (const [name, tok] of entries(T.radius)) {
    L.push(`  /// ${tok.value}px${tok.source ? ` — ${tok.source}` : ""}.`);
    L.push(`  static const double ${name} = ${dartNum(tok.value)};`);
  }
  L.push("}");
  L.push("");

  // --- shadows
  L.push("/// Hard offset shadows from DESIGN.md §13. Blur is always zero.");
  L.push("///");
  L.push("/// The colour is theme-dependent, so these are builders rather than");
  L.push("/// constants — pass [LkSemanticColors.border].");
  L.push("abstract final class LkShadows {");
  for (const [name, tok] of entries(T.shadow)) {
    const n = name === "default" ? "regular" : name;
    L.push(`  /// ${tok.offsetX}px offset, no blur${tok.source ? ` — ${tok.source}` : ""}.`);
    L.push(`  static BoxShadow ${n}(Color color) => BoxShadow(`);
    L.push(`        color: color,`);
    L.push(`        offset: const Offset(${dartNum(tok.offsetX)}, ${dartNum(tok.offsetY)}),`);
    L.push(`      );`);
    L.push("");
  }
  L.push("}");
  L.push("");

  // --- motion
  const ez = T.animation.easing.value;
  L.push("/// Motion tokens. DESIGN.md §41 requires short, functional, predictable");
  L.push("/// motion but names no values; these come from the committed design system.");
  L.push("abstract final class LkMotion {");
  L.push(`  /// ${T.animation.durationFast.value}ms — press feedback and other immediate responses.`);
  L.push(`  static const Duration durationFast = Duration(milliseconds: ${T.animation.durationFast.value});`);
  L.push(`  /// ${T.animation.durationBase.value}ms — the default transition.`);
  L.push(`  static const Duration durationBase = Duration(milliseconds: ${T.animation.durationBase.value});`);
  L.push(`  /// Standard easing curve for every L Key transition.`);
  L.push(`  static const Cubic easing = Cubic(${ez.map(dartNum).join(", ")});`);
  L.push(`  /// ${T.animation.pressTranslate.value}px — DESIGN.md §15 press displacement.`);
  L.push(`  static const double pressTranslate = ${dartNum(T.animation.pressTranslate.value)};`);
  L.push("}");
  L.push("");

  // --- dimensions
  L.push("/// Component dimensions. DESIGN.md names none of these; values come from");
  L.push("/// the committed design system and WCAG 2.5.5 for the tap target.");
  L.push("abstract final class LkDimens {");
  for (const [name, tok] of entries(T.dimension)) {
    L.push(`  /// ${tok.value}px — ${tok.source ?? words(name)}.`);
    L.push(`  static const double ${name} = ${dartNum(tok.value)};`);
  }
  L.push("}");
  L.push("");

  // --- typography
  L.push("/// Font families from DESIGN.md §8.");
  L.push("abstract final class LkFonts {");
  for (const [name, tok] of entries(T.typography.family)) {
    if (tok.source) L.push(`  /// ${tok.source}`);
    L.push(`  static const String ${name} = '${tok.value}';`);
  }
  L.push("");
  L.push("  /// Appended to every text style so Burmese renders instead of tofu.");
  L.push("  static const List<String> fallback = <String>[myanmar];");
  L.push("}");
  L.push("");

  L.push("/// Type scale from DESIGN.md §9-10.");
  L.push("///");
  L.push("/// `letterSpacing` is stored in em in tokens.json and resolved to logical");
  L.push("/// pixels here, because Flutter expects an absolute value.");
  L.push("abstract final class LkTypeScale {");
  for (const [name, s] of entries(T.typography.scale)) {
    const family = T.typography.family[s.family].value;
    const weight = T.typography.weight[s.weight].value;
    const ls = (s.letterSpacing * s.size).toFixed(2);
    L.push(`  /// ${s.source}`);
    L.push(`  static const TextStyle ${name} = TextStyle(`);
    L.push(`    fontFamily: '${family}',`);
    L.push(`    fontFamilyFallback: LkFonts.fallback,`);
    L.push(`    fontSize: ${dartNum(s.size)},`);
    L.push(`    height: ${s.lineHeight},`);
    L.push(`    letterSpacing: ${Number(ls)},`);
    L.push(`    fontWeight: FontWeight.w${weight},`);
    L.push(`  );`);
    L.push("");
  }
  L.push("}");
  L.push("");

  return L.join("\n");
}

/* -------------------------------------------------------------- CSS emit */

function emitCss() {
  const L = [];
  L.push("/*");
  for (const line of BANNER_LINES) L.push(`  ${line}`);
  L.push("*/");
  L.push("");
  L.push(":root {");

  L.push("  /* palette — DESIGN.md §5-6 */");
  for (const [name, tok] of entries(T.color)) {
    L.push(`  --lk-color-${kebab(name)}: ${tok.value};`);
  }

  L.push("");
  L.push("  /* typography — DESIGN.md §8-10 */");
  const fams = T.typography.family;
  L.push(`  --lk-font-display: "${fams.display.value}", "${fams.myanmar.value}", system-ui, sans-serif;`);
  L.push(`  --lk-font-body: "${fams.body.value}", "${fams.myanmar.value}", system-ui, sans-serif;`);
  L.push(`  --lk-font-mono: "${fams.mono.value}", "${fams.myanmar.value}", ui-monospace, monospace;`);
  for (const [name, tok] of entries(T.typography.weight)) {
    L.push(`  --lk-weight-${kebab(name)}: ${tok.value};`);
  }
  for (const [name, s] of entries(T.typography.scale)) {
    const k = kebab(name);
    L.push(`  --lk-size-${k}: ${s.size}px;`);
    L.push(`  --lk-line-height-${k}: ${s.lineHeight};`);
    L.push(`  --lk-tracking-${k}: ${s.letterSpacing}em;`);
  }

  L.push("");
  L.push("  /* spacing — DESIGN.md §14 */");
  for (const [name, tok] of entries(T.spacing)) {
    L.push(`  --lk-space-${name.replace("s", "")}: ${tok.value}px;`);
  }

  L.push("");
  L.push("  /* borders and radii — DESIGN.md §11-12 */");
  for (const [name, tok] of entries(T.border)) {
    L.push(`  --lk-border-${kebab(name)}: ${tok.value}px;`);
  }
  for (const [name, tok] of entries(T.radius)) {
    L.push(`  --lk-radius-${kebab(name)}: ${tok.value}px;`);
  }

  L.push("");
  L.push("  /* shadows — DESIGN.md §13, zero blur */");
  for (const [name, tok] of entries(T.shadow)) {
    L.push(
      `  --lk-shadow-${kebab(name)}: ${tok.offsetX}px ${tok.offsetY}px ${tok.blur}px var(--lk-border-color);`,
    );
  }

  L.push("");
  L.push("  /* motion — values from the design system; DESIGN.md §41 names none */");
  L.push(`  --lk-duration-fast: ${T.animation.durationFast.value}ms;`);
  L.push(`  --lk-duration-base: ${T.animation.durationBase.value}ms;`);
  L.push(`  --lk-ease: cubic-bezier(${T.animation.easing.value.join(",")});`);
  L.push(`  --lk-press-translate: ${T.animation.pressTranslate.value}px;`);

  L.push("");
  L.push("  /* component dimensions */");
  for (const [name, tok] of entries(T.dimension)) {
    L.push(`  --lk-${kebab(name)}: ${tok.value}px;`);
  }

  L.push("");
  L.push("  /* semantic roles — light. Reference these, never the palette. */");
  for (const [k, ref] of entries(T.semantic.light)) {
    L.push(`  --lk-${kebab(k)}: var(--lk-color-${kebab(ref)});`);
  }
  L.push("  --lk-border-color: var(--lk-border);");
  L.push("}");
  L.push("");

  const darkBlock = (indent) => {
    const out = [];
    for (const [k, ref] of entries(T.semantic.dark)) {
      out.push(`${indent}--lk-${kebab(k)}: var(--lk-color-${kebab(ref)});`);
    }
    out.push(`${indent}--lk-border-color: var(--lk-border);`);
    return out.join("\n");
  };

  L.push("/* Dark theme — DESIGN.md §6, §68. Three viewer states are covered:");
  L.push("   an explicit choice stamps data-theme, and the default system setting");
  L.push("   stamps nothing, leaving only prefers-color-scheme. */");
  L.push("@media (prefers-color-scheme: dark) {");
  L.push('  :root:not([data-theme="light"]) {');
  L.push(darkBlock("    "));
  L.push("  }");
  L.push("}");
  L.push("");
  L.push(':root[data-theme="dark"] {');
  L.push(darkBlock("  "));
  L.push("}");
  L.push("");
  L.push("/* Motion is a preference, not decoration — DESIGN.md §41, §42. */");
  L.push("@media (prefers-reduced-motion: reduce) {");
  L.push("  :root {");
  L.push("    --lk-duration-fast: 1ms;");
  L.push("    --lk-duration-base: 1ms;");
  L.push("  }");
  L.push("}");
  L.push("");

  return L.join("\n");
}

/* --------------------------------------------------------------- TS emit */

function emitTs() {
  const L = [];
  L.push("/**");
  for (const line of BANNER_LINES) L.push(` * ${line}`);
  L.push(" */");
  L.push("");
  L.push("export const tokens = " + JSON.stringify(stripMeta(T), null, 2) + " as const;");
  L.push("");
  L.push("export type SemanticColorKey = keyof typeof tokens.semantic.light;");
  L.push("export type SpacingKey = keyof typeof tokens.spacing;");
  L.push("export type TypeScaleKey = keyof typeof tokens.typography.scale;");
  L.push("");
  L.push("/** CSS custom-property name for a semantic colour role. */");
  L.push("export const cssVar = (key: SemanticColorKey): string =>");
  L.push('  `var(--lk-${key.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase()})`;');
  L.push("");
  return L.join("\n");
}

/** Drop $comment/$meta keys so the TS payload is data only. */
function stripMeta(node) {
  if (Array.isArray(node)) return node.map(stripMeta);
  if (node && typeof node === "object") {
    return Object.fromEntries(entries(node).map(([k, v]) => [k, stripMeta(v)]));
  }
  return node;
}

/* ----------------------------------------------------------- dart format */

/**
 * Runs `dart format` over generated Dart.
 *
 * The repository runs `dart format --set-exit-if-changed` in CI, so generated
 * output has to already be formatted or the two checks fight each other: the
 * formatter rewrites the file, and the drift check then reports it as stale.
 * Formatting here makes the committed file the fixed point of both.
 *
 * A missing `dart` is therefore fatal rather than a warning. Falling back to
 * unformatted output would silently compare two different shapes of the same
 * tokens and report drift that regenerating cannot fix.
 */
function dartFormat(source) {
  const scratch = join(tmpdir(), `lk-tokens-${process.pid}.dart`);
  try {
    writeFileSync(scratch, source);
    const r = spawnSync(
      "dart",
      ["format", "--output=show", "--summary=none", scratch],
      { encoding: "utf8" },
    );
    if (r.error || r.status !== 0) {
      console.error(
        "\n`dart` is not on PATH, so tokens.g.dart cannot be produced in the\n" +
          "`dart format` shape it is committed in. Install Flutter, or pass\n" +
          "`--targets=web` to work on the CSS and TS outputs alone.",
      );
      process.exit(1);
    }
    // Defensive: older Dart appends a "Formatted N files ..." summary to
    // stdout even with --output=show, which would land inside the file.
    return r.stdout.replace(/^Formatted .*seconds\.\n?$/m, "");
  } finally {
    rmSync(scratch, { force: true });
  }
}

/* ------------------------------------------------------------------ main */

checkContrast();

/*
 * Targets exist because the outputs need different toolchains. tokens.g.dart
 * is committed in `dart format` shape and can only be reproduced where `dart`
 * lives, so CI splits the gate: the Node job checks `web`, the Flutter job
 * checks `dart`. Run together they are the same check as before.
 */
const ALL_TARGETS = ["dart", "web"];
const targetsArg = process.argv.find((a) => a.startsWith("--targets="));
const TARGETS = targetsArg ? targetsArg.slice("--targets=".length).split(",") : ALL_TARGETS;

for (const t of TARGETS) {
  if (!ALL_TARGETS.includes(t)) {
    console.error(`Unknown target "${t}". Expected one or more of: ${ALL_TARGETS.join(", ")}.`);
    process.exit(1);
  }
}

// Bodies are thunks so an unselected Dart target never shells out to `dart`.
const outputs = [
  {
    target: "dart",
    path: join(REPO, "mobile/lib/app/theme/tokens.g.dart"),
    render: () => dartFormat(emitDart()),
  },
  { target: "web", path: join(HERE, "dist/tokens.css"), render: emitCss },
  { target: "web", path: join(HERE, "dist/tokens.ts"), render: emitTs },
].filter((o) => TARGETS.includes(o.target));

let drifted = 0;
for (const { path, render } of outputs) {
  const body = render();
  const rel = path.replace(REPO + "/", "");
  if (CHECK) {
    let current = null;
    try {
      current = readFileSync(path, "utf8");
    } catch {
      /* missing counts as drift */
    }
    if (current === body) {
      console.log(`  ok    ${rel}`);
    } else {
      console.error(`  DRIFT ${rel}`);
      drifted++;
    }
  } else {
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, body);
    console.log(`  wrote ${rel} (${body.length} bytes)`);
  }
}

if (CHECK && drifted) {
  console.error(
    `\n${drifted} generated file(s) do not match tokens.json.\nRun \`npm run tokens\` and commit the result.`,
  );
  process.exit(1);
}

console.log(
  CHECK
    ? `\nTokens are in sync (${TARGETS.join(", ")}).`
    : `\nTokens generated (${TARGETS.join(", ")}).`,
);
