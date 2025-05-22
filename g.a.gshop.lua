local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local Players = game:GetService("Players")

local function GetServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local response = HttpService:JSONDecode(game:HttpGet(url))
    return response
end

local function HopToOldestServer()
    local cursor = nil
    local tried = {}
    for _ = 1, 5 do  -- attempts to find a good one in 5 pages
        local servers = GetServers(cursor)
        if not servers or not servers.data then break end
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and not tried[server.id] and server.id ~= game.JobId then
                tried[server.id] = true
                print("Attempting to join server:", server.id, "Players:", server.playing)
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, Players.LocalPlayer)
                wait(3)
            end
        end
        cursor = servers.nextPageCursor
        if not cursor then break end
    end
    warn("No older server found or all are full.")
end

HopToOldestServer()