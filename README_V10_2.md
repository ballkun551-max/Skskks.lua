# BALL KUN AI FARM V10.2 — README

V9 เป็นฐานหลัก (ระบบเดิมอยู่ครบ) + ต่อเติมระบบจาก V10.1 ในไฟล์เดียว
**สถานะ: ยังไม่ได้ทดสอบในเกมจริง** ดูรายงานเปรียบเทียบสำหรับสิ่งที่ตรวจแล้วและยังไม่ได้ตรวจ

## ติดตั้ง
1. วาง `BALL_KUN_AI_FARM_V10_2.lua` ในโฟลเดอร์ workspace ของตัวรัน
2. รัน `BALL_KUN_AI_FARM_V10_2_Loader.lua` (หรือรันไฟล์หลักตรง ๆ ก็ได้)
3. เปิด/ปิดหน้าต่าง: `RightControl` หรือปุ่ม BK | สั่งผ่านโค้ด: `BK("สแกนทั้งหมด")` | API: `getgenv().BALLKUN_V102`

## UI (หน้าต่างเดียว 8 แท็บ)
Dashboard · Scanner · Manual Learning · AI Analyzer · Session Manager · Replay · Settings · Logs
หน้าเดิมของ V9 ทั้ง 10 หน้ายังอยู่ เข้าได้จากปุ่มนำทางในแท็บ Scanner / AI Analyzer / Settings / Dashboard

## ปุ่มหลัก
START SCAN · START RECORDING · PAUSE · RESUME · STOP RECORDING · SAVE SESSION · LOAD SESSION · ANALYZE DATA

- START SCAN รันเฉพาะ Scanner ที่เปิดสวิตช์ไว้ (อ่านอย่างเดียว) ไม่ใช่ Auto Dump ที่เดินตัวละคร
- START RECORDING: ช่อง "ID session" ว่าง = เริ่มใหม่ / ใส่ ID = บันทึกต่อจาก session เดิม
- LOAD SESSION: ช่อง ID ว่าง = โหลดอันล่าสุดของแมพนี้

## สวิตช์ (ทุกตัวมีผลจริงและจำค่าไว้ใน v102_settings.json)
| สวิตช์ | ผล |
|---|---|
| Map / NPC / Vehicle / Job (+UI, Remote) Scanner | ปิด = ถูกข้ามตอนกดสแกน (ผ่าน `ScanMgr.enabled` ของ V9) |
| Interaction Recorder | บันทึกเฉพาะปุ่ม/คลิกที่ผู้เล่นกดเอง |
| Movement Recorder | บันทึกตำแหน่ง (ปิด = ไม่เก็บ path) |
| Vehicle Recorder | บันทึกการนั่ง/ลงรถ |
| Route Recorder | เส้นทางแบบย่อ |
| Result Recorder | ผลภารกิจ + ค่า leaderstats (ปิด = ผลเป็น unknown) |
| AI Learning | session นี้ถูกใช้เป็นข้อมูลเรียนรู้หรือไม่ (Farm Plan/Replay ใช้เฉพาะที่เปิดไว้) |
| AI Analyzer | วิเคราะห์อัตโนมัติเมื่อหยุดบันทึก และเปิดปุ่ม ANALYZE / Farm Plan / ความสอดคล้อง |
| AI Replay | เปิดการวางแผน/จำลอง |
Job Recorder (ขั้นตอนภารกิจ) ก็มีสวิตช์ในแท็บ Manual Learning

## ข้อมูลสามประเภท (แยกชัดในรายงาน)
- **ยืนยัน (เกม)**: เหตุการณ์ที่ตรวจจับได้จริง เช่น ProximityPrompt, ClickDetector, SeatPart, ค่า leaderstats, ตัวละครตาย
- **ผู้เล่นป้อน**: อาชีพ ชื่อภารกิจ ผลสำเร็จ/ล้มเหลว ข้อผิดพลาดที่กดบันทึกเอง
- **ยังไม่ยืนยัน (อนุมาน)**: เช่น ลำดับขั้นตอนเป็นลำดับเวลา ไม่ใช่ลำดับที่เกมกำหนด

## Multi Map
- ตรวจ `game.PlaceId` ตอนเริ่ม: แมพใหม่สร้าง `BALL_KUN_AI_Dump/<PlaceId>/map_db.json` อัตโนมัติ
- ทุกการอ่าน/เขียน session ผูกกับ PlaceId ปัจจุบัน; session ต่าง PlaceId ถูกปฏิเสธทั้งตอน Load / Import / วิเคราะห์

## ความปลอดภัย
- ไม่สุ่มชื่อ Remote / ไม่เรียก FireServer-InvokeServer จากระบบบันทึกและ Replay
- Recorder ไม่กดปุ่ม ไม่เดินตัวละคร ไม่สร้างผลลัพธ์เอง
- Replay เป็น Simulation เท่านั้น (`Replay.execute` ปิดไว้เสมอ)
- ปุ่ม ⚡ Auto Dump ของ V9 (หน้า "ศูนย์ควบคุม V9") ยังเป็นพฤติกรรมเดิมของ V9 ที่เดินสำรวจและคลิก UI — แยกจากระบบบันทึก

## ข้อจำกัดที่ทราบ
- ยังไม่ได้รันในเกมจริง ต้องทดสอบด้วยปุ่ม RUN TESTS (แท็บ Settings) และเล่นจริงหนึ่งรอบ
- V9 ยังไม่มี Shop Scanner (แท็บ Shop แสดงว่ายังไม่สร้าง) — ไม่ได้อยู่ในขอบเขตงานนี้
- "ผลลัพธ์ที่ตรวจสอบได้" ทำได้เฉพาะแมพที่มี `leaderstats` ของผู้เล่น
- Session.list อ่านสูงสุด 60 รายการล่าสุด; เพดานต่อ session: 20,000 จุด / 5,000 เหตุการณ์
