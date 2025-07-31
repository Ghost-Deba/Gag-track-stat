local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local http = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل ساعة (3600 ثانية)
local WEBHOOK_NAME = "Ghost Pet Tracker"

-- قائمة الحيوانات الأليفة مع التحقق من الأسماء الدقيقة
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"
}

local function debugPrint(...)
    print("[DEBUG]", ...)
end

local function getPlayerThumbnail(userId)
    local success, response = pcall(function()
        return game:HttpGet("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..userId.."&size=420x420&format=Png")
    end)
    
    if success then
        local data = http:JSONDecode(response)
        if data and data.data and data.data[1] then
            return data.data[1].imageUrl
        end
    end
    return "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=420&height=420&format=png"
end

local function countItems()
    local petCounts = {}
    local kitsuneChestCount = 0
    
    -- تهيئة العدادات
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end
    
    debugPrint("بدء عد العناصر في الحقيبة...")
    debugPrint("عدد العناصر في الحقيبة:", #backpack:GetChildren())
    
    -- عد العناصر
    for _, item in ipairs(backpack:GetChildren()) do
        debugPrint("فحص العنصر:", item.Name)
        
        -- عد صناديق Kitsune Chest
        if item.Name:find("Kitsune Chest %[x%d+%]") then
            local count = tonumber(item.Name:match("%[x(%d+)%]")) or 1
            kitsuneChestCount = kitsuneChestCount + count
            debugPrint("تم العثور على Kitsune Chest، العدد:", count)
        else
            -- عد الحيوانات الأليفة بدقة
            for _, petName in ipairs(petNames) do
                if item.Name == petName then
                    petCounts[petName] = petCounts[petName] + 1
                    debugPrint("تم العثور على حيوان أليف:", petName, "العدد الجديد:", petCounts[petName])
                    break
                end
            end
        end
    end
    
    debugPrint("انتهى العد. عدد صناديق Kitsune Chest:", kitsuneChestCount)
    return petCounts, kitsuneChestCount
end

local function createMessage(petCounts, kitsuneChestCount)
    local totalPets = 0
    local petList = ""
    local chestList = ""
    local userId = player.UserId
    local avatarUrl = getPlayerThumbnail(userId)
    local thumbnailUrl = getPlayerThumbnail(userId)
    
    -- قائمة الحيوانات الأليفة
    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            totalPets = totalPets + count
        end
    end
    
    if petList == "" then
        petList = "> No Pets Found"
    end
    
    -- قائمة الصناديق
    if kitsuneChestCount > 0 then
        chestList = "> Kitsune Chest : `x" .. kitsuneChestCount .. "`\n"
    end
    
    -- إنشاء رسالة الديسكورد
    local embed = {
        title = "🐾 Pets In Inventory",
        description = petList,
        color = 0x00FF00,
        thumbnail = {
            url = thumbnailUrl
        },
        fields = {
            {
                name = "User Info",
                value = "> Total Pets : `x" .. totalPets .. "`\n> Account : ||" .. player.Name .. "||",
                inline = false
            }
        },
        footer = {
            text = ("Last Update : ") .. os.date("%Y-%m-%d %H:%M:%S")
        }
    }
    
    -- إضافة قسم الصناديق إذا وجدت
    if kitsuneChestCount > 0 then
        table.insert(embed.fields, {
            name = "📦 Chests",
            value = chestList,
            inline = false
        })
    end
    
    return {
        username = WEBHOOK_NAME,
        avatar_url = avatarUrl,
        embeds = {embed}
    }
end

local function sendToWebhook(data)
    if not getgenv().config or not getgenv().config.WEBHOOK_URL then
        warn("⛔ لم يتم تعيين رابط الويب هوك")
        return false
    end
    
    local success, json = pcall(http.JSONEncode, http, data)
    if not success then
        warn("❌ فشل في ترميز بيانات JSON")
        return false
    end
    
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if not request then
        warn("❌ لم يتم العثور على دالة request متاحة")
        return false
    end
    
    local success, response = pcall(function()
        return request({
            Url = getgenv().config.WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
    end)
    
    if not success then
        warn("❌ فشل في إرسال الطلب:", response)
        return false
    end
    
    if response.Success then
        print("✅ تم إرسال البيانات بنجاح")
        return true
    else
        warn("❌ فشل إرسال الويب هوك. رمز الحالة:", response.StatusCode)
        return false
    end
end

local function startTracking()
    print("🚀 بدء تتبع الحيوانات الأليفة والصناديق...")
    
    -- إرسال التقرير الأولي فور التشغيل
    local petCounts, kitsuneChestCount = countItems()
    local firstReport = createMessage(petCounts, kitsuneChestCount)
    
    debugPrint("البيانات المرسلة:", http:JSONEncode(firstReport))
    
    if sendToWebhook(firstReport) then
        print("✅ تم إرسال التقرير الأولي بنجاح")
    else
        warn("❌ فشل إرسال التقرير الأولي")
    end
    
    -- بدء التتبع الدوري
    while true do
        wait(UPDATE_INTERVAL)
        
        print("🔄 إرسال التقرير الدوري...")
        local petCounts, kitsuneChestCount = countItems()
        local periodicReport = createMessage(petCounts, kitsuneChestCount)
        
        debugPrint("البيانات المرسلة:", http:JSONEncode(periodicReport))
        
        if sendToWebhook(periodicReport) then
            print("✅ تم إرسال التقرير الدوري")
        else
            warn("❌ فشل إرسال التقرير الدوري")
        end
    end
end

-- التحقق من وجود العناصر قبل البدء
if not player or not backpack then
    warn("❌ لم يتم العثور على اللاعب أو الحقيبة")
else
    print("🎮 تم التعرف على اللاعب:", player.Name)
    startTracking()
end
