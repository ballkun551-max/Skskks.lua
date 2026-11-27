# Database Schema — BALL KUN AI FARM V10.5

ทุกไฟล์เป็น JSON (UTF-8) อยู่ในโฟลเดอร์ workspace ของตัวรัน ข้อมูลแยกตาม PlaceId และห้ามข้ามแมพ

## โครงโฟลเดอร์
```
BALL_KUN_Dump/                         ← ของ V9 (ผลสแกน, settings.json, diagnostics)
BALL_KUN_AI_Dump/
  maps_index.json                      ← รายการ PlaceId ที่เคยใช้
  v102_settings.json                   ← ค่าสวิตช์ทั้งหมดของ V10.4
  exports/<PlaceId>_<sessionId>.json   ← session ที่ส่งออก (ไม่เขียนทับ)
  <PlaceId>/
    map_db.json                        ← DB ของแมพ (สร้างอัตโนมัติเมื่อเจอแมพใหม่)
    farmplan.json                      ← Farm Plan ล่าสุด
    profile.json, jobs.json, ...       ← ไฟล์ Smart Dump / Game Profile ของ V9 (ไม่เปลี่ยน)
    sessions/<sessionId>.json          ← session ที่บันทึก
    sessions/<sessionId>_report.txt    ← รายงาน AI Analyzer
```
`sessionId` ต้องเป็น `A-Z a-z 0-9 _ -` เท่านั้น (กัน path หลุดโฟลเดอร์) ID ใหม่ใช้รูปแบบ `YYYYMMDD_HHMMSS_<8 ตัวสุ่ม>` ส่วน ID เก่าที่ไม่มีส่วนสุ่มยังใช้ได้

## maps_index.json
`{ "maps": [ <PlaceId:number>, ... ] }`

## <PlaceId>/map_db.json
| ฟิลด์ | ชนิด | ความหมาย |
|---|---|---|
| schema | number | เวอร์ชัน schema (2) |
| placeId, gameId | number | จาก `game.PlaceId` / `game.GameId` |
| name | string | `game.Name` ตอนลงทะเบียนครั้งแรก |
| firstSeen, lastSeen | string | `YYYY-MM-DD HH:MM:SS` |
| visits | number | จำนวนครั้งที่รันสคริปต์ในแมพนี้ |
| builtinStops | boolean | มีจุดเดินทางฝังในโค้ด V9 (`KNOWN_STOPS_BY_PLACE`) หรือไม่ |

## <PlaceId>/sessions/<id>.json
| ฟิลด์ | ชนิด | ที่มา |
|---|---|---|
| schema, version | number, string | 2 / เวอร์ชันที่สร้าง session (ปัจจุบัน "10.5") |
| id, name | string | ระบบ / ผู้เล่นตั้งชื่อ |
| placeId, gameId, mapName, player | | ระบบ |
| profession | string | **ผู้เล่นป้อน** |
| startedAt, endedAt | string | ระบบ |
| duration | number | วินาที ไม่นับช่วง PAUSE |
| recording | boolean | true = ยังไม่ปิด (อาจค้างจากปิดเกมกลางคัน) |
| learn | boolean | ค่า AI Learning ตอนบันทึก (Farm Plan/Replay ใช้เฉพาะ true) |
| options | object | ค่าสวิตช์ Recorder ตอนบันทึก |
| path[] | `{t,x,y,z}` | ตำแหน่ง (Movement Recorder) สูงสุด 20,000 จุด |
| route[] | `{t,x,y,z}` | เส้นทางแบบย่อ ทุก 10 สตั๊ด (Route Recorder) |
| events[] | ดูด้านล่าง | สูงสุด 5,000 รายการ |
| missions[] | ดูด้านล่าง | |
| counts, sizeBytes, capped | | สถิติ — `counts.byType` = {prompt, click, tool, gui, abort} (V10.4) |
| activeMission | object? | **V10.5** ภารกิจที่ยังไม่จบ (เก็บทุก Save/Autosave, เป็น nil เมื่อจบ/ยกเลิก) ใช้กู้เมื่อเกมปิดกลางคัน — ไม่ถูกนับเป็นภารกิจจนกว่าจะกู้ |

### events[] (ทุกรายการมี `t` = วินาทีนับจากเริ่ม, `kind`)
| kind | ฟิลด์เพิ่ม | แหล่งข้อมูล |
|---|---|---|
| interaction | type, src="game", action, object, path, pos[x,y,z]? + ฟิลด์ตาม type (ดูตารางถัดไป) | เกม (Prompt / Click / Tool / ปุ่ม UI ที่ผู้เล่นกดเอง) |
| npc | src="game", action = near/leave/interact, name, path, pos[x,y,z], dist, + near: hasPrompt/hasClick/hasDialog, + interact: via = prompt/click | เกม (ตำแหน่งโมเดลเทียบผู้เล่น / Prompt-Click ที่ผู้เล่นกดเอง) |
| interaction_abort | type="prompt", action, object, path, pos, held, hold, note | **คำนวณฝั่งไคลเอนต์** (ปล่อยปุ่มก่อนครบเวลาถือ) ไม่ใช่ผลที่เกมยืนยัน ไม่นับเป็นขั้นตอนภารกิจ/Farm Plan |
| vehicle | action = enter/exit, seat, class, pos | เกม (Humanoid.SeatPart) |
| result | src="game", stat, value, delta | เกม (leaderstats ของผู้เล่น) |
| mission | action = start/end/note/cancel (note/cancel เพิ่มใน V10.5), name, result, note, cancel: steps (จำนวนที่ทิ้ง) | ผู้เล่นกดปุ่มเอง |
| error | src = game / player / system, note, corrected? | เกม (ตัวละครตาย) / ผู้เล่น / ระบบ |
| system | note | ระบบ (เริ่ม/หยุด/pause/resume) |

### ฟิลด์ของ interaction แยกตาม `type` (เพิ่มใน V10.4 ข้อมูลเก่าไม่มี `type` ระบบอนุมานจาก action)
| type | action | ฟิลด์เพิ่ม |
|---|---|---|
| prompt | ActionText ของ prompt | hold (HoldDuration), key (KeyboardKeyCode), held (วินาทีที่ถือจริง ถ้ามีการถือ), dist (ระยะถึงวัตถุ คำนวณฝั่งไคลเอนต์) |
| click | click / rightclick | button (left/right), maxDist, dist |
| tool | tool_equip / tool_unequip / tool_use | path = `Tool:<ชื่อ>`, at[x,y,z] ตำแหน่งผู้เล่น, seated? (ใช้ Tool ขณะนั่ง) — `tool_use` ถี่เกิน 1 ครั้ง/2 วิ นับเป็นซ้ำ |
| gui | ui_click | object = ข้อความบนปุ่ม (ตัด 60 ตัวอักษร), screen = ชื่อ ScreenGui, at[x,y,z] — ไม่บันทึกข้อความใน TextBox/แชต |

ข้อความทุกช่องถูกตัดอักขระควบคุมและตัดตามตัวอักษร (ไม่ตัดกลาง UTF-8) กัน JSON เสียหาย

### NPC (V10.4)
- NPC = Model ที่มี Humanoid และไม่ใช่ตัวละครผู้เล่น (**ตัดสินจากโครงสร้าง ไม่ใช่ที่เกมยืนยัน**) รัศมีเข้า 30 / ออก 36 สตั๊ด (กันสลับถี่) สูงสุด 300 ตัวที่ติดตาม และบันทึก near ได้ 20 ครั้งต่อตัวต่อ session
- `interaction` ที่เกิดกับ NPC จะมีฟิลด์ `npc` (ชื่อ) และมีเหตุการณ์ `npc/interact` คู่กัน (Farm Plan ใช้ขั้นตอน interaction ตามเดิม ไม่ซ้ำ)
- `counts.byType` เพิ่ม npc, npc_near, npc_leave, npc_interact
- options เพิ่ม `npc`

### missions[]
`name, startT, endT, duration, profession, steps[{t,action,object,path,pos,type?}], result ("success"|"fail"|"unknown"), resultSource ("player"|"system"), note, statsDelta?{stat=delta}`
- `result` = **ผู้เล่นป้อน** ไม่ใช่ผลที่เกมยืนยัน (ภารกิจที่กู้อัตโนมัติ = `unknown`, `resultSource="system"`)
- `statsDelta` = **เกมยืนยัน** (ผลต่างของ leaderstats ระหว่างเริ่ม-จบภารกิจ) มีเฉพาะเมื่อค่าเปลี่ยนจริง
- `steps` = เฉพาะ interaction (เหมือน V10.2 ใช้ทำลายเซ็น/Farm Plan) `type` (V10.5) = prompt/click/tool/gui ข้อมูลเก่าไม่มี ระบบอนุมานจาก action

**ฟิลด์เพิ่มใน V10.5 (ส่วนที่ 5)** — ข้อมูลเก่าไม่มี อ่านได้ตามเดิม
| ฟิลด์ | ชนิด | ความหมาย / ที่มา |
|---|---|---|
| marks[] | `{t, kind, ...}` ≤ 200 | เหตุการณ์ระหว่างภารกิจ **เกมยืนยัน**: `vehicle`{action,class,pos} · `result`{stat,value,delta} · `error`{src,note} · `npc`{action,name,pos} · **คำนวณฝั่งไคลเอนต์**: `interaction_abort`{action,object,calc=true} |
| marksDropped | number? | จำนวน marks ที่ทิ้งเพราะเกินเพดาน |
| notes[] | `{t, text, src="player", pos?}` ≤ 100 | **ผู้เล่นป้อน** ข้อความ ≤ 120 ตัวอักษร ไม่เข้า steps/ลายเซ็น/Farm Plan |
| startPos, endPos | `[x,y,z]?` | ตำแหน่งผู้เล่นตอนเริ่ม/จบ (อ่านจากเกม) |
| interrupted | boolean? | true = ถูกตัดขาด (STOP ก่อนจบ หรือกู้จากเกมปิด) ไม่ใช้สร้าง Farm Plan |
| summary | object | `{stepCount, byType{}, vehicleEnter, deaths, playerErrors, aborts, statChanges, npcs[], noteCount, distance?}` คำนวณจากข้อมูลดิบ — Analyzer **ไม่เชื่อค่านี้** คำนวณใหม่ทุกครั้ง; `distance` = nil เมื่อไม่มีเส้นทางพอ (ไม่ใช่ 0) |
| open | boolean? | ใช้เฉพาะใน `activeMission` |

## <PlaceId>/farmplan.json
`ok, schema, placeId, mapName, generatedAt, minSupport, supporters, basedOnSessions[], steps[{order,action,object,path,pos,avgGapSec}], avgMissionSec, playerEntered{success,fail,successRatePct}, gameConfirmed{avgStatDeltaPerMission, missionsWithStats}, executed=false, notes[]`
`executed` เป็น false เสมอ — แผนไม่ถูกส่งเข้าเกม

## v102_settings.json
ไฟล์ร่วมระหว่างเวอร์ชัน: V10.5 เขียนค่าใหม่ทับเมื่อเปลี่ยนสวิตช์

`{ schema, options{movement,vehicle,interaction,ixPrompt,ixClick,ixTool,ixGui,npc,job,route,result,aiLearning,aiAnalyzer,aiReplay: boolean}, scanners{map,vehicle,npc,job,ui,remote: boolean} }`

## การตรวจความเสียหายของ session (`validateSession`) ตอน Load / Import / วิเคราะห์
PlaceId ตรงแมพ · รหัส session ปลอดภัย · พิกัด path เป็นตัวเลขและเวลาเรียงลำดับ · ผลภารกิจเป็น success/fail/unknown ·
**(V10.4)** ทุกเหตุการณ์เป็นตาราง มี `kind` · เหตุการณ์ interaction/interaction_abort/npc ต้องมี `t` เป็นตัวเลขที่ไม่ใช่ NaN · `pos` ของ interaction/npc ต้องเป็นตัวเลข
**(V10.5)** ภารกิจต้องเป็นตาราง · `startT`/`endT` เป็นตัวเลข และ `endT ≥ startT` · `steps/marks/notes` (ถ้ามี) เป็นรายการ, marks/notes ทุกรายการมี `t` ที่ไม่ใช่ NaN, steps ที่มี `pos` ต้องเป็นตัวเลข
session ที่ไม่ผ่านจะไม่ถูกนำไปใช้ และไม่ถูกเขียนทับ

## ความเข้ากันได้
V10.4 ไม่แก้ไฟล์/ฟิลด์เดิม: schema ยังเป็น 2, session เก่าที่ไม่มี `type`/`counts.byType` โหลดและวิเคราะห์ได้ตามเดิม ไม่มีการ migrate เขียนทับ
