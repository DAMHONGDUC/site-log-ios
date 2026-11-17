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

