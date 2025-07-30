-- ======= الإعدادات الأساسية =======
local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local http = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل ساعة

-- ======= تكوين الويب هوك =======
if not getgenv().config then
    getgenv().config = {
        WEBHOOK_URL = "https://discord.com/api/webhooks/1400070454235893880/6j4c4REzFxGPHQeD4QsJpo96UyT1WcI2LDmehXKy1q0GEp3MKElsA0e0XLLmKYGH2O23"
    }
end

-- ======= قائمة الحيوانات الأليفة =======
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"
}

-- ======= الدوال الأساسية =======

local function getPlayerAvatar()
    return "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
end

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
    local fields = {}
    local total = 0
    
    for petName, count in pairs(petCounts) do
        if count > 0 then
            table.insert(fields, {
                name = petName,
                value = count,
                inline = true
            })
            total = total + count
        end
    end
    
    return {
        username = player.Name .. " | Pet Tracker",
        avatar_url = getPlayerAvatar(),
        embeds = {{
            title = "🐾 إحصائيات الحيوانات",
            description = total > 0 and ("المجموع: "..total) or "لا توجد حيوانات",
            color = 0x00FF00,
            fields = fields,
            footer = {
                text = "آخر تحديث: "..os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

local function sendToWebhook(data)
    if not getgenv().config.WEBHOOK_URL then
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

-- ======= التشغيل الرئيسي =======
local function startTracking()
    while true do
        local counts = countPets()
        local message = createMessage(counts)
        
        if sendToWebhook(message) then
            print("✅ تم إرسال الإحصائيات بنجاح")
        else
            warn("❌ فشل في إرسال البيانات")
        end
        
        wait(UPDATE_INTERVAL)
    end
end

-- بدء التشغيل
startTracking()
