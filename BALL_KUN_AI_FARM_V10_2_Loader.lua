--[[ BALL KUN AI FARM V10.2 — Loader
วิธีใช้: วาง BALL_KUN_AI_FARM_V10_2.lua ไว้ในโฟลเดอร์ workspace ของตัวรัน แล้วรันไฟล์นี้
ทางเลือก: ตั้ง getgenv().BALLKUN_SOURCE_URL = "<ลิงก์ไฟล์ของคุณเอง>" ก่อนรัน เพื่อโหลดจากลิงก์แทน
Loader นี้ไม่มีลิงก์ฝังไว้ และไม่ส่งข้อมูลออกไปไหน
]]
local ENV = (getgenv and getgenv()) or _G
local FILE = "BALL_KUN_AI_FARM_V10_2.lua"

if ENV.BALLKUN_LOADING then
    warn("[BALL KUN LOADER] กำลังโหลดอยู่แล้ว ข้ามการรันซ้ำ")
    return
end
ENV.BALLKUN_LOADING = true

local function finish() ENV.BALLKUN_LOADING = nil end

local function fetchSource()
    local url = ENV.BALLKUN_SOURCE_URL
    if type(url) == "string" and url ~= "" then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" and #res > 1000 then return res, "url" end
        return nil, "โหลดจากลิงก์ไม่สำเร็จ: " .. tostring(res)
    end
    if type(readfile) ~= "function" then return nil, "ตัวรันไม่มี readfile และไม่ได้ตั้ง BALLKUN_SOURCE_URL" end
    if type(isfile) == "function" and not isfile(FILE) then return nil, "ไม่พบไฟล์ " .. FILE .. " ในโฟลเดอร์ workspace" end
    local ok, res = pcall(readfile, FILE)
    if ok and type(res) == "string" and #res > 1000 then return res, "file" end
    return nil, "อ่านไฟล์ไม่สำเร็จ: " .. tostring(res)
end

local src, how = fetchSource()
if not src then
    warn("[BALL KUN LOADER] " .. tostring(how))
    finish()
    return
end

local loader = loadstring or load
if type(loader) ~= "function" then
    warn("[BALL KUN LOADER] ตัวรันไม่มี loadstring")
    finish()
    return
end

local fn, compileErr = loader(src, "=BALL_KUN_AI_FARM_V10_2")
if not fn then
    warn("[BALL KUN LOADER] ไฟล์หลักคอมไพล์ไม่ผ่าน: " .. tostring(compileErr))
    finish()
    return
end

local ok, err = xpcall(fn, debug.traceback)
finish()
if not ok then
    warn("[BALL KUN LOADER] ไฟล์หลักทำงานผิดพลาด:\n" .. tostring(err))
else
    print("[BALL KUN LOADER] โหลด V10.2 สำเร็จ (" .. how .. ") เปิด/ปิด UI: RightControl หรือปุ่ม BK")
end
