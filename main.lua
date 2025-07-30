local player = game:GetService("Players").LocalPlayer
local backpack = player:WaitForChild("Backpack")
local http = game:GetService("HttpService")

-- Configuration in getgenv()
if not getgenv().config then
    getgenv().config = {
        WEBHOOK_URL = "https://discord.com/api/webhooks/your_webhook_id/your_webhook_token",
        MESSAGE_ID = "123456789012345678" -- Replace with your message ID
    }
end

local UPDATE_INTERVAL = 60 -- Update interval in seconds (minimum 5)

-- List of all pet names to track
local petNames = {
    "Starfish","Crab","Seagull","Bunny","Dog","Golden Lab","Bee","Shiba Inu","Maneki-neko",
    "Flamingo","Toucan","Sea Turtle","Orangutan","Seal","Honey Bee","Wasp","Nihonzaru","Grey Mouse",
    "Tarantula Hawk","Kodama","Corrupted Kodama","Caterpillar","Snail","Petal Bee","Moth","Scarlet Macaw",
    "Ostrich","Peacock","Capybara","Tanuki","Tanchozuru","Raiju","Brown Mouse","Giant Ant","Praying Mantis",
    "Red Giant Ant","Squirrel","Bear Bee","Butterfly","Pack Bee","Mimic Octopus","Kappa","Koi","Red Fox",
    "Dragonfly","Disco Bee","Queen Bee (Pet)","Kitsune","Corrupted Kitsune"
    -- Add more as needed
}

-- Fixed avatar function using Roblox API
local function getPlayerAvatar()
    return "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
end

-- Verify webhook URL format
local function isValidWebhook(url)
    return url and string.find(url, "https://discord.com/api/webhooks/") == 1
end

-- Count pets in backpack
local function countPets()
    local petCounts = {}
    
    -- Initialize counts
    for _, petName in ipairs(petNames) do
        petCounts[petName] = 0
    end
    
    -- Scan backpack
    for _, item in ipairs(backpack:GetChildren()) do
        for petName, _ in pairs(petCounts) do
            if string.find(item.Name, petName) then
                petCounts[petName] = petCounts[petName] + 1
                break
            end
        end
    end
    
    return petCounts
end

-- Create the embed message (excludes zero counts)
local function createEmbed(petCounts)
    local embed = {
        title = "🌿 Garden Pet Tracker 🐾",
        description = "**Player:** " .. player.Name,
        color = 5814783, -- Purple color
        fields = {},
        footer = {
            text = "Last updated: " .. os.date("%Y-%m-%d %H:%M:%S")
        }
    }
    
    local totalPets = 0
    local hasPets = false
    
    -- Add pet counts (only if > 0)
    for petName, count in pairs(petCounts) do
        if count > 0 then
            table.insert(embed.fields, {
                name = petName,
                value = tostring(count),
                inline = true
            })
            totalPets = totalPets + count
            hasPets = true
        end
    end
    
    -- Add total count if we have any pets
    if hasPets then
        table.insert(embed.fields, {
            name = "TOTAL PETS",
            value = tostring(totalPets),
            inline = false
        })
    else
        embed.description = embed.description .. "\n\nNo pets found in backpack!"
    end
    
    return {
        username = player.Name .. "'s Pet Tracker",
        avatar_url = getPlayerAvatar(),
        embeds = {embed}
    }
end

-- Edit the webhook message
local function editWebhookMessage(content)
    if not isValidWebhook(getgenv().config.WEBHOOK_URL) then
        warn("Invalid webhook URL in config")
        return false
    end
    
    if not getgenv().config.MESSAGE_ID or getgenv().config.MESSAGE_ID == "" then
        warn("No message ID specified in config")
        return false
    end
    
    local jsonData = http:JSONEncode(content)
    local headers = {["Content-Type"] = "application/json"}
    
    local url = getgenv().config.WEBHOOK_URL .. "/messages/" .. getgenv().config.MESSAGE_ID
    local request = http_request or request or HttpPost or syn.request
    
    if request then
        local response = request({
            Url = url,
            Method = "PATCH",
            Headers = headers,
            Body = jsonData
        })
        
        if response.StatusCode == 404 then
            warn("Message not found - check your message ID")
        elseif response.StatusCode == 429 then
            local retryAfter = tonumber(response.Headers["Retry-After"]) or 5
            warn("Rate limited - retrying after " .. retryAfter .. " seconds")
            wait(retryAfter)
            return editWebhookMessage(content)
        end
        
        return response.Success
    else
        warn("HTTP request function not available")
        return false
    end
end

-- Main tracking function
local function startTracking()
    if not isValidWebhook(getgenv().config.WEBHOOK_URL) then
        print("Please set a valid webhook URL in getgenv().config!")
        return
    end
    
    if not getgenv().config.MESSAGE_ID or getgenv().config.MESSAGE_ID == "" then
        print("Please set a message ID in getgenv().config!")
        return
    end
    
    print("Starting pet tracker for " .. player.Name)
    print("Editing message ID: " .. getgenv().config.MESSAGE_ID)
    
    while true do
        local success, counts = pcall(countPets)
        if not success then
            warn("Error counting pets: " .. tostring(counts))
            wait(UPDATE_INTERVAL)
            continue
        end
        
        local embed = createEmbed(counts)
        local success = editWebhookMessage(embed)
        
        if success then
            print("Stats updated successfully at " .. os.date("%X"))
        else
            warn("Failed to update stats")
        end
        
        wait(UPDATE_INTERVAL)
    end
end

-- Start the tracker
startTracking()
