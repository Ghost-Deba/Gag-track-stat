local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
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

-- ======= الدوال المساعدة المعدلة =======
local function getPlayerImage(size, imageType)
    local success, result = pcall(function()
        return game:GetService("Players"):GetUserThumbnailAsync(
            player.UserId,
            imageType or Enum.ThumbnailType.AvatarBust,
            size or Enum.ThumbnailSize.Size100x100
        )
    end)
    return success and result or "https://i.imgur.com/J5hOFNC.png" -- صورة افتراضية إذا فشل
end

local function getPlayerAvatar()
    return getPlayerImage(Enum.ThumbnailSize.Size420x420, Enum.ThumbnailType.HeadShot)
end

local function getPlayerThumbnail()
    return getPlayerImage(Enum.ThumbnailSize.Size100x100, Enum.ThumbnailType.AvatarBust)
end

-- ======= بقية الدوال كما هي (بدون تغيير) =======
local function countPets()
    local petCounts = {}
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end
    
    for _, item in ipairs(backpack:GetChildren()) do
        for petName, _ in pairs(petCounts) do
            if string.find(item.Name, petName) then
                petCounts[petName] = petCounts[petName] + 1
            end
        end
    end
    
    return petCounts
end

local function createMessage(petCounts)
    local total = 0
    local petList = ""
    
    for petName, count in pairs(petCounts) do
        if count > 0 then
            petList = petList .. "> " .. petName .. " : `x" .. count .. "`\n"
            total = total + count
        end
    end
    
    if petList == "" then
        petList = "> No Pets Found"
    end
    
    return {
        username = WEBHOOK_NAME,
        avatar_url = getPlayerAvatar(),
        embeds = {{
            title = "🐾 Pets In Inventory",
            description = petList,
            color = 0x00FF00,
            thumbnail = {
                url = getPlayerThumbnail()
            },
            fields = {
                {
                    name = "User Info",
                    value = "> Total Pets : `x" .. total .. "`\n> Account : ||" .. player.Name .. "||",
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
