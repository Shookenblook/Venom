-- ╔══════════════════════════════════════════════════════════╗
-- ║       Venom.lol v3.0 — Open Aimbot Merge Edition        ║
-- ║  LocalScript → StarterGui                                ║
-- ║  Every Open Aimbot function integrated + full bypass     ║
-- ╚══════════════════════════════════════════════════════════╝

-- ══════════════════════════════════════════
-- [0] BYPASS CORE — runs FIRST
-- ══════════════════════════════════════════
local _rawPrint = print
local _rawWarn  = warn
print = function() end
warn  = function() end
error = function() end

local function safeExec(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function randBetween(a, b) return a + math.random() * (b - a) end
local function jitterWait(base, pct)
    pct = pct or 0.25
    task.wait(base * randBetween(1 - pct, 1 + pct))
end
local function jitterLoop(base, pct, cb)
    task.spawn(function()
        while true do jitterWait(base, pct); safeExec(cb) end
    end)
end
local function cycleConnection(ivl, cb)
    local conn
    local function connect()
        conn = game:GetService("RunService").RenderStepped:Connect(function() safeExec(cb) end)
    end
    connect()
    task.spawn(function()
        while true do
            task.wait(randBetween(ivl * 0.8, ivl * 1.2))
            if conn then conn:Disconnect() end
            task.wait(randBetween(0.01, 0.05))
            connect()
        end
    end)
end
local function rampProp(getObj, prop, target)
    task.spawn(function()
        local obj = getObj(); if not obj then return end
        local sv  = obj[prop]
        local steps = math.random(8,14)
        for i = 1, steps do
            jitterWait(0.04, 0.3)
            obj = getObj(); if not obj then return end
            local t = i/steps
            local e = t < 0.5 and 2*t*t or 1-(-2*t+2)^2/2
            obj[prop] = sv + (target-sv)*e
        end
    end)
end

-- Executor capability flags
local HAS_HOOK_META  = type(hookmetamethod)    == "function"
local HAS_GET_NCALL  = type(getnamecallmethod) == "function"
local HAS_NEWCC      = type(newcclosure)       == "function"
local HAS_CHECKER    = type(checkcaller)       == "function"
local HAS_HOOKFN     = type(hookfunction)      == "function"
local HAS_CLONE      = type(clonefunction)     == "function"
local HAS_MOVEREL    = type(mousemoverel)      == "function"
local HAS_M1CLICK    = type(mouse1click)       == "function"
local HAS_DRAWING    = false
pcall(function() local t=Drawing.new("Square"); t:Remove(); HAS_DRAWING=true end)

-- ══════════════════════════════════════════
-- [1] SERVICES
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
local Camera    = workspace.CurrentCamera
local IsComputer = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

-- ══════════════════════════════════════════
-- [2] THEME
-- ══════════════════════════════════════════
local PURPLE      = Color3.fromRGB(138,43,226)
local PURPLE_DIM  = Color3.fromRGB(90,20,160)
local PURPLE_DARK = Color3.fromRGB(40,10,70)
local BG          = Color3.fromRGB(8,8,12)
local BG2         = Color3.fromRGB(14,14,20)
local BG3         = Color3.fromRGB(20,20,30)
local TEXT        = Color3.fromRGB(220,220,230)
local SUBTEXT     = Color3.fromRGB(130,120,150)
local RED         = Color3.fromRGB(200,50,50)
local GREEN       = Color3.fromRGB(50,220,100)
local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
local CONFIG_FILE = string.format("venom_%s.json", game.GameId)

-- ══════════════════════════════════════════
-- [3] MATH HANDLER (from Open Aimbot)
-- ══════════════════════════════════════════
local MathHandler = {}

function MathHandler:CalcDir(origin, pos, mag)
    return typeof(origin)=="Vector3" and typeof(pos)=="Vector3"
        and (pos-origin).Unit * mag or Vector3.zero
end

function MathHandler:CalcChance(pct)
    return typeof(pct)=="number"
        and math.round(math.clamp(pct,1,100))/100
            >= math.round(Random.new():NextNumber()*100)/100
end

function MathHandler:Abbreviate(n)
    if type(n) ~= "number" then return tostring(n) end
    local abbrs = {T=1e12,B=1e9,M=1e6,K=1e3}
    for k,v in abbrs do
        if math.abs(n) >= v then return math.round(n/v)..k end
    end
    return tostring(math.round(n))
end

function MathHandler:GetPlayerName(str)
    if typeof(str)=="string" and #str>0 then
        for _, plr in Players:GetPlayers() do
            if string.sub(string.lower(plr.Name),1,#string.lower(str))==string.lower(str) then
                return plr.Name
            end
        end
    end
    return ""
end

-- ══════════════════════════════════════════
-- [4] STATE  (merged Venom + Open Aimbot)
-- ══════════════════════════════════════════
local state = {
    -- Aimbot
    aimEnabled=false, aimMode="Camera", aimKey="RMB",
    onePressAim=false, aimPart="Head", randomAimPart=false,
    offAfterKill=false, silentChance=100,
    silentMethods={"Mouse.Hit / Mouse.Target","GetMouseLocation","Raycast"},
    useOffset=false, offsetType="Static", staticOffset=10,
    dynamicOffset=10, autoOffset=false, maxAutoOffset=50,
    useSensitivity=false, sensitivity=50,
    useNoise=false, noiseFrequency=50,
    -- Camlock
    camlockEnabled=false, camlockKeybind="Q", camlockToggle=false,
    camlockPart="Head", useAdvanced=false, smoothingOn=false,
    predictX=0, predictY=0, smoothX=5, smoothY=5, camlockStyle="Linear",
    -- Checks — Player (Venom + Open Aimbot)
    aliveCheck=false, godCheck=false, teamCheck=false, friendCheck=false,
    followCheck=false, verifiedBadgeCheck=false,
    wallCheck=false, waterCheck=false,
    -- Checks — Distance
    fovCheck=false, fovRadius=100,
    magnitudeCheck=false, triggerMagnitude=500,
    -- Checks — Advanced (Open Aimbot)
    transparencyCheck=false, ignoredTransparency=0.5,
    whitelistGroupCheck=false, whitelistGroup=0,
    blacklistGroupCheck=false, blacklistGroup=0,
    -- Checks — Expert (Open Aimbot)
    ignoredPlayersCheck=false, ignoredPlayers={},
    targetPlayersCheck=false, targetPlayers={},
    -- Bots
    spinBot=false, spinKey="T", onePressSpinning=false,
    spinVelocity=50, spinPart="HumanoidRootPart", randomSpinPart=false,
    triggerBot=false, triggerKey="E", onePressTrigger=false,
    smartTrigger=false, triggerChance=100,
    -- Visuals
    fovVisible=false, fovKey="R", fovThickness=2, fovOpacity=0.8,
    fovFilled=false, fovColor=Color3.fromRGB(255,255,255),
    espEnabled=false, espKey="Z", espBoxes=true, espNames=true,
    espHealth=true, espMagnitude=false, espTracers=false,
    espThickness=2, espOpacity=0.8,
    espColor=Color3.fromRGB(138,43,226), useTeamColor=false,
    rainbowVisuals=false, rainbowDelay=5,
    chams=false, espBoxFilled=false,
    fullbright=false, noFog=false, noShadows=false,
    -- Movement
    flyEnabled=false, noclip=false, infiniteJump=false,
    speedBoost=false, walkSpeed=16, jumpPower=50,
    godMode=false, antiAfk=false, invisible=false,
    sprintEnabled=false, sprintSpeed=28,
    -- Addons
    crosshair=false, crosshairStyle="Plus", crosshairSize=10,
    hitmarker=false, clickTp=false, minimap=true,
    -- Rendering
    renderMode="RenderStepped",
}

-- ══════════════════════════════════════════
-- [5] CONFIG SAVE / LOAD  (game-ID keyed)
-- ══════════════════════════════════════════
local function saveConfig()
    safeExec(function()
        local data = {}
        for k,v in state do
            local t=type(v)
            if t=="boolean" or t=="number" or t=="string" then data[k]=v
            elseif t=="table" then data[k]=v end
        end
        if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end
    end)
end

local function loadConfig()
    safeExec(function()
        if not (isfile and readfile) then return end
        if not isfile(CONFIG_FILE) then return end
        local raw = readfile(CONFIG_FILE)
        if not raw then return end
        local ok,data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(data)~="table" then return end
        for k,v in data do if state[k]~=nil then state[k]=v end end
    end)
end
loadConfig()

-- ══════════════════════════════════════════
-- [6] RUNTIME FIELDS
-- ══════════════════════════════════════════
local Aiming         = false
local Target         = nil
local AimTween       = nil
local Spinning       = false
local Triggering     = false
local ShowFov        = state.fovVisible
local ShowESP        = state.espEnabled
local MouseSens      = UserInputService.MouseDeltaSensitivity
local Clock          = os.clock()
local stickyTarget   = nil
local RobloxActive   = true
local bv, bg
local jumpCooldown   = false
local camlockState   = false
local oldNamecall    = nil
local oldIndex       = nil

-- Camera ownership (prevents aimbot/camlock fighting)
local cameraOwner = "none"
local function claimCamera(owner)
    cameraOwner = owner
    Camera.CameraType = Enum.CameraType.Scriptable
end
local function releaseCamera(owner)
    if cameraOwner == owner then
        cameraOwner = "none"
        Camera.CameraType = Enum.CameraType.Custom
    end
end

-- ══════════════════════════════════════════
-- [7] HELPERS
-- ══════════════════════════════════════════
local function getHum()
    local c=Player.Character; return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c=Player.Character; return c and c:FindFirstChild("HumanoidRootPart")
end
local function getClosestInFOV()
    local closest,closestD=nil,math.huge
    for _,plr in Players:GetPlayers() do
        if plr~=Player and plr.Character then
            local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local sp,onScreen=Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                    local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if dist<state.fovRadius and dist<closestD then
                        closestD=dist; closest=plr
                    end
                end
            end
        end
    end
    return closest
end

-- ══════════════════════════════════════════
-- [8] IS_READY  (full Open Aimbot merge)
-- ══════════════════════════════════════════
local function IsReady(tgt)
    if not tgt then return false end
    local hum  = tgt:FindFirstChildOfClass("Humanoid")
    local aimP = tgt:FindFirstChild(state.aimPart)
    if not hum or not aimP or not aimP:IsA("BasePart") then return false end
    if not Player.Character then return false end
    local nativeP = Player.Character:FindFirstChild(state.aimPart)
    if not nativeP or not nativeP:IsA("BasePart") then return false end
    local plr = Players:GetPlayerFromCharacter(tgt)
    if not plr or plr==Player then return false end
    local head = tgt:FindFirstChild("Head")

    -- ── checks ──
    if state.aliveCheck       and hum.Health==0                                             then return false end
    if state.godCheck         and (hum.Health>=1e36 or tgt:FindFirstChildOfClass("ForceField")) then return false end
    if state.teamCheck        and plr.TeamColor==Player.TeamColor                           then return false end
    if state.friendCheck      and plr:IsFriendsWith(Player.UserId)                         then return false end
    if state.followCheck      and plr.FollowUserId==Player.UserId                          then return false end
    if state.verifiedBadgeCheck and plr.HasVerifiedBadge                                   then return false end
    if state.transparencyCheck and head and head:IsA("BasePart")
        and head.Transparency >= state.ignoredTransparency                                  then return false end
    if state.whitelistGroupCheck and plr:IsInGroup(state.whitelistGroup)                   then return false end
    if state.blacklistGroupCheck and not plr:IsInGroup(state.blacklistGroup)               then return false end
    if state.ignoredPlayersCheck and table.find(state.ignoredPlayers, plr.Name)            then return false end
    if state.targetPlayersCheck  and not table.find(state.targetPlayers, plr.Name)         then return false end

    if state.wallCheck then
        local rp=RaycastParams.new()
        rp.FilterType=Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances={Player.Character}
        rp.IgnoreWater = not state.waterCheck
        local dir=MathHandler:CalcDir(nativeP.Position,aimP.Position,(aimP.Position-nativeP.Position).Magnitude)
        local res=workspace:Raycast(nativeP.Position,dir,rp)
        if not res or not res.Instance or not res.Instance:FindFirstAncestor(plr.Name) then return false end
    end
    if state.magnitudeCheck and (aimP.Position-nativeP.Position).Magnitude>state.triggerMagnitude then return false end

    -- ── offset + noise ──
    local noise = state.useNoise and Vector3.new(
        Random.new():NextNumber(-state.noiseFrequency/100, state.noiseFrequency/100),
        Random.new():NextNumber(-state.noiseFrequency/100, state.noiseFrequency/100),
        Random.new():NextNumber(-state.noiseFrequency/100, state.noiseFrequency/100)
    ) or Vector3.zero

    local offset = Vector3.zero
    if state.useOffset then
        local moveDir=(hum and hum.MoveDirection or Vector3.zero)
        local dist=(aimP.Position-nativeP.Position).Magnitude
        if state.autoOffset then
            local auto=aimP.Position.Y*state.staticOffset*dist/1000
            auto = math.min(auto, state.maxAutoOffset)
            offset=Vector3.new(0,auto,0)+moveDir*state.dynamicOffset/10
        elseif state.offsetType=="Static" then
            offset=Vector3.new(0,aimP.Position.Y*state.staticOffset/10,0)
        elseif state.offsetType=="Dynamic" then
            offset=moveDir*state.dynamicOffset/10
        else
            offset=Vector3.new(0,aimP.Position.Y*state.staticOffset/10,0)+moveDir*state.dynamicOffset/10
        end
    end

    local finalPos = aimP.Position + offset + noise
    local vpPos,vis = Camera:WorldToViewportPoint(finalPos)
    local dist = (finalPos-nativeP.Position).Magnitude
    local cf = CFrame.new(finalPos)*CFrame.fromEulerAnglesYXZ(
        math.rad(aimP.Orientation.X),math.rad(aimP.Orientation.Y),math.rad(aimP.Orientation.Z))
    return true, tgt, {vpPos,vis}, finalPos, dist, cf, aimP
end

-- ══════════════════════════════════════════
-- [9] VALID ARGUMENTS  (Open Aimbot)
-- ══════════════════════════════════════════
local ValidArgs = {
    Raycast                    ={Required=3,Arguments={"Instance","Vector3","Vector3","RaycastParams"}},
    FindPartOnRay              ={Required=2,Arguments={"Instance","Ray","Instance","boolean","boolean"}},
    FindPartOnRayWithIgnoreList={Required=3,Arguments={"Instance","Ray","table","boolean","boolean"}},
    FindPartOnRayWithWhitelist ={Required=3,Arguments={"Instance","Ray","table","boolean"}},
}
local function validateArgs(args,method)
    if type(args)~="table" or type(method)~="table" or #args<method.Required then return false end
    local m=0
    for i,a in args do if typeof(a)==method.Arguments[i] then m+=1 end end
    return m>=method.Required
end

-- ══════════════════════════════════════════
-- [10] BYPASS: __index hook (Mouse.Hit/Target)
-- ══════════════════════════════════════════
--  Wrapped in newcclosure + checkcaller guard + delayed install
if HAS_HOOK_META then
    task.delay(randBetween(1.5,3.5), function()
        safeExec(function()
            local innerIdx = function(self, idx)
                if HAS_CHECKER and not checkcaller() then
                    if state.aimMode=="Silent" and Aiming and IsReady(Target) and select(3,IsReady(Target))[2]
                        and MathHandler:CalcChance(state.silentChance) and self==Mouse then
                        if idx=="Hit"     or idx=="hit"     then return select(6,IsReady(Target)) end
                        if idx=="Target"  or idx=="target"  then return select(7,IsReady(Target)) end
                        if idx=="X"       or idx=="x"       then return select(3,IsReady(Target))[1].X end
                        if idx=="Y"       or idx=="y"       then return select(3,IsReady(Target))[1].Y end
                        if idx=="UnitRay" or idx=="unitRay" then
                            return Ray.new(self.Origin,(select(6,IsReady(Target))-self.Origin).Unit)
                        end
                    end
                end
                return oldIndex(self,idx)
            end
            local hookFn = HAS_NEWCC and newcclosure(innerIdx) or innerIdx
            oldIndex = hookmetamethod(game,"__index",hookFn)
            if HAS_CLONE then oldIndex=clonefunction(oldIndex) end
        end)
    end)
end

-- ══════════════════════════════════════════
-- [11] BYPASS: __namecall hook (Silent Aim)
-- ══════════════════════════════════════════
--  Layers: newcclosure + checkcaller + delayed install + clonefunction
--  Fallback: hookfunction on individual RemoteEvents

local function buildAimArgs(args)
    if not MathHandler:CalcChance(state.silentChance) then return args end
    local target=getClosestInFOV()
    if not target or not target.Character then return args end
    local hrp=target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return args end
    local jPos=hrp.Position+Vector3.new(
        randBetween(-0.12,0.12), randBetween(-0.10,0.10), randBetween(-0.04,0.04))
    for i=1,args.n do
        if typeof(args[i])=="Vector3" then args[i]=jPos
        elseif typeof(args[i])=="Instance" then
            local ok,isBase=pcall(function() return args[i]:IsA("BasePart") end)
            if ok and isBase then args[i]=hrp end
        end
    end
    return args
end

task.delay(randBetween(2.0,5.0), function()
    safeExec(function()
        if HAS_HOOK_META and HAS_GET_NCALL then
            local innerNC = function(self,...)
                if HAS_CHECKER and not checkcaller() then
                    local method = getnamecallmethod()
                    local args   = table.pack(...)
                    if state.aimMode=="Silent" and Aiming and IsReady(Target) and select(3,IsReady(Target))[2] then
                        local sm = state.silentMethods
                        -- GetMouseLocation
                        if table.find(sm,"GetMouseLocation") and self==UserInputService
                            and (method=="GetMouseLocation" or method=="getMouseLocation") then
                            local vp=select(3,IsReady(Target))[1]
                            return Vector2.new(vp.X,vp.Y)
                        end
                        -- Raycast
                        if table.find(sm,"Raycast") and self==workspace
                            and (string.lower(method)=="raycast") and validateArgs(args,ValidArgs.Raycast) then
                            args[3]=MathHandler:CalcDir(args[2],select(4,IsReady(Target)),select(5,IsReady(Target)))
                            local ok,r=pcall(oldNamecall,self,table.unpack(args,1,args.n)); return r
                        end
                        -- FindPartOnRay
                        for _,mn in {"FindPartOnRay","FindPartOnRayWithIgnoreList","FindPartOnRayWithWhitelist"} do
                            if table.find(sm,mn) and self==workspace and string.lower(method)==string.lower(mn)
                                and validateArgs(args,ValidArgs[mn]) then
                                args[2]=Ray.new(args[2].Origin,MathHandler:CalcDir(args[2].Origin,select(4,IsReady(Target)),select(5,IsReady(Target))))
                                local ok,r=pcall(oldNamecall,self,table.unpack(args,1,args.n)); return r
                            end
                        end
                        -- FireServer
                        if method=="FireServer" then
                            args=buildAimArgs(args)
                            local ok,r=pcall(oldNamecall,self,table.unpack(args,1,args.n)); return r
                        end
                    end
                end
                return oldNamecall(self,...)
            end
            local hookFn = HAS_NEWCC and newcclosure(innerNC) or innerNC
            oldNamecall  = hookmetamethod(game,"__namecall",hookFn)
            if HAS_CLONE then oldNamecall=clonefunction(oldNamecall) end

        elseif HAS_HOOKFN then
            -- Fallback: hook FireServer on each RemoteEvent directly
            local function hookRemote(remote)
                safeExec(function()
                    local orig=remote.FireServer
                    if HAS_CLONE then orig=clonefunction(orig) end
                    local patched=function(s,...)
                        if not state.aimMode=="Silent" then return orig(s,...) end
                        local args=buildAimArgs(table.pack(...))
                        return orig(s,table.unpack(args,1,args.n))
                    end
                    if HAS_NEWCC then patched=newcclosure(patched) end
                    hookfunction(orig,patched)
                end)
            end
            for _,d in game:GetDescendants() do
                if d:IsA("RemoteEvent") then hookRemote(d) end
            end
            game.DescendantAdded:Connect(function(d)
                if d:IsA("RemoteEvent") then task.delay(randBetween(0.1,0.3),function() hookRemote(d) end) end
            end)
        end
    end)
end)

-- ══════════════════════════════════════════
-- [12] BYPASS: God Mode
-- ══════════════════════════════════════════
jitterLoop(0.08, 0.5, function()
    if not state.godMode then return end
    if math.random()<0.06 then return end
    local hum=getHum()
    if hum then hum.Health=hum.MaxHealth-randBetween(0.001,0.08) end
end)

-- ══════════════════════════════════════════
-- [13] BYPASS: Noclip
-- ══════════════════════════════════════════
jitterLoop(0.03, 0.4, function()
    if not state.noclip then return end
    local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- ══════════════════════════════════════════
-- [14] BYPASS: Infinite Jump
-- ══════════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if not state.infiniteJump or jumpCooldown then return end
    safeExec(function()
        local hum=getHum(); if not hum then return end
        local st=hum:GetState()
        if st==Enum.HumanoidStateType.Freefall or st==Enum.HumanoidStateType.Jumping then
            jumpCooldown=true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.delay(randBetween(0.06,0.13), function() jumpCooldown=false end)
        end
    end)
end)

-- ══════════════════════════════════════════
-- [15] BYPASS: Anti-AFK (proactive loop)
-- ══════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(randBetween(50,85))
        if state.antiAfk then
            safeExec(function()
                local cam=workspace.CurrentCamera
                if math.random()>0.5 then
                    VirtualUser:Button2Down(Vector2.zero, cam.CFrame)
                    task.wait(randBetween(0.04,0.18))
                    VirtualUser:Button2Up(Vector2.zero, cam.CFrame)
                else
                    VirtualUser:MoveMouse(Vector2.new(math.random(-2,2),math.random(-2,2)))
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════════
-- [16] FLY  (bypassed BodyVelocity)
-- ══════════════════════════════════════════
local function setFly(on)
    state.flyEnabled=on
    local hrp=getHRP(); local hum=getHum()
    if not hrp or not hum then return end
    if on then
        safeExec(function()
            hum.PlatformStand=true
            bv=Instance.new("BodyVelocity")
            bv.Name=HttpService:GenerateGUID(false):sub(1,7)
            bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=hrp
            bg=Instance.new("BodyGyro")
            bg.Name=HttpService:GenerateGUID(false):sub(1,7)
            bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=hrp
        end)
    else
        safeExec(function()
            if bv then bv:Destroy(); bv=nil end
            if bg then bg:Destroy(); bg=nil end
            hum.PlatformStand=false
        end)
    end
end

cycleConnection(12, function()
    if not state.flyEnabled or not bv or not bg then return end
    local cam=workspace.CurrentCamera; local dir=Vector3.zero
    local UIS=UserInputService
    if UIS:IsKeyDown(Enum.KeyCode.W)         then dir+=cam.CFrame.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.S)         then dir-=cam.CFrame.LookVector  end
    if UIS:IsKeyDown(Enum.KeyCode.A)         then dir-=cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D)         then dir+=cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0)     end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) and not state.sprintEnabled then
        dir-=Vector3.new(0,1,0)
    end
    local n=Vector3.new(randBetween(-0.03,0.03),randBetween(-0.03,0.03),randBetween(-0.03,0.03))
    local mf=1e5+randBetween(-500,500)
    bv.Velocity=dir*60+n; bv.MaxForce=Vector3.new(mf,mf,mf); bg.CFrame=cam.CFrame
end)

-- ══════════════════════════════════════════
-- [17] SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = HttpService:GenerateGUID(false):sub(1,8)
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = PlayerGui

-- ══════════════════════════════════════════
-- [18] FOV DRAWING
-- ══════════════════════════════════════════
local FovDraw = nil
local function updateFovDraw()
    if not HAS_DRAWING then return end
    if not FovDraw then
        FovDraw = Drawing.new("Circle")
        FovDraw.Visible=false; FovDraw.ZIndex=4; FovDraw.NumSides=64
        FovDraw.Radius=state.fovRadius; FovDraw.Thickness=state.fovThickness
        FovDraw.Transparency=state.fovOpacity; FovDraw.Filled=state.fovFilled
        FovDraw.Color=state.fovColor
    end
    local ml=UserInputService:GetMouseLocation()
    safeExec(function()
        FovDraw.Position=Vector2.new(ml.X,ml.Y); FovDraw.Radius=state.fovRadius
        FovDraw.Thickness=state.fovThickness; FovDraw.Transparency=state.fovOpacity
        FovDraw.Filled=state.fovFilled; FovDraw.Color=state.fovColor
        FovDraw.Visible=ShowFov
    end)
end

-- ══════════════════════════════════════════
-- [19] ESP  (Drawing API, proper health bars)
-- ══════════════════════════════════════════
local espObjects = {}

local function espColor(plr)
    if state.rainbowVisuals then
        return Color3.fromHSV(os.clock()%state.rainbowDelay/state.rainbowDelay,1,1)
    end
    if state.useTeamColor and plr and plr.TeamColor then return plr.TeamColor.Color end
    return state.espColor
end

local function getOrCreateESP(plr)
    if not HAS_DRAWING then return nil end
    if espObjects[plr] then return espObjects[plr] end
    local function nd(objType,props)
        local ok,obj=pcall(Drawing.new,objType); if not ok then return nil end
        for k,v in props do pcall(function() obj[k]=v end) end; return obj
    end
    local d={}
    d.box      = nd("Square",{Visible=false,Color=PURPLE,Thickness=state.espThickness,Filled=state.espBoxFilled,Transparency=state.espOpacity})
    d.name     = nd("Text",{Visible=false,Color=PURPLE,Size=13,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=state.espOpacity})
    d.hpBarBG  = nd("Square",{Visible=false,Color=Color3.fromRGB(20,20,20),Filled=true,Transparency=0.5,Thickness=1})
    d.hpBarFill= nd("Square",{Visible=false,Color=Color3.fromRGB(80,255,80),Filled=true,Transparency=state.espOpacity,Thickness=1})
    d.health   = nd("Text",{Visible=false,Color=Color3.fromRGB(80,255,80),Size=11,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=state.espOpacity})
    d.magnitude= nd("Text",{Visible=false,Color=PURPLE,Size=11,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Transparency=state.espOpacity})
    d.tracer   = nd("Line",{Visible=false,Color=PURPLE,Thickness=state.espThickness,Transparency=state.espOpacity})
    espObjects[plr]=d; return d
end

local function hideESP(d)
    if not d then return end
    for _,k in {"box","name","hpBarBG","hpBarFill","health","magnitude","tracer"} do
        if d[k] then safeExec(function() d[k].Visible=false end) end
    end
end

local function destroyESP(d)
    if not d then return end
    for _,k in {"box","name","hpBarBG","hpBarFill","health","magnitude","tracer"} do
        if d[k] then safeExec(function() d[k]:Remove() end) end
    end
end

local function updateESP(plr)
    local d=getOrCreateESP(plr); if not d then return end
    local char=plr.Character
    if not char then hideESP(d); return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not hum then hideESP(d); return end

    local topWP=head.Position+Vector3.new(0,head.Size.Y/2+0.1,0)
    local botWP=hrp.Position-Vector3.new(0,hrp.Size.Y/2+0.3,0)
    local topSP,vis=Camera:WorldToViewportPoint(topWP)
    local botSP=Camera:WorldToViewportPoint(botWP)
    local hrpSP=Camera:WorldToViewportPoint(hrp.Position)
    if not vis then hideESP(d); return end

    local boxH=math.abs(botSP.Y-topSP.Y)
    local boxW=boxH*0.55
    local boxX=hrpSP.X-boxW/2
    local boxY=topSP.Y
    local col=espColor(plr)
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    local hpCol=Color3.fromRGB(math.round(255*(1-pct)),math.round(200*pct),0)
    local myHead=Player.Character and Player.Character:FindFirstChild("Head")
    local dist=myHead and math.round((head.Position-myHead.Position).Magnitude) or 0

    if d.box then
        d.box.Visible=ShowESP and state.espBoxes; d.box.Position=Vector2.new(boxX,boxY)
        d.box.Size=Vector2.new(boxW,boxH); d.box.Color=col
        d.box.Thickness=math.max(1,state.espThickness); d.box.Transparency=state.espOpacity
        d.box.Filled=state.espBoxFilled
    end
    local barW,barX=4,boxX-6
    if d.hpBarBG then
        d.hpBarBG.Visible=ShowESP and state.espHealth
        d.hpBarBG.Position=Vector2.new(barX,boxY); d.hpBarBG.Size=Vector2.new(barW,boxH)
    end
    if d.hpBarFill then
        local fH=boxH*pct
        d.hpBarFill.Visible=ShowESP and state.espHealth
        d.hpBarFill.Position=Vector2.new(barX,boxY+boxH-fH)
        d.hpBarFill.Size=Vector2.new(barW,fH); d.hpBarFill.Color=hpCol
    end
    if d.name then
        local isTarget=Aiming and Target and Target==char
        d.name.Visible=ShowESP and state.espNames
        d.name.Text=isTarget and ("🎯"..plr.DisplayName) or plr.DisplayName
        d.name.Position=Vector2.new(hrpSP.X,boxY-16); d.name.Color=col
    end
    if d.health then
        d.health.Visible=ShowESP and state.espHealth
        d.health.Text=string.format("%d/%d HP",math.floor(hum.Health),math.floor(hum.MaxHealth))
        d.health.Position=Vector2.new(hrpSP.X,boxY-28); d.health.Color=hpCol
    end
    if d.magnitude then
        d.magnitude.Visible=ShowESP and state.espMagnitude
        d.magnitude.Text=string.format("[%sm]", MathHandler:Abbreviate(dist))
        d.magnitude.Position=Vector2.new(hrpSP.X,botSP.Y+2); d.magnitude.Color=col
    end
    if d.tracer then
        local vp=Camera.ViewportSize
        d.tracer.Visible=ShowESP and state.espTracers
        d.tracer.From=Vector2.new(vp.X/2,vp.Y)
        d.tracer.To=Vector2.new(hrpSP.X,botSP.Y); d.tracer.Color=col
    end
    if state.chams and ShowESP then
        for _,p in char:GetDescendants() do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Material=Enum.Material.Neon; p.Color=PURPLE_DIM
            end
        end
    end
end

-- ══════════════════════════════════════════
-- [20] CROSSHAIR
-- ══════════════════════════════════════════
local crosshairParts={}
local function buildCrosshair()
    for _,p in crosshairParts do safeExec(function() p:Destroy() end) end
    crosshairParts={}
    if not state.crosshair then return end
    local s=state.crosshairSize; local col=PURPLE
    local defs={
        Plus  ={{UDim2.new(0,-s,0,-1),UDim2.new(0,s*2,0,2)},{UDim2.new(0,-1,0,-s),UDim2.new(0,2,0,s*2)}},
        Dot   ={{UDim2.new(0,-3,0,-3),UDim2.new(0,6,0,6)}},
        Circle={},
    }
    for _,ln in (defs[state.crosshairStyle] or defs.Plus) do
        local f=Instance.new("Frame"); f.BackgroundColor3=col; f.BorderSizePixel=0
        f.AnchorPoint=Vector2.new(0.5,0.5)
        f.Position=UDim2.new(0.5,0,0.5,0)+ln[1]; f.Size=ln[2]; f.ZIndex=20; f.Parent=ScreenGui
        if state.crosshairStyle=="Dot" then Instance.new("UICorner",f).CornerRadius=UDim.new(1,0) end
        table.insert(crosshairParts,f)
    end
    if state.crosshairStyle=="Circle" then
        local f=Instance.new("Frame"); f.BackgroundTransparency=1; f.BorderSizePixel=0
        f.AnchorPoint=Vector2.new(0.5,0.5); f.Position=UDim2.new(0.5,0,0.5,0)
        f.Size=UDim2.new(0,s*2,0,s*2); f.ZIndex=20; f.Parent=ScreenGui
        Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
        local st=Instance.new("UIStroke"); st.Color=col; st.Thickness=1.5; st.Parent=f
        table.insert(crosshairParts,f)
    end
end

-- ══════════════════════════════════════════
-- [21] HITMARKER
-- ══════════════════════════════════════════
local hitFrames={}; local lastHealths={}
local function showHitmarker()
    if not state.hitmarker then return end
    for _,f in hitFrames do safeExec(function() f:Destroy() end) end; hitFrames={}
    local vp=Camera.ViewportSize; local cx,cy=vp.X/2,vp.Y/2
    for _,angle in {-45,45} do
        local f=Instance.new("Frame"); f.BackgroundColor3=Color3.fromRGB(255,80,80)
        f.BorderSizePixel=0; f.AnchorPoint=Vector2.new(0.5,0.5)
        f.Size=UDim2.new(0,12,0,2); f.Position=UDim2.new(0,cx,0,cy)
        f.Rotation=angle; f.ZIndex=25; f.Parent=ScreenGui
        table.insert(hitFrames,f)
    end
    task.delay(0.15,function()
        for _,f in hitFrames do safeExec(function() f:Destroy() end) end; hitFrames={}
    end)
end

RunService.Heartbeat:Connect(function()
    if not state.hitmarker then return end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        local hum=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local prev=lastHealths[plr] or hum.Health
            if hum.Health<prev then showHitmarker() end
            lastHealths[plr]=hum.Health
        end
    end
end)

-- ══════════════════════════════════════════
-- [22] MINIMAP
-- ══════════════════════════════════════════
local MinimapFrame=Instance.new("Frame")
MinimapFrame.Size=UDim2.new(0,160,0,160); MinimapFrame.Position=UDim2.new(1,-170,1,-170)
MinimapFrame.BackgroundColor3=Color3.fromRGB(10,10,15); MinimapFrame.BorderSizePixel=0
MinimapFrame.ZIndex=15; MinimapFrame.Visible=state.minimap; MinimapFrame.Parent=ScreenGui
Instance.new("UICorner",MinimapFrame).CornerRadius=UDim.new(0,8)
local mmStroke=Instance.new("UIStroke"); mmStroke.Color=PURPLE; mmStroke.Thickness=1; mmStroke.Parent=MinimapFrame
local mmLbl=Instance.new("TextLabel"); mmLbl.Size=UDim2.new(1,0,0,16)
mmLbl.BackgroundTransparency=1; mmLbl.Text="MINIMAP"; mmLbl.TextColor3=PURPLE
mmLbl.TextSize=9; mmLbl.Font=Enum.Font.GothamBold; mmLbl.ZIndex=16; mmLbl.Parent=MinimapFrame
local mmArea=Instance.new("Frame"); mmArea.Size=UDim2.new(1,-6,1,-20); mmArea.Position=UDim2.new(0,3,0,17)
mmArea.BackgroundColor3=Color3.fromRGB(18,18,28); mmArea.BorderSizePixel=0; mmArea.ZIndex=16
mmArea.ClipsDescendants=true; mmArea.Parent=MinimapFrame
Instance.new("UICorner",mmArea).CornerRadius=UDim.new(0,4)
local selfDot=Instance.new("Frame"); selfDot.Size=UDim2.new(0,6,0,6); selfDot.AnchorPoint=Vector2.new(0.5,0.5)
selfDot.BackgroundColor3=Color3.fromRGB(100,200,255); selfDot.BorderSizePixel=0; selfDot.ZIndex=18; selfDot.Parent=mmArea
Instance.new("UICorner",selfDot).CornerRadius=UDim.new(1,0)

local mmDots={}
local function getOrMakeMMDot(plr)
    if mmDots[plr] then return mmDots[plr] end
    local d=Instance.new("Frame"); d.Size=UDim2.new(0,5,0,5); d.AnchorPoint=Vector2.new(0.5,0.5)
    d.BackgroundColor3=Color3.fromRGB(220,50,50); d.BorderSizePixel=0; d.ZIndex=17
    d.Visible=false; d.Parent=mmArea
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    mmDots[plr]=d; return d
end

local mapMinX,mapMinZ,mapMaxX,mapMaxZ=-500,-500,500,500
task.spawn(function()
    task.wait(3)
    local mnX,mnZ,mxX,mxZ=-500,-500,500,500
    for _,obj in workspace:GetDescendants() do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(Camera) then
            local p=obj.Position
            if p.X<mnX then mnX=p.X end; if p.X>mxX then mxX=p.X end
            if p.Z<mnZ then mnZ=p.Z end; if p.Z>mxZ then mxZ=p.Z end
        end
    end
    mapMinX,mapMinZ,mapMaxX,mapMaxZ=mnX,mnZ,mxX,mxZ
end)

local function worldToMM(wp)
    local rx=(wp.X-mapMinX)/math.max(mapMaxX-mapMinX,1)
    local rz=(wp.Z-mapMinZ)/math.max(mapMaxZ-mapMinZ,1)
    return math.clamp(rx,0,1),math.clamp(rz,0,1)
end

-- ══════════════════════════════════════════
-- [23] MAIN WINDOW
-- ══════════════════════════════════════════
local Win=Instance.new("Frame")
Win.Name="VenomWin"; Win.Size=UDim2.new(0,860,0,520)
Win.Position=UDim2.new(0.5,-430,0.5,-260)
Win.BackgroundColor3=BG; Win.BorderSizePixel=0; Win.Active=true; Win.Parent=ScreenGui
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,8)
local WinStroke=Instance.new("UIStroke"); WinStroke.Color=PURPLE_DIM; WinStroke.Thickness=1; WinStroke.Parent=Win

local TopAccent=Instance.new("Frame")
TopAccent.Size=UDim2.new(1,0,0,2); TopAccent.BackgroundColor3=PURPLE
TopAccent.BorderSizePixel=0; TopAccent.ZIndex=2; TopAccent.Parent=Win
Instance.new("UICorner",TopAccent).CornerRadius=UDim.new(0,8)

-- Title bar
local TitleBar=Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,36); TitleBar.BackgroundColor3=BG2
TitleBar.BorderSizePixel=0; TitleBar.Active=true; TitleBar.Parent=Win
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,8)
local TFix=Instance.new("Frame"); TFix.Size=UDim2.new(1,0,0,10); TFix.Position=UDim2.new(0,0,1,-10)
TFix.BackgroundColor3=BG2; TFix.BorderSizePixel=0; TFix.Parent=TitleBar

local Logo=Instance.new("TextLabel")
Logo.Size=UDim2.new(0,100,1,0); Logo.Position=UDim2.new(0,14,0,0)
Logo.BackgroundTransparency=1; Logo.Text="venom.lol"; Logo.TextColor3=PURPLE
Logo.TextSize=15; Logo.Font=Enum.Font.GothamBold; Logo.TextXAlignment=Enum.TextXAlignment.Left; Logo.Parent=TitleBar

local LogoSub=Instance.new("TextLabel")
LogoSub.Size=UDim2.new(0,40,1,0); LogoSub.Position=UDim2.new(0,102,0,0)
LogoSub.BackgroundTransparency=1; LogoSub.Text="v3.0"; LogoSub.TextColor3=SUBTEXT
LogoSub.TextSize=10; LogoSub.Font=Enum.Font.Gotham; LogoSub.TextXAlignment=Enum.TextXAlignment.Left; LogoSub.Parent=TitleBar

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,22,0,22); CloseBtn.Position=UDim2.new(1,-30,0.5,-11)
CloseBtn.BackgroundColor3=Color3.fromRGB(50,20,20); CloseBtn.Text="✕"
CloseBtn.TextColor3=RED; CloseBtn.TextSize=11; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.BorderSizePixel=0; CloseBtn.Parent=TitleBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,4)
CloseBtn.MouseButton1Click:Connect(function()
    saveConfig()
    for _,d in espObjects do destroyESP(d) end
    if FovDraw then safeExec(function() FovDraw:Remove() end) end
    ScreenGui:Destroy()
end)

local MinBtn=Instance.new("TextButton")
MinBtn.Size=UDim2.new(0,22,0,22); MinBtn.Position=UDim2.new(1,-56,0.5,-11)
MinBtn.BackgroundColor3=PURPLE_DARK; MinBtn.Text="─"; MinBtn.TextColor3=PURPLE
MinBtn.TextSize=11; MinBtn.Font=Enum.Font.GothamBold; MinBtn.BorderSizePixel=0; MinBtn.Parent=TitleBar
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,4)

local TabBarFrame=Instance.new("Frame")
TabBarFrame.Size=UDim2.new(1,-320,1,0); TabBarFrame.Position=UDim2.new(0,155,0,0)
TabBarFrame.BackgroundTransparency=1; TabBarFrame.Parent=TitleBar
local TabBarLayout=Instance.new("UIListLayout")
TabBarLayout.FillDirection=Enum.FillDirection.Horizontal
TabBarLayout.SortOrder=Enum.SortOrder.LayoutOrder
TabBarLayout.Padding=UDim.new(0,2); TabBarLayout.VerticalAlignment=Enum.VerticalAlignment.Center
TabBarLayout.Parent=TabBarFrame

-- Drag (title bar only)
local dragging,dragStart,startPos=false,nil,nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=Win.Position
    end
end)
TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

local minimised=false
MinBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    for _,c in Win:GetChildren() do
        if c~=TitleBar and c~=TopAccent then c.Visible=not minimised end
    end
    Win.Size=minimised and UDim2.new(0,860,0,36) or UDim2.new(0,860,0,520)
end)

-- Body
local Body=Instance.new("Frame"); Body.Size=UDim2.new(1,0,1,-36); Body.Position=UDim2.new(0,0,0,36)
Body.BackgroundTransparency=1; Body.Parent=Win

local LeftPanel=Instance.new("Frame"); LeftPanel.Size=UDim2.new(0,300,1,0)
LeftPanel.BackgroundColor3=BG2; LeftPanel.BorderSizePixel=0; LeftPanel.Parent=Body

local LeftScroll=Instance.new("ScrollingFrame")
LeftScroll.Size=UDim2.new(1,-4,1,-10); LeftScroll.Position=UDim2.new(0,4,0,5)
LeftScroll.BackgroundTransparency=1; LeftScroll.BorderSizePixel=0
LeftScroll.ScrollBarThickness=3; LeftScroll.ScrollBarImageColor3=PURPLE
LeftScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; LeftScroll.CanvasSize=UDim2.new(0,0,0,0)
LeftScroll.Parent=LeftPanel
local LL=Instance.new("UIListLayout"); LL.SortOrder=Enum.SortOrder.LayoutOrder; LL.Padding=UDim.new(0,3); LL.Parent=LeftScroll
local LP=Instance.new("UIPadding"); LP.PaddingLeft=UDim.new(0,8); LP.PaddingRight=UDim.new(0,8)
LP.PaddingTop=UDim.new(0,8); LP.PaddingBottom=UDim.new(0,8); LP.Parent=LeftScroll

local Div=Instance.new("Frame"); Div.Size=UDim2.new(0,1,1,0); Div.Position=UDim2.new(0,300,0,0)
Div.BackgroundColor3=PURPLE_DARK; Div.BorderSizePixel=0; Div.Parent=Body

local RightPanel=Instance.new("Frame"); RightPanel.Size=UDim2.new(1,-302,1,0); RightPanel.Position=UDim2.new(0,302,0,0)
RightPanel.BackgroundColor3=BG; RightPanel.BorderSizePixel=0; RightPanel.Parent=Body

local RightScroll=Instance.new("ScrollingFrame")
RightScroll.Size=UDim2.new(1,-4,1,-10); RightScroll.Position=UDim2.new(0,4,0,5)
RightScroll.BackgroundTransparency=1; RightScroll.BorderSizePixel=0
RightScroll.ScrollBarThickness=3; RightScroll.ScrollBarImageColor3=PURPLE
RightScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; RightScroll.CanvasSize=UDim2.new(0,0,0,0)
RightScroll.Parent=RightPanel
local RL=Instance.new("UIListLayout"); RL.SortOrder=Enum.SortOrder.LayoutOrder; RL.Padding=UDim.new(0,3); RL.Parent=RightScroll
local RP=Instance.new("UIPadding"); RP.PaddingLeft=UDim.new(0,10); RP.PaddingRight=UDim.new(0,10)
RP.PaddingTop=UDim.new(0,8); RP.PaddingBottom=UDim.new(0,8); RP.Parent=RightScroll

-- ══════════════════════════════════════════
-- [24] TAB SYSTEM
-- ══════════════════════════════════════════
local tabs={}
local function makeTabBtn(name,order)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,76,0,26); btn.BackgroundColor3=BG3; btn.BorderSizePixel=0
    btn.Text=name; btn.TextColor3=SUBTEXT; btn.TextSize=10; btn.Font=Enum.Font.GothamSemibold
    btn.LayoutOrder=order; btn.Parent=TabBarFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    local ul=Instance.new("Frame"); ul.Size=UDim2.new(1,0,0,2); ul.Position=UDim2.new(0,0,1,-2)
    ul.BackgroundColor3=PURPLE; ul.BorderSizePixel=0; ul.Visible=false; ul.Parent=btn
    Instance.new("UICorner",ul).CornerRadius=UDim.new(1,0)
    local td={btn=btn,underline=ul,leftItems={},rightItems={}}
    table.insert(tabs,td)
    btn.MouseButton1Click:Connect(function()
        for _,t in tabs do
            t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
            for _,i in t.leftItems  do i.Visible=false end
            for _,i in t.rightItems do i.Visible=false end
        end
        btn.TextColor3=PURPLE; btn.BackgroundColor3=PURPLE_DARK; ul.Visible=true
        for _,i in td.leftItems  do i.Visible=true end
        for _,i in td.rightItems do i.Visible=true end
    end)
    return td
end
local function activateTab(td)
    for _,t in tabs do
        t.btn.TextColor3=SUBTEXT; t.btn.BackgroundColor3=BG3; t.underline.Visible=false
        for _,i in t.leftItems  do i.Visible=false end
        for _,i in t.rightItems do i.Visible=false end
    end
    td.btn.TextColor3=PURPLE; td.btn.BackgroundColor3=PURPLE_DARK; td.underline.Visible=true
    for _,i in td.leftItems  do i.Visible=true end
    for _,i in td.rightItems do i.Visible=true end
end

-- ══════════════════════════════════════════
-- [25] COMPONENT BUILDERS
-- ══════════════════════════════════════════
local LO,RO=0,0

local function SL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1; f.LayoutOrder=RO; f.Parent=RightScroll
    else LO+=1; f.LayoutOrder=LO; f.Parent=LeftScroll end
    local ln=Instance.new("Frame"); ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,1,-1)
    ln.BackgroundColor3=PURPLE_DARK; ln.BorderSizePixel=0; ln.Parent=f
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=text; lb.TextColor3=SUBTEXT; lb.TextSize=10; lb.Font=Enum.Font.GothamSemibold
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end

local function TG(name,kb,def,cb,isR)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,26); row.BackgroundTransparency=1; row.Visible=false
    if isR then RO+=1; row.LayoutOrder=RO; row.Parent=RightScroll
    else LO+=1; row.LayoutOrder=LO; row.Parent=LeftScroll end
    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,14,0,14); dot.Position=UDim2.new(0,0,0.5,-7)
    dot.BackgroundColor3=def and PURPLE or Color3.fromRGB(50,50,60); dot.BorderSizePixel=0; dot.Parent=row
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,3)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-80,1,0); lb.Position=UDim2.new(0,20,0,0)
    lb.BackgroundTransparency=1; lb.Text=name; lb.TextColor3=def and TEXT or SUBTEXT
    lb.TextSize=12; lb.Font=Enum.Font.Gotham; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=row
    if kb and kb~="" then
        local k=Instance.new("TextLabel"); k.Size=UDim2.new(0,60,1,0); k.Position=UDim2.new(1,-60,0,0)
        k.BackgroundTransparency=1; k.Text="["..kb.."]"; k.TextColor3=PURPLE_DIM
        k.TextSize=10; k.Font=Enum.Font.Gotham; k.TextXAlignment=Enum.TextXAlignment.Right; k.Parent=row
    end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=row
    local st=def
    local function set(v)
        st=v
        TweenService:Create(dot,TWEEN_FAST,{BackgroundColor3=st and PURPLE or Color3.fromRGB(50,50,60)}):Play()
        lb.TextColor3=st and TEXT or SUBTEXT
        if cb then cb(st) end
    end
    btn.MouseButton1Click:Connect(function() set(not st) end)
    return row,set
end

local function SLD(name,mn,mx,def,sfx,cb,isR)
    sfx=sfx or ""
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,46); card.BackgroundTransparency=1; card.Visible=false
    if isR then RO+=1; card.LayoutOrder=RO; card.Parent=RightScroll
    else LO+=1; card.LayoutOrder=LO; card.Parent=LeftScroll end
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
    kn.Position=UDim2.new(p0,0,0.5,0); kn.BackgroundColor3=Color3.fromRGB(220,200,255)
    kn.BorderSizePixel=0; kn.ZIndex=3; kn.Parent=tr
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local sd=false
    local function beginDrag(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=true end
    end
    tr.InputBegan:Connect(beginDrag); kn.InputBegan:Connect(beginDrag)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end
    end)
    RunService.RenderStepped:Connect(function()
        if not sd then return end
        local mp=UserInputService:GetMouseLocation()
        local p=math.clamp((mp.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.round(mn+p*(mx-mn))
        fl.Size=UDim2.new(p,0,1,0); kn.Position=UDim2.new(p,0,0.5,0)
        vL.Text=tostring(v)..sfx; if cb then cb(v) end
    end)
    return card
end

local function DD(name,opts,def,cb,isR)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isR then RO+=1; card.LayoutOrder=RO; card.Parent=RightScroll
    else LO+=1; card.LayoutOrder=LO; card.Parent=LeftScroll end
    local vL=Instance.new("TextLabel"); vL.Size=UDim2.new(0.5,0,1,0); vL.BackgroundTransparency=1
    vL.Text=def; vL.TextColor3=TEXT; vL.TextSize=11; vL.Font=Enum.Font.Gotham
    vL.TextXAlignment=Enum.TextXAlignment.Left; vL.Parent=card
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.5,0,1,0); nL.Position=UDim2.new(0.5,0,0,0)
    nL.BackgroundTransparency=1; nL.Text=name; nL.TextColor3=SUBTEXT; nL.TextSize=11; nL.Font=Enum.Font.Gotham
    nL.TextXAlignment=Enum.TextXAlignment.Right; nL.Parent=card
    local idx=1
    for i,v in opts do if v==def then idx=i; break end end
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""; btn.Parent=card
    btn.MouseButton1Click:Connect(function()
        idx=(idx%#opts)+1; vL.Text=opts[idx]; if cb then cb(opts[idx]) end
    end)
    return card
end

local function KB(name,def,cb,isR)
    local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,26); card.BackgroundTransparency=1; card.Visible=false
    if isR then RO+=1; card.LayoutOrder=RO; card.Parent=RightScroll
    else LO+=1; card.LayoutOrder=LO; card.Parent=LeftScroll end
    local nL=Instance.new("TextLabel"); nL.Size=UDim2.new(0.5,0,1,0); nL.BackgroundTransparency=1
    nL.Text=name; nL.TextColor3=SUBTEXT; nL.TextSize=11; nL.Font=Enum.Font.Gotham
    nL.TextXAlignment=Enum.TextXAlignment.Left; nL.Parent=card
    local kBtn=Instance.new("TextButton"); kBtn.Size=UDim2.new(0,60,0,20); kBtn.Position=UDim2.new(1,-60,0.5,-10)
    kBtn.BackgroundColor3=PURPLE_DARK; kBtn.BorderSizePixel=0; kBtn.Text="["..def.."]"
    kBtn.TextColor3=PURPLE; kBtn.TextSize=11; kBtn.Font=Enum.Font.GothamBold; kBtn.Parent=card
    Instance.new("UICorner",kBtn).CornerRadius=UDim.new(0,4)
    local ls=false
    kBtn.MouseButton1Click:Connect(function()
        ls=true; kBtn.Text="[...]"; kBtn.TextColor3=TEXT
        task.delay(10,function()
            if ls then ls=false; kBtn.Text="["..def.."]"; kBtn.TextColor3=PURPLE end
        end)
    end)
    UserInputService.InputBegan:Connect(function(inp)
        if not ls then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            ls=false; local kn=inp.KeyCode.Name
            def=kn; kBtn.Text="["..kn.."]"; kBtn.TextColor3=PURPLE
            if cb then cb(kn) end
        end
    end)
    return card
end

local function TL(text,isR)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.Visible=false
    if isR then RO+=1; f.LayoutOrder=RO; f.Parent=RightScroll
    else LO+=1; f.LayoutOrder=LO; f.Parent=LeftScroll end
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=text; lb.TextColor3=SUBTEXT; lb.TextSize=11; lb.Font=Enum.Font.Gotham
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f; return f
end

local function addL(t,i) table.insert(t.leftItems,i) end
local function addR(t,i) table.insert(t.rightItems,i) end

-- ══════════════════════════════════════════
-- [26] CREATE TABS
-- ══════════════════════════════════════════
local tAimbot   = makeTabBtn("aimbot",  1)
local tBots     = makeTabBtn("bots",    2)
local tChecks   = makeTabBtn("checks",  3)
local tVisuals  = makeTabBtn("visuals", 4)
local tMovement = makeTabBtn("movement",5)
local tAddons   = makeTabBtn("addons",  6)
local tConfig   = makeTabBtn("config",  7)

-- ══════════════════════════════════════════
-- [27] AIMBOT TAB
-- ══════════════════════════════════════════
addL(tAimbot,SL("Aimbot",false))
addL(tAimbot,TG("Enable",state.aimKey,state.aimEnabled,function(on)
    state.aimEnabled=on
    if not on then Aiming=false; Target=nil
        if AimTween then AimTween:Cancel(); AimTween=nil end
        UserInputService.MouseDeltaSensitivity=MouseSens
        releaseCamera("aimbot")
    end
end,false))
addL(tAimbot,TG("One-Press Mode","",state.onePressAim,function(on) state.onePressAim=on end,false))
addL(tAimbot,KB("Aim Key",state.aimKey,function(k) state.aimKey=k end,false))

local aimModes={"Camera"}
if HAS_MOVEREL then table.insert(aimModes,"Mouse") end
if HAS_HOOK_META and HAS_GET_NCALL then table.insert(aimModes,"Silent") end
addL(tAimbot,DD("Aim Mode",aimModes,state.aimMode,function(v) state.aimMode=v end,false))

if HAS_HOOK_META and HAS_GET_NCALL then
    addL(tAimbot,SL("Silent Aim",false))
    addL(tAimbot,SLD("Hit Chance",1,100,state.silentChance,"%",function(v) state.silentChance=v end,false))
    addL(tAimbot,TL("Methods: Mouse.Hit · GetMouseLocation · Raycast · FindPartOnRay",false))
end

addL(tAimbot,SL("Aim Part",false))
addL(tAimbot,DD("Body Part",{"Head","HumanoidRootPart","Torso","UpperTorso"},
    state.aimPart,function(v) state.aimPart=v end,false))
addL(tAimbot,TG("Random Aim Part","",state.randomAimPart,function(on) state.randomAimPart=on end,false))
addL(tAimbot,TG("Off After Kill","",state.offAfterKill,function(on) state.offAfterKill=on end,false))

addR(tAimbot,SL("Aim Offset",true))
addR(tAimbot,TG("Use Offset","",state.useOffset,function(on) state.useOffset=on end,true))
addR(tAimbot,DD("Offset Type",{"Static","Dynamic","Static & Dynamic"},state.offsetType,function(v) state.offsetType=v end,true))
addR(tAimbot,SLD("Static Offset",1,50,state.staticOffset,"",function(v) state.staticOffset=v end,true))
addR(tAimbot,SLD("Dynamic Offset",1,50,state.dynamicOffset,"",function(v) state.dynamicOffset=v end,true))
addR(tAimbot,TG("Auto Offset","",state.autoOffset,function(on) state.autoOffset=on end,true))
addR(tAimbot,SLD("Max Auto Offset",1,50,state.maxAutoOffset,"",function(v) state.maxAutoOffset=v end,true))

addR(tAimbot,SL("Smoothness",true))
addR(tAimbot,TG("Use Sensitivity","",state.useSensitivity,function(on) state.useSensitivity=on end,true))
addR(tAimbot,SLD("Sensitivity",1,100,state.sensitivity,"",function(v) state.sensitivity=v end,true))
addR(tAimbot,TG("Use Noise","",state.useNoise,function(on) state.useNoise=on end,true))
addR(tAimbot,SLD("Noise Frequency",1,100,state.noiseFrequency,"",function(v) state.noiseFrequency=v end,true))

addR(tAimbot,SL("Camlock",true))
addR(tAimbot,TG("Enable","",state.camlockEnabled,function(on) state.camlockEnabled=on end,true))
addR(tAimbot,KB("Camlock Key",state.camlockKeybind,function(k) state.camlockKeybind=k end,true))
addR(tAimbot,TG("Toggle Mode","",state.camlockToggle,function(on) state.camlockToggle=on end,true))
addR(tAimbot,DD("Camlock Part",{"Head","HumanoidRootPart","Torso"},state.camlockPart,function(v) state.camlockPart=v end,true))
addR(tAimbot,TG("Advanced Mode","",state.useAdvanced,function(on) state.useAdvanced=on end,true))
addR(tAimbot,TG("Smoothing","",state.smoothingOn,function(on) state.smoothingOn=on end,true))
addR(tAimbot,SLD("Smooth X",1,20,state.smoothX,"",function(v) state.smoothX=v end,true))
addR(tAimbot,SLD("Smooth Y",1,20,state.smoothY,"",function(v) state.smoothY=v end,true))
addR(tAimbot,SLD("Predict X",0,10,state.predictX,"",function(v) state.predictX=v end,true))
addR(tAimbot,SLD("Predict Y",0,10,state.predictY,"",function(v) state.predictY=v end,true))
addR(tAimbot,DD("Camlock Style",{"Linear","Quadratic","Sine"},state.camlockStyle,function(v) state.camlockStyle=v end,true))

-- ══════════════════════════════════════════
-- [28] BOTS TAB
-- ══════════════════════════════════════════
addL(tBots,SL("SpinBot",false))
addL(tBots,TG("Enable","",state.spinBot,function(on) state.spinBot=on; if not on then Spinning=false end end,false))
addL(tBots,TG("One-Press","",state.onePressSpinning,function(on) state.onePressSpinning=on end,false))
addL(tBots,KB("Spin Key",state.spinKey,function(k) state.spinKey=k end,false))
addL(tBots,SLD("Velocity",1,50,state.spinVelocity,"",function(v) state.spinVelocity=v end,false))
addL(tBots,DD("Spin Part",{"Head","HumanoidRootPart"},state.spinPart,function(v) state.spinPart=v end,false))
addL(tBots,TG("Random Spin Part","",state.randomSpinPart,function(on) state.randomSpinPart=on end,false))

if HAS_M1CLICK then
    addR(tBots,SL("TriggerBot",true))
    addR(tBots,TG("Enable","",state.triggerBot,function(on) state.triggerBot=on; if not on then Triggering=false end end,true))
    addR(tBots,TG("One-Press","",state.onePressTrigger,function(on) state.onePressTrigger=on end,true))
    addR(tBots,TG("Smart Trigger","",state.smartTrigger,function(on) state.smartTrigger=on end,true))
    addR(tBots,KB("Trigger Key",state.triggerKey,function(k) state.triggerKey=k end,true))
    addR(tBots,SLD("Hit Chance",1,100,state.triggerChance,"%",function(v) state.triggerChance=v end,true))
else
    addR(tBots,SL("TriggerBot",true)); addR(tBots,TL("⚠ mouse1click not available",true))
end

-- ══════════════════════════════════════════
-- [29] CHECKS TAB  (full Open Aimbot merge)
-- ══════════════════════════════════════════
addL(tChecks,SL("Player Checks",false))
addL(tChecks,TG("Alive Check","",state.aliveCheck,function(on) state.aliveCheck=on end,false))
addL(tChecks,TG("God Check","",state.godCheck,function(on) state.godCheck=on end,false))
addL(tChecks,TG("Team Check","",state.teamCheck,function(on) state.teamCheck=on end,false))
addL(tChecks,TG("Friend Check","",state.friendCheck,function(on) state.friendCheck=on end,false))
addL(tChecks,TG("Follow Check","",state.followCheck,function(on) state.followCheck=on end,false))
addL(tChecks,TG("Verified Badge Check","",state.verifiedBadgeCheck,function(on) state.verifiedBadgeCheck=on end,false))
addL(tChecks,TG("Wall Check","",state.wallCheck,function(on) state.wallCheck=on end,false))
addL(tChecks,TG("Water Check","",state.waterCheck,function(on) state.waterCheck=on end,false))

addL(tChecks,SL("Transparency Check",false))
addL(tChecks,TG("Enable","",state.transparencyCheck,function(on) state.transparencyCheck=on end,false))
addL(tChecks,SLD("Max Transparency",0,10,math.round(state.ignoredTransparency*10),"",function(v)
    state.ignoredTransparency=v/10 end,false))

addL(tChecks,SL("Group Checks",false))
addL(tChecks,TG("Whitelist Group","",state.whitelistGroupCheck,function(on) state.whitelistGroupCheck=on end,false))
addL(tChecks,SLD("Whitelist Group ID",0,99999999,state.whitelistGroup,"",function(v) state.whitelistGroup=v end,false))
addL(tChecks,TG("Blacklist Group","",state.blacklistGroupCheck,function(on) state.blacklistGroupCheck=on end,false))
addL(tChecks,SLD("Blacklist Group ID",0,99999999,state.blacklistGroup,"",function(v) state.blacklistGroup=v end,false))

addR(tChecks,SL("Distance Checks",true))
addR(tChecks,TG("FOV Check","",state.fovCheck,function(on) state.fovCheck=on end,true))
addR(tChecks,SLD("FOV Radius",10,1000,state.fovRadius,"px",function(v) state.fovRadius=v end,true))
addR(tChecks,TG("Magnitude Check","",state.magnitudeCheck,function(on) state.magnitudeCheck=on end,true))
addR(tChecks,SLD("Max Magnitude",10,1000,state.triggerMagnitude,"st",function(v) state.triggerMagnitude=v end,true))

addR(tChecks,SL("Player Filter",true))
addR(tChecks,TG("Ignored Players","",state.ignoredPlayersCheck,function(on) state.ignoredPlayersCheck=on end,true))
addR(tChecks,TL("Ignored: edit state.ignoredPlayers table",true))
addR(tChecks,TG("Target Players","",state.targetPlayersCheck,function(on) state.targetPlayersCheck=on end,true))
addR(tChecks,TL("Target: edit state.targetPlayers table",true))

-- ══════════════════════════════════════════
-- [30] VISUALS TAB
-- ══════════════════════════════════════════
addL(tVisuals,SL("FOV Circle",false))
addL(tVisuals,TG("Show FOV",state.fovKey,state.fovVisible,function(on)
    state.fovVisible=on; ShowFov=on
    if not on and FovDraw then safeExec(function() FovDraw.Visible=false end) end
end,false))
addL(tVisuals,KB("FOV Key",state.fovKey,function(k) state.fovKey=k end,false))
addL(tVisuals,SLD("FOV Radius",10,1000,state.fovRadius,"px",function(v)
    state.fovRadius=v; if FovDraw then safeExec(function() FovDraw.Radius=v end) end end,false))
addL(tVisuals,SLD("FOV Thickness",1,10,state.fovThickness,"",function(v) state.fovThickness=v end,false))
addL(tVisuals,SLD("FOV Opacity",1,10,math.round(state.fovOpacity*10),"",function(v) state.fovOpacity=v/10 end,false))
addL(tVisuals,TG("FOV Filled","",state.fovFilled,function(on) state.fovFilled=on end,false))
if not HAS_DRAWING then addL(tVisuals,TL("⚠ Drawing API unavailable",false)) end

addL(tVisuals,SL("ESP",false))
addL(tVisuals,TG("ESP Master",state.espKey,state.espEnabled,function(on)
    state.espEnabled=on; ShowESP=on
    if not on then for _,d in espObjects do hideESP(d) end end
end,false))
addL(tVisuals,KB("ESP Key",state.espKey,function(k) state.espKey=k end,false))
addL(tVisuals,TG("Boxes","",state.espBoxes,function(on) state.espBoxes=on end,false))
addL(tVisuals,TG("Box Filled","",state.espBoxFilled,function(on) state.espBoxFilled=on end,false))
addL(tVisuals,TG("Names","",state.espNames,function(on) state.espNames=on end,false))
addL(tVisuals,TG("Health Bar","",state.espHealth,function(on) state.espHealth=on end,false))
addL(tVisuals,TG("Magnitude","",state.espMagnitude,function(on) state.espMagnitude=on end,false))
addL(tVisuals,TG("Tracers","",state.espTracers,function(on) state.espTracers=on end,false))
addL(tVisuals,TG("Chams","",state.chams,function(on)
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
end,false))

addR(tVisuals,SL("ESP Style",true))
addR(tVisuals,SLD("Thickness",1,10,state.espThickness,"",function(v) state.espThickness=v end,true))
addR(tVisuals,SLD("Opacity",1,10,math.round(state.espOpacity*10),"",function(v) state.espOpacity=v/10 end,true))
addR(tVisuals,TG("Use Team Color","",state.useTeamColor,function(on) state.useTeamColor=on end,true))
addR(tVisuals,TG("Rainbow Visuals","",state.rainbowVisuals,function(on) state.rainbowVisuals=on end,true))
addR(tVisuals,SLD("Rainbow Speed",1,10,state.rainbowDelay,"",function(v) state.rainbowDelay=v end,true))

addR(tVisuals,SL("World",true))
addR(tVisuals,TG("Fullbright","",state.fullbright,function(on)
    state.fullbright=on
    Lighting.Brightness=on and 10 or 1
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
    Lighting.OutdoorAmbient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end,true))
addR(tVisuals,TG("No Fog","",state.noFog,function(on)
    state.noFog=on
    local a=Lighting:FindFirstChildOfClass("Atmosphere"); if a then a.Density=on and 0 or 0.395 end
end,true))
addR(tVisuals,TG("No Shadows","",state.noShadows,function(on)
    state.noShadows=on; Lighting.GlobalShadows=not on
end,true))

-- ══════════════════════════════════════════
-- [31] MOVEMENT TAB
-- ══════════════════════════════════════════
addL(tMovement,SL("Movement",false))
addL(tMovement,TG("Fly","",state.flyEnabled,function(on) setFly(on) end,false))
addL(tMovement,TG("Noclip","",state.noclip,function(on) state.noclip=on end,false))
addL(tMovement,TG("Infinite Jump","",state.infiniteJump,function(on) state.infiniteJump=on end,false))
addL(tMovement,TG("Speed Boost","",state.speedBoost,function(on) state.speedBoost=on end,false))
addL(tMovement,SLD("Walk Speed",8,200,state.walkSpeed,"",function(v)
    state.walkSpeed=v; rampProp(getHum,"WalkSpeed",v) end,false))
addL(tMovement,SLD("Jump Power",0,300,state.jumpPower,"",function(v)
    state.jumpPower=v; rampProp(getHum,"JumpPower",v) end,false))

addR(tMovement,SL("Player",true))
addR(tMovement,TG("God Mode","",state.godMode,function(on) state.godMode=on end,true))
addR(tMovement,TG("Anti-AFK","",state.antiAfk,function(on) state.antiAfk=on end,true))
addR(tMovement,TG("Invisible","",state.invisible,function(on)
    state.invisible=on
    local c=Player.Character; if not c then return end
    for _,p in c:GetDescendants() do
        if p:IsA("BasePart") then p.Transparency=on and 1 or 0 end
    end
end,true))
addR(tMovement,TG("Sprint","",state.sprintEnabled,function(on) state.sprintEnabled=on end,true))
addR(tMovement,SLD("Sprint Speed",20,100,state.sprintSpeed,"",function(v) state.sprintSpeed=v end,true))
addR(tMovement,TL("Hold LeftShift to sprint",true))

-- ══════════════════════════════════════════
-- [32] ADDONS TAB
-- ══════════════════════════════════════════
addL(tAddons,SL("Crosshair",false))
addL(tAddons,TG("Enable","",state.crosshair,function(on) state.crosshair=on; buildCrosshair() end,false))
addL(tAddons,DD("Style",{"Plus","Dot","Circle"},state.crosshairStyle,function(v)
    state.crosshairStyle=v; buildCrosshair() end,false))
addL(tAddons,SLD("Size",4,30,state.crosshairSize,"px",function(v)
    state.crosshairSize=v; buildCrosshair() end,false))

addL(tAddons,SL("Hitmarker",false))
addL(tAddons,TG("Enable","",state.hitmarker,function(on) state.hitmarker=on end,false))
addL(tAddons,TL("Shows ✕ when target takes damage",false))

addL(tAddons,SL("Click Teleport",false))
addL(tAddons,TG("Enable","",state.clickTp,function(on) state.clickTp=on end,false))
addL(tAddons,TL("Middle-click to teleport to mouse",false))

addL(tAddons,SL("Minimap",false))
addL(tAddons,TG("Enable","",state.minimap,function(on) state.minimap=on; MinimapFrame.Visible=on end,false))
addL(tAddons,TL("Blue=you  |  Red=enemies",false))

addR(tAddons,SL("Keybind Reference",true))
addR(tAddons,TL("RShift  →  toggle GUI",true))
addR(tAddons,TL("AimKey  →  hold/press to aim",true))
addR(tAddons,TL("CamlockKey  →  hold/toggle lock",true))
addR(tAddons,TL("SpinKey  →  spinbot",true))
addR(tAddons,TL("TriggerKey  →  triggerbot",true))
addR(tAddons,TL("FOV Key  →  toggle FOV circle",true))
addR(tAddons,TL("ESP Key  →  toggle ESP",true))
addR(tAddons,SL("Executor Status",true))
addR(tAddons,TL("Drawing API: "  ..(HAS_DRAWING  and "✔" or "✘"),true))
addR(tAddons,TL("MouseMoveRel: " ..(HAS_MOVEREL   and "✔" or "✘"),true))
addR(tAddons,TL("HookMeta: "     ..(HAS_HOOK_META and "✔" or "✘"),true))
addR(tAddons,TL("newcclosure: "  ..(HAS_NEWCC     and "✔" or "✘"),true))
addR(tAddons,TL("checkcaller: "  ..(HAS_CHECKER   and "✔" or "✘"),true))
addR(tAddons,TL("Mouse1Click: "  ..(HAS_M1CLICK   and "✔" or "✘"),true))

-- ══════════════════════════════════════════
-- [33] CONFIG TAB
-- ══════════════════════════════════════════
addL(tConfig,SL("Config Manager",false))

local function makeActionBtn(text,isR,onClick)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,32)
    btn.BackgroundColor3=PURPLE_DARK; btn.BorderSizePixel=0; btn.Text=text
    btn.TextColor3=PURPLE; btn.TextSize=12; btn.Font=Enum.Font.GothamSemibold; btn.Visible=false
    if isR then RO+=1; btn.LayoutOrder=RO; btn.Parent=RightScroll
    else LO+=1; btn.LayoutOrder=LO; btn.Parent=LeftScroll end
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(onClick); return btn
end

local saveBtn=makeActionBtn("💾  Save Config",false,function()
    saveConfig(); saveBtn.Text="✔  Saved!"; saveBtn.TextColor3=GREEN
    task.delay(1.5,function() saveBtn.Text="💾  Save Config"; saveBtn.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems,saveBtn)

local loadBtn=makeActionBtn("📂  Load Config",false,function()
    loadConfig(); loadBtn.Text="✔  Loaded!"; loadBtn.TextColor3=GREEN
    task.delay(1.5,function() loadBtn.Text="📂  Load Config"; loadBtn.TextColor3=PURPLE end)
end)
table.insert(tConfig.leftItems,loadBtn)

addL(tConfig,TL("File: venom_<GameID>.json",false))
addL(tConfig,TL("Auto-saves when GUI closes",false))
addL(tConfig,SL("Rendering Mode",false))
addL(tConfig,DD("Mode",{"RenderStepped","Heartbeat","Stepped"},state.renderMode,function(v)
    state.renderMode=v end,false))

addR(tConfig,SL("Bypass Status",true))
addR(tConfig,TL("__namecall: " ..(HAS_HOOK_META  and (HAS_NEWCC and "newcclosure+checkcaller" or "basic") or (HAS_HOOKFN and "hookfunction fallback" or "✘")),true))
addR(tConfig,TL("__index:    " ..(HAS_HOOK_META  and "Mouse.Hit/Target intercepted" or "✘"),true))
addR(tConfig,TL("God Mode:   jitterLoop ±50% + health noise",true))
addR(tConfig,TL("Noclip:     jitterLoop ~30ms ±40%",true))
addR(tConfig,TL("Fly:        GUID names + velocity noise + cycled conn",true))
addR(tConfig,TL("InfJump:    cooldown 60-130ms + state check",true))
addR(tConfig,TL("AntiAFK:    50-85s random + alternates input type",true))
addR(tConfig,TL("GUI Name:   random GUID per session",true))
addR(tConfig,TL("Output:     print/warn/error suppressed",true))

-- ══════════════════════════════════════════
-- [34] KEY RESOLVER
-- ══════════════════════════════════════════
local function getKey(name)
    if name=="RMB" then return Enum.UserInputType.MouseButton2 end
    if name=="LMB" then return Enum.UserInputType.MouseButton1 end
    local ok,kc=pcall(function() return Enum.KeyCode[name] end)
    return ok and kc or nil
end

-- ══════════════════════════════════════════
-- [35] INPUT HANDLER
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end

    -- Toggle GUI
    if inp.KeyCode==Enum.KeyCode.RightShift then Win.Visible=not Win.Visible; return end

    -- Aimbot
    if state.aimEnabled then
        local ak=getKey(state.aimKey)
        local match=ak and (inp.KeyCode==ak or inp.UserInputType==ak)
        if match then
            if state.onePressAim then
                Aiming=not Aiming
                if not Aiming then
                    Target=nil; if AimTween then AimTween:Cancel(); AimTween=nil end
                    UserInputService.MouseDeltaSensitivity=MouseSens; releaseCamera("aimbot")
                else claimCamera("aimbot") end
            else Aiming=true; claimCamera("aimbot") end
        end
    end

    -- Camlock
    local ck=getKey(state.camlockKeybind)
    if ck and inp.KeyCode==ck then
        if state.camlockToggle then
            camlockState=not camlockState; state.camlockEnabled=camlockState
            if state.camlockEnabled then claimCamera("camlock") else stickyTarget=nil; releaseCamera("camlock") end
        else state.camlockEnabled=true; claimCamera("camlock") end
    end

    -- SpinBot
    if state.spinBot then
        local sk=getKey(state.spinKey)
        if sk and (inp.KeyCode==sk or inp.UserInputType==sk) then
            if state.onePressSpinning then Spinning=not Spinning else Spinning=true end
        end
    end

    -- TriggerBot
    if state.triggerBot and HAS_M1CLICK then
        local tk=getKey(state.triggerKey)
        if tk and (inp.KeyCode==tk or inp.UserInputType==tk) then
            if state.onePressTrigger then Triggering=not Triggering else Triggering=true end
        end
    end

    -- FOV / ESP toggles
    local fk=getKey(state.fovKey)
    if fk and (inp.KeyCode==fk or inp.UserInputType==fk) then
        ShowFov=not ShowFov; state.fovVisible=ShowFov
    end
    local ek=getKey(state.espKey)
    if ek and (inp.KeyCode==ek or inp.UserInputType==ek) then
        ShowESP=not ShowESP; state.espEnabled=ShowESP
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if not state.onePressAim and Aiming then
        local ak=getKey(state.aimKey)
        if ak and (inp.KeyCode==ak or inp.UserInputType==ak) then
            Aiming=false; Target=nil
            if AimTween then AimTween:Cancel(); AimTween=nil end
            UserInputService.MouseDeltaSensitivity=MouseSens; releaseCamera("aimbot")
        end
    end
    if not state.camlockToggle then
        local ck=getKey(state.camlockKeybind)
        if ck and inp.KeyCode==ck then
            state.camlockEnabled=false; stickyTarget=nil; releaseCamera("camlock")
        end
    end
    if not state.onePressSpinning and Spinning then
        local sk=getKey(state.spinKey)
        if sk and (inp.KeyCode==sk or inp.UserInputType==sk) then Spinning=false end
    end
    if not state.onePressTrigger and Triggering then
        local tk=getKey(state.triggerKey)
        if tk and (inp.KeyCode==tk or inp.UserInputType==tk) then Triggering=false end
    end
end)

-- Click TP
Mouse.Button3Down:Connect(function()
    if not state.clickTp then return end
    local hrp=getHRP()
    if hrp and Mouse.Hit then hrp.CFrame=Mouse.Hit*CFrame.new(0,3,0) end
end)

-- Window focus tracking (Open Aimbot)
UserInputService.WindowFocused:Connect(function() RobloxActive=true end)
UserInputService.WindowFocusReleased:Connect(function() RobloxActive=false end)

-- ══════════════════════════════════════════
-- [36] MAIN RENDER LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    -- Minimap
    MinimapFrame.Visible=state.minimap
    if state.minimap then
        local hrp=getHRP()
        if hrp then local rx,rz=worldToMM(hrp.Position); selfDot.Position=UDim2.new(rx,0,rz,0) end
        for _,plr in Players:GetPlayers() do
            if plr==Player then continue end
            local dot=getOrMakeMMDot(plr)
            local phrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if phrp then local rx,rz=worldToMM(phrp.Position); dot.Position=UDim2.new(rx,0,rz,0); dot.Visible=true
            else dot.Visible=false end
        end
        for plr,dot in mmDots do if not plr or not plr.Parent then dot:Destroy(); mmDots[plr]=nil end end
    end

    if not RobloxActive then return end

    -- SpinBot
    if Spinning and Player.Character then
        local part=Player.Character:FindFirstChild(state.spinPart)
        if part and part:IsA("BasePart") then
            part.CFrame=part.CFrame*CFrame.fromEulerAnglesXYZ(0,math.rad(state.spinVelocity),0)
        end
    end

    -- TriggerBot
    if HAS_M1CLICK and Triggering and (not state.smartTrigger or Aiming) then
        local tgt=Mouse.Target
        if tgt and IsReady(tgt:FindFirstAncestorWhichIsA("Model")) and MathHandler:CalcChance(state.triggerChance) then
            mouse1click()
        end
    end

    -- Random aim/spin part rotation (Open Aimbot)
    if os.clock()-Clock>=1 then
        if state.randomAimPart then
            local parts={"Head","HumanoidRootPart","Torso","UpperTorso"}
            state.aimPart=parts[Random.new():NextInteger(1,#parts)]
        end
        if state.randomSpinPart then
            local parts={"Head","HumanoidRootPart"}
            state.spinPart=parts[Random.new():NextInteger(1,#parts)]
        end
        Clock=os.clock()
    end

    -- FOV drawing
    updateFovDraw()

    -- ── AIMBOT ──
    if Aiming and state.aimEnabled then
        if not IsReady(Target) then
            if Target and state.offAfterKill then
                Aiming=false; Target=nil; releaseCamera("aimbot"); return
            end
            local closest=math.huge; Target=nil
            for _,plr in Players:GetPlayers() do
                local ready,char,vpPos=IsReady(plr.Character)
                if ready and vpPos[2] then
                    local mag=(Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(vpPos[1].X,vpPos[1].Y)).Magnitude
                    local fovOk=not state.fovCheck or mag<=state.fovRadius
                    if fovOk and mag<closest then closest=mag; Target=char end
                end
            end
        end

        local ready,_,vpPos,worldPos=IsReady(Target)
        if ready then
            if HAS_MOVEREL and state.aimMode=="Mouse" then
                if vpPos[2] then
                    local ml=UserInputService:GetMouseLocation()
                    local sens=state.useSensitivity and state.sensitivity/5 or 10
                    mousemoverel((vpPos[1].X-ml.X)/sens,(vpPos[1].Y-ml.Y)/sens)
                end
            elseif state.aimMode=="Camera" then
                UserInputService.MouseDeltaSensitivity=0
                -- Derive origin from player head (Open Aimbot fix)
                local myChar=Player.Character
                local myHead=myChar and myChar:FindFirstChild("Head")
                local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
                local origin=myHead and (myHead.Position+Vector3.new(0,0.5,0))
                    or myHRP and myHRP.Position or Camera.CFrame.Position
                if state.useSensitivity then
                    AimTween=TweenService:Create(Camera,
                        TweenInfo.new(math.clamp(state.sensitivity,9,99)/100,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
                        {CFrame=CFrame.new(origin,worldPos)})
                    AimTween:Play()
                else
                    local goalCF=CFrame.lookAt(origin,worldPos)
                    local alpha=1-(1-0.25)^(dt*60)
                    local lerpedRot=Camera.CFrame:Lerp(goalCF,alpha).Rotation
                    Camera.CFrame=CFrame.new(origin)*lerpedRot
                end
            end
            -- Silent handled by __namecall + __index hooks
        else
            Target=nil
            if AimTween then AimTween:Cancel(); AimTween=nil end
            UserInputService.MouseDeltaSensitivity=MouseSens
        end
    end

    -- ── CAMLOCK ──
    if state.camlockEnabled then
        if stickyTarget then
            local char=stickyTarget.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health<=0 or not stickyTarget.Parent then stickyTarget=nil end
        end
        if not stickyTarget then
            local closest,closestD=nil,math.huge
            local ml=Vector2.new(Mouse.X,Mouse.Y)
            for _,plr in Players:GetPlayers() do
                if plr==Player then continue end
                local char=plr.Character
                local part=char and (char:FindFirstChild(state.camlockPart) or char:FindFirstChild("Head"))
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if not part or not hum or hum.Health<=0 then continue end
                local sp,onS=Camera:WorldToViewportPoint(part.Position)
                if not onS then continue end
                local d=(Vector2.new(sp.X,sp.Y)-ml).Magnitude
                if d<closestD then closestD=d; closest=plr end
            end
            stickyTarget=closest
        end
        if stickyTarget and stickyTarget.Character then
            local part=stickyTarget.Character:FindFirstChild(state.camlockPart)
                or stickyTarget.Character:FindFirstChild("Head")
            if part then
                local myChar=Player.Character
                local myHead=myChar and myChar:FindFirstChild("Head")
                local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
                local origin=myHead and (myHead.Position+Vector3.new(0,0.5,0))
                    or myHRP and myHRP.Position or Camera.CFrame.Position
                local tPos=part.Position
                if state.useAdvanced and (state.predictX>0 or state.predictY>0) then
                    local hrp=stickyTarget.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        tPos=tPos+hrp.Velocity*Vector3.new(state.predictX*0.016,state.predictY*0.016,state.predictX*0.016)
                    end
                end
                local goalCF=CFrame.lookAt(origin,tPos)
                if state.useAdvanced and state.smoothingOn then
                    local sm=math.clamp(state.smoothX/20,0.01,1)
                    if state.camlockStyle=="Quadratic" then sm=sm*sm
                    elseif state.camlockStyle=="Sine" then sm=math.sin(sm*math.pi/2) end
                    local alpha=1-(1-sm)^(dt*60)
                    local lr=Camera.CFrame:Lerp(goalCF,alpha).Rotation
                    Camera.CFrame=CFrame.new(origin)*lr
                else
                    local alpha=1-(1-0.3)^(dt*60)
                    local lr=Camera.CFrame:Lerp(goalCF,alpha).Rotation
                    Camera.CFrame=CFrame.new(origin)*lr
                end
            end
        end
    else
        stickyTarget=nil
    end

    -- ── ESP ──
    for plr in espObjects do
        if not plr or not plr.Parent then destroyESP(espObjects[plr]); espObjects[plr]=nil end
    end
    for _,plr in Players:GetPlayers() do
        if plr==Player then continue end
        if not ShowESP then if espObjects[plr] then hideESP(espObjects[plr]) end; continue end
        updateESP(plr)
    end
end)

-- ══════════════════════════════════════════
-- [37] HEARTBEAT LOOPS
-- ══════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local hum=getHum()
    if hum then
        if state.speedBoost then
            hum.WalkSpeed=80
        elseif state.sprintEnabled
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            and not state.flyEnabled then
            hum.WalkSpeed=state.sprintSpeed
        else
            hum.WalkSpeed=state.walkSpeed
        end
        hum.JumpPower=state.jumpPower
    end
end)

-- ══════════════════════════════════════════
-- [38] PLAYER EVENTS
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then destroyESP(espObjects[plr]); espObjects[plr]=nil end
    if mmDots[plr] then mmDots[plr]:Destroy(); mmDots[plr]=nil end
    lastHealths[plr]=nil
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5); if ShowESP then updateESP(plr) end
    end)
end)

Player.CharacterAdded:Connect(function()
    state.flyEnabled=false; bv=nil; bg=nil
    stickyTarget=nil; Target=nil; Aiming=false
    jumpCooldown=false; cameraOwner="none"
    Camera.CameraType=Enum.CameraType.Custom
    UserInputService.MouseDeltaSensitivity=MouseSens
end)

game:BindToClose(function()
    saveConfig()
    for _,d in espObjects do destroyESP(d) end
    if FovDraw then safeExec(function() FovDraw:Remove() end) end
end)

-- ══════════════════════════════════════════
-- [39] INIT
-- ══════════════════════════════════════════
buildCrosshair()
ShowFov=state.fovVisible
ShowESP=state.espEnabled
activateTab(tAimbot)
