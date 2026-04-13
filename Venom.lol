-- Venom.lol GUI - v1.7
-- Whitelist system by Roblox User ID

-- ══════════════════════════════════════════
--  WHITELIST CHECK
-- ══════════════════════════════════════════
local SERVER = "https://subventionary-letha-boughten.ngrok-free.dev"
local rbxid  = tostring(game:GetService("Players").LocalPlayer.UserId)

-- Loading screen
local _Players  = game:GetService("Players")
local loadGui   = Instance.new("ScreenGui")
loadGui.Name         = "VenomLoad"
loadGui.ResetOnSpawn = false
loadGui.Parent       = _Players.LocalPlayer:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size                   = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3       = Color3.fromRGB(5, 5, 8)
bg.BackgroundTransparency = 0
bg.BorderSizePixel        = 0
bg.Parent                 = loadGui

local card = Instance.new("Frame")
card.Size             = UDim2.new(0, 340, 0, 150)
card.Position         = UDim2.new(0.5, -170, 0.5, -75)
card.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
card.BorderSizePixel  = 0
card.Parent           = loadGui
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
local cs = Instance.new("UIStroke", card)
cs.Color     = Color3.fromRGB(138, 43, 226)
cs.Thickness = 1.5

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1, 0, 0, 46)
titleLbl.Position           = UDim2.new(0, 0, 0, 8)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "venom.lol"
titleLbl.TextColor3         = Color3.fromRGB(138, 43, 226)
titleLbl.TextSize           = 24
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.Parent             = card

local statusLbl = Instance.new("TextLabel")
statusLbl.Size               = UDim2.new(1, -24, 0, 30)
statusLbl.Position           = UDim2.new(0, 12, 0, 60)
statusLbl.BackgroundTransparency = 1
statusLbl.Text               = "Checking whitelist..."
statusLbl.TextColor3         = Color3.fromRGB(130, 120, 150)
statusLbl.TextSize           = 13
statusLbl.Font               = Enum.Font.Gotham
statusLbl.TextXAlignment     = Enum.TextXAlignment.Center
statusLbl.Parent             = card

local idLbl = Instance.new("TextLabel")
idLbl.Size               = UDim2.new(1, -24, 0, 22)
idLbl.Position           = UDim2.new(0, 12, 0, 94)
idLbl.BackgroundTransparency = 1
idLbl.Text               = "User ID: " .. rbxid
idLbl.TextColor3         = Color3.fromRGB(60, 55, 80)
idLbl.TextSize           = 10
idLbl.Font               = Enum.Font.Gotham
idLbl.TextXAlignment     = Enum.TextXAlignment.Center
idLbl.Parent             = card

local subLbl = Instance.new("TextLabel")
subLbl.Size               = UDim2.new(1, -24, 0, 20)
subLbl.Position           = UDim2.new(0, 12, 0, 120)
subLbl.BackgroundTransparency = 1
subLbl.Text               = ""
subLbl.TextColor3         = Color3.fromRGB(138, 43, 226)
subLbl.TextSize           = 10
subLbl.Font               = Enum.Font.Gotham
subLbl.TextXAlignment     = Enum.TextXAlignment.Center
subLbl.Parent             = card

-- Do the whitelist check
local ok, result = pcall(function()
    return game:HttpGet(SERVER .. "/check?rbxid=" .. rbxid)
end)

if not ok then result = "api_error" end
result = result and result:gsub("%s+", "") or "api_error"

if result == "valid" then
    statusLbl.Text       = "Access Granted!"
    statusLbl.TextColor3 = Color3.fromRGB(50, 200, 50)
    idLbl.Text           = "Welcome!"
    task.wait(1)
    loadGui:Destroy()
else
    local messages = {
        not_whitelisted = {"Not Whitelisted",  "Contact an admin on Discord to get access."},
        blacklisted     = {"Blacklisted",       "You have been blacklisted from venom.lol."},
        expired         = {"Access Expired",    "Your whitelist has expired. Contact an admin."},
        api_error       = {"Server Error",      "Could not reach the server. Try again later."},
        missing_id      = {"Error",             "Could not read your Roblox User ID."},
    }
    local msg = messages[result] or {"Access Denied", "Status: " .. tostring(result)}
    statusLbl.Text       = msg[1]
    statusLbl.TextColor3 = Color3.fromRGB(200, 50, 50)
    idLbl.Text           = msg[2]
    subLbl.Text          = "discord.gg/yourserver"
    return  -- stop script here, nothing loads
end

-- ══════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse     = Player:GetMouse()

-- ══════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════
local PURPLE      = Color3.fromRGB(138, 43, 226)
local PURPLE_DIM  = Color3.fromRGB(90, 20, 160)
local PURPLE_DARK = Color3.fromRGB(40, 10, 70)
local BG          = Color3.fromRGB(8, 8, 12)
local BG2         = Color3.fromRGB(14, 14, 20)
local BG3         = Color3.fromRGB(20, 20, 30)
local TEXT        = Color3.fromRGB(220, 220, 230)
local SUBTEXT     = Color3.fromRGB(130, 120, 150)
local RED         = Color3.fromRGB(200, 50, 50)
local GREEN       = Color3.fromRGB(50, 200, 50)
local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local CONFIG_FILE = "venom_config.json"

-- ══════════════════════════════════════════
--  DRAWING API CHECK
-- ══════════════════════════════════════════
local hasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "userdata") and Drawing.new ~= nil

-- ══════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════
local state = {
    aimEnabled        = false,
    stickyAim         = false,
    aimPart           = "Head",
    aimMethod         = "Closest To Mouse",
    aimFov            = 50,
    showFov           = false,
    useFov            = true,
    camlockEnabled    = false,
    camlockKeybind    = "Q",
    camlockMode       = "Hold",
    camlockToggle     = false,
    camlockPart       = "Head",
    useAdvanced       = false,
    smoothingOn       = false,
    predictX          = 0,
    predictY          = 0,
    smoothX           = 5,
    smoothY           = 5,
    camlockStyle      = "Linear",
    esp               = false,
    espBoxes          = false,
    espNames          = false,
    espHealth         = false,
    espTracers        = false,
    chams             = false,
    fullbright        = false,
    noFog             = false,
    noShadows         = false,
    flyEnabled        = false,
    noclip            = false,
    infiniteJump      = false,
    speedBoost        = false,
    walkSpeed         = 16,
    jumpPower         = 50,
    godMode           = false,
    antiAfk           = false,
    invisible         = false,
    minimapEnabled    = true,
    minimapRange      = 300,
    showGameMap       = true,
}

local bv, bg
local stickyTarget    = nil
local tracerThickness = 1
local MINIMAP_SIZE    = 180
local onePressActive  = false
local onePressUsed    = false

-- ══════════════════════════════════════════
--  ESP DRAWING OBJECTS
-- ══════════════════════════════════════════
local espDrawings = {}

local function newDrawing(objType, props)
    if not hasDrawing then return nil end
    local ok, obj = pcall(Drawing.new, objType)
    if not ok or not obj then return nil end
    for k, v in props do pcall(function() obj[k] = v end) end
    return obj
end

local function hideDrawings(d)
    if not d then return end
    if d.box        then d.box.Visible        = false end
    if d.nameText   then d.nameText.Visible   = false end
    if d.healthText then d.healthText.Visible = false end
    if d.healthBg   then d.healthBg.Visible   = false end
    if d.tracer     then d.tracer.Visible     = false end
end

local function destroyDrawings(d)
    if not d then return end
    pcall(function() if d.box        then d.box:Remove()        end end)
    pcall(function() if d.nameText   then d.nameText:Remove()   end end)
    pcall(function() if d.healthText then d.healthText:Remove() end end)
    pcall(function() if d.healthBg   then d.healthBg:Remove()   end end)
    pcall(function() if d.tracer     then d.tracer:Remove()     end end)
end

local function getOrCreateESP(plr)
    if not hasDrawing then return nil end
    if espDrawings[plr] then return espDrawings[plr] end
    local d = {}
    d.box = newDrawing("Square", {
        Visible=false, Color=PURPLE, Thickness=1, Filled=false, Transparency=1 })
    d.nameText = newDrawing("Text", {
        Visible=false, Color=PURPLE, Size=13, Center=true,
        Outline=true, OutlineColor=Color3.new(0,0,0), Transparency=1,
        Font=Drawing.Fonts and Drawing.Fonts.UI or 0 })
    d.healthBg = newDrawing("Square", {
        Visible=false, Color=Color3.fromRGB(30,0,0), Thickness=1,
        Filled=true, Transparency=0.4 })
    d.healthText = newDrawing("Text", {
        Visible=false, Color=Color3.fromRGB(80,255,80), Size=11,
        Center=true, Outline=true, OutlineColor=Color3.new(0,0,0),
        Transparency=1, Font=Drawing.Fonts and Drawing.Fonts.UI or 0 })
    d.tracer = newDrawing("Line", {
        Visible=false, Color=PURPLE, Thickness=tracerThickness, Transparency=1 })
    espDrawings[plr] = d
    return d
end

local function updateESPForPlayer(plr)
    local d = getOrCreateESP(plr)
    if not d then return end
    local char = plr.Character
    if not char then hideDrawings(d) return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideDrawings(d) return end
    local cam = workspace.CurrentCamera
    local topWorld    = head.Position + Vector3.new(0, head.Size.Y/2+0.1, 0)
    local bottomWorld = hrp.Position  - Vector3.new(0, hrp.Size.Y/2+0.3, 0)
    local topSP,_    = cam:WorldToViewportPoint(topWorld)
    local bottomSP,_ = cam:WorldToViewportPoint(bottomWorld)
    local hrpSP, hrpVis = cam:WorldToViewportPoint(hrp.Position)
    if not hrpVis then hideDrawings(d) return end
    local boxH = math.abs(bottomSP.Y - topSP.Y)
    local boxW = boxH * 0.55
    local boxX = hrpSP.X - boxW/2
    local boxY = topSP.Y
    local showBox    = state.esp and state.espBoxes
    local showName   = state.esp and state.espNames
    local showHealth = state.esp and state.espHealth
    local showTracer = state.esp and state.espTracers
    if d.box then
        d.box.Visible = showBox
        if showBox then
            d.box.Position = Vector2.new(boxX, boxY)
            d.box.Size     = Vector2.new(boxW, boxH)
            d.box.Color    = PURPLE
        end
    end
    if d.nameText then
        d.nameText.Visible = showName
        if showName then
            d.nameText.Text     = plr.DisplayName
            d.nameText.Position = Vector2.new(hrpSP.X, topSP.Y-16)
            d.nameText.Color    = PURPLE
        end
    end
    local pct = math.clamp(hum.Health/math.max(hum.MaxHealth,1), 0, 1)
    local hpColor = Color3.fromRGB(math.round(255*(1-pct)), math.round(200*pct), 0)
    if d.healthBg then
        d.healthBg.Visible = showHealth
        if showHealth then
            d.healthBg.Position = Vector2.new(boxX-6, boxY)
            d.healthBg.Size     = Vector2.new(4, boxH)
        end
    end
    if d.healthText then
        d.healthText.Visible = showHealth
        if showHealth then
            d.healthText.Text     = math.floor(pct*100).."%"
            d.healthText.Position = Vector2.new(hrpSP.X, topSP.Y-28)
            d.healthText.Color    = hpColor
        end
    end
    if d.tracer then
        d.tracer.Visible = showTracer
        if showTracer then
            local vp = cam.ViewportSize
            d.tracer.From      = Vector2.new(vp.X/2, vp.Y)
            d.tracer.To        = Vector2.new(hrpSP.X, hrpSP.Y)
            d.tracer.Color     = PURPLE
            d.tracer.Thickness = tracerThickness
        end
    end
    if state.esp and state.chams then
        for _, p in char:GetDescendants() do
            if p:IsA("BasePart") then
                p.Material = Enum.Material.Neon
                p.Color    = PURPLE_DIM
            end
        end
    end
end

local function cleanupESPForPlayer(plr)
    if espDrawings[plr] then
        destroyDrawings(espDrawings[plr])
        espDrawings[plr] = nil
    end
end

local function cleanupAllESP()
    for plr,_ in espDrawings do
        destroyDrawings(espDrawings[plr])
        espDrawings[plr] = nil
    end
end

-- ══════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════
local function saveConfig()
    local data = {}
    for k,v in state do data[k] = v end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
end

local function loadConfig()
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data)~="table" then return end
    for k,v in data do if state[k]~=nil then state[k]=v end end
end

loadConfig()

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getClosestToMouse(partName)
    partName = partName or state.aimPart
    local closest, closestD = nil, math.huge
    local cam    = workspace.CurrentCamera
    local mp     = Vector2.new(Mouse.X, Mouse.Y)
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    for _, plr in Players:GetPlayers() do
        if plr == Player then continue end
        local char = plr.Character
        if not char then continue end
        local part = char:FindFirstChild(partName) or char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health<=0 then continue end
        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenPos     = Vector2.new(sp.X, sp.Y)
        local distFromMouse = (screenPos - mp).Magnitude
        local checkDist     = state.aimMethod=="Closest To Mouse"
            and distFromMouse or (screenPos-center).Magnitude
        local inFov = not state.useFov or distFromMouse<=state.aimFov
        if inFov and checkDist<closestD then
            closestD = checkDist
            closest  = plr
        end
    end
    return closest
end

-- ══════════════════════════════════════════
--  MAP SCANNER
-- ══════════════════════════════════════════
local MAP_CELLS  = 64
local mapMinX, mapMaxX = math.huge, -math.huge
local mapMinZ, mapMaxZ = math.huge, -math.huge
local mapGrid    = {}
local mapScanned = false

local function scanMap()
    mapMinX, mapMaxX = math.huge, -math.huge
    mapMinZ, mapMaxZ = math.huge, -math.huge
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or game) then
            local p = obj.Position
            if p.X < mapMinX then mapMinX = p.X end
            if p.X > mapMaxX then mapMaxX = p.X end
            if p.Z < mapMinZ then mapMinZ = p.Z end
            if p.Z > mapMaxZ then mapMaxZ = p.Z end
        end
    end
    if mapMinX == math.huge then
        mapMinX, mapMaxX = -500, 500
        mapMinZ, mapMaxZ = -500, 500
    end
    local padX = (mapMaxX - mapMinX) * 0.05
    local padZ = (mapMaxZ - mapMinZ) * 0.05
    mapMinX = mapMinX - padX; mapMaxX = mapMaxX + padX
    mapMinZ = mapMinZ - padZ; mapMaxZ = mapMaxZ + padZ
    local cellCountX = (mapMaxX - mapMinX) / MAP_CELLS
    local cellCountZ = (mapMaxZ - mapMinZ) / MAP_CELLS
    local rawGrid    = {}
    local maxDensity = 0
    for r = 1, MAP_CELLS do rawGrid[r] = {} for c = 1, MAP_CELLS do rawGrid[r][c] = 0 end end
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or game) then
            local p   = obj.Position
            local col = math.clamp(math.floor((p.X - mapMinX)/cellCountX)+1, 1, MAP_CELLS)
            local row = math.clamp(math.floor((p.Z - mapMinZ)/cellCountZ)+1, 1, MAP_CELLS)
            rawGrid[row][col] = rawGrid[row][col] + 1
            if rawGrid[row][col] > maxDensity then maxDensity = rawGrid[row][col] end
        end
    end
    for r = 1, MAP_CELLS do
        mapGrid[r] = {}
        for c = 1, MAP_CELLS do
            mapGrid[r][c] = maxDensity > 0 and (rawGrid[r][c] / maxDensity) or 0
        end
    end
    mapScanned = true
end

task.spawn(scanMap)

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "VenomGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = PlayerGui

-- ══════════════════════════════════════════
--  MINIMAP
-- ══════════════════════════════════════════
local MinimapFrame = Instance.new("Frame")
MinimapFrame.Size             = UDim2.new(0, MINIMAP_SIZE, 0, MINIMAP_SIZE)
MinimapFrame.Position         = UDim2.new(1, -(MINIMAP_SIZE+14), 1, -(MINIMAP_SIZE+14))
MinimapFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
MinimapFrame.BorderSizePixel  = 0
MinimapFrame.ZIndex           = 5
MinimapFrame.Visible          = state.minimapEnabled
MinimapFrame.Parent           = ScreenGui
Instance.new("UICorner", MinimapFrame).CornerRadius = UDim.new(0, 8)
local mmStroke = Instance.new("UIStroke", MinimapFrame)
mmStroke.Color = PURPLE_DIM; mmStroke.Thickness = 1.5

local mmClip = Instance.new("Frame")
mmClip.Size               = UDim2.new(1, 0, 1, 0)
mmClip.BackgroundTransparency = 1
mmClip.ClipsDescendants   = true
mmClip.ZIndex             = 5
mmClip.Parent             = MinimapFrame
Instance.new("UICorner", mmClip).CornerRadius = UDim.new(0, 8)

local mapLayer = Instance.new("Frame")
mapLayer.Size               = UDim2.new(1, 0, 1, 0)
mapLayer.BackgroundTransparency = 1
mapLayer.ZIndex             = 5
mapLayer.Parent             = mmClip

local TILE_COUNT = MAP_CELLS
local tilePx     = MINIMAP_SIZE / TILE_COUNT
local mapTiles   = {}

for r = 1, TILE_COUNT do
    mapTiles[r] = {}
    for c = 1, TILE_COUNT do
        local tile = Instance.new("Frame")
        tile.Size             = UDim2.new(0, math.ceil(tilePx)+1, 0, math.ceil(tilePx)+1)
        tile.Position         = UDim2.new(0, (c-1)*tilePx, 0, (r-1)*tilePx)
        tile.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
        tile.BorderSizePixel  = 0
        tile.ZIndex           = 5
        tile.Parent           = mapLayer
        mapTiles[r][c]        = tile
    end
end

local function applyMapGrid()
    if not mapScanned then return end
    for r = 1, TILE_COUNT do
        for c = 1, TILE_COUNT do
            local d    = mapGrid[r] and mapGrid[r][c] or 0
            local grey = math.clamp(d, 0, 1)
            mapTiles[r][c].BackgroundColor3 = Color3.fromRGB(
                math.round(20 + grey * 60),
                math.round(12 + grey * 20),
                math.round(35 + grey * 80)
            )
        end
    end
end

task.spawn(function()
    while not mapScanned do task.wait(0.1) end
    applyMapGrid()
end)

local mmRescanBtn = Instance.new("TextButton")
mmRescanBtn.Size             = UDim2.new(1, 0, 0, 14)
mmRescanBtn.Position         = UDim2.new(0, 0, 0, 0)
mmRescanBtn.BackgroundColor3 = Color3.fromRGB(20, 10, 35)
mmRescanBtn.BorderSizePixel  = 0
mmRescanBtn.Text             = "MAP [rescan]"
mmRescanBtn.TextColor3       = SUBTEXT
mmRescanBtn.TextSize         = 8
mmRescanBtn.Font             = Enum.Font.GothamSemibold
mmRescanBtn.ZIndex           = 9
mmRescanBtn.Parent           = mmClip
mmRescanBtn.MouseButton1Click:Connect(function()
    mmRescanBtn.Text = "scanning..."
    task.spawn(function()
        scanMap(); applyMapGrid()
        mmRescanBtn.Text = "MAP [rescan]"
    end)
end)

local radarLayer = Instance.new("Frame")
radarLayer.Size               = UDim2.new(1, 0, 1, 0)
radarLayer.BackgroundTransparency = 1
radarLayer.ZIndex             = 6
radarLayer.Parent             = mmClip

for _, pct in {0.33, 0.66, 1.0} do
    local rSize = MINIMAP_SIZE * pct
    local ring  = Instance.new("Frame")
    ring.Size             = UDim2.new(0, rSize, 0, rSize)
    ring.Position         = UDim2.new(0.5, -rSize/2, 0.5, -rSize/2)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel  = 0
    ring.ZIndex           = 6
    ring.Parent           = radarLayer
    local rs = Instance.new("UIStroke", ring)
    rs.Color        = Color3.fromRGB(50, 30, 80)
    rs.Thickness    = 0.5
    rs.Transparency = 0.5
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
end

local function mmLine(vert)
    local l = Instance.new("Frame")
    l.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    l.BorderSizePixel  = 0
    l.ZIndex           = 6
    l.Parent           = radarLayer
    if vert then
        l.Size = UDim2.new(0, 1, 1, 0); l.Position = UDim2.new(0.5, 0, 0, 0)
    else
        l.Size = UDim2.new(1, 0, 0, 1); l.Position = UDim2.new(0, 0, 0.5, 0)
    end
end
mmLine(true); mmLine(false)

local mmSelf = Instance.new("Frame")
mmSelf.Size             = UDim2.new(0, 8, 0, 8)
mmSelf.AnchorPoint      = Vector2.new(0.5, 0.5)
mmSelf.Position         = UDim2.new(0.5, 0, 0.5, 0)
mmSelf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mmSelf.BorderSizePixel  = 0
mmSelf.ZIndex           = 9
mmSelf.Parent           = radarLayer
Instance.new("UICorner", mmSelf).CornerRadius = UDim.new(1, 0)

local mmLabel = Instance.new("TextLabel")
mmLabel.Size              = UDim2.new(1, 0, 0, 13)
mmLabel.Position          = UDim2.new(0, 0, 1, 2)
mmLabel.BackgroundTransparency = 1
mmLabel.Text              = "RADAR " .. tostring(state.minimapRange) .. "st"
mmLabel.TextColor3        = SUBTEXT
mmLabel.TextSize          = 8
mmLabel.Font              = Enum.Font.GothamSemibold
mmLabel.ZIndex            = 5
mmLabel.Parent            = MinimapFrame

local mmDots = {}
local function getMMDot(i)
    if mmDots[i] then return mmDots[i] end
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 7, 0, 7)
    dot.AnchorPoint      = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = RED
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 8
    dot.Visible          = false
    dot.Parent           = radarLayer
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dn = Instance.new("TextLabel")
    dn.Size               = UDim2.new(0, 50, 0, 11)
    dn.AnchorPoint        = Vector2.new(0.5, 1)
    dn.Position           = UDim2.new(0.5, 0, 0, -1)
    dn.BackgroundTransparency = 1
    dn.TextColor3         = TEXT
    dn.TextSize           = 7
    dn.Font               = Enum.Font.GothamBold
    dn.ZIndex             = 9
    dn.Parent             = dot
    mmDots[i] = dot
    return dot
end

-- ══════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════
local FovCircle = Instance.new("Frame")
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.ZIndex  = 10
FovCircle.Visible = false
FovCircle.Parent  = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke")
FovStroke.Color        = PURPLE
FovStroke.Thickness    = 1.5
FovStroke.Transparency = 0.2
FovStroke.Parent       = FovCircle

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = state.showFov and state.aimEnabled
    if not FovCircle.Visible then return end
    local r = state.aimFov
    FovCircle.Size     = UDim2.new(0, r*2, 0, r*2)
    FovCircle.Position = UDim2.new(0, Mouse.X-r, 0, Mouse.Y-r)
end)

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local Win = Instance.new("Frame")
Win.Name             = "VenomWin"
Win.Size             = UDim2.new(0, 820, 0, 480)
Win.Position         = UDim2.new(0.5, -410, 0.5, -240)
Win.BackgroundColor3 = BG
Win.BorderSizePixel  = 0
Win.Active           = true
Win.Parent           = ScreenGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 8)
local WinStroke = Instance.new("UIStroke")
WinStroke.Color = PURPLE_DIM; WinStroke.Thickness = 1; WinStroke.Parent = Win

local TopAccent = Instance.new("Frame")
TopAccent.Size             = UDim2.new(1, 0, 0, 2)
TopAccent.BackgroundColor3 = PURPLE
TopAccent.BorderSizePixel  = 0
TopAccent.ZIndex           = 2
TopAccent.Parent           = Win
Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 8)

-- ══════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = BG2
TitleBar.BorderSizePixel  = 0
TitleBar.Active           = true
TitleBar.Parent           = Win
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TFix = Instance.new("Frame")
TFix.Size             = UDim2.new(1, 0, 0, 10)
TFix.Position         = UDim2.new(0, 0, 1, -10)
TFix.BackgroundColor3 = BG2
TFix.BorderSizePixel  = 0
TFix.Parent           = TitleBar

local Logo = Instance.new("TextLabel")
Logo.Size           = UDim2.new(0, 120, 1, 0)
Logo.Position       = UDim2.new(0, 14, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text           = "venom.lol"
Logo.TextColor3     = PURPLE
Logo.TextSize       = 15
Logo.Font           = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent         = TitleBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size           = UDim2.new(0, 60, 1, 0)
LogoSub.Position       = UDim2.new(0, 105, 0, 0)
LogoSub.BackgroundTransparency = 1
LogoSub.Text           = "v1.7"
LogoSub.TextColor3     = SUBTEXT
LogoSub.TextSize       = 10
LogoSub.Font           = Enum.Font.Gotham
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent         = TitleBar

-- Whitelist status indicator
local WLIndicator = Instance.new("TextLabel")
WLIndicator.Size           = UDim2.new(0, 140, 1, 0)
WLIndicator.Position       = UDim2.new(0, 160, 0, 0)
WLIndicator.BackgroundTransparency = 1
WLIndicator.Text           = "Whitelisted: " .. rbxid
WLIndicator.TextColor3     = GREEN
WLIndicator.TextSize       = 9
WLIndicator.Font           = Enum.Font.Gotham
WLIndicator.TextXAlignment = Enum.TextXAlignment.Left
WLIndicator.Parent         = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 22, 0, 22)
CloseBtn.Position         = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50,20,20)
CloseBtn.Text             = "X"
CloseBtn.TextColor3       = RED
CloseBtn.TextSize         = 11
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function()
    saveConfig(); cleanupAllESP(); ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 22, 0, 22)
MinBtn.Position         = UDim2.new(1, -56, 0.5, -11)
MinBtn.BackgroundColor3 = PURPLE_DARK
MinBtn.Text             = "-"
MinBtn.TextColor3       = PURPLE
MinBtn.TextSize         = 11
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.Parent           = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local TabBarFrame = Instance.new("Frame")
TabBarFrame.Size     = UDim2.new(1, -320, 1, 0)
TabBarFrame.Position = UDim2.new(0, 310, 0, 0)
TabBarFrame.BackgroundTransparency = 1
TabBarFrame.Parent   = TitleBar

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection     = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder         = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding           = UDim.new(0, 2)
TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabBarLayout.Parent            = TabBarFrame

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=Win.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
            startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

local minimised = false
MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    for _,c in Win:GetChildren() do
        if c~=TitleBar and c~=TopAccent then c.Visible = not minimised end
    end
    Win.Size = minimised and UDim2.new(0,820,0,36) or UDim2.new(0,820,0,480)
end)

-- ══════════════════════════════════════════
--  BODY
-- ══════════════════════════════════════════
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1,0,1,-36); Body.Position = UDim2.new(0,0,0,36)
Body.BackgroundTransparency = 1; Body.Parent = Win

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0,280,1,0); LeftPanel.BackgroundColor3 = BG2
LeftPanel.BorderSizePixel = 0; LeftPanel.Parent = Body

local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Size = UDim2.new(1,-4,1,-10); LeftScroll.Position = UDim2.new(0,4,0,5)
LeftScroll.BackgroundTransparency=1; LeftScroll.BorderSizePixel=0
LeftScroll.ScrollBarThickness=3; LeftScroll.ScrollBarImageColor3=PURPLE
LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
LeftScroll.CanvasSize=UDim2.new(0,0,0,0); LeftScroll.Parent=LeftPanel

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.SortOrder=Enum.SortOrder.LayoutOrder; LeftLayout.Padding=UDim.new(0,3)
LeftLayout.Parent=LeftScroll

local LeftPad = Instance.new("UIPadding")
LeftPad.PaddingLeft=UDim.new(0,8); LeftPad.PaddingRight=UDim.new(0,8)
LeftPad.PaddingTop=UDim.new(0,8); LeftPad.PaddingBottom=UDim.new(0,8)
LeftPad.Parent=LeftScroll

local Div = Instance.new("Frame")
Div.Size=UDim2.new(0,1,1,0); Div.Position=UDim2.new(0,280,0,0)
Div.BackgroundColor3=PURPLE_DARK; Div.BorderSizePixel=0; Div.Parent=Body

local RightPanel = Instance.new("Frame")
RightPanel.Size=UDim2.new(1,-282,1,0); RightPanel.Position=UDim2.new(0,282,0,0)
RightPanel.BackgroundColor3=BG; RightPanel.BorderSizePixel=0; RightPanel.Parent=Body

local RightScroll = Instance.new("ScrollingFrame")
RightScroll.Size=UDim2.new(1,-4,1,-10); RightScroll.Position=UDim2.new(0,4,0,5)
RightScroll.BackgroundTransparency=1; RightScroll.BorderSizePixel=0
RightScroll.ScrollBarThickness=3; RightScroll.ScrollBarImageColor3=PURPLE
RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
RightScroll.CanvasSize=UDim2.new(0,0,0,0); RightScroll.Parent=RightPanel

local RightLayout = Instance.new("UIListLayout")
RightLayout.SortOrder=Enum.SortOrder.LayoutOrder; RightLayout.Padding=UDim.new(0,3)
RightLayout.Parent=RightScroll

local RightPad = Instance.new("UIPadding")
RightPad.PaddingLeft=UDim.new(0,10); RightPad.PaddingRight=UDim.new(0,10)
RightPad.PaddingTop=UDim.new(0,8); RightPad.PaddingBottom=UDim.new(0,8)
RightPad.Parent=RightScroll

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabs = {}

local function makeTabBtn(name, order)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(0,82,0,26); btn.BackgroundColor3=BG3
    btn.BorderSizePixel=0; btn.Text=name; btn.TextColor3=SUBTEXT
    btn.TextSize=11; btn.Font=Enum.Font.GothamSemibold
    btn.LayoutOrder=order; btn.Parent=TabBarFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    local underline=Instance.new("Frame")
    underline.Size=UDim2.new(1,0,0,2); underline.Position=UDim2.new(0,0,1,-2)
    underline.BackgroundColor3=PURPLE; underline.BorderSizePixel=0
    underline.Visible=false; underline.Parent=btn
    Instance.new("UICorner",underline).CornerRadius=UDim.new(1,0)
    local tabData={btn=btn,underline=underline,leftItems={},rightItems={}}
    table.insert(tabs,tabData)
    btn.MouseButton1Click:Connect(function()
        for _,t in tabs do
            t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3
            t.underline.Visible=false
            for _,item in t.leftItems  do item.Visible=false end
            for _,item in t.rightItems do item.Visible=false end
        end
        btn.TextColor3=PURPLE; btn.BackgroundColor3=PURPLE_DARK
        underline.Visible=true
        for _,item in tabData.leftItems  do item.Visible=true end
        for _,item in tabData.rightItems do item.Visible=true end
    end)
    return tabData
end

local function activateTab(tabData)
    for _,t in tabs do
        t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3
        t.underline.Visible=false
        for _,item in t.leftItems  do item.Visible=false end
        for _,item in t.rightItems do item.Visible=false end
    end
    tabData.btn.TextColor3=PURPLE; tabData.btn.BackgroundColor3=PURPLE_DARK
    tabData.underline.Visible=true
    for _,item in tabData.leftItems  do item.Visible=true end
    for _,item in tabData.rightItems do item.Visible=true end
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════
local leftOrder=0
local rightOrder=0

local function SectionLabel(text, isRight)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.Visible=false
    if isRight then rightOrder+=1;f.LayoutOrder=rightOrder;f.Parent=RightScroll
    else leftOrder+=1;f.LayoutOrder=leftOrder;f.Parent=LeftScroll end
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=PURPLE_DARK; line.BorderSizePixel=0; line.Parent=f
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=text; lbl.TextColor3=SUBTEXT; lbl.TextSize=10
    lbl.Font=Enum.Font.GothamSemibold; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=f
    return f
end

local function Toggle(name, keybind, default, callback, isRight)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.Visible=false
    if isRight then rightOrder+=1;row.LayoutOrder=rightOrder;row.Parent=RightScroll
    else leftOrder+=1;row.LayoutOrder=leftOrder;row.Parent=LeftScroll end
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,14,0,14); dot.Position=UDim2.new(0,0,0.5,-7)
    dot.BackgroundColor3=default and PURPLE or Color3.fromRGB(50,50,60)
    dot.BorderSizePixel=0; dot.Parent=row
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-80,1,0); lbl.Position=UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=name
    lbl.TextColor3=default and TEXT or SUBTEXT; lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=row
    if keybind and keybind~="" then
        local kb=Instance.new("TextLabel")
        kb.Size=UDim2.new(0,60,1,0); kb.Position=UDim2.new(1,-60,0,0)
        kb.BackgroundTransparency=1; kb.Text="["..keybind.."]"
        kb.TextColor3=PURPLE_DIM; kb.TextSize=10; kb.Font=Enum.Font.Gotham
        kb.TextXAlignment=Enum.TextXAlignment.Right; kb.Parent=row
    end
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text=""; btn.Parent=row
    local st=default
    local function setState(v)
        st=v
        TweenService:Create(dot,TWEEN_FAST,{
            BackgroundColor3=st and PURPLE or Color3.fromRGB(50,50,60)}):Play()
        lbl.TextColor3=st and TEXT or SUBTEXT
        if callback then callback(st) end
    end
    btn.MouseButton1Click:Connect(function() setState(not st) end)
    return row, setState
end

local function Slider(name, min, max, default, suffix, callback, isRight)
    suffix=suffix or ""
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,46); card.BackgroundTransparency=1; card.Visible=false
    if isRight then rightOrder+=1;card.LayoutOrder=rightOrder;card.Parent=RightScroll
    else leftOrder+=1;card.LayoutOrder=leftOrder;card.Parent=LeftScroll end
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.6,0,0,18); nameLbl.BackgroundTransparency=1
    nameLbl.Text=name; nameLbl.TextColor3=SUBTEXT; nameLbl.TextSize=11
    nameLbl.Font=Enum.Font.Gotham; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.Parent=card
    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.4,0,0,18); valLbl.Position=UDim2.new(0.6,0,0,0)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(default)..suffix
    valLbl.TextColor3=PURPLE; valLbl.TextSize=11; valLbl.Font=Enum.Font.GothamBold
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=card
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,0,0,4)
    track.Position=UDim2.new(0,0,0,26)
    track.BackgroundColor3=Color3.fromRGB(35,25,55); track.BorderSizePixel=0
    track.Parent=card
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct0=math.clamp((default-min)/(max-min),0,1)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct0,0,1,0); fill.BackgroundColor3=PURPLE
    fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(220,200,255)
    knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local sdrag=false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=false end
    end)
    RunService.RenderStepped:Connect(function()
        if not sdrag then return end
        local mp=UserInputService:GetMouseLocation()
        local p=math.clamp((mp.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.round(min+p*(max-min))
        fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,0.5,0)
        valLbl.Text=tostring(v)..suffix
        if callback then callback(v) end
    end)
    return card
end

local function Dropdown(name, options, default, callback, isRight)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isRight then rightOrder+=1;card.LayoutOrder=rightOrder;card.Parent=RightScroll
    else leftOrder+=1;card.LayoutOrder=leftOrder;card.Parent=LeftScroll end
    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.5,0,1,0); valLbl.BackgroundTransparency=1
    valLbl.Text=default; valLbl.TextColor3=TEXT; valLbl.TextSize=11
    valLbl.Font=Enum.Font.Gotham; valLbl.TextXAlignment=Enum.TextXAlignment.Left
    valLbl.Parent=card
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.5,0,1,0); nameLbl.Position=UDim2.new(0.5,0,0,0)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=SUBTEXT
    nameLbl.TextSize=11; nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextXAlignment=Enum.TextXAlignment.Right; nameLbl.Parent=card
    local idx=1
    for i,v in options do if v==default then idx=i break end end
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text=""; btn.Parent=card
    btn.MouseButton1Click:Connect(function()
        idx=(idx%#options)+1; valLbl.Text=options[idx]
        if callback then callback(options[idx]) end
    end)
    return card
end

local function KeybindPicker(name, default, callback, isRight)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isRight then rightOrder+=1;card.LayoutOrder=rightOrder;card.Parent=RightScroll
    else leftOrder+=1;card.LayoutOrder=leftOrder;card.Parent=LeftScroll end
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.5,0,1,0); nameLbl.BackgroundTransparency=1
    nameLbl.Text=name; nameLbl.TextColor3=SUBTEXT; nameLbl.TextSize=11
    nameLbl.Font=Enum.Font.Gotham; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.Parent=card
    local keyBtn=Instance.new("TextButton")
    keyBtn.Size=UDim2.new(0,60,0,20); keyBtn.Position=UDim2.new(1,-60,0.5,-10)
    keyBtn.BackgroundColor3=PURPLE_DARK; keyBtn.BorderSizePixel=0
    keyBtn.Text="["..default.."]"; keyBtn.TextColor3=PURPLE
    keyBtn.TextSize=11; keyBtn.Font=Enum.Font.GothamBold; keyBtn.Parent=card
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,4)
    local listening=false
    keyBtn.MouseButton1Click:Connect(function()
        listening=true; keyBtn.Text="[...]"; keyBtn.TextColor3=TEXT
    end)
    UserInputService.InputBegan:Connect(function(inp,gpe)
        if not listening then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            listening=false
            local keyName=inp.KeyCode.Name
            keyBtn.Text="["..keyName.."]"; keyBtn.TextColor3=PURPLE
            if callback then callback(keyName) end
        end
    end)
    return card
end

local function TextLabel(text, isRight)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.Visible=false
    if isRight then rightOrder+=1;f.LayoutOrder=rightOrder;f.Parent=RightScroll
    else leftOrder+=1;f.LayoutOrder=leftOrder;f.Parent=LeftScroll end
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=text; lbl.TextColor3=SUBTEXT; lbl.TextSize=11
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=f
    return f
end

-- ══════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════
local tCamlock  = makeTabBtn("camlock",  1)
local tVisuals  = makeTabBtn("visuals",  2)
local tMovement = makeTabBtn("movement", 3)
local tSettings = makeTabBtn("settings", 4)
local tConfig   = makeTabBtn("config",   5)

local function addL(t,i) table.insert(t.leftItems,  i) end
local function addR(t,i) table.insert(t.rightItems, i) end

-- ══════════════════════════════════════════
--  CAMLOCK TAB
-- ══════════════════════════════════════════
addL(tCamlock, SectionLabel("Aim Assist Settings", false))

local aimRow, setAimEnabled = Toggle(
    "Enable", state.camlockKeybind, state.aimEnabled,
    function(on) state.aimEnabled=on end, false)
addL(tCamlock, aimRow)

addL(tCamlock, Toggle("Sticky Aim","",state.stickyAim,function(on)
    state.stickyAim=on; stickyTarget=nil
end, false))

addL(tCamlock, Dropdown("Type",{"Camera","Mouse"},"Camera",function(v) end,false))
addL(tCamlock, Dropdown("Target Method",
    {"Closest To Mouse","Closest To Camera","Lowest Health"},
    state.aimMethod, function(v) state.aimMethod=v end, false))
addL(tCamlock, Dropdown("Camlock Body Part",
    {"Head","HumanoidRootPart","Torso"},
    state.camlockPart, function(v)
        state.camlockPart=v; state.aimPart=v; stickyTarget=nil
    end, false))
addL(tCamlock, Toggle("Show FOV","",state.showFov,function(on) state.showFov=on end, false))
addL(tCamlock, Toggle("Use FOV","",state.useFov,function(on) state.useFov=on end, false))
addL(tCamlock, Slider("Radius",10,400,state.aimFov,"px",function(v) state.aimFov=v end, false))

addR(tCamlock, SectionLabel("Advanced Settings", true))
addR(tCamlock, Toggle("Use Advanced","Custom",state.useAdvanced,function(on) state.useAdvanced=on end, true))
addR(tCamlock, Slider("Predict X",0,10,state.predictX,"",function(v) state.predictX=v end, true))
addR(tCamlock, Slider("Predict Y",0,10,state.predictY,"",function(v) state.predictY=v end, true))
addR(tCamlock, Toggle("Enable Smoothing","",state.smoothingOn,function(on) state.smoothingOn=on end, true))
addR(tCamlock, Slider("Smoothing X",1,20,state.smoothX,"",function(v) state.smoothX=v end, true))
addR(tCamlock, Slider("Smoothing Y",1,20,state.smoothY,"",function(v) state.smoothY=v end, true))
addR(tCamlock, Dropdown("Style",{"Linear","Quadratic","Sine"},state.camlockStyle,function(v) state.camlockStyle=v end, true))
addR(tCamlock, SectionLabel("Keybind and Mode", true))
addR(tCamlock, KeybindPicker("Aimlock Key",state.camlockKeybind,function(key) state.camlockKeybind=key end, true))

local modeCard = Instance.new("Frame")
modeCard.Size = UDim2.new(1,0,0,46)
modeCard.BackgroundTransparency = 1
modeCard.Visible = false
rightOrder+=1; modeCard.LayoutOrder=rightOrder; modeCard.Parent=RightScroll
table.insert(tCamlock.rightItems, modeCard)

local modeLbl = Instance.new("TextLabel")
modeLbl.Size=UDim2.new(1,0,0,16); modeLbl.BackgroundTransparency=1
modeLbl.Text="Key Mode"; modeLbl.TextColor3=SUBTEXT; modeLbl.TextSize=11
modeLbl.Font=Enum.Font.Gotham; modeLbl.TextXAlignment=Enum.TextXAlignment.Left
modeLbl.Parent=modeCard

local modeRow = Instance.new("Frame")
modeRow.Size=UDim2.new(1,0,0,26); modeRow.Position=UDim2.new(0,0,0,18)
modeRow.BackgroundTransparency=1; modeRow.Parent=modeCard

local modeLayout = Instance.new("UIListLayout")
modeLayout.FillDirection=Enum.FillDirection.Horizontal
modeLayout.SortOrder=Enum.SortOrder.LayoutOrder
modeLayout.Padding=UDim.new(0,4)
modeLayout.Parent=modeRow

local modeBtns = {}
local MODES = {"Hold","Toggle","OnePress"}

local function refreshModeBtns()
    for _, mb in modeBtns do
        local active = (mb.Name == state.camlockMode)
        mb.BackgroundColor3 = active and PURPLE or PURPLE_DARK
        mb.TextColor3       = active and TEXT   or SUBTEXT
    end
end

for i, modeName in MODES do
    local mb = Instance.new("TextButton")
    mb.Name             = modeName
    mb.Size             = UDim2.new(0, 84, 1, 0)
    mb.BackgroundColor3 = PURPLE_DARK
    mb.BorderSizePixel  = 0
    mb.Text             = modeName
    mb.TextColor3       = SUBTEXT
    mb.TextSize         = 10
    mb.Font             = Enum.Font.GothamSemibold
    mb.LayoutOrder      = i
    mb.Parent           = modeRow
    Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 4)
    mb.MouseButton1Click:Connect(function()
        state.camlockMode    = modeName
        state.camlockToggle  = (modeName == "Toggle")
        state.camlockEnabled = false
        onePressActive       = false
        onePressUsed         = false
        stickyTarget         = nil
        refreshModeBtns()
    end)
    table.insert(modeBtns, mb)
end

refreshModeBtns()

local modeHints = {
    Hold     = "Hold key to lock, release to unlock",
    Toggle   = "Press key to lock on/off",
    OnePress = "Press key to snap aim once instantly",
}
local modeHintLbl = Instance.new("TextLabel")
modeHintLbl.Size=UDim2.new(1,0,0,14)
modeHintLbl.BackgroundTransparency=1
modeHintLbl.Text=modeHints[state.camlockMode]
modeHintLbl.TextColor3=Color3.fromRGB(100,80,140)
modeHintLbl.TextSize=9
modeHintLbl.Font=Enum.Font.Gotham
modeHintLbl.TextXAlignment=Enum.TextXAlignment.Left
modeHintLbl.Visible=false
rightOrder+=1; modeHintLbl.LayoutOrder=rightOrder; modeHintLbl.Parent=RightScroll
table.insert(tCamlock.rightItems, modeHintLbl)

RunService.Heartbeat:Connect(function()
    modeHintLbl.Text = modeHints[state.camlockMode] or ""
end)

-- ══════════════════════════════════════════
--  VISUALS TAB
-- ══════════════════════════════════════════
addL(tVisuals, SectionLabel("ESP", false))
addL(tVisuals, Toggle("ESP Master","",state.esp,function(on)
    state.esp=on
    if not on then
        for plr,d in espDrawings do hideDrawings(d) end
        for _,plr in Players:GetPlayers() do
            if plr~=Player and plr.Character then
                for _,p in plr.Character:GetDescendants() do
                    if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic end
                end
            end
        end
    end
end, false))
addL(tVisuals, Toggle("Boxes","",state.espBoxes,function(on) state.espBoxes=on end, false))
addL(tVisuals, Toggle("Names","",state.espNames,function(on) state.espNames=on end, false))
addL(tVisuals, Toggle("Health","",state.espHealth,function(on) state.espHealth=on end, false))
addL(tVisuals, Toggle("Tracers","",state.espTracers,function(on)
    state.espTracers=on
    if not on then for plr,d in espDrawings do if d.tracer then d.tracer.Visible=false end end end
end, false))
addL(tVisuals, Toggle("Chams","",state.chams,function(on)
    state.chams=on
    if not on then
        for _,plr in Players:GetPlayers() do
            if plr~=Player and plr.Character then
                for _,p in plr.Character:GetDescendants() do
                    if p:IsA("BasePart") then p.Material=Enum.Material.SmoothPlastic end
                end
            end
        end
    end
end, false))

if not hasDrawing then
    addL(tVisuals, TextLabel("Drawing API not available", false))
    addL(tVisuals, TextLabel("ESP requires executor with Drawing", false))
end

addR(tVisuals, SectionLabel("World", true))
addR(tVisuals, Toggle("Fullbright","",state.fullbright,function(on)
    state.fullbright=on
    Lighting.Brightness=on and 10 or 1
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end, true))
addR(tVisuals, Toggle("No Fog","",state.noFog,function(on)
    state.noFog=on
    local a=Lighting:FindFirstChildOfClass("Atmosphere")
    if a then a.Density=on and 0 or 0.395 end
end, true))
addR(tVisuals, Toggle("No Shadows","",state.noShadows,function(on)
    state.noShadows=on; Lighting.GlobalShadows=not on
end, true))

addR(tVisuals, SectionLabel("ESP Preview", true))

local espPreviewFrame=Instance.new("Frame")
espPreviewFrame.Size=UDim2.new(1,0,0,170); espPreviewFrame.BackgroundColor3=BG3
espPreviewFrame.BorderSizePixel=0; espPreviewFrame.Visible=false
rightOrder+=1; espPreviewFrame.LayoutOrder=rightOrder; espPreviewFrame.Parent=RightScroll
Instance.new("UICorner",espPreviewFrame).CornerRadius=UDim.new(0,6)
local epStroke=Instance.new("UIStroke",espPreviewFrame)
epStroke.Color=PURPLE_DARK; epStroke.Thickness=1
table.insert(tVisuals.rightItems, espPreviewFrame)

local previewBox=Instance.new("Frame")
previewBox.Size=UDim2.new(0,30,0,72); previewBox.Position=UDim2.new(0.5,-15,0,44)
previewBox.BackgroundTransparency=1; previewBox.BorderSizePixel=0; previewBox.Parent=espPreviewFrame
local previewBoxStroke=Instance.new("UIStroke",previewBox)
previewBoxStroke.Color=PURPLE; previewBoxStroke.Thickness=1.5

local previewHead=Instance.new("Frame")
previewHead.Size=UDim2.new(0,16,0,16); previewHead.Position=UDim2.new(0.5,-8,0,24)
previewHead.BackgroundColor3=BG3; previewHead.BorderSizePixel=0; previewHead.Parent=espPreviewFrame
Instance.new("UICorner",previewHead).CornerRadius=UDim.new(1,0)
local previewHeadStroke=Instance.new("UIStroke",previewHead)
previewHeadStroke.Color=PURPLE; previewHeadStroke.Thickness=1.5

local previewName=Instance.new("TextLabel")
previewName.Size=UDim2.new(1,0,0,14); previewName.Position=UDim2.new(0,0,0,6)
previewName.BackgroundTransparency=1; previewName.Text="Enemy"
previewName.TextColor3=PURPLE; previewName.TextSize=11; previewName.Font=Enum.Font.GothamBold
previewName.TextXAlignment=Enum.TextXAlignment.Center; previewName.Parent=espPreviewFrame

local previewHpBg=Instance.new("Frame")
previewHpBg.Size=UDim2.new(0,4,0,72); previewHpBg.Position=UDim2.new(0.5,-23,0,44)
previewHpBg.BackgroundColor3=Color3.fromRGB(30,0,0); previewHpBg.BorderSizePixel=0
previewHpBg.Parent=espPreviewFrame
Instance.new("UICorner",previewHpBg).CornerRadius=UDim.new(0,2)

local previewHpFill=Instance.new("Frame")
previewHpFill.Size=UDim2.new(1,0,0.72,0); previewHpFill.Position=UDim2.new(0,0,0.28,0)
previewHpFill.BackgroundColor3=GREEN; previewHpFill.BorderSizePixel=0
previewHpFill.Parent=previewHpBg
Instance.new("UICorner",previewHpFill).CornerRadius=UDim.new(0,2)

local previewTracer=Instance.new("Frame")
previewTracer.Size=UDim2.new(0,1.5,0,30); previewTracer.Position=UDim2.new(0.5,0,1,-30)
previewTracer.AnchorPoint=Vector2.new(0.5,0); previewTracer.BackgroundColor3=PURPLE
previewTracer.BorderSizePixel=0; previewTracer.Parent=espPreviewFrame

local previewHpLabel=Instance.new("TextLabel")
previewHpLabel.Size=UDim2.new(1,0,0,14); previewHpLabel.Position=UDim2.new(0,0,0,118)
previewHpLabel.BackgroundTransparency=1; previewHpLabel.Text="72 HP"
previewHpLabel.TextColor3=GREEN; previewHpLabel.TextSize=10; previewHpLabel.Font=Enum.Font.GothamBold
previewHpLabel.TextXAlignment=Enum.TextXAlignment.Center; previewHpLabel.Parent=espPreviewFrame

local previewHpDir,previewHpPct = -1, 0.72
RunService.Heartbeat:Connect(function(dt)
    if not espPreviewFrame.Visible then return end
    previewBox.Visible     = state.espBoxes
    previewName.Visible    = state.espNames
    previewHpBg.Visible    = state.espHealth
    previewHpFill.Visible  = state.espHealth
    previewHpLabel.Visible = state.espHealth
    previewTracer.Visible  = state.espTracers
    previewBoxStroke.Color  = state.espBoxes and PURPLE or Color3.fromRGB(40,40,55)
    previewHeadStroke.Color = state.espBoxes and PURPLE or Color3.fromRGB(40,40,55)
    previewHpPct = previewHpPct + previewHpDir * dt * 0.08
    if previewHpPct<=0.1 then previewHpDir=1 end
    if previewHpPct>=1.0 then previewHpDir=-1 end
    previewHpFill.Size=UDim2.new(1,0,previewHpPct,0)
    previewHpFill.Position=UDim2.new(0,0,1-previewHpPct,0)
    local hpInt=math.floor(previewHpPct*100)
    previewHpLabel.Text=hpInt.." HP"
    local hpC=Color3.fromRGB(math.round(255*(1-previewHpPct)),math.round(200*previewHpPct),0)
    previewHpFill.BackgroundColor3=hpC; previewHpLabel.TextColor3=hpC
end)

-- ══════════════════════════════════════════
--  MOVEMENT TAB
-- ══════════════════════════════════════════
addL(tMovement, SectionLabel("Movement", false))
addL(tMovement, Toggle("Fly","",state.flyEnabled,function(on)
    state.flyEnabled=on
    local hrp=getHRP(); local hum=getHum()
    if not hrp or not hum then return end
    if on then
        hum.PlatformStand=true
        bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero
        bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
        bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
        bg.P=1e4; bg.Parent=hrp
    else
        if bv then bv:Destroy();bv=nil end
        if bg then bg:Destroy();bg=nil end
        hum.PlatformStand=false
    end
end, false))
addL(tMovement, Toggle("Noclip","",state.noclip,function(on) state.noclip=on end, false))
addL(tMovement, Toggle("Infinite Jump","",state.infiniteJump,function(on) state.infiniteJump=on end, false))
addL(tMovement, Toggle("Speed Boost","",state.speedBoost,function(on) state.speedBoost=on end, false))
addL(tMovement, Slider("Walk Speed",8,200,state.walkSpeed,"",function(v) state.walkSpeed=v end, false))
addL(tMovement, Slider("Jump Power",0,300,state.jumpPower,"",function(v) state.jumpPower=v end, false))

addR(tMovement, SectionLabel("Player", true))
addR(tMovement, Toggle("God Mode","",state.godMode,function(on) state.godMode=on end, true))
addR(tMovement, Toggle("Anti-AFK","",state.antiAfk,function(on) state.antiAfk=on end, true))
addR(tMovement, Toggle("Invisible","",state.invisible,function(on)
    state.invisible=on
    local char=Player.Character; if not char then return end
    for _,p in char:GetDescendants() do
        if p:IsA("BasePart") then p.Transparency=on and 1 or 0 end
    end
end, true))

-- ══════════════════════════════════════════
--  SETTINGS TAB
-- ══════════════════════════════════════════
addL(tSettings, SectionLabel("Interface", false))
addL(tSettings, Slider("UI Opacity",10,100,100,"%",function(v)
    Win.BackgroundTransparency=1-(v/100) end, false))
addL(tSettings, Slider("Tracer Thickness",1,5,1,"px",function(v)
    tracerThickness=v
    for plr,d in espDrawings do
        if d.tracer then pcall(function() d.tracer.Thickness=v end) end
    end
end, false))

addL(tSettings, SectionLabel("Minimap", false))
addL(tSettings, Toggle("Show Minimap","",state.minimapEnabled,function(on)
    state.minimapEnabled=on; MinimapFrame.Visible=on
end, false))
addL(tSettings, Slider("Radar Range",50,1000,state.minimapRange,"st",function(v)
    state.minimapRange=v
    mmLabel.Text="RADAR "..tostring(v).."st"
end, false))
addL(tSettings, Toggle("Show Game Map","",state.showGameMap,function(on)
    state.showGameMap=on; mapLayer.Visible=on
end, false))

local rescanBtn = Instance.new("TextButton")
rescanBtn.Size=UDim2.new(1,0,0,28); rescanBtn.BackgroundColor3=PURPLE_DARK
rescanBtn.BorderSizePixel=0; rescanBtn.Text="Rescan Game Map"
rescanBtn.TextColor3=PURPLE; rescanBtn.TextSize=11; rescanBtn.Font=Enum.Font.GothamSemibold
rescanBtn.Visible=false
leftOrder+=1; rescanBtn.LayoutOrder=leftOrder; rescanBtn.Parent=LeftScroll
Instance.new("UICorner",rescanBtn).CornerRadius=UDim.new(0,5)
rescanBtn.MouseButton1Click:Connect(function()
    rescanBtn.Text="Scanning..."; rescanBtn.TextColor3=TEXT
    task.spawn(function()
        scanMap(); applyMapGrid()
        rescanBtn.Text="Rescan Game Map"; rescanBtn.TextColor3=PURPLE
    end)
end)
table.insert(tSettings.leftItems, rescanBtn)

addR(tSettings, SectionLabel("Keybinds", true))
addR(tSettings, TextLabel("GUI Toggle:  [RShift]", true))
addR(tSettings, TextLabel("Fly:         [toggle via UI]", true))
addR(tSettings, TextLabel("Aimlock:     [see camlock tab]", true))

addR(tSettings, SectionLabel("Whitelist Info", true))
addR(tSettings, TextLabel("Status: Whitelisted", true))
addR(tSettings, TextLabel("ID: " .. rbxid, true))

-- ══════════════════════════════════════════
--  CONFIG TAB
-- ══════════════════════════════════════════
addL(tConfig, SectionLabel("Config", false))

local saveRow=Instance.new("TextButton")
saveRow.Size=UDim2.new(1,0,0,32); saveRow.BackgroundColor3=PURPLE_DARK
saveRow.BorderSizePixel=0; saveRow.Text="Save Config"
saveRow.TextColor3=PURPLE; saveRow.TextSize=12; saveRow.Font=Enum.Font.GothamSemibold
saveRow.Visible=false; leftOrder+=1; saveRow.LayoutOrder=leftOrder; saveRow.Parent=LeftScroll
Instance.new("UICorner",saveRow).CornerRadius=UDim.new(0,6)
saveRow.MouseButton1Click:Connect(function()
    saveConfig(); saveRow.Text="Saved!"; saveRow.TextColor3=GREEN
    task.delay(1.5,function() saveRow.Text="Save Config"; saveRow.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems, saveRow)

local loadRow=Instance.new("TextButton")
loadRow.Size=UDim2.new(1,0,0,32); loadRow.BackgroundColor3=PURPLE_DARK
loadRow.BorderSizePixel=0; loadRow.Text="Load Config"
loadRow.TextColor3=PURPLE; loadRow.TextSize=12; loadRow.Font=Enum.Font.GothamSemibold
loadRow.Visible=false; leftOrder+=1; loadRow.LayoutOrder=leftOrder; loadRow.Parent=LeftScroll
Instance.new("UICorner",loadRow).CornerRadius=UDim.new(0,6)
loadRow.MouseButton1Click:Connect(function()
    loadConfig(); loadRow.Text="Loaded!"; loadRow.TextColor3=GREEN
    task.delay(1.5,function() loadRow.Text="Load Config"; loadRow.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems, loadRow)

addL(tConfig, TextLabel("Config auto-saves on close.", false))
addL(tConfig, TextLabel("File: venom_config.json", false))
addR(tConfig, SectionLabel("Auto Save", true))
addR(tConfig, Toggle("Auto Save on Toggle","",true,function(on) end, true))

-- ══════════════════════════════════════════
--  RUNTIME LOOPS
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.flyEnabled or not bv or not bg then return end
    local cam=workspace.CurrentCamera; local dir=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir+=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir-=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir-=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir+=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
    bv.Velocity=dir*60; bg.CFrame=cam.CFrame
end)

RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local char=Player.Character; if not char then return end
    for _,p in char:GetDescendants() do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump then return end
    local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

RunService.Heartbeat:Connect(function()
    local hum=getHum(); if not hum then return end
    if state.godMode then hum.Health=hum.MaxHealth end
    hum.WalkSpeed=state.speedBoost and 80 or state.walkSpeed
    hum.JumpPower=state.jumpPower
end)

Player.Idled:Connect(function()
    if not state.antiAfk then return end
    VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ══════════════════════════════════════════
--  KEYBIND HANDLING
-- ══════════════════════════════════════════
local camlockToggleState = false

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    local ok, kc = pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
    if ok and kc and inp.KeyCode == kc then
        if state.camlockMode == "Hold" then
            state.camlockEnabled = true
        elseif state.camlockMode == "Toggle" then
            camlockToggleState   = not camlockToggleState
            state.camlockEnabled = camlockToggleState
            if not camlockToggleState then stickyTarget=nil end
        elseif state.camlockMode == "OnePress" then
            if not onePressUsed then
                onePressActive = true
                onePressUsed   = true
            end
        end
    end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Win.Visible = not Win.Visible
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    local ok, kc = pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
    if ok and kc and inp.KeyCode == kc then
        if state.camlockMode == "Hold" then
            state.camlockEnabled = false
            stickyTarget         = nil
        elseif state.camlockMode == "OnePress" then
            onePressUsed = false
        end
    end
end)

-- ══════════════════════════════════════════
--  CAMLOCK LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.aimEnabled then return end

    if state.camlockMode == "OnePress" then
        if not onePressActive then return end
        local target = getClosestToMouse(state.camlockPart)
        if target and target.Character then
            local part = target.Character:FindFirstChild(state.camlockPart)
                       or target.Character:FindFirstChild("Head")
            if part then
                local cam    = workspace.CurrentCamera
                local origin = cam.CFrame.Position
                local tPos   = part.Position
                if state.useAdvanced and (state.predictX>0 or state.predictY>0) then
                    local hrp=target.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel=hrp.Velocity
                        tPos=tPos+Vector3.new(
                            vel.X*state.predictX*0.016,
                            vel.Y*state.predictY*0.016,
                            vel.Z*state.predictX*0.016)
                    end
                end
                cam.CFrame = CFrame.lookAt(origin, tPos)
            end
        end
        onePressActive = false
        return
    end

    if not state.camlockEnabled then return end

    if stickyTarget then
        local char = stickyTarget.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not stickyTarget.Parent or not char or not hum or hum.Health<=0 then
            stickyTarget=nil
        elseif state.useFov then
            local part=char:FindFirstChild(state.camlockPart) or char:FindFirstChild("Head")
            if part then
                local cam=workspace.CurrentCamera
                local sp, onScreen=cam:WorldToViewportPoint(part.Position)
                if not onScreen then
                    stickyTarget=nil
                elseif state.stickyAim then
                    local dist=(Vector2.new(sp.X,sp.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                    if dist>state.aimFov*3 then stickyTarget=nil end
                end
            end
        end
    end

    if not stickyTarget then
        stickyTarget = getClosestToMouse(state.camlockPart)
    elseif not state.stickyAim then
        local fresh = getClosestToMouse(state.camlockPart)
        if fresh then stickyTarget=fresh end
    end

    local target=stickyTarget
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(state.camlockPart)
               or target.Character:FindFirstChild("Head")
    if not part then return end

    local cam       = workspace.CurrentCamera
    local origin    = cam.CFrame.Position
    local targetPos = part.Position

    if state.useAdvanced and (state.predictX>0 or state.predictY>0) then
        local hrp=target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel=hrp.Velocity
            targetPos=targetPos+Vector3.new(
                vel.X*state.predictX*0.016,
                vel.Y*state.predictY*0.016,
                vel.Z*state.predictX*0.016)
        end
    end

    local targetCF = CFrame.lookAt(origin, targetPos)
    if state.useAdvanced and state.smoothingOn then
        local smooth=math.clamp(state.smoothX/20,0.01,1)
        if     state.camlockStyle=="Linear"    then cam.CFrame=cam.CFrame:Lerp(targetCF,smooth)
        elseif state.camlockStyle=="Quadratic" then cam.CFrame=cam.CFrame:Lerp(targetCF,smooth*smooth)
        elseif state.camlockStyle=="Sine"      then cam.CFrame=cam.CFrame:Lerp(targetCF,math.sin(smooth*math.pi/2))
        end
    else
        cam.CFrame = targetCF
    end
end)

-- ══════════════════════════════════════════
--  ESP LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    for plr,_ in espDrawings do
        if not plr or not plr.Parent then cleanupESPForPlayer(plr) end
    end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        if not state.esp then
            if espDrawings[plr] then hideDrawings(espDrawings[plr]) end
            continue
        end
        updateESPForPlayer(plr)
    end
end)

-- ══════════════════════════════════════════
--  MINIMAP LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    MinimapFrame.Visible = state.minimapEnabled
    mapLayer.Visible     = state.showGameMap
    if not state.minimapEnabled then return end
    local selfHRP = getHRP()
    if not selfHRP then return end
    local selfPos  = selfHRP.Position
    local cam      = workspace.CurrentCamera
    local _,camY,_ = cam.CFrame:ToEulerAnglesYXZ()
    if mapScanned then
        local normX = (selfPos.X - mapMinX) / math.max(mapMaxX - mapMinX, 1)
        local normZ = (selfPos.Z - mapMinZ) / math.max(mapMaxZ - mapMinZ, 1)
        local offX  = (0.5 - normX) * MINIMAP_SIZE
        local offZ  = (0.5 - normZ) * MINIMAP_SIZE
        mapLayer.Position = UDim2.new(0, offX, 0, offZ)
    end
    local dotIdx = 0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1
        local dot=getMMDot(dotIdx)
        dot.Visible=true
        local dn=dot:FindFirstChildOfClass("TextLabel")
        if dn then dn.Text=plr.Name end
        local offset=hrp.Position-selfPos
        local rotX  = offset.X*math.cos(camY)+offset.Z*math.sin(camY)
        local rotZ  =-offset.X*math.sin(camY)+offset.Z*math.cos(camY)
        local px=math.clamp(rotX/state.minimapRange,-1,1)*(MINIMAP_SIZE/2)
        local py=math.clamp(rotZ/state.minimapRange,-1,1)*(MINIMAP_SIZE/2)
        dot.Position=UDim2.new(0.5,px,0.5,py)
        if plr==stickyTarget then
            dot.BackgroundColor3=PURPLE
        else
            local ok,myTeam=pcall(function() return Player.Team end)
            local ok2,plrTeam=pcall(function() return plr.Team end)
            if ok and ok2 and myTeam and plrTeam and myTeam==plrTeam then
                dot.BackgroundColor3=GREEN
            else
                dot.BackgroundColor3=RED
            end
        end
    end
    for i=dotIdx+1,#mmDots do mmDots[i].Visible=false end
end)

-- ══════════════════════════════════════════
--  PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr) cleanupESPForPlayer(plr) end)

Player.CharacterAdded:Connect(function()
    state.flyEnabled=false; stickyTarget=nil
    onePressActive=false; onePressUsed=false
    bv=nil; bg=nil
end)

game:BindToClose(function() saveConfig(); cleanupAllESP() end)

-- ══════════════════════════════════════════
--  ACTIVATE FIRST TAB
-- ══════════════════════════════════════════
activateTab(tCamlock)

print("[Venom.lol v1.7] Loaded - Whitelisted: " .. rbxid)
print("Mode: "..state.camlockMode.." | Key: "..state.camlockKeybind.." | RShift = toggle GUI")
