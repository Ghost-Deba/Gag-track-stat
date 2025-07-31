local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local leaderstats = player:WaitForChild("leaderstats")
local http = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل ساعة (3600 ثانية)
local WEBHOOK_NAME = "Ghost Pet Tracker"

-- ======= قائمة الحيوانات الأليفة =======
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"
}

-- ======= الدوال المساعدة =======
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

-- دالة لتنسيق الأرقام (1k, 1m, 1b, 1t, 1qa)
local function formatNumber(num)
    if not num then return "0" end
    
    local suffixes = {"", "k", "m", "b", "t", "qa"}
    local suffixIndex = 1
    
    while num >= 1000 and suffixIndex < #suffixes do
        num = num / 1000
        suffixIndex = suffixIndex + 1
    end
    
    if suffixIndex == 1 then
        return tostring(math.floor(num))
    end
    
    return string.format("%.1f%s", math.floor(num * 10) / 10, suffixes[suffixIndex])
end

-- دالة لحساب عدد الحيوانات الأليفة
local function countPets()
    local petCounts = {}
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end
    
    for _, item in ipairs(backpack:GetChildren()) do
        local itemName = item.Name
        for petName, _ in pairs(petCounts) do
            -- مطابقة دقيقة مع بداية ونهاية الاسم
            if string.match(itemName, "^"..petName.."$") or 
               string.match(itemName, "^"..petName.." %[") or 
               string.match(itemName, " "..petName.."$") then
                petCounts[petName] = petCounts[petName] + 1
            end
        end
    end
    
    return petCounts
end

-- دالة للحصول على عدد صناديق Kitsune
-- دالة محسنة للحصول على عدد صناديق Kitsune
local function getKitsuneChestCount()
    local total = 0
    print("\n[بحث] جاري فحص صناديق كيتسون...")
    
    for _, item in ipairs(backpack:GetChildren()) do
        if item.Name:lower():find("kitsune chest") then
            -- الطريقة الدقيقة لاستخراج العدد من النمط: [X359] أو [359]
            local quantityStr = item.Name:match("%[X?(%d+)%]")
            
            if quantityStr then
                local quantity = tonumber(quantityStr)
                print("✅ وجدت:", item.Name, "-> الكمية:", quantity)
                total = total + quantity
            else
                print("⚠️ صندوق بدون كمية محددة:", item.Name)
                total = total + 1
            end
        end
    end
    
    print("📊 الإجمالي:", total)
    return total
end

-- دالة للحصول على عدد الـ Sheckles
local function getSheckles()
    local shecklesStat = leaderstats:FindFirstChild("Sheckles")
    if shecklesStat then
        return shecklesStat.Value or 0
    end
    return 0
end

local function createMessage(petCounts, kitsuneCount, sheckles)
    local totalPets = 0
    local petList = ""
    local userId = player.UserId
    local avatarUrl = getPlayerThumbnail(userId)
    local thumbnailUrl = getPlayerThumbnail(userId)
    
    -- إنشاء قائمة الحيوانات الأليفة
    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            totalPets = totalPets + count
        end
    end
    
    if petList == "" then
        petList = "> No Pets Found"
    end
    
    -- تنسيق عدد الـ Sheckles
    local formattedSheckles = formatNumber(sheckles)
    
    return {
        username = WEBHOOK_NAME,
        avatar_url = avatarUrl,
        embeds = {{
            title = "🐾 Pets In Inventory",
            description = petList,
            color = 0x00FF00,
            thumbnail = {
                url = thumbnailUrl
            },
            fields = {
                    {
                    name = "Event",
                    value = "> Kitsune Chest: `x" .. kitsuneCount .. "`\n" ..
                    inline = false
                    }
                {
                    name = "User Info",
                    value = "> Total Pets : `x" .. totalPets .. "`\n" ..
                            "> Sheckles : `" .. formattedSheckles .. "`\n" ..
                            "> Account : ||" .. player.Name .. "||",
                    inline = false
                }
            },
            footer = {
                text = ("Last Update : ") .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

local function sendToWebhook(data)
    if not getgenv().config or not getgenv().config.WEBHOOK_URL then
        warn("⛔ لم يتم تعيين رابط الويب هوك")
        return false
    end
    
    local success, json = pcall(http.JSONEncode, http, data)
    if not success then return false end
    
    local request = (syn and syn.request) or http_request or request
    if not request then return false end
    
    local response = request({
        Url = getgenv().config.WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = json
    })
    
    return response.Success
end

-- ======= الدالة الرئيسية =======
local function startTracking()
    -- إرسال التقرير الأولي فور التشغيل
    local firstReport = createMessage(
        countPets(),
        getKitsuneChestCount(),
        getSheckles()
    )
    
    if sendToWebhook(firstReport) then
        print("✅ تم إرسال التقرير الأولي بنجاح")
    else
        warn("❌ فشل إرسال التقرير الأولي")
    end
    
    -- بدء التتبع الدوري
    while true do
        wait(UPDATE_INTERVAL) -- الانتظار للمدة المحددة
        
        local periodicReport = createMessage(
            countPets(),
            getKitsuneChestCount(),
            getSheckles()
        )
        
        if sendToWebhook(periodicReport) then
            print("✅ تم إرسال التقرير الدوري")
        else
            warn("❌ فشل إرسال التقرير الدوري")
        end
    end
end

-- ======= بدء التشغيل =======
startTracking()
