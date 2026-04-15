-- ══════════════════════════════════════════════════════════════════
--  blueblur  v4.0  |  ULTIMATE EDITION
--  Full aimbot · Combat · Teleport · World ESP · All Features
--  RShift=GUI | RMB=Aim | M=Full Map | B=BunnyHop | Click=TP
-- ══════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")

local Player     = Players.LocalPlayer
local PlayerGui  = Player:WaitForChild("PlayerGui")
local Mouse      = Player:GetMouse()
local Camera     = workspace.CurrentCamera

-- ══════════════════════════════════════════
--  WHITELIST CHECK
-- ══════════════════════════════════════════
local NGROK_URL = "https://subventionary-letha-boughten.ngrok-free.dev"
local function CheckWhitelist()
    local response
    if getfenv().request then
        local ok,res=pcall(function()
            return request({
                Url    = NGROK_URL.."/check?rbxid="..tostring(Player.UserId),
                Method = "GET",
                Headers= {["ngrok-skip-browser-warning"]="true"},
            })
        end)
        if ok and res and res.Body then response=res.Body end
    end
    if not response then
        local ok,res=pcall(function()
            return game:HttpGet(NGROK_URL.."/check?rbxid="..tostring(Player.UserId),true)
        end)
        if ok then response=res else warn("[BlueBlur] WL fail:",res); return false end
    end
    response=tostring(response):match("^%s*(.-)%s*$")
    return response=="valid"
end

-- ══════════════════════════════════════════
--  SPLASH SCREEN  (animated)
-- ══════════════════════════════════════════
local SplashGui=Instance.new("ScreenGui")
SplashGui.Name="VenomSplash"; SplashGui.ResetOnSpawn=false
SplashGui.IgnoreGuiInset=true; SplashGui.DisplayOrder=999; SplashGui.Parent=PlayerGui

local SplashBG=Instance.new("Frame"); SplashBG.Size=UDim2.new(1,0,1,0)
SplashBG.BackgroundColor3=Color3.fromRGB(4,4,12); SplashBG.BorderSizePixel=0; SplashBG.Parent=SplashGui

-- Scanline overlay effect
for i=1,40 do
    local sl=Instance.new("Frame"); sl.Size=UDim2.new(1,0,0,1)
    sl.Position=UDim2.new(0,0,0,i*15); sl.BackgroundColor3=Color3.fromRGB(30, 100, 255)
    sl.BackgroundTransparency=0.95; sl.BorderSizePixel=0; sl.Parent=SplashBG
end

local SplashCard=Instance.new("Frame"); SplashCard.Size=UDim2.new(0,340,0,180)
SplashCard.AnchorPoint=Vector2.new(0.5,0.5); SplashCard.Position=UDim2.new(0.5,0,0.7,0)
SplashCard.BackgroundColor3=Color3.fromRGB(6,6,18); SplashCard.BackgroundTransparency=0
SplashCard.BorderSizePixel=0; SplashCard.Parent=SplashBG
Instance.new("UICorner",SplashCard).CornerRadius=UDim.new(0,14)
local cardStroke=Instance.new("UIStroke",SplashCard)
cardStroke.Color=Color3.fromRGB(30, 100, 255); cardStroke.Thickness=2

-- Glow frame behind card
local GlowBehind=Instance.new("ImageLabel"); GlowBehind.Size=UDim2.new(0,500,0,300)
GlowBehind.AnchorPoint=Vector2.new(0.5,0.5); GlowBehind.Position=UDim2.new(0.5,0,0.5,0)
GlowBehind.BackgroundTransparency=1
GlowBehind.Image="rbxasset://textures/ui/LuaApp/icons/ic-back.png"
GlowBehind.ImageColor3=Color3.fromRGB(30, 100, 255); GlowBehind.ImageTransparency=0.85; GlowBehind.Parent=SplashCard

local SplashTitle=Instance.new("TextLabel"); SplashTitle.Size=UDim2.new(1,0,0,40)
SplashTitle.Position=UDim2.new(0,0,0,18); SplashTitle.BackgroundTransparency=1
SplashTitle.Text="blueblur"; SplashTitle.TextColor3=Color3.fromRGB(80, 150, 255)
SplashTitle.TextSize=28; SplashTitle.Font=Enum.Font.GothamBlack; SplashTitle.Parent=SplashCard

local SplashVer=Instance.new("TextLabel"); SplashVer.Size=UDim2.new(1,0,0,16)
SplashVer.Position=UDim2.new(0,0,0,50); SplashVer.BackgroundTransparency=1
SplashVer.Text="v4.0  —  ULTIMATE EDITION"; SplashVer.TextColor3=Color3.fromRGB(60, 80, 120)
SplashVer.TextSize=11; SplashVer.Font=Enum.Font.GothamSemibold; SplashVer.Parent=SplashCard

local SplashSub=Instance.new("TextLabel"); SplashSub.Size=UDim2.new(1,-20,0,18)
SplashSub.Position=UDim2.new(0,10,0,80); SplashSub.BackgroundTransparency=1
SplashSub.Text="Verifying whitelist..."; SplashSub.TextColor3=Color3.fromRGB(90, 110, 150)
SplashSub.TextSize=12; SplashSub.Font=Enum.Font.Gotham; SplashSub.Parent=SplashCard

local SplashBarBG=Instance.new("Frame"); SplashBarBG.Size=UDim2.new(1,-24,0,5)
SplashBarBG.Position=UDim2.new(0,12,1,-22); SplashBarBG.BackgroundColor3=Color3.fromRGB(15, 25, 55)
SplashBarBG.BorderSizePixel=0; SplashBarBG.Parent=SplashCard
Instance.new("UICorner",SplashBarBG).CornerRadius=UDim.new(1,0)

local SplashBar=Instance.new("Frame"); SplashBar.Size=UDim2.new(0,0,1,0)
SplashBar.BackgroundColor3=Color3.fromRGB(30, 100, 255); SplashBar.BorderSizePixel=0; SplashBar.Parent=SplashBarBG
Instance.new("UICorner",SplashBar).CornerRadius=UDim.new(1,0)

-- Animate in
TweenService:Create(SplashCard,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Position=UDim2.new(0.5,0,0.5,0)}):Play()
TweenService:Create(SplashBar,TweenInfo.new(1.4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),
    {Size=UDim2.new(0.88,0,1,0)}):Play()

-- Pulsing stroke
task.spawn(function()
    while SplashGui.Parent do
        TweenService:Create(cardStroke,TweenInfo.new(1),{Thickness=3,Color=Color3.fromRGB(60, 130, 255)}):Play()
        task.wait(1)
        TweenService:Create(cardStroke,TweenInfo.new(1),{Thickness=1.5,Color=Color3.fromRGB(20, 60, 180)}):Play()
        task.wait(1)
    end
end)

local granted=CheckWhitelist()

if not granted then
    SplashSub.Text="❌  Not whitelisted."; SplashSub.TextColor3=Color3.fromRGB(220,80,80)
    cardStroke.Color=Color3.fromRGB(220,50,50)
    TweenService:Create(SplashBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(200,50,50)}):Play()
    task.wait(3); TweenService:Create(SplashBG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
    task.wait(0.4); SplashGui:Destroy(); return
end

SplashSub.Text="✅  Access granted!"; SplashSub.TextColor3=Color3.fromRGB(80,220,120)
TweenService:Create(SplashBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(60,220,90)}):Play()
task.wait(1)
TweenService:Create(SplashBG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
task.wait(0.4); SplashGui:Destroy()

-- ══════════════════════════════════════════
--  CAPABILITY FLAGS
-- ══════════════════════════════════════════
local hasDrawing     = false
pcall(function() local t=Drawing.new("Square"); t:Remove(); hasDrawing=true end)
local hasMoveRel     = not not getfenv().mousemoverel
local hasHookMeta    = not not (getfenv().hookmetamethod and getfenv().newcclosure
                                and getfenv().checkcaller and getfenv().getnamecallmethod)
local hasMouse1Click = not not getfenv().mouse1click

-- ══════════════════════════════════════════
--  THEME - BLUE/DARK BLUE/BLACK
-- ══════════════════════════════════════════
local C = {
    BLUE        = Color3.fromRGB(30, 100, 255),
    BLUE_MID    = Color3.fromRGB(20, 70, 200),
    BLUE_DIM    = Color3.fromRGB(15, 40, 130),
    BLUE_DARK   = Color3.fromRGB(8, 15, 55),
    BG          = Color3.fromRGB(5, 5, 12),
    BG2         = Color3.fromRGB(10, 10, 20),
    BG3         = Color3.fromRGB(16, 18, 32),
    BG4         = Color3.fromRGB(22, 24, 40),
    TEXT        = Color3.fromRGB(225, 230, 255),
    SUBTEXT     = Color3.fromRGB(100, 110, 150),
    RED         = Color3.fromRGB(220, 60, 60),
    GREEN       = Color3.fromRGB(60, 220, 90),
    GOLD        = Color3.fromRGB(255, 200, 40),
    CYAN        = Color3.fromRGB(60, 180, 255),
    WHITE       = Color3.fromRGB(255, 255, 255),
}
local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local TWEEN_MED   = TweenInfo.new(0.25, Enum.EasingStyle.Quad)
local CONFIG_FILE = "blueblur_config_v4.json"

-- ══════════════════════════════════════════
--  AIMBOT STATE
-- ══════════════════════════════════════════
local Aim = {
    enabled=false, mode="Camera", aimPart="Head",
    keyMode="Hold", key="RMB",
    fovEnabled=false, fovRadius=150, showFov=false,
    smoothEnabled=false, smoothAmount=0.25,
    predictEnabled=false, predictAmount=0.08,
    silentChance=100,
    spinEnabled=false, spinSpeed=50, spinPart="HumanoidRootPart",
    triggerEnabled=false, triggerChance=100, triggerSmartOnly=false,
    checkAlive=true, checkTeam=false, checkFriend=false,
    checkWall=false, checkGod=false, maxDist=1000,
}
local aimActive=false; local aimTarget=nil
local savedSens=UserInputService.MouseDeltaSensitivity
local aimToggleState=false; local onePressConsumed=false

-- ══════════════════════════════════════════
--  NON-AIMBOT STATE
-- ══════════════════════════════════════════
local state = {
    esp=false, espBoxes=true, espNames=true, espHealth=true,
    espTracers=false, espDistance=true, espChams=false,
    fullbright=false, noFog=false, noShadows=false,
    flyEnabled=false, noclip=false, infiniteJump=false,
    speedBoost=false, walkSpeed=16, jumpPower=50,
    godMode=false, antiAfk=false, invisible=false,
    bunnyhop=false, autoSprint=false, sprintSpeed=28,
    thirdPerson=false, tpDistance=8,
    crosshair=false, crosshairStyle="Plus", crosshairSize=10,
    hitboxExpander=false, hitboxSize=6,
    fakelag=false, fakelagAmount=3,
    autoRejoin=false,
    minimapEnabled=true, minimapRange=300,
    fullMapOpen=false,
    -- COMBAT FEATURES
    silentTeleport=false, silentTpDistance=50,
    antiLock=false, antiAimAngle=180,
    reachEnabled=false, reachAmount=20,
    -- UTILITY FEATURES
    clickTp=false, teleportToPlayer="None",
    serverHop=false, copyCoords=false,
    antiVoid=false, voidHeight=-50,
    antiStomp=false, antiRagdoll=false,
    -- VISUAL FEATURES
    worldEsp=false, worldEspChests=false, worldEspItems=false,
    worldEspDoors=false, worldEspObjectives=false,
    speedOverlay=false,
    playerList=false, killFeed=false,
    sessionInfo=false,
    -- QOL FEATURES
    streamerMode=false,
    matchAutoAccept=false, matchAutoQueue=false,
    autoEquip=false,
    -- SOUND VISUALIZER (Fortnite-style)
    soundViz=false, soundVizRange=100,
    soundVizFootsteps=true, soundVizGunfire=true,
    soundVizVehicles=true, soundVizExplosions=true,
    soundVizDoors=true, soundVizVoice=true,
    soundVizEnemiesOnly=false,
    -- WORLD ESP OBJECTS CACHE
    worldEspObjects={},
}
local bv,bg
local tracerThickness=1
local MINIMAP_SIZE=200
local MAP_CELLS=64
local mapMinX,mapMaxX,mapMinZ,mapMaxZ=math.huge,-math.huge,math.huge,-math.huge
local mapGrid={}; local mapScanned=false
local mapColorGrid={}  -- stores Color3 per cell from part colors

-- ══════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════
local function saveConfig()
    local d={}
    for k,v in state do local t=type(v); if t=="boolean" or t=="number" or t=="string" then d[k]=v end end
    d["_aim_mode"]=Aim.mode; d["_aim_part"]=Aim.aimPart; d["_aim_keymode"]=Aim.keyMode
    d["_aim_fov"]=Aim.fovRadius; d["_aim_smooth"]=Aim.smoothAmount
    d["_aim_predict"]=Aim.predictAmount; d["_aim_maxdist"]=Aim.maxDist
    pcall(function() writefile(CONFIG_FILE,HttpService:JSONEncode(d)) end)
end
local function loadConfig()
    local ok,raw=pcall(readfile,CONFIG_FILE); if not ok or not raw then return end
    local ok2,d=pcall(HttpService.JSONDecode,HttpService,raw); if not ok2 or type(d)~="table" then return end
    for k,v in d do if state[k]~=nil then state[k]=v end end
    if d["_aim_mode"]    then Aim.mode=d["_aim_mode"] end
    if d["_aim_part"]    then Aim.aimPart=d["_aim_part"] end
    if d["_aim_keymode"] then Aim.keyMode=d["_aim_keymode"] end
    if d["_aim_fov"]     then Aim.fovRadius=d["_aim_fov"] end
    if d["_aim_smooth"]  then Aim.smoothAmount=d["_aim_smooth"] end
    if d["_aim_predict"] then Aim.predictAmount=d["_aim_predict"] end
    if d["_aim_maxdist"] then Aim.maxDist=d["_aim_maxdist"] end
end
loadConfig()

-- ══════════════════════════════════════════
--  COLOR-SCAN MAP  (samples real part colors)
-- ══════════════════════════════════════════
local function scanMap()
    mapMinX,mapMaxX,mapMinZ,mapMaxZ=math.huge,-math.huge,math.huge,-math.huge
    local parts={}
    for _,obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Player.Character or game) then
            local p=obj.Position
            if p.X<mapMinX then mapMinX=p.X end; if p.X>mapMaxX then mapMaxX=p.X end
            if p.Z<mapMinZ then mapMinZ=p.Z end; if p.Z>mapMaxZ then mapMaxZ=p.Z end
            table.insert(parts,obj)
        end
    end
    if mapMinX==math.huge then mapMinX,mapMaxX,mapMinZ,mapMaxZ=-500,500,-500,500 end
    local px=(mapMaxX-mapMinX)*0.05; local pz=(mapMaxZ-mapMinZ)*0.05
    mapMinX-=px; mapMaxX+=px; mapMinZ-=pz; mapMaxZ+=pz
    local cx=(mapMaxX-mapMinX)/MAP_CELLS; local cz=(mapMaxZ-mapMinZ)/MAP_CELLS
    -- accumulate color per cell
    local colorAccR={}; local colorAccG={}; local colorAccB={}; local colorCount={}
    local heightAcc={}
    for r=1,MAP_CELLS do
        colorAccR[r]={}; colorAccG[r]={}; colorAccB[r]={}; colorCount[r]={}; heightAcc[r]={}
        for c=1,MAP_CELLS do colorAccR[r][c]=0; colorAccG[r][c]=0; colorAccB[r][c]=0; colorCount[r][c]=0; heightAcc[r][c]=0 end
    end
    for _,obj in parts do
        local p=obj.Position
        local col=math.clamp(math.floor((p.X-mapMinX)/cx)+1,1,MAP_CELLS)
        local row=math.clamp(math.floor((p.Z-mapMinZ)/cz)+1,1,MAP_CELLS)
        colorAccR[row][col]+=obj.Color.R
        colorAccG[row][col]+=obj.Color.G
        colorAccB[row][col]+=obj.Color.B
        colorCount[row][col]+=1
        if p.Y>heightAcc[row][col] then heightAcc[row][col]=p.Y end
    end
    for r=1,MAP_CELLS do
        mapGrid[r]={}; mapColorGrid[r]={}
        for c=1,MAP_CELLS do
            local cnt=colorCount[r][c]
            if cnt>0 then
                -- blend real part color with a darkened/map-tinted version
                local rr=colorAccR[r][c]/cnt
                local gg=colorAccG[r][c]/cnt
                local bb=colorAccB[r][c]/cnt
                -- darken for minimap aesthetic, add slight blue tint
                mapGrid[r][c]=cnt
                mapColorGrid[r][c]=Color3.new(
                    math.clamp(rr*0.55+0.05, 0, 1),
                    math.clamp(gg*0.50+0.05, 0, 1),
                    math.clamp(bb*0.60+0.10, 0, 1)
                )
            else
                mapGrid[r][c]=0
                mapColorGrid[r][c]=Color3.fromRGB(6, 6, 18)
            end
        end
    end
    mapScanned=true
end
task.spawn(scanMap)

-- ══════════════════════════════════════════
--  AIMBOT HELPERS
-- ══════════════════════════════════════════
local function getHum()  local c=Player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP()  local c=Player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHead() local c=Player.Character; return c and c:FindFirstChild("Head") end
local function mousePos() return UserInputService:GetMouseLocation() end
local function chance(pct) return math.random(1,100)<=pct end

local function isValidTarget(char)
    if not char or not char.Parent then return false end
    local plr=Players:GetPlayerFromCharacter(char)
    if not plr or plr==Player then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
    local myPart=Player.Character and (Player.Character:FindFirstChild(Aim.aimPart) or Player.Character:FindFirstChild("HumanoidRootPart"))
    if not hum or not part or not myPart then return false end
    if Aim.checkAlive and hum.Health<=0 then return false end
    if Aim.checkGod and (hum.Health>=1e36 or char:FindFirstChildOfClass("ForceField")) then return false end
    if Aim.checkTeam and plr.TeamColor==Player.TeamColor then return false end
    if Aim.checkFriend and plr:IsFriendsWith(Player.UserId) then return false end
    if Aim.maxDist>0 and (part.Position-myPart.Position).Magnitude>Aim.maxDist then return false end
    if Aim.fovEnabled then
        local sp,vis=Camera:WorldToViewportPoint(part.Position)
        if not vis then return false end
        if (Vector2.new(sp.X,sp.Y)-mousePos()).Magnitude>Aim.fovRadius then return false end
    end
    if Aim.checkWall then
        local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances={Player.Character}
        local dir=part.Position-myPart.Position
        local res=workspace:Raycast(myPart.Position,dir,rp)
        if not res or not res.Instance or not res.Instance:IsDescendantOf(char) then return false end
    end
    return true
end

local function findTarget()
    local best,bestDist=nil,math.huge
    local mp=mousePos()
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character
        if not isValidTarget(char) then continue end
        local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
        local sp,vis=Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
        if d<bestDist then bestDist=d; best=char end
    end
    return best
end

local function getAimPos(char)
    local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
    if not part then return nil end
    local pos=part.Position
    if Aim.predictEnabled then
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then pos=pos+hrp.AssemblyLinearVelocity*Aim.predictAmount end
    end
    return pos
end

local function applyAim(char)
    local worldPos=getAimPos(char); if not worldPos then return end
    local origin=Camera.CFrame.Position
    if Aim.mode=="Camera" then
        UserInputService.MouseDeltaSensitivity=0
        local goalCF=CFrame.lookAt(origin,worldPos)
        if Aim.smoothEnabled then Camera.CFrame=Camera.CFrame:Lerp(goalCF,math.clamp(Aim.smoothAmount,0.01,1))
        else Camera.CFrame=goalCF end
    elseif Aim.mode=="Mouse" and hasMoveRel then
        local sp,vis=Camera:WorldToViewportPoint(worldPos); if not vis then return end
        local mp=mousePos(); local dx=sp.X-mp.X; local dy=sp.Y-mp.Y
        local sens=Aim.smoothEnabled and math.max(1,(1-Aim.smoothAmount)*20) or 1
        getfenv().mousemoverel(dx/sens,dy/sens)
    end
end

local function installSilentAimHooks()
    if not hasHookMeta then return end
    local function getSilentTarget()
        if not aimActive or Aim.mode~="Silent" then return nil end
        local char=aimTarget or findTarget()
        if not isValidTarget(char) then return nil end
        if not chance(Aim.silentChance) then return nil end
        return char
    end
    local oldIndex; oldIndex=getfenv().hookmetamethod(game,"__index",getfenv().newcclosure(function(self,key)
        if self==Mouse and not getfenv().checkcaller() then
            local char=getSilentTarget()
            if char then
                local wp=getAimPos(char)
                if wp then
                    local sp=Camera:WorldToViewportPoint(wp)
                    if key=="Hit" or key=="hit" then
                        local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
                        return CFrame.new(wp)*(part and CFrame.fromEulerAnglesYXZ(math.rad(part.Orientation.X),math.rad(part.Orientation.Y),math.rad(part.Orientation.Z)) or CFrame.identity)
                    elseif key=="Target" or key=="target" then return char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
                    elseif key=="X" or key=="x" then return sp.X
                    elseif key=="Y" or key=="y" then return sp.Y end
                end
            end
        end
        return oldIndex(self,key)
    end))
    local oldNC; oldNC=getfenv().hookmetamethod(game,"__namecall",getfenv().newcclosure(function(...)
        local method=getfenv().getnamecallmethod(); local args={...}; local self=args[1]
        if not getfenv().checkcaller() then
            local char=getSilentTarget()
            if char then
                local wp=getAimPos(char)
                if wp then
                    local sp=Camera:WorldToViewportPoint(wp)
                    if self==UserInputService and (method=="GetMouseLocation" or method=="getMouseLocation") then
                        return Vector2.new(sp.X,sp.Y)
                    elseif self==workspace and (method=="Raycast" or method=="raycast")
                       and typeof(args[2])=="Vector3" and typeof(args[3])=="Vector3" then
                        args[3]=(wp-args[2]).Unit*(wp-args[2]).Magnitude
                        return oldNC(table.unpack(args))
                    end
                end
            end
        end
        return oldNC(...)
    end))
end
pcall(installSilentAimHooks)

UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not aimActive then savedSens=UserInputService.MouseDeltaSensitivity end
end)

-- Main aimbot + spinbot + triggerbot loop
RunService.RenderStepped:Connect(function()
    if aimTarget and not isValidTarget(aimTarget) then aimTarget=nil end
    if aimActive then
        if not aimTarget then aimTarget=findTarget() end
        if aimTarget then applyAim(aimTarget) end
    else
        if UserInputService.MouseDeltaSensitivity==0 then UserInputService.MouseDeltaSensitivity=savedSens end
    end
    if Aim.spinEnabled and Player.Character then
        local sp=Player.Character:FindFirstChild(Aim.spinPart)
        if sp and sp:IsA("BasePart") then sp.CFrame=sp.CFrame*CFrame.fromEulerAnglesXYZ(0,math.rad(Aim.spinSpeed),0) end
    end
    if hasMouse1Click and Aim.triggerEnabled then
        if not Aim.triggerSmartOnly or aimActive then
            local tgt=Mouse.Target
            if tgt then
                local char=tgt:FindFirstAncestorWhichIsA("Model")
                if isValidTarget(char) and chance(Aim.triggerChance) then getfenv().mouse1click() end
            end
        end
    end
end)

local function aimKeyDown()
    if Aim.keyMode=="Hold" then aimActive=true
    elseif Aim.keyMode=="Toggle" then
        aimToggleState=not aimToggleState; aimActive=aimToggleState
        if not aimActive then aimTarget=nil end
    elseif Aim.keyMode=="OnePress" then
        if not onePressConsumed then
            onePressConsumed=true
            local char=findTarget()
            if char then
                local wp=getAimPos(char)
                if wp then Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,wp) end
            end
        end
    end
end
local function aimKeyUp()
    if Aim.keyMode=="Hold" then aimActive=false; aimTarget=nil; UserInputService.MouseDeltaSensitivity=savedSens end
    if Aim.keyMode=="OnePress" then onePressConsumed=false end
end

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui=Instance.new("ScreenGui"); ScreenGui.Name="VenomGUI"
ScreenGui.ResetOnSpawn=false; ScreenGui.IgnoreGuiInset=true
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ScreenGui.Parent=PlayerGui

-- ══════════════════════════════════════════
--  COLOR-SCAN MINIMAP  (Fortnite-style) - FIXED: ABOVE RADAR
-- ══════════════════════════════════════════
local MinimapFrame=Instance.new("Frame")
MinimapFrame.Size=UDim2.new(0,MINIMAP_SIZE,0,MINIMAP_SIZE)
-- FIXED: Position minimap ABOVE the radar (moved up by 12 pixels more)
MinimapFrame.Position=UDim2.new(1,-(MINIMAP_SIZE+12),1,-(MINIMAP_SIZE+24)) -- Moved 12px higher
MinimapFrame.BackgroundColor3=Color3.fromRGB(4, 4, 14); MinimapFrame.BorderSizePixel=0
MinimapFrame.ZIndex=5; MinimapFrame.Visible=state.minimapEnabled; MinimapFrame.Parent=ScreenGui
Instance.new("UICorner",MinimapFrame).CornerRadius=UDim.new(1,0)

local mmOuter=Instance.new("UIStroke",MinimapFrame)
mmOuter.Color=Color3.fromRGB(30, 100, 255); mmOuter.Thickness=2.5

-- Pulsing border animation
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(mmOuter,TweenInfo.new(1.5),{Thickness=3.5,Color=Color3.fromRGB(60, 130, 255)}):Play()
        task.wait(1.5)
        TweenService:Create(mmOuter,TweenInfo.new(1.5),{Thickness=1.8,Color=Color3.fromRGB(20, 60, 200)}):Play()
        task.wait(1.5)
    end
end)

local mmClip=Instance.new("Frame"); mmClip.Size=UDim2.new(1,-4,1,-4)
mmClip.Position=UDim2.new(0,2,0,2); mmClip.BackgroundTransparency=1
mmClip.ClipsDescendants=true; mmClip.ZIndex=5; mmClip.Parent=MinimapFrame
Instance.new("UICorner",mmClip).CornerRadius=UDim.new(1,0)

-- Map tile layer (color-scanned)
local mapLayer=Instance.new("Frame"); mapLayer.Size=UDim2.new(1,0,1,0)
mapLayer.BackgroundTransparency=1; mapLayer.ZIndex=5; mapLayer.Parent=mmClip

local tilePx=MINIMAP_SIZE/MAP_CELLS; local mapTiles={}
for r=1,MAP_CELLS do mapTiles[r]={}
    for c=1,MAP_CELLS do
        local t=Instance.new("Frame")
        t.Size=UDim2.new(0,math.ceil(tilePx)+1,0,math.ceil(tilePx)+1)
        t.Position=UDim2.new(0,(c-1)*tilePx,0,(r-1)*tilePx)
        t.BackgroundColor3=Color3.fromRGB(6, 6, 18); t.BorderSizePixel=0; t.ZIndex=5; t.Parent=mapLayer
        mapTiles[r][c]=t
    end
end

local function applyColorMapToTiles(tiles,tileCount,targetGrid)
    if not mapScanned then return end
    local scale=MAP_CELLS/tileCount
    for r=1,tileCount do for c=1,tileCount do
        local sr=math.clamp(math.round((r-0.5)*scale),1,MAP_CELLS)
        local sc=math.clamp(math.round((c-0.5)*scale),1,MAP_CELLS)
        local col=targetGrid[sr] and targetGrid[sr][sc]
        if tiles[r] and tiles[r][c] and col then
            tiles[r][c].BackgroundColor3=col
        end
    end end
end

task.spawn(function()
    while not mapScanned do task.wait(0.2) end
    applyColorMapToTiles(mapTiles,MAP_CELLS,mapColorGrid)
end)

-- Compass rings
for _,pct in {0.3,0.6,0.9} do
    local rs=(MINIMAP_SIZE-8)*pct; local ring=Instance.new("Frame")
    ring.Size=UDim2.new(0,rs,0,rs); ring.Position=UDim2.new(0.5,-rs/2,0.5,-rs/2)
    ring.BackgroundTransparency=1; ring.BorderSizePixel=0; ring.ZIndex=6; ring.Parent=mmClip
    local st=Instance.new("UIStroke",ring); st.Color=Color3.fromRGB(40, 70, 180); st.Thickness=0.6; st.Transparency=0.6
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
end

-- Crosshair lines
for _,vert in {true,false} do
    local l=Instance.new("Frame"); l.BackgroundColor3=Color3.fromRGB(30, 70, 140)
    l.BorderSizePixel=0; l.ZIndex=6; l.BackgroundTransparency=0.4; l.Parent=mmClip
    if vert then l.Size=UDim2.new(0,1,1,0); l.Position=UDim2.new(0.5,0,0,0)
    else l.Size=UDim2.new(1,0,0,1); l.Position=UDim2.new(0,0,0.5,0) end
end

-- Radar layer (enemy dots)
local radarLayer=Instance.new("Frame"); radarLayer.Size=UDim2.new(1,0,1,0)
radarLayer.BackgroundTransparency=1; radarLayer.ZIndex=7; radarLayer.Parent=mmClip

-- Self dot (white with glow stroke)
local mmSelf=Instance.new("Frame"); mmSelf.Size=UDim2.new(0,10,0,10)
mmSelf.AnchorPoint=Vector2.new(0.5,0.5); mmSelf.Position=UDim2.new(0.5,0,0.5,0)
mmSelf.BackgroundColor3=Color3.fromRGB(255,255,255); mmSelf.BorderSizePixel=0; mmSelf.ZIndex=10; mmSelf.Parent=radarLayer
Instance.new("UICorner",mmSelf).CornerRadius=UDim.new(1,0)
local mmSelfStroke=Instance.new("UIStroke",mmSelf); mmSelfStroke.Color=Color3.fromRGB(150, 180, 255); mmSelfStroke.Thickness=2

-- Compass labels
for label,pos in {N=UDim2.new(0.5,0,0,3),S=UDim2.new(0.5,0,1,-13),W=UDim2.new(0,3,0.5,-6),E=UDim2.new(1,-13,0.5,-6)} do
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0,11,0,11); l.Position=pos
    l.BackgroundTransparency=1; l.Text=label; l.TextColor3=Color3.fromRGB(140, 170, 255)
    l.TextSize=8; l.Font=Enum.Font.GothamBlack; l.ZIndex=11; l.Parent=mmClip
end

-- Minimap label bar at bottom
local mmBar=Instance.new("Frame"); mmBar.Size=UDim2.new(1,0,0,18)
mmBar.Position=UDim2.new(0,0,1,4); mmBar.BackgroundTransparency=1; mmBar.ZIndex=5; mmBar.Parent=MinimapFrame
local mmLabel=Instance.new("TextLabel"); mmLabel.Size=UDim2.new(1,0,1,0)
mmLabel.BackgroundTransparency=1; mmLabel.Text="▣ RADAR  ·  "..state.minimapRange.."st  ·  [M] MAP"
mmLabel.TextColor3=Color3.fromRGB(60, 90, 150); mmLabel.TextSize=8; mmLabel.Font=Enum.Font.GothamSemibold; mmLabel.ZIndex=5; mmLabel.Parent=mmBar

-- Rescan button (overlay, top-left of minimap)
local mmRescanBtn=Instance.new("TextButton"); mmRescanBtn.Size=UDim2.new(0,56,0,14)
mmRescanBtn.Position=UDim2.new(0,4,0,4); mmRescanBtn.BackgroundColor3=Color3.fromRGB(10, 15, 40)
mmRescanBtn.BackgroundTransparency=0.3; mmRescanBtn.BorderSizePixel=0
mmRescanBtn.Text="↺ RESCAN"; mmRescanBtn.TextColor3=Color3.fromRGB(80, 130, 255)
mmRescanBtn.TextSize=7; mmRescanBtn.Font=Enum.Font.GothamSemibold; mmRescanBtn.ZIndex=12; mmRescanBtn.Parent=mmClip
Instance.new("UICorner",mmRescanBtn).CornerRadius=UDim.new(0,3)
mmRescanBtn.MouseButton1Click:Connect(function()
    mmRescanBtn.Text="scanning…"
    task.spawn(function()
        scanMap()
        applyColorMapToTiles(mapTiles,MAP_CELLS,mapColorGrid)
        if state.fullMapOpen then applyColorMapToTiles(fullMapTiles,FULLMAP_CELLS,mapColorGrid) end
        mmRescanBtn.Text="↺ RESCAN"
    end)
end)

local mmDots={}
local function getMMDot(i)
    if mmDots[i] then return mmDots[i] end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,8,0,8); dot.AnchorPoint=Vector2.new(0.5,0.5)
    dot.BackgroundColor3=C.RED; dot.BorderSizePixel=0; dot.ZIndex=9; dot.Visible=false; dot.Parent=radarLayer
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local ds=Instance.new("UIStroke",dot); ds.Color=Color3.fromRGB(255,100,100); ds.Thickness=1.2
    local dn=Instance.new("TextLabel"); dn.Size=UDim2.new(0,55,0,11)
    dn.AnchorPoint=Vector2.new(0.5,1); dn.Position=UDim2.new(0.5,0,0,-2)
    dn.BackgroundTransparency=1; dn.TextColor3=C.TEXT; dn.TextSize=7
    dn.Font=Enum.Font.GothamBold; dn.ZIndex=10; dn.Parent=dot
    mmDots[i]={dot=dot,stroke=ds,label=dn}; return mmDots[i]
end

-- ══════════════════════════════════════════
--  FULL MAP  (Fortnite-style, press M)
-- ══════════════════════════════════════════
local FULLMAP_CELLS=80; local FULLMAP_SIZE=520; local fullMapTiles={}

local FullMapFrame=Instance.new("Frame")
FullMapFrame.Size=UDim2.new(0,FULLMAP_SIZE+24,0,FULLMAP_SIZE+70)
FullMapFrame.AnchorPoint=Vector2.new(0.5,0.5); FullMapFrame.Position=UDim2.new(0.5,0,0.5,0)
FullMapFrame.BackgroundColor3=Color3.fromRGB(5, 5, 16); FullMapFrame.BorderSizePixel=0
FullMapFrame.ZIndex=50; FullMapFrame.Visible=false; FullMapFrame.Parent=ScreenGui
Instance.new("UICorner",FullMapFrame).CornerRadius=UDim.new(0,14)
local fmStroke=Instance.new("UIStroke",FullMapFrame); fmStroke.Color=C.BLUE; fmStroke.Thickness=2.5

-- Animate stroke
task.spawn(function()
    while ScreenGui.Parent do
        if state.fullMapOpen then
            TweenService:Create(fmStroke,TweenInfo.new(1.2),{Thickness=4,Color=Color3.fromRGB(60, 140, 255)}):Play()
            task.wait(1.2)
            TweenService:Create(fmStroke,TweenInfo.new(1.2),{Thickness=2,Color=Color3.fromRGB(25, 70, 200)}):Play()
            task.wait(1.2)
        else task.wait(0.5) end
    end
end)

local fmHeader=Instance.new("Frame"); fmHeader.Size=UDim2.new(1,0,0,44)
fmHeader.BackgroundColor3=Color3.fromRGB(8, 8, 22); fmHeader.BorderSizePixel=0; fmHeader.ZIndex=51; fmHeader.Parent=FullMapFrame
Instance.new("UICorner",fmHeader).CornerRadius=UDim.new(0,14)
local fmFix=Instance.new("Frame"); fmFix.Size=UDim2.new(1,0,0,14); fmFix.Position=UDim2.new(0,0,1,-14)
fmFix.BackgroundColor3=Color3.fromRGB(8, 8, 22); fmFix.BorderSizePixel=0; fmFix.ZIndex=51; fmFix.Parent=fmHeader
local fmTitle=Instance.new("TextLabel"); fmTitle.Size=UDim2.new(1,-50,1,0)
fmTitle.Position=UDim2.new(0,16,0,0); fmTitle.BackgroundTransparency=1
fmTitle.Text="🗺  blueblur  v4.0  —  FULL MAP  [M to close]"; fmTitle.TextColor3=C.BLUE
fmTitle.TextSize=15; fmTitle.Font=Enum.Font.GothamBlack; fmTitle.TextXAlignment=Enum.TextXAlignment.Left; fmTitle.ZIndex=52; fmTitle.Parent=fmHeader
local fmClose=Instance.new("TextButton"); fmClose.Size=UDim2.new(0,26,0,26); fmClose.Position=UDim2.new(1,-34,0.5,-13)
fmClose.BackgroundColor3=Color3.fromRGB(50,15,22); fmClose.Text="✕"; fmClose.TextColor3=C.RED
fmClose.TextSize=12; fmClose.Font=Enum.Font.GothamBold; fmClose.BorderSizePixel=0; fmClose.ZIndex=52; fmClose.Parent=fmHeader
Instance.new("UICorner",fmClose).CornerRadius=UDim.new(0,5)
fmClose.MouseButton1Click:Connect(function() state.fullMapOpen=false; FullMapFrame.Visible=false end)

local fmArea=Instance.new("Frame"); fmArea.Size=UDim2.new(0,FULLMAP_SIZE,0,FULLMAP_SIZE)
fmArea.Position=UDim2.new(0,12,0,50); fmArea.BackgroundColor3=Color3.fromRGB(8, 8, 22)
fmArea.BorderSizePixel=0; fmArea.ZIndex=51; fmArea.ClipsDescendants=true; fmArea.Parent=FullMapFrame
Instance.new("UICorner",fmArea).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",fmArea).Color=C.BLUE_DIM

local fmTilePx=FULLMAP_SIZE/FULLMAP_CELLS
for r=1,FULLMAP_CELLS do fullMapTiles[r]={}
    for c=1,FULLMAP_CELLS do
        local t=Instance.new("Frame")
        t.Size=UDim2.new(0,math.ceil(fmTilePx)+1,0,math.ceil(fmTilePx)+1)
        t.Position=UDim2.new(0,(c-1)*fmTilePx,0,(r-1)*fmTilePx)
        t.BackgroundColor3=Color3.fromRGB(8, 8, 22); t.BorderSizePixel=0; t.ZIndex=52; t.Parent=fmArea
        fullMapTiles[r][c]=t
    end
end
task.spawn(function() while not mapScanned do task.wait(0.2) end; applyColorMapToTiles(fullMapTiles,FULLMAP_CELLS,mapColorGrid) end)

-- Grid lines on full map
for i=1,5 do
    local p=i/6
    local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,1); h.Position=UDim2.new(0,0,p,0)
    h.BackgroundColor3=Color3.fromRGB(30, 45, 90); h.BorderSizePixel=0; h.ZIndex=53; h.Parent=fmArea
    local v=Instance.new("Frame"); v.Size=UDim2.new(0,1,1,0); v.Position=UDim2.new(p,0,0,0)
    v.BackgroundColor3=Color3.fromRGB(30, 45, 90); v.BorderSizePixel=0; v.ZIndex=53; v.Parent=fmArea
end

-- Compass labels on full map
for label,pos in {N=UDim2.new(0.5,0,0,6),S=UDim2.new(0.5,0,1,-18),W=UDim2.new(0,6,0.5,-8),E=UDim2.new(1,-18,0.5,-8)} do
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(0,16,0,16); l.Position=pos
    l.BackgroundTransparency=1; l.Text=label; l.TextColor3=Color3.fromRGB(150, 180, 255)
    l.TextSize=11; l.Font=Enum.Font.GothamBlack; l.ZIndex=58; l.Parent=fmArea
end

-- Self dot on full map
local fmSelf=Instance.new("Frame"); fmSelf.Size=UDim2.new(0,12,0,12)
fmSelf.AnchorPoint=Vector2.new(0.5,0.5); fmSelf.BackgroundColor3=Color3.fromRGB(80, 180, 255)
fmSelf.BorderSizePixel=0; fmSelf.ZIndex=59; fmSelf.Parent=fmArea
Instance.new("UICorner",fmSelf).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",fmSelf).Color=Color3.fromRGB(255,255,255)

-- Heading arrow on full map self dot
local fmArrow=Instance.new("Frame"); fmArrow.Size=UDim2.new(0,2,0,10)
fmArrow.AnchorPoint=Vector2.new(0.5,1); fmArrow.Position=UDim2.new(0.5,0,0,0)
fmArrow.BackgroundColor3=C.CYAN; fmArrow.BorderSizePixel=0; fmArrow.ZIndex=60; fmArrow.Parent=fmSelf

local fmEnemyDots={}
local function getFmDot(i)
    if fmEnemyDots[i] then return fmEnemyDots[i] end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,10,0,10); dot.AnchorPoint=Vector2.new(0.5,0.5)
    dot.BackgroundColor3=C.RED; dot.BorderSizePixel=0; dot.ZIndex=57; dot.Visible=false; dot.Parent=fmArea
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",dot).Color=Color3.fromRGB(255,120,120)
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(0,65,0,13)
    nl.AnchorPoint=Vector2.new(0.5,1); nl.Position=UDim2.new(0.5,0,0,-2)
    nl.BackgroundTransparency=1; nl.TextColor3=C.TEXT; nl.TextSize=9; nl.Font=Enum.Font.GothamBold; nl.ZIndex=58; nl.Parent=dot
    fmEnemyDots[i]={dot=dot,label=nl}; return fmEnemyDots[i]
end

local fmFooter=Instance.new("TextLabel"); fmFooter.Size=UDim2.new(1,0,0,22)
fmFooter.Position=UDim2.new(0,0,1,-22); fmFooter.BackgroundTransparency=1
fmFooter.Text="🔵 You   🔴 Enemy   🟡 Aimbot Target   🟢 Teammate"
fmFooter.TextColor3=C.SUBTEXT; fmFooter.TextSize=10; fmFooter.Font=Enum.Font.GothamSemibold
fmFooter.ZIndex=52; fmFooter.Parent=FullMapFrame

local fmRescanBtn=Instance.new("TextButton"); fmRescanBtn.Size=UDim2.new(0,130,0,26)
fmRescanBtn.AnchorPoint=Vector2.new(1,0); fmRescanBtn.Position=UDim2.new(1,-12,0,52)
fmRescanBtn.BackgroundColor3=C.BLUE_DARK; fmRescanBtn.BorderSizePixel=0
fmRescanBtn.Text="↺ Rescan Map"; fmRescanBtn.TextColor3=C.BLUE; fmRescanBtn.TextSize=11
fmRescanBtn.Font=Enum.Font.GothamSemibold; fmRescanBtn.ZIndex=55; fmRescanBtn.Parent=FullMapFrame
Instance.new("UICorner",fmRescanBtn).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",fmRescanBtn).Color=C.BLUE_DIM
fmRescanBtn.MouseButton1Click:Connect(function()
    fmRescanBtn.Text="Scanning…"
    task.spawn(function()
        scanMap()
        applyColorMapToTiles(mapTiles,MAP_CELLS,mapColorGrid)
        applyColorMapToTiles(fullMapTiles,FULLMAP_CELLS,mapColorGrid)
        fmRescanBtn.Text="↺ Rescan Map"
    end)
end)

-- ══════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════
local FovCircle=Instance.new("Frame"); FovCircle.BackgroundTransparency=1; FovCircle.BorderSizePixel=0
FovCircle.ZIndex=10; FovCircle.Visible=false; FovCircle.Parent=ScreenGui
Instance.new("UICorner",FovCircle).CornerRadius=UDim.new(1,0)
local FovStroke=Instance.new("UIStroke"); FovStroke.Color=C.BLUE; FovStroke.Thickness=2; FovStroke.Transparency=0.25; FovStroke.Parent=FovCircle

RunService.RenderStepped:Connect(function()
    FovCircle.Visible=Aim.showFov and Aim.fovEnabled
    if not FovCircle.Visible then return end
    local r=Aim.fovRadius; local ml=mousePos()
    FovCircle.Size=UDim2.new(0,r*2,0,r*2); FovCircle.Position=UDim2.new(0,ml.X-r,0,ml.Y-r)
end)

-- ══════════════════════════════════════════
--  CUSTOM CROSSHAIR
-- ══════════════════════════════════════════
local crosshairDrawings={}
local function rebuildCrosshair()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end; crosshairDrawings={}
    if not state.crosshair or not hasDrawing then return end
    local s=state.crosshairSize
    if state.crosshairStyle=="Plus" then
        for _,def in {{Vector2.new(-s,0),Vector2.new(s,0)},{Vector2.new(0,-s),Vector2.new(0,s)}} do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]; l.Color=C.BLUE; l.Thickness=1.5; l.Transparency=1; l.Visible=true; table.insert(crosshairDrawings,l) end
    elseif state.crosshairStyle=="Dot" then
        local c=Drawing.new("Circle"); c.Radius=3; c.Color=C.BLUE; c.Filled=true; c.Transparency=1; c.Visible=true; table.insert(crosshairDrawings,c)
    elseif state.crosshairStyle=="X" then
        for _,def in {{Vector2.new(-s,-s),Vector2.new(s,s)},{Vector2.new(s,-s),Vector2.new(-s,s)}} do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]; l.Color=C.BLUE; l.Thickness=1.5; l.Transparency=1; l.Visible=true; table.insert(crosshairDrawings,l) end
    end
end

RunService.RenderStepped:Connect(function()
    if not state.crosshair or not hasDrawing or #crosshairDrawings==0 then return end
    local vp=Camera.ViewportSize; local cx,cy=vp.X/2,vp.Y/2; local s=state.crosshairSize
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
    d.box=newDraw("Square",{Visible=false,Color=C.BLUE,Thickness=1,Filled=false,Transparency=1})
    d.nameText=newDraw("Text",{Visible=false,Color=C.BLUE,Size=13,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    d.healthBg=newDraw("Square",{Visible=false,Color=Color3.fromRGB(20,20,20),Filled=true,Transparency=0.5,Thickness=1})
    d.healthFill=newDraw("Square",{Visible=false,Color=C.GREEN,Filled=true,Transparency=1,Thickness=1})
    d.tracer=newDraw("Line",{Visible=false,Color=C.BLUE,Thickness=tracerThickness,Transparency=1})
    d.distLabel=newDraw("Text",{Visible=false,Color=C.SUBTEXT,Size=11,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    espDrawings[plr]=d; return d
end
local function updateESPForPlayer(plr)
    local d=getOrCreateESP(plr); if not d then return end
    local char=plr.Character; if not char then hideDrawings(d); return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); local head=char:FindFirstChild("Head"); local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideDrawings(d); return end
    local topSP=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,head.Size.Y/2+0.1,0))
    local botSP=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,hrp.Size.Y/2+0.3,0))
    local hrpSP,hrpVis=Camera:WorldToViewportPoint(hrp.Position)
    if not hrpVis then hideDrawings(d); return end
    local boxH=math.abs(botSP.Y-topSP.Y); local boxW=boxH*0.55
    local boxX=hrpSP.X-boxW/2; local boxY=topSP.Y
    local isTarget=(char==aimTarget)
    local col=isTarget and C.GOLD or C.BLUE
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    local hpCol=Color3.fromRGB(math.round(255*(1-pct)),math.round(200*pct),0)
    local myHead=getHead()
    local dist=myHead and math.round((head.Position-myHead.Position).Magnitude) or 0
    if d.box then d.box.Visible=state.esp and state.espBoxes
        if d.box.Visible then d.box.Position=Vector2.new(boxX,boxY); d.box.Size=Vector2.new(boxW,boxH); d.box.Color=col; d.box.Thickness=isTarget and 2 or 1 end end
    if d.nameText then d.nameText.Visible=state.esp and state.espNames
        if d.nameText.Visible then d.nameText.Text=plr.DisplayName..(isTarget and " ◀" or ""); d.nameText.Position=Vector2.new(hrpSP.X,topSP.Y-16); d.nameText.Color=col end end
    local barW,barX=4,boxX-7
    if d.healthBg then d.healthBg.Visible=state.esp and state.espHealth
        if d.healthBg.Visible then d.healthBg.Position=Vector2.new(barX,boxY); d.healthBg.Size=Vector2.new(barW,boxH) end end
    if d.healthFill then local fH=boxH*pct; d.healthFill.Visible=state.esp and state.espHealth
        if d.healthFill.Visible then d.healthFill.Position=Vector2.new(barX,boxY+boxH-fH); d.healthFill.Size=Vector2.new(barW,fH); d.healthFill.Color=hpCol end end
    if d.tracer then local vp=Camera.ViewportSize; d.tracer.Visible=state.esp and state.espTracers
        if d.tracer.Visible then d.tracer.From=Vector2.new(vp.X/2,vp.Y); d.tracer.To=Vector2.new(hrpSP.X,botSP.Y); d.tracer.Color=col; d.tracer.Thickness=isTarget and tracerThickness+1 or tracerThickness end end
    if d.distLabel then d.distLabel.Visible=state.esp and state.espDistance
        if d.distLabel.Visible then d.distLabel.Text=tostring(dist).."m"; d.distLabel.Position=Vector2.new(hrpSP.X,botSP.Y+2); d.distLabel.Color=isTarget and C.GOLD or C.SUBTEXT end end
    if state.esp and state.espChams then
        for _,p in char:GetDescendants() do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Material=Enum.Material.Neon; p.Color=isTarget and C.GOLD or C.BLUE_MID end
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
        head.Size=on and Vector3.new(state.hitboxSize,state.hitboxSize,state.hitboxSize) or Vector3.new(2,1,1)
    end
end
Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(function(char)
    task.wait(1)
    if state.hitboxExpander then local h=char:FindFirstChild("Head"); if h then h.Size=Vector3.new(state.hitboxSize,state.hitboxSize,state.hitboxSize) end end
end) end)

-- ══════════════════════════════════════════
--  OTHER FEATURES
-- ══════════════════════════════════════════
local fakeLagConn=nil
local function setFakeLag(on)
    if fakeLagConn then fakeLagConn:Disconnect(); fakeLagConn=nil end
    if on then fakeLagConn=RunService.Heartbeat:Connect(function()
        if not state.fakelag then return end
        local hrp=getHRP(); if not hrp then return end
        local origin=hrp.CFrame
        for i=1,state.fakelagAmount do hrp.CFrame=origin*CFrame.new(math.random(-1,1)*0.5,0,math.random(-1,1)*0.5) end
        hrp.CFrame=origin
    end) end
end

local origMaxZoom=400
local function setThirdPerson(on)
    if on then origMaxZoom=Player.CameraMaxZoomDistance; Player.CameraMaxZoomDistance=state.tpDistance; Player.CameraMinZoomDistance=state.tpDistance
    else Player.CameraMaxZoomDistance=origMaxZoom; Player.CameraMinZoomDistance=0.5 end
end

local function setupAutoRejoin()
    Player.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid",10); if not hum then return end
        hum.Died:Connect(function() if state.autoRejoin then task.wait(3); pcall(function() TeleportService:Teleport(game.PlaceId,Player) end) end end)
    end)
end
setupAutoRejoin()

-- ══════════════════════════════════════════
--  MAIN WINDOW  (Reign-style layout) - BLUE THEME
-- ══════════════════════════════════════════
local WIN_W,WIN_H=880,540
local Win=Instance.new("Frame"); Win.Name="BlueBlurWin"
Win.Size=UDim2.new(0,WIN_W,0,WIN_H)
Win.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
Win.BackgroundColor3=C.BG; Win.BorderSizePixel=0; Win.Active=true; Win.Parent=ScreenGui
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,10)
local winStroke=Instance.new("UIStroke",Win); winStroke.Color=C.BLUE; winStroke.Thickness=2

-- Animated glow on main window
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(winStroke,TweenInfo.new(2),{Thickness=3.5,Color=Color3.fromRGB(60, 120, 255)}):Play()
        task.wait(2)
        TweenService:Create(winStroke,TweenInfo.new(2),{Thickness=1.5,Color=Color3.fromRGB(15, 50, 160)}):Play()
        task.wait(2)
    end
end)

-- Top accent stripe
local TopAccent=Instance.new("Frame"); TopAccent.Size=UDim2.new(1,0,0,3); TopAccent.BackgroundColor3=C.BLUE
TopAccent.BorderSizePixel=0; TopAccent.ZIndex=3; TopAccent.Parent=Win
Instance.new("UICorner",TopAccent).CornerRadius=UDim.new(0,10)

-- Title bar
local TitleBar=Instance.new("Frame"); TitleBar.Size=UDim2.new(1,0,0,42); TitleBar.BackgroundColor3=C.BG2
TitleBar.BorderSizePixel=0; TitleBar.Active=true; TitleBar.ZIndex=2; TitleBar.Parent=Win
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,10)
local TFix=Instance.new("Frame"); TFix.Size=UDim2.new(1,0,0,14); TFix.Position=UDim2.new(0,0,1,-14)
TFix.BackgroundColor3=C.BG2; TFix.BorderSizePixel=0; TFix.ZIndex=2; TFix.Parent=TitleBar
Instance.new("UIStroke",TitleBar).Color=C.BLUE_DARK

-- Logo
local Logo=Instance.new("TextLabel"); Logo.Size=UDim2.new(0,110,1,0); Logo.Position=UDim2.new(0,14,0,0)
Logo.BackgroundTransparency=1; Logo.Text="blueblur"; Logo.TextColor3=C.BLUE
Logo.TextSize=17; Logo.Font=Enum.Font.GothamBlack; Logo.TextXAlignment=Enum.TextXAlignment.Left; Logo.ZIndex=3; Logo.Parent=TitleBar

local LogoSub=Instance.new("TextLabel"); LogoSub.Size=UDim2.new(0,40,1,0); LogoSub.Position=UDim2.new(0,116,0,0)
LogoSub.BackgroundTransparency=1; LogoSub.Text="v4.0"; LogoSub.TextColor3=C.SUBTEXT
LogoSub.TextSize=10; LogoSub.Font=Enum.Font.GothamSemibold; LogoSub.TextXAlignment=Enum.TextXAlignment.Left; LogoSub.ZIndex=3; LogoSub.Parent=TitleBar

-- Status indicator (animated dot)
local StatusDot=Instance.new("Frame"); StatusDot.Size=UDim2.new(0,8,0,8)
StatusDot.Position=UDim2.new(0,158,0.5,-4); StatusDot.BackgroundColor3=C.GREEN; StatusDot.BorderSizePixel=0; StatusDot.ZIndex=3; StatusDot.Parent=TitleBar
Instance.new("UICorner",StatusDot).CornerRadius=UDim.new(1,0)
local StatusLbl=Instance.new("TextLabel"); StatusLbl.Size=UDim2.new(0,80,1,0); StatusLbl.Position=UDim2.new(0,170,0,0)
StatusLbl.BackgroundTransparency=1; StatusLbl.Text="ACTIVE"; StatusLbl.TextColor3=C.GREEN
StatusLbl.TextSize=10; StatusLbl.Font=Enum.Font.GothamSemibold; StatusLbl.TextXAlignment=Enum.TextXAlignment.Left; StatusLbl.ZIndex=3; StatusLbl.Parent=TitleBar
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(StatusDot,TweenInfo.new(0.8),{BackgroundTransparency=0.8}):Play(); task.wait(0.8)
        TweenService:Create(StatusDot,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play(); task.wait(0.8)
    end
end)

-- Close + minimize
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,24,0,24); CloseBtn.Position=UDim2.new(1,-28,0.5,-12)
CloseBtn.BackgroundColor3=Color3.fromRGB(55,15,22); CloseBtn.Text="✕"; CloseBtn.TextColor3=C.RED
CloseBtn.TextSize=11; CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.BorderSizePixel=0; CloseBtn.ZIndex=5; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,4)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Win,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.32); saveConfig(); cleanupAllESP()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end; ScreenGui:Destroy()
end)

local MinBtn=Instance.new("TextButton"); MinBtn.Size=UDim2.new(0,24,0,24); MinBtn.Position=UDim2.new(1,-56,0.5,-12)
MinBtn.BackgroundColor3=C.BLUE_DARK; MinBtn.Text="─"; MinBtn.TextColor3=C.BLUE
MinBtn.TextSize=11; MinBtn.Font=Enum.Font.GothamBold; MinBtn.BorderSizePixel=0; MinBtn.ZIndex=5; MinBtn.Parent=TitleBar
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,4)

local minimised=false
MinBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    if minimised then
        TweenService:Create(Win,TWEEN_MED,{Size=UDim2.new(0,WIN_W,0,42)}):Play()
    else
        TweenService:Create(Win,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,WIN_W,0,WIN_H)}):Play()
    end
end)

-- Tab bar (in title bar, Reign-style)
local TabBarFrame=Instance.new("Frame"); TabBarFrame.Size=UDim2.new(1,-340,1,0); TabBarFrame.Position=UDim2.new(0,250,0,0)
TabBarFrame.BackgroundTransparency=1; TabBarFrame.ZIndex=3; TabBarFrame.Parent=TitleBar
local TabBarLayout=Instance.new("UIListLayout"); TabBarLayout.FillDirection=Enum.FillDirection.Horizontal
TabBarLayout.SortOrder=Enum.SortOrder.LayoutOrder; TabBarLayout.Padding=UDim.new(0,2)
TabBarLayout.VerticalAlignment=Enum.VerticalAlignment.Center; TabBarLayout.Parent=TabBarFrame

-- Drag
local dragging,dragStart,startPos=false,nil,nil
TitleBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=i.Position; startPos=Win.Position end end)
TitleBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart; Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end)

-- Body
local Body=Instance.new("Frame"); Body.Size=UDim2.new(1,0,1,-42); Body.Position=UDim2.new(0,0,0,42)
Body.BackgroundTransparency=1; Body.Parent=Win

-- Left sidebar (280px wide)
local LeftPanel=Instance.new("Frame"); LeftPanel.Size=UDim2.new(0,280,1,0)
LeftPanel.BackgroundColor3=C.BG2; LeftPanel.BorderSizePixel=0; LeftPanel.Parent=Body
local LeftStroke=Instance.new("UIStroke",LeftPanel); LeftStroke.Color=C.BLUE_DARK; LeftStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local LeftScroll=Instance.new("ScrollingFrame"); LeftScroll.Size=UDim2.new(1,-16,1,-6); LeftScroll.Position=UDim2.new(0,8,0,3)
LeftScroll.BackgroundTransparency=1; LeftScroll.BorderSizePixel=0; LeftScroll.ScrollBarThickness=2
LeftScroll.ScrollBarImageColor3=C.BLUE; LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
LeftScroll.CanvasSize=UDim2.new(0,0,0,0); LeftScroll.Parent=LeftPanel
local LL=Instance.new("UIListLayout"); LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.Padding=UDim.new(0,2); LL.Parent=LeftScroll
local LP=Instance.new("UIPadding"); LP.PaddingLeft=UDim.new(0,8); LP.PaddingRight=UDim.new(0,8)
LP.PaddingTop=UDim.new(0,8); LP.PaddingBottom=UDim.new(0,8); LP.Parent=LeftScroll

-- Divider line
local Divider=Instance.new("Frame"); Divider.Size=UDim2.new(0,1,1,0); Divider.Position=UDim2.new(0,280,0,0)
Divider.BackgroundColor3=C.BLUE_DARK; Divider.BackgroundTransparency=0.5; Divider.BorderSizePixel=0; Divider.Parent=Body

-- Right panel (fills remaining space)
local RightPanel=Instance.new("Frame"); RightPanel.Size=UDim2.new(1,-282,1,0); RightPanel.Position=UDim2.new(0,282,0,0)
RightPanel.BackgroundColor3=C.BG; RightPanel.BorderSizePixel=0; RightPanel.Parent=Body

local RightScroll=Instance.new("ScrollingFrame"); RightScroll.Size=UDim2.new(1,-16,1,-6); RightScroll.Position=UDim2.new(0,8,0,3)
RightScroll.BackgroundTransparency=1; RightScroll.BorderSizePixel=0; RightScroll.ScrollBarThickness=2
RightScroll.ScrollBarImageColor3=C.BLUE; RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
RightScroll.CanvasSize=UDim2.new(0,0,0,0); RightScroll.Parent=RightPanel
local RL=Instance.new("UIListLayout"); RL.SortOrder=Enum.SortOrder.LayoutOrder; RL.Padding=UDim.new(0,2); RL.Parent=RightScroll
local RP=Instance.new("UIPadding"); RP.PaddingLeft=UDim.new(0,8); RP.PaddingRight=UDim.new(0,8)
RP.PaddingTop=UDim.new(0,8); RP.PaddingBottom=UDim.new(0,8); RP.Parent=RightScroll

-- ══════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════
local tabs={}
local function makeTabBtn(name,order)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,78,0,28); btn.BackgroundColor3=C.BG3
    btn.BorderSizePixel=0; btn.Text=name; btn.TextColor3=C.SUBTEXT; btn.TextSize=10
    btn.Font=Enum.Font.GothamSemibold; btn.LayoutOrder=order; btn.ZIndex=4; btn.Parent=TabBarFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    local ul=Instance.new("Frame"); ul.Size=UDim2.new(0.8,0,0,2); ul.Position=UDim2.new(0.1,0,1,-2)
    ul.BackgroundColor3=C.BLUE; ul.BorderSizePixel=0; ul.Visible=false; ul.ZIndex=5; ul.Parent=btn
    Instance.new("UICorner",ul).CornerRadius=UDim.new(1,0)
    local td={btn=btn,underline=ul,leftItems={},rightItems={}}; table.insert(tabs,td)
    btn.MouseButton1Click:Connect(function()
        for _,t in tabs do
            t.btn.TextColor3=C.SUBTEXT; t.btn.BackgroundColor3=C.BG3; t.underline.Visible=false
            for _,i in t.leftItems do i.Visible=false end; for _,i in t.rightItems do i.Visible=false end
        end
        TweenService:Create(btn,TWEEN_FAST,{BackgroundColor3=C.BLUE_DARK}):Play()
        btn.TextColor3=C.BLUE; ul.Visible=true
        for _,i in td.leftItems do i.Visible=true end; for _,i in td.rightItems do i.Visible=true end
    end); return td
end
local function activateTab(td)
    for _,t in tabs do
        t.btn.TextColor3=C.SUBTEXT; t.btn.BackgroundColor3=C.BG3; t.underline.Visible=false
        for _,i in t.leftItems do i.Visible=false end; for _,i in t.rightItems do i.Visible=false end
    end
    td.btn.TextColor3=C.BLUE; td.btn.BackgroundColor3=C.BLUE_DARK; td.underline.Visible=true
    for _,i in td.leftItems do i.Visible=true end; for _,i in td.rightItems do i.Visible=true end
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS  (Reign-style) - BLUE
-- ══════════════════════════════════════════
local LO,RO=0,0

-- Section label with glow line
local function SL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1;f.LayoutOrder=RO;f.Parent=RightScroll else LO+=1;f.LayoutOrder=LO;f.Parent=LeftScroll end
    local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,0,0,20); bg.Position=UDim2.new(0,0,0,4)
    bg.BackgroundColor3=C.BLUE_DARK; bg.BackgroundTransparency=0.3; bg.BorderSizePixel=0; bg.Parent=f
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,4)
    local ln=Instance.new("Frame"); ln.Size=UDim2.new(0,3,0,14); ln.Position=UDim2.new(0,0,0.5,-7)
    ln.BackgroundColor3=C.BLUE; ln.BorderSizePixel=0; ln.Parent=bg
    Instance.new("UICorner",ln).CornerRadius=UDim.new(1,0)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-8,1,0); lb.Position=UDim2.new(0,8,0,0)
    lb.BackgroundTransparency=1; lb.Text=text:upper(); lb.TextColor3=C.BLUE
    lb.TextSize=10; lb.Font=Enum.Font.GothamBlack; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=bg
    return f
end

-- Toggle row (Reign-style checkbox with keybind)
local function TG(name,kb,def,cb,isR)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,28); row.BackgroundColor3=C.BG3
    row.BackgroundTransparency=0.4; row.BorderSizePixel=0; row.Visible=false
    if isR then RO+=1;row.LayoutOrder=RO;row.Parent=RightScroll else LO+=1;row.LayoutOrder=LO;row.Parent=LeftScroll end
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,5)
    local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=def and C.BLUE_DIM or Color3.fromRGB(20, 25, 50); rowStroke.Thickness=1

    local chk=Instance.new("Frame"); chk.Size=UDim2.new(0,14,0,14); chk.Position=UDim2.new(0,8,0.5,-7)
    chk.BackgroundColor3=def and C.BLUE or Color3.fromRGB(20, 25, 50); chk.BorderSizePixel=0; chk.Parent=row
    Instance.new("UICorner",chk).CornerRadius=UDim.new(0,3)
    local chkStroke=Instance.new("UIStroke",chk); chkStroke.Color=def and C.BLUE or Color3.fromRGB(40, 60, 120); chkStroke.Thickness=1

    local tick=Instance.new("TextLabel"); tick.Size=UDim2.new(1,0,1,0); tick.BackgroundTransparency=1; tick.AnchorPoint=Vector2.new(0.5,0.5); tick.Position=UDim2.new(0.5,0.5,0.5,0)
    tick.Text="✓"; tick.TextColor3=C.WHITE; tick.TextSize=8; tick.Font=Enum.Font.GothamBold
    tick.Visible=def; tick.Parent=chk

    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,30,0,0)
    lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=def and C.TEXT or C.SUBTEXT
    lb.TextSize=11; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row

    if kb and kb~="" then
        local kl=Instance.new("TextLabel"); kl.Size=UDim2.new(0,40,0,16); kl.Position=UDim2.new(1,-46,0.5,-8)
        kl.BackgroundColor3=C.BLUE_DARK; kl.BackgroundTransparency=0.2; kl.BorderSizePixel=0
        kl.Text=kb; kl.TextColor3=C.BLUE; kl.TextSize=8; kl.Font=Enum.Font.GothamBold
        kl.TextXAlignment=Enum.TextXAlignment.Center; kl.Parent=row
        Instance.new("UICorner",kl).CornerRadius=UDim.new(0,3)
    end

    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=2; btn.Parent=row
    local st=def
    local function setState(v)
        st=v; tick.Visible=v
        TweenService:Create(chk,TWEEN_FAST,{BackgroundColor3=st and C.BLUE or Color3.fromRGB(20, 25, 50)}):Play()
        TweenService:Create(chkStroke,TWEEN_FAST,{Color=st and C.BLUE or Color3.fromRGB(40, 60, 120)}):Play()
        TweenService:Create(rowStroke,TWEEN_FAST,{Color=st and C.BLUE_DIM or Color3.fromRGB(20, 25, 50)}):Play()
        lb.TextColor3=st and C.TEXT or C.SUBTEXT
        if cb then cb(st) end
    end
    btn.MouseButton1Click:Connect(function() setState(not st) end)
    btn.MouseEnter:Connect(function() TweenService:Create(row,TWEEN_FAST,{BackgroundTransparency=0.2}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(row,TWEEN_FAST,{BackgroundTransparency=0.4}):Play() end)
    return row,setState
end

-- Slider (Reign-style horizontal bar)
local function SLD(name,mn,mx,def,sfx,cb,isR)
    sfx=sfx or ""
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,52); card.BackgroundColor3=C.BG3
    card.BackgroundTransparency=0.4; card.BorderSizePixel=0; card.Visible=false
    if isR then RO+=1;card.LayoutOrder=RO;card.Parent=RightScroll else LO+=1;card.LayoutOrder=LO;card.Parent=LeftScroll end
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)
    Instance.new("UIStroke",card).Color=Color3.fromRGB(20, 25, 50)
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.65,0,0,20); nL.Position=UDim2.new(0,10,0,4)
    nL.BackgroundTransparency=1; nL.Text=name; nL.TextColor3=C.SUBTEXT; nL.TextSize=11
    nL.Font=Enum.Font.Gotham; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(0.35,-4,0,20); vL.Position=UDim2.new(0.65,0,0,4)
    vL.BackgroundTransparency=1; vL.Text=tostring(def)..sfx; vL.TextColor3=C.BLUE
    vL.TextSize=11; vL.Font=Enum.Font.GothamBold; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.Parent=card
    local track=Instance.new("Frame"); track.Size=UDim2.new(1,-20,0,6); track.Position=UDim2.new(0,10,0,30)
    track.BackgroundColor3=Color3.fromRGB(15, 18, 45); track.BorderSizePixel=0; track.Parent=card
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local p0=math.clamp((def-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame"); fill.Size=UDim2.new(p0,0,1,0); fill.BackgroundColor3=C.BLUE; fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(p0,0,0.5,0); knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0; knob.ZIndex=4; knob.Parent=track
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",knob).Color=C.BLUE
    local sd=false
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end)
    RunService.RenderStepped:Connect(function()
        if not sd then return end
        local mp=UserInputService:GetMouseLocation()
        local p=math.clamp((mp.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.round(mn+p*(mx-mn)); fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,0.5,0)
        vL.Text=tostring(v)..sfx; if cb then cb(v) end
    end)
    return card
end

-- Dropdown (click-to-cycle, Reign-style)
local function DD(name,opts,def,cb,isR)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,30); card.BackgroundColor3=C.BG3
    card.BackgroundTransparency=0.4; card.BorderSizePixel=0; card.Visible=false
    if isR then RO+=1;card.LayoutOrder=RO;card.Parent=RightScroll else LO+=1;card.LayoutOrder=LO;card.Parent=LeftScroll end
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,5)
    Instance.new("UIStroke",card).Color=Color3.fromRGB(20, 25, 50)
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.45,0,1,0); nL.Position=UDim2.new(0,10,0,0)
    nL.BackgroundTransparency=1; nL.Text=name; nL.TextColor3=C.SUBTEXT; nL.TextSize=11
    nL.Font=Enum.Font.Gotham; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
    local vBg=Instance.new("Frame"); vBg.Size=UDim2.new(0.52,0,0,22); vBg.Position=UDim2.new(0.46,0,0.5,-11)
    vBg.BackgroundColor3=C.BLUE_DARK; vBg.BorderSizePixel=0; vBg.Parent=card
    Instance.new("UICorner",vBg).CornerRadius=UDim.new(0,4)
    Instance.new("UIStroke",vBg).Color=C.BLUE_DIM
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(1,-24,1,0); vL.Position=UDim2.new(0,8,0,0)
    vL.BackgroundTransparency=1; vL.Text=def; vL.TextColor3=C.TEXT; vL.TextSize=11
    vL.Font=Enum.Font.GothamSemibold; vL.TextXAlignment=Enum.TextXAlignment.Left; vL.Parent=vBg
    local arr=Instance.new("TextLabel"); arr.Size=UDim2.new(0,14,0,14); arr.Position=UDim2.new(1,-14,0.5,-7); arr.AnchorPoint=Vector2.new(0.5,0.5)
    arr.BackgroundTransparency=1; arr.Text="▾"; arr.TextColor3=C.BLUE; arr.TextSize=10; arr.Font=Enum.Font.GothamBold; arr.Parent=vBg
    local idx=1; for i,v in opts do if v==def then idx=i; break end end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=2; btn.Parent=card
    btn.MouseButton1Click:Connect(function()
        idx=(idx%#opts)+1; vL.Text=opts[idx]
        TweenService:Create(vBg,TWEEN_FAST,{BackgroundColor3=C.BLUE_MID}):Play()
        task.delay(0.15,function() TweenService:Create(vBg,TWEEN_FAST,{BackgroundColor3=C.BLUE_DARK}):Play() end)
        if cb then cb(opts[idx]) end
    end)
    btn.MouseEnter:Connect(function() TweenService:Create(card,TWEEN_FAST,{BackgroundTransparency=0.2}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(card,TWEEN_FAST,{BackgroundTransparency=0.4}):Play() end)
    return card
end

-- Text label (info)
local function TL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1;f.LayoutOrder=RO;f.Parent=RightScroll else LO+=1;f.LayoutOrder=LO;f.Parent=LeftScroll end
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-10,1,0); lb.Position=UDim2.new(0,10,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextColor3=C.SUBTEXT; lb.TextSize=11
    lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end

-- Status badge row (for executor status)
local function BADGE(text,ok,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1;f.LayoutOrder=RO;f.Parent=RightScroll else LO+=1;f.LayoutOrder=LO;f.Parent=LeftScroll end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,10,0.5,-4)
    dot.BackgroundColor3=ok and C.GREEN or C.RED; dot.BorderSizePixel=0; dot.Parent=f
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-24,1,0); lb.Position=UDim2.new(0,24,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextColor3=ok and C.TEXT or C.SUBTEXT
    lb.TextSize=11; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end

local function addL(t,i) table.insert(t.leftItems,i) end
local function addR(t,i) table.insert(t.rightItems,i) end

-- ══════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════
local tAimbot  = makeTabBtn("AIMBOT",  1)
local tCombat  = makeTabBtn("COMBAT",  2)
local tTeleport = makeTabBtn("TELEPORT", 3)
local tVisuals = makeTabBtn("VISUALS", 4)
local tWorld   = makeTabBtn("WORLD",   5)
local tMove    = makeTabBtn("MOVE",    6)
local tExtras  = makeTabBtn("EXTRAS",  7)
local tConfig  = makeTabBtn("CONFIG",  8)

-- ─── AIMBOT ───
addL(tAimbot,SL("Core Settings",false))
addL(tAimbot,TG("Enable Aimbot","RMB",Aim.enabled,function(on) Aim.enabled=on; if not on then aimActive=false; aimTarget=nil end end,false))
addL(tAimbot,DD("Aim Mode",{"Camera","Mouse","Silent"},Aim.mode,function(v) Aim.mode=v end,false))
addL(tAimbot,DD("Aim Part",{"Head","HumanoidRootPart","Torso","UpperTorso"},Aim.aimPart,function(v) Aim.aimPart=v; aimTarget=nil end,false))
addL(tAimbot,DD("Key Mode",{"Hold","Toggle","OnePress"},Aim.keyMode,function(v) Aim.keyMode=v; aimActive=false; aimTarget=nil end,false))
addR(tAimbot,SL("Field of View",true))
addR(tAimbot,TG("Enable FOV","",Aim.fovEnabled,function(on) Aim.fovEnabled=on end,true))
addR(tAimbot,TG("Show FOV Circle","",Aim.showFov,function(on) Aim.showFov=on end,true))
addR(tAimbot,SLD("FOV Radius",10,600,Aim.fovRadius,"px",function(v) Aim.fovRadius=v end,true))
addL(tAimbot,SL("Smoothing",false))
addL(tAimbot,TG("Enable Smoothing","",Aim.smoothEnabled,function(on) Aim.smoothEnabled=on end,false))
addL(tAimbot,SLD("Smooth Amount",1,100,math.round(Aim.smoothAmount*100),"%",function(v) Aim.smoothAmount=v/100 end,false))
addR(tAimbot,SL("Prediction",true))
addR(tAimbot,TG("Enable Prediction","",Aim.predictEnabled,function(on) Aim.predictEnabled=on end,true))
addR(tAimbot,SLD("Predict Amount",1,30,math.round(Aim.predictAmount*100),"ms",function(v) Aim.predictAmount=v/100 end,true))
addR(tAimbot,SL("Silent Aim",true))
addR(tAimbot,hasHookMeta and TL("✔ Silent hooks installed",true) or TL("⚠ hookmetamethod not available",true))
addR(tAimbot,SLD("Silent Chance",1,100,Aim.silentChance,"%",function(v) Aim.silentChance=v end,true))
addR(tAimbot,SL("Range",true))
addR(tAimbot,SLD("Max Distance",0,2000,Aim.maxDist,"st",function(v) Aim.maxDist=v end,true))
addR(tAimbot,TL("0 = unlimited range",true))

-- ─── COMBAT ───
addL(tCombat,SL("SpinBot",false))
addL(tCombat,TG("Enable SpinBot","",Aim.spinEnabled,function(on) Aim.spinEnabled=on end,false))
addL(tCombat,SLD("Spin Speed",1,100,Aim.spinSpeed,"°/f",function(v) Aim.spinSpeed=v end,false))
addL(tCombat,DD("Spin Part",{"Head","HumanoidRootPart"},Aim.spinPart,function(v) Aim.spinPart=v end,false))
addR(tCombat,SL("TriggerBot",true))
if hasMouse1Click then
    addR(tCombat,TG("Enable TriggerBot","",Aim.triggerEnabled,function(on) Aim.triggerEnabled=on end,true))
    addR(tCombat,TG("Smart Mode (aiming only)","",Aim.triggerSmartOnly,function(on) Aim.triggerSmartOnly=on end,true))
    addR(tCombat,SLD("Hit Chance",1,100,Aim.triggerChance,"%",function(v) Aim.triggerChance=v end,true))
else
    addR(tCombat,TL("⚠ mouse1click not available",true))
end
addL(tCombat,SL("Anti-Lock",false))
addL(tCombat,TG("Enable Anti-Lock","",state.antiLock,function(on) state.antiLock=on end,false))
addL(tCombat,SLD("Fake Angle",1,360,state.antiAimAngle,"°",function(v) state.antiAimAngle=v end,false))
addR(tCombat,SL("Reach",true))
addR(tCombat,TG("Enable Reach","",state.reachEnabled,function(on) state.reachEnabled=on end,true))
addR(tCombat,SLD("Reach Distance",1,100,state.reachAmount,"st",function(v) state.reachAmount=v end,true))
addL(tCombat,SL("Hitbox Expander",false))
addL(tCombat,TG("Enable Hitbox","",state.hitboxExpander,function(on) state.hitboxExpander=on; applyHitboxes(on) end,false))
addL(tCombat,SLD("Hitbox Size",2,20,state.hitboxSize,"st",function(v) state.hitboxSize=v; if state.hitboxExpander then applyHitboxes(true) end end,false))

-- ─── TELEPORT ───
addL(tTeleport,SL("Click Teleport",false))
addL(tTeleport,TG("Enable Click TP","",state.clickTp,function(on) state.clickTp=on end,false))
addL(tTeleport,TL("Click anywhere to teleport",false))
addR(tTeleport,SL("Teleport to Player",true))
local tpPlayers={"None"}
for _,p in Players:GetPlayers() do if p~=Player then table.insert(tpPlayers,p.Name) end end
addR(tTeleport,DD("Select Player",tpPlayers,"None",function(v) state.teleportToPlayer=v end,true))
local tpBtn=Instance.new("TextButton"); tpBtn.Size=UDim2.new(1,0,0,30); tpBtn.BackgroundColor3=C.BLUE_DARK
tpBtn.BorderSizePixel=0; tpBtn.Text="TP to Player"; tpBtn.TextColor3=C.BLUE
tpBtn.TextSize=11; tpBtn.Font=Enum.Font.GothamSemibold; tpBtn.Visible=false
RO+=1; tpBtn.LayoutOrder=RO; tpBtn.Parent=RightScroll
Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",tpBtn).Color=C.BLUE_DIM
tpBtn.MouseButton1Click:Connect(function()
    if state.teleportToPlayer~="None" then
        local target=Players:FindFirstChild(state.teleportToPlayer)
        if target and target.Character then
            local hrp=target.Character:FindFirstChild("HumanoidRootPart")
            local myHRP=getHRP()
            if hrp and myHRP then myHRP.CFrame=hrp.CFrame*CFrame.new(0,0,3) end
        end
    end
end)
table.insert(tTeleport.rightItems,tpBtn)
addL(tTeleport,SL("Server Utilities",false))
addL(tTeleport,TG("Server Hop","",state.serverHop,function(on) state.serverHop=on end,false))
addL(tTeleport,TG("Copy Coords","",state.copyCoords,function(on) state.copyCoords=on end,false))
addL(tTeleport,TL("Copies your position to clipboard",false))
addR(tTeleport,SL("Protection",true))
addR(tTeleport,TG("Anti-Void","",state.antiVoid,function(on) state.antiVoid=on end,true))
addR(tTeleport,SLD("Void Height",-500,100,state.voidHeight,"",function(v) state.voidHeight=v end,true))
addR(tTeleport,TG("Anti-Stomp","",state.antiStomp,function(on) state.antiStomp=on end,true))
addR(tTeleport,TG("Anti-Ragdoll","",state.antiRagdoll,function(on) state.antiRagdoll=on end,true))
addL(tTeleport,SL("Fake Lag",false))
addL(tTeleport,TG("Enable Fake Lag","",state.fakelag,function(on) state.fakelag=on; setFakeLag(on) end,false))
addL(tTeleport,SLD("Lag Amount",1,20,state.fakelagAmount,"f",function(v) state.fakelagAmount=v end,false))

-- ─── VISUALS ───
addL(tVisuals,SL("ESP",false))
addL(tVisuals,TG("ESP Master","",state.esp,function(on) state.esp=on; if not on then for _,d in espDrawings do hideDrawings(d) end end end,false))
addL(tVisuals,TG("Boxes","",state.espBoxes,function(on) state.espBoxes=on end,false))
addL(tVisuals,TG("Names","",state.espNames,function(on) state.espNames=on end,false))
addL(tVisuals,TG("Health Bars","",state.espHealth,function(on) state.espHealth=on end,false))
addL(tVisuals,TG("Tracers","",state.espTracers,function(on) state.espTracers=on end,false))
addL(tVisuals,TG("Distance Labels","",state.espDistance,function(on) state.espDistance=on end,false))
if not hasDrawing then addL(tVisuals,TL("⚠ Drawing API not available",false)) end
addR(tVisuals,SL("World Lighting",true))
addR(tVisuals,TG("Fullbright","",state.fullbright,function(on) state.fullbright=on
    Lighting.Brightness=on and 10 or 1
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127) end,true))
addR(tVisuals,TG("No Fog","",state.noFog,function(on) state.noFog=on
    local a=Lighting:FindFirstChildOfClass("Atmosphere"); if a then a.Density=on and 0 or 0.395 end end,true))
addR(tVisuals,TG("No Shadows","",state.noShadows,function(on) state.noShadows=on; Lighting.GlobalShadows=not on end,true))
addR(tVisuals,SL("Minimap",true))
addR(tVisuals,TG("Show Minimap","",state.minimapEnabled,function(on) state.minimapEnabled=on; MinimapFrame.Visible=on end,true))
addR(tVisuals,SLD("Radar Range",50,1000,state.minimapRange,"st",function(v)
    state.minimapRange=v; mmLabel.Text="▣ RADAR  ·  "..v.."st  ·  [M] MAP" end,true))
addR(tVisuals,SL("Overlays",true))
addR(tVisuals,TG("Speed Overlay","",state.speedOverlay,function(on) state.speedOverlay=on end,true))
addR(tVisuals,TG("Player List","",state.playerList,function(on) state.playerList=on end,true))
addR(tVisuals,TG("Kill Feed","",state.killFeed,function(on) state.killFeed=on end,true))
addR(tVisuals,TG("Session Info","",state.sessionInfo,function(on) state.sessionInfo=on end,true))

-- ─── WORLD ───
addL(tWorld,SL("World ESP",false))
addL(tWorld,TG("Enable World ESP","",state.worldEsp,function(on) state.worldEsp=on end,false))
addL(tWorld,TG("Show Chests","",state.worldEspChests,function(on) state.worldEspChests=on end,false))
addL(tWorld,TG("Show Items","",state.worldEspItems,function(on) state.worldEspItems=on end,false))
addL(tWorld,TG("Show Doors","",state.worldEspDoors,function(on) state.worldEspDoors=on end,false))
addL(tWorld,TG("Show Objectives","",state.worldEspObjectives,function(on) state.worldEspObjectives=on end,false))
addL(tWorld,TL("World ESP highlights objects in game",false))
addR(tWorld,SL("Sound Visualizer",true))
addR(tWorld,TG("Enable Sound Viz","",state.soundViz,function(on) state.soundViz=on end,true))
addR(tWorld,SLD("Sound Range",20,500,state.soundVizRange,"st",function(v) state.soundVizRange=v end,true))
addR(tWorld,SL("Sound Types",true))
addR(tWorld,TG("Footsteps","",state.soundVizFootsteps,function(on) state.soundVizFootsteps=on end,true))
addR(tWorld,TG("Gunfire","",state.soundVizGunfire,function(on) state.soundVizGunfire=on end,true))
addR(tWorld,TG("Vehicles","",state.soundVizVehicles,function(on) state.soundVizVehicles=on end,true))
addR(tWorld,TG("Explosions","",state.soundVizExplosions,function(on) state.soundVizExplosions=on end,true))
addR(tWorld,TG("Doors","",state.soundVizDoors,function(on) state.soundVizDoors=on end,true))
addR(tWorld,TG("Voice Chat","",state.soundVizVoice,function(on) state.soundVizVoice=on end,true))
addR(tWorld,SL("Filters",true))
addR(tWorld,TG("Enemies Only","",state.soundVizEnemiesOnly,function(on) state.soundVizEnemiesOnly=on end,true))

-- ─── MOVEMENT ───
addL(tMove,SL("Locomotion",false))
addL(tMove,TG("Fly","",state.flyEnabled,function(on)
    state.flyEnabled=on; local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
    if on then hum.PlatformStand=true
        bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
        bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=hrp
    else if bv then bv:Destroy();bv=nil end; if bg then bg:Destroy();bg=nil end; hum.PlatformStand=false end
end,false))
addL(tMove,TG("Noclip","",state.noclip,function(on) state.noclip=on end,false))
addL(tMove,TG("Infinite Jump","",state.infiniteJump,function(on) state.infiniteJump=on end,false))
addL(tMove,TG("Bunny Hop","B",state.bunnyhop,function(on) state.bunnyhop=on end,false))
addL(tMove,TG("Auto Sprint","",state.autoSprint,function(on) state.autoSprint=on end,false))
addL(tMove,SLD("Sprint Speed",16,100,state.sprintSpeed,"",function(v) state.sprintSpeed=v end,false))
addL(tMove,TG("Speed Boost","",state.speedBoost,function(on) state.speedBoost=on end,false))
addL(tMove,SLD("Walk Speed",8,200,state.walkSpeed,"",function(v) state.walkSpeed=v end,false))
addL(tMove,SLD("Jump Power",0,300,state.jumpPower,"",function(v) state.jumpPower=v end,false))
addR(tMove,SL("Player",true))
addR(tMove,TG("God Mode","",state.godMode,function(on) state.godMode=on end,true))
addR(tMove,TG("Anti-AFK","",state.antiAfk,function(on) state.antiAfk=on end,true))
addR(tMove,TG("Invisible","",state.invisible,function(on)
    state.invisible=on; local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do
        if p:IsA("BasePart") then
            p.LocalTransparencyModifier=on and 1 or 0
        elseif p:IsA("Decal") or p:IsA("Texture") then
            p.Transparency=on and 1 or 0
        end
    end end,true))
addR(tMove,TG("Third Person","",state.thirdPerson,function(on) state.thirdPerson=on; setThirdPerson(on) end,true))
addR(tMove,SLD("3P Distance",3,30,state.tpDistance,"st",function(v)
    state.tpDistance=v; if state.thirdPerson then Player.CameraMaxZoomDistance=v; Player.CameraMinZoomDistance=v end end,true))

-- ─── EXTRAS ───
addL(tExtras,SL("Crosshair",false))
addL(tExtras,TG("Custom Crosshair","",state.crosshair,function(on) state.crosshair=on; rebuildCrosshair() end,false))
addL(tExtras,DD("Style",{"Plus","Dot","X"},state.crosshairStyle,function(v) state.crosshairStyle=v; rebuildCrosshair() end,false))
addL(tExtras,SLD("Size",4,30,state.crosshairSize,"px",function(v) state.crosshairSize=v; rebuildCrosshair() end,false))
addL(tExtras,SL("Auto Features",false))
addL(tExtras,TG("Auto Rejoin","",state.autoRejoin,function(on) state.autoRejoin=on end,false))
addL(tExtras,TG("Auto Equip Weapon","",state.autoEquip,function(on) state.autoEquip=on end,false))
addR(tExtras,SL("Match Automation",true))
addR(tExtras,TG("Auto Accept Match","",state.matchAutoAccept,function(on) state.matchAutoAccept=on end,true))
addR(tExtras,TG("Auto Queue","",state.matchAutoQueue,function(on) state.matchAutoQueue=on end,true))
addR(tExtras,SL("Streamer Mode",true))
addR(tExtras,TG("Enable Streamer Mode","",state.streamerMode,function(on) state.streamerMode=on end,true))
addR(tExtras,TL("Hides script presence",true))
addL(tExtras,SL("Keybinds",false))
addL(tExtras,TL("RShift  →  Toggle GUI",false))
addL(tExtras,TL("RMB     →  Aim (hold/toggle/one)",false))
addL(tExtras,TL("M       →  Full Map",false))
addL(tExtras,TL("B       →  Bunny Hop",false))
addL(tExtras,TL("Click   →  Teleport (if enabled)",false))

-- ─── CONFIG ───
addL(tConfig,SL("Save & Load",false))
local saveRow=Instance.new("TextButton"); saveRow.Size=UDim2.new(1,0,0,34); saveRow.BackgroundColor3=C.BLUE_DARK
saveRow.BorderSizePixel=0; saveRow.Text="💾  Save Config"; saveRow.TextColor3=C.BLUE
saveRow.TextSize=12; saveRow.Font=Enum.Font.GothamSemibold; saveRow.Visible=false
LO+=1; saveRow.LayoutOrder=LO; saveRow.Parent=LeftScroll
Instance.new("UICorner",saveRow).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",saveRow).Color=C.BLUE_DIM
saveRow.MouseButton1Click:Connect(function() saveConfig()
    TweenService:Create(saveRow,TWEEN_FAST,{BackgroundColor3=Color3.fromRGB(20,60,25)}):Play()
    saveRow.Text="✔  Saved!"; saveRow.TextColor3=C.GREEN
    task.delay(1.5,function() TweenService:Create(saveRow,TWEEN_FAST,{BackgroundColor3=C.BLUE_DARK}):Play(); saveRow.Text="💾  Save Config"; saveRow.TextColor3=C.BLUE end)
end)
table.insert(tConfig.leftItems,saveRow)

local loadRow=Instance.new("TextButton"); loadRow.Size=UDim2.new(1,0,0,34); loadRow.BackgroundColor3=C.BLUE_DARK
loadRow.BorderSizePixel=0; loadRow.Text="📂  Load Config"; loadRow.TextColor3=C.BLUE
loadRow.TextSize=12; loadRow.Font=Enum.Font.GothamSemibold; loadRow.Visible=false
LO+=1; loadRow.LayoutOrder=LO; loadRow.Parent=LeftScroll
Instance.new("UICorner",loadRow).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",loadRow).Color=C.BLUE_DIM
loadRow.MouseButton1Click:Connect(function() loadConfig()
    TweenService:Create(loadRow,TWEEN_FAST,{BackgroundColor3=Color3.fromRGB(20,60,25)}):Play()
    loadRow.Text="✔  Loaded!"; loadRow.TextColor3=C.GREEN
    task.delay(1.5,function() TweenService:Create(loadRow,TWEEN_FAST,{BackgroundColor3=C.BLUE_DARK}):Play(); loadRow.Text="📂  Load Config"; loadRow.TextColor3=C.BLUE end)
end)
table.insert(tConfig.leftItems,loadRow)

addL(tConfig,TL("File: blueblur_config.json",false))
addL(tConfig,TL("Auto-saves on GUI close",false))

addR(tConfig,SL("Executor Status",true))
addR(tConfig,BADGE("Drawing API",hasDrawing,true))
addR(tConfig,BADGE("mousemoverel",hasMoveRel,true))
addR(tConfig,BADGE("hookmetamethod",hasHookMeta,true))
addR(tConfig,BADGE("mouse1click",hasMouse1Click,true))
addR(tConfig,SL("Mode Notes",true))
addR(tConfig,TL("Camera  →  moves camera to lock",true))
addR(tConfig,TL("Mouse   →  requires mousemoverel",true))
addR(tConfig,TL("Silent  →  requires hookmetamethod",true))
addR(tConfig,TL("blueblur  v4.0  —  Ultimate",true))

-- ══════════════════════════════════════════
--  GLOBAL INPUT
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then
        if Win.Visible then
            TweenService:Create(Win,TWEEN_FAST,{BackgroundTransparency=1}):Play()
            task.delay(0.15,function() Win.Visible=false; Win.BackgroundTransparency=0 end)
        else
            Win.Visible=true; Win.Size=UDim2.new(0,WIN_W*0.8,0,WIN_H*0.8)
            TweenService:Create(Win,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,WIN_W,0,WIN_H)}):Play()
        end
        return
    end
    if inp.KeyCode==Enum.KeyCode.M then
        state.fullMapOpen=not state.fullMapOpen; FullMapFrame.Visible=state.fullMapOpen
        if state.fullMapOpen and mapScanned then applyColorMapToTiles(fullMapTiles,FULLMAP_CELLS,mapColorGrid) end
        return
    end
    if not Aim.enabled then return end
    local isRMB=inp.UserInputType==Enum.UserInputType.MouseButton2
    local isKey=false; if Aim.key~="RMB" then pcall(function() isKey=inp.KeyCode==Enum.KeyCode[Aim.key] end) end
    if isRMB or isKey then aimKeyDown() end
end)

UserInputService.InputEnded:Connect(function(inp)
    local isRMB=inp.UserInputType==Enum.UserInputType.MouseButton2
    local isKey=false; if Aim.key~="RMB" then pcall(function() isKey=inp.KeyCode==Enum.KeyCode[Aim.key] end) end
    if isRMB or isKey then aimKeyUp() end
end)

-- ══════════════════════════════════════════
--  MOVEMENT RUNTIME
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.flyEnabled or not bv or not bg then return end
    local cam=Camera; local dir=Vector3.zero
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
    local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end
end)

UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump then return end
    local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

RunService.Heartbeat:Connect(function()
    if state.bunnyhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    local hum=getHum(); if not hum then return end
    if state.godMode then hum.Health=hum.MaxHealth end
    if state.speedBoost then hum.WalkSpeed=80
    elseif state.autoSprint then hum.WalkSpeed=state.sprintSpeed
    else hum.WalkSpeed=state.walkSpeed end
    hum.JumpPower=state.jumpPower
    -- Anti-Void
    if state.antiVoid then
        local hrp=getHRP()
        if hrp and hrp.Position.Y < state.voidHeight then
            hrp.CFrame=CFrame.new(hrp.Position.X,state.voidHeight+10,hrp.Position.Z)
        end
    end
    -- Anti-Stomp (prevent death on fall)
    if state.antiStomp then
        local hrp=getHRP()
        if hrp then
            local vel=hrp.AssemblyLinearVelocity
            if vel.Y < -50 then
                vel=Vector3.new(vel.X,0,vel.Z)
                hrp.AssemblyLinearVelocity=vel
            end
        end
    end
end)

Player.Idled:Connect(function()
    if not state.antiAfk then return end
    VirtualUser:Button2Down(Vector2.zero,Camera.CFrame); task.wait(0.1); VirtualUser:Button2Up(Vector2.zero,Camera.CFrame)
end)

-- ══════════════════════════════════════════
--  CLICK TELEPORT
-- ══════════════════════════════════════════
Mouse.Button1Down:Connect(function()
    if state.clickTp then
        local hrp=getHRP()
        if hrp then
            local target=Mouse.Target
            if target then
                local pos=target.Position
                hrp.CFrame=CFrame.new(pos.X,pos.Y+3,pos.Z)
            end
        end
    end
end)

-- ══════════════════════════════════════════
--  COPY COORDINATES
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if state.copyCoords then
        local hrp=getHRP()
        if hrp and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and UserInputService:IsKeyDown(Enum.KeyCode.C) then
            local pos=hrp.Position
            local coords=string.format("X:%.2f, Y:%.2f, Z:%.2f",pos.X,pos.Y,pos.Z)
            pcall(function() setclipboard(coords) end)
            state.copyCoords=false
        end
    end
end)

-- ══════════════════════════════════════════
--  SERVER HOP
-- ══════════════════════════════════════════
local function serverHop()
    if not state.serverHop then return end
    pcall(function()
        local servers={}
        local cursor=nil
        repeat
            local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortFilter=2&limit=100"
            if cursor then url=url.."&cursor="..cursor end
            local res=game:HttpGet(url,true)
            local data=HttpService:JSONDecode(res)
            for _,s in data.data do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers,s.id)
                end
            end
            cursor=data.nextPageCursor
        until not cursor or #servers > 0
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)],Player)
        end
    end)
end

-- ══════════════════════════════════════════
--  ANTI-RAGDOLL
-- ══════════════════════════════════════════
Player.CharacterAdded:Connect(function(char)
    if state.antiRagdoll then
        local hum=char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
    end
end)

-- ══════════════════════════════════════════
--  SPEED OVERLAY (Drawing)
-- ══════════════════════════════════════════
local speedTextDrawing=nil
RunService.RenderStepped:Connect(function()
    if state.speedOverlay and hasDrawing then
        if not speedTextDrawing then
            speedTextDrawing=Drawing.new("Text")
            speedTextDrawing.Size=16
            speedTextDrawing.Font=Drawing.Fonts.UI
            speedTextDrawing.Color=C.BLUE
            speedTextDrawing.Outline=true
            speedTextDrawing.OutlineColor=Color3.new(0,0,0)
            speedTextDrawing.Text="Speed: 0"
            speedTextDrawing.Position=Vector2.new(10,60)
            speedTextDrawing.Visible=true
        end
        local hum=getHum()
        if hum then
            speedTextDrawing.Text="Speed: "..math.floor(hum.WalkSpeed)
        end
    elseif speedTextDrawing then
        speedTextDrawing:Remove()
        speedTextDrawing=nil
    end
end)

-- ══════════════════════════════════════════
--  WORLD ESP OBJECTS SCANNER
-- ══════════════════════════════════════════
local function scanWorldObjects()
    state.worldEspObjects={}
    local chestNames={"Chest","Treasure","Loot","Supply","Crate"}
    local itemNames={"Tool","Weapon","Pickup","Drop","Coin","Gem"}
    local doorNames={"Door","Gate","Exit","Enter"}
    local objNames={"Objective","Flag","Capture","Point","Base"}

    for _,obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") then
            local name=obj.Name:lower()
            local objType=nil
            for _,c in chestNames do if name:find(c:lower()) then objType="chest" break end end
            if not objType then for _,i in itemNames do if name:find(i:lower()) then objType="item" break end end end
            if not objType then for _,d in doorNames do if name:find(d:lower()) then objType="door" break end end end
            if not objType then for _,o in objNames do if name:find(o:lower()) then objType="objective" break end end end
            if objType then
                table.insert(state.worldEspObjects,{obj=obj,type=objType})
            end
        end
    end
end
task.spawn(scanWorldObjects)

-- ══════════════════════════════════════════
--  PLAYER LIST UI
-- ══════════════════════════════════════════
local playerListGui=nil
local function createPlayerList()
    if playerListGui then playerListGui:Destroy() end
    playerListGui=Instance.new("ScreenGui"); playerListGui.Name="BlueBlurPlayerList"
    playerListGui.ResetOnSpawn=false; playerListGui.Parent=PlayerGui

    local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,200,0,300)
    frame.Position=UDim2.new(0,10,0.5,-150); frame.BackgroundColor3=C.BG2
    frame.BackgroundTransparency=0.2; frame.BorderSizePixel=0; frame.Parent=playerListGui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",frame).Color=C.BLUE_DIM

    local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,0,0,25)
    title.BackgroundTransparency=1; title.Text="Player List"
    title.TextColor3=C.BLUE; title.TextSize=12; title.Font=Enum.Font.GothamBold; title.Parent=frame

    local list=Instance.new("ScrollingFrame"); list.Size=UDim2.new(1,-10,1,-30)
    list.Position=UDim2.new(0,5,0,28); list.BackgroundTransparency=1
    list.ScrollBarThickness=3; list.ScrollBarImageColor3=C.BLUE
    list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.Parent=frame
    local ly=Instance.new("UIListLayout"); ly.SortOrder=Enum.SortOrder.LayoutOrder; ly.Padding=UDim.new(0,2); ly.Parent=list

    local idx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        idx=idx+1
        local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,20)
        row.BackgroundColor3=C.BG3; row.BackgroundTransparency=0.5; row.LayoutOrder=idx; row.Parent=list
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)

        local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(0.6,-5,1,0)
        nm.Position=UDim2.new(0,5,0,0); nm.BackgroundTransparency=1
        nm.Text=plr.DisplayName; nm.TextColor3=C.TEXT; nm.TextSize=10
        nm.Font=Enum.Font.Gotham; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.Parent=row

        local hp=Instance.new("TextLabel"); hp.Size=UDim2.new(0.4,-5,1,0)
        hp.Position=UDim2.new(0.6,0,0,0); hp.BackgroundTransparency=1
        hp.Text="--"; hp.TextColor3=C.SUBTEXT; hp.TextSize=9
        hp.Font=Enum.Font.Gotham; hp.TextXAlignment=Enum.TextXAlignment.Right; hp.Parent=row

        plr.CharacterAdded:Connect(function(char)
            local hum=char:WaitForChild("Humanoid")
            hum.HealthChanged:Connect(function(h)
                hp.Text=math.floor(h).."/"..math.floor(hum.MaxHealth)
                hp.TextColor3=h > hum.MaxHealth*0.5 and C.GREEN or C.RED
            end)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if state.playerList and not playerListGui then
        createPlayerList()
    elseif not state.playerList and playerListGui then
        playerListGui:Destroy()
        playerListGui=nil
    end
end)

-- ══════════════════════════════════════════
--  SESSION INFO UI
-- ══════════════════════════════════════════
local sessionInfoDrawing=nil
RunService.RenderStepped:Connect(function()
    if state.sessionInfo and hasDrawing then
        if not sessionInfoDrawing then
            sessionInfoDrawing=Drawing.new("Text")
            sessionInfoDrawing.Size=14
            sessionInfoDrawing.Font=Drawing.Fonts.UI
            sessionInfoDrawing.Color=C.TEXT
            sessionInfoDrawing.Outline=true
            sessionInfoDrawing.OutlineColor=Color3.new(0,0,0)
            sessionInfoDrawing.Text=""
            sessionInfoDrawing.Position=Vector2.new(10,80)
            sessionInfoDrawing.Visible=true
        end
        local ping=math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local fps=math.floor(1/game:GetService("RunService").RenderStepped:Wait())
        sessionInfoDrawing.Text="Ping: "..ping.."ms | FPS: "..fps
    elseif sessionInfoDrawing then
        sessionInfoDrawing:Remove()
        sessionInfoDrawing=nil
    end
end)

-- ══════════════════════════════════════════
--  KILL FEED UI
-- ══════════════════════════════════════════
local killFeedGui=nil
local killFeedEntries={}
local function addKillFeedEntry(killer,victim)
    if not killFeedGui then return end
    local entry={text=killer.." eliminated "..victim,age=0}
    table.insert(killFeedEntries,1,entry)
    if #killFeedEntries > 5 then table.remove(killFeedEntries) end
    -- Rebuild kill feed
    for _,c in killFeedGui:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
    for i,e in ipairs(killFeedEntries) do
        local row=Instance.new("Frame"); row.Size=UDim2.new(1,-10,0,18)
        row.Position=UDim2.new(0,5,0,(i-1)*20+5); row.BackgroundColor3=C.BG3
        row.BackgroundTransparency=0.7; row.BorderSizePixel=0; row.Parent=killFeedGui
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
        local txt=Instance.new("TextLabel"); txt.Size=UDim2.new(1,0,1,0)
        txt.BackgroundTransparency=1; txt.Text=e.text; txt.TextColor3=C.TEXT
        txt.TextSize=10; txt.Font=Enum.Font.Gotham; txt.Parent=row
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            local killer=plr:FindFirstChild("Creator") and Players:GetPlayerFromCharacter(plr.Creator)
            if killer then
                addKillFeedEntry(killer.DisplayName,plr.DisplayName)
            end
        end)
    end)
end)

RunService.RenderStepped:Connect(function()
    if state.killFeed and not killFeedGui then
        killFeedGui=Instance.new("ScreenGui"); killFeedGui.Name="BlueBlurKillFeed"
        killFeedGui.ResetOnSpawn=false; killFeedGui.Parent=PlayerGui
        local frame=Instance.new("Frame"); frame.Size=UDim2.new(0,220,0,120)
        frame.Position=UDim2.new(1,-230,0,10); frame.BackgroundTransparency=1; frame.Parent=killFeedGui
    elseif not state.killFeed and killFeedGui then
        killFeedGui:Destroy()
        killFeedGui=nil
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
--  MINIMAP LOOP  (color-aware, rotates with camera) - FIXED POSITION
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    MinimapFrame.Visible=state.minimapEnabled
    if not state.minimapEnabled then return end
    local selfHRP=getHRP(); if not selfHRP then return end
    local selfPos=selfHRP.Position
    local _,camY,_=Camera.CFrame:ToEulerAnglesYXZ()
    -- Scroll map layer so self is always centered
    if mapScanned then
        local nx=(selfPos.X-mapMinX)/math.max(mapMaxX-mapMinX,1)
        local nz=(selfPos.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1)
        mapLayer.Position=UDim2.new(0,(0.5-nx)*MINIMAP_SIZE,0,(0.5-nz)*MINIMAP_SIZE)
    end
    -- Rotate heading arrow
    local headArrow=mmSelf:FindFirstChild("HeadingArrow")
    -- Update enemy dots
    local targetPlr=aimTarget and Players:GetPlayerFromCharacter(aimTarget)
    local dotIdx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1
        local entry=getMMDot(dotIdx); local dot=entry.dot; local dn=entry.label; local ds=entry.stroke
        dot.Visible=true
        if dn then dn.Text=plr.DisplayName:sub(1,8) end
        local offset=hrp.Position-selfPos
        local rx=offset.X*math.cos(camY)+offset.Z*math.sin(camY)
        local rz=-offset.X*math.sin(camY)+offset.Z*math.cos(camY)
        dot.Position=UDim2.new(0.5,math.clamp(rx/state.minimapRange,-0.9,0.9)*(MINIMAP_SIZE/2-6),
                                0.5,math.clamp(rz/state.minimapRange,-0.9,0.9)*(MINIMAP_SIZE/2-6))
        if plr==targetPlr then dot.BackgroundColor3=C.GOLD; if ds then ds.Color=C.GOLD end
        else
            local ok1,mt=pcall(function() return Player.Team end); local ok2,pt=pcall(function() return plr.Team end)
            local isTeam=ok1 and ok2 and mt and pt and mt==pt
            dot.BackgroundColor3=isTeam and C.GREEN or C.RED
            if ds then ds.Color=isTeam and C.GREEN or C.RED end
        end
    end
    for i=dotIdx+1,#mmDots do mmDots[i].dot.Visible=false end
end)

-- ══════════════════════════════════════════
--  FULL MAP LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not state.fullMapOpen or not mapScanned then return end
    local selfHRP=getHRP()
    if selfHRP then
        local nx=math.clamp((selfHRP.Position.X-mapMinX)/math.max(mapMaxX-mapMinX,1),0,1)
        local nz=math.clamp((selfHRP.Position.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1),0,1)
        fmSelf.Position=UDim2.new(nx,0,nz,0)
        -- Rotate heading arrow in full map
        local _,camY,_=Camera.CFrame:ToEulerAnglesYXZ()
        fmArrow.Rotation=math.deg(-camY)
    end
    local targetPlr=aimTarget and Players:GetPlayerFromCharacter(aimTarget)
    local dotIdx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1
        local entry=getFmDot(dotIdx); local dot=entry.dot; local nl=entry.label
        dot.Visible=true; if nl then nl.Text=plr.DisplayName:sub(1,10) end
        local nx=math.clamp((hrp.Position.X-mapMinX)/math.max(mapMaxX-mapMinX,1),0,1)
        local nz=math.clamp((hrp.Position.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1),0,1)
        dot.Position=UDim2.new(nx,0,nz,0)
        if plr==targetPlr then dot.BackgroundColor3=C.GOLD
        else
            local ok1,mt=pcall(function() return Player.Team end); local ok2,pt=pcall(function() return plr.Team end)
            dot.BackgroundColor3=(ok1 and ok2 and mt and pt and mt==pt) and C.GREEN or C.RED
        end
    end
    for i=dotIdx+1,#fmEnemyDots do fmEnemyDots[i].dot.Visible=false end
end)

-- ══════════════════════════════════════════
--  PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr) cleanupESPForPlayer(plr) end)

Player.CharacterAdded:Connect(function()
    state.flyEnabled=false; bv=nil; bg=nil
    aimActive=false; aimTarget=nil
    UserInputService.MouseDeltaSensitivity=savedSens
    Camera.CameraType=Enum.CameraType.Custom
    if state.thirdPerson then task.wait(1); setThirdPerson(true) end
end)

game:BindToClose(function()
    saveConfig(); cleanupAllESP()
    for _,d in crosshairDrawings do pcall(function() d:Remove() end) end
    -- Cleanup sound viz drawings
    for _,d in soundVizDrawings do pcall(function() d:Remove() end) end
end)

-- ══════════════════════════════════════════
--  FORTNITE-STYLE SOUND VISUALIZER
-- ══════════════════════════════════════════
local soundVizDrawings={}
local soundVizActive={}
local soundVizColors={
    footsteps=Color3.fromRGB(255,50,50),    -- Red for footsteps
    gunfire=Color3.fromRGB(255,200,50),     -- Orange for gunfire
    vehicles=Color3.fromRGB(100,200,255),   -- Blue for vehicles
    explosions=Color3.fromRGB(255,100,50), -- Red-orange for explosions
    doors=Color3.fromRGB(200,200,100),      -- Yellow for doors
    voice=Color3.fromRGB(100,255,100),      -- Green for voice chat
}

-- Sound name patterns (lowercase for matching)
local soundPatterns={
    {pattern="walk|step|foot|run|jump|land",type="footsteps"},
    {pattern="shoot|gun|fire|pistol|rifle|shot|gunfire|weapon",type="gunfire"},
    {pattern="car|vehicle|motor|engine|drive|truck|helicop",type="vehicles"},
    {pattern="explosion|bomb|grenade|rocket|frag|explode",type="explosions"},
    {pattern="door|open|close|creak|gate",type="doors"},
    {pattern="voice|speak|talk|mic|chat|audio",type="voice"},
}

-- Create sound viz UI (circular radar around screen)
local soundVizGui=Instance.new("ScreenGui"); soundVizGui.Name="BlueBlurSoundViz"
soundVizGui.ResetOnSpawn=false; soundVizGui.Parent=PlayerGui
soundVizGui.Enabled=false

-- Create the circular radar frame
local soundVizFrame=Instance.new("Frame"); soundVizFrame.Name="SoundRadar"
soundVizFrame.Size=UDim2.new(0,300,0,300); soundVizFrame.AnchorPoint=Vector2.new(0.5,0.5)
soundVizFrame.Position=UDim2.new(0.5,0,0.5,0); soundVizFrame.BackgroundTransparency=1
soundVizFrame.Parent=soundVizGui

-- Create direction indicators (12 directions)
for i=1,12 do
    local angle=(i-1)*30
    local rad=math.rad(angle)
    local x=math.cos(rad)*130
    local y=math.sin(rad)*130
    local dot=Instance.new("Frame"); dot.Name="Dir"..i
    dot.Size=UDim2.new(0,12,0,12); dot.Position=UDim2.new(0.5,0,0.5,0)
    dot.BackgroundColor3=Color3.fromRGB(50,50,80); dot.BackgroundTransparency=0.7
    dot.AnchorPoint=Vector2.new(0.5,0.5); dot.Position=UDim2.new(0.5,x-6,0.5,-y-6)
    dot.BorderSizePixel=0; dot.Parent=soundVizFrame
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end

-- Center dot
local centerDot=Instance.new("Frame"); centerDot.Name="Center"
centerDot.Size=UDim2.new(0,20,0,20); centerDot.Position=UDim2.new(0.5,0,0.5,0)
centerDot.BackgroundColor3=C.BLUE; centerDot.BackgroundTransparency=0.5
centerDot.AnchorPoint=Vector2.new(0.5,0.5); centerDot.BorderSizePixel=0
centerDot.Parent=soundVizFrame
Instance.new("UICorner",centerDot).CornerRadius=UDim.new(1,0)

-- Helper: Check if player is enemy
local function isEnemy(plr)
    if plr==Player then return false end
    local ok1,mt=pcall(function() return Player.Team end)
    local ok2,pt=pcall(function() return plr.Team end)
    if ok1 and ok2 and mt and pt then
        return mt~=pt
    end
    return true -- Assume enemy if no team info
end

-- Helper: Get sound type from sound object
local function getSoundType(snd)
    if not snd then return nil end
    local name=(snd.SoundId or "")..(snd.Name or "")
    local lower=name:lower()
    for _,s in ipairs(soundPatterns) do
        if lower:find(s.pattern) then return s.type end
    end
    return nil
end

-- Helper: Create indicator for sound
local function createSoundIndicator(soundType,soundPos,isEnemyFlag)
    if not hasDrawing then return end
    if not state.soundViz then return end

    local selfHRP=getHRP()
    if not selfHRP then return end

    local offset=soundPos-selfHRP.Position
    local dist=offset.Magnitude
    if dist > state.soundVizRange then return end

    -- Check if enemy-only filter is enabled
    if state.soundVizEnemiesOnly and isEnemyFlag==false then return end

    -- Map to screen position
    local screenPos=Camera:WorldToScreenPoint(soundPos)
    if screenPos.Z < 0 then return end -- Behind camera

    -- Calculate angle from screen center to sound
    local centerX=Camera.ViewportSize.X/2
    local centerY=Camera.ViewportSize.Y/2
    local relX=screenPos.X-centerX
    local relY=-(screenPos.Y-centerY) -- Flip Y axis
    local angle=math.atan2(relY,relX)

    -- Create triangle indicator
    local ind=Drawing.new("Triangle")
    ind.Color=soundVizColors[soundType] or C.RED
    ind.Filled=true
    ind.Thickness=2
    ind.Transparency=0.2
    ind.Visible=true

    -- Position at screen edge, pointing to sound
    local radius=math.min(centerX,centerY)*0.9
    local indX=centerX+math.cos(angle)*radius
    local indY=centerY+math.sin(angle)*radius
    local size=15
    ind.PointA=Vector2.new(indX+math.cos(angle)*size,indY+math.sin(angle)*size)
    ind.PointB=Vector2.new(indX+math.cos(angle+2.6)*size*0.7,indY+math.sin(angle+2.6)*size*0.7)
    ind.PointC=Vector2.new(indX+math.cos(angle-2.6)*size*0.7,indY+math.sin(angle-2.6)*size*0.7)

    table.insert(soundVizDrawings,ind)
    table.insert(soundVizActive,{
        drawing=ind,
        created=tick(),
        duration=2.0, -- Longer duration
    })
end

-- Track player movement for footstep detection
local playerLastPos={}
local playerMovingState={}

Players.PlayerAdded:Connect(function(plr)
    playerLastPos[plr]=nil
    playerMovingState[plr]=false

    plr.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid")
        local hrp=char:WaitForChild("HumanoidRootPart")
        playerLastPos[plr]=hrp.Position

        -- Detect running state changes
        hum.Running:Connect(function(speed)
            if speed > 1 and state.soundViz and state.soundVizFootsteps then
                local currentPos=hrp.Position
                local lastPos=playerLastPos[plr]
                if lastPos then
                    local dist=(currentPos-lastPos).Magnitude
                    if dist > 0.5 then -- Real movement
                        createSoundIndicator("footsteps",currentPos,isEnemy(plr))
                    end
                end
                playerLastPos[plr]=currentPos
            end
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    playerLastPos[plr]=nil
    playerMovingState[plr]=nil
end)

-- Sound monitoring (sounds playing in workspace)
task.spawn(function()
    while true do
        task.wait(0.05) -- Check more frequently
        if not state.soundViz then continue end

        for _,desc in workspace:GetDescendants() do
            if desc:IsA("Sound") and desc.IsPlaying and desc.Volume > 0 then
                local soundType=getSoundType(desc)
                if soundType then
                    -- Check if this sound type is enabled
                    local enabled=false
                    if soundType=="footsteps" and state.soundVizFootsteps then enabled=true end
                    if soundType=="gunfire" and state.soundVizGunfire then enabled=true end
                    if soundType=="vehicles" and state.soundVizVehicles then enabled=true end
                    if soundType=="explosions" and state.soundVizExplosions then enabled=true end
                    if soundType=="doors" and state.soundVizDoors then enabled=true end
                    if soundType=="voice" and state.soundVizVoice then enabled=true end

                    if enabled then
                        -- Get sound position
                        local soundParent=desc.Parent
                        local soundPos=nil

                        if soundParent:IsA("BasePart") then
                            soundPos=soundParent.Position
                        elseif soundParent:IsA("Model") and soundParent.PrimaryPart then
                            soundPos=soundParent.PrimaryPart.Position
                        elseif soundParent:IsA("Tool") and soundParent.Parent then
                            if soundParent.Parent:IsA("Model") then
                                local hrp=soundParent.Parent:FindFirstChild("HumanoidRootPart")
                                if hrp then soundPos=hrp.Position end
                            end
                        end

                        if soundPos then
                            -- Try to identify who made the sound
                            local enemyFlag=true -- Default to showing
                            if soundParent:IsA("Model") then
                                local plr=Players:GetPlayerFromCharacter(soundParent)
                                if plr then enemyFlag=isEnemy(plr) end
                            end
                            createSoundIndicator(soundType,soundPos,enemyFlag)
                        end
                    end
                end
            end
        end
    end
end)

-- Sound visualizer update loop
RunService.RenderStepped:Connect(function()
    local guiEnabled=state.soundViz and hasDrawing
    soundVizGui.Enabled=guiEnabled
    if not guiEnabled then
        for _,d in soundVizDrawings do pcall(function() d.Visible=false end) end
        return
    end
    -- Clean up old indicators
    local now=tick()
    local newDrawings={}
    local newActive={}
    for i,d in ipairs(soundVizDrawings) do
        local entry=soundVizActive[i]
        if entry then
            local age=now-entry.created
            if age < entry.duration then
                -- Fade out
                local alpha=1-(age/entry.duration)
                pcall(function()
                    d.Transparency=alpha*0.5
                    d.Visible=true
                end)
                table.insert(newDrawings,d)
                table.insert(newActive,entry)
            else
                pcall(function() d:Remove() end)
            end
        end
    end
    soundVizDrawings=newDrawings
    soundVizActive=newActive
end)

-- ══════════════════════════════════════════
--  BOOT  (animate window open)
-- ══════════════════════════════════════════
activateTab(tAimbot)
rebuildCrosshair()

Win.Size=UDim2.new(0,WIN_W*0.7,0,WIN_H*0.7)
Win.Position=UDim2.new(0.5,-WIN_W*0.35,0.5,-WIN_H*0.35)
TweenService:Create(Win,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.new(0,WIN_W,0,WIN_H),Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)}):Play()

print("╔═══════════════════════════════════════╗")
print("║   blueblur  v4.0  ULTIMATE  loaded ✓  ║")
print("╠═══════════════════════════════════════╣")
print("║  RShift=GUI | RMB=Aim | M=Map        ║")
print("║  B=BunnyHop | Click=Teleport         ║")
print("╚═══════════════════════════════════════╝")
print("Features: Aimbot | Combat | Sound Viz | All Extras")
print("Drawing:"..tostring(hasDrawing).." | MoveRel:"..tostring(hasMoveRel).." | HookMeta:"..tostring(hasHookMeta))
