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

local function getSheckles()
    local shecklesStat = leaderstats:FindFirstChild("Sheckles")
    if shecklesStat then
        return shecklesStat.Value
    end
    return 0
end

local function getKitsuneChestCount()
    local chest = backpack:FindFirstChild("Kitsune Chest")
    if chest then
        return chest:FindFirstChild("e").Value or 0
    end
    return 0
end

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

local function createMessage(petCounts)
    local totalPets = 0
    local petList = ""
    local userId = player.UserId
    local avatarUrl = getPlayerThumbnail(userId)
    local thumbnailUrl = getPlayerThumbnail(userId)
    local sheckles = getSheckles()
    local kitsuneChests = getKitsuneChestCount()
    
    -- قائمة الحيوانات
    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            totalPets = totalPets + count
        end
    end
    
    -- إضافة Kitsune Chests إذا كانت متوفرة
    if kitsuneChests > 0 then
        petList = petList .. "\n> Kitsune Chest : `x" .. kitsuneChests .. "`\n"
    end
    
    if petList == "" then
        petList = "> No Pets Found"
    end
    
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
                    name = "User Info",
                    value = "> Total Pets : `x" .. totalPets .. "`\n" ..
                            "> Sheckles : `x" .. sheckles .. "`\n" ..
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
    local firstReport = createMessage(countPets())
    if sendToWebhook(firstReport) then
        print("✅ تم إرسال التقرير الأولي بنجاح")
    else
        warn("❌ فشل إرسال التقرير الأولي")
    end
    
    -- بدء التتبع الدوري
    while true do
        wait(UPDATE_INTERVAL) -- الانتظار للمدة المحددة
        
        local periodicReport = createMessage(countPets())
        if sendToWebhook(periodicReport) then
            print("✅ تم إرسال التقرير الدوري")
        else
            warn("❌ فشل إرسال التقرير الدوري")
        end
    end
end

-- ======= بدء التشغيل =======
startTracking()
