# รายงานเปรียบเทียบ V9 กับ V10.2

## 1. ไฟล์ที่ได้
`BALL_KUN_AI_FARM_V10_2.lua` = V9 ทั้งไฟล์ + บล็อก "V10.2 MODULE" (≈1,620 บรรทัด) ที่แทรกก่อนตาราง `TABS`
ผลเทียบกับ V9 ด้วย diff: **ไม่มีบรรทัดของ V9 ถูกลบ** มีบรรทัดเดิมถูกแก้ 4 จุด และเพิ่มบรรทัดใหม่

| จุดที่แก้ใน V9 | เหตุผล |
|---|---|
| `VERSION = "9.0"` → `"10.2"` | แสดงเวอร์ชันใหม่ในไฟล์สแกนและ log |
| `local TABS = {` → `local TABS_V9 = {` + `local TABS = ScanMgr.V102.tabs` | เมนูหลักเหลือ 8 แท็บ ส่วน 10 หน้าเดิมเก็บไว้ใน `ALL_TABS` |
| `showTab("dash")` → `showTab("v_dash")` | เริ่มที่ Dashboard ใหม่ |
| `ENV.BALLKUN_SCANNER = {...}` เพิ่ม `V102 = ScanMgr.V102` | เปิดให้เข้าถึงผ่านโค้ด |
| `Destroy()` เพิ่ม `ScanMgr.V102.shutdown()` และ `ENV.BALLKUN_V102 = nil` | หยุดบันทึกและตัด connection ของ V10.2 |

## 2. ระบบ V9 ที่ตรวจว่ายังอยู่
Map / NPC / Vehicle / Job / UI / Remote Scanner, Auto Dump, Smart Dump, Game Profile, Diag (ตรวจระบบ/ทดสอบตัวเอง/JSON), ErrLog, Recovery (REC + recoveryInfo), ระบบไฟล์และสำรอง, Settings/Palette/Font — ตรวจด้วยการเทียบชื่อฟังก์ชันและ diff กับไฟล์ต้นฉบับ (ไม่ใช่การรัน)

## 3. ระบบ V10.1 ที่รวมแล้ว และการเชื่อมกับ V9
| ระบบ V10.1 | สถานะใน V10.2 | จุดเชื่อมกับ V9 |
|---|---|---|
| Dual Mode Core | รวมแล้ว (Rec / Replay / validateSession) | ใช้ `ScanMgr`, `Diag.watch`, `logf` |
| Manual Learning | รวมแล้ว (+ Pause/Resume/Continue/Autosave) | UI ใช้ `card/btn/switch` ของ V9 |
| Movement / Vehicle / Interaction / Job / Route / Result Recorder | รวมแล้ว, สวิตช์แยกทุกตัว | — |
| Session Manager | รวมแล้ว (+ กัน ID อันตราย, จำกัดรายการ) | โฟลเดอร์ `AI_FOLDER` เดียวกับ Smart Dump |
| AI Analyzer | รวมแล้ว + เพิ่ม Farm Plan, ความสอดคล้อง, แยกเกม/ผู้เล่น/อนุมาน | สวิตช์ AI Analyzer ใหม่ |
| Replay Simulator | รวมแล้ว (Simulation เท่านั้น) | ผูกสวิตช์ AI Replay |
| UI แยกหน้าต่าง V10.1 | **แทนที่ด้วยแท็บใน UI เดียวของ V9** | — |
| Tests | รวมแล้ว + เพิ่มทดสอบ Multi Map / Switches | ปุ่ม RUN TESTS ในแท็บ Settings |

## 4. ปัญหาของ V10.1 ที่แก้ระหว่างรวม
- global รั่ว `Analyzer`, `Session_load` → ย้ายเข้า namespace
- ชื่อฟังก์ชันชนกับ V9 (`connect`, `ensureDir`, `sget`) → ใช้ชื่อเฉพาะ (`rconn`, `mkdirs`, `sg`)
- autosave thread ซ้ำเมื่อกดหยุด-เริ่มเร็ว → ใช้ token
- connection ของตัวละครเก่าค้างทุกครั้งที่เกิดใหม่ → ตัดทิ้งเมื่อเกิดใหม่
- `counts` รีเซ็ตเป็น 0 ตอนบันทึกต่อ → นับจากข้อมูลเดิม
- รับ session ID/ path อะไรก็ได้ → จำกัดตัวอักษรของ ID
- `Rec.stop` ผูกกับ AI Learning → แยกเป็น AI Analyzer (วิเคราะห์) และ AI Learning (ใช้เรียนรู้)

## 5. ที่เพิ่มใหม่ตามสเปก
Multi Map (map_db.json, maps_index.json, กันข้ามแมพ) · ผลที่เกมยืนยันจาก leaderstats · Farm Plan · รายงานความสอดคล้อง · สวิตช์ 12 ตัว (+3 ตัวเสริม) · Loader · Schema

## 6. การตรวจก่อนส่ง — ทำอะไรไปแล้ว / ยังไม่ได้ทำ
| รายการ | สถานะ |
|---|---|
| สมดุล `function/if/do/repeat ... end` และวงเล็บ (สคริปต์ตรวจเอง) | ผ่านทั้ง V9 ต้นฉบับและไฟล์รวม |
| **Syntax Lua จริง (parser)** | **ยังไม่ได้ตรวจ** — เครื่องที่ใช้สร้างไม่มี luac/luau และติดตั้งไม่ได้ |
| ชื่อฟังก์ชันซ้ำในโมดูล | ไม่พบ |
| global รั่ว / ตัวแปรไม่ได้ประกาศในโมดูล | ไม่พบ (ตรวจด้วยสคริปต์แบบประมาณ) |
| ตัวแปร upvalue ที่โมดูลอ้างจาก V9 | ประกาศก่อนจุดแทรกครบทุกตัว |
| เพดาน local ต่อฟังก์ชัน (200) | V9 ≈177 + 1 ตัวที่เพิ่ม; โมดูลอยู่ในฟังก์ชันของตัวเอง |
| Event connections / Memory leaks | ตรวจด้วยการอ่านโค้ดเท่านั้น (ตัดครบใน `Rec.stop`/`shutdown`) **ยังไม่ได้วัดจริง** |
| Save / Load, ทดสอบแต่ละโมดูล | **ยังไม่ได้รัน** — มีปุ่ม RUN TESTS ให้ทดสอบในเกม |
| ใช้งานในเกมจริง | **ยังไม่ได้ทดสอบ** |

## 7. ความเสี่ยงที่ควรดูเมื่อทดสอบครั้งแรก
1. ถ้าสคริปต์ไม่ขึ้นเลย ให้ดูข้อความ compile error จาก Loader ก่อน (ยังไม่เคยผ่าน parser จริง)
2. ปุ่ม/หน้าใหม่ที่พังจะถูกจับโดย `btn`/`showTab` และไปอยู่ในแท็บ Logs
3. `HttpService:JSONEncode` ไม่รับ key ที่ไม่ใช่ string/ลำดับ — ถ้า Farm Plan บันทึกไม่ได้ ดู Logs
