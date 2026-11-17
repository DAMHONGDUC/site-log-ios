/* Design tokens: the single source for every colour and text style on the three pages.
   DSColor (iOS and Android) and DSTextStyle mirror these values; change them here first. */
const COLOR_TOKENS = [
  // [Figma variable, css var, DSColor name, light, dark, Material 3 role set in SiteLogTheme, usage]
  ['Background', [
    ['bg/canvas', 'bg', 'canvas', '#FFFFFF', '#0F1011', 'background', 'Screen background'],
    ['bg/raised', 'surface', 'raised', '#FFFFFF', '#18191B', 'surface', 'Docks, tab and navigation bars, sheets, dialogs'],
    ['bg/fill', 'sunken', 'fill', '#F3F2EF', '#232427', '—', 'Text fields, search, segmented track, panels, active nav indicator'],
    ['bg/plan', 'plan', 'plan', '#FBFAF7', '#1B1C1E', '—', 'Floor-plan canvas'],
  ]],
  ['Line', [
    ['line/hairline', 'line', 'hairline', '#E8E5E0', '#2C2D31', '—', 'Row separators, dock and bar edges'],
    ['line/strong', 'line-strong', 'lineStrong', '#CFCAC1', '#3F4045', '—', 'Outlined buttons and fields, dashed drop zones'],
  ]],
  ['Text', [
    ['text/primary', 'ink', 'textPrimary', '#16181B', '#F2F0EC', 'primary · onSurface', 'Titles, body, primary button fill'],
    ['text/secondary', 'ink2', 'textSecondary', '#63676E', '#A4A7AD', '—', 'Subtitles, meta, counts, placeholders, footers'],
    ['text/tertiary', 'ink3', 'textTertiary', '#868A91', '#80848A', '—', 'Icons, chevrons, disabled controls (3:1); never text'],
    ['text/on-primary', 'on-ink', 'onPrimary', '#FFFFFF', '#16181B', 'onPrimary', 'Text on primary (ink) fills'],
  ]],
  ['Accent', [
    ['accent/hi-vis', 'hi', 'hiVis', '#FFD400', '#FFD400', '—', 'App mark, capture button, live-session dot: nothing else'],
    ['accent/on-hi-vis', 'hi-ink', 'onHiVis', '#1B1700', '#1B1700', '—', 'Icon and text on hi-vis'],
  ]],
  ['Severity & status', [
    ['severity/critical', 'crit', 'critical', '#D8342A', '#FF5B4F', 'error', '● Critical, failed, overdue'],
    ['severity/major', 'major', 'major', '#B35F00', '#FFA43D', '—', '● Major, needs verification'],
    ['severity/minor', 'minor', 'minor', '#3E6FA8', '#80A9DC', '—', '● Minor'],
    ['status/success', 'ok', 'success', '#1D8454', '#43C287', '—', '● Resolved, pass, connected'],
    ['status/waiting', 'wait', 'waiting', '#7E838B', '#8E939B', '—', '◌ Waiting: never red'],
  ]],
];

/* 4 sizes (28, 20, 17, 13) and 2 weights (400, 600). System chrome (status bar, tab and navigation bar
   labels, badges, keyboards) keeps the platform's own sizes and is not a token. */
const TYPE_TOKENS = [
  // [token, family, weight, tracking, tabular, iOS [size, line], Android [size, line], usage, SwiftUI, Compose]
  ['title', 'sans', 600, '-0.02em', false, [28, 36], [28, 36], 'Screen titles (large title, large top app bar), peak headlines', '.title.weight(.semibold)', 'headlineMedium'],
  ['figure', 'sans', 600, '-0.02em', true, [28, 36], [28, 36], 'Big progress numbers', '.title.weight(.semibold).monospacedDigit()', 'DSTextStyle.figure'],
  ['heading', 'sans', 600, '-0.01em', false, [20, 28], [20, 28], 'Section headers, detail, sheet and dialog titles', '.title3.weight(.semibold)', 'titleLarge'],
  ['bodyStrong', 'sans', 600, '0', false, [17, 24], [17, 24], 'Buttons, nav titles, emphasised rows', '.headline', 'titleMedium'],
  ['body', 'sans', 400, '0', false, [17, 24], [17, 24], 'Row titles, text fields, sentences', '.body', 'bodyLarge'],
  ['captionStrong', 'sans', 600, '0', false, [13, 20], [13, 20], 'Field labels, tags, overlay labels', '.footnote.weight(.semibold)', 'labelMedium'],
  ['caption', 'sans', 400, '0', false, [13, 20], [13, 20], 'Subtitles, meta, counts, footers', '.footnote', 'bodySmall'],
  ['code', 'mono', 400, '0', false, [13, 20], [13, 20], 'Only real codes: hashes, file names, report IDs', '.footnote.monospaced()', 'DSTextStyle.code'],
];

/* Spacing: every padding, margin and gap is one of these (4 / 8 pt grid). Same names in DSSpacing on both platforms. */
const SPACING_TOKENS = [
  // [name, value (pt on iOS, dp on Android), used for]
  ['spacing0', 0, 'Rows stacked in a list (the hairline separates them)'],
  ['spacing4', 4, 'Title to its subtitle, icon to its label, segmented track inset'],
  ['spacing8', 8, 'Inside a group: chips, side-by-side buttons, label to field, marker to text'],
  ['spacing12', 12, 'Row lead to text, lines inside a panel'],
  ['spacing16', 16, 'Screen side margin, row and panel padding, between fields'],
  ['spacing20', 20, 'Sheet side padding (iOS), floating tab bar inset'],
  ['spacing24', 24, 'Between groups on a dense screen, sheet and dialog padding (Android)'],
  ['spacing32', 32, 'Between sections on a screen'],
  ['spacing40', 40, 'Around a centred hero (done, empty state)'],
  ['spacing48', 48, 'Large top inset, space under a keypad'],
  ['spacing64', 64, 'Space kept free above floating bars'],
  ['spacing96', 96, 'Lifts centred empty states clear of the floating tab bar'],
];

/* Fixed layout values: set by the platform or by the touch-target rule, not picked per screen. */
const LAYOUT_CONSTANTS = [
  // [name, iOS, Android, why]
  ['Screen side margin', '16 pt', '16 dp', 'spacing16 on every screen'],
  ['Minimum touch target', '44 pt', '48 dp', 'Platform minimum; also what works with gloves'],
  ['Control height (buttons, fields, chips)', '44–50 pt', '48–56 dp', 'Never under the touch target'],
  ['Status bar', '54 pt', '40 dp', 'System'],
  ['Bottom safe area', '34 pt (home indicator)', '24 dp (gesture bar)', 'System'],
  ['Floating tab bar / navigation bar', '64 pt capsule, 20 pt inset, 26 pt above the bottom', '80 dp bar', 'Content scrolls underneath (iOS)'],
];

const FONTS = {
  ios: { sans: 'IBM Plex Sans', mono: 'IBM Plex Mono', ships: 'SF Pro · SF Mono' },
  android: { sans: 'Inter', mono: 'JetBrains Mono', ships: 'Inter · JetBrains Mono (bundled)' },
};

/* A page may set window.TYPE_ALIAS = { body: '.row .t' } before this script: those selectors get the style too. */
(() => {
  const alias = window.TYPE_ALIAS || {};
  const all = COLOR_TOKENS.flatMap(([, t]) => t);
  const vars = (i) => all.map(t => `--${t[1]}: ${t[i]};`).join(' ');
  const typeRules = (platform, index) => TYPE_TOKENS
    .filter(t => t[index])
    .map(([n, f, w, tr, tab, ios, android]) => {
      const [s, lh] = platform === 'ios' ? ios : android;
      const extra = alias[n] ? alias[n].split(',').map(sel => `, .p-${platform} ${sel.trim()}`).join('') : '';
      return `.p-${platform} .t-${n}${extra} { font-family: var(--${f}); font-size: ${s}px; line-height: ${lh}px; font-weight: ${w}; letter-spacing: ${tr}; ${tab ? "font-feature-settings: 'tnum';" : ''} }`;
    }).join('\n');
  const fontVars = (p) => `.p-${p} { --sans: '${FONTS[p].sans}', system-ui, sans-serif; --mono: '${FONTS[p].mono}', ui-monospace, monospace; }`;
  document.write(`<style id="tokens">:root, .theme-light { ${vars(3)} } .theme-dark { ${vars(4)} color-scheme: dark; }
${fontVars('ios')}\n${fontVars('android')}\n${typeRules('ios', 5)}\n${typeRules('android', 6)}</style>`);
})();
