-- ══════════════════════════════════════════════════════════════════
--  BlueBlur  v4.0  |  Ultimate Edition
--  LocalScript → StarterGui
--  RShift=GUI | RMB=Aim
-- ══════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local VirtualUser      = game:GetService("VirtualUser")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse     = Player:GetMouse()
local Camera    = workspace.CurrentCamera

-- ══════════════════════════════════════════
--  WHITELIST
-- ══════════════════════════════════════════
local NGROK_URL = "https://subventionary-letha-boughten.ngrok-free.dev"
local function CheckWhitelist()
    local response
    if getfenv().request then
        local ok,res=pcall(function()
            return request({Url=NGROK_URL.."/check?rbxid="..tostring(Player.UserId),
                Method="GET",Headers={["ngrok-skip-browser-warning"]="true"}})
        end)
        if ok and res and res.Body then response=res.Body end
    end
    if not response then
        local ok,res=pcall(function() return game:HttpGet(NGROK_URL.."/check?rbxid="..tostring(Player.UserId),true) end)
        if ok then response=res else warn("[BlueBlur] WL fail:",res); return false end
    end
    response=tostring(response):match("^%s*(.-)%s*$")
    return response=="valid"
end

-- ══════════════════════════════════════════
--  SPLASH
-- ══════════════════════════════════════════
local SplashGui=Instance.new("ScreenGui")
SplashGui.Name="BBSplash"; SplashGui.ResetOnSpawn=false
SplashGui.IgnoreGuiInset=true; SplashGui.DisplayOrder=999; SplashGui.Parent=PlayerGui

local SBG=Instance.new("Frame"); SBG.Size=UDim2.new(1,0,1,0)
SBG.BackgroundColor3=Color3.fromRGB(4,4,12); SBG.BorderSizePixel=0; SBG.Parent=SplashGui
for i=1,40 do
    local sl=Instance.new("Frame"); sl.Size=UDim2.new(1,0,0,1)
    sl.Position=UDim2.new(0,0,0,i*15); sl.BackgroundColor3=Color3.fromRGB(30,100,255)
    sl.BackgroundTransparency=0.95; sl.BorderSizePixel=0; sl.Parent=SBG
end

local SCard=Instance.new("Frame"); SCard.Size=UDim2.new(0,340,0,180)
SCard.AnchorPoint=Vector2.new(0.5,0.5); SCard.Position=UDim2.new(0.5,0,0.7,0)
SCard.BackgroundColor3=Color3.fromRGB(6,6,18); SCard.BorderSizePixel=0; SCard.Parent=SBG
Instance.new("UICorner",SCard).CornerRadius=UDim.new(0,14)
local SSt=Instance.new("UIStroke",SCard); SSt.Color=Color3.fromRGB(30,100,255); SSt.Thickness=2

local STL=Instance.new("TextLabel"); STL.Size=UDim2.new(1,0,0,34)
STL.Position=UDim2.new(0,0,0,18); STL.BackgroundTransparency=1; STL.Text="blueblur"
STL.TextColor3=Color3.fromRGB(80,150,255); STL.TextSize=28; STL.Font=Enum.Font.GothamBlack; STL.Parent=SCard

local SVL=Instance.new("TextLabel"); SVL.Size=UDim2.new(1,0,0,14)
SVL.Position=UDim2.new(0,0,0,50); SVL.BackgroundTransparency=1; SVL.Text="v4.0  —  ULTIMATE EDITION"
SVL.TextColor3=Color3.fromRGB(60,80,120); SVL.TextSize=11; SVL.Font=Enum.Font.GothamSemibold; SVL.Parent=SCard

local SSL=Instance.new("TextLabel"); SSL.Size=UDim2.new(1,-16,0,16)
SSL.Position=UDim2.new(0,8,0,80); SSL.BackgroundTransparency=1; SSL.Text="Verifying whitelist..."
SSL.TextColor3=Color3.fromRGB(90,110,160); SSL.TextSize=12; SSL.Font=Enum.Font.Gotham; SSL.Parent=SCard

local SBarBG=Instance.new("Frame"); SBarBG.Size=UDim2.new(1,-20,0,5)
SBarBG.Position=UDim2.new(0,10,1,-18); SBarBG.BackgroundColor3=Color3.fromRGB(15,20,55)
SBarBG.BorderSizePixel=0; SBarBG.Parent=SCard
Instance.new("UICorner",SBarBG).CornerRadius=UDim.new(1,0)
local SBar=Instance.new("Frame"); SBar.Size=UDim2.new(0,0,1,0)
SBar.BackgroundColor3=Color3.fromRGB(30,100,255); SBar.BorderSizePixel=0; SBar.Parent=SBarBG
Instance.new("UICorner",SBar).CornerRadius=UDim.new(1,0)

TweenService:Create(SCard,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,0,0.5,0)}):Play()
TweenService:Create(SBar,TweenInfo.new(1.4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{Size=UDim2.new(0.88,0,1,0)}):Play()
task.spawn(function()
    while SplashGui.Parent do
        TweenService:Create(SSt,TweenInfo.new(1),{Thickness=3,Color=Color3.fromRGB(60,130,255)}):Play(); task.wait(1)
        TweenService:Create(SSt,TweenInfo.new(1),{Thickness=1.5,Color=Color3.fromRGB(20,60,180)}):Play(); task.wait(1)
    end
end)

local granted=CheckWhitelist()
if not granted then
    SSL.Text="Not whitelisted."; SSL.TextColor3=Color3.fromRGB(220,80,80); SSt.Color=Color3.fromRGB(200,50,50)
    TweenService:Create(SBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(200,50,50)}):Play()
    task.wait(3); TweenService:Create(SBG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
    task.wait(0.4); SplashGui:Destroy(); return
end
SSL.Text="✅  Access granted!"; SSL.TextColor3=Color3.fromRGB(60,210,90)
TweenService:Create(SBar,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(40,200,80)}):Play()
task.wait(0.9); TweenService:Create(SBG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
task.wait(0.4); SplashGui:Destroy()

-- ══════════════════════════════════════════
--  CAPABILITY FLAGS
-- ══════════════════════════════════════════
local hasDrawing=false
pcall(function() local t=Drawing.new("Square"); t:Remove(); hasDrawing=true end)
local hasMoveRel     = not not getfenv().mousemoverel
local hasHookMeta    = not not (getfenv().hookmetamethod and getfenv().newcclosure
                        and getfenv().checkcaller and getfenv().getnamecallmethod)
local hasMouse1Click = not not getfenv().mouse1click

-- ══════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════
local C={
    BLUE      =Color3.fromRGB(30,100,255),
    BLUE_MID  =Color3.fromRGB(20,70,200),
    BLUE_DIM  =Color3.fromRGB(15,40,130),
    BLUE_DARK =Color3.fromRGB(8,15,55),
    BG        =Color3.fromRGB(10,10,16),    -- main window bg
    BG2       =Color3.fromRGB(14,14,22),    -- sidebar bg
    BG3       =Color3.fromRGB(18,18,28),    -- content bg
    BG4       =Color3.fromRGB(22,22,34),    -- hover
    LINE      =Color3.fromRGB(30,32,52),    -- dividers
    TEXT      =Color3.fromRGB(220,225,245),
    SUB       =Color3.fromRGB(110,115,145),
    DIM       =Color3.fromRGB(55,58,80),
    RED       =Color3.fromRGB(210,55,55),
    GREEN     =Color3.fromRGB(55,205,80),
    GOLD      =Color3.fromRGB(255,195,40),
    TEAL      =Color3.fromRGB(0,195,210),
}
local TF=TweenInfo.new(0.12,Enum.EasingStyle.Quad)

-- ══════════════════════════════════════════
--  AIMBOT STATE
-- ══════════════════════════════════════════
local Aim={
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

-- ══════════════════════════════════════════
--  GENERAL STATE
-- ══════════════════════════════════════════
local S={
    -- esp
    esp=false, espBoxes=true, espNames=true, espHealth=true,
    espTracers=false, espDistance=true, espChams=false,
    -- world
    fullbright=false, noFog=false, noShadows=false,
    -- movement
    flyEnabled=false, noclip=false, infiniteJump=false,
    speedBoost=false, walkSpeed=16, jumpPower=50,
    godMode=false, antiAfk=false, invisible=false,
    bunnyhop=false, autoSprint=false, sprintSpeed=28,
    thirdPerson=false, tpDistance=8,
    -- combat extras
    hitboxExpander=false, hitboxSize=6,
    antiLock=false, antiAimAngle=180,
    reachEnabled=false, reachAmount=20,
    fakelag=false, fakelagAmount=3,
    -- bullet range
    bulletRange=false, bulletRangeDist=9999, bulletRangeChance=100,
    -- teleport
    clickTp=false, antiVoid=false, voidHeight=-50,
    antiStomp=false, autoRejoin=false,
    -- visuals
    crosshair=false, crosshairStyle="Plus", crosshairSize=10,
    speedOverlay=false,
    -- minimap
    minimapEnabled=true, minimapRange=300,
}

local aimActive=false; local aimTarget=nil; local aimToggled=false
local savedSens=UserInputService.MouseDeltaSensitivity
local bv,bg; local tracerThickness=1

-- ══════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════
local CFG="blueblur_config_v4.json"
local function saveConfig()
    local d={}
    for k,v in S   do local t=type(v); if t=="boolean" or t=="number" or t=="string" then d[k]=v end end
    for k,v in Aim do local t=type(v); if t=="boolean" or t=="number" or t=="string" then d["a_"..k]=v end end
    pcall(function() writefile(CFG,HttpService:JSONEncode(d)) end)
end
local function loadConfig()
    local ok,raw=pcall(readfile,CFG); if not ok or not raw then return end
    local ok2,d=pcall(HttpService.JSONDecode,HttpService,raw); if not ok2 or type(d)~="table" then return end
    for k,v in d do
        if k:sub(1,2)=="a_" then local ak=k:sub(3); if Aim[ak]~=nil then Aim[ak]=v end
        elseif S[k]~=nil then S[k]=v end
    end
end
loadConfig()

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local function getHum() local c=Player.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getHRP() local c=Player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHead() local c=Player.Character; return c and c:FindFirstChild("Head") end
local function chance(p) return math.random(1,100)<=p end

local function isValidTarget(char)
    if not char or not char.Parent then return false end
    local plr=Players:GetPlayerFromCharacter(char); if not plr or plr==Player then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
    local myP=Player.Character and (Player.Character:FindFirstChild(Aim.aimPart) or Player.Character:FindFirstChild("HumanoidRootPart"))
    if not hum or not part or not myP then return false end
    if Aim.checkAlive  and hum.Health<=0 then return false end
    if Aim.checkGod    and (hum.Health>=1e36 or char:FindFirstChildOfClass("ForceField")) then return false end
    if Aim.checkTeam   and plr.TeamColor==Player.TeamColor then return false end
    if Aim.checkFriend and plr:IsFriendsWith(Player.UserId) then return false end
    if Aim.maxDist>0   and (part.Position-myP.Position).Magnitude>Aim.maxDist then return false end
    if Aim.fovEnabled then
        local sp,vis=Camera:WorldToViewportPoint(part.Position); if not vis then return false end
        local mp=UserInputService:GetMouseLocation()
        if (Vector2.new(sp.X,sp.Y)-mp).Magnitude>Aim.fovRadius then return false end
    end
    if Aim.checkWall then
        local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances={Player.Character}
        local res=workspace:Raycast(myP.Position,part.Position-myP.Position,rp)
        if not res or not res.Instance or not res.Instance:IsDescendantOf(char) then return false end
    end
    return true
end

local function findTarget()
    local best,bestD=nil,math.huge; local mp=UserInputService:GetMouseLocation()
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        if not isValidTarget(plr.Character) then continue end
        local part=plr.Character:FindFirstChild(Aim.aimPart) or plr.Character:FindFirstChild("Head")
        local sp,vis=Camera:WorldToViewportPoint(part.Position); if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
        if d<bestD then bestD=d; best=plr.Character end
    end
    return best
end

local function getAimPos(char)
    local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head"); if not part then return nil end
    local pos=part.Position
    if Aim.predictEnabled then
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then pos=pos+hrp.AssemblyLinearVelocity*Aim.predictAmount end
    end
    return pos
end

local function applyAim(char)
    local wp=getAimPos(char); if not wp then return end
    if Aim.mode=="Camera" then
        UserInputService.MouseDeltaSensitivity=0
        local goalCF=CFrame.lookAt(Camera.CFrame.Position,wp)
        if Aim.smoothEnabled then Camera.CFrame=Camera.CFrame:Lerp(goalCF,math.clamp(Aim.smoothAmount,0.01,1))
        else Camera.CFrame=goalCF end
    elseif Aim.mode=="Mouse" and hasMoveRel then
        local sp,vis=Camera:WorldToViewportPoint(wp); if not vis then return end
        local mp=UserInputService:GetMouseLocation()
        local sens=Aim.smoothEnabled and math.max(1,(1-Aim.smoothAmount)*20) or 1
        getfenv().mousemoverel((sp.X-mp.X)/sens,(sp.Y-mp.Y)/sens)
    end
end

-- ══════════════════════════════════════════
--  BULLET RANGE HELPER
-- ══════════════════════════════════════════
local function getBulletRangeTarget()
    if not S.bulletRange then return nil end
    if not hasHookMeta then return nil end
    if not chance(S.bulletRangeChance) then return nil end
    local best,bestD=nil,math.huge
    local myP=Player.Character and (Player.Character:FindFirstChild(Aim.aimPart) or Player.Character:FindFirstChild("HumanoidRootPart"))
    if not myP then return nil end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local part=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
        if not hum or not part then continue end
        if Aim.checkAlive  and hum.Health<=0 then continue end
        if Aim.checkGod    and (hum.Health>=1e36 or char:FindFirstChildOfClass("ForceField")) then continue end
        if Aim.checkTeam   and plr.TeamColor==Player.TeamColor then continue end
        if Aim.checkFriend and plr:IsFriendsWith(Player.UserId) then continue end
        local dist=(part.Position-myP.Position).Magnitude
        if dist>S.bulletRangeDist then continue end
        if Aim.checkWall then
            local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances={Player.Character}
            local res=workspace:Raycast(myP.Position,part.Position-myP.Position,rp)
            if not res or not res.Instance or not res.Instance:IsDescendantOf(char) then continue end
        end
        if dist<bestD then bestD=dist; best=char end
    end
    return best
end

-- ══════════════════════════════════════════
--  HOOKS (silent aim + bullet range)
-- ══════════════════════════════════════════
local function installHooks()
    if not hasHookMeta then return end

    local function getST()
        if not aimActive or Aim.mode~="Silent" then return nil end
        local char=aimTarget or findTarget(); if not isValidTarget(char) then return nil end
        if not chance(Aim.silentChance) then return nil end; return char
    end

    local oi; oi=hookmetamethod(game,"__index",newcclosure(function(self,key)
        if self==Mouse and not checkcaller() then
            local char=getST(); if char then
                local wp=getAimPos(char); if wp then
                    local sp=Camera:WorldToViewportPoint(wp)
                    if key=="Hit" or key=="hit" then
                        local p=char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
                        return CFrame.new(wp)*(p and CFrame.fromEulerAnglesYXZ(math.rad(p.Orientation.X),math.rad(p.Orientation.Y),math.rad(p.Orientation.Z)) or CFrame.identity)
                    elseif key=="Target" or key=="target" then return char:FindFirstChild(Aim.aimPart) or char:FindFirstChild("Head")
                    elseif key=="X" or key=="x" then return sp.X
                    elseif key=="Y" or key=="y" then return sp.Y end
                end end
        end; return oi(self,key)
    end))

    local on; on=hookmetamethod(game,"__namecall",newcclosure(function(...)
        local m=getnamecallmethod(); local a=table.pack(...); local s=a[1]
        if not checkcaller() then
            -- Silent aim
            local char=getST(); if char then
                local wp=getAimPos(char); if wp then
                    local sp=Camera:WorldToViewportPoint(wp)
                    if s==UserInputService and(m=="GetMouseLocation" or m=="getMouseLocation") then return Vector2.new(sp.X,sp.Y) end
                    if s==workspace and(m=="Raycast" or m=="raycast") and typeof(a[2])=="Vector3" and typeof(a[3])=="Vector3" then
                        a[3]=(wp-a[2]).Unit*(wp-a[2]).Magnitude; return on(table.unpack(a,1,a.n)) end
                end end
            -- Bullet range
            if S.bulletRange and(m=="FireServer" or m=="fireServer" or m=="InvokeServer" or m=="invokeServer") then
                local brChar=getBulletRangeTarget(); if brChar then
                    local brPart=brChar:FindFirstChild(Aim.aimPart) or brChar:FindFirstChild("Head")
                    if brPart then
                        local tPos=brPart.Position+Vector3.new(math.random(-5,5)*0.01,math.random(-5,5)*0.01,math.random(-5,5)*0.01)
                        for i=2,a.n do
                            if typeof(a[i])=="Vector3" then a[i]=tPos
                            elseif typeof(a[i])=="CFrame" then a[i]=CFrame.new(tPos)
                            elseif typeof(a[i])=="Instance" then
                                local ok,isB=pcall(function() return a[i]:IsA("BasePart") end)
                                if ok and isB then a[i]=brPart end
                            end
                        end
                        local ok,res=pcall(on,table.unpack(a,1,a.n)); return res
                    end
                end
            end
        end; return on(...)
    end))
end
pcall(installHooks)

UserInputService:GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
    if not aimActive then savedSens=UserInputService.MouseDeltaSensitivity end
end)

-- ══════════════════════════════════════════
--  AIM / BOT LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if aimTarget and not isValidTarget(aimTarget) then aimTarget=nil end
    if aimActive and Aim.enabled then
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
        aimToggled=not aimToggled; aimActive=aimToggled
        if not aimActive then aimTarget=nil end
    elseif Aim.keyMode=="OnePress" then
        local char=findTarget()
        if char then local wp=getAimPos(char); if wp then Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,wp) end end
    end
end
local function aimKeyUp()
    if Aim.keyMode=="Hold" then aimActive=false; aimTarget=nil; UserInputService.MouseDeltaSensitivity=savedSens end
end

-- ══════════════════════════════════════════
--  HITBOX / EXTRAS
-- ══════════════════════════════════════════
local function applyHitboxes(on)
    for _,plr in Players:GetPlayers() do if plr~=Player and plr.Character then
        local h=plr.Character:FindFirstChild("Head"); if h then
            h.Size=on and Vector3.new(S.hitboxSize,S.hitboxSize,S.hitboxSize) or Vector3.new(2,1,1) end end end
end
Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Connect(function(char) task.wait(1)
    if S.hitboxExpander then local h=char:FindFirstChild("Head"); if h then h.Size=Vector3.new(S.hitboxSize,S.hitboxSize,S.hitboxSize) end end
end) end)

local origMaxZoom=400
local function setThirdPerson(on)
    if on then origMaxZoom=Player.CameraMaxZoomDistance; Player.CameraMaxZoomDistance=S.tpDistance; Player.CameraMinZoomDistance=S.tpDistance
    else Player.CameraMaxZoomDistance=origMaxZoom; Player.CameraMinZoomDistance=0.5 end
end

-- ══════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════
local espObjects={}
local function nd(t,p) if not hasDrawing then return nil end
    local ok,obj=pcall(Drawing.new,t); if not ok then return nil end
    for k,v in p do pcall(function() obj[k]=v end) end; return obj end
local function hideD(d) if not d then return end
    for _,k in{"box","name","hpBg","hpFill","dist","tracer"} do if d[k] then pcall(function() d[k].Visible=false end) end end end
local function destroyD(d) if not d then return end
    for _,k in{"box","name","hpBg","hpFill","dist","tracer"} do if d[k] then pcall(function() d[k]:Remove() end) end end end
local function mkESP(plr)
    if not hasDrawing then return nil end
    if espObjects[plr] then return espObjects[plr] end
    local d={}
    d.box  =nd("Square",{Visible=false,Color=C.BLUE,Thickness=1,Filled=false,Transparency=1})
    d.name =nd("Text",  {Visible=false,Color=C.BLUE,Size=13,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    d.hpBg =nd("Square",{Visible=false,Color=Color3.fromRGB(20,20,25),Filled=true,Transparency=0.5,Thickness=1})
    d.hpFill=nd("Square",{Visible=false,Color=C.GREEN,Filled=true,Transparency=1,Thickness=1})
    d.dist =nd("Text",  {Visible=false,Color=C.SUB,Size=11,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=1,Font=Drawing.Fonts and Drawing.Fonts.UI or 0})
    d.tracer=nd("Line", {Visible=false,Color=C.BLUE,Thickness=tracerThickness,Transparency=1})
    espObjects[plr]=d; return d
end
local function updateESP(plr)
    local d=mkESP(plr); if not d then return end
    local char=plr.Character; if not char then hideD(d); return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); local head=char:FindFirstChild("Head"); local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideD(d); return end
    local topSP,vis=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,head.Size.Y/2+0.1,0))
    local botSP    =Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,hrp.Size.Y/2+0.3,0))
    local hrpSP    =Camera:WorldToViewportPoint(hrp.Position)
    if not vis then hideD(d); return end
    local bH=math.abs(botSP.Y-topSP.Y); local bW=bH*0.55; local bX=hrpSP.X-bW/2; local bY=topSP.Y
    local isTgt=(char==aimTarget); local col=isTgt and C.GOLD or C.BLUE
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    local hpC=Color3.fromRGB(math.round(255*(1-pct)),math.round(200*pct),0)
    local myH=getHead(); local dist=myH and math.round((head.Position-myH.Position).Magnitude) or 0
    if d.box then d.box.Visible=S.esp and S.espBoxes; if d.box.Visible then d.box.Position=Vector2.new(bX,bY); d.box.Size=Vector2.new(bW,bH); d.box.Color=col end end
    if d.name then d.name.Visible=S.esp and S.espNames; if d.name.Visible then d.name.Text=plr.DisplayName..(isTgt and " ◀" or ""); d.name.Position=Vector2.new(hrpSP.X,bY-15); d.name.Color=col end end
    local brW,brX=4,bX-7
    if d.hpBg   then d.hpBg.Visible=S.esp and S.espHealth; if d.hpBg.Visible then d.hpBg.Position=Vector2.new(brX,bY); d.hpBg.Size=Vector2.new(brW,bH) end end
    if d.hpFill then local fH=bH*pct; d.hpFill.Visible=S.esp and S.espHealth; if d.hpFill.Visible then d.hpFill.Position=Vector2.new(brX,bY+bH-fH); d.hpFill.Size=Vector2.new(brW,fH); d.hpFill.Color=hpC end end
    if d.dist   then d.dist.Visible=S.esp and S.espDistance; if d.dist.Visible then d.dist.Text=dist.."m"; d.dist.Position=Vector2.new(hrpSP.X,botSP.Y+2); d.dist.Color=col end end
    if d.tracer then local vp=Camera.ViewportSize; d.tracer.Visible=S.esp and S.espTracers; if d.tracer.Visible then d.tracer.From=Vector2.new(vp.X/2,vp.Y); d.tracer.To=Vector2.new(hrpSP.X,botSP.Y); d.tracer.Color=col end end
    if S.espChams and S.esp then for _,p in char:GetDescendants() do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Material=Enum.Material.Neon; p.Color=isTgt and C.GOLD or C.BLUE_MID end end end
end

-- ══════════════════════════════════════════
--  CROSSHAIR
-- ══════════════════════════════════════════
local crDrawings={}
local function rebuildCrosshair()
    for _,d in crDrawings do pcall(function() d:Remove() end) end; crDrawings={}
    if not S.crosshair or not hasDrawing then return end
    local sz=S.crosshairSize
    if S.crosshairStyle=="Plus" then
        for _,def in {{Vector2.new(-sz,0),Vector2.new(sz,0)},{Vector2.new(0,-sz),Vector2.new(0,sz)}} do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]; l.Color=C.BLUE; l.Thickness=1.5; l.Transparency=1; l.Visible=true; table.insert(crDrawings,l) end
    elseif S.crosshairStyle=="Dot" then
        local c=Drawing.new("Circle"); c.Radius=3; c.Color=C.BLUE; c.Filled=true; c.Transparency=1; c.Visible=true; table.insert(crDrawings,c)
    elseif S.crosshairStyle=="X" then
        for _,def in {{Vector2.new(-sz,-sz),Vector2.new(sz,sz)},{Vector2.new(sz,-sz),Vector2.new(-sz,sz)}} do
            local l=Drawing.new("Line"); l.From=def[1]; l.To=def[2]; l.Color=C.BLUE; l.Thickness=1.5; l.Transparency=1; l.Visible=true; table.insert(crDrawings,l) end
    end
end
RunService.RenderStepped:Connect(function()
    if not S.crosshair or not hasDrawing or #crDrawings==0 then return end
    local vp=Camera.ViewportSize; local cx,cy=vp.X/2,vp.Y/2; local s=S.crosshairSize
    if S.crosshairStyle=="Plus" and #crDrawings>=2 then
        crDrawings[1].From=Vector2.new(cx-s,cy); crDrawings[1].To=Vector2.new(cx+s,cy)
        crDrawings[2].From=Vector2.new(cx,cy-s); crDrawings[2].To=Vector2.new(cx,cy+s)
    elseif S.crosshairStyle=="X" and #crDrawings>=2 then
        crDrawings[1].From=Vector2.new(cx-s,cy-s); crDrawings[1].To=Vector2.new(cx+s,cy+s)
        crDrawings[2].From=Vector2.new(cx+s,cy-s); crDrawings[2].To=Vector2.new(cx-s,cy+s)
    elseif S.crosshairStyle=="Dot" and #crDrawings>=1 then
        crDrawings[1].Position=Vector2.new(cx,cy) end
end)

-- ══════════════════════════════════════════
--  MINIMAP
-- ══════════════════════════════════════════
local MM_SZ=180

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local SG=Instance.new("ScreenGui")
SG.Name=HttpService:GenerateGUID(false):sub(1,8)
SG.ResetOnSpawn=false; SG.IgnoreGuiInset=true
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=PlayerGui

-- FOV circle
local FovF=Instance.new("Frame"); FovF.BackgroundTransparency=1; FovF.BorderSizePixel=0
FovF.ZIndex=10; FovF.Visible=false; FovF.Parent=SG
Instance.new("UICorner",FovF).CornerRadius=UDim.new(1,0)
local FovStr=Instance.new("UIStroke"); FovStr.Color=C.BLUE; FovStr.Thickness=1.5; FovStr.Transparency=0.15; FovStr.Parent=FovF
RunService.RenderStepped:Connect(function()
    FovF.Visible=Aim.showFov and Aim.fovEnabled; if not FovF.Visible then return end
    local r=Aim.fovRadius; local ml=UserInputService:GetMouseLocation()
    FovF.Size=UDim2.new(0,r*2,0,r*2); FovF.Position=UDim2.new(0,ml.X-r,0,ml.Y-r)
end)

-- Minimap (top-right, draggable)
local MinimapFrame=Instance.new("Frame")
MinimapFrame.Size=UDim2.new(0,MM_SZ,0,MM_SZ)
MinimapFrame.Position=UDim2.new(1,-(MM_SZ+12),0,12)
MinimapFrame.BackgroundColor3=Color3.fromRGB(4,4,14); MinimapFrame.BorderSizePixel=0
MinimapFrame.ZIndex=5; MinimapFrame.Visible=S.minimapEnabled; MinimapFrame.Active=true; MinimapFrame.Parent=SG
Instance.new("UICorner",MinimapFrame).CornerRadius=UDim.new(1,0)
local mmStr=Instance.new("UIStroke",MinimapFrame); mmStr.Color=C.BLUE; mmStr.Thickness=2

-- Minimap draggable
local mmDrag,mmDS,mmDP=false,nil,nil
MinimapFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then mmDrag=true; mmDS=i.Position; mmDP=MinimapFrame.Position end end)
MinimapFrame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then mmDrag=false end end)
UserInputService.InputChanged:Connect(function(i)
    if mmDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-mmDS; MinimapFrame.Position=UDim2.new(mmDP.X.Scale,mmDP.X.Offset+d.X,mmDP.Y.Scale,mmDP.Y.Offset+d.Y) end end)

local mmClip=Instance.new("Frame"); mmClip.Size=UDim2.new(1,-4,1,-4); mmClip.Position=UDim2.new(0,2,0,2)
mmClip.BackgroundTransparency=1; mmClip.ClipsDescendants=true; mmClip.ZIndex=5; mmClip.Parent=MinimapFrame
Instance.new("UICorner",mmClip).CornerRadius=UDim.new(1,0)

for _,v in{true,false} do local l=Instance.new("Frame"); l.BackgroundColor3=Color3.fromRGB(30,60,140)
    l.BorderSizePixel=0; l.ZIndex=6; l.BackgroundTransparency=0.5; l.Parent=mmClip
    if v then l.Size=UDim2.new(0,1,1,0); l.Position=UDim2.new(0.5,0,0,0)
    else l.Size=UDim2.new(1,0,0,1); l.Position=UDim2.new(0,0,0.5,0) end end

for _,pct in{0.3,0.6,0.9} do
    local rs=(MM_SZ-4)*pct; local ring=Instance.new("Frame")
    ring.Size=UDim2.new(0,rs,0,rs); ring.Position=UDim2.new(0.5,-rs/2,0.5,-rs/2)
    ring.BackgroundTransparency=1; ring.BorderSizePixel=0; ring.ZIndex=6; ring.Parent=mmClip
    local st=Instance.new("UIStroke",ring); st.Color=Color3.fromRGB(30,70,160); st.Thickness=0.5; st.Transparency=0.5
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
end

local mmSelf=Instance.new("Frame"); mmSelf.Size=UDim2.new(0,8,0,8); mmSelf.AnchorPoint=Vector2.new(0.5,0.5)
mmSelf.Position=UDim2.new(0.5,0,0.5,0); mmSelf.BackgroundColor3=Color3.fromRGB(255,255,255)
mmSelf.BorderSizePixel=0; mmSelf.ZIndex=9; mmSelf.Parent=mmClip
Instance.new("UICorner",mmSelf).CornerRadius=UDim.new(1,0)

local mmLabel=Instance.new("TextLabel"); mmLabel.Size=UDim2.new(1,0,0,11)
mmLabel.Position=UDim2.new(0,0,1,3); mmLabel.BackgroundTransparency=1
mmLabel.Text="RADAR · "..S.minimapRange.."st"; mmLabel.TextColor3=C.DIM
mmLabel.TextSize=8; mmLabel.Font=Enum.Font.GothamBold; mmLabel.ZIndex=5; mmLabel.Parent=MinimapFrame

local mmDots={}
local function getMMDot(i)
    if mmDots[i] then return mmDots[i] end
    local d=Instance.new("Frame"); d.Size=UDim2.new(0,7,0,7); d.AnchorPoint=Vector2.new(0.5,0.5)
    d.BackgroundColor3=C.RED; d.BorderSizePixel=0; d.ZIndex=8; d.Visible=false; d.Parent=mmClip
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); mmDots[i]=d; return d
end

-- ══════════════════════════════════════════
--  MAIN WINDOW  (MangoGUI style)
-- ══════════════════════════════════════════
local WIN_W,WIN_H,SB_W=780,490,140
local Win=Instance.new("Frame"); Win.Name="BBWin"
Win.Size=UDim2.new(0,WIN_W,0,WIN_H); Win.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
Win.BackgroundColor3=C.BG; Win.BorderSizePixel=0; Win.Active=true; Win.Parent=SG
Instance.new("UIStroke",Win).Color=C.LINE

-- ── SIDEBAR ──
local Sidebar=Instance.new("Frame"); Sidebar.Size=UDim2.new(0,SB_W,1,0)
Sidebar.BackgroundColor3=C.BG2; Sidebar.BorderSizePixel=0; Sidebar.Parent=Win
local SideDiv=Instance.new("Frame"); SideDiv.Size=UDim2.new(0,1,1,0); SideDiv.Position=UDim2.new(1,-1,0,0)
SideDiv.BackgroundColor3=C.LINE; SideDiv.BorderSizePixel=0; SideDiv.Parent=Sidebar

-- Logo area (drag handle)
local LogoArea=Instance.new("Frame"); LogoArea.Size=UDim2.new(1,0,0,52)
LogoArea.BackgroundColor3=C.BG2; LogoArea.BorderSizePixel=0; LogoArea.Active=true; LogoArea.Parent=Sidebar
local LogoDiv=Instance.new("Frame"); LogoDiv.Size=UDim2.new(1,0,0,1); LogoDiv.Position=UDim2.new(0,0,1,0)
LogoDiv.BackgroundColor3=C.LINE; LogoDiv.BorderSizePixel=0; LogoDiv.Parent=LogoArea

-- Badge + name
local BadgeF=Instance.new("Frame"); BadgeF.Size=UDim2.new(0,28,0,28)
BadgeF.Position=UDim2.new(0,8,0.5,-14); BadgeF.BackgroundColor3=C.BLUE_DARK
BadgeF.BorderSizePixel=0; BadgeF.Parent=LogoArea
Instance.new("UICorner",BadgeF).CornerRadius=UDim.new(0,4)
Instance.new("UIStroke",BadgeF).Color=C.BLUE_MID
local BadgeTxt=Instance.new("TextLabel"); BadgeTxt.Size=UDim2.new(1,0,1,0); BadgeTxt.BackgroundTransparency=1
BadgeTxt.Text="B°"; BadgeTxt.TextColor3=C.BLUE; BadgeTxt.TextSize=11; BadgeTxt.Font=Enum.Font.GothamBlack; BadgeTxt.Parent=BadgeF

local NameLbl=Instance.new("TextLabel"); NameLbl.Size=UDim2.new(1,-46,0,16)
NameLbl.Position=UDim2.new(0,42,0.5,-18); NameLbl.BackgroundTransparency=1
NameLbl.Text="blueblur"; NameLbl.TextColor3=C.TEXT; NameLbl.TextSize=12; NameLbl.Font=Enum.Font.GothamBlack
NameLbl.TextXAlignment=Enum.TextXAlignment.Left; NameLbl.Parent=LogoArea

local VerLbl=Instance.new("TextLabel"); VerLbl.Size=UDim2.new(1,-46,0,11)
VerLbl.Position=UDim2.new(0,42,0.5,2); VerLbl.BackgroundTransparency=1
VerLbl.Text="v4.0  ultimate"; VerLbl.TextColor3=C.DIM; VerLbl.TextSize=8; VerLbl.Font=Enum.Font.Gotham
VerLbl.TextXAlignment=Enum.TextXAlignment.Left; VerLbl.Parent=LogoArea

-- Window controls
local CloseBtn=Instance.new("TextButton"); CloseBtn.Size=UDim2.new(0,16,0,16)
CloseBtn.Position=UDim2.new(1,-SB_W+6,0,8); CloseBtn.BackgroundTransparency=1
CloseBtn.Text="✕"; CloseBtn.TextColor3=C.DIM; CloseBtn.TextSize=11; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.BorderSizePixel=0; CloseBtn.ZIndex=5; CloseBtn.Parent=Win
CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3=C.RED end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3=C.DIM end)
CloseBtn.MouseButton1Click:Connect(function()
    saveConfig(); for _,d in espObjects do destroyD(d) end
    for _,d in crDrawings do pcall(function() d:Remove() end) end; SG:Destroy()
end)

local MinBtn=Instance.new("TextButton"); MinBtn.Size=UDim2.new(0,16,0,16)
MinBtn.Position=UDim2.new(1,-SB_W+24,0,8); MinBtn.BackgroundTransparency=1
MinBtn.Text="─"; MinBtn.TextColor3=C.DIM; MinBtn.TextSize=11; MinBtn.Font=Enum.Font.GothamBold
MinBtn.BorderSizePixel=0; MinBtn.ZIndex=5; MinBtn.Parent=Win
MinBtn.MouseEnter:Connect(function() MinBtn.TextColor3=C.TEXT end)
MinBtn.MouseLeave:Connect(function() MinBtn.TextColor3=C.DIM end)
local minimised=false
MinBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    Win.Size=minimised and UDim2.new(0,WIN_W,0,52) or UDim2.new(0,WIN_W,0,WIN_H)
    MinBtn.Text=minimised and "□" or "─"
end)

-- Drag
local drag,dS,dP=false,nil,nil
LogoArea.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; dS=i.Position; dP=Win.Position end end)
LogoArea.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dS; Win.Position=UDim2.new(dP.X.Scale,dP.X.Offset+d.X,dP.Y.Scale,dP.Y.Offset+d.Y) end end)

-- Nav scroll
local NavScroll=Instance.new("ScrollingFrame"); NavScroll.Size=UDim2.new(1,0,1,-53); NavScroll.Position=UDim2.new(0,0,0,53)
NavScroll.BackgroundTransparency=1; NavScroll.BorderSizePixel=0
NavScroll.ScrollBarThickness=0; NavScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
NavScroll.CanvasSize=UDim2.new(0,0,0,0); NavScroll.Parent=Sidebar
local NavLayout=Instance.new("UIListLayout"); NavLayout.SortOrder=Enum.SortOrder.LayoutOrder; NavLayout.Parent=NavScroll

-- Content area
local ContentArea=Instance.new("Frame"); ContentArea.Size=UDim2.new(1,-SB_W,1,0); ContentArea.Position=UDim2.new(0,SB_W,0,0)
ContentArea.BackgroundColor3=C.BG3; ContentArea.BorderSizePixel=0; ContentArea.Parent=Win

-- ══════════════════════════════════════════
--  PAGE / NAV SYSTEM  (MangoGUI style)
-- ══════════════════════════════════════════
local pages={}; local activePage=nil; local activeNavBtn=nil

local function makePage(id)
    local p=Instance.new("Frame"); p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1
    p.BorderSizePixel=0; p.Visible=false; p.Parent=ContentArea
    -- Two scrolling columns
    local c1=Instance.new("ScrollingFrame")
    c1.Size=UDim2.new(0.5,-1,1,0); c1.BackgroundTransparency=1; c1.BorderSizePixel=0
    c1.ScrollBarThickness=2; c1.ScrollBarImageColor3=C.BLUE_DIM
    c1.AutomaticCanvasSize=Enum.AutomaticSize.Y; c1.CanvasSize=UDim2.new(0,0,0,0); c1.Parent=p
    local l1=Instance.new("UIListLayout"); l1.SortOrder=Enum.SortOrder.LayoutOrder; l1.Padding=UDim.new(0,0); l1.Parent=c1
    local p1=Instance.new("UIPadding"); p1.PaddingLeft=UDim.new(0,14); p1.PaddingRight=UDim.new(0,10); p1.PaddingTop=UDim.new(0,10); p1.Parent=c1
    local div=Instance.new("Frame"); div.Size=UDim2.new(0,1,1,0); div.Position=UDim2.new(0.5,0,0,0)
    div.BackgroundColor3=C.LINE; div.BorderSizePixel=0; div.Parent=p
    local c2=Instance.new("ScrollingFrame")
    c2.Size=UDim2.new(0.5,-1,1,0); c2.Position=UDim2.new(0.5,1,0,0); c2.BackgroundTransparency=1; c2.BorderSizePixel=0
    c2.ScrollBarThickness=2; c2.ScrollBarImageColor3=C.BLUE_DIM
    c2.AutomaticCanvasSize=Enum.AutomaticSize.Y; c2.CanvasSize=UDim2.new(0,0,0,0); c2.Parent=p
    local l2=Instance.new("UIListLayout"); l2.SortOrder=Enum.SortOrder.LayoutOrder; l2.Padding=UDim.new(0,0); l2.Parent=c2
    local p2=Instance.new("UIPadding"); p2.PaddingLeft=UDim.new(0,14); p2.PaddingRight=UDim.new(0,10); p2.PaddingTop=UDim.new(0,10); p2.Parent=c2
    pages[id]={frame=p,c1=c1,c2=c2}; return c1,c2
end

local function showPage(id)
    if activePage then activePage.Visible=false end
    if pages[id] then activePage=pages[id].frame; activePage.Visible=true end
end

local navOrd=0
local function mkCatLabel(text)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,22)
    f.BackgroundTransparency=1; navOrd+=1; f.LayoutOrder=navOrd; f.Parent=NavScroll
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-12,1,0); lb.Position=UDim2.new(0,8,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextColor3=C.SUB; lb.TextSize=10; lb.Font=Enum.Font.GothamBold
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local ul=Instance.new("Frame"); ul.Size=UDim2.new(1,-16,0,1); ul.Position=UDim2.new(0,8,1,-1)
    ul.BackgroundColor3=C.LINE; ul.BorderSizePixel=0; ul.Parent=f
end

local firstNav=true
local function mkNavBtn(text,pageId)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20)
    f.BackgroundTransparency=1; navOrd+=1; f.LayoutOrder=navOrd; f.Parent=NavScroll
    local accent=Instance.new("Frame"); accent.Size=UDim2.new(0,2,0,11); accent.Position=UDim2.new(0,6,0.5,-5.5)
    accent.BackgroundColor3=C.BLUE; accent.BorderSizePixel=0; accent.Visible=false; accent.Parent=f
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-14,1,0); lb.Position=UDim2.new(0,12,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextSize=11
    lb.Font=firstNav and Enum.Font.GothamSemibold or Enum.Font.Gotham
    lb.TextColor3=firstNav and C.TEXT or C.DIM
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    if firstNav then accent.Visible=true; activeNavBtn={accent=accent,label=lb}; showPage(pageId); firstNav=false end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=f
    btn.MouseButton1Click:Connect(function()
        if activeNavBtn then activeNavBtn.accent.Visible=false; activeNavBtn.label.TextColor3=C.DIM; activeNavBtn.label.Font=Enum.Font.Gotham end
        accent.Visible=true; lb.TextColor3=C.TEXT; lb.Font=Enum.Font.GothamSemibold
        activeNavBtn={accent=accent,label=lb}; showPage(pageId)
    end)
    btn.MouseEnter:Connect(function() if activeNavBtn and activeNavBtn.label~=lb then lb.TextColor3=C.SUB end end)
    btn.MouseLeave:Connect(function() if activeNavBtn and activeNavBtn.label~=lb then lb.TextColor3=C.DIM end end)
end

local function mkNavSp(h)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,h or 4)
    f.BackgroundTransparency=1; navOrd+=1; f.LayoutOrder=navOrd; f.Parent=NavScroll
end

-- ══════════════════════════════════════════
--  COMPONENT BUILDERS  (MangoGUI style)
-- ══════════════════════════════════════════
local cOrd={}
local function nOrd(col) cOrd[col]=(cOrd[col] or 0)+1; return cOrd[col] end

-- Section header: "label ——————"
local function SH(col,text)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0,0,0,14); lb.AutomaticSize=Enum.AutomaticSize.X
    lb.Position=UDim2.new(0,0,0,6); lb.BackgroundTransparency=1; lb.Text=text
    lb.TextColor3=C.TEXT; lb.TextSize=11; lb.Font=Enum.Font.GothamBold
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local line=Instance.new("Frame"); line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.LINE; line.BorderSizePixel=0; line.Parent=f
end

-- Toggle with optional ⚙ icon
local function TG(col,text,def,gear,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,19); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    -- square checkbox
    local chk=Instance.new("Frame"); chk.Size=UDim2.new(0,10,0,10); chk.Position=UDim2.new(0,0,0.5,-5)
    chk.BackgroundColor3=def and C.BLUE or Color3.fromRGB(22,22,36); chk.BorderSizePixel=0; chk.Parent=f
    local chkS=Instance.new("UIStroke",chk); chkS.Color=def and C.BLUE or C.LINE; chkS.Thickness=1
    local tick=Instance.new("TextLabel"); tick.Size=UDim2.new(1,0,1,0); tick.BackgroundTransparency=1
    tick.Text="✓"; tick.TextColor3=Color3.new(1,1,1); tick.TextSize=7; tick.Font=Enum.Font.GothamBold
    tick.Visible=def; tick.Parent=chk
    -- label
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,gear and -18 or 0,1,0); lb.Position=UDim2.new(0,15,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextColor3=def and C.TEXT or C.SUB; lb.TextSize=11; lb.Font=Enum.Font.Gotham
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    if gear then
        local g=Instance.new("TextLabel"); g.Size=UDim2.new(0,14,1,0); g.Position=UDim2.new(1,-14,0,0)
        g.BackgroundTransparency=1; g.Text="⚙"; g.TextColor3=C.DIM; g.TextSize=11; g.Font=Enum.Font.Gotham; g.Parent=f
    end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=2; btn.Parent=f
    local st=def
    local function set(v)
        st=v; tick.Visible=v
        chk.BackgroundColor3=v and C.BLUE or Color3.fromRGB(22,22,36)
        chkS.Color=v and C.BLUE or C.LINE; lb.TextColor3=v and C.TEXT or C.SUB
        if cb then cb(v) end
    end
    btn.MouseButton1Click:Connect(function() set(not st) end)
    btn.MouseEnter:Connect(function() lb.TextColor3=C.TEXT end)
    btn.MouseLeave:Connect(function() lb.TextColor3=st and C.TEXT or C.SUB end)
    return f,set
end

-- Slider: "label | value ——bar——"
local function SLD(col,label,mn,mx,def,sfx,cb)
    sfx=sfx or ""
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,33); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local hdr=Instance.new("TextLabel"); hdr.Size=UDim2.new(1,0,0,13)
    hdr.BackgroundTransparency=1; hdr.TextColor3=C.SUB; hdr.TextSize=11; hdr.Font=Enum.Font.Gotham
    hdr.TextXAlignment=Enum.TextXAlignment.Left; hdr.Parent=f
    local function upH(v) hdr.Text=label.." | "..tostring(v)..sfx end; upH(def)
    local tr=Instance.new("Frame"); tr.Size=UDim2.new(1,0,0,3); tr.Position=UDim2.new(0,0,0,17)
    tr.BackgroundColor3=Color3.fromRGB(22,22,38); tr.BorderSizePixel=0; tr.Parent=f
    local p0=math.clamp((def-mn)/(mx-mn),0,1)
    local fl=Instance.new("Frame"); fl.Size=UDim2.new(p0,0,1,0); fl.BackgroundColor3=C.TEAL; fl.BorderSizePixel=0; fl.Parent=tr
    local kn=Instance.new("Frame"); kn.Size=UDim2.new(0,9,0,9); kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new(p0,0,0.5,0); kn.BackgroundColor3=Color3.new(1,1,1); kn.BorderSizePixel=0; kn.ZIndex=3; kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",kn).Color=C.TEAL
    local sd=false
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end end)
    RunService.RenderStepped:Connect(function()
        if not sd then return end
        local mp=UserInputService:GetMouseLocation()
        local p=math.clamp((mp.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.round(mn+p*(mx-mn)); fl.Size=UDim2.new(p,0,1,0); kn.Position=UDim2.new(p,0,0.5,0)
        upH(v); if cb then cb(v) end
    end)
end

-- Dropdown (click-cycle): "label | value ≡"
local function DD(col,label,opts,def,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,33); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,0,13); lb.BackgroundTransparency=1
    lb.Text=label; lb.TextColor3=C.SUB; lb.TextSize=11; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
    local vBg=Instance.new("Frame"); vBg.Size=UDim2.new(1,0,0,17); vBg.Position=UDim2.new(0,0,0,15)
    vBg.BackgroundColor3=Color3.fromRGB(16,16,28); vBg.BorderSizePixel=0; vBg.Parent=f
    Instance.new("UIStroke",vBg).Color=C.LINE
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(1,-18,1,0); vL.Position=UDim2.new(0,5,0,0)
    vL.BackgroundTransparency=1; vL.Text=def; vL.TextColor3=C.TEXT; vL.TextSize=11; vL.Font=Enum.Font.Gotham
    vL.TextXAlignment=Enum.TextXAlignment.Left; vL.Parent=vBg
    local arr=Instance.new("TextLabel"); arr.Size=UDim2.new(0,16,1,0); arr.Position=UDim2.new(1,-18,0,0)
    arr.BackgroundTransparency=1; arr.Text="≡"; arr.TextColor3=C.SUB; arr.TextSize=13; arr.Font=Enum.Font.GothamBold; arr.Parent=vBg
    local idx=1; for i,v in opts do if v==def then idx=i; break end end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,17); btn.Position=UDim2.new(0,0,0,15)
    btn.BackgroundTransparency=1; btn.Text=""; btn.ZIndex=2; btn.Parent=f
    btn.MouseButton1Click:Connect(function()
        idx=(idx%#opts)+1; vL.Text=opts[idx]
        TweenService:Create(vBg,TF,{BackgroundColor3=C.BLUE_DARK}):Play()
        task.delay(0.15,function() TweenService:Create(vBg,TF,{BackgroundColor3=Color3.fromRGB(16,16,28)}):Play() end)
        if cb then cb(opts[idx]) end
    end)
end

-- Info text
local function TL(col,text)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,14); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=text; lb.TextColor3=C.DIM; lb.TextSize=10; lb.Font=Enum.Font.Gotham
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
end

-- Spacer
local function SP(col,h)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,h or 6); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
end

-- Action button
local function AB(col,text,cb)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0)
    btn.BackgroundColor3=C.BLUE_DARK; btn.BorderSizePixel=0; btn.Text=text
    btn.TextColor3=C.TEXT; btn.TextSize=11; btn.Font=Enum.Font.GothamSemibold; btn.Parent=f
    Instance.new("UIStroke",btn).Color=C.BLUE_MID
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TF,{BackgroundColor3=C.BLUE_MID}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TF,{BackgroundColor3=C.BLUE_DARK}):Play() end)
    btn.MouseButton1Click:Connect(function()
        cb()
        TweenService:Create(btn,TF,{BackgroundColor3=C.BLUE}):Play()
        task.delay(0.4,function() TweenService:Create(btn,TF,{BackgroundColor3=C.BLUE_DARK}):Play() end)
    end)
end

-- Status badge
local function BADGE(col,text,ok)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,17); f.BackgroundTransparency=1
    f.LayoutOrder=nOrd(col); f.Parent=col
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,0,0.5,-3.5)
    dot.BackgroundColor3=ok and C.GREEN or C.RED; dot.BorderSizePixel=0; dot.Parent=f
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-12,1,0); lb.Position=UDim2.new(0,12,0,0)
    lb.BackgroundTransparency=1; lb.Text=text; lb.TextColor3=ok and C.TEXT or C.DIM
    lb.TextSize=11; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
end

-- ══════════════════════════════════════════
--  BUILD NAV + PAGES
-- ══════════════════════════════════════════
mkCatLabel("main")
mkNavBtn("| ragebot","ragebot")
mkNavBtn("  legitbot","legitbot")
mkNavSp()
mkCatLabel("visuals")
mkNavBtn("  players","players")
mkNavBtn("  world","world")
mkNavSp()
mkCatLabel("misc")
mkNavBtn("  movement","movement")
mkNavBtn("  configs","configs")
mkNavBtn("  addons","addons")

-- ─── RAGEBOT ───
local r1,r2=makePage("ragebot")
SH(r1,"general"); SP(r1,2)
TG(r1,"ragebot",false,false,function(on) Aim.enabled=on; if not on then aimActive=false; aimTarget=nil end end)
TG(r1,"auto fire",false,true,function(on) Aim.triggerEnabled=on end)
TG(r1,"spinbot",false,true,function(on) Aim.spinEnabled=on end)
TG(r1,"hitbox expander",false,true,function(on) S.hitboxExpander=on; applyHitboxes(on) end)
TG(r1,"bullet range",false,true,function(on) S.bulletRange=on end)
SP(r1,2)
DD(r1,"target hitbox",{"Head","HumanoidRootPart","Torso","UpperTorso"},"Head",function(v) Aim.aimPart=v; aimTarget=nil end)
SP(r1,2)
TG(r1,"prediction",false,true,function(on) Aim.predictEnabled=on end)
SLD(r1,"field of view",10,600,150,"px",function(v) Aim.fovRadius=v end)
SLD(r1,"fire chance",1,100,100,"%",function(v) Aim.triggerChance=v end)
SLD(r1,"smooth amount",1,100,25,"%",function(v) Aim.smoothAmount=v/100 end)
SLD(r1,"spin speed",1,100,50,"°",function(v) Aim.spinSpeed=v end)
SLD(r1,"hitbox size",2,20,6,"st",function(v) S.hitboxSize=v; if S.hitboxExpander then applyHitboxes(true) end end)
SP(r1,4)
SH(r1,"bullet range")
SP(r1,2)
SLD(r1,"max distance",100,9999,9999,"st",function(v) S.bulletRangeDist=v end)
SLD(r1,"hit chance",1,100,100,"%",function(v) S.bulletRangeChance=v end)
TL(r1,"intercepts FireServer/InvokeServer")
TL(r1,"redirects bullets to nearest enemy")
if not hasHookMeta then TL(r1,"⚠ hookmetamethod unavailable") end
SP(r1,4)
SH(r1,"visualization")
SP(r1,2)
TG(r1,"show fov circle",false,false,function(on) Aim.showFov=on end)
TG(r1,"fov check",false,false,function(on) Aim.fovEnabled=on end)
TG(r1,"smoothing",false,false,function(on) Aim.smoothEnabled=on end)

SH(r2,"anti"); SP(r2,2)
TG(r2,"silent aim",false,true,function(on) Aim.mode=on and "Silent" or "Camera" end)
TG(r2,"wall check",false,false,function(on) Aim.checkWall=on end)
TG(r2,"team check",false,false,function(on) Aim.checkTeam=on end)
TG(r2,"friend check",false,false,function(on) Aim.checkFriend=on end)
TG(r2,"alive check",true,false,function(on) Aim.checkAlive=on end)
TG(r2,"god mode check",false,false,function(on) Aim.checkGod=on end)
SLD(r2,"max aim dist",0,2000,1000,"st",function(v) Aim.maxDist=v end)
TL(r2,"0 = unlimited range")
SP(r2,5)
SH(r2,"utility"); SP(r2,2)
TG(r2,"god mode",false,false,function(on) S.godMode=on end)
TG(r2,"invisible",false,false,function(on)
    S.invisible=on; local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do if p:IsA("BasePart") then p.LocalTransparencyModifier=on and 1 or 0 end end end)
TG(r2,"anti-afk",false,false,function(on) S.antiAfk=on end)
TG(r2,"anti-void",false,false,function(on) S.antiVoid=on end)
TG(r2,"anti-stomp",false,false,function(on) S.antiStomp=on end)
TG(r2,"fake lag",false,false,function(on) S.fakelag=on end)
SLD(r2,"lag frames",1,20,3,"f",function(v) S.fakelagAmount=v end)
TG(r2,"auto rejoin on death",false,false,function(on) S.autoRejoin=on end)

-- ─── LEGITBOT ───
local l1,l2=makePage("legitbot")
SH(l1,"legitimate aim"); SP(l1,2)
DD(l1,"aim mode",{"Camera","Mouse","Silent"},"Camera",function(v) Aim.mode=v end)
DD(l1,"key mode",{"Hold","Toggle","OnePress"},"Hold",function(v) Aim.keyMode=v; aimActive=false; aimTarget=nil end)
TG(l1,"smoothing",false,true,function(on) Aim.smoothEnabled=on end)
SLD(l1,"smooth amount",1,100,25,"%",function(v) Aim.smoothAmount=v/100 end)
TG(l1,"prediction",false,true,function(on) Aim.predictEnabled=on end)
SLD(l1,"predict amount",1,30,8,"ms",function(v) Aim.predictAmount=v/100 end)
SP(l1,4)
SH(l1,"silent aim"); SP(l1,2)
if hasHookMeta then TL(l1,"✔ hooks installed") else TL(l1,"⚠ hookmetamethod unavailable") end
SLD(l1,"silent chance",1,100,100,"%",function(v) Aim.silentChance=v end)
TL(l1,"intercepted: Mouse.Hit, Target, X, Y")
TL(l1,"intercepted: GetMouseLocation, Raycast")

SH(l2,"fov"); SP(l2,2)
TG(l2,"fov enabled",false,false,function(on) Aim.fovEnabled=on end)
TG(l2,"show circle",false,false,function(on) Aim.showFov=on end)
SLD(l2,"fov radius",10,600,150,"px",function(v) Aim.fovRadius=v end)
SP(l2,5)
SH(l2,"executor status"); SP(l2,2)
BADGE(l2,"mousemoverel",hasMoveRel)
BADGE(l2,"hookmetamethod",hasHookMeta)
BADGE(l2,"mouse1click",hasMouse1Click)
BADGE(l2,"Drawing API",hasDrawing)

-- ─── PLAYERS (ESP) ───
local e1,e2=makePage("players")
SH(e1,"player esp"); SP(e1,2)
TG(e1,"esp enabled",false,false,function(on) S.esp=on; if not on then for _,d in espObjects do hideD(d) end end end)
TG(e1,"boxes",true,false,function(on) S.espBoxes=on end)
TG(e1,"names",true,false,function(on) S.espNames=on end)
TG(e1,"health bars",true,false,function(on) S.espHealth=on end)
TG(e1,"tracers",false,false,function(on) S.espTracers=on end)
TG(e1,"distance",true,false,function(on) S.espDistance=on end)
TG(e1,"chams",false,true,function(on) S.espChams=on
    if not on then for _,p in Players:GetPlayers() do if p~=Player and p.Character then
        for _,pt in p.Character:GetDescendants() do if pt:IsA("BasePart") then pt.Material=Enum.Material.SmoothPlastic end end end end end end)
if not hasDrawing then TL(e1,"⚠ Drawing API unavailable") end

SH(e2,"minimap"); SP(e2,2)
TG(e2,"show minimap",true,false,function(on) S.minimapEnabled=on; MinimapFrame.Visible=on end)
SLD(e2,"radar range",50,1000,300,"st",function(v) S.minimapRange=v; mmLabel.Text="RADAR · "..v.."st" end)
SP(e2,5)
SH(e2,"world lighting"); SP(e2,2)
TG(e2,"fullbright",false,false,function(on)
    S.fullbright=on; Lighting.Brightness=on and 10 or 1
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127) end)
TG(e2,"no fog",false,false,function(on)
    S.noFog=on; local a=Lighting:FindFirstChildOfClass("Atmosphere"); if a then a.Density=on and 0 or 0.395 end end)
TG(e2,"no shadows",false,false,function(on) S.noShadows=on; Lighting.GlobalShadows=not on end)

-- ─── WORLD ───
local w1,w2=makePage("world")
SH(w1,"crosshair"); SP(w1,2)
TG(w1,"custom crosshair",false,false,function(on) S.crosshair=on; rebuildCrosshair() end)
DD(w1,"style",{"Plus","Dot","X"},"Plus",function(v) S.crosshairStyle=v; rebuildCrosshair() end)
SLD(w1,"size",4,30,10,"px",function(v) S.crosshairSize=v; rebuildCrosshair() end)
SP(w1,4)
SH(w1,"click teleport"); SP(w1,2)
TG(w1,"enable click tp",false,false,function(on) S.clickTp=on end)
TL(w1,"click anywhere to tp there")
SP(w1,4)
SH(w1,"world esp (beta)"); SP(w1,2)
TL(w1,"highlights named workspace objects")
TL(w1,"chests, items, doors, objectives")

SH(w2,"speed overlay"); SP(w2,2)
TG(w2,"show speed",false,false,function(on) S.speedOverlay=on end)
SP(w2,5)
SH(w2,"third person"); SP(w2,2)
TG(w2,"third person",false,false,function(on) S.thirdPerson=on; setThirdPerson(on) end)
SLD(w2,"camera distance",3,30,8,"st",function(v) S.tpDistance=v; if S.thirdPerson then Player.CameraMaxZoomDistance=v; Player.CameraMinZoomDistance=v end end)

-- ─── MOVEMENT ───
local m1,m2=makePage("movement")
SH(m1,"locomotion"); SP(m1,2)
TG(m1,"fly",false,false,function(on)
    S.flyEnabled=on; local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
    if on then hum.PlatformStand=true
        bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
        bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=hrp
    else if bv then bv:Destroy();bv=nil end; if bg then bg:Destroy();bg=nil end; hum.PlatformStand=false end end)
TG(m1,"noclip",false,false,function(on) S.noclip=on end)
TG(m1,"infinite jump",false,false,function(on) S.infiniteJump=on end)
TG(m1,"bunny hop",false,false,function(on) S.bunnyhop=on end)
TG(m1,"auto sprint",false,false,function(on) S.autoSprint=on end)
TG(m1,"speed boost",false,false,function(on) S.speedBoost=on end)
SP(m1,4)
SLD(m1,"walk speed",8,200,16,"",function(v) S.walkSpeed=v end)
SLD(m1,"jump power",0,300,50,"",function(v) S.jumpPower=v end)
SLD(m1,"sprint speed",16,100,28,"",function(v) S.sprintSpeed=v end)

SH(m2,"keybinds"); SP(m2,2)
TL(m2,"RShift  →  toggle GUI")
TL(m2,"RMB     →  aimbot")
TL(m2,"LeftShift → sprint (fly: descend)")
TL(m2,"Space   →  fly ascend")
SP(m2,5)
SH(m2,"status"); SP(m2,2)
TL(m2,"Camera: moves cam to target")
TL(m2,"Mouse: uses mousemoverel")
TL(m2,"Silent: hooks mouse remotes")
TL(m2,"Bullet Range: hooks FireServer")

-- ─── CONFIGS ───
local cfg1,cfg2=makePage("configs")
SH(cfg1,"save & load"); SP(cfg1,2)
AB(cfg1,"💾  Save Config",function()
    saveConfig() end)
SP(cfg1,3)
AB(cfg1,"📂  Load Config",function()
    loadConfig() end)
SP(cfg1,4)
TL(cfg1,"file: blueblur_config_v4.json")
TL(cfg1,"auto-saves on gui close")

SH(cfg2,"executor"); SP(cfg2,2)
BADGE(cfg2,"Drawing API",hasDrawing)
BADGE(cfg2,"mousemoverel",hasMoveRel)
BADGE(cfg2,"hookmetamethod",hasHookMeta)
BADGE(cfg2,"mouse1click",hasMouse1Click)

-- ─── ADDONS ───
local a1,a2=makePage("addons")
SH(a1,"combat bots"); SP(a1,2)
TG(a1,"spinbot",false,true,function(on) Aim.spinEnabled=on end)
DD(a1,"spin part",{"HumanoidRootPart","Head"},"HumanoidRootPart",function(v) Aim.spinPart=v end)
SLD(a1,"spin speed",1,100,50,"°",function(v) Aim.spinSpeed=v end)
SP(a1,4)
SH(a1,"triggerbot"); SP(a1,2)
if hasMouse1Click then
    TG(a1,"enable triggerbot",false,true,function(on) Aim.triggerEnabled=on end)
    TG(a1,"smart (aiming only)",false,false,function(on) Aim.triggerSmartOnly=on end)
    SLD(a1,"trigger chance",1,100,100,"%",function(v) Aim.triggerChance=v end)
else
    TL(a1,"⚠ mouse1click unavailable")
end

SH(a2,"reach hack"); SP(a2,2)
TG(a2,"enable reach",false,false,function(on) S.reachEnabled=on end)
SLD(a2,"reach distance",1,100,20,"st",function(v) S.reachAmount=v end)
TL(a2,"extends tool/sword range")
SP(a2,4)
SH(a2,"anti-lock"); SP(a2,2)
TG(a2,"enable anti-lock",false,false,function(on) S.antiLock=on end)
SLD(a2,"spin angle",1,360,180,"°",function(v) S.antiAimAngle=v end)

-- ══════════════════════════════════════════
--  INDICATOR (bottom-left draggable panel)
-- ══════════════════════════════════════════
local IndicFrame=Instance.new("Frame"); IndicFrame.Size=UDim2.new(0,240,0,80)
IndicFrame.Position=UDim2.new(0,10,1,-94); IndicFrame.BackgroundColor3=C.BG2
IndicFrame.BackgroundTransparency=0.1; IndicFrame.BorderSizePixel=0; IndicFrame.Active=true; IndicFrame.Parent=SG
Instance.new("UIStroke",IndicFrame).Color=C.LINE
local IndicTitle=Instance.new("Frame"); IndicTitle.Size=UDim2.new(1,0,0,18)
IndicTitle.BackgroundColor3=C.BG; IndicTitle.BorderSizePixel=0; IndicTitle.Active=true; IndicTitle.Parent=IndicFrame
Instance.new("UIStroke",IndicTitle).Color=C.LINE
local IndicTitleLbl=Instance.new("TextLabel"); IndicTitleLbl.Size=UDim2.new(1,-26,1,0); IndicTitleLbl.Position=UDim2.new(0,8,0,0)
IndicTitleLbl.BackgroundTransparency=1; IndicTitleLbl.Text="— indicator"; IndicTitleLbl.TextColor3=C.DIM
IndicTitleLbl.TextSize=10; IndicTitleLbl.Font=Enum.Font.GothamSemibold; IndicTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; IndicTitleLbl.Parent=IndicTitle
local IndicClose=Instance.new("TextButton"); IndicClose.Size=UDim2.new(0,14,0,14)
IndicClose.Position=UDim2.new(1,-16,0.5,-7); IndicClose.BackgroundTransparency=1
IndicClose.Text="✕"; IndicClose.TextColor3=C.DIM; IndicClose.TextSize=9; IndicClose.Font=Enum.Font.GothamBold; IndicClose.Parent=IndicTitle
IndicClose.MouseButton1Click:Connect(function() IndicFrame.Visible=false end)

-- Drag indicator
local idDrag,idDS,idDP=false,nil,nil
IndicTitle.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then idDrag=true; idDS=i.Position; idDP=IndicFrame.Position end end)
IndicTitle.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then idDrag=false end end)
UserInputService.InputChanged:Connect(function(i)
    if idDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-idDS; IndicFrame.Position=UDim2.new(idDP.X.Scale,idDP.X.Offset+d.X,idDP.Y.Scale,idDP.Y.Offset+d.Y) end end)

-- Content inside indicator
local IndicContent=Instance.new("Frame"); IndicContent.Size=UDim2.new(1,0,1,-18); IndicContent.Position=UDim2.new(0,0,0,18)
IndicContent.BackgroundTransparency=1; IndicContent.Parent=IndicFrame

local IndicAvatar=Instance.new("Frame"); IndicAvatar.Size=UDim2.new(0,42,0,42)
IndicAvatar.Position=UDim2.new(0,8,0.5,-21); IndicAvatar.BackgroundColor3=C.BLUE_DARK
IndicAvatar.BorderSizePixel=0; IndicAvatar.Parent=IndicContent
Instance.new("UICorner",IndicAvatar).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",IndicAvatar).Color=C.BLUE_MID
local IndicAvatarLbl=Instance.new("TextLabel"); IndicAvatarLbl.Size=UDim2.new(1,0,1,0)
IndicAvatarLbl.BackgroundTransparency=1; IndicAvatarLbl.Text="👤"; IndicAvatarLbl.TextSize=18; IndicAvatarLbl.Parent=IndicAvatar

local IndicName=Instance.new("TextLabel"); IndicName.Size=UDim2.new(1,-62,0,16)
IndicName.Position=UDim2.new(0,58,0,4); IndicName.BackgroundTransparency=1
IndicName.Text=Player.DisplayName.." (@"..Player.Name..")"; IndicName.TextColor3=C.TEXT
IndicName.TextSize=11; IndicName.Font=Enum.Font.GothamBold; IndicName.TextXAlignment=Enum.TextXAlignment.Left; IndicName.Parent=IndicContent

local IndicStatus=Instance.new("TextLabel"); IndicStatus.Size=UDim2.new(1,-62,0,12)
IndicStatus.Position=UDim2.new(0,58,0,22); IndicStatus.BackgroundTransparency=1
IndicStatus.Text="0 studs"; IndicStatus.TextColor3=C.DIM
IndicStatus.TextSize=10; IndicStatus.Font=Enum.Font.Gotham; IndicStatus.TextXAlignment=Enum.TextXAlignment.Left; IndicStatus.Parent=IndicContent

-- HP bar in indicator
local IndicHpLabel=Instance.new("TextLabel"); IndicHpLabel.Size=UDim2.new(1,-62,0,11)
IndicHpLabel.Position=UDim2.new(0,58,0,36); IndicHpLabel.BackgroundTransparency=1
IndicHpLabel.Text="Armor"; IndicHpLabel.TextColor3=C.DIM
IndicHpLabel.TextSize=9; IndicHpLabel.Font=Enum.Font.Gotham; IndicHpLabel.TextXAlignment=Enum.TextXAlignment.Left; IndicHpLabel.Parent=IndicContent

local IndicHpBg=Instance.new("Frame"); IndicHpBg.Size=UDim2.new(1,-62,0,8)
IndicHpBg.Position=UDim2.new(0,58,0,47); IndicHpBg.BackgroundColor3=Color3.fromRGB(22,22,38); IndicHpBg.BorderSizePixel=0; IndicHpBg.Parent=IndicContent
local IndicHpFill=Instance.new("Frame"); IndicHpFill.Size=UDim2.new(1,0,1,0)
IndicHpFill.BackgroundColor3=C.GREEN; IndicHpFill.BorderSizePixel=0; IndicHpFill.Parent=IndicHpBg
local IndicHpVal=Instance.new("TextLabel"); IndicHpVal.Size=UDim2.new(1,0,1,0)
IndicHpVal.BackgroundTransparency=1; IndicHpVal.Text="100/100"; IndicHpVal.TextColor3=Color3.new(1,1,1)
IndicHpVal.TextSize=8; IndicHpVal.Font=Enum.Font.GothamBold; IndicHpVal.Parent=IndicHpBg

-- Update indicator every heartbeat
RunService.Heartbeat:Connect(function()
    local hrp=getHRP(); local hum=getHum()
    if hrp then IndicStatus.Text=math.round((hrp.Position-Vector3.new(0,hrp.Position.Y,0)).Magnitude).." studs" end
    if hum then
        local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
        IndicHpFill.Size=UDim2.new(pct,0,1,0)
        IndicHpFill.BackgroundColor3=Color3.fromRGB(math.round(255*(1-pct)),math.round(200*pct),0)
        IndicHpVal.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
        IndicHpLabel.Text="Health"
    end
end)

-- ══════════════════════════════════════════
--  SPEED OVERLAY
-- ══════════════════════════════════════════
local speedDraw=nil
RunService.RenderStepped:Connect(function()
    if S.speedOverlay and hasDrawing then
        if not speedDraw then
            speedDraw=Drawing.new("Text"); speedDraw.Size=15; speedDraw.Font=Drawing.Fonts.UI
            speedDraw.Color=C.BLUE; speedDraw.Outline=true; speedDraw.OutlineColor=Color3.new(0,0,0)
            speedDraw.Position=Vector2.new(10,60); speedDraw.Visible=true
        end
        local hum=getHum(); if hum then speedDraw.Text="speed: "..math.floor(hum.WalkSpeed) end
    elseif speedDraw then speedDraw:Remove(); speedDraw=nil end
end)

-- ══════════════════════════════════════════
--  INPUT
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible; return end
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

-- Click teleport
Mouse.Button1Down:Connect(function()
    if S.clickTp and Mouse.Target then
        local hrp=getHRP()
        if hrp then
            local pos=Mouse.Target.Position
            hrp.CFrame=CFrame.new(pos.X,pos.Y+hrp.Size.Y/2+0.5,pos.Z)
        end
    end
end)

-- ══════════════════════════════════════════
--  RUNTIME LOOPS
-- ══════════════════════════════════════════

-- Fly
RunService.RenderStepped:Connect(function()
    if not S.flyEnabled or not bv or not bg then return end
    local cam=Camera; local dir=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir+=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir-=cam.CFrame.LookVector  end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir-=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir+=cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0)     end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0)     end
    bv.Velocity=dir*60; bg.CFrame=cam.CFrame
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not S.noclip then return end
    local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end
end)

-- Speed / God / Jump
RunService.Heartbeat:Connect(function()
    local hum=getHum(); if not hum then return end
    if S.godMode then hum.Health=hum.MaxHealth end
    if S.speedBoost then hum.WalkSpeed=80
    elseif S.autoSprint and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not S.flyEnabled then
        hum.WalkSpeed=S.sprintSpeed
    else hum.WalkSpeed=S.walkSpeed end
    hum.JumpPower=S.jumpPower
    if S.bunnyhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    if S.antiVoid then
        local hrp=getHRP()
        if hrp and hrp.Position.Y < -50 then hrp.CFrame=CFrame.new(hrp.Position.X,-50+5,hrp.Position.Z) end
    end
    if S.antiStomp then
        local hrp=getHRP()
        if hrp and hrp.AssemblyLinearVelocity.Y < -50 then
            hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z) end
    end
    if S.fakelag then
        local hrp=getHRP(); if not hrp then return end
        local orig=hrp.CFrame
        for _=1,S.fakelagAmount do hrp.CFrame=orig*CFrame.new(math.random(-1,1)*0.5,0,math.random(-1,1)*0.5) end
        hrp.CFrame=orig
    end
    if S.antiLock then
        local hrp=getHRP(); if hrp then
            hrp.CFrame=hrp.CFrame*CFrame.fromEulerAnglesXYZ(0,math.rad(S.antiAimAngle),0) end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not S.infiniteJump then return end
    local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

Player.Idled:Connect(function()
    if not S.antiAfk then return end
    VirtualUser:Button2Down(Vector2.zero,Camera.CFrame); task.wait(0.1); VirtualUser:Button2Up(Vector2.zero,Camera.CFrame)
end)

-- Auto-rejoin
local function setupAutoRejoin()
    Player.CharacterAdded:Connect(function(char)
        local hum=char:WaitForChild("Humanoid",10); if not hum then return end
        hum.Died:Connect(function()
            if S.autoRejoin then task.wait(3); pcall(function() TeleportService:Teleport(game.PlaceId,Player) end) end
        end)
    end)
end
setupAutoRejoin()

-- ESP loop
RunService.RenderStepped:Connect(function()
    for plr in espObjects do if not plr or not plr.Parent then destroyD(espObjects[plr]); espObjects[plr]=nil end end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        if not S.esp then if espObjects[plr] then hideD(espObjects[plr]) end; continue end
        updateESP(plr)
    end
end)

-- Minimap loop
RunService.RenderStepped:Connect(function()
    MinimapFrame.Visible=S.minimapEnabled
    if not S.minimapEnabled then return end
    local selfHRP=getHRP(); if not selfHRP then return end
    local selfPos=selfHRP.Position; local _,camY,_=Camera.CFrame:ToEulerAnglesYXZ()
    local targetPlr=aimTarget and Players:GetPlayerFromCharacter(aimTarget)
    local dotIdx=0
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local char=plr.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then continue end
        dotIdx+=1; local dot=getMMDot(dotIdx); dot.Visible=true
        local offset=hrp.Position-selfPos
        local rx=offset.X*math.cos(camY)+offset.Z*math.sin(camY)
        local rz=-offset.X*math.sin(camY)+offset.Z*math.cos(camY)
        dot.Position=UDim2.new(0.5,math.clamp(rx/S.minimapRange,-0.9,0.9)*(MM_SZ/2-4),
                                0.5,math.clamp(rz/S.minimapRange,-0.9,0.9)*(MM_SZ/2-4))
        if plr==targetPlr then dot.BackgroundColor3=C.GOLD
        else local ok1,mt=pcall(function() return Player.Team end); local ok2,pt=pcall(function() return plr.Team end)
            dot.BackgroundColor3=(ok1 and ok2 and mt and pt and mt==pt) and C.GREEN or C.RED end
    end
    for i=dotIdx+1,#mmDots do mmDots[i].Visible=false end
end)

-- ══════════════════════════════════════════
--  PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then destroyD(espObjects[plr]); espObjects[plr]=nil end
end)

Player.CharacterAdded:Connect(function()
    S.flyEnabled=false; bv=nil; bg=nil
    aimActive=false; aimTarget=nil
    UserInputService.MouseDeltaSensitivity=savedSens
    Camera.CameraType=Enum.CameraType.Custom
    if S.thirdPerson then task.wait(1); setThirdPerson(true) end
end)

game:BindToClose(function()
    saveConfig()
    for _,d in espObjects do destroyD(d) end
    for _,d in crDrawings do pcall(function() d:Remove() end) end
end)

-- ══════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════
rebuildCrosshair()
print("╔══════════════════════════════════════╗")
print("║   blueblur  v4.0  ULTIMATE  ✓        ║")
print("╠══════════════════════════════════════╣")
print("║  RShift=GUI | RMB=Aim | B=Bunny      ║")
print("╚══════════════════════════════════════╝")
