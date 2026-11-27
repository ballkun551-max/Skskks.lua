# Database Schema — BALL KUN AI FARM V10.2

ทุกไฟล์เป็น JSON (UTF-8) อยู่ในโฟลเดอร์ workspace ของตัวรัน ข้อมูลแยกตาม PlaceId และห้ามข้ามแมพ

## โครงโฟลเดอร์
```
BALL_KUN_Dump/                         ← ของ V9 (ผลสแกน, settings.json, diagnostics)
BALL_KUN_AI_Dump/
  maps_index.json                      ← รายการ PlaceId ที่เคยใช้
  v102_settings.json                   ← ค่าสวิตช์ทั้งหมดของ V10.2
  exports/<PlaceId>_<sessionId>.json   ← session ที่ส่งออก (ไม่เขียนทับ)
  <PlaceId>/
    map_db.json                        ← DB ของแมพ (สร้างอัตโนมัติเมื่อเจอแมพใหม่)
    farmplan.json                      ← Farm Plan ล่าสุด
    profile.json, jobs.json, ...       ← ไฟล์ Smart Dump / Game Profile ของ V9 (ไม่เปลี่ยน)
    sessions/<sessionId>.json          ← session ที่บันทึก
    sessions/<sessionId>_report.txt    ← รายงาน AI Analyzer
```
`sessionId` ต้องเป็น `A-Z a-z 0-9 _ -` เท่านั้น (กัน path หลุดโฟลเดอร์)

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
| schema, version | number, string | 2 / "10.2" |
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
| counts, sizeBytes, capped | | สถิติ |

### events[] (ทุกรายการมี `t` = วินาทีนับจากเริ่ม, `kind`)
| kind | ฟิลด์เพิ่ม | แหล่งข้อมูล |
|---|---|---|
| interaction | action, object, path, pos[x,y,z] | เกม (ProximityPrompt / ClickDetector ที่ผู้เล่นกดเอง) |
| vehicle | action = enter/exit, seat, class, pos | เกม (Humanoid.SeatPart) |
| result | src="game", stat, value, delta | เกม (leaderstats ของผู้เล่น) |
| mission | action = start/end, name, result, note | ผู้เล่นกดปุ่มเอง |
| error | src = game / player / system, note, corrected? | เกม (ตัวละครตาย) / ผู้เล่น / ระบบ |
| system | note | ระบบ (เริ่ม/หยุด/pause/resume) |

### missions[]
`name, startT, endT, duration, profession, steps[{t,action,object,path,pos}], result ("success"|"fail"|"unknown"), resultSource="player", note, statsDelta?{stat=delta}`
- `result` = **ผู้เล่นป้อน** ไม่ใช่ผลที่เกมยืนยัน
- `statsDelta` = **เกมยืนยัน** (ผลต่างของ leaderstats ระหว่างเริ่ม-จบภารกิจ) มีเฉพาะเมื่อค่าเปลี่ยนจริง

## <PlaceId>/farmplan.json
`ok, schema, placeId, mapName, generatedAt, minSupport, supporters, basedOnSessions[], steps[{order,action,object,path,pos,avgGapSec}], avgMissionSec, playerEntered{success,fail,successRatePct}, gameConfirmed{avgStatDeltaPerMission, missionsWithStats}, executed=false, notes[]`
`executed` เป็น false เสมอ — แผนไม่ถูกส่งเข้าเกม

## v102_settings.json
`{ schema, options{movement,vehicle,interaction,job,route,result,aiLearning,aiAnalyzer,aiReplay: boolean}, scanners{map,vehicle,npc,job,ui,remote: boolean} }`
