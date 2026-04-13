-- Venom.lol GUI v2.0
-- Engine: Open Aimbot (ttwiz_z) | Shell: Venom
-- Features: Whitelist, Spinbot, Triggerbot, Hitbox Expander, Bunny Hop,
--           Third Person, Custom Crosshair (Drawing), ESP Distance, Auto Rejoin,
--           Fake Lag, Bhop+AutoSprint, Full Fortnite-style Map (press M)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local StarterGui       = game:GetService("StarterGui")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse     = Player:GetMouse()
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

-- ══════════════════════════════════════════
--  WHITELIST
-- ══════════════════════════════════════════
local NGROK_URL = "https://subventionary-letha-boughten.ngrok-free.dev/verify"

local function CheckWhitelist()
    local success, response = pcall(function()
        return request({
            Url    = NGROK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"]               = "application/json",
                ["ngrok-skip-browser-warning"] = "true",
            },
            Body = HttpService:JSONEncode({ roblox_id = Player.UserId }),
        })
    end)
    return success and response and response.StatusCode == 200
end

-- Splash screen
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "VenomSplash"; SplashGui.ResetOnSpawn=false
SplashGui.IgnoreGuiInset=true; SplashGui.DisplayOrder=999; SplashGui.Parent=PlayerGui

local SplashBG=Instance.new("Frame"); SplashBG.Size=UDim2.new(1,0,1,0)
SplashBG.BackgroundColor3=Color3.fromRGB(6,6,10); SplashBG.BorderSizePixel=0; SplashBG.Parent=SplashGui

local SplashCard=Instance.new("Frame"); SplashCard.Size=UDim2.new(0,300,0,150)
SplashCard.AnchorPoint=Vector2.new(0.5,0.5); SplashCard.Position=UDim2.new(0.5,0,0.55,0)
SplashCard.BackgroundColor3=Color3.fromRGB(8,8,12); SplashCard.BorderSizePixel=0; SplashCard.Parent=SplashBG
Instance.new("UICorner",SplashCard).CornerRadius=UDim.new(0,12)
local SplashStroke=Instance.new("UIStroke",SplashCard)
SplashStroke.Color=Color3.fromRGB(138,43,226); SplashStroke.Thickness=1.5

local SplashTitle=Instance.new("TextLabel"); SplashTitle.Size=UDim2.new(1,0,0,30)
SplashTitle.Position=UDim2.new(0,0,0,20); SplashTitle.BackgroundTransparency=1
SplashTitle.Text="venom.lol"; SplashTitle.TextColor3=Color3.fromRGB(138,43,226)
SplashTitle.TextSize=22; SplashTitle.Font=Enum.Font.GothamBold; SplashTitle.Parent=SplashCard

local SplashSub=Instance.new("TextLabel"); SplashSub.Size=UDim2.new(1,0,0,18)
SplashSub.Position=UDim2.new(0,0,0,56); SplashSub.BackgroundTransparency=1
SplashSub.Text="Verifying whitelist..."; SplashSub.TextColor3=Color3.fromRGB(130,120,150)
SplashSub.TextSize=12; SplashSub.Font=Enum.Font.Gotham; SplashSub.Parent=SplashCard

local SplashBarBG=Instance.new("Frame"); SplashBarBG.Size=UDim2.new(1,-24,0,4)
SplashBarBG.Position=UDim2.new(0,12,1,-18); SplashBarBG.BackgroundColor3=Color3.fromRGB(35,25,55)
SplashBarBG.BorderSizePixel=0; SplashBarBG.Parent=SplashCard
Instance.new("UICorner",SplashBarBG).CornerRadius=UDim.new(1,0)
local SplashBar=Instance.new("Frame"); SplashBar.Size=UDim2.new(0,0,1,0)
SplashBar.BackgroundColor3=Color3.fromRGB(138,43,226); SplashBar.BorderSizePixel=0; SplashBar.Parent=SplashBarBG
Instance.new("UICorner",SplashBar).CornerRadius=UDim.new(1,0)

SplashCard.Position=UDim2.new(0.5,0,0.65,0); SplashCard.BackgroundTransparency=1
TweenService:Create(SplashCard,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=0}):Play()
TweenService:Create(SplashBar,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),
    {Size=UDim2.new(0.85,0,1,0)}):Play()

local granted = CheckWhitelist()

if not granted then
    SplashSub.Text="❌  Not whitelisted."; SplashSub.TextColor3=Color3.fromRGB(210,100,100)
    SplashStroke.Color=Color3.fromRGB(200,50,50)
    TweenService:Create(SplashBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(200,50,50)}):Play()
    task.wait(3)
    TweenService:Create(SplashBG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
    task.wait(0.4); SplashGui:Destroy(); return
end

SplashSub.Text="✅  Access granted!"; SplashSub.TextColor3=Color3.fromRGB(80,210,120)
TweenService:Create(SplashBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(60,210,90)}):Play()
task.wait(0.8)
TweenService:Create(SplashBG,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play()
task.wait(0.35); SplashGui:Destroy()

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
local GOLD        = Color3.fromRGB(255, 200, 40)
local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local CONFIG_FILE = "venom_config.json"

-- ══════════════════════════════════════════
--  CAPABILITY CHECKS
-- ══════════════════════════════════════════
local hasDrawing = false
pcall(function() local t=Drawing.new("Square"); t:Remove(); hasDrawing=true end)
local hasMoveRel     = not not getfenv().mousemoverel
local hasHookMeta    = not not (getfenv().hookmetamethod and getfenv().newcclosure
                                and getfenv().checkcaller and getfenv().getnamecallmethod)
local hasMouse1Click = not not getfenv().mouse1click

-- ══════════════════════════════════════════
--  OPEN AIMBOT CONFIGURATION
-- ══════════════════════════════════════════
local Configuration = {
    Aimbot                = false,
    OnePressAimingMode    = false,
    AimKey                = IsComputer and Enum.UserInputType.MouseButton2 or nil,
    AimMode               = "Camera",
    SilentAimMethods      = {"Mouse.Hit / Mouse.Target","GetMouseLocation"},
    SilentAimChance       = 100,
    OffAimbotAfterKill    = false,
    AimPart               = "HumanoidRootPart",
    UseOffset             = false,
    OffsetType            = "Static",
    StaticOffsetIncrement = 10,
    DynamicOffsetIncrement= 10,
    AutoOffset            = false,
    MaxAutoOffset         = 50,
    UseSensitivity        = false,
    Sensitivity           = 50,
    UseNoise              = false,
    NoiseFrequency        = 50,
    AliveCheck            = true,
    GodCheck              = false,
    TeamCheck             = false,
    FriendCheck           = false,
    FollowCheck           = false,
    WallCheck             = false,
    WaterCheck            = false,
    FoVCheck              = false,
    FoVRadius             = 120,
    MagnitudeCheck        = false,
    TriggerMagnitude      = 500,
    TransparencyCheck     = false,
    IgnoredTransparency   = 0.5,
    IgnoredPlayersCheck   = false,
    IgnoredPlayers        = {},
    TargetPlayersCheck    = false,
    TargetPlayers         = {},
    -- SpinBot
    SpinBot               = false,
    SpinBotVelocity       = 50,
    SpinPart              = "HumanoidRootPart",
    -- TriggerBot
    TriggerBot            = false,
    TriggerBotChance      = 100,
    SmartTriggerBot       = false,
}

-- ══════════════════════════════════════════
--  AIMBOT RUNTIME
-- ══════════════════════════════════════════
local Aiming           = false
local Target           = nil
local AimTween         = nil
local MouseSensitivity = UserInputService.MouseDeltaSensitivity
local ShowingFoV       = false
local Spinning         = false
local Triggering       = false
local Clock            = os.clock()

local MathHandler = {}
function MathHandler:CalculateDirection(O,P,M)
    return typeof(O)=="Vector3" and typeof(P)=="Vector3" and typeof(M)=="number"
        and (P-O).Unit*M or Vector3.zero
end
function MathHandler:CalculateChance(Pct)
    return typeof(Pct)=="number" and
        math.round(math.clamp(Pct,1,100))/100 >= math.round(Random.new():NextNumber()*100)/100
        or false
end

local function IsReady(Char)
    if not Char then return false end
    local hum  = Char:FindFirstChildOfClass("Humanoid")
    local aimP = Char:FindFirstChild(Configuration.AimPart)
    if not hum or not aimP or not aimP:IsA("BasePart") then return false end
    if not Player.Character then return false end
    local nativeP = Player.Character:FindFirstChild(Configuration.AimPart)
    if not nativeP or not nativeP:IsA("BasePart") then return false end
    local _plr = Players:GetPlayerFromCharacter(Char)
    if not _plr or _plr==Player then return false end

    local Head = Char:FindFirstChild("Head")
    if Configuration.AliveCheck   and hum.Health==0 then return false end
    if Configuration.GodCheck     and (hum.Health>=1e36 or Char:FindFirstChildOfClass("ForceField")) then return false end
    if Configuration.TeamCheck    and _plr.TeamColor==Player.TeamColor then return false end
    if Configuration.FriendCheck  and _plr:IsFriendsWith(Player.UserId) then return false end
    if Configuration.FollowCheck  and _plr.FollowUserId==Player.UserId  then return false end

    if Configuration.WallCheck then
        local dir=MathHandler:CalculateDirection(nativeP.Position,aimP.Position,(aimP.Position-nativeP.Position).Magnitude)
        local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances={Player.Character}; rp.IgnoreWater=not Configuration.WaterCheck
        local res=workspace:Raycast(nativeP.Position,dir,rp)
        if not res or not res.Instance or not res.Instance:FindFirstAncestor(_plr.Name) then return false end
    end

    if Configuration.MagnitudeCheck and (aimP.Position-nativeP.Position).Magnitude>Configuration.TriggerMagnitude then return false end
    if Configuration.TransparencyCheck and Head and Head:IsA("BasePart") and Head.Transparency>=Configuration.IgnoredTransparency then return false end
    if Configuration.IgnoredPlayersCheck and table.find(Configuration.IgnoredPlayers,_plr.Name) then return false end
    if Configuration.TargetPlayersCheck  and not table.find(Configuration.TargetPlayers,_plr.Name) then return false end

    local offset=Vector3.zero
    if Configuration.UseOffset then
        if Configuration.AutoOffset then
            local ay=math.min(aimP.Position.Y*Configuration.StaticOffsetIncrement*(aimP.Position-nativeP.Position).Magnitude/1000,Configuration.MaxAutoOffset)
            offset=Vector3.new(0,ay,0)+hum.MoveDirection*Configuration.DynamicOffsetIncrement/10
        elseif Configuration.OffsetType=="Static" then
            offset=Vector3.new(0,aimP.Position.Y*Configuration.StaticOffsetIncrement/10,0)
        elseif Configuration.OffsetType=="Dynamic" then
            offset=hum.MoveDirection*Configuration.DynamicOffsetIncrement/10
        else
            offset=Vector3.new(0,aimP.Position.Y*Configuration.StaticOffsetIncrement/10,0)+hum.MoveDirection*Configuration.DynamicOffsetIncrement/10
        end
    end

    local noise=Vector3.zero
    if Configuration.UseNoise then
        local n=Configuration.NoiseFrequency/100
        noise=Vector3.new(Random.new():NextNumber(-n,n),Random.new():NextNumber(-n,n),Random.new():NextNumber(-n,n))
    end

    local FinalPos=aimP.Position+offset+noise
    local vp,onScreen=workspace.CurrentCamera:WorldToViewportPoint(FinalPos)
    return true,Char,{vp,onScreen},FinalPos,(FinalPos-nativeP.Position).Magnitude,
        CFrame.new(FinalPos)*CFrame.fromEulerAnglesYXZ(
            math.rad(aimP.Orientation.X),math.rad(aimP.Orientation.Y),math.rad(aimP.Orientation.Z)),aimP
end

local function ResetAimbotFields(keepAim,keepTarget)
    Aiming=keepAim and Aiming or false
    Target=keepTarget and Target or nil
    if AimTween then AimTween:Cancel(); AimTween=nil end
    UserInputService.MouseDeltaSensitivity=MouseSensitivity
end

-- Silent Aim Hooks
local function hookSilentAim()
    if not hasHookMeta then return end
    local OldIndex; OldIndex=getfenv().hookmetamethod(game,"__index",getfenv().newcclosure(function(self,idx)
        if not getfenv().checkcaller() and Configuration.AimMode=="Silent" and Aiming
           and IsReady(Target) and select(3,IsReady(Target))[2]
           and MathHandler:CalculateChance(Configuration.SilentAimChance) and self==Mouse then
            if idx=="Hit"     or idx=="hit"     then return select(6,IsReady(Target)) end
            if idx=="Target"  or idx=="target"  then return select(7,IsReady(Target)) end
            if idx=="X"       or idx=="x"       then return select(3,IsReady(Target))[1].X end
            if idx=="Y"       or idx=="y"       then return select(3,IsReady(Target))[1].Y end
            if idx=="UnitRay" or idx=="unitRay" then
                return Ray.new(self.Origin,(select(6,IsReady(Target))-self.Origin).Unit) end
        end
        return OldIndex(self,idx)
    end))
    local OldNC; OldNC=getfenv().hookmetamethod(game,"__namecall",getfenv().newcclosure(function(...)
        local Method=getfenv().getnamecallmethod(); local Args={...}; local s=Args[1]
        if not getfenv().checkcaller() and Configuration.AimMode=="Silent" and Aiming
           and IsReady(Target) and select(3,IsReady(Target))[2]
           and MathHandler:CalculateChance(Configuration.SilentAimChance) then
            if s==UserInputService and (Method=="GetMouseLocation" or Method=="getMouseLocation") then
                return Vector2.new(select(3,IsReady(Target))[1].X,select(3,IsReady(Target))[1].Y)
            elseif s==workspace and (Method=="Raycast" or Method=="raycast")
               and typeof(Args[2])=="Vector3" and typeof(Args[3])=="Vector3" then
                Args[3]=MathHandler:CalculateDirection(Args[2],select(4,IsReady(Target)),select(5,IsReady(Target)))
                return OldNC(table.unpack(Args))
            end
        end
        return OldNC(...)
    end))
end
pcall(hookSilentAim)

UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not Aiming or not (hasMoveRel and Configuration.AimMode=="Mouse" or Configuration.AimMode=="Silent") then
        MouseSensitivity=UserInputService.MouseDeltaSensitivity
    end
end)

-- ══════════════════════════════════════════
--  VENOM STATE
-- ══════════════════════════════════════════
local state = {
    esp=false, espBoxes=true, espNames=true, espHealth=true, espTracers=false,
    espDistance=true, espChams=false,
    fullbright=false, noFog=false, noShadows=false, showEspPreview=false,
    flyEnabled=false, noclip=false, infiniteJump=false,
    speedBoost=false, walkSpeed=16, jumpPower=50,
    godMode=false, antiAfk=false, invisible=false,
    bunnyhop=false, autoSprint=false, sprintSpeed=28,
    thirdPerson=false, tpDistance=8,
    crosshair=false, crosshairStyle="Plus", crosshairSize=10, crosshairColor=PURPLE,
    hitboxExpander=false, hitboxSize=6,
    fakelag=false, fakelagAmount=3,
    autoRejoin=false,
    minimapEnabled=true, minimapRange=300, showGameMap=true,
    fullMapOpen=false,
}

local bv, bg
local tracerThickness = 1
local MINIMAP_SIZE    = 180

-- ══════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════
local function saveConfig()
    local data={}
    for k,v in state do local t=type(v); if t=="boolean" or t=="number" or t=="string" then data[k]=v end end
    pcall(function() writefile(CONFIG_FILE,HttpService:JSONEncode(data)) end)
end
local function loadConfig()
    local ok,raw=pcall(readfile,CONFIG_FILE)
    if not ok or not raw then return end
    local ok2,data=pcall(HttpService.JSONDecode,HttpService,raw)
    if not ok2 or type(data)~="table" then return end
    for k,v in data do if state[k]~=nil then state[k]=v end end
end
loadConfig()

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getHum()  local c=Player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP()  local c=Player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHead() local c=Player.Character; return c and c:FindFirstChild("Head") end

-- ══════════════════════════════════════════
--  MAP SCANNER
-- ══════════════════════════════════════════
local MAP_CELLS=64
local mapMinX,mapMaxX,mapMinZ,mapMaxZ=math.huge,-math.huge,math.huge,-math.huge
local mapGrid={}; local mapScanned=false
local function scanMap()
    mapMinX,mapMaxX,mapMinZ,mapMaxZ=math.huge,-math.huge,math.huge,-math.huge
    for _,obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or game) then
            local p=obj.Position
            if p.X<mapMinX then mapMinX=p.X end; if p.X>mapMaxX then mapMaxX=p.X end
            if p.Z<mapMinZ then mapMinZ=p.Z end; if p.Z>mapMaxZ then mapMaxZ=p.Z end
        end
    end
    if mapMinX==math.huge then mapMinX,mapMaxX,mapMinZ,mapMaxZ=-500,500,-500,500 end
    local px=(mapMaxX-mapMinX)*0.05; local pz=(mapMaxZ-mapMinZ)*0.05
    mapMinX-=px; mapMaxX+=px; mapMinZ-=pz; mapMaxZ+=pz
    local cx=(mapMaxX-mapMinX)/MAP_CELLS; local cz=(mapMaxZ-mapMinZ)/MAP_CELLS
    local raw={}; local maxD=0
    for r=1,MAP_CELLS do raw[r]={} for c=1,MAP_CELLS do raw[r][c]=0 end end
    for _,obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or game) then
            local p=obj.Position
            local col=math.clamp(math.floor((p.X-mapMinX)/cx)+1,1,MAP_CELLS)
            local row=math.clamp(math.floor((p.Z-mapMinZ)/cz)+1,1,MAP_CELLS)
            raw[row][col]+=1; if raw[row][col]>maxD then maxD=raw[row][col] end
        end
    end
    for r=1,MAP_CELLS do mapGrid[r]={}
        for c=1,MAP_CELLS do mapGrid[r][c]=maxD>0 and raw[r][c]/maxD or 0 end
    end
    mapScanned=true
end
task.spawn(scanMap)

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="VenomGUI"; ScreenGui.ResetOnSpawn=false
ScreenGui.IgnoreGuiInset=true; ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=PlayerGui

-- ══════════════════════════════════════════
--  MINIMAP (small corner radar)
-- ══════════════════════════════════════════
local MinimapFrame=Instance.new("Frame")
MinimapFrame.Size=UDim2.new(0,MINIMAP_SIZE,0,MINIMAP_SIZE)
MinimapFrame.Position=UDim2.new(1,-(MINIMAP_SIZE+14),1,-(MINIMAP_SIZE+14))
MinimapFrame.BackgroundColor3=Color3.fromRGB(8,8,14); MinimapFrame.BorderSizePixel=0
MinimapFrame.ZIndex=5; MinimapFrame.Visible=state.minimapEnabled; MinimapFrame.Parent=ScreenGui
Instance.new("UICorner",MinimapFrame).CornerRadius=UDim.new(0,8)
local mmStroke=Instance.new("UIStroke",MinimapFrame); mmStroke.Color=PURPLE_DIM; mmStroke.Thickness=1.5

local mmClip=Instance.new("Frame"); mmClip.Size=UDim2.new(1,0,1,0)
mmClip.BackgroundTransparency=1; mmClip.ClipsDescendants=true; mmClip.ZIndex=5; mmClip.Parent=MinimapFrame
Instance.new("UICorner",mmClip).CornerRadius=UDim.new(0,8)

local mapLayer=Instance.new("Frame"); mapLayer.Size=UDim2.new(1,0,1,0)
mapLayer.BackgroundTransparency=1; mapLayer.ZIndex=5; mapLayer.Parent=mmClip

local tilePx=MINIMAP_SIZE/MAP_CELLS; local mapTiles={}
for r=1,MAP_CELLS do mapTiles[r]={}
    for c=1,MAP_CELLS do
        local t=Instance.new("Frame")
        t.Size=UDim2.new(0,math.ceil(tilePx)+1,0,math.ceil(tilePx)+1)
        t.Position=UDim2.new(0,(c-1)*tilePx,0,(r-1)*tilePx)
        t.BackgroundColor3=Color3.fromRGB(12,12,20); t.BorderSizePixel=0; t.ZIndex=5; t.Parent=mapLayer
        mapTiles[r][c]=t
    end
end

local function applyMapGrid(tiles,tileCount)
    if not mapScanned then return end
    local scale=MAP_CELLS/tileCount
    for r=1,tileCount do for c=1,tileCount do
        local sr=math.clamp(math.round((r-0.5)*scale),1,MAP_CELLS)
        local sc=math.clamp(math.round((c-0.5)*scale),1,MAP_CELLS)
        local d=mapGrid[sr] and mapGrid[sr][sc] or 0
        if tiles[r] and tiles[r][c] then
            tiles[r][c].BackgroundColor3=Color3.fromRGB(
                math.round(20+d*60),math.round(12+d*20),math.round(35+d*80))
        end
    end end
end
task.spawn(function() while not mapScanned do task.wait(0.1) end; applyMapGrid(mapTiles,MAP_CELLS) end)

local mmRescanBtn=Instance.new("TextButton")
mmRescanBtn.Size=UDim2.new(1,0,0,14); mmRescanBtn.BackgroundColor3=Color3.fromRGB(20,10,35)
mmRescanBtn.BorderSizePixel=0; mmRescanBtn.Text="▣ MAP  [tap to rescan]"; mmRescanBtn.TextColor3=SUBTEXT
mmRescanBtn.TextSize=8; mmRescanBtn.Font=Enum.Font.GothamSemibold; mmRescanBtn.ZIndex=9; mmRescanBtn.Parent=mmClip
mmRescanBtn.MouseButton1Click:Connect(function()
    mmRescanBtn.Text="scanning..."
    task.spawn(function() scanMap(); applyMapGrid(mapTiles,MAP_CELLS); mmRescanBtn.Text="▣ MAP  [tap to rescan]" end)
end)

local radarLayer=Instance.new("Frame"); radarLayer.Size=UDim2.new(1,0,1,0)
radarLayer.BackgroundTransparency=1; radarLayer.ZIndex=6; radarLayer.Parent=mmClip

for _,pct in {0.33,0.66,1.0} do
    local rs=MINIMAP_SIZE*pct; local ring=Instance.new("Frame")
    ring.Size=UDim2.new(0,rs,0,rs); ring.Position=UDim2.new(0.5,-rs/2,0.5,-rs/2)
    ring.BackgroundTransparency=1; ring.BorderSizePixel=0; ring.ZIndex=6; ring.Parent=radarLayer
    local st=Instance.new("UIStroke",ring); st.Color=Color3.fromRGB(50,30,80); st.Thickness=0.5; st.Transparency=0.5
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
end
local function mmLine(vert)
    local l=Instance.new("Frame"); l.BackgroundColor3=Color3.fromRGB(50,30,80); l.BorderSizePixel=0; l.ZIndex=6; l.Parent=radarLayer
    if vert then l.Size=UDim2.new(0,1,1,0); l.Position=UDim2.new(0.5,0,0,0)
    else l.Size=UDim2.new(1,0,0,1); l.Position=UDim2.new(0,0,0.5,0) end
end
mmLine(true); mmLine(false)

local mmSelf=Instance.new("Frame"); mmSelf.Size=UDim2.new(0,8,0,8)
mmSelf.AnchorPoint=Vector2.new(0.5,0.5); mmSelf.Position=UDim2.new(0.5,0,0.5,0)
mmSelf.BackgroundColor3=Color3.fromRGB(255,255,255); mmSelf.BorderSizePixel=0; mmSelf.ZIndex=9; mmSelf.Parent=radarLayer
Instance.new("UICorner",mmSelf).CornerRadius=UDim.new(1,0)

local mmLabel=Instance.new("TextLabel"); mmLabel.Size=UDim2.new(1,0,0,13)
mmLabel.Position=UDim2.new(0,0,1,2); mmLabel.BackgroundTransparency=1
mmLabel.Text="RADAR  ·  "..tostring(state.minimapRange).."st"; mmLabel.TextColor3=SUBTEXT
mmLabel.TextSize=8; mmLabel.Font=Enum.Font.GothamSemibold; mmLabel.ZIndex=5; mmLabel.Parent=MinimapFrame

-- M key hint
local mmMHint=Instance.new("TextLabel"); mmMHint.Size=UDim2.new(1,0,0,11)
mmMHint.Position=UDim2.new(0,0,1,17); mmMHint.BackgroundTransparency=1
mmMHint.Text="[M] Full Map"; mmMHint.TextColor3=Color3.fromRGB(90,60,130)
mmMHint.TextSize=8; mmMHint.Font=Enum.Font.Gotham; mmMHint.ZIndex=5; mmMHint.Parent=MinimapFrame

local mmDots={}
local function getMMDot(i)
    if mmDots[i] then return mmDots[i] end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,7,0,7); dot.AnchorPoint=Vector2.new(0.5,0.5)
    dot.BackgroundColor3=RED; dot.BorderSizePixel=0; dot.ZIndex=8; dot.Visible=false; dot.Parent=radarLayer
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local dn=Instance.new("TextLabel"); dn.Size=UDim2.new(0,50,0,11)
    dn.AnchorPoint=Vector2.new(0.5,1); dn.Position=UDim2.new(0.5,0,0,-1)
    dn.BackgroundTransparency=1; dn.TextColor3=TEXT; dn.TextSize=7; dn.Font=Enum.Font.GothamBold; dn.ZIndex=9; dn.Parent=dot
    mmDots[i]=dot; return dot
end

-- ══════════════════════════════════════════
--  FULL MAP  (Fortnite-style, press M)
-- ══════════════════════════════════════════
local FULLMAP_CELLS = 96
local fullMapTiles  = {}
local FULLMAP_SIZE  = 560

local FullMapFrame=Instance.new("Frame")
FullMapFrame.Size=UDim2.new(0,FULLMAP_SIZE+20,0,FULLMAP_SIZE+60)
FullMapFrame.AnchorPoint=Vector2.new(0.5,0.5); FullMapFrame.Position=UDim2.new(0.5,0,0.5,0)
FullMapFrame.BackgroundColor3=Color3.fromRGB(6,6,10); FullMapFrame.BorderSizePixel=0
FullMapFrame.ZIndex=50; FullMapFrame.Visible=false; FullMapFrame.Parent=ScreenGui
Instance.new("UICorner",FullMapFrame).CornerRadius=UDim.new(0,12)
local fmStroke=Instance.new("UIStroke",FullMapFrame); fmStroke.Color=PURPLE; fmStroke.Thickness=2

-- Header
local fmHeader=Instance.new("Frame"); fmHeader.Size=UDim2.new(1,0,0,36)
fmHeader.BackgroundColor3=BG2; fmHeader.BorderSizePixel=0; fmHeader.ZIndex=51; fmHeader.Parent=FullMapFrame
Instance.new("UICorner",fmHeader).CornerRadius=UDim.new(0,12)
local fmHeaderFix=Instance.new("Frame"); fmHeaderFix.Size=UDim2.new(1,0,0,12)
fmHeaderFix.Position=UDim2.new(0,0,1,-12); fmHeaderFix.BackgroundColor3=BG2
fmHeaderFix.BorderSizePixel=0; fmHeaderFix.ZIndex=51; fmHeaderFix.Parent=fmHeader

local fmTitle=Instance.new("TextLabel"); fmTitle.Size=UDim2.new(1,-40,1,0)
fmTitle.Position=UDim2.new(0,14,0,0); fmTitle.BackgroundTransparency=1
fmTitle.Text="🗺  FULL MAP  —  [M] to close"; fmTitle.TextColor3=PURPLE
fmTitle.TextSize=14; fmTitle.Font=Enum.Font.GothamBold; fmTitle.TextXAlignment=Enum.TextXAlignment.Left
fmTitle.ZIndex=52; fmTitle.Parent=fmHeader

local fmCloseBtn=Instance.new("TextButton"); fmCloseBtn.Size=UDim2.new(0,22,0,22)
fmCloseBtn.Position=UDim2.new(1,-30,0.5,-11); fmCloseBtn.BackgroundColor3=Color3.fromRGB(50,20,20)
fmCloseBtn.Text="✕"; fmCloseBtn.TextColor3=RED; fmCloseBtn.TextSize=11
fmCloseBtn.Font=Enum.Font.GothamBold; fmCloseBtn.BorderSizePixel=0; fmCloseBtn.ZIndex=52; fmCloseBtn.Parent=fmHeader
Instance.new("UICorner",fmCloseBtn).CornerRadius=UDim.new(0,4)
fmCloseBtn.MouseButton1Click:Connect(function()
    state.fullMapOpen=false; FullMapFrame.Visible=false
end)

-- Map area
local fmArea=Instance.new("Frame"); fmArea.Size=UDim2.new(0,FULLMAP_SIZE,0,FULLMAP_SIZE)
fmArea.Position=UDim2.new(0,10,0,42); fmArea.BackgroundColor3=Color3.fromRGB(10,10,18)
fmArea.BorderSizePixel=0; fmArea.ZIndex=51; fmArea.ClipsDescendants=true; fmArea.Parent=FullMapFrame
Instance.new("UICorner",fmArea).CornerRadius=UDim.new(0,6)

-- Build full-map tile grid
local fmTilePx=FULLMAP_SIZE/FULLMAP_CELLS
for r=1,FULLMAP_CELLS do fullMapTiles[r]={}
    for c=1,FULLMAP_CELLS do
        local t=Instance.new("Frame")
        t.Size=UDim2.new(0,math.ceil(fmTilePx)+1,0,math.ceil(fmTilePx)+1)
        t.Position=UDim2.new(0,(c-1)*fmTilePx,0,(r-1)*fmTilePx)
        t.BackgroundColor3=Color3.fromRGB(10,10,18); t.BorderSizePixel=0; t.ZIndex=52; t.Parent=fmArea
        fullMapTiles[r][c]=t
    end
end

-- Compass rose labels
local compass={N=UDim2.new(0.5,0,0,4),S=UDim2.new(0.5,0,1,-14),
               W=UDim2.new(0,4,0.5,0),E=UDim2.new(1,-14,0.5,0)}
for label,pos in compass do
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0,14,0,14); l.Position=pos
    l.BackgroundTransparency=1; l.Text=label; l.TextColor3=Color3.fromRGB(200,180,255)
    l.TextSize=10; l.Font=Enum.Font.GothamBold; l.ZIndex=58; l.Parent=fmArea
end

-- Grid lines on full map
for i=1,5 do
    local p=(i/6)
    local lh=Instance.new("Frame"); lh.Size=UDim2.new(1,0,0,1); lh.Position=UDim2.new(0,0,p,0)
    lh.BackgroundColor3=Color3.fromRGB(40,25,70); lh.BorderSizePixel=0; lh.ZIndex=53; lh.Parent=fmArea
    local lv=Instance.new("Frame"); lv.Size=UDim2.new(0,1,1,0); lv.Position=UDim2.new(p,0,0,0)
    lv.BackgroundColor3=Color3.fromRGB(40,25,70); lv.BorderSizePixel=0; lv.ZIndex=53; lv.Parent=fmArea
end

-- Self marker on full map
local fmSelf=Instance.new("Frame"); fmSelf.Size=UDim2.new(0,10,0,10)
fmSelf.AnchorPoint=Vector2.new(0.5,0.5); fmSelf.Position=UDim2.new(0.5,0,0.5,0)
fmSelf.BackgroundColor3=Color3.fromRGB(100,220,255); fmSelf.BorderSizePixel=0; fmSelf.ZIndex=59; fmSelf.Parent=fmArea
Instance.new("UICorner",fmSelf).CornerRadius=UDim.new(1,0)
local fmSelfStroke=Instance.new("UIStroke",fmSelf); fmSelfStroke.Color=Color3.fromRGB(255,255,255); fmSelfStroke.Thickness=1.5

-- Enemy dots pool for full map
local fmEnemyDots={}
local function getFmDot(i)
    if fmEnemyDots[i] then return fmEnemyDots[i] end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,9,0,9); dot.AnchorPoint=Vector2.new(0.5,0.5)
    dot.BackgroundColor3=RED; dot.BorderSizePixel=0; dot.ZIndex=57; dot.Visible=false; dot.Parent=fmArea
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0,60,0,12)
    nl.AnchorPoint=Vector2.new(0.5,1); nl.Position=UDim2.new(0.5,0,0,-1)
    nl.BackgroundTransparency=1; nl.TextColor3=TEXT; nl.TextSize=8; nl.Font=Enum.Font.GothamBold; nl.ZIndex=58; nl.Parent=dot
    fmEnemyDots[i]=dot; return dot
end

-- Footer: legend
local fmFooter=Instance.new("Frame"); fmFooter.Size=UDim2.new(1,0,0,22)
fmFooter.Position=UDim2.new(0,0,1,-22); fmFooter.BackgroundTransparency=1; fmFooter.ZIndex=51; fmFooter.Parent=FullMapFrame
local fmLegend=Instance.new("TextLabel"); fmLegend.Size=UDim2.new(1,0,1,0)
fmLegend.BackgroundTransparency=1
fmLegend.Text="🔵 You   🔴 Enemy   🟡 Aimbot Target   🟢 Teammate"
fmLegend.TextColor3=SUBTEXT; fmLegend.TextSize=9; fmLegend.Font=Enum.Font.Gotham
fmLegend.ZIndex=52; fmLegend.Parent=fmFooter

-- Rescan button on full map
local fmRescanBtn=Instance.new("TextButton"); fmRescanBtn.Size=UDim2.new(0,120,0,22)
fmRescanBtn.AnchorPoint=Vector2.new(1,0); fmRescanBtn.Position=UDim2.new(1,-10,0,42+4)
fmRescanBtn.BackgroundColor3=PURPLE_DARK; fmRescanBtn.BorderSizePixel=0
fmRescanBtn.Text="↺ Rescan Map"; fmRescanBtn.TextColor3=PURPLE; fmRescanBtn.TextSize=10
fmRescanBtn.Font=Enum.Font.GothamSemibold; fmRescanBtn.ZIndex=52; fmRescanBtn.Parent=FullMapFrame
Instance.new("UICorner",fmRescanBtn).CornerRadius=UDim.new(0,4)
fmRescanBtn.MouseButton1Click:Connect(function()
    fmRescanBtn.Text="Scanning..."
    task.spawn(function()
        scanMap(); applyMapGrid(mapTiles,MAP_CELLS); applyMapGrid(fullMapTiles,FULLMAP_CELLS)
        fmRescanBtn.Text="↺ Rescan Map"
    end)
end)
task.spawn(function() while not mapScanned do task.wait(0.1) end; applyMapGrid(fullMapTiles,FULLMAP_CELLS) end)

-- ══════════════════════════════════════════
--  ESP PREVIEW POPUP
-- ══════════════════════════════════════════
local ESP_W,ESP_H=130,200
local EspPreviewPopup=Instance.new("Frame")
EspPreviewPopup.Name="EspPreview"; EspPreviewPopup.Size=UDim2.new(0,ESP_W,0,ESP_H)
EspPreviewPopup.Position=UDim2.new(1,-(MINIMAP_SIZE+ESP_W+28),1,-(ESP_H+14))
EspPreviewPopup.BackgroundColor3=Color3.fromRGB(8,8,14); EspPreviewPopup.BorderSizePixel=0
EspPreviewPopup.ZIndex=5; EspPreviewPopup.Visible=state.showEspPreview; EspPreviewPopup.Active=true
EspPreviewPopup.Parent=ScreenGui
Instance.new("UICorner",EspPreviewPopup).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",EspPreviewPopup).Color=PURPLE_DIM

local epTbar=Instance.new("Frame"); epTbar.Size=UDim2.new(1,0,0,22)
epTbar.BackgroundColor3=BG2; epTbar.BorderSizePixel=0; epTbar.ZIndex=6; epTbar.Active=true; epTbar.Parent=EspPreviewPopup
Instance.new("UICorner",epTbar).CornerRadius=UDim.new(0,8)
local epTFix=Instance.new("Frame"); epTFix.Size=UDim2.new(1,0,0,8); epTFix.Position=UDim2.new(0,0,1,-8)
epTFix.BackgroundColor3=BG2; epTFix.BorderSizePixel=0; epTFix.ZIndex=6; epTFix.Parent=epTbar
local epTLbl=Instance.new("TextLabel"); epTLbl.Size=UDim2.new(1,-24,1,0); epTLbl.Position=UDim2.new(0,8,0,0)
epTLbl.BackgroundTransparency=1; epTLbl.Text="ESP Preview"; epTLbl.TextColor3=PURPLE
epTLbl.TextSize=10; epTLbl.Font=Enum.Font.GothamBold; epTLbl.TextXAlignment=Enum.TextXAlignment.Left
epTLbl.ZIndex=7; epTLbl.Parent=epTbar
local epClose=Instance.new("TextButton"); epClose.Size=UDim2.new(0,16,0,16); epClose.Position=UDim2.new(1,-20,0.5,-8)
epClose.BackgroundColor3=Color3.fromRGB(50,20,20); epClose.BorderSizePixel=0; epClose.Text="✕"
epClose.TextColor3=RED; epClose.TextSize=9; epClose.Font=Enum.Font.GothamBold; epClose.ZIndex=8; epClose.Parent=epTbar
Instance.new("UICorner",epClose).CornerRadius=UDim.new(0,3)
epClose.MouseButton1Click:Connect(function() state.showEspPreview=false; EspPreviewPopup.Visible=false end)

-- Draggable
local epDrag,epDS,epSP=false,nil,nil
epTbar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then epDrag=true; epDS=i.Position; epSP=EspPreviewPopup.Position end end)
epTbar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then epDrag=false end end)
UserInputService.InputChanged:Connect(function(i)
    if epDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-epDS
        EspPreviewPopup.Position=UDim2.new(epSP.X.Scale,epSP.X.Offset+d.X,epSP.Y.Scale,epSP.Y.Offset+d.Y)
    end
end)

local epContent=Instance.new("Frame"); epContent.Size=UDim2.new(1,0,1,-22)
epContent.Position=UDim2.new(0,0,0,22); epContent.BackgroundTransparency=1; epContent.ZIndex=6; epContent.Parent=EspPreviewPopup

local previewBox=Instance.new("Frame"); previewBox.Size=UDim2.new(0,30,0,72)
previewBox.Position=UDim2.new(0.5,-15,0,34); previewBox.BackgroundTransparency=1; previewBox.BorderSizePixel=0; previewBox.ZIndex=7; previewBox.Parent=epContent
local previewBoxStroke=Instance.new("UIStroke",previewBox); previewBoxStroke.Color=PURPLE; previewBoxStroke.Thickness=1.5
local previewHead=Instance.new("Frame"); previewHead.Size=UDim2.new(0,16,0,16)
previewHead.Position=UDim2.new(0.5,-8,0,14); previewHead.BackgroundColor3=BG3; previewHead.BorderSizePixel=0; previewHead.ZIndex=7; previewHead.Parent=epContent
Instance.new("UICorner",previewHead).CornerRadius=UDim.new(1,0)
local previewHeadStroke=Instance.new("UIStroke",previewHead); previewHeadStroke.Color=PURPLE; previewHeadStroke.Thickness=1.5
local previewName=Instance.new("TextLabel"); previewName.Size=UDim2.new(1,0,0,14); previewName.Position=UDim2.new(0,0,0,0)
previewName.BackgroundTransparency=1; previewName.Text="Enemy"; previewName.TextColor3=PURPLE
previewName.TextSize=10; previewName.Font=Enum.Font.GothamBold; previewName.TextXAlignment=Enum.TextXAlignment.Center
previewName.ZIndex=7; previewName.Parent=epContent
local previewHpBg=Instance.new("Frame"); previewHpBg.Size=UDim2.new(0,4,0,72)
previewHpBg.Position=UDim2.new(0.5,-23,0,34); previewHpBg.BackgroundColor3=Color3.fromRGB(30,0,0)
previewHpBg.BorderSizePixel=0; previewHpBg.ZIndex=7; previewHpBg.Parent=epContent
Instance.new("UICorner",previewHpBg).CornerRadius=UDim.new(0,2)
local previewHpFill=Instance.new("Frame"); previewHpFill.Size=UDim2.new(1,0,0.72,0)
previewHpFill.Position=UDim2.new(0,0,0.28,0); previewHpFill.BackgroundColor3=GREEN
previewHpFill.BorderSizePixel=0; previewHpFill.ZIndex=8; previewHpFill.Parent=previewHpBg
Instance.new("UICorner",previewHpFill).CornerRadius=UDim.new(0,2)
local previewTracer=Instance.new("Frame"); previewTracer.Size=UDim2.new(0,1.5,0,28)
previewTracer.Position=UDim2.new(0.5,0,1,-28); previewTracer.AnchorPoint=Vector2.new(0.5,0)
previewTracer.BackgroundColor3=PURPLE; previewTracer.BorderSizePixel=0; previewTracer.ZIndex=7; previewTracer.Parent=epContent
local previewHpLabel=Instance.new("TextLabel"); previewHpLabel.Size=UDim2.new(1,0,0,12)
previewHpLabel.Position=UDim2.new(0,0,1,-22); previewHpLabel.BackgroundTransparency=1; previewHpLabel.Text="72 HP"
previewHpLabel.TextColor3=GREEN; previewHpLabel.TextSize=9; previewHpLabel.Font=Enum.Font.GothamBold
previewHpLabel.TextXAlignment=Enum.TextXAlignment.Center; previewHpLabel.ZIndex=7; previewHpLabel.Parent=epContent
local previewDistLabel=Instance.new("TextLabel"); previewDistLabel.Size=UDim2.new(1,0,0,11)
previewDistLabel.Position=UDim2.new(0,0,1,-10); previewDistLabel.BackgroundTransparency=1; previewDistLabel.Text="~42m"
previewDistLabel.TextColor3=SUBTEXT; previewDistLabel.TextSize=8; previewDistLabel.Font=Enum.Font.Gotham
previewDistLabel.TextXAlignment=Enum.TextXAlignment.Center; previewDistLabel.ZIndex=7; previewDistLabel.Parent=epContent

local prevHpDir,prevHpPct=-1,0.72
RunService.Heartbeat:Connect(function(dt)
    if not EspPreviewPopup.Visible then return end
    previewBox.Visible=state.espBoxes; previewName.Visible=state.espNames
    previewHpBg.Visible=state.espHealth; previewHpFill.Visible=state.espHealth
    previewHpLabel.Visible=state.espHealth; previewTracer.Visible=state.espTracers
    previewDistLabel.Visible=state.espDistance
    previewBoxStroke.Color=state.espBoxes and PURPLE or Color3.fromRGB(40,40,55)
    previewHeadStroke.Color=state.espBoxes and PURPLE or Color3.fromRGB(40,40,55)
    prevHpPct+=prevHpDir*dt*0.08
    if prevHpPct<=0.1 then prevHpDir=1 end; if prevHpPct>=1.0 then prevHpDir=-1 end
    previewHpFill.Size=UDim2.new(1,0,prevHpPct,0); previewHpFill.Position=UDim2.new(0,0,1-prevHpPct,0)
    local hpInt=math.floor(prevHpPct*100); previewHpLabel.Text=hpInt.." HP"
    local hpC=Color3.fromRGB(math.round(255*(1-prevHpPct)),math.round(200*prevHpPct),0)
    previewHpFill.BackgroundColor3=hpC; previewHpLabel.TextColor3=hpC
    previewDistLabel.Text="~"..math.floor(30+prevHpPct*120).."m"
end)

-- ══════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════
local FovCircle=Instance.new("Frame"); FovCircle.BackgroundTransparency=1; FovCircle.BorderSizePixel=0
FovCircle.ZIndex=10; FovCircle.Visible=false; FovCircle.Parent=ScreenGui
Instance.new("UICorner",FovCircle).CornerRadius=UDim.new(1,0)
local FovStroke=Instance.new("UIStroke"); FovStroke.Color=PURPLE; FovStroke.Thickness=1.5; FovStroke.Transparency=0.2; FovStroke.Parent=FovCircle
RunService.RenderStepped:Connect(function()
    FovCircle.Visible=ShowingFoV and Configuration.FoVCheck
    if not FovCircle.Visible then return end
    local r=Configuration.FoVRadius; local ml=UserInputService:GetMouseLocation()
    FovCircle.Size=UDim2.new(0,r*2,0,r*2); FovCircle.Position=UDim2.new(0,ml.X-r,0,ml.Y-r)
end)

-- ══════════════════════════════════════════
--  CUSTOM CROSSHAIR  (Drawing API)
-- ══════════════════════════════════════════
local crosshairDrawings={}
local function rebuildCrosshair()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end
    crosshairDrawings={}
    if not state.crosshair or not hasDrawing then return end
    local s=state.crosshairSize; local col=state.crosshairColor or PURPLE
    if state.crosshairStyle=="Plus" then
        for _,def in {
            {Vector2.new(-s,0),Vector2.new(s,0)},
            {Vector2.new(0,-s),Vector2.new(0,s)}
        } do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]
            l.Color=col; l.Thickness=1.5; l.Transparency=1; l.Visible=true
            table.insert(crosshairDrawings,l)
        end
    elseif state.crosshairStyle=="Dot" then
        local c=Drawing.new("Circle"); c.Radius=3; c.Color=col; c.Filled=true
        c.Transparency=1; c.Visible=true; table.insert(crosshairDrawings,c)
    elseif state.crosshairStyle=="X" then
        for _,def in {
            {Vector2.new(-s,-s),Vector2.new(s,s)},
            {Vector2.new(s,-s),Vector2.new(-s,s)}
        } do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]
            l.Color=col; l.Thickness=1.5; l.Transparency=1; l.Visible=true
            table.insert(crosshairDrawings,l)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not state.crosshair or not hasDrawing or #crosshairDrawings==0 then return end
    local vp=workspace.CurrentCamera.ViewportSize
    local cx,cy=vp.X/2,vp.Y/2
    for _,d in crosshairDrawings do
        if d.From~=nil then -- Line
            local base=Vector2.new(cx,cy)
            if d.From.X<0 or d.From.Y<0 or (d.From.X==0 and d.From.Y~=0) then
                -- recalculate per-line offset stored at creation via closure
                -- just update center-relative positions
            end
        elseif d.Position~=nil then -- Circle
            d.Position=Vector2.new(cx,cy)
        end
    end
end)

-- We rebuild with absolute coords each frame
RunService.RenderStepped:Connect(function()
    if not state.crosshair or not hasDrawing then return end
    if #crosshairDrawings==0 then return end
    local vp=workspace.CurrentCamera.ViewportSize
    local cx,cy=vp.X/2,vp.Y/2
    local s=state.crosshairSize
    if state.crosshairStyle=="Plus" and #crosshairDrawings>=2 then
        crosshairDrawings[1].From=Vector2.new(cx-s,cy); crosshairDrawings[1].To=Vector2.new(cx+s,cy)
        crosshairDrawings[2].From=Vector2.new(cx,cy-s); crosshairDrawings[2].To=Vector2.new(cx,cy+s)
    elseif state.crosshairStyle=="X" and #crosshairDrawings>=2 then
        crosshairDrawings[1].From=Vector2.new(cx-s,cy-s); crosshairDrawings[1].To=Vector2.new(cx+s,cy+s)
        crosshairDrawings[2].From=Vector2.new(cx+s,cy-s); crosshairDrawings[2].To=Vector2.new(cx-s,cy+s)
    elseif state.crosshairStyle=="Dot" and #crosshairDrawings>=1 then
        crosshairDrawings[1].Position=Vector2.new(cx,cy)
    end
end)

-- ══════════════════════════════════════════
--  ESP DRAWINGS
-- ══════════════════════════════════════════
local espDrawings={}

local function newDraw(t,props)
    if not hasDrawing then return nil end
    local ok,obj=pcall(Drawing.new,t); if not ok then return nil end
    for k,v in props do pcall(function() obj[k]=v end) end; return obj
end

local function hideDrawings(d)
    if not d then return end
    for _,k in {"box","nameText","healthBg","healthFill","tracer","distLabel"} do
        if d[k] then pcall(function() d[k].Visible=false end) end
    end
end

local function destroyDrawings(d)
    if not d then return end
    for _,k in {"box","nameText","healthBg","healthFill","tracer","distLabel"} do
        pcall(function() if d[k] then d[k]:Remove() end end)
    end
end

local function getOrCreateESP(plr)
    if not hasDrawing then return nil end
    if espDrawings[plr] then return espDrawings[plr] end
    local d={}
    d.box=newDraw("Square",{Visible=false,Color=PURPLE,Thickness=1,Filled=false,Transparency=1})
    d.nameText=newDraw("Text",{Visible=false,Color=PURPLE,Size=13,Center=true,
        Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,
        Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    d.healthBg=newDraw("Square",{Visible=false,Color=Color3.fromRGB(20,20,20),Filled=true,Transparency=0.5,Thickness=1})
    d.healthFill=newDraw("Square",{Visible=false,Color=Color3.fromRGB(80,255,80),Filled=true,Transparency=1,Thickness=1})
    d.tracer=newDraw("Line",{Visible=false,Color=PURPLE,Thickness=tracerThickness,Transparency=1})
    d.distLabel=newDraw("Text",{Visible=false,Color=SUBTEXT,Size=11,Center=true,
        Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,
        Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    espDrawings[plr]=d; return d
end

local function updateESPForPlayer(plr)
    local d=getOrCreateESP(plr); if not d then return end
    local char=plr.Character; if not char then hideDrawings(d); return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideDrawings(d); return end
    local cam=workspace.CurrentCamera
    local topSP=cam:WorldToViewportPoint(head.Position+Vector3.new(0,head.Size.Y/2+0.1,0))
    local botSP=cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,hrp.Size.Y/2+0.3,0))
    local hrpSP,hrpVis=cam:WorldToViewportPoint(hrp.Position)
    if not hrpVis then hideDrawings(d); return end
    local boxH=math.abs(botSP.Y-topSP.Y); local boxW=boxH*0.55
    local boxX=hrpSP.X-boxW/2; local boxY=topSP.Y
    local isTarget=(char==Target)
    local col=isTarget and GOLD or PURPLE
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    local hpCol=Color3.fromRGB(math.round(255*(1-pct)),math.round(200*pct),0)
    local myHead=getHead()
    local dist=myHead and math.round((head.Position-myHead.Position).Magnitude) or 0

    if d.box then
        d.box.Visible=state.esp and state.espBoxes
        if d.box.Visible then d.box.Position=Vector2.new(boxX,boxY); d.box.Size=Vector2.new(boxW,boxH); d.box.Color=col; d.box.Thickness=isTarget and 2 or 1 end
    end
    if d.nameText then
        d.nameText.Visible=state.esp and state.espNames
        if d.nameText.Visible then d.nameText.Text=plr.DisplayName..(isTarget and " ◀" or ""); d.nameText.Position=Vector2.new(hrpSP.X,topSP.Y-16); d.nameText.Color=col end
    end
    local barW,barX=4,boxX-barW-2
    if d.healthBg then
        d.healthBg.Visible=state.esp and state.espHealth
        if d.healthBg.Visible then d.healthBg.Position=Vector2.new(barX,boxY); d.healthBg.Size=Vector2.new(barW,boxH); d.healthBg.Color=Color3.fromRGB(20,20,20) end
    end
    if d.healthFill then
        local fH=boxH*pct
        d.healthFill.Visible=state.esp and state.espHealth
        if d.healthFill.Visible then d.healthFill.Position=Vector2.new(barX,boxY+boxH-fH); d.healthFill.Size=Vector2.new(barW,fH); d.healthFill.Color=hpCol end
    end
    if d.tracer then
        local vp=cam.ViewportSize
        d.tracer.Visible=state.esp and state.espTracers
        if d.tracer.Visible then d.tracer.From=Vector2.new(vp.X/2,vp.Y); d.tracer.To=Vector2.new(hrpSP.X,botSP.Y); d.tracer.Color=col; d.tracer.Thickness=isTarget and tracerThickness+1 or tracerThickness end
    end
    if d.distLabel then
        d.distLabel.Visible=state.esp and state.espDistance
        if d.distLabel.Visible then d.distLabel.Text=tostring(dist).."m"; d.distLabel.Position=Vector2.new(hrpSP.X,botSP.Y+2); d.distLabel.Color=isTarget and GOLD or SUBTEXT end
    end
    if state.esp and state.espChams then
        for _,p in char:GetDescendants() do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Material=Enum.Material.Neon; p.Color=isTarget and GOLD or PURPLE_DIM
            end
        end
    end
end

local function cleanupESPForPlayer(plr)
    if espDrawings[plr] then destroyDrawings(espDrawings[plr]); espDrawings[plr]=nil end
end
local function cleanupAllESP()
    for plr in espDrawings do destroyDrawings(espDrawings[plr]); espDrawings[plr]=nil end
end

-- ══════════════════════════════════════════
--  HITBOX EXPANDER
-- ══════════════════════════════════════════
local function applyHitboxes(on)
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; if not char then continue end
        local head=char:FindFirstChild("Head"); if not head then continue end
        if on then head.Size=Vector3.new(state.hitboxSize,state.hitboxSize,state.hitboxSize)
        else head.Size=Vector3.new(2,1,1) end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        if state.hitboxExpander then
            local head=char:FindFirstChild("Head"); if head then head.Size=Vector3.new(state.hitboxSize,state.hitboxSize,state.hitboxSize) end
        end
        if state.esp then updateESPForPlayer(plr) end
    end)
end)

-- ══════════════════════════════════════════
--  FAKE LAG
-- ══════════════════════════════════════════
local fakeLagConn=nil
local function setFakeLag(on)
    if fakeLagConn then fakeLagConn:Disconnect(); fakeLagConn=nil end
    if on then
        fakeLagConn=RunService.Heartbeat:Connect(function()
            if not state.fakelag then return end
            local hrp=getHRP(); if not hrp then return end
            local origin=hrp.CFrame
            for i=1,state.fakelagAmount do
                hrp.CFrame=origin*CFrame.new(math.random(-1,1)*0.5,0,math.random(-1,1)*0.5)
            end
            hrp.CFrame=origin
        end)
    end
end

-- ══════════════════════════════════════════
--  THIRD PERSON CAMERA
-- ══════════════════════════════════════════
local originalMaxZoom=400
local function setThirdPerson(on)
    if on then
        originalMaxZoom=Player.CameraMaxZoomDistance
        Player.CameraMaxZoomDistance=state.tpDistance
        Player.CameraMinZoomDistance=state.tpDistance
    else
        Player.CameraMaxZoomDistance=originalMaxZoom
        Player.CameraMinZoomDistance=0.5
    end
end

-- ══════════════════════════════════════════
--  AUTO REJOIN
-- ══════════════════════════════════════════
local function setupAutoRejoin()
    Player.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid",10)
        if not hum then return end
        hum.Died:Connect(function()
            if state.autoRejoin then
                task.wait(3)
                TeleportService:Teleport(game.PlaceId,Player)
            end
        end)
    end)
end
setupAutoRejoin()

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local Win=Instance.new("Frame"); Win.Name="VenomWin"; Win.Size=UDim2.new(0,840,0,520)
Win.Position=UDim2.new(0.5,-420,0.5,-260); Win.BackgroundColor3=BG; Win.BorderSizePixel=0; Win.Active=true; Win.Parent=ScreenGui
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",Win).Color=PURPLE_DIM

local TopAccent=Instance.new("Frame"); TopAccent.Size=UDim2.new(1,0,0,2); TopAccent.BackgroundColor3=PURPLE
TopAccent.BorderSizePixel=0; TopAccent.ZIndex=2; TopAccent.Parent=Win
Instance.new("UICorner",TopAccent).CornerRadius=UDim.new(0,8)

local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,36); TitleBar.BackgroundColor3=BG2
TitleBar.BorderSizePixel=0; TitleBar.Active=true; TitleBar.Parent=Win
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,8)
local TFix=Instance.new("Frame"); TFix.Size=UDim2.new(1,0,0,10); TFix.Position=UDim2.new(0,0,1,-10)
TFix.BackgroundColor3=BG2; TFix.BorderSizePixel=0; TFix.Parent=TitleBar

local Logo=Instance.new("TextLabel"); Logo.Size=UDim2.new(0,100,1,0); Logo.Position=UDim2.new(0,14,0,0)
Logo.BackgroundTransparency=1; Logo.Text="venom.lol"; Logo.TextColor3=PURPLE
Logo.TextSize=15; Logo.Font=Enum.Font.GothamBold; Logo.TextXAlignment=Enum.TextXAlignment.Left; Logo.Parent=TitleBar
local LogoSub=Instance.new("TextLabel"); LogoSub.Size=UDim2.new(0,50,1,0); LogoSub.Position=UDim2.new(0,102,0,0)
LogoSub.BackgroundTransparency=1; LogoSub.Text="v2.0"; LogoSub.TextColor3=SUBTEXT
LogoSub.TextSize=10; LogoSub.Font=Enum.Font.Gotham; LogoSub.TextXAlignment=Enum.TextXAlignment.Left; LogoSub.Parent=TitleBar

local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,22,0,22); CloseBtn.Position=UDim2.new(1,-30,0.5,-11)
CloseBtn.BackgroundColor3=Color3.fromRGB(50,20,20); CloseBtn.Text="✕"; CloseBtn.TextColor3=RED
CloseBtn.TextSize=11; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.BorderSizePixel=0; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,4)
CloseBtn.MouseButton1Click:Connect(function() saveConfig(); cleanupAllESP()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end; ScreenGui:Destroy() end)

local MinBtn=Instance.new("TextButton"); MinBtn.Size=UDim2.new(0,22,0,22); MinBtn.Position=UDim2.new(1,-56,0.5,-11)
MinBtn.BackgroundColor3=PURPLE_DARK; MinBtn.Text="─"; MinBtn.TextColor3=PURPLE
MinBtn.TextSize=11; MinBtn.Font=Enum.Font.GothamBold; MinBtn.BorderSizePixel=0; MinBtn.Parent=TitleBar
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,4)

local TabBarFrame=Instance.new("Frame"); TabBarFrame.Size=UDim2.new(1,-290,1,0); TabBarFrame.Position=UDim2.new(0,160,0,0)
TabBarFrame.BackgroundTransparency=1; TabBarFrame.Parent=TitleBar
local TabBarLayout=Instance.new("UIListLayout"); TabBarLayout.FillDirection=Enum.FillDirection.Horizontal
TabBarLayout.SortOrder=Enum.SortOrder.LayoutOrder; TabBarLayout.Padding=UDim.new(0,2)
TabBarLayout.VerticalAlignment=Enum.VerticalAlignment.Center; TabBarLayout.Parent=TabBarFrame

local dragging,dragStart,startPos=false,nil,nil
TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=Win.Position end end)
TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart; Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)

local minimised=false
MinBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    for _,c in Win:GetChildren() do if c~=TitleBar and c~=TopAccent then c.Visible=not minimised end end
    Win.Size=minimised and UDim2.new(0,840,0,36) or UDim2.new(0,840,0,520)
end)

local Body=Instance.new("Frame"); Body.Size=UDim2.new(1,0,1,-36); Body.Position=UDim2.new(0,0,0,36)
Body.BackgroundTransparency=1; Body.Parent=Win

local LeftPanel=Instance.new("Frame"); LeftPanel.Size=UDim2.new(0,270,1,0)
LeftPanel.BackgroundColor3=BG2; LeftPanel.BorderSizePixel=0; LeftPanel.Parent=Body

local LeftScroll=Instance.new("ScrollingFrame"); LeftScroll.Size=UDim2.new(1,-4,1,-10); LeftScroll.Position=UDim2.new(0,4,0,5)
LeftScroll.BackgroundTransparency=1; LeftScroll.BorderSizePixel=0; LeftScroll.ScrollBarThickness=3
LeftScroll.ScrollBarImageColor3=PURPLE; LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
LeftScroll.CanvasSize=UDim2.new(0,0,0,0); LeftScroll.Parent=LeftPanel
local LL=Instance.new("UIListLayout"); LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.Padding=UDim.new(0,3); LL.Parent=LeftScroll
local LP=Instance.new("UIPadding"); LP.PaddingLeft=UDim.new(0,8); LP.PaddingRight=UDim.new(0,8)
LP.PaddingTop=UDim.new(0,8); LP.PaddingBottom=UDim.new(0,8); LP.Parent=LeftScroll

local Div=Instance.new("Frame"); Div.Size=UDim2.new(0,1,1,0); Div.Position=UDim2.new(0,270,0,0)
Div.BackgroundColor3=PURPLE_DARK; Div.BorderSizePixel=0; Div.Parent=Body

local RightPanel=Instance.new("Frame"); RightPanel.Size=UDim2.new(1,-272,1,0); RightPanel.Position=UDim2.new(0,272,0,0)
RightPanel.BackgroundColor3=BG; RightPanel.BorderSizePixel=0; RightPanel.Parent=Body

local RightScroll=Instance.new("ScrollingFrame"); RightScroll.Size=UDim2.new(1,-4,1,-10); RightScroll.Position=UDim2.new(0,4,0,5)
RightScroll.BackgroundTransparency=1; RightScroll.BorderSizePixel=0; RightScroll.ScrollBarThickness=3
RightScroll.ScrollBarImageColor3=PURPLE; RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
RightScroll.CanvasSize=UDim2.new(0,0,0,0); RightScroll.Parent=RightPanel
local RL=Instance.new("UIListLayout"); RL.SortOrder=Enum.SortOrder.LayoutOrder; RL.Padding=UDim.new(0,3); RL.Parent=RightScroll
local RP=Instance.new("UIPadding"); RP.PaddingLeft=UDim.new(0,10); RP.PaddingRight=UDim.new(0,10)
RP.PaddingTop=UDim.new(0,8); RP.PaddingBottom=UDim.new(0,8); RP.Parent=RightScroll

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabs={}
local function makeTabBtn(name,order)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,72,0,26); btn.BackgroundColor3=BG3
    btn.BorderSizePixel=0; btn.Text=name; btn.TextColor3=SUBTEXT; btn.TextSize=10
    btn.Font=Enum.Font.GothamSemibold; btn.LayoutOrder=order; btn.Parent=TabBarFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    local ul=Instance.new("Frame"); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2)
    ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false; ul.Parent=btn
    Instance.new("UICorner",ul).CornerRadius=UDim.new(1,0)
    local td={btn=btn,underline=ul,leftItems={},rightItems={}}; table.insert(tabs,td)
    btn.MouseButton1Click:Connect(function()
        for _,t in tabs do t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
            for _,i in t.leftItems do i.Visible=false end; for _,i in t.rightItems do i.Visible=false end end
        btn.TextColor3=PURPLE; btn.BackgroundColor3=PURPLE_DARK; ul.Visible=true
        for _,i in td.leftItems do i.Visible=true end; for _,i in td.rightItems do i.Visible=true end
    end); return td
end
local function activateTab(td)
    for _,t in tabs do t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
        for _,i in t.leftItems do i.Visible=false end; for _,i in t.rightItems do i.Visible=false end end
    td.btn.TextColor3=PURPLE; td.btn.BackgroundColor3=PURPLE_DARK; td.underline.Visible=true
    for _,i in td.leftItems do i.Visible=true end; for _,i in td.rightItems do i.Visible=true end
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════
local LO,RO=0,0
local function SL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1;f.LayoutOrder=RO;f.Parent=RightScroll else LO+=1;f.LayoutOrder=LO;f.Parent=LeftScroll end
    local ln=Instance.new("Frame"); ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,1,-1)
    ln.BackgroundColor3=PURPLE_DARK; ln.BorderSizePixel=0; ln.Parent=f
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=text; lb.TextColor3=SUBTEXT; lb.TextSize=10; lb.Font=Enum.Font.GothamSemibold
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end
local function TG(name,kb,def,cb,isR)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.Visible=false
    if isR then RO+=1;row.LayoutOrder=RO;row.Parent=RightScroll else LO+=1;row.LayoutOrder=LO;row.Parent=LeftScroll end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,14,0,14); dot.Position=UDim2.new(0,0,0.5,-7)
    dot.BackgroundColor3=def and PURPLE or Color3.fromRGB(50,50,60); dot.BorderSizePixel=0; dot.Parent=row
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,3)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,20,0,0)
    lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=def and TEXT or SUBTEXT
    lb.TextSize=12; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row
    if kb and kb~="" then local kl=Instance.new("TextLabel"); kl.Size=UDim2.new(0,60,1,0); kl.Position=UDim2.new(1,-60,0,0)
        kl.BackgroundTransparency=1; kl.Text="["..kb.."]"; kl.TextColor3=PURPLE_DIM; kl.TextSize=10
        kl.Font=Enum.Font.Gotham; kl.TextXAlignment=Enum.TextXAlignment.Right; kl.Parent=row end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    local st=def
    local function setState(v) st=v
        TweenService:Create(dot,TWEEN_FAST,{BackgroundColor3=st and PURPLE or Color3.fromRGB(50,50,60)}):Play()
        lb.TextColor3=st and TEXT or SUBTEXT; if cb then cb(st) end end
    btn.MouseButton1Click:Connect(function() setState(not st) end); return row, setState
end
local function SLD(name,mn,mx,def,sfx,cb,isR)
    sfx=sfx or ""
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,46); card.BackgroundTransparency=1; card.Visible=false
    if isR then RO+=1;card.LayoutOrder=RO;card.Parent=RightScroll else LO+=1;card.LayoutOrder=LO;card.Parent=LeftScroll end
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.6,0,0,18); nL.BackgroundTransparency=1
    nL.Text=name; nL.TextColor3=SUBTEXT; nL.TextSize=11; nL.Font=Enum.Font.Gotham
    nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(0.4,0,0,18); vL.Position=UDim2.new(0.6,0,0,0)
    vL.BackgroundTransparency=1; vL.Text=tostring(def)..sfx; vL.TextColor3=PURPLE
    vL.TextSize=11; vL.Font=Enum.Font.GothamBold; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.Parent=card
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(1,0,0,4); tr.Position=UDim2.new(0,0,0,26)
    tr.BackgroundColor3=Color3.fromRGB(35,25,55); tr.BorderSizePixel=0; tr.Parent=card
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local p0=math.clamp((def-mn)/(mx-mn),0,1)
    local fl=Instance.new("Frame"); fl.Size=UDim2.new(p0,0,1,0); fl.BackgroundColor3=PURPLE; fl.BorderSizePixel=0; fl.Parent=tr
    Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,12,0,12); kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new(p0,0,0.5,0); kn.BackgroundColor3=Color3.fromRGB(220,200,255); kn.BorderSizePixel=0; kn.ZIndex=3; kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local sd=false
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end)
    RunService.RenderStepped:Connect(function()
        if not sd then return end
        local mp=UserInputService:GetMouseLocation(); local p=math.clamp((mp.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.round(mn+p*(mx-mn)); fl.Size=UDim2.new(p,0,1,0); kn.Position=UDim2.new(p,0,0.5,0)
        vL.Text=tostring(v)..sfx; if cb then cb(v) end end)
    return card
end
local function DD(name,opts,def,cb,isR)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isR then RO+=1;card.LayoutOrder=RO;card.Parent=RightScroll else LO+=1;card.LayoutOrder=LO;card.Parent=LeftScroll end
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(0.5,0,1,0); vL.BackgroundTransparency=1
    vL.Text=def; vL.TextColor3=TEXT; vL.TextSize=11; vL.Font=Enum.Font.Gotham; vL.TextXAlignment=Enum.TextXAlignment.Left; vL.Parent=card
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.5,0,1,0); nL.Position=UDim2.new(0.5,0,0,0)
    nL.BackgroundTransparency=1; nL.Text=name; nL.TextColor3=SUBTEXT; nL.TextSize=11; nL.Font=Enum.Font.Gotham
    nL.TextXAlignment=Enum.TextXAlignment.Right; nL.Parent=card
    local idx=1; for i,v in opts do if v==def then idx=i; break end end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=card
    btn.MouseButton1Click:Connect(function() idx=(idx%#opts)+1; vL.Text=opts[idx]; if cb then cb(opts[idx]) end end); return card
end
local function TL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1;f.LayoutOrder=RO;f.Parent=RightScroll else LO+=1;f.LayoutOrder=LO;f.Parent=LeftScroll end
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=text; lb.TextColor3=SUBTEXT; lb.TextSize=11; lb.Font=Enum.Font.Gotham
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end
local function addL(t,i) table.insert(t.leftItems,i) end
local function addR(t,i) table.insert(t.rightItems,i) end

-- ══════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════
local tAimbot  = makeTabBtn("aimbot",   1)
local tBots    = makeTabBtn("bots",     2)
local tChecks  = makeTabBtn("checks",   3)
local tVisuals = makeTabBtn("visuals",  4)
local tMove    = makeTabBtn("movement", 5)
local tAddons  = makeTabBtn("addons",   6)
local tConfig  = makeTabBtn("config",   7)

-- ── AIMBOT TAB ──
addL(tAimbot, SL("Aimbot",false))
addL(tAimbot, TG("Enable Aimbot","",Configuration.Aimbot,function(on) Configuration.Aimbot=on; if not on then ResetAimbotFields() end end,false))
addL(tAimbot, TG("One-Press Mode","",Configuration.OnePressAimingMode,function(on) Configuration.OnePressAimingMode=on end,false))
addL(tAimbot, DD("Aim Mode",{"Camera","Mouse","Silent"},Configuration.AimMode,function(v) Configuration.AimMode=v end,false))
addL(tAimbot, DD("Aim Part",{"Head","HumanoidRootPart","Torso","UpperTorso"},Configuration.AimPart,function(v) Configuration.AimPart=v end,false))
addL(tAimbot, TG("Show FOV Circle","",false,function(on) ShowingFoV=on end,false))
addL(tAimbot, SLD("FOV Radius",10,600,Configuration.FoVRadius,"px",function(v) Configuration.FoVRadius=v end,false))
addL(tAimbot, TG("Off After Kill","",Configuration.OffAimbotAfterKill,function(on) Configuration.OffAimbotAfterKill=on end,false))
addL(tAimbot, SL("Offset",false))
addL(tAimbot, TG("Use Offset","",Configuration.UseOffset,function(on) Configuration.UseOffset=on end,false))
addL(tAimbot, DD("Offset Type",{"Static","Dynamic","Static & Dynamic"},Configuration.OffsetType,function(v) Configuration.OffsetType=v end,false))
addL(tAimbot, SLD("Static Offset",1,50,Configuration.StaticOffsetIncrement,"",function(v) Configuration.StaticOffsetIncrement=v end,false))
addL(tAimbot, SLD("Dynamic Offset",1,50,Configuration.DynamicOffsetIncrement,"",function(v) Configuration.DynamicOffsetIncrement=v end,false))
addR(tAimbot, SL("Sensitivity & Noise",true))
addR(tAimbot, TG("Use Sensitivity","",Configuration.UseSensitivity,function(on) Configuration.UseSensitivity=on end,true))
addR(tAimbot, SLD("Sensitivity",1,100,Configuration.Sensitivity,"",function(v) Configuration.Sensitivity=v end,true))
addR(tAimbot, TG("Use Noise","",Configuration.UseNoise,function(on) Configuration.UseNoise=on end,true))
addR(tAimbot, SLD("Noise Frequency",1,100,Configuration.NoiseFrequency,"",function(v) Configuration.NoiseFrequency=v end,true))
addR(tAimbot, SL("Silent Aim",true))
addR(tAimbot, TG("Mouse.Hit/Target","",true,function(on)
    local k="Mouse.Hit / Mouse.Target"
    if on then if not table.find(Configuration.SilentAimMethods,k) then table.insert(Configuration.SilentAimMethods,k) end
    else local i=table.find(Configuration.SilentAimMethods,k); if i then table.remove(Configuration.SilentAimMethods,i) end end end,true))
addR(tAimbot, TG("GetMouseLocation","",true,function(on)
    local k="GetMouseLocation"
    if on then if not table.find(Configuration.SilentAimMethods,k) then table.insert(Configuration.SilentAimMethods,k) end
    else local i=table.find(Configuration.SilentAimMethods,k); if i then table.remove(Configuration.SilentAimMethods,i) end end end,true))
addR(tAimbot, TG("Raycast","",false,function(on)
    local k="Raycast"
    if on then if not table.find(Configuration.SilentAimMethods,k) then table.insert(Configuration.SilentAimMethods,k) end
    else local i=table.find(Configuration.SilentAimMethods,k); if i then table.remove(Configuration.SilentAimMethods,i) end end end,true))
addR(tAimbot, SLD("Silent Chance",1,100,Configuration.SilentAimChance,"%",function(v) Configuration.SilentAimChance=v end,true))

-- ── BOTS TAB ──
addL(tBots, SL("SpinBot",false))
addL(tBots, TG("Enable SpinBot","",Configuration.SpinBot,function(on) Configuration.SpinBot=on; if not on then Spinning=false end end,false))
addL(tBots, SLD("Spin Velocity",1,100,Configuration.SpinBotVelocity,"°/f",function(v) Configuration.SpinBotVelocity=v end,false))
addL(tBots, DD("Spin Part",{"Head","HumanoidRootPart"},Configuration.SpinPart,function(v) Configuration.SpinPart=v end,false))
addL(tBots, SL("TriggerBot",false))
if hasMouse1Click then
    addL(tBots, TG("Enable TriggerBot","",Configuration.TriggerBot,function(on) Configuration.TriggerBot=on end,false))
    addL(tBots, TG("Smart (only while aiming)","",Configuration.SmartTriggerBot,function(on) Configuration.SmartTriggerBot=on end,false))
    addL(tBots, SLD("Hit Chance",1,100,Configuration.TriggerBotChance,"%",function(v) Configuration.TriggerBotChance=v end,false))
else
    addL(tBots, TL("⚠ mouse1click not available",false))
end

-- ── CHECKS TAB ──
addL(tChecks, SL("Basic Checks",false))
addL(tChecks, TG("Alive Check","",Configuration.AliveCheck,function(on) Configuration.AliveCheck=on end,false))
addL(tChecks, TG("God Check","",Configuration.GodCheck,function(on) Configuration.GodCheck=on end,false))
addL(tChecks, TG("Team Check","",Configuration.TeamCheck,function(on) Configuration.TeamCheck=on end,false))
addL(tChecks, TG("Friend Check","",Configuration.FriendCheck,function(on) Configuration.FriendCheck=on end,false))
addL(tChecks, TG("Wall Check","",Configuration.WallCheck,function(on) Configuration.WallCheck=on end,false))
addR(tChecks, SL("Advanced Checks",true))
addR(tChecks, TG("FoV Check","",Configuration.FoVCheck,function(on) Configuration.FoVCheck=on end,true))
addR(tChecks, TG("Magnitude Check","",Configuration.MagnitudeCheck,function(on) Configuration.MagnitudeCheck=on end,true))
addR(tChecks, SLD("Max Magnitude",10,1000,Configuration.TriggerMagnitude,"st",function(v) Configuration.TriggerMagnitude=v end,true))
addR(tChecks, TG("Transparency Check","",Configuration.TransparencyCheck,function(on) Configuration.TransparencyCheck=on end,true))
addR(tChecks, TG("Ignored Players","",Configuration.IgnoredPlayersCheck,function(on) Configuration.IgnoredPlayersCheck=on end,true))
addR(tChecks, TG("Target Players","",Configuration.TargetPlayersCheck,function(on) Configuration.TargetPlayersCheck=on end,true))

-- ── VISUALS TAB ──
addL(tVisuals, SL("ESP",false))
addL(tVisuals, TG("ESP Master","",state.esp,function(on) state.esp=on
    if not on then for _,d in espDrawings do hideDrawings(d) end end end,false))
addL(tVisuals, TG("Boxes","",state.espBoxes,function(on) state.espBoxes=on end,false))
addL(tVisuals, TG("Names","",state.espNames,function(on) state.espNames=on end,false))
addL(tVisuals, TG("Health","",state.espHealth,function(on) state.espHealth=on end,false))
addL(tVisuals, TG("Tracers","",state.espTracers,function(on) state.espTracers=on
    if not on then for _,d in espDrawings do if d.tracer then pcall(function() d.tracer.Visible=false end) end end end end,false))
addL(tVisuals, TG("Distance Labels","",state.espDistance,function(on) state.espDistance=on end,false))
addL(tVisuals, TG("Chams","",state.espChams,function(on) state.espChams=on
    if not on then for _,p in Players:GetPlayers() do if p~=Player and p.Character then
        for _,pt in p.Character:GetDescendants() do if pt:IsA("BasePart") then pt.Material=Enum.Material.SmoothPlastic end end end end end end,false))
if not hasDrawing then addL(tVisuals, TL("⚠ Drawing API unavailable",false)) end
addR(tVisuals, SL("World",true))
addR(tVisuals, TG("Fullbright","",state.fullbright,function(on) state.fullbright=on
    Lighting.Brightness=on and 10 or 1
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127) end,true))
addR(tVisuals, TG("No Fog","",state.noFog,function(on) state.noFog=on
    local a=Lighting:FindFirstChildOfClass("Atmosphere"); if a then a.Density=on and 0 or 0.395 end end,true))
addR(tVisuals, TG("No Shadows","",state.noShadows,function(on) state.noShadows=on; Lighting.GlobalShadows=not on end,true))
addR(tVisuals, SL("ESP Preview",true))
addR(tVisuals, TG("Show Preview","",state.showEspPreview,function(on) state.showEspPreview=on; EspPreviewPopup.Visible=on end,true))
addR(tVisuals, TL("Popup is draggable by title bar",true))

-- ── MOVEMENT TAB ──
addL(tMove, SL("Movement",false))
addL(tMove, TG("Fly","",state.flyEnabled,function(on)
    state.flyEnabled=on; local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
    if on then hum.PlatformStand=true
        bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
        bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=hrp
    else if bv then bv:Destroy();bv=nil end; if bg then bg:Destroy();bg=nil end; hum.PlatformStand=false end
end,false))
addL(tMove, TG("Noclip","",state.noclip,function(on) state.noclip=on end,false))
addL(tMove, TG("Infinite Jump","",state.infiniteJump,function(on) state.infiniteJump=on end,false))
addL(tMove, TG("Bunny Hop","B",state.bunnyhop,function(on) state.bunnyhop=on end,false))
addL(tMove, TG("Auto Sprint","",state.autoSprint,function(on) state.autoSprint=on end,false))
addL(tMove, SLD("Sprint Speed",16,100,state.sprintSpeed,"",function(v) state.sprintSpeed=v end,false))
addL(tMove, TG("Speed Boost","",state.speedBoost,function(on) state.speedBoost=on end,false))
addL(tMove, SLD("Walk Speed",8,200,state.walkSpeed,"",function(v) state.walkSpeed=v end,false))
addL(tMove, SLD("Jump Power",0,300,state.jumpPower,"",function(v) state.jumpPower=v end,false))
addR(tMove, SL("Player",true))
addR(tMove, TG("God Mode","",state.godMode,function(on) state.godMode=on end,true))
addR(tMove, TG("Anti-AFK","",state.antiAfk,function(on) state.antiAfk=on end,true))
addR(tMove, TG("Invisible","",state.invisible,function(on)
    state.invisible=on; local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do if p:IsA("BasePart") then p.Transparency=on and 1 or 0 end end end,true))
addR(tMove, TG("Third Person","",state.thirdPerson,function(on) state.thirdPerson=on; setThirdPerson(on) end,true))
addR(tMove, SLD("3P Distance",3,30,state.tpDistance,"st",function(v)
    state.tpDistance=v; if state.thirdPerson then Player.CameraMaxZoomDistance=v; Player.CameraMinZoomDistance=v end end,true))

-- ── ADDONS TAB ──
addL(tAddons, SL("Crosshair",false))
addL(tAddons, TG("Custom Crosshair","",state.crosshair,function(on) state.crosshair=on; rebuildCrosshair() end,false))
addL(tAddons, DD("Style",{"Plus","Dot","X"},state.crosshairStyle,function(v) state.crosshairStyle=v; rebuildCrosshair() end,false))
addL(tAddons, SLD("Size",4,30,state.crosshairSize,"px",function(v) state.crosshairSize=v; rebuildCrosshair() end,false))
addL(tAddons, SL("Combat Addons",false))
addL(tAddons, TG("Hitbox Expander","",state.hitboxExpander,function(on) state.hitboxExpander=on; applyHitboxes(on) end,false))
addL(tAddons, SLD("Hitbox Size",2,20,state.hitboxSize,"st",function(v) state.hitboxSize=v; if state.hitboxExpander then applyHitboxes(true) end end,false))
addL(tAddons, SL("Utility",false))
addL(tAddons, TG("Fake Lag","",state.fakelag,function(on) state.fakelag=on; setFakeLag(on) end,false))
addL(tAddons, SLD("Lag Frames",1,10,state.fakelagAmount,"f",function(v) state.fakelagAmount=v end,false))
addL(tAddons, TG("Auto Rejoin on Death","",state.autoRejoin,function(on) state.autoRejoin=on end,false))
addR(tAddons, SL("Minimap",true))
addR(tAddons, TG("Show Minimap","",state.minimapEnabled,function(on) state.minimapEnabled=on; MinimapFrame.Visible=on end,true))
addR(tAddons, SLD("Radar Range",50,1000,state.minimapRange,"st",function(v)
    state.minimapRange=v; mmLabel.Text="RADAR  ·  "..tostring(v).."st" end,true))
addR(tAddons, TG("Show Game Map","",state.showGameMap,function(on) state.showGameMap=on; mapLayer.Visible=on end,true))
addR(tAddons, TL("Press [M] for full Fortnite-style map",true))
addR(tAddons, SL("Keybinds",true))
addR(tAddons, TL("GUI Toggle:  [RShift]",true))
addR(tAddons, TL("Aim Key:     [RMB]",true))
addR(tAddons, TL("Full Map:    [M]",true))

-- ── CONFIG TAB ──
addL(tConfig, SL("Config",false))
local saveRow=Instance.new("TextButton"); saveRow.Size=UDim2.new(1,0,0,32); saveRow.BackgroundColor3=PURPLE_DARK
saveRow.BorderSizePixel=0; saveRow.Text="💾  Save Config"; saveRow.TextColor3=PURPLE
saveRow.TextSize=12; saveRow.Font=Enum.Font.GothamSemibold; saveRow.Visible=false
LO+=1; saveRow.LayoutOrder=LO; saveRow.Parent=LeftScroll
Instance.new("UICorner",saveRow).CornerRadius=UDim.new(0,6)
saveRow.MouseButton1Click:Connect(function() saveConfig(); saveRow.Text="✔  Saved!"; saveRow.TextColor3=GREEN
    task.delay(1.5,function() saveRow.Text="💾  Save Config"; saveRow.TextColor3=PURPLE end) end)
table.insert(tConfig.leftItems,saveRow)
local loadRow=Instance.new("TextButton"); loadRow.Size=UDim2.new(1,0,0,32); loadRow.BackgroundColor3=PURPLE_DARK
loadRow.BorderSizePixel=0; loadRow.Text="📂  Load Config"; loadRow.TextColor3=PURPLE
loadRow.TextSize=12; loadRow.Font=Enum.Font.GothamSemibold; loadRow.Visible=false
LO+=1; loadRow.LayoutOrder=LO; loadRow.Parent=LeftScroll
Instance.new("UICorner",loadRow).CornerRadius=UDim.new(0,6)
loadRow.MouseButton1Click:Connect(function() loadConfig(); loadRow.Text="✔  Loaded!"; loadRow.TextColor3=GREEN
    task.delay(1.5,function() loadRow.Text="📂  Load Config"; loadRow.TextColor3=PURPLE end) end)
table.insert(tConfig.leftItems,loadRow)
addL(tConfig, TL("File: venom_config.json",false))
addL(tConfig, TL("Auto-saves on GUI close",false))
addR(tConfig, SL("Status",true))
addR(tConfig, TL("venom.lol v2.0",true))
addR(tConfig, TL("Drawing: "..(hasDrawing and "✔" or "✘"),true))
addR(tConfig, TL("MouseMoveRel: "..(hasMoveRel and "✔" or "✘"),true))
addR(tConfig, TL("HookMeta: "..(hasHookMeta and "✔" or "✘"),true))
addR(tConfig, TL("Mouse1Click: "..(hasMouse1Click and "✔" or "✘"),true))

-- ══════════════════════════════════════════
--  INPUT HANDLING
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end

    -- GUI toggle
    if inp.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible; return end

    -- Full map toggle [M]
    if inp.KeyCode==Enum.KeyCode.M then
        state.fullMapOpen=not state.fullMapOpen
        FullMapFrame.Visible=state.fullMapOpen
        return
    end

    -- Aimbot key (RMB)
    local aimMatch=(inp.UserInputType==Enum.UserInputType.MouseButton2)
        or (typeof(Configuration.AimKey)=="EnumItem" and inp.KeyCode==Configuration.AimKey)
    if Configuration.Aimbot and aimMatch then
        if Configuration.OnePressAimingMode then
            if Aiming then ResetAimbotFields() else Aiming=true end
        else Aiming=true end
    end

    -- SpinBot hold key (Spin is toggled via tab)
    -- TriggerBot hold key
end)

UserInputService.InputEnded:Connect(function(inp)
    local aimMatch=(inp.UserInputType==Enum.UserInputType.MouseButton2)
        or (typeof(Configuration.AimKey)=="EnumItem" and inp.KeyCode==Configuration.AimKey)
    if Aiming and not Configuration.OnePressAimingMode and aimMatch then
        ResetAimbotFields()
    end
end)

-- ══════════════════════════════════════════
--  RUNTIME LOOPS
-- ══════════════════════════════════════════

-- Fly
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

-- Noclip
RunService.Stepped:Connect(function()
    if not state.noclip then return end
    local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump then return end
    local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Bunny hop
RunService.Heartbeat:Connect(function()
    if not state.bunnyhop then return end
    local hum=getHum(); if not hum then return end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Speed / God / Jump / Sprint
RunService.Heartbeat:Connect(function()
    local hum=getHum(); if not hum then return end
    if state.godMode then hum.Health=hum.MaxHealth end
    if state.speedBoost then hum.WalkSpeed=80
    elseif state.autoSprint then hum.WalkSpeed=state.sprintSpeed
    else hum.WalkSpeed=state.walkSpeed end
    hum.JumpPower=state.jumpPower
end)

-- Anti-AFK
Player.Idled:Connect(function()
    if not state.antiAfk then return end
    VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
    task.wait(0.1); VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
end)

-- ══════════════════════════════════════════
--  OPEN AIMBOT + SPINBOT + TRIGGERBOT LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    -- SpinBot
    if Configuration.SpinBot and Configuration.SpinPart and Player.Character then
        local part=Player.Character:FindFirstChild(Configuration.SpinPart)
        if part and part:IsA("BasePart") then
            part.CFrame=part.CFrame*CFrame.fromEulerAnglesXYZ(0,math.rad(Configuration.SpinBotVelocity),0)
        end
    end

    -- TriggerBot
    if hasMouse1Click and Configuration.TriggerBot and (not Configuration.SmartTriggerBot or Aiming) then
        local tgt=Mouse.Target
        if tgt and IsReady(tgt:FindFirstAncestorWhichIsA("Model")) and MathHandler:CalculateChance(Configuration.TriggerBotChance) then
            getfenv().mouse1click()
        end
    end

    -- Aimbot
    if not Configuration.Aimbot and Aiming then ResetAimbotFields(); return end
    if not Aiming then return end

    if not IsReady(Target) then
        if Target and Configuration.OffAimbotAfterKill then ResetAimbotFields(); return end
        Target=nil; local closest=math.huge
        for _,plr in Players:GetPlayers() do
            local ok,Char,vp=IsReady(plr.Character)
            if ok and vp[2] then
                local dist=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(vp[1].X,vp[1].Y)).Magnitude
                if dist<closest and dist<=(Configuration.FoVCheck and Configuration.FoVRadius or dist) then
                    Target=Char; closest=dist end
            end
        end
    end

    local ok,_,vp,WorldPos=IsReady(Target)
    if not ok or not vp[2] then ResetAimbotFields(true); return end

    -- FIX: use player head as camera origin so camera follows player
    local myChar=Player.Character
    local myHead=myChar and myChar:FindFirstChild("Head")
    local myHRP =myChar and myChar:FindFirstChild("HumanoidRootPart")
    local origin=myHead and (myHead.Position+Vector3.new(0,0.5,0))
                 or myHRP and myHRP.Position
                 or workspace.CurrentCamera.CFrame.Position

    if hasMoveRel and Configuration.AimMode=="Mouse" then
        ResetAimbotFields(true,true)
        local ml=UserInputService:GetMouseLocation()
        local sens=Configuration.UseSensitivity and Configuration.Sensitivity/5 or 10
        getfenv().mousemoverel((vp[1].X-ml.X)/sens,(vp[1].Y-ml.Y)/sens)
    elseif Configuration.AimMode=="Camera" then
        UserInputService.MouseDeltaSensitivity=0
        if Configuration.UseSensitivity then
            AimTween=TweenService:Create(workspace.CurrentCamera,
                TweenInfo.new(math.clamp(Configuration.Sensitivity,9,99)/100,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
                {CFrame=CFrame.new(origin,WorldPos)})
            AimTween:Play()
        else
            local alpha=1-(1-0.25)^(dt*60)
            local goalCF=CFrame.lookAt(origin,WorldPos)
            local lerpedRot=workspace.CurrentCamera.CFrame:Lerp(goalCF,alpha).Rotation
            workspace.CurrentCamera.CFrame=CFrame.new(origin)*lerpedRot
        end
    elseif Configuration.AimMode=="Silent" then
        ResetAimbotFields(true,true)
    end
end)

-- ══════════════════════════════════════════
--  ESP LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    for plr in espDrawings do if not plr or not plr.Parent then cleanupESPForPlayer(plr) end end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        if not state.esp then if espDrawings[plr] then hideDrawings(espDrawings[plr]) end; continue end
        updateESPForPlayer(plr)
    end
end)

-- ══════════════════════════════════════════
--  MINIMAP LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    MinimapFrame.Visible=state.minimapEnabled; mapLayer.Visible=state.showGameMap
    if not state.minimapEnabled then return end
    local selfHRP=getHRP(); if not selfHRP then return end
    local selfPos=selfHRP.Position
    local cam=workspace.CurrentCamera; local _,camY,_=cam.CFrame:ToEulerAnglesYXZ()
    if mapScanned then
        local nx=(selfPos.X-mapMinX)/math.max(mapMaxX-mapMinX,1)
        local nz=(selfPos.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1)
        mapLayer.Position=UDim2.new(0,(0.5-nx)*MINIMAP_SIZE,0,(0.5-nz)*MINIMAP_SIZE)
    end
    local targetPlr=Target and Players:GetPlayerFromCharacter(Target)
    local dotIdx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1; local dot=getMMDot(dotIdx); dot.Visible=true
        local dn=dot:FindFirstChildOfClass("TextLabel"); if dn then dn.Text=plr.Name end
        local offset=hrp.Position-selfPos
        local rx=offset.X*math.cos(camY)+offset.Z*math.sin(camY)
        local rz=-offset.X*math.sin(camY)+offset.Z*math.cos(camY)
        local px=math.clamp(rx/state.minimapRange,-1,1)*(MINIMAP_SIZE/2)
        local py=math.clamp(rz/state.minimapRange,-1,1)*(MINIMAP_SIZE/2)
        dot.Position=UDim2.new(0.5,px,0.5,py)
        if plr==targetPlr then dot.BackgroundColor3=GOLD
        else local ok1,mt=pcall(function() return Player.Team end); local ok2,pt=pcall(function() return plr.Team end)
            dot.BackgroundColor3=(ok1 and ok2 and mt and pt and mt==pt) and GREEN or RED end
    end
    for i=dotIdx+1,#mmDots do mmDots[i].Visible=false end
end)

-- ══════════════════════════════════════════
--  FULL MAP LOOP  (when open)
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.fullMapOpen then return end
    if not mapScanned then return end
    local selfHRP=getHRP()
    if selfHRP then
        local nx=(selfHRP.Position.X-mapMinX)/math.max(mapMaxX-mapMinX,1)
        local nz=(selfHRP.Position.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1)
        fmSelf.Position=UDim2.new(math.clamp(nx,0,1),0,math.clamp(nz,0,1),0)
    end
    local targetPlr=Target and Players:GetPlayerFromCharacter(Target)
    local dotIdx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1; local dot=getFmDot(dotIdx); dot.Visible=true
        local nl=dot:FindFirstChildOfClass("TextLabel"); if nl then nl.Text=plr.Name end
        local nx=math.clamp((hrp.Position.X-mapMinX)/math.max(mapMaxX-mapMinX,1),0,1)
        local nz=math.clamp((hrp.Position.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1),0,1)
        dot.Position=UDim2.new(nx,0,nz,0)
        if plr==targetPlr then dot.BackgroundColor3=GOLD
        else local ok1,mt=pcall(function() return Player.Team end); local ok2,pt=pcall(function() return plr.Team end)
            dot.BackgroundColor3=(ok1 and ok2 and mt and pt and mt==pt) and GREEN or RED end
    end
    for i=dotIdx+1,#fmEnemyDots do fmEnemyDots[i].Visible=false end
end)

-- ══════════════════════════════════════════
--  PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr) cleanupESPForPlayer(plr) end)

Player.CharacterAdded:Connect(function()
    state.flyEnabled=false; bv=nil; bg=nil
    ResetAimbotFields()
    workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
    if state.thirdPerson then task.wait(1); setThirdPerson(true) end
end)

game:BindToClose(function() saveConfig(); cleanupAllESP()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end end)

-- ══════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════
activateTab(tAimbot)
rebuildCrosshair()

print("[Venom v2.0] Loaded ✓  |  Engine: Open Aimbot (ttwiz_z)")
print("RShift=GUI | RMB=Aim | M=Full Map | Drawing:"..tostring(hasDrawing))
