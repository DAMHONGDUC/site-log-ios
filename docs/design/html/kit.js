/* Pieces both platforms draw the same way: icons, site photos, the app mark, markers, plans. */
const I = (n, s = 20, sw = 1.75) => `<i data-lucide="${n}" style="width:${s}px;height:${s}px;stroke-width:${sw}"></i>`;

const SEV_LABEL = { crit: 'Critical', major: 'Major', minor: 'Minor', ok: 'Resolved', wait: 'Waiting' };
const sev = (k, t, extra = '') => `<span class="sev ${k} ${extra}">${t ?? SEV_LABEL[k]}</span>`;
const progress = (f) => `<div class="progress"><i style="width:${f * 100}%"></i></div>`;
const thumb = (v, s = 48, r = 8, o = {}) => `<span class="thumb" style="width:${s}px;height:${s}px;border-radius:${r}px">${scene(v, o)}</span>`;

/* App mark: docs/design/app-icon/app-icon.svg drawn inline. `layer` picks a part for the adaptive icon. */
const MARK_DEFS = `<defs><linearGradient id="mk-bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFDC2E"/><stop offset="1" stop-color="#FFC900"/></linearGradient><linearGradient id="mk-vial" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFF6C4"/><stop offset="1" stop-color="#F4E27A"/></linearGradient><filter id="mk-lift" x="-20%" y="-40%" width="140%" height="200%"><feDropShadow dx="0" dy="20" stdDeviation="24" flood-color="#7A5A00" flood-opacity="0.28"/></filter></defs>`;
const MARK_BG = `<rect width="1024" height="1024" fill="url(#mk-bg)"/>`;
const TICKS = [150, 186, 222, 258, 294, 726, 762, 798, 834, 870].map((x, i) => `<line x1="${x}" y1="${i % 3 === 0 ? 582 : 600}" x2="${x}" y2="628"/>`).join('');
const BRACKETS = `<path d="M136 322 V252 Q136 222 166 222 H236"/><path d="M788 222 H858 Q888 222 888 252 V322"/><path d="M888 702 V772 Q888 802 858 802 H788"/><path d="M236 802 H166 Q136 802 136 772 V702"/>`;
const LEVEL = (inner) => `<g transform="translate(512 512) scale(0.78) translate(-512 -512)">${inner}</g>`;
/* Full-colour artwork without the background: viewfinder corners, REC dot, spirit level */
const markArt = () => `<g fill="none" stroke="#16181B" stroke-width="30" stroke-linecap="round" stroke-linejoin="round">${BRACKETS}</g>
  <circle cx="226" cy="312" r="26" fill="#E5352B"/>
  ${LEVEL(`<g filter="url(#mk-lift)"><rect x="92" y="372" width="840" height="280" rx="64" fill="#16181B"/></g>
    <g stroke="#FFD400" stroke-width="12" stroke-linecap="round">${TICKS}</g>
    <circle cx="176" cy="444" r="19" fill="#FFD400"/><circle cx="848" cy="444" r="19" fill="#FFD400"/>
    <rect x="322" y="436" width="380" height="148" rx="74" fill="url(#mk-vial)"/><rect x="322" y="436" width="380" height="148" rx="74" fill="none" stroke="#0B0C0E" stroke-width="6"/>
    <ellipse cx="512" cy="504" rx="76" ry="46" fill="#FFFFFF"/><ellipse cx="490" cy="489" rx="27" ry="11" fill="#FFFFFF" opacity="0.9"/>
    <g stroke="#16181B" stroke-width="14" stroke-linecap="round"><line x1="418" y1="462" x2="418" y2="558"/><line x1="606" y1="462" x2="606" y2="558"/></g>`)}`;
/* One-colour artwork for Android themed icons: only the alpha counts, so details are cut out, not drawn dark */
const markMono = (fill) => `<mask id="mk-mono" maskUnits="userSpaceOnUse" x="0" y="0" width="1024" height="1024">
  <g fill="none" stroke="#fff" stroke-width="30" stroke-linecap="round" stroke-linejoin="round">${BRACKETS}</g><circle cx="226" cy="312" r="26" fill="#fff"/>
  ${LEVEL(`<rect x="92" y="372" width="840" height="280" rx="64" fill="#fff"/><g stroke="#000" stroke-width="12" stroke-linecap="round">${TICKS}</g>
    <circle cx="176" cy="444" r="19" fill="#000"/><circle cx="848" cy="444" r="19" fill="#000"/>
    <rect x="322" y="436" width="380" height="148" rx="74" fill="#000"/><ellipse cx="512" cy="504" rx="76" ry="46" fill="#fff"/>
    <g stroke="#fff" stroke-width="14" stroke-linecap="round"><line x1="418" y1="462" x2="418" y2="558"/><line x1="606" y1="462" x2="606" y2="558"/></g>`)}
</mask><rect width="1024" height="1024" fill="${fill}" mask="url(#mk-mono)"/>`;
const APP_MARK = `${MARK_DEFS}${MARK_BG}${markArt()}`;
/* iOS masks the square master with its own corner radius (~22.5%); Android masks the adaptive icon itself. */
const appMark = (size, radius = 0.225) => `<svg viewBox="0 0 1024 1024" width="${size}" height="${size}" style="border-radius:${Math.round(size * radius)}px;display:block;box-shadow:0 0 0 1px rgba(0,0,0,.06)">${APP_MARK}</svg>`;

/* Projects as workspaces (Slack-like): each project owns Home and Issues; a switch at the top left changes project. */
const PROJECTS = [
  // [name, place, scene, open, overdue, live]
  ['Riverside Tower B', 'District 7', 0, 14, 2, true],
  ['Harbor View Villas', 'Thu Duc', 1, 3, 0, false],
  ['Northgate Warehouse', 'Binh Duong', 2, 0, 0, false],
  ['Lakeside Clinic', 'District 2', 3, 6, 1, false],
  ['Saigon Pearl Lobby', 'Binh Thanh', 1, 1, 0, false],
];
const wsTile = (v, s = 36, r = 10) => thumb(v, s, r);

/* Home sub-tabs: each tab has its own filter; when the page scrolls, the tab row pins under the app bar. */
const HOME_FILTERS = {
  // tab: [[group, options, selected indexes]]
  Sessions: [['Sort by', ['Newest first', 'Oldest first'], [0]], ['Period', ['This month', 'Last 3 months', 'All time'], [1]], ['Inspector', ['Hanh Nguyen', 'Tran Minh'], []], ['Show only', ['Has a report', 'Has open issues'], [0]]],
  Locations: [['Sort by', ['Level order', 'Most issues first'], [0]], ['Level', ['Level 7', 'Level 8', 'Level 9'], []], ['Status', ['Not checked', 'Has issues', 'Re-check due', 'Done'], [1]]],
  Issues: [['Sort by', ['Severity', 'Due date', 'Recently updated'], [0]], ['Status', ['Open', 'In progress', 'Resolved', 'Verified'], [0]], ['Severity', ['Critical', 'Major', 'Minor'], [0, 1]], ['Due', ['Overdue', 'Due this week', 'No due date'], [0]], ['Assigned to', ['Tuan’s masonry crew', 'Phuc Electric', 'AquaSeal', 'Painters'], []], ['Show only', ['Has a photo', 'Pinned on a plan'], []]],
  Plans: [['Sort by', ['Level', 'Name', 'Most pins'], [0]], ['Level', ['Level 7', 'Level 8', 'Level 9'], [0]], ['Type', ['PDF', 'Photo of a sheet'], []], ['Pins', ['Has pins', 'No pins'], [0]]],
};
/* Issues tab: one chip per filter group (opens that group alone); a chip with a value shows it and is filled */
const ISSUE_CHIP_GROUPS = ['Status', 'Severity', 'Due', 'Assigned to', 'Show only'];
const ISSUE_STATES = {
  all: { Status: ['Open'] },
  filtered: { Status: ['Open'], Severity: ['Critical', 'Major'], Due: ['Overdue'] },
  nomatch: { Status: ['Open'], Severity: ['Minor'], Due: ['Overdue'] },
};
/* The main filter (all groups) is the first chip; its badge counts groups set beyond the default Status */
const issueChips = (st) => { const n = Object.keys(st).filter(k => k !== 'Status').length; return `<div class="chips scroll"><span class="chip fbtn" style="padding:0 12px;position:relative">${I('list-filter', 18, 2.2)}${n ? `<span class="fbadge">${n}</span>` : ''}</span>${ISSUE_CHIP_GROUPS.map(g => { const v = st[g] || []; return `<span class="chip ${v.length ? 'on' : ''}">${v.length ? v.join(', ') : g}${I('chevron-down', 16, 2.4)}</span>`; }).join('')}</div>`; };
/* Issues filtered by Critical + Major and Overdue */
const ISSUES_FILTERED = [[3, 'Exposed wiring at socket', '7A Kitchen · Phuc Electric', 'crit', '2 days late'], [2, 'Loose tile at the entrance', '7C Hall · Tuan’s crew', 'major', '1 day late'], [1, 'Water stain under the window', '8A Bedroom 2 · AquaSeal', 'major', '5 days late']];
/* Plan viewer: what the pins layer shows */
const PIN_LAYERS = [['crit', 'Critical', '1 pin', true], ['major', 'Major', '2 pins', true], ['minor', 'Minor', '1 pin', true], ['ok', 'Closed issues', '2 pins', false]];
/* Walkthrough: jump to a unit */
const JUMP_UNITS = [['Level 7', '37 of 82 rooms', [['Unit 7A', 3, 4], ['Unit 7B', 0, 5], ['Unit 7C', 5, 5], ['Unit 7D', 4, 6]]], ['Level 8', '0 of 41 rooms', [['Unit 8A', 0, 4], ['Unit 8B', 0, 5]]]];
const FILTERED_SESSIONS = [['Tue 12 Aug', '112 photos · 14 issues · Hanh'], ['Mon 28 Jul', '87 photos · 9 issues · Hanh'], ['Wed 25 Jun', '58 photos · 6 issues · Hanh'], ['Mon 9 Jun', '71 photos · 4 issues · Minh']];
const FILTERED_PLANS = [['Level 7 architectural', 'PDF · 7 pins'], ['Level 7 electrical', 'PDF, sheet 2 of 6 · 1 pin'], ['Level 7 plumbing', 'PDF · 2 pins']];
const MORE_SESSIONS = [['Tue 12 Aug', '112 photos · 14 issues · Hanh', true], ['Mon 28 Jul', '87 photos · 9 issues · Hanh', true], ['Thu 10 Jul', '64 photos · 5 issues · Minh', false], ['Wed 25 Jun', '58 photos · 6 issues · Hanh', true], ['Mon 9 Jun', '71 photos · 4 issues · Minh', true], ['Fri 23 May', '40 photos · 2 issues · Hanh', false], ['Tue 6 May', '35 photos · 3 issues · Hanh', true]];
const UNITS_WITH_ISSUES = [['Level 7', [['Unit 7A', '3 of 4 rooms checked', 'crit', '2 critical'], ['Unit 7D', '4 of 6 rooms checked', 'major', '1 major']]], ['Level 8', [['Unit 8A', '0 of 4 rooms checked', 'major', '1 major'], ['Unit 8C', '2 of 6 rooms checked', 'minor', '3 minor']]]];
const MORE_PLANS = [['Level 7 architectural', 'PDF · 7 pins'], ['Level 8 architectural', 'PDF · 3 pins'], ['Level 9 architectural', 'Photo of printed sheet · no pins'], ['Level 7 electrical', 'PDF, sheet 2 of 6 · 1 pin'], ['Level 8 electrical', 'PDF, sheet 3 of 6 · no pins'], ['Level 7 plumbing', 'PDF · 2 pins'], ['Level 8 plumbing', 'PDF · no pins'], ['Roof plan', 'PDF · 1 pin']];

/* Team and roles (one company, four roles): site-log-be docs/feature-docs/05-team-and-roles.md */
const ROLES = [
  ['admin', 'Admin', 'Members, roles and everything else'],
  ['manager', 'Manager', 'Runs projects: rooms, plans, closes issues, signs reports'],
  ['inspector', 'Inspector', 'Walks the site: photos, issues, checklists, reports'],
  ['viewer', 'Viewer', 'Reads the projects they are added to'],
];
const roleName = (k) => ROLES.find(r => r[0] === k)[1];
const MEMBERS = [
  // [name, email, role, initials, avatar colour, projects]
  ['Hanh Nguyen', 'hanh@eastline.vn', 'admin', 'HN', '#C9B79C', 'All projects'],
  ['Tran Minh', 'minh@eastline.vn', 'manager', 'TM', '#9DB0B8', 'All projects'],
  ['Le Thu', 'thu@eastline.vn', 'inspector', 'LT', '#B8A59D', '2 projects'],
  ['Pham Quang', 'quang@eastline.vn', 'inspector', 'PQ', '#A9B39A', '1 project'],
  ['Riverside Development', 'pm@riverside.vn', 'viewer', 'RD', '#B3A9C2', '1 project'],
];
const INVITES = [['vu@eastline.vn', 'inspector', 'Expires in 6 days'], ['qa@aquaseal.vn', 'viewer', 'Expires in 2 days']];
/* Push notifications: the kinds a member can turn on or off (per device), and sample pushes */
const PUSH_KINDS = [
  // [kind, title in Settings, what triggers it, on by default in the samples]
  ['uploadsVerified', 'Photos are safe', 'A walkthrough’s photos are uploaded and verified', true],
  ['issueAssigned', 'Assigned to you', 'An issue is assigned to you, or to someone else after you', true],
  ['issueRechecked', 'Re-check results', 'An issue you logged or own is re-checked: resolved, still open or worse', true],
  ['dueSoon', 'Due tomorrow', 'One summary at 8:00 of your open issues due the next day', false],
  ['access', 'Projects and role', 'You are added to or removed from a project, or your role changes', true],
];
const PUSH_SAMPLES = {
  // kind: [title, body, time]
  issueAssigned: ['Assigned to you · Major', 'Hairline crack by the skirting, 7A Living room. Due Fri.', 'now'],
  uploadsVerified: ['Level 7 walkthrough is safe', 'All 112 photos are uploaded and verified.', '9:12'],
  issueRechecked: ['Re-check: still open', 'Le Thu re-checked Exposed wiring at socket, 7A Kitchen.', 'Yesterday'],
  dueSoon: ['2 issues due tomorrow', 'Riverside Tower B · Phuc Electric, Tuan’s crew.', '8:00'],
  access: ['Added to Harbor View Villas', 'Hanh Nguyen added you as Inspector.', 'Mon'],
};
/* A push as the system draws it (system chrome: 15 pt text, not app tokens). iOS: glass card with the app icon; Android: card with a small icon and the app name. */
const pushCardIOS = (kind, o = {}) => { const [t, b, time] = PUSH_SAMPLES[kind]; return `<div style="display:flex;gap:10px;align-items:flex-start;padding:12px 14px;border-radius:24px;background:${o.lock ? 'rgba(245,245,245,.72)' : '#fff'};${o.lock ? 'backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);' : 'box-shadow:0 6px 20px rgba(0,0,0,.12),0 0 0 .5px rgba(0,0,0,.06);'}color:#16181B;text-align:left">${appMark(38)}<div style="flex:1;min-width:0"><div style="display:flex;gap:8px;align-items:baseline"><span style="flex:1;font-size:15px;line-height:20px;font-weight:600">${t}</span><span style="font-size:13px;line-height:20px;color:rgba(22,24,27,.55)">${time}</span></div><div style="font-size:15px;line-height:20px">${b}</div></div></div>`; };
const pushCardAND = (kind, o = {}) => { const [t, b, time] = PUSH_SAMPLES[kind]; return `<div style="padding:14px 16px;border-radius:24px;background:${o.lock ? '#2A2C30' : '#fff'};color:${o.lock ? '#F2F0EC' : '#16181B'};${o.lock ? '' : 'box-shadow:0 4px 16px rgba(0,0,0,.12),0 0 0 1px rgba(0,0,0,.05);'}text-align:left;display:flex;flex-direction:column;gap:4px"><div style="display:flex;gap:8px;align-items:center;font-size:13px;line-height:20px;color:${o.lock ? '#A4A7AD' : '#63676E'}"><span style="width:20px;height:20px;border-radius:10px;background:#FFD400;display:grid;place-items:center;color:#1B1700">${I('camera', 12, 2.4)}</span>SiteLog · ${time === 'now' ? 'now' : time}</div><div style="font-size:15px;line-height:20px;font-weight:600">${t}</div><div style="font-size:15px;line-height:20px">${b}</div></div>`; };
/* Team activity (member_events): [day, [[initials, colour, who, what, time]]] */
const ACTIVITY = [
  ['Today', [
    ['HN', '#C9B79C', 'Hanh Nguyen', 'invited vu@eastline.vn as Inspector', '9:40'],
    ['HN', '#C9B79C', 'Hanh Nguyen', 'changed Le Thu from Viewer to Inspector', '9:12'],
    ['TM', '#9DB0B8', 'Tran Minh', 'added Pham Quang to Riverside Tower B', '8:05'],
  ]],
  ['Yesterday', [
    ['HN', '#C9B79C', 'Hanh Nguyen', 'resent the invite to qa@aquaseal.vn', '17:20'],
    ['RD', '#B3A9C2', 'Riverside Development', 'joined as Viewer', '14:02'],
  ]],
];
/* Default avatar: initials always centred in the circle (line-height 1, no inherited line box); size → initials size */
const AVATAR_TEXT = { 56: 20, 48: 17, 40: 15, 24: 10, 20: 9 };
const avatar = (ini, color, s = 40) => `<span style="width:${s}px;height:${s}px;border-radius:${s / 2}px;background:${color};color:#fff;display:inline-flex;align-items:center;justify-content:center;font-weight:600;font-size:${AVATAR_TEXT[s] || Math.round(s * 0.38)}px;line-height:1;letter-spacing:0;text-align:center;flex:none;overflow:hidden">${ini}</span>`;
const roleTag = (k) => `<span class="tag" style="margin-left:0">${roleName(k)}</span>`;

/* Issue assignees: a member or a subcontractor typed in; the list shows only their avatar, the detail shows avatar + name */
const ASSIGNEES = { 'Phuc Electric': ['PE', '#9DB0B8'], 'Tuan’s crew': ['TC', '#C9B79C'], 'Tuan’s masonry crew': ['TC', '#C9B79C'], 'painters': ['PT', '#B3A9C2'], 'AquaSeal': ['AS', '#A9B39A'] };
const assigneeAvatar = (who, s = 24) => { const [ini, c] = ASSIGNEES[who] || [who.slice(0, 2).toUpperCase(), '#A0A3A9']; return `<span title="${who}" style="display:inline-flex">${avatar(ini, c, s)}</span>`; };
/* In a list the avatar sits right of the date, under the severity, right-aligned; with no date it sits alone on that line */
const withAssignee = (who, trail) => {
  const col = 'display:flex;flex-direction:column;align-items:flex-end;gap:4px';
  const date = trail.match(/(<span class="fn"[^>]*>[^<]*<\/span>)<\/div>$/);
  if (date) return trail.replace(date[1], `<span class="hstack" style="gap:4px">${date[1]}${assigneeAvatar(who, 20)}</span>`);
  return `<div style="${col}">${trail}${assigneeAvatar(who, 20)}</div>`;
};
const assigneeLine = (who) => `<span class="hstack" style="gap:8px">${assigneeAvatar(who)}<span class="t-body">${who}</span></span>`;

/* Result hero: the icon sits on the horizontal centre for every success, error or empty result.
   tone: ok (success), crit (failed), neutral (paused, waiting, empty). */
const hero = (tone, icon, title, text, o = {}) => `<div class="hero" ${o.style ? `style="${o.style}"` : ''}><span class="hero-ic ${tone}">${I(icon, 32, tone === 'neutral' ? 2 : 2.6)}</span><div class="hero-txt"><div class="${o.big ? 't-title' : 't-heading'}">${title}</div>${text ? `<div class="t-body" style="color:var(--ink2)">${text}</div>` : ''}</div>${o.extra || ''}</div>`;

/* Empty state wrapper: centres its content vertically in the view (see .empty) */
const empty = (inner) => `<div class="empty">${inner}</div>`;

/* Site photo stand-ins: flat architectural scenes rather than grey boxes */
function scene(v = 0, o = {}) {
  const pal = [
    ['#D9D3C7', '#C9C1B2', '#9E9584', '#E9E4DA'],
    ['#CFD6D8', '#B7C1C4', '#7F8C90', '#E4EAEB'],
    ['#C9C5BE', '#B3AEA5', '#8A857C', '#DCD8D1'],
    ['#DCCFBE', '#C8B8A3', '#A08C74', '#EDE4D8'],
  ][v % 4];
  const crack = o.crack ? `<path d="M210 250 l14 18 -8 14 16 20 -6 16 14 22" fill="none" stroke="#5B4A3A" stroke-width="2.2" stroke-linecap="round"/>` : '';
  const tiles = v % 4 === 1 ? Array.from({ length: 8 }, (_, i) => `<line x1="${i * 50}" y1="0" x2="${i * 50}" y2="330" stroke="#fff" stroke-opacity=".55" stroke-width="2"/>`).join('') + Array.from({ length: 7 }, (_, i) => `<line x1="0" y1="${i * 50}" x2="400" y2="${i * 50}" stroke="#fff" stroke-opacity=".55" stroke-width="2"/>`).join('') : '';
  return `<svg class="ph" viewBox="0 0 400 500" preserveAspectRatio="xMidYMid slice">
    <rect width="400" height="500" fill="${pal[0]}"/>
    <polygon points="0,0 70,40 70,360 0,420" fill="${pal[1]}"/>
    <polygon points="400,0 330,40 330,360 400,420" fill="${pal[1]}"/>
    <rect x="70" y="40" width="260" height="320" fill="${pal[0]}"/>${tiles}
    <polygon points="0,420 70,360 330,360 400,420 400,500 0,500" fill="${pal[2]}"/>
    ${v % 4 === 0 ? `<rect x="120" y="90" width="120" height="150" fill="${pal[3]}" stroke="${pal[2]}" stroke-width="6"/><line x1="180" y1="90" x2="180" y2="240" stroke="${pal[2]}" stroke-width="4"/>` : ''}
    ${v % 4 === 2 ? `<rect x="250" y="130" width="60" height="230" fill="${pal[2]}" opacity=".6"/><circle cx="298" cy="250" r="4" fill="${pal[3]}"/>` : ''}
    ${v % 4 === 3 ? `<ellipse cx="200" cy="80" rx="80" ry="30" fill="#A38A6C" opacity=".35"/>` : ''}
    <line x1="70" y1="360" x2="330" y2="360" stroke="${pal[2]}" stroke-width="3"/>
    ${crack}
  </svg>`;
}

/* Floor plan and pins, shared by both plan viewers */
const planDrawing = () => `<svg viewBox="0 0 393 560" preserveAspectRatio="xMidYMid slice" style="position:absolute;inset:0;width:100%;height:100%" fill="none" stroke="#3C4046" stroke-width="2.5">
  <rect x="20" y="20" width="353" height="500"/><line x1="200" y1="20" x2="200" y2="200"/><line x1="20" y1="200" x2="373" y2="200"/><line x1="120" y1="200" x2="120" y2="320"/><line x1="20" y1="320" x2="373" y2="320"/><line x1="200" y1="320" x2="200" y2="450"/><line x1="20" y1="450" x2="373" y2="450"/>
  <path d="M200 120 a28 28 0 0 1 28 28" stroke-width="1.2"/><path d="M60 200 a28 28 0 0 0 28 -28" stroke-width="1.2"/>
  <g font-family="var(--sans)" font-size="11" fill="#7C8087" stroke="none"><text x="32" y="40">7A Living</text><text x="212" y="40">7A Bedroom 1</text><text x="32" y="220">Bath</text><text x="132" y="220">7A Kitchen</text><text x="32" y="340">7B Living</text><text x="212" y="340">7B Bedroom 1</text><text x="32" y="470">Corridor</text></g></svg>`;
const pins = () => `${[['crit', 1, 250, 250], ['major', 2, 90, 100], ['major', 3, 140, 140], ['minor', 4, 290, 90]].map(([k, n, x, y]) => `<div class="pin" style="left:${x}px;top:${y}px;background:var(--${k})"><b>${n}</b></div>`).join('')}<div class="pin hollow" style="left:60px;top:250px"><b>5</b></div><div class="pin hollow" style="left:300px;top:390px"><b>6</b></div><div class="cluster" style="left:95px;top:380px">5</div>`;

/* Status bar glyphs */
const battery = (c) => `<svg width="27" height="13" viewBox="0 0 27 13"><rect x=".5" y=".5" width="23" height="12" rx="3.5" fill="none" stroke="${c}" opacity=".4"/><rect x="2" y="2" width="17" height="9" rx="2" fill="${c}"/><rect x="25" y="4.5" width="1.5" height="4" rx=".75" fill="${c}" opacity=".4"/></svg>`;
const signal = (c) => `<svg width="18" height="12" viewBox="0 0 18 12"><rect x="0" y="8" width="3" height="4" rx="1" fill="${c}"/><rect x="5" y="5.5" width="3" height="6.5" rx="1" fill="${c}"/><rect x="10" y="3" width="3" height="9" rx="1" fill="${c}"/><rect x="15" y="0" width="3" height="12" rx="1" fill="${c}" opacity=".35"/></svg>`;
const wifi = (c) => `<svg width="17" height="12" viewBox="0 0 17 12"><path d="M8.5 2.3c2.3 0 4.4.9 6 2.4l1.2-1.2A10.2 10.2 0 0 0 8.5.6 10.2 10.2 0 0 0 1.3 3.5l1.2 1.2c1.6-1.5 3.7-2.4 6-2.4Zm0 3.4c1.4 0 2.6.5 3.6 1.4l1.2-1.2a7 7 0 0 0-9.6 0l1.2 1.2c1-.9 2.2-1.4 3.6-1.4Zm0 3.3c.5 0 1 .2 1.3.5L8.5 11 7.2 9.5c.3-.3.8-.5 1.3-.5Z" fill="${c}"/></svg>`;

/* Screen registry: each platform page pushes groups of screens, then renders them. */
const GROUPS = [];
const group = (name, spec, screens) => GROUPS.push({ name, spec, screens });
const figure = (id, title, phone, w) => ({ id, html: `<figure class="screen" style="width:${w}px"><figcaption><span>${id}</span>${title}</figcaption>${phone}</figure>` });
/* Flows: rows of small screens; the tapped control gets a ring and an arrow leads to the next screen. */
const FLOW_SCALE = 0.5;
const FLOW_HOT = '.ic,.ibtn,.btn,.row,.li,.chip,.gcap,.gbtn,.tab,.dest,.side,.efab,.side-btn,.act,.link,.ws,.tbtn,.capture,.fab,.shutter,.pin';
function findHot(root, hot) {
  if (!hot) return null;
  if (/^[.#\[]/.test(hot)) return root.querySelector(hot);
  const el = [...root.querySelectorAll('*')].filter(e => e.textContent.trim() === hot).pop();
  return el ? (el.closest(FLOW_HOT) || el) : null;
}
function flowsHTML(flows) {
  const all = GROUPS.flatMap(g => g.screens);
  const card = (st) => {
    const sc = all.find(x => x.id === st.id);
    const w = +sc.html.match(/width:(\d+)px/)[1];
    const h = w === 393 ? 852 : 917;
    const title = sc.html.match(/<figcaption><span>[^<]*<\/span>([^<]*)<\/figcaption>/)[1];
    const phone = sc.html.replace(/^<figure[^>]*>/, '').replace(/<\/figure>$/, '').replace(/<figcaption>[\s\S]*?<\/figcaption>/, '');
    return `<div class="flow-step"><div class="flow-cap"><span>${st.id}</span>${title}</div><div class="flow-card" style="width:${w * FLOW_SCALE}px;height:${h * FLOW_SCALE}px"><div style="width:${w}px;transform:scale(${FLOW_SCALE});transform-origin:0 0">${phone}</div></div></div>`;
  };
  return `<section class="group">${flows.map((f, fi) => `<div class="flow"><h3>${f.name}</h3><div class="flow-row" data-flow="${fi}">${f.steps.map(card).join('')}</div></div>`).join('')}</section>`;
}
function drawFlows(flows) {
  document.querySelectorAll('.flow-row').forEach(row => {
    row.querySelectorAll('.flow-ink').forEach(e => e.remove());
    const steps = flows[+row.dataset.flow].steps;
    const box = row.getBoundingClientRect();
    const cards = [...row.querySelectorAll('.flow-card')];
    let svg = `<svg class="flow-ink" width="${box.width}" height="${box.height}"><defs><marker id="fa" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#2563EB"/></marker></defs>`;
    let extra = '';
    steps.forEach((st, i) => {
      if (i === cards.length - 1) return;
      const hot = findHot(cards[i], st.hot);
      const next = cards[i + 1].getBoundingClientRect();
      const cur = cards[i].getBoundingClientRect();
      let r = hot ? hot.getBoundingClientRect() : { left: cur.right - 24, top: cur.top + cur.height / 2 - 12, width: 24, height: 24 };
      const x0 = r.left - box.left, y0 = r.top - box.top;
      if (hot) extra += `<div class="flow-ink flow-ring" style="left:${x0 - 3}px;top:${y0 - 3}px;width:${r.width + 6}px;height:${r.height + 6}px"></div>`;
      const sx = x0 + r.width + 3, sy = y0 + r.height / 2;
      const ex = next.left - box.left - 6, ey = Math.min(Math.max(sy, next.top - box.top + 40), next.bottom - box.top - 40);
      const mx = (cur.right - box.left + ex) / 2;
      svg += `<path d="M${sx},${sy} C${mx},${sy} ${mx},${ey} ${ex},${ey}" fill="none" stroke="#2563EB" stroke-width="2" marker-end="url(#fa)"/>`;
      extra += `<div class="flow-ink flow-label" style="left:${mx}px;top:${(sy + ey) / 2}px">${st.label}</div>`;
    });
    row.insertAdjacentHTML('beforeend', svg + '</svg>' + extra);
  });
}
function renderGroups(target, darkIds) {
  const all = GROUPS.flatMap(g => g.screens);
  const dark = darkIds.map(id => all.find(s => s.id === id).html.replace('<figcaption><span>', '<figcaption><span>Dark · '));
  let html = '';
  for (const g of GROUPS) {
    html += `<section class="group"><h2>${g.name}<small>${g.spec} · ${g.screens.length} screens</small></h2><div class="row-screens">${g.screens.map(s => s.html).join('')}</div></section>`;
  }
  html += `<section class="group"><h2>Dark mode<small>the same screens with dark token values</small></h2><div class="row-screens theme-dark">${dark.join('')}</div></section>`;
  document.getElementById(target).innerHTML = html;
  lucide.createIcons();
}
/* The flows page: builds each flow from the screens already registered with group() */
function renderFlows(target, flows) {
  document.getElementById(target).innerHTML = flowsHTML(flows);
  lucide.createIcons();
  drawFlows(flows);
  document.fonts.ready.then(() => drawFlows(flows));
}
