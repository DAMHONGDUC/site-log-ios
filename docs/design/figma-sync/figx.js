/* Figma sync, browser side: serialises a rendered design page into chunks and posts them to server.mjs (see README.md). */
(function () {
  const P = window.__FIGX = {};
  P.materialise = function (root = document.body) {
    if (document.documentElement.dataset.figxMat) return 'already';
    let n = 0;
    for (const el of [...root.querySelectorAll('*')]) {
      if (el.closest('svg')) continue;
      for (const pseudo of ['::before', '::after']) {
        const cs = getComputedStyle(el, pseudo);
        if (!cs || cs.content === 'none' || cs.content === 'normal' || cs.display === 'none') continue;
        const sp = document.createElement('span');
        sp.dataset.figxPseudo = pseudo;
        for (let i = 0; i < cs.length; i++) { const k = cs[i]; sp.style.setProperty(k, cs.getPropertyValue(k)); }
        let txt = cs.content;
        txt = (txt.startsWith('"') || txt.startsWith("'")) ? txt.slice(1, -1) : '';
        sp.textContent = txt;
        if (pseudo === '::before') el.insertBefore(sp, el.firstChild); else el.appendChild(sp);
        n++;
      }
    }
    const st = document.createElement('style');
    st.textContent = '*:not([data-figx-pseudo])::before, *:not([data-figx-pseudo])::after { content: none !important; display: none !important; }';
    document.head.appendChild(st);
    document.documentElement.dataset.figxMat = '1';
    return n;
  };

  const hex = (c) => {
    const m = c && c.match(/rgba?\(([^)]+)\)/);
    if (!m) return null;
    const p = m[1].split(/[ ,\/]+/).filter(Boolean).map(Number);
    const a = p.length > 3 ? p[3] : 1;
    if (!(a > 0.004)) return null;
    const h = p.slice(0, 3).map(v => Math.round(v).toString(16).padStart(2, '0')).join('').toUpperCase();
    return a < 1 ? h + Math.round(a * 255).toString(16).padStart(2, '0').toUpperCase() : h;
  };
  const r1 = (v) => Math.round(v * 2) / 2;
  const splitTop = (s) => { const out = []; let d = 0, cur = ''; for (const ch of s) { if (ch === '(') d++; if (ch === ')') d--; if (ch === ',' && d === 0) { out.push(cur.trim()); cur = ''; } else cur += ch; } if (cur.trim()) out.push(cur.trim()); return out; };
  const shadows = (s) => {
    if (!s || s === 'none') return null;
    const out = [];
    for (const part of splitTop(s)) {
      const col = part.match(/rgba?\([^)]+\)/); const c = col ? hex(col[0]) : null; if (!c) continue;
      const rest = part.replace(/rgba?\([^)]+\)/, '').trim();
      const inset = /inset/.test(rest);
      const nums = rest.replace('inset', '').trim().split(/\s+/).map(parseFloat).filter(v => !isNaN(v));
      const [x = 0, y = 0, b = 0, sp = 0] = nums;
      out.push([inset ? 'i' : 'd', r1(x), r1(y), r1(b), r1(sp), c]);
    }
    return out.length ? out : null;
  };
  const conic = (bg) => { const m = bg && bg.match(/conic-gradient\((.*)\)$/); if (!m) return null; const parts = splitTop(m[1]); const a = parts[0].match(/(rgba?\([^)]+\))\s+([\d.]+)deg/); const b = parts[1] && parts[1].match(/(rgba?\([^)]+\))/); return a ? [hex(a[1]), parseFloat(a[2]), b ? hex(b[1]) : null] : null; };
  const linear = (bg) => {
    const m = bg && bg.match(/linear-gradient\((.*)\)$/); if (!m) return null;
    const parts = splitTop(m[1]); let ang = 180;
    if (/deg/.test(parts[0])) ang = parseFloat(parts.shift());
    else if (/^to /.test(parts[0])) { const t = parts.shift(); ang = { 'to bottom': 180, 'to top': 0, 'to right': 90, 'to left': 270 }[t] ?? 180; }
    const stops = parts.map((p, i) => { const c = p.match(/rgba?\([^)]+\)/); const pos = p.match(/([\d.]+)%/); return [c ? (hex(c[0]) || '00000000') : '00000000', pos ? parseFloat(pos[1]) / 100 : i / Math.max(1, parts.length - 1)]; });
    return [ang, stops];
  };
  const famCode = (f) => /Plex Mono/i.test(f) ? 'm' : /JetBrains/i.test(f) ? 'j' : /Inter/i.test(f) ? 'i' : 'p';

  P.ser = function (rootEl, opt = {}) {
    const svgs = [], svgIdx = new Map();
    const keep = opt.keep || '';
    const addSvg = (s) => { if (!svgIdx.has(s)) { svgIdx.set(s, svgs.length); svgs.push(s); } return svgIdx.get(s); };
    const box = (r, px, py) => [r1(r.left + scrollX - px), r1(r.top + scrollY - py), r1(r.width), r1(r.height)];
    function svgOf(el, r) {
      const cl = el.cloneNode(true);
      const src = [el, ...el.querySelectorAll('*')], dst = [cl, ...cl.querySelectorAll('*')];
      src.forEach((s, i) => {
        const cs = getComputedStyle(s), d = dst[i];
        if (s !== el && cs.display === 'none') { d.remove(); return; }
        for (const k of ['fill', 'stroke']) {
          const v = cs[k];
          if (!v || v === 'none') { if (s.tagName !== 'svg') d.setAttribute(k, 'none'); continue; }
          if (/url\(/.test(v)) continue;
          const h = hex(v); d.setAttribute(k, h ? '#' + h.slice(0, 6) : 'none');
          if (h && h.length === 8) d.setAttribute(k + '-opacity', (parseInt(h.slice(6), 16) / 255).toFixed(2));
        }
        const sw = cs.strokeWidth; if (sw && d.getAttribute('stroke') && d.getAttribute('stroke') !== 'none') d.setAttribute('stroke-width', parseFloat(sw));
        if (s !== el && cs.opacity !== '1') d.setAttribute('opacity', cs.opacity);
        d.removeAttribute('class'); d.removeAttribute('style'); d.removeAttribute('data-lucide');
      });
      cl.querySelectorAll('[marker-end]').forEach(path => {
        const n = (path.getAttribute('d') || '').match(/-?[\d.]+/g); if (!n || n.length < 4) return;
        const [x1, y1, x2, y2] = n.slice(-4).map(Number); const a = Math.atan2(y2 - y1, x2 - x1);
        const P = (d, w) => `${(x2 - d * Math.cos(a) - w * Math.sin(a)).toFixed(1)},${(y2 - d * Math.sin(a) + w * Math.cos(a)).toFixed(1)}`;
        const tri = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        tri.setAttribute('d', `M${P(8, -5)} L${x2 + 2 * Math.cos(a)},${y2 + 2 * Math.sin(a)} L${P(8, 5)} Z`); tri.setAttribute('fill', path.getAttribute('stroke') || '#2563EB');
        path.removeAttribute('marker-end'); path.parentNode.appendChild(tri);
      });
      cl.querySelectorAll('marker').forEach(m => m.remove());
      cl.setAttribute('width', Math.round(r.width)); cl.setAttribute('height', Math.round(r.height));
      cl.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
      return addSvg(cl.outerHTML.replace(/\s+/g, ' ').replace(/> </g, '><').replace(/(\d+\.\d{2})\d+/g, '$1'));
    }
    function pie(w, h, c1, deg, c2) {
      const R = Math.min(w, h) / 2, cx = w / 2, cy = h / 2;
      let s = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}">`;
      if (c2) s += `<circle cx="${cx}" cy="${cy}" r="${R}" fill="#${c2.slice(0, 6)}"/>`;
      if (deg >= 359.9) s += `<circle cx="${cx}" cy="${cy}" r="${R}" fill="#${c1.slice(0, 6)}"/>`;
      else if (deg > 0) { const a = (deg - 90) * Math.PI / 180; const x = cx + R * Math.cos(a), y = cy + R * Math.sin(a); s += `<path d="M${cx} ${cy} L${cx} ${cy - R} A${R} ${R} 0 ${deg > 180 ? 1 : 0} 1 ${x.toFixed(2)} ${y.toFixed(2)} Z" fill="#${c1.slice(0, 6)}"/>`; }
      return addSvg(s + '</svg>');
    }
    function textRun(node, px, py, cs, sc = 1) {
      let t = node.textContent.replace(/\s+/g, ' ');
      if (!t.trim()) return null;
      const range = document.createRange(); range.selectNodeContents(node);
      const rects = [...range.getClientRects()].filter(r => r.width > 0.5);
      if (!rects.length) return null;
      const u = rects.reduce((a, r) => ({ l: Math.min(a.l, r.left), t: Math.min(a.t, r.top), r: Math.max(a.r, r.right), b: Math.max(a.b, r.bottom) }), { l: 1e9, t: 1e9, r: -1e9, b: -1e9 });
      if (node.previousSibling == null || cs.display === 'flex') t = t.replace(/^ /, '');
      if (node.nextSibling == null || cs.display === 'flex') t = t.replace(/ $/, '');
      if (!t) return null;
      if (cs.textTransform === 'uppercase') t = t.toUpperCase();
      const fs = parseFloat(cs.fontSize) * sc;
      const L = (cs.lineHeight === 'normal' ? Math.round(parseFloat(cs.fontSize) * 1.25) : parseFloat(cs.lineHeight)) * sc;
      const lines = new Set(rects.map(r => Math.round(r.top))).size;
      const ch = rects[0].height;
      const y = u.t - (L - ch) / 2;
      const p = { t, z: r1(fs), w: +cs.fontWeight, f: famCode(cs.fontFamily), c: hex(cs.color) || '000000', l: r1(L) };
      if (lines > 1) { p.ml = 1; if (cs.textAlign === 'center') p.a = 'c'; else if (cs.textAlign === 'right' || cs.textAlign === 'end') p.a = 'r'; }
      const ls = parseFloat(cs.letterSpacing) * sc; if (ls) p.ls = Math.round(ls * 100) / 100;
      if (cs.fontStyle === 'italic') p.it = 1;
      const td = cs.textDecorationLine || ''; if (td.includes('underline')) p.u = 1; if (td.includes('line-through')) p.st = 1;
      const w = lines > 1 ? u.r - u.l + 2 : u.r - u.l;
      return ['T', r1(u.l + scrollX - px), r1(y + scrollY - py), r1(w), r1(L * lines), p];
    }
    function nameOf(el) {
      if (el.matches('figure')) { const c = el.querySelector('figcaption'); return c ? c.textContent.replace(/\s+/g, ' ').trim() : 'figure'; }
      if (el.matches('section, .group, .cmp')) { const h = el.querySelector('h1, h2, h3'); if (h) return ((h.firstChild && h.firstChild.nodeType === 3 ? h.firstChild.textContent : h.textContent) || '').replace(/\s+/g, ' ').trim().slice(0, 60); }
      return el.classList[0] || el.tagName.toLowerCase();
    }
    function walk(el, px, py, out, isRoot, psc = 1) {
      const cs = getComputedStyle(el);
      if (cs.display === 'none' || cs.visibility === 'hidden' || +cs.opacity === 0) return;
      const tag = el.tagName.toLowerCase();
      if (['script', 'style', 'link', 'br', 'template', 'noscript'].includes(tag)) return;
      const r = el.getBoundingClientRect();
      if (tag === 'svg') {
        if (!(r.width && r.height)) return;
        const rr = parseFloat(cs.borderTopLeftRadius) || 0;
        const rad = cs.borderTopLeftRadius.includes('%') ? Math.min(r.width, r.height) * parseFloat(cs.borderTopLeftRadius) / 100 : rr;
        const sv = ['S', 0, 0, r1(r.width), r1(r.height), svgOf(el, r)];
        if (rad) out.push(['F', ...box(r, px, py), { r: r1(Math.min(rad, Math.min(r.width, r.height) / 2)), c: 1, n: 'mask' }, [sv]]);
        else out.push(['S', ...box(r, px, py), sv[5]]);
        return;
      }
      const sc = el.offsetWidth > 0 && r.width > 0 ? r.width / el.offsetWidth : psc;
      const p = {};
      const fill = hex(cs.backgroundColor); if (fill) p.f = fill;
      const cg = conic(cs.backgroundImage);
      if (cg && cg[0]) { out.push(['S', ...box(r, px, py), pie(Math.round(r.width), Math.round(r.height), cg[0], cg[1], cg[2])]); return; }
      const lg = linear(cs.backgroundImage); if (lg) p.g = lg;
      const bw = ['Top', 'Right', 'Bottom', 'Left'].map(s => r1((parseFloat(cs['border' + s + 'Width']) || 0) * sc));
      const bc = ['Top', 'Right', 'Bottom', 'Left'].map((s, i) => bw[i] && cs['border' + s + 'Style'] !== 'none' ? hex(cs['border' + s + 'Color']) : null);
      const dashed = ['Top', 'Right', 'Bottom', 'Left'].some(s => cs['border' + s + 'Style'] === 'dashed') ? 1 : 0;
      if (bc.some(Boolean)) {
        if (bw.every(w => w === bw[0]) && bc.every(c => c === bc[0])) p.s = [bw[0], bc[0], dashed];
        else p.sw = [bw.map((w, i) => bc[i] ? w : 0), bc.find(Boolean), dashed];
      }
      const rad = ['TopLeft', 'TopRight', 'BottomRight', 'BottomLeft'].map(k => { const v = cs['border' + k + 'Radius']; return v.includes('%') ? Math.min(r.width, r.height) * parseFloat(v) / 100 : (parseFloat(v) || 0) * sc; }).map(v => r1(Math.min(v, Math.min(r.width, r.height) / 2)));
      if (rad.some(Boolean)) p.r = rad.every(v => v === rad[0]) ? rad[0] : rad;
      const sh = shadows(cs.boxShadow); if (sh) p.e = sc === 1 ? sh : sh.map(([k, x, y, b, sp, c]) => [k, r1(x * sc), r1(y * sc), r1(b * sc), r1(sp * sc), c]);
      const bm = (cs.backdropFilter || cs.webkitBackdropFilter || '').match(/blur\(([\d.]+)px\)/); if (bm) p.b = r1(+bm[1] * sc);
      if (+cs.opacity < 1) p.o = +(+cs.opacity).toFixed(2);
      if ((cs.overflowX !== 'visible' || cs.overflowY !== 'visible') && el.children.length) p.c = 1;
      const kept = isRoot || (keep && el.matches(keep));
      const visual = kept || p.f || p.g || p.s || p.sw || p.e || p.b || p.o || p.c;
      const nx = visual ? r.left + scrollX : px, ny = visual ? r.top + scrollY : py;
      const kids = [];
      for (const c of el.childNodes) {
        if (c.nodeType === 3) { const t = textRun(c, nx, ny, cs, sc); if (t) kids.push(t); }
        else if (c.nodeType === 1) walk(c, nx, ny, kids, false, sc);
      }
      if (visual && r.width > 0 && r.height > 0) {
        p.n = nameOf(el);
        const node = ['F', ...box(r, px, py), p];
        if (kids.length) node.push(kids);
        out.push(node);
      } else out.push(...kids);
    }
    const out = [];
    walk(rootEl, 0, 0, out, true);
    return { s: svgs, d: out };
  };

  const b64 = (s) => { const bytes = new TextEncoder().encode(s); let bin = ''; for (let i = 0; i < bytes.length; i += 0x8000) bin += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000)); return btoa(bin); };
  P.carrier = (json) => `<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"><text x="0" y="6" font-size="6">${b64(json)}</text></svg>`;
  P.post = async (name, body) => (await fetch('http://localhost:8766/?name=' + encodeURIComponent(name), { method: 'POST', body })).text();

  /* <img src="*.svg"> → inline <svg> in a clipping span, so it exports as vectors */
  P.inlineImgs = async function () {
    let n = 0;
    for (const img of [...document.querySelectorAll('img')]) {
      if (!/\.svg(\?|$)/.test(img.src)) continue;
      const txt = await (await fetch(img.src)).text();
      const r = img.getBoundingClientRect(), cs = getComputedStyle(img);
      const sp = document.createElement('span');
      sp.style.cssText = `display:${cs.display === 'inline' ? 'inline-block' : cs.display};width:${r.width}px;height:${r.height}px;border-radius:${cs.borderRadius};overflow:hidden;margin:${cs.margin};flex:none;vertical-align:${cs.verticalAlign}`;
      sp.innerHTML = txt.replace(/<\?xml[^>]*>/, '');
      const s = sp.querySelector('svg'); s.setAttribute('width', r.width); s.setAttribute('height', r.height); s.style.display = 'block';
      img.replaceWith(sp); n++;
    }
    return n;
  };

  P.exportOne = async function (name, el, keepSel) {
    P.materialise();
    const json = JSON.stringify(P.ser(el, { keep: keepSel }));
    await P.post(name, P.carrier(json));
    return json.length;
  };

  /* chunks: elements to export as top-level frames, in document order */
  P.exportPage = async function (prefix, chunkSel, keepSel, extra = {}) {
    P.materialise();
    const chunks = [...document.querySelectorAll(chunkSel)];
    const report = [];
    let i = 0;
    for (const el of chunks) {
      const d = P.ser(el, { keep: keepSel });
      const json = JSON.stringify(d);
      const name = `figx-c-${prefix}-${String(++i).padStart(3, '0')}.svg`;
      await P.post(name, P.carrier(json));
      report.push([name, json.length]);
    }
    const meta = { bg: hex(getComputedStyle(document.body).backgroundColor) || 'FFFFFF', w: document.documentElement.scrollWidth, h: document.documentElement.scrollHeight, ...extra };
    await P.post(`figx-meta-${prefix}.json`, JSON.stringify(meta));
    return { count: report.length, total: report.reduce((a, r) => a + r[1], 0), max: Math.max(...report.map(r => r[1])), meta };
  };
})();
