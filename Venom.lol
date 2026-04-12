-- Venom.lol GUI - Fixed & Complete v1.5
-- LocalScript → StarterGui

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
local Camera    = workspace.CurrentCamera

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
local GREEN       = Color3.fromRGB(50, 220, 100)
local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local CONFIG_FILE = "venom_config.json"

-- ══════════════════════════════════════════
--  DRAWING API CHECK
-- ══════════════════════════════════════════
local hasDrawing = false
pcall(function()
    local t = Drawing.new("Square")
    t:Remove()
    hasDrawing = true
end)

-- ══════════════════════════════════════════
--  STATE
-- ══════════════════════════════════════════
local state = {
    aimEnabled      = false,
    stickyAim       = false,
    aimPart         = "Head",
    aimMethod       = "Closest To Mouse",
    aimFov          = 50,
    showFov         = false,
    useFov          = true,

    camlockEnabled  = false,
    camlockKeybind  = "Q",
    camlockToggle   = false,
    camlockPart     = "Head",
    useAdvanced     = false,
    smoothingOn     = false,
    predictX        = 0,
    predictY        = 0,
    smoothX         = 5,
    smoothY         = 5,
    camlockStyle    = "Linear",

    esp             = false,
    espBoxes        = false,
    espNames        = false,
    espHealth       = false,
    espTracers      = false,
    chams           = false,
    fullbright      = false,
    noFog           = false,
    noShadows       = false,

    flyEnabled      = false,
    noclip          = false,
    infiniteJump    = false,
    speedBoost      = false,
    walkSpeed       = 16,
    jumpPower       = 50,

    godMode         = false,
    antiAfk         = false,
    invisible       = false,

    -- Addons
    crosshair       = false,
    crosshairStyle  = "Plus",
    crosshairSize   = 10,
    crosshairColor  = Color3.fromRGB(255, 255, 255),
    hitmarker       = false,
    clickTp         = false,
    sprintEnabled   = false,
    sprintSpeed     = 28,
    thirdPerson     = false,
    tpDistance      = 8,
    espPreview      = true,
    minimap         = true,
}

local bv, bg
local stickyTarget    = nil
local tracerThickness = 1

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
    for _, key in {"box","nameText","healthText","healthBg","tracer"} do
        pcall(function() if d[key] then d[key]:Remove() end end)
    end
end

local function getOrCreateESP(plr)
    if not hasDrawing then return nil end
    if espDrawings[plr] then return espDrawings[plr] end
    local d = {}
    d.box = newDrawing("Square", {
        Visible = false, Color = PURPLE,
        Thickness = 1, Filled = false, Transparency = 1,
    })
    d.nameText = newDrawing("Text", {
        Visible = false, Color = PURPLE, Size = 13,
        Center = true, Outline = true,
        OutlineColor = Color3.new(0,0,0), Transparency = 1,
        Font = Drawing.Fonts and Drawing.Fonts.UI or 0,
    })
    d.healthBg = newDrawing("Square", {
        Visible = false, Color = Color3.fromRGB(30,0,0),
        Thickness = 1, Filled = true, Transparency = 0.4,
    })
    d.healthText = newDrawing("Text", {
        Visible = false, Color = Color3.fromRGB(80,255,80),
        Size = 11, Center = true, Outline = true,
        OutlineColor = Color3.new(0,0,0), Transparency = 1,
        Font = Drawing.Fonts and Drawing.Fonts.UI or 0,
    })
    d.tracer = newDrawing("Line", {
        Visible = false, Color = PURPLE,
        Thickness = tracerThickness, Transparency = 1,
    })
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

    local topWorld    = head.Position + Vector3.new(0, head.Size.Y/2 + 0.1, 0)
    local bottomWorld = hrp.Position  - Vector3.new(0, hrp.Size.Y/2 + 0.3, 0)
    local topSP,_     = Camera:WorldToViewportPoint(topWorld)
    local bottomSP,_  = Camera:WorldToViewportPoint(bottomWorld)
    local hrpSP, vis  = Camera:WorldToViewportPoint(hrp.Position)

    if not vis then hideDrawings(d) return end

    local boxH = math.abs(bottomSP.Y - topSP.Y)
    local boxW = boxH * 0.55
    local boxX = hrpSP.X - boxW/2
    local boxY = topSP.Y

    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
    local hpColor = Color3.fromRGB(
        math.round(255*(1-pct)),
        math.round(200*pct), 0)

    if d.box then
        d.box.Visible  = state.esp and state.espBoxes
        d.box.Position = Vector2.new(boxX, boxY)
        d.box.Size     = Vector2.new(boxW, boxH)
        d.box.Color    = PURPLE
    end
    if d.nameText then
        d.nameText.Visible   = state.esp and state.espNames
        d.nameText.Text      = plr.DisplayName
        d.nameText.Position  = Vector2.new(hrpSP.X, topSP.Y - 16)
    end
    if d.healthBg then
        d.healthBg.Visible   = state.esp and state.espHealth
        d.healthBg.Position  = Vector2.new(boxX - 6, boxY)
        d.healthBg.Size      = Vector2.new(4, boxH)
    end
    if d.healthText then
        d.healthText.Visible  = state.esp and state.espHealth
        d.healthText.Text     = math.floor(pct*100).."%"
        d.healthText.Position = Vector2.new(hrpSP.X, topSP.Y - 28)
        d.healthText.Color    = hpColor
    end
    if d.tracer then
        local vp = Camera.ViewportSize
        d.tracer.Visible    = state.esp and state.espTracers
        d.tracer.From       = Vector2.new(vp.X/2, vp.Y)
        d.tracer.To         = Vector2.new(hrpSP.X, hrpSP.Y)
        d.tracer.Color      = PURPLE
        d.tracer.Thickness  = tracerThickness
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
--  CONFIG SAVE / LOAD
-- ══════════════════════════════════════════
local function saveConfig()
    local data = {}
    for k,v in state do
        if type(v) ~= "userdata" then data[k] = v end
    end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
end

local function loadConfig()
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end
    for k, v in data do
        if state[k] ~= nil and type(state[k]) ~= "userdata" then
            state[k] = v
        end
    end
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
    local closest  = nil
    local closestD = math.huge
    local mp       = Vector2.new(Mouse.X, Mouse.Y)
    local center   = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, plr in Players:GetPlayers() do
        if plr == Player then continue end
        local char = plr.Character
        if not char then continue end
        local part = char:FindFirstChild(partName) or char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenPos     = Vector2.new(sp.X, sp.Y)
        local distFromMouse = (screenPos - mp).Magnitude
        local distFromCenter= (screenPos - center).Magnitude
        local checkDist     = state.aimMethod == "Closest To Mouse"
            and distFromMouse or distFromCenter
        local inFov = not state.useFov or distFromMouse <= state.aimFov
        if inFov and checkDist < closestD then
            closestD = checkDist
            closest  = plr
        end
    end
    return closest
end

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VenomGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ══════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════
local FovCircle = Instance.new("Frame")
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.ZIndex = 10
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1,0)
local FovStroke = Instance.new("UIStroke")
FovStroke.Color = PURPLE
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.2
FovStroke.Parent = FovCircle

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = state.showFov and state.aimEnabled
    if not FovCircle.Visible then return end
    local r = state.aimFov
    FovCircle.Size     = UDim2.new(0, r*2, 0, r*2)
    FovCircle.Position = UDim2.new(0, Mouse.X-r, 0, Mouse.Y-r)
end)

-- ══════════════════════════════════════════
--  CROSSHAIR (Addon)
-- ══════════════════════════════════════════
local crosshairParts = {}

local function buildCrosshair()
    for _, p in crosshairParts do p:Destroy() end
    crosshairParts = {}
    if not state.crosshair then return end
    local s = state.crosshairSize
    local col = state.crosshairColor
    local styles = {
        Plus = {
            { UDim2.new(0,-s,0,-1), UDim2.new(0,s*2,0,2) },
            { UDim2.new(0,-1,0,-s), UDim2.new(0,2,0,s*2) },
        },
        Cross = {
            { UDim2.new(0,-s,0,-1), UDim2.new(0,s*2,0,2) },
            { UDim2.new(0,-s,0,-s), UDim2.new(0,s*2,0,s*2) },
        },
        Dot = {
            { UDim2.new(0,-3,0,-3), UDim2.new(0,6,0,6) },
        },
        Circle = {},
    }
    local lines = styles[state.crosshairStyle] or styles["Plus"]
    for _, ln in lines do
        local f = Instance.new("Frame")
        f.BackgroundColor3 = col
        f.BorderSizePixel  = 0
        f.AnchorPoint      = Vector2.new(0.5, 0.5)
        f.Position         = UDim2.new(0.5,0,0.5,0) + ln[1]
        f.Size             = ln[2]
        f.ZIndex           = 20
        f.Parent           = ScreenGui
        if state.crosshairStyle == "Dot" then
            Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
        end
        table.insert(crosshairParts, f)
    end
    if state.crosshairStyle == "Circle" then
        local f = Instance.new("Frame")
        f.BackgroundTransparency = 1
        f.BorderSizePixel  = 0
        f.AnchorPoint      = Vector2.new(0.5, 0.5)
        f.Position         = UDim2.new(0.5,0,0.5,0)
        f.Size             = UDim2.new(0, s*2, 0, s*2)
        f.ZIndex           = 20
        f.Parent           = ScreenGui
        Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
        local st = Instance.new("UIStroke")
        st.Color     = col
        st.Thickness = 1.5
        st.Parent    = f
        table.insert(crosshairParts, f)
    end
end

-- ══════════════════════════════════════════
--  HITMARKER (Addon)
-- ══════════════════════════════════════════
local hitmarkerActive = false
local hitmarkerFrames = {}

local function showHitmarker()
    if not state.hitmarker then return end
    -- Clear old
    for _, f in hitmarkerFrames do f:Destroy() end
    hitmarkerFrames = {}
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    local offsets = { {-8,-8,8,8}, {8,-8,-8,8} }
    for _, o in offsets do
        local f = Instance.new("Frame")
        f.BackgroundColor3 = Color3.fromRGB(255,80,80)
        f.BorderSizePixel  = 0
        f.AnchorPoint      = Vector2.new(0.5,0.5)
        f.Size             = UDim2.new(0,12,0,1)
        f.Position         = UDim2.new(0, cx, 0, cy)
        f.Rotation         = math.deg(math.atan2(o[4]-o[2], o[3]-o[1]))
        f.ZIndex           = 25
        f.Parent           = ScreenGui
        table.insert(hitmarkerFrames, f)
    end
    task.delay(0.15, function()
        for _, f in hitmarkerFrames do
            if f and f.Parent then f:Destroy() end
        end
        hitmarkerFrames = {}
    end)
end

-- ══════════════════════════════════════════
--  MINIMAP (Addon)
-- ══════════════════════════════════════════
local MinimapFrame = Instance.new("Frame")
MinimapFrame.Name = "Minimap"
MinimapFrame.Size = UDim2.new(0, 160, 0, 160)
MinimapFrame.Position = UDim2.new(1, -170, 1, -170)
MinimapFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MinimapFrame.BorderSizePixel = 0
MinimapFrame.ZIndex = 15
MinimapFrame.Visible = state.minimap
MinimapFrame.Parent = ScreenGui
Instance.new("UICorner", MinimapFrame).CornerRadius = UDim.new(0, 8)
local MinimapStroke = Instance.new("UIStroke")
MinimapStroke.Color = PURPLE
MinimapStroke.Thickness = 1
MinimapStroke.Parent = MinimapFrame

local MinimapLabel = Instance.new("TextLabel")
MinimapLabel.Size = UDim2.new(1,0,0,16)
MinimapLabel.BackgroundTransparency = 1
MinimapLabel.Text = "MINIMAP"
MinimapLabel.TextColor3 = PURPLE
MinimapLabel.TextSize = 9
MinimapLabel.Font = Enum.Font.GothamBold
MinimapLabel.ZIndex = 16
MinimapLabel.Parent = MinimapFrame

-- Minimap area (inner map)
local MinimapArea = Instance.new("Frame")
MinimapArea.Size = UDim2.new(1,-6,1,-20)
MinimapArea.Position = UDim2.new(0,3,0,17)
MinimapArea.BackgroundColor3 = Color3.fromRGB(18,18,28)
MinimapArea.BorderSizePixel = 0
MinimapArea.ZIndex = 16
MinimapArea.ClipsDescendants = true
MinimapArea.Parent = MinimapFrame
Instance.new("UICorner", MinimapArea).CornerRadius = UDim.new(0,4)

-- Self dot
local SelfDot = Instance.new("Frame")
SelfDot.Size = UDim2.new(0,6,0,6)
SelfDot.AnchorPoint = Vector2.new(0.5,0.5)
SelfDot.BackgroundColor3 = Color3.fromRGB(100,200,255)
SelfDot.BorderSizePixel = 0
SelfDot.ZIndex = 18
SelfDot.Parent = MinimapArea
Instance.new("UICorner", SelfDot).CornerRadius = UDim.new(1,0)

-- Pool of enemy dots
local minimapDots = {}
local function getOrMakeMinimapDot(plr)
    if minimapDots[plr] then return minimapDots[plr] end
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,5,0,5)
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundColor3 = Color3.fromRGB(220,50,50)
    dot.BorderSizePixel = 0
    dot.ZIndex = 17
    dot.Visible = false
    dot.Parent = MinimapArea
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    minimapDots[plr] = dot
    return dot
end

-- Map bounds — we auto-detect from workspace
local function getMapBounds()
    local minX, minZ, maxX, maxZ = -500, -500, 500, 500
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(workspace.CurrentCamera) then
            local p = obj.Position
            if p.X < minX then minX = p.X end
            if p.X > maxX then maxX = p.X end
            if p.Z < minZ then minZ = p.Z end
            if p.Z > maxZ then maxZ = p.Z end
        end
    end
    return minX, minZ, maxX, maxZ
end

local mapMinX, mapMinZ, mapMaxX, mapMaxZ = -500,-500,500,500
task.spawn(function()
    task.wait(3) -- wait for world to load
    mapMinX, mapMinZ, mapMaxX, mapMaxZ = getMapBounds()
end)

local function worldToMinimap(worldPos)
    local rx = (worldPos.X - mapMinX) / math.max(mapMaxX - mapMinX, 1)
    local rz = (worldPos.Z - mapMinZ) / math.max(mapMaxZ - mapMinZ, 1)
    return math.clamp(rx, 0, 1), math.clamp(rz, 0, 1)
end

RunService.RenderStepped:Connect(function()
    MinimapFrame.Visible = state.minimap
    if not state.minimap then return end

    local myHRP = getHRP()
    if myHRP then
        local rx, rz = worldToMinimap(myHRP.Position)
        SelfDot.Position = UDim2.new(rx, 0, rz, 0)
    end

    for _, plr in Players:GetPlayers() do
        if plr == Player then continue end
        local dot = getOrMakeMinimapDot(plr)
        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local rx, rz = worldToMinimap(hrp.Position)
            dot.Position = UDim2.new(rx, 0, rz, 0)
            dot.Visible  = true
        else
            dot.Visible = false
        end
    end

    -- cleanup dots for players who left
    for plr, dot in minimapDots do
        if not plr or not plr.Parent then
            dot:Destroy()
            minimapDots[plr] = nil
        end
    end
end)

-- ══════════════════════════════════════════
--  ESP PREVIEW WINDOW
-- ══════════════════════════════════════════
local ESPPreview = Instance.new("Frame")
ESPPreview.Name = "ESPPreview"
ESPPreview.Size = UDim2.new(0, 130, 0, 170)
ESPPreview.Position = UDim2.new(1, -170, 0, 10)
ESPPreview.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ESPPreview.BorderSizePixel = 0
ESPPreview.ZIndex = 15
ESPPreview.Visible = state.espPreview
ESPPreview.Parent = ScreenGui
Instance.new("UICorner", ESPPreview).CornerRadius = UDim.new(0, 6)
local ESPPreviewStroke = Instance.new("UIStroke")
ESPPreviewStroke.Color = PURPLE
ESPPreviewStroke.Thickness = 1
ESPPreviewStroke.Parent = ESPPreview

-- Title bar
local ESPPreviewTitle = Instance.new("Frame")
ESPPreviewTitle.Size = UDim2.new(1,0,0,20)
ESPPreviewTitle.BackgroundColor3 = PURPLE_DARK
ESPPreviewTitle.BorderSizePixel = 0
ESPPreviewTitle.ZIndex = 16
ESPPreviewTitle.Parent = ESPPreview
Instance.new("UICorner", ESPPreviewTitle).CornerRadius = UDim.new(0,6)
local ESPPreviewFix = Instance.new("Frame")
ESPPreviewFix.Size = UDim2.new(1,0,0,6)
ESPPreviewFix.Position = UDim2.new(0,0,1,-6)
ESPPreviewFix.BackgroundColor3 = PURPLE_DARK
ESPPreviewFix.BorderSizePixel = 0
ESPPreviewFix.ZIndex = 16
ESPPreviewFix.Parent = ESPPreviewTitle
local ESPPreviewTitleLbl = Instance.new("TextLabel")
ESPPreviewTitleLbl.Size = UDim2.new(1,-20,1,0)
ESPPreviewTitleLbl.Position = UDim2.new(0,8,0,0)
ESPPreviewTitleLbl.BackgroundTransparency = 1
ESPPreviewTitleLbl.Text = "ESP Preview"
ESPPreviewTitleLbl.TextColor3 = SUBTEXT
ESPPreviewTitleLbl.TextSize = 9
ESPPreviewTitleLbl.Font = Enum.Font.GothamBold
ESPPreviewTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
ESPPreviewTitleLbl.ZIndex = 17
ESPPreviewTitleLbl.Parent = ESPPreviewTitle

local ESPCloseBtn = Instance.new("TextButton")
ESPCloseBtn.Size = UDim2.new(0,14,0,14)
ESPCloseBtn.Position = UDim2.new(1,-16,0.5,-7)
ESPCloseBtn.BackgroundColor3 = Color3.fromRGB(60,20,20)
ESPCloseBtn.Text = "✕"
ESPCloseBtn.TextColor3 = RED
ESPCloseBtn.TextSize = 8
ESPCloseBtn.Font = Enum.Font.GothamBold
ESPCloseBtn.BorderSizePixel = 0
ESPCloseBtn.ZIndex = 18
ESPCloseBtn.Parent = ESPPreviewTitle
Instance.new("UICorner", ESPCloseBtn).CornerRadius = UDim.new(0,3)
ESPCloseBtn.MouseButton1Click:Connect(function()
    state.espPreview = false
    ESPPreview.Visible = false
end)

-- ViewportFrame to show a 3D character preview
local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1,-4, 1,-24)
Viewport.Position = UDim2.new(0,2,0,22)
Viewport.BackgroundColor3 = Color3.fromRGB(14,14,22)
Viewport.BorderSizePixel = 0
Viewport.ZIndex = 16
Viewport.LightColor = Color3.fromRGB(200,180,255)
Viewport.LightDirection = Vector3.new(-1,-1,-1)
Viewport.Ambient = Color3.fromRGB(80,60,120)
Viewport.Parent = ESPPreview
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0,4)

-- ESP overlay elements ON the preview
local prevBox = Instance.new("Frame")
prevBox.BackgroundTransparency = 1
prevBox.BorderSizePixel = 0
prevBox.Size = UDim2.new(0,44,0,80)
prevBox.Position = UDim2.new(0.5,-22,0.5,-34)
prevBox.ZIndex = 20
prevBox.Parent = Viewport
local prevBoxStroke = Instance.new("UIStroke")
prevBoxStroke.Color = PURPLE
prevBoxStroke.Thickness = 1
prevBoxStroke.Parent = prevBox

local prevName = Instance.new("TextLabel")
prevName.Size = UDim2.new(1,0,0,14)
prevName.Position = UDim2.new(0,0,-0.2,0)
prevName.BackgroundTransparency = 1
prevName.Text = "Player"
prevName.TextColor3 = PURPLE
prevName.TextSize = 9
prevName.Font = Enum.Font.GothamBold
prevName.TextXAlignment = Enum.TextXAlignment.Center
prevName.ZIndex = 21
prevName.Parent = prevBox

local prevHealth = Instance.new("TextLabel")
prevHealth.Size = UDim2.new(1,0,0,12)
prevHealth.Position = UDim2.new(0,0,-0.35,0)
prevHealth.BackgroundTransparency = 1
prevHealth.Text = "100%"
prevHealth.TextColor3 = GREEN
prevHealth.TextSize = 8
prevHealth.Font = Enum.Font.Gotham
prevHealth.TextXAlignment = Enum.TextXAlignment.Center
prevHealth.ZIndex = 21
prevHealth.Parent = prevBox

-- Health bar on preview
local prevHpBg = Instance.new("Frame")
prevHpBg.Size = UDim2.new(0,3,1,0)
prevHpBg.Position = UDim2.new(0,-6,0,0)
prevHpBg.BackgroundColor3 = Color3.fromRGB(30,0,0)
prevHpBg.BorderSizePixel = 0
prevHpBg.ZIndex = 21
prevHpBg.Parent = prevBox
Instance.new("UICorner", prevHpBg).CornerRadius = UDim.new(0,2)
local prevHpFill = Instance.new("Frame")
prevHpFill.Size = UDim2.new(1,0,0.75,0)
prevHpFill.AnchorPoint = Vector2.new(0,1)
prevHpFill.Position = UDim2.new(0,0,1,0)
prevHpFill.BackgroundColor3 = GREEN
prevHpFill.BorderSizePixel = 0
prevHpFill.ZIndex = 22
prevHpFill.Parent = prevHpBg
Instance.new("UICorner", prevHpFill).CornerRadius = UDim.new(0,2)

-- Tracer line preview
local prevTracer = Instance.new("Frame")
prevTracer.Size = UDim2.new(0,1,0,30)
prevTracer.Position = UDim2.new(0.5,0,1,-2)
prevTracer.BackgroundColor3 = PURPLE
prevTracer.BorderSizePixel = 0
prevTracer.ZIndex = 20
prevTracer.Parent = Viewport

-- Clone local player character into viewport for preview
local function refreshPreviewChar()
    -- Clear old model
    for _, c in Viewport:GetChildren() do
        if c:IsA("Model") then c:Destroy() end
    end

    local char = Player.Character
    if not char then return end

    -- Try to find another player to preview, fallback to self
    local previewChar = nil
    for _, plr in Players:GetPlayers() do
        if plr ~= Player and plr.Character then
            previewChar = plr.Character
            break
        end
    end
    if not previewChar then previewChar = char end

    local clone = previewChar:Clone()
    -- Remove scripts from clone
    for _, s in clone:GetDescendants() do
        if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("Animator") then
            s:Destroy()
        end
    end

    local hrp = clone:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    clone.Parent = Viewport

    -- Set up camera for viewport
    local vpCam = Instance.new("Camera")
    vpCam.Parent = Viewport
    Viewport.CurrentCamera = vpCam

    if hrp then
        vpCam.CFrame = CFrame.new(hrp.Position + Vector3.new(0,1,5), hrp.Position + Vector3.new(0,1,0))
    end

    -- Update name label
    for _, plr in Players:GetPlayers() do
        if plr ~= Player and plr.Character == previewChar then
            prevName.Text = plr.DisplayName
            break
        end
    end
end

-- Refresh preview every few seconds
task.spawn(function()
    while true do
        task.wait(5)
        if state.espPreview then
            pcall(refreshPreviewChar)
        end
    end
end)

-- Update preview visibility to reflect ESP toggles
RunService.RenderStepped:Connect(function()
    ESPPreview.Visible = state.espPreview
    prevBox.Visible    = state.espBoxes
    prevName.Visible   = state.espNames
    prevHpBg.Visible   = state.espHealth
    prevHpFill.Visible = state.espHealth
    prevHealth.Visible = state.espHealth
    prevTracer.Visible = state.espTracers
end)

task.spawn(function()
    task.wait(2)
    pcall(refreshPreviewChar)
end)

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local Win = Instance.new("Frame")
Win.Name = "VenomWin"
Win.Size = UDim2.new(0, 820, 0, 480)
Win.Position = UDim2.new(0.5,-410,0.5,-240)
Win.BackgroundColor3 = BG
Win.BorderSizePixel = 0
Win.Active = true
Win.Parent = ScreenGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0,8)
local WinStroke = Instance.new("UIStroke")
WinStroke.Color = PURPLE_DIM
WinStroke.Thickness = 1
WinStroke.Parent = Win

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1,0,0,2)
TopAccent.BackgroundColor3 = PURPLE
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 2
TopAccent.Parent = Win
Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0,8)

-- ══════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = BG2
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Win
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,8)

local TFix = Instance.new("Frame")
TFix.Size = UDim2.new(1,0,0,10)
TFix.Position = UDim2.new(0,0,1,-10)
TFix.BackgroundColor3 = BG2
TFix.BorderSizePixel = 0
TFix.Parent = TitleBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0,120,1,0)
Logo.Position = UDim2.new(0,14,0,0)
Logo.BackgroundTransparency = 1
Logo.Text = "venom.lol"
Logo.TextColor3 = PURPLE
Logo.TextSize = 15
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TitleBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(0,60,1,0)
LogoSub.Position = UDim2.new(0,105,0,0)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "v1.5"
LogoSub.TextColor3 = SUBTEXT
LogoSub.TextSize = 10
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,22,0,22)
CloseBtn.Position = UDim2.new(1,-30,0.5,-11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50,20,20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = RED
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)
CloseBtn.MouseButton1Click:Connect(function()
    saveConfig()
    cleanupAllESP()
    ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0,22,0,22)
MinBtn.Position = UDim2.new(1,-56,0.5,-11)
MinBtn.BackgroundColor3 = PURPLE_DARK
MinBtn.Text = "─"
MinBtn.TextColor3 = PURPLE
MinBtn.TextSize = 11
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,4)

local TabBarFrame = Instance.new("Frame")
TabBarFrame.Size = UDim2.new(1,-300,1,0)
TabBarFrame.Position = UDim2.new(0,170,0,0)
TabBarFrame.BackgroundTransparency = 1
TabBarFrame.Parent = TitleBar

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0,2)
TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabBarLayout.Parent = TabBarFrame

-- Drag
local dragging, dragStart, startPos = false,nil,nil
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
    for _, c in Win:GetChildren() do
        if c ~= TitleBar and c ~= TopAccent then c.Visible = not minimised end
    end
    Win.Size = minimised and UDim2.new(0,820,0,36) or UDim2.new(0,820,0,480)
end)

-- ══════════════════════════════════════════
--  BODY
-- ══════════════════════════════════════════
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1,0,1,-36)
Body.Position = UDim2.new(0,0,0,36)
Body.BackgroundTransparency = 1
Body.Parent = Win

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0,280,1,0)
LeftPanel.BackgroundColor3 = BG2
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = Body

local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Size = UDim2.new(1,-4,1,-10)
LeftScroll.Position = UDim2.new(0,4,0,5)
LeftScroll.BackgroundTransparency = 1
LeftScroll.BorderSizePixel = 0
LeftScroll.ScrollBarThickness = 3
LeftScroll.ScrollBarImageColor3 = PURPLE
LeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftScroll.CanvasSize = UDim2.new(0,0,0,0)
LeftScroll.Parent = LeftPanel

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Padding = UDim.new(0,3)
LeftLayout.Parent = LeftScroll

local LeftPad = Instance.new("UIPadding")
LeftPad.PaddingLeft=UDim.new(0,8); LeftPad.PaddingRight=UDim.new(0,8)
LeftPad.PaddingTop=UDim.new(0,8); LeftPad.PaddingBottom=UDim.new(0,8)
LeftPad.Parent = LeftScroll

Instance.new("Frame", Body).Size = UDim2.new(0,1,1,0)
local _d = Body:FindFirstChild("Frame")
if _d then _d.Position=UDim2.new(0,280,0,0); _d.BackgroundColor3=PURPLE_DARK; _d.BorderSizePixel=0 end

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1,-282,1,0)
RightPanel.Position = UDim2.new(0,282,0,0)
RightPanel.BackgroundColor3 = BG
RightPanel.BorderSizePixel = 0
RightPanel.Parent = Body

local RightScroll = Instance.new("ScrollingFrame")
RightScroll.Size = UDim2.new(1,-4,1,-10)
RightScroll.Position = UDim2.new(0,4,0,5)
RightScroll.BackgroundTransparency = 1
RightScroll.BorderSizePixel = 0
RightScroll.ScrollBarThickness = 3
RightScroll.ScrollBarImageColor3 = PURPLE
RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightScroll.CanvasSize = UDim2.new(0,0,0,0)
RightScroll.Parent = RightPanel

local RightLayout = Instance.new("UIListLayout")
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Padding = UDim.new(0,3)
RightLayout.Parent = RightScroll

local RightPad = Instance.new("UIPadding")
RightPad.PaddingLeft=UDim.new(0,10); RightPad.PaddingRight=UDim.new(0,10)
RightPad.PaddingTop=UDim.new(0,8); RightPad.PaddingBottom=UDim.new(0,8)
RightPad.Parent = RightScroll

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabs = {}

local function makeTabBtn(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,76,0,26)
    btn.BackgroundColor3 = BG3
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = SUBTEXT
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = TabBarFrame
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,4)
    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(1,0,0,2)
    underline.Position = UDim2.new(0,0,1,-2)
    underline.BackgroundColor3 = PURPLE
    underline.BorderSizePixel = 0
    underline.Visible = false
    underline.Parent = btn
    Instance.new("UICorner",underline).CornerRadius = UDim.new(1,0)
    local tabData = {btn=btn,underline=underline,leftItems={},rightItems={}}
    table.insert(tabs, tabData)
    btn.MouseButton1Click:Connect(function()
        for _,t in tabs do
            t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
            for _,i in t.leftItems do i.Visible=false end
            for _,i in t.rightItems do i.Visible=false end
        end
        btn.TextColor3=PURPLE; btn.BackgroundColor3=PURPLE_DARK; underline.Visible=true
        for _,i in tabData.leftItems do i.Visible=true end
        for _,i in tabData.rightItems do i.Visible=true end
    end)
    return tabData
end

local function activateTab(tabData)
    for _,t in tabs do
        t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
        for _,i in t.leftItems do i.Visible=false end
        for _,i in t.rightItems do i.Visible=false end
    end
    tabData.btn.TextColor3=PURPLE; tabData.btn.BackgroundColor3=PURPLE_DARK; tabData.underline.Visible=true
    for _,i in tabData.leftItems do i.Visible=true end
    for _,i in tabData.rightItems do i.Visible=true end
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════
local leftOrder  = 0
local rightOrder = 0

local function SectionLabel(text, isRight)
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.Visible=false
    if isRight then rightOrder+=1; f.LayoutOrder=rightOrder; f.Parent=RightScroll
    else leftOrder+=1; f.LayoutOrder=leftOrder; f.Parent=LeftScroll end
    local line=Instance.new("Frame")
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=PURPLE_DARK; line.BorderSizePixel=0; line.Parent=f
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.TextColor3=SUBTEXT; lbl.TextSize=10; lbl.Font=Enum.Font.GothamSemibold
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=f
    return f
end

local function Toggle(name, keybind, default, callback, isRight)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.Visible=false
    if isRight then rightOrder+=1; row.LayoutOrder=rightOrder; row.Parent=RightScroll
    else leftOrder+=1; row.LayoutOrder=leftOrder; row.Parent=LeftScroll end
    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,14,0,14); dot.Position=UDim2.new(0,0,0.5,-7)
    dot.BackgroundColor3=default and PURPLE or Color3.fromRGB(50,50,60)
    dot.BorderSizePixel=0; dot.Parent=row
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-80,1,0); lbl.Position=UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=name
    lbl.TextColor3=default and TEXT or SUBTEXT; lbl.TextSize=12
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    if keybind and keybind~="" then
        local kb=Instance.new("TextLabel")
        kb.Size=UDim2.new(0,60,1,0); kb.Position=UDim2.new(1,-60,0,0)
        kb.BackgroundTransparency=1; kb.Text="["..keybind.."]"
        kb.TextColor3=PURPLE_DIM; kb.TextSize=10; kb.Font=Enum.Font.Gotham
        kb.TextXAlignment=Enum.TextXAlignment.Right; kb.Parent=row
    end
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    local st=default
    local function setState(v)
        st=v
        TweenService:Create(dot,TWEEN_FAST,{BackgroundColor3=st and PURPLE or Color3.fromRGB(50,50,60)}):Play()
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
    if isRight then rightOrder+=1; card.LayoutOrder=rightOrder; card.Parent=RightScroll
    else leftOrder+=1; card.LayoutOrder=leftOrder; card.Parent=LeftScroll end
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.6,0,0,18); nameLbl.BackgroundTransparency=1
    nameLbl.Text=name; nameLbl.TextColor3=SUBTEXT; nameLbl.TextSize=11
    nameLbl.Font=Enum.Font.Gotham; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.Parent=card
    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.4,0,0,18); valLbl.Position=UDim2.new(0.6,0,0,0)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(default)..suffix
    valLbl.TextColor3=PURPLE; valLbl.TextSize=11; valLbl.Font=Enum.Font.GothamBold
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=card
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,0,0,4); track.Position=UDim2.new(0,0,0,26)
    track.BackgroundColor3=Color3.fromRGB(35,25,55); track.BorderSizePixel=0; track.Parent=card
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct0=math.clamp((default-min)/(max-min),0,1)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct0,0,1,0); fill.BackgroundColor3=PURPLE
    fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.BackgroundColor3=Color3.fromRGB(220,200,255)
    knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local sdrag=false
    track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=true end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then sdrag=false end end)
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
    if isRight then rightOrder+=1; card.LayoutOrder=rightOrder; card.Parent=RightScroll
    else leftOrder+=1; card.LayoutOrder=leftOrder; card.Parent=LeftScroll end
    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0.5,0,1,0); valLbl.BackgroundTransparency=1
    valLbl.Text=default; valLbl.TextColor3=TEXT; valLbl.TextSize=11
    valLbl.Font=Enum.Font.Gotham; valLbl.TextXAlignment=Enum.TextXAlignment.Left; valLbl.Parent=card
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.5,0,1,0); nameLbl.Position=UDim2.new(0.5,0,0,0)
    nameLbl.BackgroundTransparency=1; nameLbl.Text=name; nameLbl.TextColor3=SUBTEXT
    nameLbl.TextSize=11; nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextXAlignment=Enum.TextXAlignment.Right; nameLbl.Parent=card
    local idx=1
    for i,v in options do if v==default then idx=i break end end
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=card
    btn.MouseButton1Click:Connect(function()
        idx=(idx%#options)+1; valLbl.Text=options[idx]
        if callback then callback(options[idx]) end
    end)
    return card
end

local function KeybindPicker(name, default, callback, isRight)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isRight then rightOrder+=1; card.LayoutOrder=rightOrder; card.Parent=RightScroll
    else leftOrder+=1; card.LayoutOrder=leftOrder; card.Parent=LeftScroll end
    local nameLbl=Instance.new("TextLabel")
    nameLbl.Size=UDim2.new(0.5,0,1,0); nameLbl.BackgroundTransparency=1; nameLbl.Text=name
    nameLbl.TextColor3=SUBTEXT; nameLbl.TextSize=11; nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.Parent=card
    local keyBtn=Instance.new("TextButton")
    keyBtn.Size=UDim2.new(0,60,0,20); keyBtn.Position=UDim2.new(1,-60,0.5,-10)
    keyBtn.BackgroundColor3=PURPLE_DARK; keyBtn.BorderSizePixel=0
    keyBtn.Text="["..default.."]"; keyBtn.TextColor3=PURPLE
    keyBtn.TextSize=11; keyBtn.Font=Enum.Font.GothamBold; keyBtn.Parent=card
    Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,4)
    local listening=false
    keyBtn.MouseButton1Click:Connect(function() listening=true; keyBtn.Text="[...]"; keyBtn.TextColor3=TEXT end)
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
    if isRight then rightOrder+=1; f.LayoutOrder=rightOrder; f.Parent=RightScroll
    else leftOrder+=1; f.LayoutOrder=leftOrder; f.Parent=LeftScroll end
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=text
    lbl.TextColor3=SUBTEXT; lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=f
    return f
end

-- ══════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════
local tCamlock  = makeTabBtn("camlock",  1)
local tVisuals  = makeTabBtn("visuals",  2)
local tMovement = makeTabBtn("movement", 3)
local tAddons   = makeTabBtn("addons",   4)
local tSettings = makeTabBtn("settings", 5)
local tConfig   = makeTabBtn("config",   6)

local function addL(t,i) table.insert(t.leftItems,i) end
local function addR(t,i) table.insert(t.rightItems,i) end

-- ══════════════════════════════════════════
--  CAMLOCK TAB
-- ══════════════════════════════════════════
addL(tCamlock, SectionLabel("Aim Assist", false))

local aimRow, setAimEnabled = Toggle("Enable", state.camlockKeybind, state.aimEnabled,
    function(on) state.aimEnabled = on end, false)
addL(tCamlock, aimRow)

addL(tCamlock, Toggle("Sticky Aim", "", state.stickyAim, function(on)
    state.stickyAim = on; stickyTarget = nil
end, false))

addL(tCamlock, Dropdown("Type", {"Camera","Mouse"}, "Camera", function(v) end, false))

addL(tCamlock, Dropdown("Target Method",
    {"Closest To Mouse","Closest To Camera","Lowest Health"},
    state.aimMethod, function(v) state.aimMethod=v end, false))

addL(tCamlock, Dropdown("Body Part",
    {"Head","HumanoidRootPart","Torso"},
    state.camlockPart, function(v)
        state.camlockPart=v; state.aimPart=v; stickyTarget=nil
    end, false))

addL(tCamlock, Toggle("Show FOV", "", state.showFov, function(on) state.showFov=on end, false))
addL(tCamlock, Toggle("Use FOV",  "", state.useFov,  function(on) state.useFov=on  end, false))
addL(tCamlock, Slider("FOV Radius", 10, 400, state.aimFov, "px", function(v) state.aimFov=v end, false))

addR(tCamlock, SectionLabel("Advanced", true))
addR(tCamlock, Toggle("Use Advanced", "", state.useAdvanced, function(on) state.useAdvanced=on end, true))
addR(tCamlock, Slider("Predict X", 0, 10, state.predictX, "", function(v) state.predictX=v end, true))
addR(tCamlock, Slider("Predict Y", 0, 10, state.predictY, "", function(v) state.predictY=v end, true))
addR(tCamlock, Toggle("Smoothing", "", state.smoothingOn, function(on) state.smoothingOn=on end, true))
addR(tCamlock, Slider("Smooth X", 1, 20, state.smoothX, "", function(v) state.smoothX=v end, true))
addR(tCamlock, Slider("Smooth Y", 1, 20, state.smoothY, "", function(v) state.smoothY=v end, true))
addR(tCamlock, Dropdown("Style", {"Linear","Quadratic","Sine"}, state.camlockStyle,
    function(v) state.camlockStyle=v end, true))
addR(tCamlock, SectionLabel("Keybind", true))
addR(tCamlock, KeybindPicker("Hold Key", state.camlockKeybind,
    function(k) state.camlockKeybind=k end, true))
addR(tCamlock, Toggle("Toggle Mode", "", state.camlockToggle,
    function(on) state.camlockToggle=on end, true))
addR(tCamlock, TextLabel("OFF = hold key", true))
addR(tCamlock, TextLabel("ON  = press to toggle", true))

-- ══════════════════════════════════════════
--  VISUALS TAB
-- ══════════════════════════════════════════
addL(tVisuals, SectionLabel("ESP", false))
addL(tVisuals, Toggle("ESP Master", "", state.esp, function(on)
    state.esp = on
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
addL(tVisuals, Toggle("Boxes",   "", state.espBoxes,  function(on) state.espBoxes=on  end, false))
addL(tVisuals, Toggle("Names",   "", state.espNames,  function(on) state.espNames=on  end, false))
addL(tVisuals, Toggle("Health",  "", state.espHealth, function(on) state.espHealth=on end, false))
addL(tVisuals, Toggle("Tracers", "", state.espTracers,function(on)
    state.espTracers=on
    if not on then for _,d in espDrawings do if d.tracer then d.tracer.Visible=false end end end
end, false))
addL(tVisuals, Toggle("Chams", "", state.chams, function(on)
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
    addL(tVisuals, TextLabel("⚠ Drawing API unavailable", false))
end

addR(tVisuals, SectionLabel("Overlays", true))
addR(tVisuals, Toggle("ESP Preview Window", "", state.espPreview, function(on)
    state.espPreview=on; ESPPreview.Visible=on
    if on then pcall(refreshPreviewChar) end
end, true))
addR(tVisuals, Toggle("Minimap", "", state.minimap, function(on)
    state.minimap=on; MinimapFrame.Visible=on
end, true))

addR(tVisuals, SectionLabel("World", true))
addR(tVisuals, Toggle("Fullbright", "", state.fullbright, function(on)
    state.fullbright=on
    Lighting.Brightness = on and 10 or 1
    Lighting.Ambient = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end, true))
addR(tVisuals, Toggle("No Fog", "", state.noFog, function(on)
    state.noFog=on
    local a=Lighting:FindFirstChildOfClass("Atmosphere")
    if a then a.Density=on and 0 or 0.395 end
end, true))
addR(tVisuals, Toggle("No Shadows", "", state.noShadows, function(on)
    state.noShadows=on; Lighting.GlobalShadows=not on
end, true))

-- ══════════════════════════════════════════
--  MOVEMENT TAB
-- ══════════════════════════════════════════
addL(tMovement, SectionLabel("Movement", false))
addL(tMovement, Toggle("Fly", "", state.flyEnabled, function(on)
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
        if bv then bv:Destroy(); bv=nil end
        if bg then bg:Destroy(); bg=nil end
        hum.PlatformStand=false
    end
end, false))
addL(tMovement, Toggle("Noclip",       "", state.noclip,       function(on) state.noclip=on       end, false))
addL(tMovement, Toggle("Infinite Jump","", state.infiniteJump, function(on) state.infiniteJump=on end, false))
addL(tMovement, Toggle("Speed Boost",  "", state.speedBoost,   function(on) state.speedBoost=on   end, false))
addL(tMovement, Slider("Walk Speed", 8,  200, state.walkSpeed, "", function(v) state.walkSpeed=v end, false))
addL(tMovement, Slider("Jump Power", 0,  300, state.jumpPower, "", function(v) state.jumpPower=v end, false))

addR(tMovement, SectionLabel("Player", true))
addR(tMovement, Toggle("God Mode", "", state.godMode, function(on) state.godMode=on end, true))
addR(tMovement, Toggle("Anti-AFK", "", state.antiAfk, function(on) state.antiAfk=on end, true))
addR(tMovement, Toggle("Invisible", "", state.invisible, function(on)
    state.invisible=on
    local char=Player.Character
    if not char then return end
    for _,p in char:GetDescendants() do
        if p:IsA("BasePart") then p.Transparency=on and 1 or 0 end
    end
end, true))

-- ══════════════════════════════════════════
--  ADDONS TAB
-- ══════════════════════════════════════════
addL(tAddons, SectionLabel("Crosshair", false))
addL(tAddons, Toggle("Enable Crosshair", "", state.crosshair, function(on)
    state.crosshair=on; buildCrosshair()
end, false))
addL(tAddons, Dropdown("Style", {"Plus","Dot","Circle"}, state.crosshairStyle, function(v)
    state.crosshairStyle=v; buildCrosshair()
end, false))
addL(tAddons, Slider("Size", 4, 30, state.crosshairSize, "px", function(v)
    state.crosshairSize=v; buildCrosshair()
end, false))

addL(tAddons, SectionLabel("Hitmarker", false))
addL(tAddons, Toggle("Enable Hitmarker", "", state.hitmarker, function(on)
    state.hitmarker=on
end, false))
addL(tAddons, TextLabel("Shows X on damage", false))

addL(tAddons, SectionLabel("Click Teleport", false))
addL(tAddons, Toggle("Click TP", "", state.clickTp, function(on)
    state.clickTp=on
end, false))
addL(tAddons, TextLabel("Middle click to teleport", false))

addR(tAddons, SectionLabel("Sprint", true))
addR(tAddons, Toggle("Enable Sprint", "", state.sprintEnabled, function(on)
    state.sprintEnabled=on
end, true))
addR(tAddons, Slider("Sprint Speed", 20, 100, state.sprintSpeed, "", function(v)
    state.sprintSpeed=v
end, true))
addR(tAddons, TextLabel("Hold LeftShift to sprint", true))

addR(tAddons, SectionLabel("Third Person", true))
addR(tAddons, Toggle("Third Person", "", state.thirdPerson, function(on)
    state.thirdPerson=on
    Camera.CameraType = on
        and Enum.CameraType.Custom
        or  Enum.CameraType.Custom
    -- zoom out/in
    if on then
        Camera.FieldOfView = 70
    else
        Camera.FieldOfView = 70
    end
end, true))
addR(tAddons, Slider("Camera Distance", 4, 20, state.tpDistance, "st", function(v)
    state.tpDistance=v
end, true))

addR(tAddons, SectionLabel("Misc Addons", true))
addR(tAddons, Toggle("Show ESP Preview", "", state.espPreview, function(on)
    state.espPreview=on; ESPPreview.Visible=on
end, true))
addR(tAddons, Toggle("Show Minimap", "", state.minimap, function(on)
    state.minimap=on; MinimapFrame.Visible=on
end, true))

-- ══════════════════════════════════════════
--  SETTINGS TAB
-- ══════════════════════════════════════════
addL(tSettings, SectionLabel("Interface", false))
addL(tSettings, Slider("UI Opacity", 10, 100, 100, "%", function(v)
    Win.BackgroundTransparency=1-(v/100)
end, false))
addL(tSettings, Slider("Tracer Thickness", 1, 5, 1, "px", function(v)
    tracerThickness=v
    for _,d in espDrawings do
        if d.tracer then pcall(function() d.tracer.Thickness=v end) end
    end
end, false))
addR(tSettings, SectionLabel("Keybinds", true))
addR(tSettings, TextLabel("GUI Toggle:  [RShift]", true))
addR(tSettings, TextLabel("Fly:         [toggle via UI]", true))
addR(tSettings, TextLabel("Aimlock:     [hold keybind above]", true))
addR(tSettings, TextLabel("Sprint:      [LeftShift]", true))
addR(tSettings, TextLabel("Click TP:    [MiddleClick]", true))

-- ══════════════════════════════════════════
--  CONFIG TAB
-- ══════════════════════════════════════════
addL(tConfig, SectionLabel("Config", false))

local saveRow=Instance.new("TextButton")
saveRow.Size=UDim2.new(1,0,0,32); saveRow.BackgroundColor3=PURPLE_DARK
saveRow.BorderSizePixel=0; saveRow.Text="💾  Save Config"; saveRow.TextColor3=PURPLE
saveRow.TextSize=12; saveRow.Font=Enum.Font.GothamSemibold; saveRow.Visible=false
leftOrder+=1; saveRow.LayoutOrder=leftOrder; saveRow.Parent=LeftScroll
Instance.new("UICorner",saveRow).CornerRadius=UDim.new(0,6)
saveRow.MouseButton1Click:Connect(function()
    saveConfig(); saveRow.Text="✔  Saved!"; saveRow.TextColor3=GREEN
    task.delay(1.5,function() saveRow.Text="💾  Save Config"; saveRow.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems, saveRow)

local loadRow=Instance.new("TextButton")
loadRow.Size=UDim2.new(1,0,0,32); loadRow.BackgroundColor3=PURPLE_DARK
loadRow.BorderSizePixel=0; loadRow.Text="📂  Load Config"; loadRow.TextColor3=PURPLE
loadRow.TextSize=12; loadRow.Font=Enum.Font.GothamSemibold; loadRow.Visible=false
leftOrder+=1; loadRow.LayoutOrder=leftOrder; loadRow.Parent=LeftScroll
Instance.new("UICorner",loadRow).CornerRadius=UDim.new(0,6)
loadRow.MouseButton1Click:Connect(function()
    loadConfig(); loadRow.Text="✔  Loaded!"; loadRow.TextColor3=GREEN
    task.delay(1.5,function() loadRow.Text="📂  Load Config"; loadRow.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems, loadRow)

addL(tConfig, TextLabel("Config auto-saves on close.", false))
addL(tConfig, TextLabel("File: venom_config.json", false))
addR(tConfig, SectionLabel("Info", true))
addR(tConfig, TextLabel("venom.lol v1.5", true))
addR(tConfig, TextLabel("RShift  →  toggle GUI", true))
addR(tConfig, TextLabel("Drawing ESP: " .. (hasDrawing and "✔ supported" or "✘ unavailable"), true))

-- ══════════════════════════════════════════
--  RUNTIME LOOPS
-- ══════════════════════════════════════════

-- Fly
RunService.RenderStepped:Connect(function()
    if not state.flyEnabled or not bv or not bg then return end
    local cam=workspace.CurrentCamera
    local dir=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
    bv.Velocity=dir*60; bg.CFrame=cam.CFrame
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local char=Player.Character
    if not char then return end
    for _,p in char:GetDescendants() do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump then return end
    local hum=getHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Sprint (LeftShift hold, separate from fly shift-down)
RunService.Heartbeat:Connect(function()
    if state.sprintEnabled and not state.flyEnabled then
        local hum=getHum()
        if hum then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                hum.WalkSpeed = state.sprintSpeed
            else
                -- will be overridden below by main speed logic anyway
            end
        end
    end
end)

-- Third person camera distance
RunService.RenderStepped:Connect(function()
    if not state.thirdPerson then return end
    local hrp = getHRP()
    if not hrp then return end
    Camera.CFrame = Camera.CFrame
end)

-- Click teleport (middle mouse)
Mouse.Button3Down:Connect(function()
    if not state.clickTp then return end
    local hrp = getHRP()
    if not hrp then return end
    local target = Mouse.Hit
    if target then
        hrp.CFrame = target * CFrame.new(0, 3, 0)
    end
end)

-- Hitmarker detection (fires when we deal damage — approximate via character health changes)
-- We hook local mouse click and check if a player near crosshair lost health
local lastHealths = {}
RunService.Heartbeat:Connect(function()
    if not state.hitmarker then return end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local prev = lastHealths[plr] or hum.Health
            if hum.Health < prev then
                showHitmarker()
            end
            lastHealths[plr] = hum.Health
        end
    end
end)

-- ══════════════════════════════════════════
--  HEARTBEAT: Speed + GodMode + JumpPower
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local hum=getHum()
    if not hum then return end
    if state.godMode then hum.Health=hum.MaxHealth end
    if state.speedBoost then
        hum.WalkSpeed=80
    elseif not (state.sprintEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not state.flyEnabled) then
        hum.WalkSpeed=state.walkSpeed
    end
    hum.JumpPower=state.jumpPower
end)

-- Anti-AFK
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
    local ok,kc=pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
    if ok and kc and inp.KeyCode==kc then
        if state.camlockToggle then
            camlockToggleState=not camlockToggleState
            state.camlockEnabled=camlockToggleState
        else
            state.camlockEnabled=true
        end
    end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        Win.Visible=not Win.Visible
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if not state.camlockToggle then
        local ok,kc=pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
        if ok and kc and inp.KeyCode==kc then
            state.camlockEnabled=false
            stickyTarget=nil
        end
    end
end)

-- ══════════════════════════════════════════
--  CAMLOCK LOOP  (fixed sticky aim)
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.aimEnabled     then stickyTarget=nil return end
    if not state.camlockEnabled then stickyTarget=nil return end

    -- Validate existing target
    if stickyTarget then
        local char=stickyTarget.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health<=0 or not stickyTarget.Parent then
            stickyTarget=nil
        elseif state.stickyAim and state.useFov then
            local part=char:FindFirstChild(state.camlockPart) or char:FindFirstChild("Head")
            if part then
                local sp,onScreen=Camera:WorldToViewportPoint(part.Position)
                if not onScreen then
                    stickyTarget=nil
                else
                    local dist=(Vector2.new(sp.X,sp.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
                    if dist>state.aimFov*2.5 then stickyTarget=nil end
                end
            end
        end
    end

    -- KEY FIX: sticky ON  → only pick new target when we have none
    --          sticky OFF → always re-evaluate closest each frame
    if state.stickyAim then
        if not stickyTarget then
            stickyTarget = getClosestToMouse(state.camlockPart)
        end
    else
        stickyTarget = getClosestToMouse(state.camlockPart)
    end

    local target=stickyTarget
    if not target or not target.Character then return end

    local part=target.Character:FindFirstChild(state.camlockPart)
             or target.Character:FindFirstChild("Head")
    if not part then return end

    local origin    = Camera.CFrame.Position
    local targetPos = part.Position

    if state.useAdvanced and state.predictX>0 then
        local hrp=target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetPos=targetPos+hrp.Velocity*Vector3.new(
                state.predictX*0.016,
                state.predictY*0.016,
                state.predictX*0.016)
        end
    end

    local targetCF=CFrame.lookAt(origin, targetPos)

    if state.useAdvanced and state.smoothingOn then
        local smooth=math.clamp(state.smoothX/20,0.01,1)
        if state.camlockStyle=="Linear" then
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,smooth)
        elseif state.camlockStyle=="Quadratic" then
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,smooth*smooth)
        elseif state.camlockStyle=="Sine" then
            Camera.CFrame=Camera.CFrame:Lerp(targetCF,math.sin(smooth*math.pi/2))
        end
    else
        Camera.CFrame=targetCF
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
--  PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr)
    cleanupESPForPlayer(plr)
    if minimapDots[plr] then
        minimapDots[plr]:Destroy()
        minimapDots[plr]=nil
    end
    lastHealths[plr]=nil
end)

Player.CharacterAdded:Connect(function()
    state.flyEnabled=false
    stickyTarget=nil
    bv=nil; bg=nil
    task.wait(1)
    pcall(refreshPreviewChar)
end)

game:BindToClose(function()
    saveConfig()
    cleanupAllESP()
end)

-- ══════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════
buildCrosshair()
activateTab(tCamlock)

print("[Venom.lol v1.5] Loaded ✓")
if not hasDrawing then
    warn("[Venom.lol] Drawing API not found — ESP requires a supported executor")
end
print("Hold ["..state.camlockKeybind.."] to aimlock | RShift to toggle GUI")
