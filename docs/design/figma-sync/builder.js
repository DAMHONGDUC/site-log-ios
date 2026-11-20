// Runs inside use_figma via new AsyncFunction('figma','D','args', src). Builds chunk carriers on args.page.
const page = await figma.getNodeByIdAsync(args.page);
await figma.setCurrentPageAsync(page);
const FAM = { p: 'IBM Plex Sans', m: 'IBM Plex Mono', i: 'Inter', j: 'JetBrains Mono' };
const STY = {
  p: { 300: 'Light', 400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold', 800: 'Bold', 900: 'Bold' },
  m: { 300: 'Light', 400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold', 800: 'Bold', 900: 'Bold' },
  i: { 300: 'Light', 400: 'Regular', 500: 'Medium', 600: 'Semi Bold', 700: 'Bold', 800: 'Extra Bold', 900: 'Black' },
  j: { 300: 'Light', 400: 'Regular', 500: 'Medium', 600: 'Bold', 700: 'Bold', 800: 'ExtraBold', 900: 'ExtraBold' },
};
const fontOf = (f, w, it) => {
  const fam = FAM[f] || FAM.p; let s = (STY[f] || STY.p)[Math.round((w || 400) / 100) * 100] || 'Regular';
  if (it) s = s === 'Regular' ? 'Italic' : s + ' Italic';
  return { family: fam, style: s };
};
const loaded = new Set();
const load = async (fn) => { const k = fn.family + '|' + fn.style; if (loaded.has(k)) return true; try { await figma.loadFontAsync(fn); loaded.add(k); return true; } catch (e) { return false; } };
const col = (h) => ({ color: { r: parseInt(h.slice(0, 2), 16) / 255, g: parseInt(h.slice(2, 4), 16) / 255, b: parseInt(h.slice(4, 6), 16) / 255 }, a: h.length > 6 ? parseInt(h.slice(6, 8), 16) / 255 : 1 });
const solid = (h) => { const c = col(h); return { type: 'SOLID', color: c.color, opacity: c.a }; };
const grad = (ang, stops) => {
  const t = ang * Math.PI / 180; const dx = Math.sin(t), dy = -Math.cos(t);
  const nx = -dy, ny = dx;
  const M = [[dx, nx, 0.5 - 0.5 * dx - 0.5 * nx], [dy, ny, 0.5 - 0.5 * dy - 0.5 * ny]];
  const det = M[0][0] * M[1][1] - M[0][1] * M[1][0];
  const a = M[1][1] / det, b = -M[0][1] / det, c = -M[1][0] / det, d = M[0][0] / det;
  const tx = -(a * M[0][2] + b * M[1][2]), ty = -(c * M[0][2] + d * M[1][2]);
  return { type: 'GRADIENT_LINEAR', gradientTransform: [[a, b, tx], [c, d, ty]], gradientStops: stops.map(([h, p]) => { const k = col(h); return { position: Math.max(0, Math.min(1, p)), color: { ...k.color, a: k.a } }; }) };
};
const errors = [];
let made = 0;
async function build(n, parent, svgs) {
  const [type, x, y, w, h, p] = n;
  if (type === 'S') {
    let node;
    try { node = figma.createNodeFromSvg(svgs[p]); } catch (e) { errors.push('svg ' + String(e).slice(0, 60)); return; }
    node.name = 'icon'; parent.appendChild(node); node.x = x; node.y = y;
    if (Math.abs(node.width - w) > 0.5 || Math.abs(node.height - h) > 0.5) { try { node.resize(Math.max(w, 0.01), Math.max(h, 0.01)); } catch (e) {} }
    made++; return;
  }
  if (type === 'T') {
    const t = figma.createText();
    let fn = fontOf(p.f, p.w, p.it);
    if (!(await load(fn))) { fn = fontOf(p.f, p.w, 0); if (!(await load(fn))) { fn = { family: 'Inter', style: 'Regular' }; await load(fn); } }
    t.fontName = fn;
    t.characters = p.t;
    t.fontSize = p.z;
    t.lineHeight = { unit: 'PIXELS', value: p.l };
    if (p.ls) t.letterSpacing = { unit: 'PIXELS', value: p.ls };
    t.fills = [solid(p.c)];
    if (p.u) t.textDecoration = 'UNDERLINE'; if (p.st) t.textDecoration = 'STRIKETHROUGH';
    parent.appendChild(t);
    if (p.ml) { t.textAutoResize = 'HEIGHT'; t.resize(Math.max(w, 1), t.height); t.textAlignHorizontal = p.a === 'c' ? 'CENTER' : p.a === 'r' ? 'RIGHT' : 'LEFT'; }
    else t.textAutoResize = 'WIDTH_AND_HEIGHT';
    t.x = x; t.y = y; made++;
    return;
  }
  const f = figma.createFrame();
  f.name = p.n || 'frame';
  parent.appendChild(f);
  f.x = x; f.y = y; f.resize(Math.max(w, 0.01), Math.max(h, 0.01));
  const fills = [];
  if (p.f) fills.push(solid(p.f));
  if (p.g) fills.push(grad(p.g[0], p.g[1]));
  f.fills = fills;
  f.clipsContent = !!p.c;
  if (p.r) { if (Array.isArray(p.r)) { f.topLeftRadius = p.r[0]; f.topRightRadius = p.r[1]; f.bottomRightRadius = p.r[2]; f.bottomLeftRadius = p.r[3]; } else f.cornerRadius = p.r; }
  if (p.s) { f.strokes = [solid(p.s[1])]; f.strokeWeight = p.s[0]; f.strokeAlign = 'INSIDE'; if (p.s[2]) f.dashPattern = [3, 2]; }
  if (p.sw) { f.strokes = [solid(p.sw[1])]; f.strokeAlign = 'INSIDE'; f.strokeTopWeight = p.sw[0][0]; f.strokeRightWeight = p.sw[0][1]; f.strokeBottomWeight = p.sw[0][2]; f.strokeLeftWeight = p.sw[0][3]; if (p.sw[2]) f.dashPattern = [3, 2]; }
  const fx = [];
  if (p.e) for (const [k, ex, ey, bl, sp, c] of p.e) { const cc = col(c); fx.push({ type: k === 'i' ? 'INNER_SHADOW' : 'DROP_SHADOW', color: { ...cc.color, a: cc.a }, offset: { x: ex, y: ey }, radius: bl, spread: sp, visible: true, blendMode: 'NORMAL' }); }
  if (p.b) fx.push({ type: 'BACKGROUND_BLUR', radius: p.b, visible: true });
  if (fx.length) f.effects = fx;
  if (p.o != null) f.opacity = p.o;
  made++;
  for (const k of (n[6] || [])) await build(k, f, svgs);
}
// Carriers may sit on another page (args.src) and are picked by name prefix (args.prefix, default 'figx-c-').
const srcPage = args.src ? await figma.getNodeByIdAsync(args.src) : page;
if (srcPage !== page) await srcPage.loadAsync();
const prefix = args.prefix || 'figx-c-';
const removed = [];
if (args.clear) for (const n of [...page.children]) { if (!n.name.startsWith('figx-')) { removed.push(n.name); n.remove(); } }
const carriers = srcPage.children.filter(n => n.name.startsWith(prefix)).sort((a, b) => a.name < b.name ? -1 : 1);
const todo = carriers.slice(0, args.max || 2);
const done = [];
for (const c of todo) {
  const tn = c.type === 'TEXT' ? c : c.findOne(n => n.type === 'TEXT');
  const data = JSON.parse(D(tn.characters));
  const root = data.d[0];
  await build(root, page, data.s);
  const top = page.children[page.children.length - 1];
  if (top.name === 'page-head') top.name = 'Page header';
  done.push(c.name + ' -> ' + top.id + ' ' + top.name);
  c.remove();
}
if (args.bg) page.backgrounds = [solid(args.bg)];
return { done, removed: removed.length, remaining: carriers.length - todo.length, made, errors: errors.slice(0, 10) };
