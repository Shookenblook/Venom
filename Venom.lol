-- Venom.lol GUI - Fixed & Complete v1.4
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
}

local bv, bg
local stickyTarget    = nil
local tracerThickness = 1

-- ══════════════════════════════════════════
--  ESP DRAWING OBJECTS  (per player)
-- ══════════════════════════════════════════
-- Each entry: { box, nameText, healthText, tracer, healthBg }
local espDrawings = {}

local function newDrawing(objType, props)
    if not hasDrawing then return nil end
    local ok, obj = pcall(Drawing.new, objType)
    if not ok or not obj then return nil end
    for k, v in props do
        pcall(function() obj[k] = v end)
    end
    return obj
end

local function hideDrawings(d)
    if not d then return end
    if d.box       then d.box.Visible       = false end
    if d.nameText  then d.nameText.Visible  = false end
    if d.healthText then d.healthText.Visible = false end
    if d.healthBg  then d.healthBg.Visible  = false end
    if d.tracer    then d.tracer.Visible    = false end
end

local function destroyDrawings(d)
    if not d then return end
    pcall(function() if d.box       then d.box:Remove()       end end)
    pcall(function() if d.nameText  then d.nameText:Remove()  end end)
    pcall(function() if d.healthText then d.healthText:Remove() end end)
    pcall(function() if d.healthBg  then d.healthBg:Remove()  end end)
    pcall(function() if d.tracer    then d.tracer:Remove()    end end)
end

local function getOrCreateESP(plr)
    if not hasDrawing then return nil end
    if espDrawings[plr] then return espDrawings[plr] end

    local d = {}

    -- Box outline
    d.box = newDrawing("Square", {
        Visible           = false,
        Color             = PURPLE,
        Thickness         = 1,
        Filled            = false,
        Transparency      = 1,
    })

    -- Name label
    d.nameText = newDrawing("Text", {
        Visible           = false,
        Color             = PURPLE,
        Size              = 13,
        Center            = true,
        Outline           = true,
        OutlineColor      = Color3.new(0,0,0),
        Transparency      = 1,
        Font              = Drawing.Fonts and Drawing.Fonts.UI or 0,
    })

    -- Health bar background (dark red strip)
    d.healthBg = newDrawing("Square", {
        Visible           = false,
        Color             = Color3.fromRGB(30, 0, 0),
        Thickness         = 1,
        Filled            = true,
        Transparency      = 0.4,
    })

    -- Health text
    d.healthText = newDrawing("Text", {
        Visible           = false,
        Color             = Color3.fromRGB(80, 255, 80),
        Size              = 11,
        Center            = true,
        Outline           = true,
        OutlineColor      = Color3.new(0,0,0),
        Transparency      = 1,
        Font              = Drawing.Fonts and Drawing.Fonts.UI or 0,
    })

    -- Tracer line
    d.tracer = newDrawing("Line", {
        Visible           = false,
        Color             = PURPLE,
        Thickness         = tracerThickness,
        Transparency      = 1,
    })

    espDrawings[plr] = d
    return d
end

local function updateESPForPlayer(plr)
    local d = getOrCreateESP(plr)
    if not d then return end

    local char = plr.Character
    if not char then hideDrawings(d) return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideDrawings(d) return end

    local cam = workspace.CurrentCamera

    -- We use Head top and HRP bottom to build the box
    local topWorld    = head.Position + Vector3.new(0, head.Size.Y / 2 + 0.1, 0)
    local bottomWorld = hrp.Position  - Vector3.new(0, hrp.Size.Y / 2 + 0.3, 0)

    local topSP,    topVis    = cam:WorldToViewportPoint(topWorld)
    local bottomSP, bottomVis = cam:WorldToViewportPoint(bottomWorld)
    local hrpSP,    hrpVis   = cam:WorldToViewportPoint(hrp.Position)

    -- Only show if at least HRP is on screen
    if not hrpVis then hideDrawings(d) return end

    local boxH   = math.abs(bottomSP.Y - topSP.Y)
    local boxW   = boxH * 0.55  -- typical character aspect
    local boxX   = hrpSP.X - boxW / 2
    local boxY   = topSP.Y

    local showBox    = state.esp and state.espBoxes
    local showName   = state.esp and state.espNames
    local showHealth = state.esp and state.espHealth
    local showTracer = state.esp and state.espTracers

    -- Box
    if d.box then
        d.box.Visible  = showBox
        if showBox then
            d.box.Position = Vector2.new(boxX, boxY)
            d.box.Size     = Vector2.new(boxW, boxH)
            d.box.Color    = PURPLE
        end
    end

    -- Name
    if d.nameText then
        d.nameText.Visible = showName
        if showName then
            d.nameText.Text     = plr.DisplayName
            d.nameText.Position = Vector2.new(hrpSP.X, topSP.Y - 16)
            d.nameText.Color    = PURPLE
        end
    end

    -- Health
    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    local hpColor = Color3.fromRGB(
        math.round(255 * (1 - pct)),
        math.round(200 * pct),
        0
    )

    if d.healthBg then
        d.healthBg.Visible = showHealth
        if showHealth then
            d.healthBg.Position = Vector2.new(boxX - 6, boxY)
            d.healthBg.Size     = Vector2.new(4, boxH)
        end
    end

    if d.healthText then
        -- We draw a filled bar on top of bg instead of text for cleaner look
        -- Re-use healthText as the filled health bar
        d.healthText.Visible = showHealth
        if showHealth then
            -- Actually draw it as a filled square for bar effect
            -- (Drawing.Text doesn't make a bar; we'll show % text above head instead)
            local hpStr = math.floor(pct * 100) .. "%"
            d.healthText.Text     = hpStr
            d.healthText.Position = Vector2.new(hrpSP.X, topSP.Y - 28)
            d.healthText.Color    = hpColor
        end
    end

    -- Tracer
    if d.tracer then
        d.tracer.Visible = showTracer
        if showTracer then
            local vp = cam.ViewportSize
            d.tracer.From      = Vector2.new(vp.X / 2, vp.Y)
            d.tracer.To        = Vector2.new(hrpSP.X, hrpSP.Y)
            d.tracer.Color     = PURPLE
            d.tracer.Thickness = tracerThickness
        end
    end

    -- Chams (still done via material since Drawing can't do 3D)
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
    for plr, _ in espDrawings do
        destroyDrawings(espDrawings[plr])
        espDrawings[plr] = nil
    end
end

-- ══════════════════════════════════════════
--  CONFIG SAVE / LOAD
-- ══════════════════════════════════════════
local function saveConfig()
    local data = {
        aimEnabled     = state.aimEnabled,
        stickyAim      = state.stickyAim,
        aimPart        = state.aimPart,
        aimMethod      = state.aimMethod,
        aimFov         = state.aimFov,
        showFov        = state.showFov,
        useFov         = state.useFov,
        camlockKeybind = state.camlockKeybind,
        camlockToggle  = state.camlockToggle,
        camlockPart    = state.camlockPart,
        useAdvanced    = state.useAdvanced,
        smoothingOn    = state.smoothingOn,
        predictX       = state.predictX,
        predictY       = state.predictY,
        smoothX        = state.smoothX,
        smoothY        = state.smoothY,
        camlockStyle   = state.camlockStyle,
        esp            = state.esp,
        espBoxes       = state.espBoxes,
        espNames       = state.espNames,
        espHealth      = state.espHealth,
        espTracers     = state.espTracers,
        chams          = state.chams,
        fullbright     = state.fullbright,
        noFog          = state.noFog,
        noShadows      = state.noShadows,
        walkSpeed      = state.walkSpeed,
        jumpPower      = state.jumpPower,
        godMode        = state.godMode,
        antiAfk        = state.antiAfk,
    }
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function loadConfig()
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or not raw then return end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or type(data) ~= "table" then return end
    for k, v in data do
        if state[k] ~= nil then state[k] = v end
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
    local cam      = workspace.CurrentCamera
    local mp       = Vector2.new(Mouse.X, Mouse.Y)
    local center   = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, plr in Players:GetPlayers() do
        if plr == Player then continue end
        local char = plr.Character
        if not char then continue end
        local part = char:FindFirstChild(partName) or char:FindFirstChild("Head")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local screenPos      = Vector2.new(sp.X, sp.Y)
        local distFromMouse  = (screenPos - mp).Magnitude
        local distFromCenter = (screenPos - center).Magnitude
        local checkDist      = state.aimMethod == "Closest To Mouse"
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
--  FOV CIRCLE (follows mouse)
-- ══════════════════════════════════════════
local FovCircle = Instance.new("Frame")
FovCircle.BackgroundTransparency = 1
FovCircle.BorderSizePixel = 0
FovCircle.ZIndex = 10
FovCircle.Visible = false
FovCircle.Parent = ScreenGui
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke")
FovStroke.Color = PURPLE
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.2
FovStroke.Parent = FovCircle

RunService.RenderStepped:Connect(function()
    FovCircle.Visible = state.showFov and state.aimEnabled
    if not FovCircle.Visible then return end
    local r = state.aimFov
    FovCircle.Size     = UDim2.new(0, r * 2, 0, r * 2)
    FovCircle.Position = UDim2.new(0, Mouse.X - r, 0, Mouse.Y - r)
end)

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local Win = Instance.new("Frame")
Win.Name = "VenomWin"
Win.Size = UDim2.new(0, 820, 0, 480)
Win.Position = UDim2.new(0.5, -410, 0.5, -240)
Win.BackgroundColor3 = BG
Win.BorderSizePixel = 0
Win.Active = true
Win.Parent = ScreenGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 8)
local WinStroke = Instance.new("UIStroke")
WinStroke.Color = PURPLE_DIM
WinStroke.Thickness = 1
WinStroke.Parent = Win

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.BackgroundColor3 = PURPLE
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 2
TopAccent.Parent = Win
Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(0, 8)

-- ══════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = BG2
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Win
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TFix = Instance.new("Frame")
TFix.Size = UDim2.new(1, 0, 0, 10)
TFix.Position = UDim2.new(0, 0, 1, -10)
TFix.BackgroundColor3 = BG2
TFix.BorderSizePixel = 0
TFix.Parent = TitleBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 120, 1, 0)
Logo.Position = UDim2.new(0, 14, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text = "venom.lol"
Logo.TextColor3 = PURPLE
Logo.TextSize = 15
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = TitleBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(0, 60, 1, 0)
LogoSub.Position = UDim2.new(0, 105, 0, 0)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "v1.4"
LogoSub.TextColor3 = SUBTEXT
LogoSub.TextSize = 10
LogoSub.Font = Enum.Font.Gotham
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = RED
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function()
    saveConfig()
    cleanupAllESP()
    ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -56, 0.5, -11)
MinBtn.BackgroundColor3 = PURPLE_DARK
MinBtn.Text = "─"
MinBtn.TextColor3 = PURPLE
MinBtn.TextSize = 11
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local TabBarFrame = Instance.new("Frame")
TabBarFrame.Size = UDim2.new(1, -300, 1, 0)
TabBarFrame.Position = UDim2.new(0, 170, 0, 0)
TabBarFrame.BackgroundTransparency = 1
TabBarFrame.Parent = TitleBar

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0, 2)
TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabBarLayout.Parent = TabBarFrame

-- Drag
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = inp.Position
        startPos  = Win.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        Win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Minimise
local minimised = false
MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    for _, c in Win:GetChildren() do
        if c ~= TitleBar and c ~= TopAccent then
            c.Visible = not minimised
        end
    end
    Win.Size = minimised
        and UDim2.new(0, 820, 0, 36)
        or  UDim2.new(0, 820, 0, 480)
end)

-- ══════════════════════════════════════════
--  BODY
-- ══════════════════════════════════════════
local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, 0, 1, -36)
Body.Position = UDim2.new(0, 0, 0, 36)
Body.BackgroundTransparency = 1
Body.Parent = Win

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 280, 1, 0)
LeftPanel.BackgroundColor3 = BG2
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = Body

local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Size = UDim2.new(1, -4, 1, -10)
LeftScroll.Position = UDim2.new(0, 4, 0, 5)
LeftScroll.BackgroundTransparency = 1
LeftScroll.BorderSizePixel = 0
LeftScroll.ScrollBarThickness = 3
LeftScroll.ScrollBarImageColor3 = PURPLE
LeftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftScroll.Parent = LeftPanel

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Padding = UDim.new(0, 3)
LeftLayout.Parent = LeftScroll

local LeftPad = Instance.new("UIPadding")
LeftPad.PaddingLeft   = UDim.new(0, 8)
LeftPad.PaddingRight  = UDim.new(0, 8)
LeftPad.PaddingTop    = UDim.new(0, 8)
LeftPad.PaddingBottom = UDim.new(0, 8)
LeftPad.Parent = LeftScroll

local Div = Instance.new("Frame")
Div.Size = UDim2.new(0, 1, 1, 0)
Div.Position = UDim2.new(0, 280, 0, 0)
Div.BackgroundColor3 = PURPLE_DARK
Div.BorderSizePixel = 0
Div.Parent = Body

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -282, 1, 0)
RightPanel.Position = UDim2.new(0, 282, 0, 0)
RightPanel.BackgroundColor3 = BG
RightPanel.BorderSizePixel = 0
RightPanel.Parent = Body

local RightScroll = Instance.new("ScrollingFrame")
RightScroll.Size = UDim2.new(1, -4, 1, -10)
RightScroll.Position = UDim2.new(0, 4, 0, 5)
RightScroll.BackgroundTransparency = 1
RightScroll.BorderSizePixel = 0
RightScroll.ScrollBarThickness = 3
RightScroll.ScrollBarImageColor3 = PURPLE
RightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RightScroll.Parent = RightPanel

local RightLayout = Instance.new("UIListLayout")
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Padding = UDim.new(0, 3)
RightLayout.Parent = RightScroll

local RightPad = Instance.new("UIPadding")
RightPad.PaddingLeft   = UDim.new(0, 10)
RightPad.PaddingRight  = UDim.new(0, 10)
RightPad.PaddingTop    = UDim.new(0, 8)
RightPad.PaddingBottom = UDim.new(0, 8)
RightPad.Parent = RightScroll

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabs = {}

local function makeTabBtn(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 82, 0, 26)
    btn.BackgroundColor3 = BG3
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = SUBTEXT
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamSemibold
    btn.LayoutOrder = order
    btn.Parent = TabBarFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(1, 0, 0, 2)
    underline.Position = UDim2.new(0, 0, 1, -2)
    underline.BackgroundColor3 = PURPLE
    underline.BorderSizePixel = 0
    underline.Visible = false
    underline.Parent = btn
    Instance.new("UICorner", underline).CornerRadius = UDim.new(1, 0)

    local tabData = { btn = btn, underline = underline, leftItems = {}, rightItems = {} }
    table.insert(tabs, tabData)

    btn.MouseButton1Click:Connect(function()
        for _, t in tabs do
            t.btn.TextColor3       = SUBTEXT
            t.btn.BackgroundColor3 = BG3
            t.underline.Visible    = false
            for _, item in t.leftItems  do item.Visible = false end
            for _, item in t.rightItems do item.Visible = false end
        end
        btn.TextColor3       = PURPLE
        btn.BackgroundColor3 = PURPLE_DARK
        underline.Visible    = true
        for _, item in tabData.leftItems  do item.Visible = true end
        for _, item in tabData.rightItems do item.Visible = true end
    end)

    return tabData
end

local function activateTab(tabData)
    for _, t in tabs do
        t.btn.TextColor3       = SUBTEXT
        t.btn.BackgroundColor3 = BG3
        t.underline.Visible    = false
        for _, item in t.leftItems  do item.Visible = false end
        for _, item in t.rightItems do item.Visible = false end
    end
    tabData.btn.TextColor3       = PURPLE
    tabData.btn.BackgroundColor3 = PURPLE_DARK
    tabData.underline.Visible    = true
    for _, item in tabData.leftItems  do item.Visible = true end
    for _, item in tabData.rightItems do item.Visible = true end
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════
local leftOrder  = 0
local rightOrder = 0

local function SectionLabel(text, isRight)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    f.Visible = false
    if isRight then rightOrder += 1; f.LayoutOrder = rightOrder; f.Parent = RightScroll
    else leftOrder += 1; f.LayoutOrder = leftOrder; f.Parent = LeftScroll end
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = PURPLE_DARK
    line.BorderSizePixel = 0
    line.Parent = f
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = SUBTEXT
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    return f
end

local function Toggle(name, keybind, default, callback, isRight)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.Visible = false
    if isRight then rightOrder += 1; row.LayoutOrder = rightOrder; row.Parent = RightScroll
    else leftOrder += 1; row.LayoutOrder = leftOrder; row.Parent = LeftScroll end
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 0, 0.5, -7)
    dot.BackgroundColor3 = default and PURPLE or Color3.fromRGB(50, 50, 60)
    dot.BorderSizePixel = 0
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 3)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = default and TEXT or SUBTEXT
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row
    if keybind and keybind ~= "" then
        local kb = Instance.new("TextLabel")
        kb.Size = UDim2.new(0, 60, 1, 0)
        kb.Position = UDim2.new(1, -60, 0, 0)
        kb.BackgroundTransparency = 1
        kb.Text = "[" .. keybind .. "]"
        kb.TextColor3 = PURPLE_DIM
        kb.TextSize = 10
        kb.Font = Enum.Font.Gotham
        kb.TextXAlignment = Enum.TextXAlignment.Right
        kb.Parent = row
    end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row
    local st = default
    local function setState(newVal)
        st = newVal
        TweenService:Create(dot, TWEEN_FAST, {
            BackgroundColor3 = st and PURPLE or Color3.fromRGB(50, 50, 60)
        }):Play()
        lbl.TextColor3 = st and TEXT or SUBTEXT
        if callback then callback(st) end
    end
    btn.MouseButton1Click:Connect(function() setState(not st) end)
    return row, setState
end

local function Slider(name, min, max, default, suffix, callback, isRight)
    suffix = suffix or ""
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 46)
    card.BackgroundTransparency = 1
    card.Visible = false
    if isRight then rightOrder += 1; card.LayoutOrder = rightOrder; card.Parent = RightScroll
    else leftOrder += 1; card.LayoutOrder = leftOrder; card.Parent = LeftScroll end
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.6, 0, 0, 18)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = SUBTEXT
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = card
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.4, 0, 0, 18)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default) .. suffix
    valLbl.TextColor3 = PURPLE
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local pct0 = math.clamp((default - min) / (max - min), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = PURPLE
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(pct0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(220, 200, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local sdrag = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sdrag = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sdrag = false end
    end)
    RunService.RenderStepped:Connect(function()
        if not sdrag then return end
        local mp = UserInputService:GetMouseLocation()
        local p  = math.clamp((mp.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v  = math.round(min + p * (max - min))
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        valLbl.Text = tostring(v) .. suffix
        if callback then callback(v) end
    end)
    return card
end

local function Dropdown(name, options, default, callback, isRight)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 26)
    card.BackgroundTransparency = 1
    card.Visible = false
    if isRight then rightOrder += 1; card.LayoutOrder = rightOrder; card.Parent = RightScroll
    else leftOrder += 1; card.LayoutOrder = leftOrder; card.Parent = LeftScroll end
    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = default
    valLbl.TextColor3 = TEXT
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextXAlignment = Enum.TextXAlignment.Left
    valLbl.Parent = card
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
    nameLbl.Position = UDim2.new(0.5, 0, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = SUBTEXT
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Right
    nameLbl.Parent = card
    local idx = 1
    for i, v in options do if v == default then idx = i break end end
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card
    btn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        valLbl.Text = options[idx]
        if callback then callback(options[idx]) end
    end)
    return card
end

local function KeybindPicker(name, default, callback, isRight)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 26)
    card.BackgroundTransparency = 1
    card.Visible = false
    if isRight then rightOrder += 1; card.LayoutOrder = rightOrder; card.Parent = RightScroll
    else leftOrder += 1; card.LayoutOrder = leftOrder; card.Parent = LeftScroll end
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = SUBTEXT
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = card
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 60, 0, 20)
    keyBtn.Position = UDim2.new(1, -60, 0.5, -10)
    keyBtn.BackgroundColor3 = PURPLE_DARK
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = "[" .. default .. "]"
    keyBtn.TextColor3 = PURPLE
    keyBtn.TextSize = 11
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.Parent = card
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)
    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "[...]"
        keyBtn.TextColor3 = TEXT
    end)
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not listening then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            local keyName = inp.KeyCode.Name
            keyBtn.Text = "[" .. keyName .. "]"
            keyBtn.TextColor3 = PURPLE
            if callback then callback(keyName) end
        end
    end)
    return card
end

local function TextLabel(text, isRight)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 20)
    f.BackgroundTransparency = 1
    f.Visible = false
    if isRight then rightOrder += 1; f.LayoutOrder = rightOrder; f.Parent = RightScroll
    else leftOrder += 1; f.LayoutOrder = leftOrder; f.Parent = LeftScroll end
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = SUBTEXT
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
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

local function addL(tabData, item) table.insert(tabData.leftItems,  item) end
local function addR(tabData, item) table.insert(tabData.rightItems, item) end

-- ══════════════════════════════════════════
--  CAMLOCK TAB
-- ══════════════════════════════════════════
addL(tCamlock, SectionLabel("Aim Assist Settings", false))

local aimRow, setAimEnabled = Toggle(
    "Enable", state.camlockKeybind, state.aimEnabled,
    function(on) state.aimEnabled = on end, false)
addL(tCamlock, aimRow)

addL(tCamlock, Toggle("Sticky Aim", "", state.stickyAim, function(on)
    state.stickyAim = on
    stickyTarget = nil
end, false))

addL(tCamlock, Dropdown("Type", {"Camera", "Mouse"}, "Camera", function(v) end, false))

addL(tCamlock, Dropdown("Target Method",
    {"Closest To Mouse", "Closest To Camera", "Lowest Health"},
    state.aimMethod, function(v) state.aimMethod = v end, false))

addL(tCamlock, Dropdown("Camlock Body Part",
    {"Head", "HumanoidRootPart", "Torso"},
    state.camlockPart, function(v)
        state.camlockPart = v
        state.aimPart     = v
        stickyTarget      = nil
    end, false))

addL(tCamlock, Toggle("Show FOV", "", state.showFov, function(on)
    state.showFov = on
end, false))

addL(tCamlock, Toggle("Use FOV", "", state.useFov, function(on)
    state.useFov = on
end, false))

addL(tCamlock, Slider("Radius", 10, 400, state.aimFov, "px", function(v)
    state.aimFov = v
end, false))

addR(tCamlock, SectionLabel("Advanced Settings", true))

addR(tCamlock, Toggle("Use Advanced", "Custom", state.useAdvanced, function(on)
    state.useAdvanced = on
end, true))

addR(tCamlock, Slider("Predict X", 0, 10, state.predictX, "", function(v)
    state.predictX = v
end, true))

addR(tCamlock, Slider("Predict Y", 0, 10, state.predictY, "", function(v)
    state.predictY = v
end, true))

addR(tCamlock, Toggle("Enable Smoothing", "", state.smoothingOn, function(on)
    state.smoothingOn = on
end, true))

addR(tCamlock, Slider("Smoothing X", 1, 20, state.smoothX, "", function(v)
    state.smoothX = v
end, true))

addR(tCamlock, Slider("Smoothing Y", 1, 20, state.smoothY, "", function(v)
    state.smoothY = v
end, true))

addR(tCamlock, Dropdown("Style",
    {"Linear", "Quadratic", "Sine"},
    state.camlockStyle, function(v) state.camlockStyle = v end, true))

addR(tCamlock, SectionLabel("Keybind", true))

addR(tCamlock, KeybindPicker("Aimlock Key (Hold)",
    state.camlockKeybind, function(key)
        state.camlockKeybind = key
    end, true))

addR(tCamlock, Toggle("Toggle Mode", "", state.camlockToggle, function(on)
    state.camlockToggle = on
end, true))

addR(tCamlock, TextLabel("OFF = hold key to aimlock", true))
addR(tCamlock, TextLabel("ON  = press key to toggle", true))

-- ══════════════════════════════════════════
--  VISUALS TAB
-- ══════════════════════════════════════════
addL(tVisuals, SectionLabel("ESP", false))

addL(tVisuals, Toggle("ESP Master", "", state.esp, function(on)
    state.esp = on
    if not on then
        -- Hide all drawing objects but keep them allocated
        for plr, d in espDrawings do
            hideDrawings(d)
        end
        -- Reset chams
        for _, plr in Players:GetPlayers() do
            if plr ~= Player and plr.Character then
                for _, part in plr.Character:GetDescendants() do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end
end, false))

addL(tVisuals, Toggle("Boxes", "", state.espBoxes, function(on)
    state.espBoxes = on
end, false))

addL(tVisuals, Toggle("Names", "", state.espNames, function(on)
    state.espNames = on
end, false))

addL(tVisuals, Toggle("Health", "", state.espHealth, function(on)
    state.espHealth = on
end, false))

addL(tVisuals, Toggle("Tracers", "", state.espTracers, function(on)
    state.espTracers = on
    if not on then
        for plr, d in espDrawings do
            if d.tracer then d.tracer.Visible = false end
        end
    end
end, false))

addL(tVisuals, Toggle("Chams", "", state.chams, function(on)
    state.chams = on
    if not on then
        for _, plr in Players:GetPlayers() do
            if plr ~= Player and plr.Character then
                for _, part in plr.Character:GetDescendants() do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.SmoothPlastic
                    end
                end
            end
        end
    end
end, false))

if not hasDrawing then
    addL(tVisuals, TextLabel("⚠ Drawing API not available", false))
    addL(tVisuals, TextLabel("ESP requires an executor with Drawing", false))
end

addR(tVisuals, SectionLabel("World", true))

addR(tVisuals, Toggle("Fullbright", "", state.fullbright, function(on)
    state.fullbright = on
    Lighting.Brightness = on and 10 or 1
    Lighting.Ambient = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end, true))

addR(tVisuals, Toggle("No Fog", "", state.noFog, function(on)
    state.noFog = on
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmos then atmos.Density = on and 0 or 0.395 end
end, true))

addR(tVisuals, Toggle("No Shadows", "", state.noShadows, function(on)
    state.noShadows = on
    Lighting.GlobalShadows = not on
end, true))

-- ══════════════════════════════════════════
--  MOVEMENT TAB
-- ══════════════════════════════════════════
addL(tMovement, SectionLabel("Movement", false))

addL(tMovement, Toggle("Fly", "", state.flyEnabled, function(on)
    state.flyEnabled = on
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    if on then
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent   = hrp
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P = 1e4
        bg.Parent = hrp
    else
        if bv then bv:Destroy(); bv = nil end
        if bg then bg:Destroy(); bg = nil end
        hum.PlatformStand = false
    end
end, false))

addL(tMovement, Toggle("Noclip", "", state.noclip, function(on)
    state.noclip = on
end, false))

addL(tMovement, Toggle("Infinite Jump", "", state.infiniteJump, function(on)
    state.infiniteJump = on
end, false))

addL(tMovement, Toggle("Speed Boost", "", state.speedBoost, function(on)
    state.speedBoost = on
end, false))

addL(tMovement, Slider("Walk Speed", 8, 200, state.walkSpeed, "", function(v)
    state.walkSpeed = v
end, false))

addL(tMovement, Slider("Jump Power", 0, 300, state.jumpPower, "", function(v)
    state.jumpPower = v
end, false))

addR(tMovement, SectionLabel("Player", true))

addR(tMovement, Toggle("God Mode", "", state.godMode, function(on)
    state.godMode = on
end, true))

addR(tMovement, Toggle("Anti-AFK", "", state.antiAfk, function(on)
    state.antiAfk = on
end, true))

addR(tMovement, Toggle("Invisible", "", state.invisible, function(on)
    state.invisible = on
    local char = Player.Character
    if not char then return end
    for _, p in char:GetDescendants() do
        if p:IsA("BasePart") then p.Transparency = on and 1 or 0 end
    end
end, true))

-- ══════════════════════════════════════════
--  SETTINGS TAB
-- ══════════════════════════════════════════
addL(tSettings, SectionLabel("Interface", false))

addL(tSettings, Slider("UI Opacity", 10, 100, 100, "%", function(v)
    Win.BackgroundTransparency = 1 - (v / 100)
end, false))

addL(tSettings, Slider("Tracer Thickness", 1, 5, 1, "px", function(v)
    tracerThickness = v
    for plr, d in espDrawings do
        if d.tracer then pcall(function() d.tracer.Thickness = v end) end
    end
end, false))

addR(tSettings, SectionLabel("Keybinds", true))
addR(tSettings, TextLabel("GUI Toggle:  [RShift]", true))
addR(tSettings, TextLabel("Fly:         [toggle via UI]", true))
addR(tSettings, TextLabel("Aimlock:     [hold keybind above]", true))

-- ══════════════════════════════════════════
--  CONFIG TAB
-- ══════════════════════════════════════════
addL(tConfig, SectionLabel("Config", false))

local saveRow = Instance.new("TextButton")
saveRow.Size = UDim2.new(1, 0, 0, 32)
saveRow.BackgroundColor3 = PURPLE_DARK
saveRow.BorderSizePixel = 0
saveRow.Text = "💾  Save Config"
saveRow.TextColor3 = PURPLE
saveRow.TextSize = 12
saveRow.Font = Enum.Font.GothamSemibold
saveRow.Visible = false
leftOrder += 1
saveRow.LayoutOrder = leftOrder
saveRow.Parent = LeftScroll
Instance.new("UICorner", saveRow).CornerRadius = UDim.new(0, 6)
saveRow.MouseButton1Click:Connect(function()
    saveConfig()
    saveRow.Text = "✔  Saved!"
    saveRow.TextColor3 = Color3.fromRGB(100, 220, 100)
    task.delay(1.5, function()
        saveRow.Text = "💾  Save Config"
        saveRow.TextColor3 = PURPLE
    end)
end)
table.insert(tConfig.leftItems, saveRow)

local loadRow = Instance.new("TextButton")
loadRow.Size = UDim2.new(1, 0, 0, 32)
loadRow.BackgroundColor3 = PURPLE_DARK
loadRow.BorderSizePixel = 0
loadRow.Text = "📂  Load Config"
loadRow.TextColor3 = PURPLE
loadRow.TextSize = 12
loadRow.Font = Enum.Font.GothamSemibold
loadRow.Visible = false
leftOrder += 1
loadRow.LayoutOrder = leftOrder
loadRow.Parent = LeftScroll
Instance.new("UICorner", loadRow).CornerRadius = UDim.new(0, 6)
loadRow.MouseButton1Click:Connect(function()
    loadConfig()
    loadRow.Text = "✔  Loaded!"
    loadRow.TextColor3 = Color3.fromRGB(100, 220, 100)
    task.delay(1.5, function()
        loadRow.Text = "📂  Load Config"
        loadRow.TextColor3 = PURPLE
    end)
end)
table.insert(tConfig.leftItems, loadRow)

addL(tConfig, TextLabel("Config auto-saves on close.", false))
addL(tConfig, TextLabel("File: venom_config.json", false))
addR(tConfig, SectionLabel("Auto Save", true))
addR(tConfig, Toggle("Auto Save on Toggle", "", true, function(on) end, true))

-- ══════════════════════════════════════════
--  RUNTIME LOOPS
-- ══════════════════════════════════════════

-- Fly
RunService.RenderStepped:Connect(function()
    if not state.flyEnabled or not bv or not bg then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
    bv.Velocity = dir * 60
    bg.CFrame   = cam.CFrame
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local char = Player.Character
    if not char then return end
    for _, p in char:GetDescendants() do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump then return end
    local hum = getHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- ══════════════════════════════════════════
--  HEARTBEAT: Speed + God + JumpPower
--  Enforced every frame so Da Hood's reset
--  system cannot override our values.
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if not hum then return end
    if state.godMode then
        hum.Health = hum.MaxHealth
    end
    if state.speedBoost then
        hum.WalkSpeed = 80
    else
        hum.WalkSpeed = state.walkSpeed
    end
    hum.JumpPower = state.jumpPower
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
    local ok, kc = pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
    if ok and kc and inp.KeyCode == kc then
        if state.camlockToggle then
            camlockToggleState   = not camlockToggleState
            state.camlockEnabled = camlockToggleState
        else
            state.camlockEnabled = true
        end
    end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Win.Visible = not Win.Visible
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if not state.camlockToggle then
        local ok, kc = pcall(function() return Enum.KeyCode[state.camlockKeybind] end)
        if ok and kc and inp.KeyCode == kc then
            state.camlockEnabled = false
            stickyTarget         = nil
        end
    end
end)

-- ══════════════════════════════════════════
--  CAMLOCK LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.aimEnabled     then stickyTarget = nil return end
    if not state.camlockEnabled then stickyTarget = nil return end

    if state.stickyAim and stickyTarget then
        local char = stickyTarget.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 or not stickyTarget.Parent then
            stickyTarget = nil
        else
            if state.useFov then
                local part = char:FindFirstChild(state.camlockPart) or char:FindFirstChild("Head")
                if part then
                    local cam = workspace.CurrentCamera
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist > state.aimFov * 2.5 then stickyTarget = nil end
                    else
                        stickyTarget = nil
                    end
                end
            end
        end
    end

    if not stickyTarget or not state.stickyAim then
        stickyTarget = getClosestToMouse(state.camlockPart)
    end

    local target = stickyTarget
    if not target or not target.Character then return end

    local part = target.Character:FindFirstChild(state.camlockPart)
               or target.Character:FindFirstChild("Head")
    if not part then return end

    local cam       = workspace.CurrentCamera
    local origin    = cam.CFrame.Position
    local targetPos = part.Position

    if state.useAdvanced and state.predictX > 0 then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            targetPos = targetPos + hrp.Velocity * Vector3.new(
                state.predictX * 0.016,
                state.predictY * 0.016,
                state.predictX * 0.016
            )
        end
    end

    local targetCF = CFrame.lookAt(origin, targetPos)

    if state.useAdvanced and state.smoothingOn then
        local smooth = math.clamp(state.smoothX / 20, 0.01, 1)
        if state.camlockStyle == "Linear" then
            cam.CFrame = cam.CFrame:Lerp(targetCF, smooth)
        elseif state.camlockStyle == "Quadratic" then
            cam.CFrame = cam.CFrame:Lerp(targetCF, smooth * smooth)
        elseif state.camlockStyle == "Sine" then
            cam.CFrame = cam.CFrame:Lerp(targetCF, math.sin(smooth * math.pi / 2))
        end
    else
        cam.CFrame = targetCF
    end
end)

-- ══════════════════════════════════════════
--  ESP LOOP  (Drawing-based, AlwaysOnTop)
--  Runs every frame. Drawing objects render
--  above everything including walls since
--  they bypass the 3D scene entirely.
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- Clean up drawings for players who left
    for plr, _ in espDrawings do
        if not plr or not plr.Parent then
            cleanupESPForPlayer(plr)
        end
    end

    for _, plr in Players:GetPlayers() do
        if plr == Player then continue end

        if not state.esp then
            -- If ESP is off, make sure drawings are hidden
            if espDrawings[plr] then hideDrawings(espDrawings[plr]) end
            continue
        end

        -- This creates drawings lazily if they don't exist yet,
        -- handles players who joined after the script started,
        -- and updates all properties every frame.
        updateESPForPlayer(plr)
    end
end)

-- ══════════════════════════════════════════
--  PLAYER JOIN/LEAVE EVENTS
--  Ensure ESP objects are cleaned up properly
-- ══════════════════════════════════════════
Players.PlayerAdded:Connect(function(plr)
    -- Drawing objects are created lazily in updateESPForPlayer
    -- so nothing needed here — it auto-creates on next frame
end)

Players.PlayerRemoving:Connect(function(plr)
    cleanupESPForPlayer(plr)
end)

-- ══════════════════════════════════════════
--  RESPAWN CLEANUP
-- ══════════════════════════════════════════
Player.CharacterAdded:Connect(function()
    state.flyEnabled = false
    stickyTarget     = nil
    bv = nil
    bg = nil
    -- Don't wipe espDrawings on respawn — other players didn't leave
    -- Just let the loop handle it next frame
end)

game:BindToClose(function()
    saveConfig()
    cleanupAllESP()
end)

-- ══════════════════════════════════════════
--  ACTIVATE FIRST TAB
-- ══════════════════════════════════════════
activateTab(tCamlock)

print("[Venom.lol v1.4] Loaded ✓")
if not hasDrawing then
    print("[Venom.lol] WARNING: Drawing API not found. ESP requires an executor that supports Drawing.new()")
end
print("Hold [" .. state.camlockKeybind .. "] to aimlock | RShift to toggle GUI")
