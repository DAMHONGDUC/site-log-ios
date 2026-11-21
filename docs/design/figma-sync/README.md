# Figma sync — log and how to resume

<dl><dd>

- Log of moving the HTML design pages ([../html/](../html/)) into Figma as editable layers, and the tools that do it.
- Last run: 2026-11-21. Stopped again by the Figma MCP limit (Starter plan, View seat: 20 calls a month) after 3 calls; the first stop was on 2026-11-17. Figma does not say when the count resets: try again in December, or upgrade to a Full seat.

</dd></dl>

## Contents

<dl><dd>

1. [Status](#1-status)
2. [Left to do](#2-left-to-do)
3. [How it works](#3-how-it-works)
4. [Resume](#4-resume)

</dd></dl>

## 1. Status

<dl><dd>

- File 1: [Site Log iOS Design](https://www.figma.com/design/uJZcCP6lzw8QTSkcu8uqvV/Site-Log-iOS-Design) (`uJZcCP6lzw8QTSkcu8uqvV`), plan `team::1667582086334207196` (Starter: 3 pages per file).
- File 2 (pages 04–05): not created yet.

| Page | Figma page id | Built | State |
|---|---|---|---|
| 01 Foundations | `0:1` | 2026-11-21 | Up to date (rebuilt from commit `07512af`: new board spacing, rounded icons) |
| 02 iOS | `54:2` | 2026-11-17 | Stale: old version (72 screens, old spacing, square app marks); the HTML now has 79 screens + 3 dark |
| 03 Android | `54:3` | 2026-11-17 | Stale, same as 02; never checked by screenshot |
| 04 Flows | — | — | Not started (file 2) |
| 05 System design | — | — | Not started (file 2) |

- Already uploaded and waiting on page 01 (small 8 × 8 frames, safe to leave): the builder `figx-builder` (`58:2`) and the carriers `figx-c-f1b-001…015` (page 02) and `figx-c-f1c-001…015` (page 03), exported from commit `07512af`. If the HTML changes before the next run, delete these carriers and export again.
- Removed from the old Page 1 (approved): the old `mockups/index.html` import and a stray text node.
- Each group is one top-level frame named after its heading; each screen is a frame named by its id and title (e.g. `A1 Face ID lock`) with a `phone` frame inside.

</dd></dl>

## 2. Left to do

<dl><dd>

| # | Task | Calls (est.) |
|---|---|---|
| 1 | Page 02: build from the waiting carriers with `clear: true` (`page: '54:2', src: '0:1', prefix: 'figx-c-f1b'`, 8 then 7) | 2 |
| 2 | Page 03: same with `page: '54:3', prefix: 'figx-c-f1c'` | 2 |
| 3 | Screenshot check of one group on 02 and 03 | 1–2 |
| 4 | File 2: `create_new_file` (exempt), `create_session`, one `use_figma` to name page 1 "04 Flows" and add "05 System design" | 2 |
| 5 | Export 04 and 05 again (`f2a`, `f2b`; the local `out/` folder is not kept), build `builder.js` carrier, one `upload_assets` with all of them (26 + 29 + 1 = 56, under 60) | 1 |
| 6 | Build 04 (26 small chunks, 2 calls) and 05 (29 chunks, 2 calls) with `src` = file 2's page 1 | 4 |
| 7 | Remove the builder on both files; screenshot check of 04 and 05 | 2–3 |
| 8 | Update the status in [00-design-plan §4](../00-design-plan.md#4-status-2026-11-17) and this log; put the file 2 page links in the README Design sections (iOS §4, Android §6), replacing "Not imported yet" | — |

- About 15 calls. Do the builds first and the read-only checks last.
- Any later change to the HTML pages makes the Figma copy stale: re-export the changed pages and rebuild them with `clear: true`.

</dd></dl>

## 3. How it works

<dl><dd>

```mermaid
flowchart LR
    Page["HTML page<br/>(browser, 1600 wide)"] -->|figx.js: serialise each group| Server["server.mjs<br/>writes carrier .svg files"]
    Server -->|up.sh: POST to upload_assets URLs| Figma["Figma page<br/>(carrier = SVG with a base64 text)"]
    Figma -->|use_figma: decode + builder.js| Layers["Frames, text, vectors"]
```

| File | Role |
|---|---|
| [figx.js](figx.js) | In the browser: turns `::before` / `::after` into real spans, inlines `<img src=*.svg>`, serialises each chunk (boxes, fills, borders, radii, shadows, blur, text runs with font and line height, SVG icons) and posts it to the server as a carrier SVG |
| [server.mjs](server.mjs) | Local endpoint on port 8766 that writes each posted carrier to a folder |
| [up.sh](up.sh) | Uploads carriers, in name order, to the upload URLs from `upload_assets`; each becomes a frame named `figx-c-…` on the target page |
| [builder.js](builder.js) | Runs inside Figma: reads the carriers (`args.src` page, `args.prefix` name), builds the layers on `args.page` at the HTML positions, deletes the carriers; `args.clear` first removes the page's old frames. Stored in the file as the carrier `figx-builder` (`54:4`) so each `use_figma` call stays small |

- Why carriers: the Figma MCP here has no HTML import tool and the plugin sandbox has no `fetch`; uploads are the only way to move large data into the file.
- Fonts in Figma: IBM Plex Sans / Mono (iOS pages), Inter / JetBrains Mono (Android); all available in the file.
- Known limits: SVG `<mask>` / `<clipPath>` are not imported (rounded `<svg>` elements are now wrapped in a clipping frame by `figx.js`); glass blur becomes a Figma background blur; scaled content (the flow cards at 50 %) is exported at its drawn size; SVG `marker-end` arrowheads become plain triangles.

</dd></dl>

## 4. Resume

<dl><dd>

1. Start the design server and the export server (the `out` folder is git-ignored):

```bash
python3 -m http.server 8765 --directory docs/design
```

```bash
node docs/design/figma-sync/server.mjs "$PWD/docs/design/figma-sync/out"
```

2. In the browser, open the page at 1600 px wide, load `/figma-sync/figx.js`, then export (page 01 first runs `__FIGX.inlineImgs()`):

| Page | Call |
|---|---|
| 04 Flows | `await __FIGX.exportPage('flo', 'header.page-head, #app .flow', '.flow-step, .phone')` — the cards are `transform: scale(0.5)`, and `figx.js` reads font sizes unscaled: first set `FLOW_SCALE` to 1 (or strip the transform) before export, then `rescale(0.5)` the cards in Figma, or teach `figx.js` the scale |
| 05 System design | `await __FIGX.exportPage('sys', 'header.page-head, #app > section.cmp', '')` |

3. `upload_assets` with `count` = number of chunks and the target `currentPageId`, then `OUT=out ./up.sh <page-id> figx-c-<prefix> <uuid…>`.
4. One `use_figma` per page with the wrapper below (`args.max` = chunks to build in that call; 7–8 groups fit).
5. In file 2, upload `builder.js` once as its own carrier first (any name, e.g. `figx-builder`) and use that node id in the wrapper.

<details>
<summary>use_figma wrapper</summary>

```js
const D = (b64) => { const A = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'; const m = {}; for (let i = 0; i < 64; i++) m[A[i]] = i; const by = []; let buf = 0, bits = 0; for (const ch of b64) { if (ch === '=') break; const v = m[ch]; if (v === undefined) continue; buf = ((buf << 6) | v) & 0xffffff; bits += 6; if (bits >= 8) { bits -= 8; by.push((buf >> bits) & 255); } } let s = '', i = 0; while (i < by.length) { const b = by[i++]; if (b < 128) s += String.fromCharCode(b); else if (b < 224) s += String.fromCharCode(((b & 31) << 6) | (by[i++] & 63)); else if (b < 240) s += String.fromCharCode(((b & 15) << 12) | ((by[i++] & 63) << 6) | (by[i++] & 63)); else { const cp = ((b & 7) << 18) | ((by[i++] & 63) << 12) | ((by[i++] & 63) << 6) | (by[i++] & 63); s += String.fromCodePoint(cp); } } return s; };
const B = await figma.getNodeByIdAsync('54:4'); // builder carrier
const src = D(B.findOne(n => n.type === 'TEXT').characters);
const AF = Object.getPrototypeOf(async function () {}).constructor;
return await new AF('figma', 'D', 'args', src)(figma, D, { page: '<page id>', max: 7, bg: 'E6E7EA' });
```

- To build the carrier for `builder.js`: base64 the file into `<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"><text x="0" y="6" font-size="6">BASE64</text></svg>`.

</details>

</dd></dl>
