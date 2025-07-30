--[[
  Grow A Garden - Pet Tracker (Backpack only, robust)
  - ينتظر Players.LocalPlayer و Backpack
  - يلتقط Tools مباشرة داخل الـBackpack (واختياريًا أي Tools داخل Folders)
  - يحدد البت عن طريق:
      1) Attribute: ItemType == "Pet" (case-insensitive)
      2) ValueObject باسم ItemType (StringValue/ValueBase) قيمته "Pet" (case-insensitive)
  - يجمع حسب الاسم الأساسي قبل أول "["  (مثال: "Moth [15 Kg][Age 40]" -> "Moth")
  - DEBUG يطبع أسباب عدم تعرفه على أدوات معيّنة
]]--

-- إعدادات
local AUTO_REFRESH       = false     -- true لتحديث دوري
local REFRESH_EVERY      = 5         -- ثواني
local SEARCH_DESCENDANTS = false     -- true لو البِتات داخل Folders جوّه الـBackpack
local DEBUG              = true      -- يطبع تفاصيل تشخيص

-- خدمات
local Players    = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- انتظار اللاعب والـBackpack بأمان
local LP = Players.LocalPlayer
while not LP do task.wait() LP = Players.LocalPlayer end

local Backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
while not Backpack do
    if DEBUG then print("[PetTracker] في انتظار Backpack...") end
    Backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    task.wait(0.5)
end

-- إشعار/لوج
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title; Text = text; Duration = 5})
    end)
end

local function log(msg)
    if rconsoleprint then rconsoleprint(msg .. "\n") else print(msg) end
end

-- Helpers
local function toLowerSafe(s)
    if typeof(s) ~= "string" then return "" end
    return string.lower(s)
end

-- هل في ValueObject باسم ItemType وقيمته "Pet" (case-insensitive)؟
local function hasItemTypeValueObject(tool)
    local v = tool:FindFirstChild("ItemType")
    if not v then return false end
    local val
    pcall(function()
        val = v.Value
    end)
    if val == nil then return false end
    return toLowerSafe(val) == "pet"
end

-- هل في Attribute ItemType = "Pet" (case-insensitive)؟
local function hasItemTypeAttribute(tool)
    local ok, attr = pcall(function()
        return tool:GetAttribute("ItemType")
    end)
    if not ok or attr == nil then return false end
    return toLowerSafe(attr) == "pet"
end

-- تحديد إن الـTool ده pet
local function isPetTool(tool)
    if not (tool and tool:IsA("Tool")) then return false end
    if hasItemTypeAttribute(tool) then return true end
    if hasItemTypeValueObject(tool) then return true end
    return false
end

-- اسم أساسي قبل أول "[" مع تشذيب المسافات
local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function getBaseName(toolName)
    if not toolName or toolName == "" then return "Unknown" end
    local base = string.match(toolName, "^(.-)%s*%[")
    base = base or toolName
    return trim(base)
end

-- الحصول على لستة الـTools الهدف من الـBackpack
local function getCandidateTools()
    local list = {}
    if SEARCH_DESCENDANTS then
        for _, inst in ipairs(Backpack:GetDescendants()) do
            if inst:IsA("Tool") then
                table.insert(list, inst)
            end
        end
    else
        for _, inst in ipairs(Backpack:GetChildren()) do
            if inst:IsA("Tool") then
                table.insert(list, inst)
            end
        end
    end
    return list
end

local function runOnce()
    -- تحديت مرجع الـBackpack لو اتغيّر
    Backpack = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    if not Backpack then
        log("[PetTracker] Backpack غير موجود حالياً.")
        return
    end

    local counts = {}
    local total  = 0
    local unknown = {}

    for _, tool in ipairs(getCandidateTools()) do
        if isPetTool(tool) then
            local base = getBaseName(tool.Name)
            counts[base] = (counts[base] or 0) + 1
            total += 1
        elseif DEBUG then
            -- أسباب محتملة لرفض التعرّف
            local reason = {}
            if not tool:IsA("Tool") then
                table.insert(reason, "Not a Tool")
            else
                if not hasItemTypeAttribute(tool) then table.insert(reason, "No Attribute ItemType='Pet'") end
                if not hasItemTypeValueObject(tool) then table.insert(reason, "No ValueObject ItemType='Pet'") end
            end
            table.insert(unknown, string.format("%s [%s]", tool.Name or "Unnamed", table.concat(reason, ", ")))
        end
    end

    log("============== Grow A Garden | Pets (Backpack) ==============")
    if next(counts) == nil then
        log("لا يوجد Pets في الـBackpack.")
        if DEBUG and #unknown > 0 then
            log("أدوات غير مُطابقة (للمساعدة في التشخيص):")
            for _, line in ipairs(unknown) do log("  - " .. line) end
        end
        notify("Pet Tracker", "لا يوجد Pets حالياً.")
        log("=============================================================")
        return
    end

    -- ترتيب أبجدي
    local names = {}
    for baseName in pairs(counts) do table.insert(names, baseName) end
    table.sort(names, function(a,b) return a:lower() < b:lower() end)

    for _, baseName in ipairs(names) do
        log(string.format("- %s : %d", baseName, counts[baseName]))
    end
    log("-------------------------------------------------------------")
    log(string.format("الإجمالي: %d Pet(s)", total))
    log("=============================================================")
    notify("Pet Tracker", "تم التحديث. الإجمالي: " .. tostring(total))
end

-- تشغيل مرة
runOnce()

-- تحديث تلقائي (اختياري)
if AUTO_REFRESH then
    task.spawn(function()
        while true do
            task.wait(REFRESH_EVERY)
            pcall(runOnce)
        end
    end)
end
