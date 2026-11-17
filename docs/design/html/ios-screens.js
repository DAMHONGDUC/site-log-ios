/* iOS screens: used by 2-ios.html (all screens) and 4-flows.html (flows built from the same screens). */
/* ---------- iOS helpers ---------- */
const sb = (o = {}) => `<div class="sb"><span>${o.time || '9:41'}</span><span class="island"></span><span class="r">${signal('currentColor')}${o.noWifi ? '' : wifi('currentColor')}${battery('currentColor')}</span></div>`;
const screen = (id, title, inner, o = {}) => figure(id, title, `<div class="phone ${o.dark ? 'dark' : ''}">${sb(o)}${inner}<div class="home ${o.lightHome ? 'light' : ''}"></div></div>`, 393);
const G = [];


/* iOS 26 nav: a glass back circle, icon actions grouped in one glass capsule, text actions as capsules ('!' = prominent) */
const nav = (o = {}) => {
  const icons = (o.right || []).filter(r => r.startsWith('@'));
  const texts = (o.right || []).filter(r => !r.startsWith('@'));
  const icon = (r) => { const [n, c] = r.slice(1).split('#'); return `<span class="ic ${c ? 'fbtn' : ''}">${I(n, 21)}${c ? `<span class="fbadge">${c}</span>` : ''}</span>`; };
  const group = icons.length ? `<div class="gcap lg">${icons.map(icon).join('')}</div>` : '';
  const txt = texts.map(r => `<div class="gcap txt ${r.startsWith('!') ? 'prom' : 'lg'}">${r.replace('!', '')}</div>`).join('');
  const titleHtml = `${o.title}${o.sub ? `<span class="ti-sub">${o.sub}</span>` : ''}`;
  /* leading: the title sits at the start of the bar (screen name over its project) instead of the centre */
  return `<div class="nav"><div class="l">${o.back ? `<div class="gbtn lg">${I('chevron-left', 24, 2.2)}</div>` : ''}${o.left || ''}${o.title && o.leading ? `<div class="ti-lead">${titleHtml}</div>` : ''}</div>${o.title && !o.leading ? `<div class="ti">${titleHtml}</div>` : ''}<div class="rt">${group}${txt}</div></div>`;
};
const lt = (t, sub) => `<div class="lt"><h1>${t}</h1>${sub ? `<div class="sub t-caption">${sub}</div>` : ''}</div>`;
const content = (h, cls = '') => `<div class="content ${cls}">${h}</div>`;
const dock = (h, cls = '') => `<div class="dock ${cls}">${h}</div>`;
const btn = (t, k = 'primary', ic, o = {}) => `<div class="btn ${k} ${o.sm ? 'sm' : ''}" ${o.disabled ? 'disabled' : ''} ${o.style ? `style="${o.style}"` : ''}>${ic ? I(ic, o.sm ? 17 : 20, 2) : ''}${t}</div>`;
const sec = (title, h, right = '') => `<section class="stack sec" style="gap:4px"><div class="sec-h"><b>${title}</b>${right ? `<span>${right}</span>` : ''}</div>${h}</section>`;
const list = (rows, inset) => `<div class="list" ${inset ? `style="--inset:${inset}px"` : ''}>${rows.join('')}</div>`;
const row = (o) => `<div class="row ${o.cls || ''}">${o.lead || ''}<div class="grow" style="display:flex;flex-direction:column;gap:0px"><div class="t" ${o.tStyle ? `style="${o.tStyle}"` : ''}>${o.title}</div>${o.sub ? `<div class="s">${o.sub}</div>` : ''}</div>${o.trail || ''}${o.chev === false ? '' : `<span class="chev">${I('chevron-right', 17, 2.2)}</span>`}</div>`;
/* Project switch: the current project's site photo + a chevron; opens W1 */
const ws = (i = 0) => `<div class="ws lg">${wsTile(PROJECTS[i][2], 28, 8)}<span class="ws-name">${PROJECTS[i][0]}</span><span style="color:var(--ink2)">${I('chevron-down', 16, 2.4)}</span></div>`;
const tabbar = (on, badge = { Issues: 2 }) => `<div class="tabbar lg">${[['house', 'Home'], ['triangle-alert', 'Issues'], ['refresh-cw', 'Sync'], ['circle-user', 'You']].map(([i, l]) => `<div class="tab ${l === on ? 'on' : ''}">${I(i, 25, l === on ? 2.1 : 1.7)}<span class="sys-label">${l}</span>${badge[l] ? `<span class="badge">${badge[l]}</span>` : ''}</div>`).join('')}</div>`;
const field = (l, v, o = {}) => `<div class="field" ${o.style ? `style="${o.style}"` : ''}>${l ? `<span>${l}</span>` : ''}<div class="input ${o.focus ? 'focus' : ''} ${o.area ? 'area' : ''}">${o.ph ? `<span class="placeholder grow t-body">${v}</span>` : `<span class="grow t-body">${v}${o.focus ? '<span class="caret"></span>' : ''}</span>`}${o.icon ? `<span style="color:var(--ink2)">${I(o.icon, 20)}</span>` : ''}</div></div>`;
const seg = (items, on, cls = '') => `<div class="seg ${cls}">${items.map(t => `<div class="${t === on ? 'on' : ''}">${t}</div>`).join('')}</div>`;
const sheet = (title, body, dk, o = {}) => `<div class="dim"></div><div class="sheet ${o.after || o.full ? 'full' : ''}" ${o.style ? `style="${o.style}"` : ''}><div class="grab"></div><div class="sh"><span class="h3">${title}</span><div class="gbtn lg">${I('x', 18, 2.4)}</div></div><div class="sbody" ${o.after ? 'style="flex:1"' : ''}>${body}</div>${dk ? dock(dk) : ''}${o.after || ''}</div>`;
const keyboard = () => `<div class="kb">${['qwertyuiop', 'asdfghjkl'].map(r => `<div class="kr">${[...r].map(k => `<span class="k">${k}</span>`).join('')}</div>`).join('')}<div class="kr"><span class="k fn" style="width:44px">${I('arrow-big-up', 20)}</span><span style="width:6px"></span>${[...'zxcvbnm'].map(k => `<span class="k">${k}</span>`).join('')}<span style="width:6px"></span><span class="k fn" style="width:44px">${I('delete', 20)}</span></div><div class="kr"><span class="k fn" style="width:90px">123</span><span class="k" style="width:190px;font-size:15px">space</span><span class="k fn" style="width:90px">next</span></div></div>`;
/* App passcode: 6 dots + iOS-style number pad */
const dots = (filled, n = 6) => `<div class="hstack" style="gap:16px;justify-content:center">${Array.from({ length: n }, (_, i) => `<span style="width:13px;height:13px;border-radius:7px;border:1.5px solid var(--ink);${i < filled ? 'background:var(--ink)' : ''}"></span>`).join('')}</div>`;
const numpad = () => `<div style="flex:none;padding:0 40px 64px;display:grid;grid-template-columns:repeat(3,78px);justify-content:space-between;row-gap:16px">${['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'].map(k => k === '' ? '<span></span>' : k === '⌫' ? `<span style="height:78px;display:grid;place-items:center;color:var(--ink)">${I('delete', 26, 1.8)}</span>` : `<span style="width:78px;height:78px;border-radius:39px;background:var(--sunken);display:grid;place-items:center;font-size:28px;font-weight:400">${k}</span>`).join('')}</div>`;
const toolbar = (left, right) => `<div class="toolbar"><div class="side lg">${left}</div><div class="capture">${I('camera', 30, 2)}</div><div class="side lg">${right}</div></div>`;


/* ======================= Access ======================= */
G.push(['Access', 'specs 07, 08', [
screen('A1', 'Face ID lock', `
  ${content(`<div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;text-align:center">
    ${appMark(72)}
    <div class="stack" style="gap:4px"><div class="t-heading">SiteLog is locked</div><div class="fn">Unlock to view site photos and reports.</div></div>
    <div style="margin-top:32px;color:var(--ink2)">${I('scan-face', 64, 1.5)}</div>
  </div>`)}
  ${dock(`${btn('Unlock with Face ID', 'primary', 'scan-face')}${btn('Enter passcode', 'ghost', null, { style: 'font-weight:600' })}`, 'clear')}`),
screen('A3', 'Enter passcode', `
  ${content(`<div style="flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:20px;text-align:center">
    ${appMark(48)}
    <div class="t-heading">Enter passcode</div>
    ${dots(2)}
    <div class="fn">2 tries left before a 1-minute wait</div>
  </div>`)}
  ${numpad()}
  <div class="fn" style="position:absolute;bottom:28px;left:0;right:0;text-align:center;font-weight:600;color:var(--ink)">Forgot passcode?</div>`),
screen('A2', 'Sign in (optional)', `
  ${content(`<div style="padding-top:48px;align-items:center;text-align:center" class="stack">
    ${appMark(56)}
    <div class="t-title" style="margin-top:24px">Your site log,<br>on every device.</div>
    <div class="t-body" style="color:var(--ink2);margin-top:8px">Sign in to back up projects and hand off between iPhone and iPad. Everything still works offline without an account.</div>
  </div>
  <div class="stack" style="margin-top:auto;gap:12px;align-items:center">
    ${[['wifi-off', 'Works with zero signal'], ['shield-check', 'Photos hashed at capture'], ['file-text', 'Signed PDF in one tap']].map(([i, t]) => `<div class="hstack" style="gap:12px"><span style="width:32px;height:32px;border-radius:8px;background:var(--sunken);display:grid;place-items:center">${I(i, 18)}</span><span class="t-body">${t}</span></div>`).join('')}
  </div>`)}
  ${dock(`<div class="btn primary">${I('apple', 20, 2)}Sign in with Apple</div>${btn('Continue with email', 'secondary', 'mail', { style: 'background:var(--surface);border-color:var(--line-strong)' })}${btn('Continue offline', 'ghost', null, { style: 'font-weight:600' })}`, 'clear')}`),
]]);

/* ======================= Home & projects ======================= */
const PLAN_ICON = `<span style="width:56px;height:40px;border-radius:4px;background:var(--plan);border:1px solid var(--line-strong);position:relative;overflow:hidden;flex:none"><svg viewBox="0 0 56 40" style="position:absolute;inset:0" fill="none" stroke="#9A9DA3" stroke-width="1"><rect x="4" y="4" width="48" height="32"/><line x1="28" y1="4" x2="28" y2="20"/><line x1="4" y1="20" x2="52" y2="20"/></svg></span>`;
const ring = (done) => `<span style="width:24px;height:24px;border-radius:12px;flex:none;background:conic-gradient(var(--ok) ${done * 360}deg, var(--sunken) 0)"></span>`;
const TAB_BODY = {
  Sessions: () => list([
      row({ lead: `<span style="width:12px"></span>`, title: 'Tue 12 Aug', sub: '112 photos · 14 issues · Hanh', trail: `<span class="file-tag">PDF</span>` }),
      row({ lead: `<span style="width:12px"></span>`, title: 'Mon 28 Jul', sub: '87 photos · 9 issues · Hanh', trail: `<span class="file-tag">PDF</span>` }),
      row({ lead: `<span style="width:12px"></span>`, title: 'Thu 10 Jul', sub: '64 photos · 5 issues · Minh' }),
    ], 44),
  Locations: () => [['Level 7', '37 of 82 rooms', [['Unit 7A', '3 of 4 rooms checked', 'crit', '2 critical'], ['Unit 7C', '5 of 5 rooms checked', 'ok', 'Done']]], ['Level 8', '0 of 41 rooms', [['Unit 8A', '0 of 4 rooms checked', 'major', '1 major']]]].map(([lvl, count, units]) => sec(lvl, list(units.map(([u, sub, k, n]) => row({ lead: ring(+sub.split(' ')[0] / +sub.split(' ')[2]), title: u, sub, trail: k ? sev(k, n) : '' })), 56), count)).join(''),
  Plans: () => list([['Level 7 architectural', 'PDF · 7 pins'], ['Level 8 architectural', 'PDF · 3 pins'], ['Level 9 architectural', 'Photo of printed sheet · no pins'], ['Level 7 electrical', 'PDF, sheet 2 of 6 · 1 pin']].map(([t, s]) => row({ lead: `<span style="width:56px;height:40px;border-radius:4px;background:var(--plan);border:1px solid var(--line-strong);position:relative;overflow:hidden;flex:none"><svg viewBox="0 0 56 40" style="position:absolute;inset:0" fill="none" stroke="#9A9DA3" stroke-width="1"><rect x="4" y="4" width="48" height="32"/><line x1="28" y1="4" x2="28" y2="20"/><line x1="4" y1="20" x2="52" y2="20"/></svg></span>`, title: t, sub: s })), 88)
    + `<div class="foot">Plans live on this iPhone and open without signal.</div>`,
};
/* Home of the current project: live walkthrough on top, then Sessions · Locations · Plans */
const syncLine = (text, icon = 'cloud-upload') => `<div class="sync-line">${I(icon, 18)}<span class="grow">${text}</span>${I('chevron-right', 16, 2.2)}</div>`;
const homeBody = (tab = 'Sessions', o = {}) => `<div class="stack" style="gap:24px"><div class="stack" style="gap:12px">
    ${o.sync || syncLine('56 files left to upload · about 6 min')}
    ${o.top || `<div class="panel" style="gap:12px">
      <div class="hstack" style="gap:8px"><span class="live"></span><span class="fn" style="color:var(--ink)">Walkthrough in progress · since 8:12</span></div>
      <div><div class="t-bodyStrong">Level 7</div><div class="meta">37 of 82 rooms · 46 photos, 7 new issues</div></div>
      ${progress(37 / 82)}
      <div class="hstack" style="justify-content:flex-end">${btn('Resume', 'primary', null, { sm: true })}</div>
    </div>`}</div>
    <div class="stack" style="gap:16px">${tabsRow(tab)}${TAB_BODY[tab]()}</div></div>`;
const filterBtn = (n = 0) => `<div class="gbtn lg fbtn">${I('list-filter', 20, 2.2)}${n ? `<span class="fbadge">${n}</span>` : ''}</div>`;
const tabsRow = (tab, n = 0) => `<div class="home-tabs">${seg(['Sessions', 'Locations', 'Plans'], tab)}${filterBtn(n)}</div>`;
/* Scrolled Home: the walkthrough card and sync line are gone; app bar + tab row stay pinned on glass */
const pinnedHome = (tab, n, body, right = ['@search', '@ellipsis']) => `<div class="pin-head">${nav({ left: ws(0), right })}${tabsRow(tab, n)}</div>${content(body, 'pinned')}`;
const resultCount = (t) => `<div class="fn">${t}</div>`;
const SCROLLED = {
  Sessions: () => list(MORE_SESSIONS.map(([d, sub, pdf]) => row({ lead: `<span style="width:12px"></span>`, title: d, sub, trail: pdf ? `<span class="file-tag">PDF</span>` : '' })), 44),
  Locations: () => resultCount('4 units') + UNITS_WITH_ISSUES.map(([lvl, units]) => sec(lvl, list(units.map(([u, sub, k, n]) => row({ lead: ring(+sub.split(' ')[0] / +sub.split(' ')[2]), title: u, sub, trail: sev(k, n) })), 56))).join(''),
  Plans: () => list(MORE_PLANS.map(([t, sub]) => row({ lead: PLAN_ICON, title: t, sub })), 88),
};
const FILTERED = {
  Sessions: () => resultCount('4 of 7 sessions') + list(FILTERED_SESSIONS.map(([d, sub]) => row({ lead: `<span style="width:12px"></span>`, title: d, sub, trail: `<span class="file-tag">PDF</span>` })), 44),
  Plans: () => resultCount('3 of 8 plans') + list(FILTERED_PLANS.map(([t, sub]) => row({ lead: PLAN_ICON, title: t, sub })), 88),
  PlansEmpty: () => empty(hero('neutral', 'search-x', 'No plans match', 'Level 9 has one plan, a photo of a printed sheet, and it has no pins yet.', { extra: btn('Clear filters', 'secondary', null, { sm: true }) })),
};
/* Every filter sheet ends with the same two buttons */
const filterActions = () => `<div class="hstack">${btn('Clear', 'outline')}${btn('Apply', 'primary')}</div>`;
const filterSheet = (tab) => sheet(`Filter ${tab.toLowerCase()}`, HOME_FILTERS[tab].map(([label, opts, on]) => `<div class="field"><span>${label}</span><div class="chips" style="flex-wrap:wrap">${opts.map((o, i) => `<span class="chip ${on.includes(i) ? 'on' : ''}">${o}</span>`).join('')}</div></div>`).join(''), filterActions(), HOME_FILTERS[tab].length > 5 ? { full: true, style: 'top:62px' } : {});
const switcher = (cur = 0) => sheet('Projects', `
    ${list(PROJECTS.map(([n, p, v, open, late, live], i) => row({ cls: 'ws-row', lead: wsTile(v, 44, 12), title: `${live ? '<span class="live" style="display:inline-block;margin-right:8px;vertical-align:1px"></span>' : ''}${n}`, sub: `${p} · ${open ? `${open} open` : 'nothing open'}${late ? ` · <span style="color:var(--crit)">${late} overdue</span>` : ''}`, trail: i === cur ? `<span style="color:var(--ink)">${I('check', 22, 2.6)}</span>` : '', chev: false })), 72)}
    ${list([row({ lead: `<span style="width:44px;height:44px;border-radius:12px;background:var(--sunken);display:grid;place-items:center">${I('plus', 22, 2.2)}</span>`, title: 'New project' }), row({ lead: `<span style="width:44px;height:44px;display:grid;place-items:center;color:var(--ink3)">${I('archive', 22)}</span>`, title: 'Archived', trail: '<span class="val">2</span>' })], 72)}`);
G.push(['Home & projects', 'spec 01 · each project is a workspace', [
screen('P1', 'Home', `
  ${nav({ left: ws(0), right: ['@search', '@ellipsis'] })}
  ${content(homeBody(), 'home-tab')}
  ${tabbar('Home')}`),
screen('W1', 'Switch project', `
  ${nav({ left: ws(0), right: ['@search', '@ellipsis'] })}
  ${content(homeBody(), 'home-tab')}
  ${switcher(0)}`),
screen('P8', 'Home · Locations', `
  ${nav({ left: ws(0), right: ['@plus', '@ellipsis'] })}
  ${content(homeBody('Locations'), 'home-tab')}
  ${tabbar('Home')}`),
screen('P9', 'Home · Plans', `
  ${nav({ left: ws(0), right: ['@plus', '@ellipsis'] })}
  ${content(homeBody('Plans'), 'home-tab')}
  ${tabbar('Home')}`),
]]);
G.push(['Home · scroll and filters', 'the tab row pins when scrolled; each sub-tab has its own filter', [
screen('P1s', 'Home · Sessions · scrolled', `
  ${pinnedHome('Sessions', 0, SCROLLED.Sessions())}
  ${tabbar('Home')}`),
screen('P1f', 'Home · Sessions · filtered', `
  ${pinnedHome('Sessions', 2, FILTERED.Sessions())}
  ${tabbar('Home')}`),
screen('P8s', 'Home · Locations · scrolled, filtered', `
  ${pinnedHome('Locations', 1, SCROLLED.Locations(), ['@plus', '@ellipsis'])}
  ${tabbar('Home')}`),
screen('P9s', 'Home · Plans · scrolled', `
  ${pinnedHome('Plans', 0, SCROLLED.Plans(), ['@plus', '@ellipsis'])}
  ${tabbar('Home')}`),
screen('P9f', 'Home · Plans · filtered', `
  ${pinnedHome('Plans', 2, FILTERED.Plans(), ['@plus', '@ellipsis'])}
  ${tabbar('Home')}`),
screen('P9e', 'Home · Plans · no match', `
  ${pinnedHome('Plans', 2, FILTERED.PlansEmpty(), ['@plus', '@ellipsis'])}
  ${tabbar('Home')}`),
screen('HF1', 'Filter sessions', `
  ${pinnedHome('Sessions', 0, SCROLLED.Sessions())}
  ${filterSheet('Sessions')}`),
screen('HF2', 'Filter locations', `
  ${pinnedHome('Locations', 1, SCROLLED.Locations(), ['@plus', '@ellipsis'])}
  ${filterSheet('Locations')}`),
screen('HF3', 'Filter plans', `
  ${pinnedHome('Plans', 0, SCROLLED.Plans(), ['@plus', '@ellipsis'])}
  ${filterSheet('Plans')}`),
]]);
const P5_INNER = `
  ${nav({ back: 'Riverside', title: 'Level 7', right: ['@list-tree'] })}
  ${content(`
    <div class="stack" style="gap:8px"><div class="hstack" style="justify-content:space-between"><span class="fn">37 of 82 rooms checked</span><span class="fn">since 8:12</span></div>${progress(37 / 82)}</div>
    <div class="chips scroll"><span class="chip on">All</span><span class="chip">Not checked</span><span class="chip">Has issues</span><span class="chip">Re-check due</span></div>
    ${sec('Unit 7A', list([
      row({ lead: `<span style="color:var(--ok)">${I('circle-check', 22, 1.8)}</span>`, title: 'Living room', trail: `<span class="hstack" style="gap:12px">${sev('crit', '2 critical')}<span class="val">4</span></span>` }),
      row({ lead: `<span style="color:var(--ok)">${I('circle-check', 22, 1.8)}</span>`, title: 'Bedroom 1', trail: `<span class="val">3</span>` }),
      row({ lead: `<span style="color:var(--ink3)">${I('circle', 22, 1.5)}</span>`, title: 'Bathroom', sub: '1 issue from 12 Aug to re-check', trail: sev('major') }),
      row({ lead: `<span style="color:var(--ink3)">${I('circle', 22, 1.5)}</span>`, title: 'Kitchen' }),
    ], 50), '3 of 4')}
    ${sec('Unit 7B', list([row({ lead: `<span style="color:var(--ink3)">${I('circle', 22, 1.5)}</span>`, title: 'Living room' })], 50), '0 of 5')}`)}
  ${toolbar(`${I('flag', 20)}End`, `${I('map', 20)}Plan`)}`;
G.push(['Projects and walkthrough', 'spec 01', [
screen('P2', 'New project · keyboard up', `
  ${nav({ back: 'Projects', title: 'New project' })}
  ${content(`
    ${field('Name', 'Riverside Tower B', { focus: true })}
    ${field('Site address', 'Street, district', { ph: true })}
    ${field('Client', 'Optional', { ph: true })}
    <div class="fn">You can add rooms, plans and checklists after it’s created.</div>`, 'tight')}
  ${dock(btn('Create project', 'primary'))}
  ${keyboard()}`),
screen('W2', 'Archived projects', `
  ${nav({ back: 'Projects', title: 'Archived' })}
  ${content(`
    ${list([
      row({ lead: wsTile(3, 44, 12), title: 'District 1 Office Fit-out', sub: 'Archived 3 Jun · 31 issues, all closed', trail: btn('Restore', 'secondary', null, { sm: true }), chev: false }),
      row({ lead: wsTile(2, 44, 12), title: 'Thu Thiem Showroom', sub: 'Archived 12 Feb · 2 issues left open', trail: btn('Restore', 'secondary', null, { sm: true }), chev: false })
    ], 72)}
    <div class="fn">Archived projects keep every photo, issue and report. Restore one to see it in the project switch again.</div>`, 'tight')}`),
screen('P4', 'Start session', `
  ${nav({ left: ws(0) })}
  ${sheet('New walkthrough', `
    ${field('Inspector', 'Hanh Nguyen')}
    <div class="field"><span>Weather</span><div class="chips"><span class="chip on">${I('sun', 16)}Sunny</span><span class="chip">${I('cloud', 16)}Overcast</span><span class="chip">${I('cloud-rain', 16)}Rain</span></div></div>
    ${field('Note for the report', 'e.g. finishing check, levels 7–9', { ph: true, area: true })}
    <div class="hstack" style="gap:12px;align-items:flex-start"><span style="color:var(--ink2);flex:none">${I('rotate-ccw', 20)}</span><span class="meta" style="color:var(--ink)">14 issues from 12 Aug will be waiting in their rooms for you to re-check.</span></div>
  `, btn('Start', 'primary'))}`),
screen('P5', 'Walkthrough · rooms', `${P5_INNER}`),
screen('P5J', 'Walkthrough · jump to a unit', `${P5_INNER}
  ${sheet('Jump to', JUMP_UNITS.map(([lvl, count, units]) => sec(lvl, list(units.map(([u, d, t]) => row({ lead: ring(d / t), title: u, sub: `${d} of ${t} rooms checked` })), 56), count)).join(''))}`),
screen('P6', 'Generate locations', `
  ${nav({ back: 'Locations', title: 'Add rooms in bulk' })}
  ${content(`
    <div class="hstack" style="gap:12px">${field('Levels', '7 to 9', { style: 'flex:1' })}${field('Units per level', 'A to H', { style: 'flex:1' })}</div>
    ${field('Rooms in every unit', 'Living room, Bedroom 1, Bedroom 2, Bathroom, Kitchen', { area: true })}
    ${sec('Preview', `<div class="code" style="line-height:24px;color:var(--ink)">Level 7 › 7A › Living room<br>Level 7 › 7A › Bedroom 1<br>Level 7 › 7A › Bedroom 2<br><span class="muted">and 117 more</span></div>`, '120 rooms')}
    <div class="fn">Already have this layout in another project? <span class="link">Copy its rooms</span></div>`, 'tight')}
  ${dock(btn('Add 120 rooms', 'primary'))}`),
screen('P7', 'Room', `
  ${nav({ back: 'Level 7', right: ['@ellipsis'] })}${lt('Living room', 'Unit 7A · Level 7')}
  ${content(`
    <div class="hstack" style="gap:12px;align-items:flex-start"><span style="color:var(--ink2);flex:none">${I('rotate-ccw', 20)}</span><div class="grow"><div class="t-body" style="font-weight:600">2 issues to re-check from 12 Aug</div><div class="meta">Crack by the skirting, loose socket cover</div></div><span class="link">Compare</span></div>
    ${sec('Photos', `<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:4px;margin:0 -16px">${[0, 3, 2, 0, 1, 3].map((v, i) => `<div style="aspect-ratio:1;position:relative">${scene(v, { crack: i === 0 })}${i === 0 ? `<span class="sev crit solid" style="position:absolute;left:6px;bottom:6px">#3</span>` : ''}${i === 5 ? `<span style="position:absolute;right:6px;bottom:6px;font-size:13px;color:#fff;text-shadow:0 1px 2px rgba(0,0,0,.6)">10:42</span>` : ''}</div>`).join('')}</div>`, '6 today')}
    ${list([row({ title: 'Finishing checklist', sub: '14 of 22 answered', trail: `<span class="val">64%</span>` })])}`, 'tight')}
  ${toolbar(`${I('triangle-alert', 20)}Issue`, `${I('list-checks', 20)}Checklist`)}`),
]]);

const ISSUES_ALL_BODY = `
    ${issueChips(ISSUE_STATES.all)}
    ${sec('Level 7', list([
      row({ lead: thumb(3, 48), title: 'Exposed wiring at socket', sub: '7A Kitchen', trail: withAssignee('Phuc Electric', `<div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px">${sev('crit')}<span class="fn" style="color:var(--crit)">2 days late</span></div>`), chev: false }),
      row({ lead: thumb(0, 48, 8, { crack: true }), title: 'Hairline crack by the skirting', sub: '7A Living room', trail: withAssignee('Tuan’s crew', `<div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px">${sev('major')}<span class="fn">Fri</span></div>`), chev: false }),
      row({ lead: thumb(2, 48), title: 'Door paint scratched', sub: '7B Bedroom 1', trail: withAssignee('painters', sev('minor')), chev: false }),
    ], 76), '3 open')}
    ${sec('Level 8', list([
      row({ lead: thumb(1, 48), title: 'Stain on bathroom ceiling', sub: '8C Bathroom', trail: withAssignee('AquaSeal', `<div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px">${sev('major')}<span class="fn">Wed 8 Oct</span></div>`), chev: false }),
    ], 76), '11 open')}`;
const ISSUES_FILTERED_BODY = () => `${issueChips(ISSUE_STATES.filtered)}${resultCount('3 of 14 open issues')}${list(ISSUES_FILTERED.map(([v, t, sub, k, late]) => row({ lead: thumb(v, 48), title: t, sub: sub.split(' · ')[0], trail: withAssignee(sub.split(' · ')[1], `<div style="display:flex;flex-direction:column;align-items:flex-end;gap:4px">${sev(k)}<span class="fn" style="color:var(--crit)">${late}</span></div>`), chev: false })), 76)}`;
/* ======================= Capture ======================= */
const camTop = (label) => `<div class="cam-top"><div class="cam-btn glass">${I('chevron-down', 22, 2)}</div><div class="cam-pill glass">${label}${I('chevron-down', 14, 2)}</div><div class="cam-btn glass">${I('zap-off', 18, 2)}</div></div>`;
const camBottom = (right) => `<div class="cam-bottom"><div class="modes"><span>VIDEO</span><span class="on">PHOTO</span><span>CHECK</span></div><div class="shutter-row"><div class="side-btn"><span class="thumb" style="width:46px;height:46px;border:2px solid #fff;border-radius:9px">${scene(0)}</span><span>4 here</span></div><div class="shutter"><i></i></div>${right || `<div class="side-btn"><span class="c glass">${I('triangle-alert', 22, 2)}</span><span>Issue</span></div>`}</div></div>`;
G.push(['Capture & issues', 'specs 02, 03, 06', [
screen('C1', 'Camera', `
  ${camTop('7A · Living room')}
  <div class="viewfinder">${scene(0, { crack: true })}<div class="focus-box"></div>
    <div class="glass" style="position:absolute;left:16px;top:12px;border-radius:10px;padding:8px 12px;display:flex;align-items:baseline;gap:8px"><span style="font-size:28px;font-weight:600">3.42</span><span style="font-size:13px">m</span><span style="font-size:13px;opacity:.7;margin-left:4px">DISTO</span></div>
  </div>
  ${camBottom()}`, { dark: true, lightHome: true }),
screen('C2', 'Log issue', `
  ${camTop('7A · Living room')}<div class="viewfinder">${scene(0, { crack: true })}</div>${camBottom()}
  ${sheet('New issue', `
    <div class="hstack" style="gap:12px">${thumb(0, 52, 8, { crack: true })}<div class="grow"><div class="t-body" style="font-weight:600">1 photo</div><div class="code">10:42:18 · 7f3a…c91e</div></div><span class="link">Add</span></div>
    ${seg(['Critical', 'Major', 'Minor'], 'Major', 'sev3')}
    ${field('', 'Hairline crack by the skirting, about 40 cm', { focus: true, icon: 'mic' })}
    <div class="chips" style="flex-wrap:wrap"><span class="chip">Wall crack</span><span class="chip">Ceiling stain</span><span class="chip">Loose tile</span></div>
    <div class="hstack" style="gap:12px">${field('Assigned to', 'Tuan’s masonry crew', { style: 'flex:1' })}${field('Due', 'Fri 3 Oct', { style: 'width:112px' })}</div>
  `, `<div class="hstack">${btn('', 'secondary', 'map-pin', { style: 'flex:0 0 50px' })}${btn('Save, next photo', 'primary')}</div>`)}`, { dark: true }),
screen('C3', 'Re-check · ghost overlay', `
  ${camTop('Re-check #3')}
  <div class="viewfinder">${scene(0)}<div style="position:absolute;inset:0;opacity:.3">${scene(0, { crack: true })}</div>
    <div class="overlay-card glass" style="top:12px"><div class="hstack" style="justify-content:space-between"><span style="font-size:13px;font-weight:600">Line up with 12 Aug</span><span style="font-size:13px;opacity:.7">30%</span></div><div style="margin-top:8px;height:3px;border-radius:2px;background:rgba(255,255,255,.25)"><div style="width:30%;height:100%;background:#fff;border-radius:2px"></div></div></div>
  </div>
  ${camBottom(`<div class="side-btn"><span class="c glass">${I('layers', 21, 2)}</span><span>Ghost</span></div>`)}`, { dark: true, lightHome: true }),
screen('C4', 'Re-check outcome', `
  ${nav({ back: 'Camera', title: 'Issue #3' })}
  ${content(`
    <div class="hstack" style="gap:4px;margin:0 -16px">${['12 Aug', 'Today'].map((t, i) => `<div class="grow" style="aspect-ratio:3/4;position:relative">${scene(0, { crack: i === 0 })}<span class="sev solid" style="position:absolute;left:8px;bottom:8px;padding-left:8px">${t}</span></div>`).join('')}</div>
    <div><div class="t-bodyStrong">Hairline crack by the skirting</div><div class="meta">Tuan’s masonry crew · opened 12 Aug</div></div>
    ${sec('Has it been fixed?', list([
      row({ lead: `<span class="radio on">${I('check', 14, 3)}</span>`, title: 'Yes, close it', sub: 'Both photos go in the report', chev: false }),
      row({ lead: `<span class="radio"></span>`, title: 'Not yet', sub: 'Keep it open, add today’s photo', chev: false }),
      row({ lead: `<span class="radio"></span>`, title: 'It got worse', sub: 'Raise to Critical', chev: false }),
    ], 50))}`, 'tight')}
  ${dock(btn('Save', 'primary'))}`),
screen('C5', 'Issues', `
  ${nav({ title: 'Issues', sub: 'Riverside Tower B', leading: true, right: ['@search'] })}
  ${content(ISSUES_ALL_BODY, 'tight')}
  ${tabbar('Issues')}`),
screen('C5f', 'Issues · filtered', `
  ${nav({ title: 'Issues', sub: 'Riverside Tower B', leading: true, right: ['@search'] })}
  ${content(ISSUES_FILTERED_BODY(), 'tight')}
  ${tabbar('Issues')}`),
screen('C5e', 'Issues · no match', `
  ${nav({ title: 'Issues', sub: 'Riverside Tower B', leading: true, right: ['@search'] })}
  ${content(`${issueChips(ISSUE_STATES.nomatch)}${empty(hero('neutral', 'search-x', 'No issues match', 'No Minor issue is overdue on Riverside Tower B.', { extra: btn('Change filters', 'secondary', null, { sm: true }) }))}`, 'tight')}
  ${tabbar('Issues')}`),
screen('F1', 'Filter issues', `
  ${nav({ title: 'Issues', sub: 'Riverside Tower B', leading: true, right: ['@search'] })}
  ${content(ISSUES_FILTERED_BODY(), 'tight')}
  ${filterSheet('Issues')}`),
screen('F1s', 'Filter issues · one group (Severity)', `
  ${nav({ title: 'Issues', sub: 'Riverside Tower B', leading: true, right: ['@search'] })}
  ${content(ISSUES_ALL_BODY, 'tight')}
  ${sheet('Severity', list([['crit', 'Critical', true], ['major', 'Major', true], ['minor', 'Minor', false]].map(([k, t, on]) => row({ lead: `<span class="sev ${k}"></span>`, title: t, trail: on ? `<span style="color:var(--ink)">${I('check', 22, 2.6)}</span>` : '', chev: false }))), filterActions())}`),
screen('C6', 'Issue detail', `
  ${nav({ back: 'Issues', right: ['@share', '@ellipsis'] })}
  <div style="height:250px;flex:none;position:relative">${scene(0, { crack: true })}<div style="position:absolute;left:0;right:0;bottom:10px;display:flex;justify-content:center;gap:8px"><i style="width:6px;height:6px;border-radius:3px;background:#fff"></i><i style="width:6px;height:6px;border-radius:3px;background:rgba(255,255,255,.5)"></i><i style="width:6px;height:6px;border-radius:3px;background:rgba(255,255,255,.5)"></i></div></div>
  ${content(`
    <div class="stack" style="gap:8px;padding-top:16px">${sev('major', 'Major · #3')}<div class="t-heading">Hairline crack by the skirting, about 40 cm</div></div>
    ${list([
      row({ title: '<span class="meta">Room</span>', trail: `<span class="t-body">7A Living room</span>`, chev: false }),
      row({ title: '<span class="meta">Assigned to</span>', trail: assigneeLine('Tuan’s masonry crew'), chev: false }),
      row({ title: '<span class="meta">Due</span>', trail: `<span class="t-body">Fri 3 Oct</span>`, chev: false }),
    ])}
    <div class="fn" style="margin-top:-12px">Opened by Hanh on 12 Aug · still open on 28 Aug</div>`, 'tight')}
  ${dock(`<div class="hstack">${btn('Mark up', 'secondary')}${btn('Re-check now', 'primary')}</div>`)}`),
]]);

/* ======================= Markup & plans ======================= */
G.push(['Markup & floor plans', 'specs 11, 12', [
screen('M1', 'Markup', `
  <div class="nav" style="color:#fff"><div class="l"><div class="gbtn glass">${I('x', 22, 2.2)}</div></div><div class="ti">Mark up</div><div class="rt"><div class="gbtn hi">${I('check', 22, 2.6)}</div></div></div>
  <div class="viewfinder" style="margin-top:8px">${scene(0, { crack: true })}
    <svg viewBox="0 0 393 560" style="position:absolute;inset:0;width:100%;height:100%" fill="none" stroke-linecap="round" stroke-linejoin="round">
      <path d="M172 232 C166 280 170 330 186 366 C230 372 276 370 294 360 C300 310 296 262 286 226 C250 220 204 222 172 232Z" stroke="#FF3B30" stroke-width="4"/>
      <path d="M58 478 C92 440 128 404 158 382" stroke="#FF3B30" stroke-width="4"/><path d="M158 382 l-20 2 m20 -2 l-5 19" stroke="#FF3B30" stroke-width="4"/>
    </svg>
    <span style="position:absolute;left:180px;top:196px;background:#FF3B30;color:#fff;font-size:17px;font-weight:600;padding:4px 8px;border-radius:4px">40 cm</span>
  </div>
  <div style="padding:16px 16px 48px;display:flex;flex-direction:column;gap:16px">
    <div class="hstack" style="justify-content:space-between">${[['pencil', 1], ['move-up-right', 0], ['square', 0], ['type', 0], ['ruler', 0], ['undo-2', 0]].map(([i, on]) => `<span style="width:46px;height:46px;border-radius:23px;display:grid;place-items:center;${on ? 'background:#fff;color:#111' : 'color:#fff'}">${I(i, 22, 2)}</span>`).join('')}</div>
    <div class="hstack" style="justify-content:center;gap:20px">${['#FF3B30', '#FFD400', '#FFFFFF', '#16181B'].map((c, i) => `<span style="width:24px;height:24px;border-radius:12px;background:${c};${i === 0 ? 'box-shadow:0 0 0 3px #0E0F10,0 0 0 5px #fff' : 'border:1px solid rgba(255,255,255,.3)'}"></span>`).join('')}</div>
  </div>`, { dark: true, lightHome: true }),
screen('M2', 'Share stamped photo', `
  ${nav({ back: 'Issue', title: 'Share photo' })}
  ${content(`
    <div style="height:300px;margin:0 -16px;position:relative">${scene(0, { crack: true })}
      <div style="position:absolute;left:0;right:0;bottom:0;background:rgba(14,15,16,.72);color:#fff;padding:8px 12px;font-family:var(--mono);font-size:11px;line-height:16px">30 Sep 2026 10:42:18 +07 · Riverside Tower B<br>Level 7 › 7A › Living room · 10.7297, 106.7215<br>Verify at sitelog.app/v/7F3K-92QD</div></div>
    <div class="fn">Time checked against the network (within 2 s) and GPS (±6 m), so the stamp can be trusted.</div>
    ${sec('Stamp shows', list([
      row({ title: 'Date and time', trail: `<span class="toggle on"></span>`, chev: false }),
      row({ title: 'Project and room', trail: `<span class="toggle on"></span>`, chev: false }),
      row({ title: 'My markup', trail: `<span class="toggle"></span>`, chev: false }),
    ]))}`, 'tight')}
  ${dock(btn('Share', 'primary', 'share'))}`),
screen('M4', 'Plan viewer', `
  ${nav({ back: 'Plans', title: 'Level 7 architectural', right: ['@layers'] })}
  <div class="plan">${planDrawing()}${pins()}</div>
  ${dock(`<div class="hstack" style="justify-content:space-between">${sev('crit', '1 critical')}${sev('major', '2 major')}${sev('minor', '1 minor')}${sev('ok', '2 closed')}</div><div class="foot">Press and hold to drop a pin</div>`)}`),
screen('M4L', 'Plan · show on plan', `
  ${nav({ back: 'Plans', title: 'Level 7 architectural', right: ['@layers'] })}
  <div class="plan">${planDrawing()}${pins()}</div>
  ${sheet('Show on plan', list(PIN_LAYERS.map(([k, l, c, on]) => row({ lead: `<span class="sev ${k}"></span>`, title: l, sub: c, trail: `<span class="toggle ${on ? 'on' : ''}"></span>`, chev: false }))) + list([row({ title: 'Group nearby pins', sub: 'Below 50% zoom', trail: `<span class="toggle on"></span>`, chev: false })]), filterActions())}`),
screen('M5', 'Pin tapped', `
  ${nav({ back: 'Plans', title: 'Level 7 architectural', right: ['@layers'] })}
  <div class="plan">${planDrawing()}${pins()}</div>
  <div class="sheet" style="box-shadow:0 -8px 24px rgba(0,0,0,.08)"><div class="grab"></div><div class="sbody" style="padding-top:16px;gap:16px"><div class="hstack" style="gap:12px;align-items:flex-start">${thumb(3, 64, 8)}<div class="grow stack" style="gap:4px">${sev('crit', 'Critical · pin 1')}<div class="t-bodyStrong">Exposed wiring at socket</div><div class="hstack" style="gap:8px">${assigneeAvatar('Phuc Electric', 20)}<span class="meta">7A Kitchen · <span style="color:var(--crit)">2 days late</span></span></div></div></div><div class="hstack">${btn('Move pin', 'secondary', null, { style: 'flex:1' })}${btn('Open', 'primary', null, { style: 'flex:1' })}</div></div><div style="height:34px"></div></div>`),
]]);

/* ======================= Checklists ======================= */
const item = (n, t, sel, o = {}) => `<div class="row" style="flex-direction:column;align-items:stretch;gap:12px;padding:16px 16px"><div class="hstack" style="align-items:flex-start;gap:12px"><span class="fn" style="width:20px;padding-top:4px">${n}</span><span class="t-body grow">${t}</span>${o.missing ? `<span class="fn" style="color:var(--major)">Needed</span>` : ''}</div><div class="ans" style="padding-left:32px"><div class="pass ${sel === 'p' ? 'on' : ''}">Pass</div><div class="fail ${sel === 'f' ? 'on' : ''}">Fail</div><div class="na ${sel === 'n' ? 'on' : ''}">N/A</div></div>${o.note ? `<div class="hstack" style="gap:12px;padding-left:32px">${thumb(0, 36, 6, { crack: true })}<span class="meta grow" style="color:var(--ink)">${o.note}</span><span class="fn">#3</span></div>` : ''}</div>`;
G.push(['Checklists', 'spec 13', [
screen('K1', 'Pick a checklist', `
  ${nav({ back: 'Living room', title: 'Checklist' })}
  ${content(`
    <div class="search">${I('search', 18)}Search</div>
    ${list([row({ lead: `<span class="live"></span>`, title: 'Finishing handover', sub: 'You stopped at item 15 of 22 this morning' })], 38)}
    ${sec('Used recently', list([row({ title: 'Finishing handover', sub: '22 items' }), row({ title: 'Bathroom waterproofing', sub: '12 items' })]))}
    ${sec('All checklists', list([row({ title: 'Sockets and switches', sub: '15 items' }), row({ title: 'Plumbing', sub: '18 items' }), row({ title: 'Doors and hardware', sub: '10 items' }), row({ title: 'Fire safety', sub: '20 items' })]), '6')}`, 'tight')}`),
screen('K2', 'Checklist run', `
  ${nav({ back: 'Back', title: 'Finishing handover', right: ['@ellipsis'] })}
  ${content(`
    <div class="stack" style="gap:8px"><div class="hstack" style="justify-content:space-between"><span class="fn">14 of 22 answered</span><span class="fn" style="color:var(--crit)">1 failed</span></div>${progress(14 / 22)}</div>
    ${list([
      item(12, 'Wall surface flat, no cracks', 'f', { note: 'Crack by the skirting — logged as issue' }),
      item(13, 'Paint even, no patches', 'p'),
      item(14, 'Floor grout even and sealed', 'n'),
      item(15, 'Door closes smoothly and locks', null, { missing: true }),
    ])}`, 'tight')}
  ${dock(`${btn('Finish', 'primary', null, { disabled: true })}<div class="foot">8 items still need an answer</div>`)}`),
screen('K3', 'Fail → issue (prefilled)', `
  ${nav({ back: 'Back', title: 'Finishing handover' })}
  ${sheet('New issue', `
    <div class="fn">From checklist item 12. A photo is required.</div>
    ${field('What’s wrong', 'Wall surface flat, no cracks')}
    ${seg(['Critical', 'Major', 'Minor'], 'Major', 'sev3')}
    <div class="hstack" style="gap:8px">${thumb(0, 72, 8, { crack: true })}<span style="width:72px;height:72px;border-radius:8px;border:1.5px dashed var(--line-strong);display:grid;place-items:center;color:var(--ink3)">${I('plus', 24)}</span></div>
    ${field('Assigned to', 'Tuan’s masonry crew')}
  `, btn('Save issue', 'primary'))}`),
screen('K4', 'Checklist done', `
  ${nav({ back: 'Living room' })}
  ${content(`
    ${hero('ok', 'check', 'Living room is done.', '19 passed, 2 failed and 1 didn’t apply. It took you 6 minutes.', { big: true })}
    ${sec('Sent to the issue list', list([row({ title: 'Crack by the skirting', trail: withAssignee('Tuan’s masonry crew', sev('major')) }), row({ title: 'Socket cover not level', trail: withAssignee('Phuc Electric', sev('minor')) })], 38))}`)}
  ${dock(`${btn('Next: Bedroom 1', 'primary')}${btn('Back to Level 7', 'ghost')}`)}`),
]]);

/* ======================= Reports ======================= */
G.push(['Reports', 'spec 05', [
screen('R1', 'Walkthrough finished', `
  ${nav({ back: 'Level 7' })}
  ${content(`
    ${hero('ok', 'check', 'All 82 rooms checked', 'Tue 30 Sep · 8:12 to 14:00, just under six hours', { big: true })}
    <div class="t-body">You took <b>112 photos</b>, logged <b>7 new issues</b> and closed <b>9</b> from last time.</div>
    ${list([
      row({ lead: `<span style="color:var(--ok)">${I('shield-check', 22)}</span>`, title: 'Every photo is fingerprinted', sub: 'Nothing was edited after capture', chev: false }),
      row({ lead: `<span style="color:var(--ink2)">${I('refresh-cw', 22)}</span>`, title: 'Uploading 87 of 112', sub: 'Keeps going if you close the app', chev: false }),
    ], 50)}`)}
  ${dock(`${btn('Make the report', 'primary')}${btn('Later', 'ghost')}`)}`),
screen('R2', 'Report options', `
  ${nav({ back: 'Back', title: 'Report', right: ['!Next'] })}
  ${content(`
    <div class="field"><span>Group issues by</span>${seg(['Room', 'Contractor'], 'Room')}</div>
    ${sec('Include', list([['Cover and summary', ''], ['Pins on each plan', '2 sheets'], ['Checklist results', '3 rooms'], ['Issues with photos', '7'], ['Before and after', '4 pairs'], ['Issues open over 14 days', ''], ['Signatures', '2 people']].map(([t, s], i) => row({ title: t, sub: s || null, trail: `<span class="toggle ${i === 5 ? '' : 'on'}"></span>`, chev: false }))))}`, 'tight')}
  ${dock(`<div class="hstack">${btn('Excel', 'secondary', null, { style: 'flex:0 0 110px' })}${btn('Create PDF', 'primary')}</div>`)}`),
screen('R3', 'Branding', `
  ${nav({ back: 'Report', title: 'Your letterhead' })}
  ${content(`
    <div class="hstack" style="gap:16px"><span style="width:64px;height:64px;border-radius:12px;background:var(--ink);color:var(--on-ink);display:grid;place-items:center;font-weight:600;font-size:20px;letter-spacing:-.02em">EL</span><div class="grow"><div class="t-body" style="font-weight:600">Eastline logo.png</div><div class="meta">Shown on the cover and every page</div></div><span class="link">Change</span></div>
    ${field('Company', 'Eastline Site Supervision Co.')}
    ${field('Prepared for', 'Riverside Development JSC')}
    ${field('Footer', 'Internal report — not a formal acceptance record', { area: true })}`)}
  ${dock(btn('Save', 'primary'))}`),
screen('R4', 'Signatures', `
  ${nav({ back: 'Report', title: 'Sign' })}
  ${content(`
    ${seg(['Hanh (supervisor) ✓', 'Contractor'], 'Contractor')}
    ${field('Name and role', 'Tran Minh, site manager')}
    <div style="height:240px;border-radius:12px;background:var(--sunken);position:relative">
      <svg viewBox="0 0 360 240" style="position:absolute;inset:0;width:100%;height:100%" fill="none" stroke="#16181B" stroke-width="2.4" stroke-linecap="round"><path d="M44 158 C66 72 92 66 100 128 C108 180 132 176 150 104 C158 74 176 82 184 132 C192 168 214 148 236 116 C246 104 262 110 262 126 C262 140 250 144 244 136 L310 128"/><line x1="28" y1="192" x2="332" y2="192" stroke="#CFCAC1" stroke-width="1"/></svg>
      <span class="fn" style="position:absolute;left:28px;bottom:16px">Sign above the line</span><span class="link" style="position:absolute;right:16px;bottom:14px">Clear</span>
    </div>
    <div class="fn">This is a handwritten signature for internal sign-off, not a certified digital signature.</div>`, 'tight')}
  ${dock(btn('Done', 'primary'))}`),
screen('R5', 'PDF preview', `
  ${nav({ back: 'Report', title: 'R-0930-07.pdf', right: ['@share'] })}
  <div style="flex:1;background:var(--sunken);padding:20px 24px;display:flex;flex-direction:column;align-items:center;gap:12px">
    <div style="width:100%;flex:1;background:#fff;box-shadow:0 2px 10px rgba(60,48,20,.18);padding:24px;display:flex;flex-direction:column;gap:12px;color:#16181B">
      <div class="hstack" style="justify-content:space-between"><span style="font-weight:600;font-size:13px">EASTLINE</span><span style="font-size:10px;color:#63676E">R-0930-07</span></div>
      <div style="margin-top:16px"><div style="font-size:19px;font-weight:600;letter-spacing:-.01em;line-height:24px">Site inspection report</div><div style="font-size:11px;color:#63676E;margin-top:4px">Riverside Tower B · 30 September 2026 · Hanh Nguyen</div></div>
      <div style="font-size:11px;line-height:16px">7 new issues: 1 critical, 4 major, 2 minor. 9 issues from 12 Aug closed.</div>
      <div style="height:1px;background:#E8E5E0"></div>
      <div class="hstack" style="gap:12px;align-items:flex-start"><span style="width:110px;height:82px;overflow:hidden;flex:none">${scene(0, { crack: true })}</span><div style="font-size:11px;line-height:15px"><b>3. Hairline crack by the skirting</b><br><span style="color:#63676E">7A Living room · Tuan’s masonry crew · due 3 Oct</span></div></div>
      <div style="margin-top:auto;font-size:9px;color:#A0A3A9;display:flex;justify-content:space-between"><span>Page 1 of 18</span><span style="font-family:var(--mono)">verify 7F3K-92QD</span></div>
    </div>
    <div class="fn">1 of 18</div>
  </div>
  ${dock(`<div class="hstack">${btn('Save to Files', 'secondary')}${btn('Send', 'primary')}</div>`)}`),
]]);

/* ======================= Sync ======================= */
G.push(['Sync & diagnostics', 'specs 04, 09, 10', [
screen('U1', 'Sync', `
  ${nav({})}${lt('Sync', 'All projects on this iPhone')}
  ${content(`
    <div class="panel" style="gap:12px">
      <div class="hstack" style="gap:8px"><span style="color:var(--ink)">${I('cloud-upload', 20)}</span><span class="t-bodyStrong grow">Uploading 187 of 243 files</span>${btn('Pause', 'secondary', null, { sm: true })}</div>
      ${progress(187 / 243)}
      <div class="fn">About 6 minutes left on this Wi-Fi. Keeps going if you close the app.</div>
    </div>
    ${sec('By project', list([
      row({ lead: wsTile(0, 40, 10), title: 'Riverside Tower B<span class="tag">Current</span>', sub: '187 of 243 files · uploading', trail: ring(187 / 243) }),
      row({ lead: wsTile(1, 40, 10), title: 'Harbor View Villas', sub: '12 videos wait for Wi-Fi', trail: sev('wait', 'Waiting') }),
      row({ lead: `<span style="width:40px;height:40px;border-radius:10px;background:var(--sunken);color:var(--ok);display:grid;place-items:center;flex:none">${I('check', 20, 2.6)}</span>`, title: '3 projects up to date', sub: 'Northgate Warehouse, Lakeside Clinic, Saigon Pearl Lobby' }),
    ], 68))}
    ${sec('Needs attention', list([row({ title: '2 photos didn’t upload', sub: 'Riverside · the server rejected the checksum', trail: btn('Retry', 'secondary', null, { sm: true }), chev: false })]))}
    <div class="foot">Last synced on this iPhone at 9:41</div>`, 'tight')}
  ${tabbar('Sync')}`),
screen('U2', 'Project files', `
  ${nav({ back: 'Sync', title: 'Riverside Tower B' })}
  ${content(`
    ${seg(['All', 'Waiting', 'Failed', 'Done'], 'All')}
    ${list([['IMG_0931.heic', '7A Living · 3.1 MB', 'Uploading', 'wait', 0], ['VID_0012.mov', '7A Kitchen · 412 MB', 'Needs Wi-Fi', 'wait', 3], ['VID_0013.mov', '8C Bath · 288 MB', 'Needs Wi-Fi', 'wait', 1], ['IMG_0922.heic', '7A Bedroom 1 · 2.8 MB', 'Failed', 'crit', 2], ['IMG_0921.heic', '7A Bedroom 1 · 2.9 MB', 'Done', 'ok', 0], ['IMG_0920.heic', '7A Bedroom 1 · 3.0 MB', 'Done', 'ok', 2]].map(([n, s, t, k, v]) => row({ lead: thumb(v, 44, 6), title: `<span class="code" style="color:var(--ink)">${n}</span>`, sub: s, trail: sev(k, t, k === 'crit' ? 'late' : ''), chev: false })), 72)}`)}`),
screen('U3', 'Diagnostics', `
  ${nav({ back: 'Settings', title: 'Diagnostics' })}
  ${content(`
    <div class="stack" style="gap:4px"><div class="hstack" style="gap:8px">${sev('ok', '')}<span class="t-bodyStrong">All 1,284 photos check out</span></div><div class="meta" style="padding-left:16px">Fingerprints match, nothing changed since capture. Checked 9:02.</div></div>
    ${sec('Storage', `<div class="stack" style="gap:12px"><div style="display:flex;height:8px;border-radius:4px;overflow:hidden;gap:4px"><i style="flex:41;background:var(--ink)"></i><i style="flex:16;background:var(--ok)"></i><i style="flex:43;background:var(--sunken)"></i></div><div class="fn">4.1 GB waiting to upload · 1.6 GB already backed up · 12 GB free</div></div>`)}
    ${sec('This iPhone', list([['Background uploads', 'On'], ['Low Power Mode', 'Off'], ['Live progress', 'Polling']].map(([t, v]) => row({ title: t, trail: `<span class="val">${v}</span>`, chev: false }))))}`, 'tight')}
  ${dock(`${btn('Free up 1.6 GB', 'secondary')}${btn('Send diagnostics to support', 'ghost')}`)}`),
]]);

