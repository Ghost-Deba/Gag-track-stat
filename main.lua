local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local http = game:GetService("HttpService")
local UPDATE_INTERVAL = 3600 -- كل 60 ثانية

-- قائمة الحيوانات الأليفة
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee","Kitsune","Corrupted Kitsune"
}

-- الحصول على صورة اللاعب
local function getPlayerAvatar()
    return "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
end

-- عد الحيوانات
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

-- إنشاء محتوى الرسالة (بدون الحيوانات التي عددها صفر)
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
            title = "🐾 Pet Statistics",
            description = total > 0 and ("Total Pets: "..total) or "No pets found!",
            color = 0x00FF00,
            fields = fields,
            footer = {
                text = "Last update: "..os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

-- إرسال البيانات إلى الويب هوك
local function sendToWebhook(data)
    local success, json = pcall(http.JSONEncode, http, data)
    if not success then return false end
    
    if syn and syn.request then
        local response = syn.request({
            Url = getgenv().config.WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
        return response.Success
    else
        -- Fallback to HttpService
        local success, response = pcall(function()
            return http:PostAsync(getgenv().config.WEBHOOK_URL, json, Enum.HttpContentType.ApplicationJson)
        end)
        return success and response ~= nil
    end
end

-- الدالة الرئيسية
local function startTracking()
    while true do
        local counts = countPets()
        local message = createMessage(counts)
        
        if sendToWebhook(message) then
            print("تم تحديث الإحصائيات بنجاح!")
        else
            warn("فشل في إرسال البيانات")
        end
        
        wait(UPDATE_INTERVAL)
    end
end

-- بدء التشغيل
startTracking()
