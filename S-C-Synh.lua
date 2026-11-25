local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local WORK_FILE = "dmx_ui_work.json"
local SHOWS_FILE = "dmx_ui_shows.json"

local guiParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("ApexDMXStudio") then
    guiParent:FindFirstChild("ApexDMXStudio"):Destroy()
end

local FIXTURE_FOOTPRINTS = {
    clara = 16,
    strobe = 8,
    mapple = 16,
    parled = 6,
    fogger = 1,
    blinder = 4,
    flower = 18,
    pixel = 20,
    retro = 12,
    wall = 8,
    windmill = 8,
    sbar = 8
}

local FIXTURE_KEYS_ORDER = {
    clara = {"dim", "strobe", "pan", "tilt", "speed", "color", "gobo", "gobor", "prism", "prism2", "prot", "frost", "focus", "ctrl"},
    strobe = {"int", "shutter", "col1", "pos6", "fx2", "cont2", "macro1", "macro2"},
    mapple = {"rdim", "rstrobe", "rc1", "rc2", "rc3", "rmac", "adim", "astrobe", "acol", "amac", "bdim", "bcol", "bmac", "mpos", "mmode"},
    parled = {"dim", "strobe", "r", "g", "b", "w"},
    fogger = {"fog"},
    blinder = {"d1", "d2", "d3", "d4"},
    flower = {"d1", "d2", "b1", "b2", "r1", "r2", "g1", "g2", "s1", "s2", "m1", "m2", "ms1", "ms2", "mo1", "mo2", "str"},
    pixel = {"mdim", "mstrb", "mr", "mg", "mb", "meff", "mespd", "mstat", "mmac", "adim", "astrb", "aeff", "aespd", "astat", "tilt", "teff", "tspd", "tsprd", "zoom"},
    retro = {"r", "g", "b", "str", "dins", "dref", "dring", "mref", "mring", "eref", "ering"},
    wall = {"dim", "strobe", "r", "g", "b", "eff", "spd"},
    windmill = {"dim", "str", "r", "g", "b", "rot", "ei", "eo"},
    sbar = {"dim", "strobe", "r", "g", "b", "eff", "spd"}
}

local FIXTURE_DEFAULTS = {
    clara = {tilt=0.5, gobor=0, color=0, strobe=0, prism=0, pan=0.5, frost=0, ctrl=0, dim=1, focus=0.5, speed=0, gobo=0, prot=0, prism2=0},
    strobe = {shutter=0, col1=0, int=1, cont2=0, fx2=0, pos6=0.5, macro2=0, macro1=0},
    mapple = {rc3=0, mpos=0.5, rc1=0, rmac=0, mmode=0, astrobe=0, amac=0, acol=0, rstrobe=0, rdim=1, adim=1, rc2=0, bdim=1, bmac=0, bcol=0},
    parled = {strobe=0, dim=1, r=1, b=1, w=0, g=1},
    fogger = {fog=1},
    blinder = {d2=1, d3=1, d1=1, d4=1},
    flower = {str=0, b1=1, b2=1, d2=1, d1=1, g1=0, ms2=0, g2=0, mo2=0, mo1=0, m2=0, m1=0, ms1=0, s1=0, r1=1, r2=1, s2=0},
    pixel = {meff=0, astrb=0, astat=0, teff=0, mstrb=0, mdim=1, tilt=0.5, mmac=0, aeff=0, mb=1, mstat=0, mr=1, mespd=0, tspd=0, aespd=0, mg=1, adim=1, tsprd=0, zoom=0.5},
    retro = {str=0, mref=0, r=1, g=1, dins=1, eref=0, dref=1, mring=0, dring=1, ering=0, b=1},
    wall = {strobe=0, dim=1, r=1, b=1, eff=0, g=1, spd=0},
    windmill = {str=0, eo=0, dim=1, b=1, ei=0, rot=0, g=1, r=1},
    sbar = {strobe=0, dim=1, r=1, b=1, eff=0, g=1, spd=0}
}

local EFFECT_TEMPLATES = {
    {name="Circle Smooth", layer="mov", target="pos", shape="circle", rate=0.35, sx=0.35, sy=0.35, phase=0, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Circle Mirror Wing", layer="mov", target="pos", shape="circle", rate=0.4, sx=0.35, sy=0.35, phase=0, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
    {name="Figure-8 Wide", layer="mov", target="pos", shape="fig8", rate=0.3, sx=0.45, sy=0.3, phase=0, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Figure-8 Vertical", layer="mov", target="pos", shape="fig8", rate=0.35, sx=0.25, sy=0.45, phase=180, wing=2, groups=1, dir=">", wax="y", dty=0.5, soft=0},
    {name="Pan Sweep Sine", layer="mov", target="pos", shape="sine", rate=0.45, sx=0.45, sy=0, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
    {name="Tilt Wave Bounce", layer="mov", target="pos", shape="sine", rate=0.5, sx=0, sy=0.4, phase=180, wing=2, groups=1, dir=">", wax="y", dty=0.5, soft=0},
    {name="Tilt Fly-Up Saw", layer="mov", target="pos", shape="saw", rate=0.55, sx=0, sy=0.45, phase=180, wing=0, groups=0, dir=">", wax="y", dty=0.5, soft=0.1},
    {name="Ballyhoo Chaos", layer="mov", target="pos", shape="random", rate=0.6, sx=0.4, sy=0.4, phase=360, wing=0, groups=0, dir="<>", wax="x", dty=0.5, soft=0.15},
    {name="Color Rainbow Saw", layer="eff", target="color", shape="saw", rate=0.6, sx=0.3, sy=0.3, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.55, soft=0.25},
    {name="Color Snap 2-Group", layer="eff", target="color", shape="square", rate=1.0, sx=0.3, sy=0.3, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.5, soft=0},
    {name="Color Wave Sine", layer="eff", target="color", shape="sine", rate=0.5, sx=0.4, sy=0.4, phase=360, wing=2, groups=0, dir="<>", wax="x", dty=0.5, soft=0.3},
    {name="Dimmer Chase Pulse", layer="eff", target="dim", shape="sine", rate=1.2, sx=0.5, sy=0.5, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.5, soft=0.2},
    {name="Dimmer Hard Flash", layer="eff", target="dim", shape="square", rate=2.0, sx=0.5, sy=0.5, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.35, soft=0},
    {name="Strobe Burst PingPong", layer="eff", target="strobe", shape="square", rate=1.5, sx=0.3, sy=0.3, phase=360, wing=0, groups=0, dir="<>", wax="x", dty=0.2, soft=0.1},
    {name="Beam Prism/Gobo Flip", layer="eff", target="beam", shape="square", rate=0.8, sx=0.3, sy=0.3, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.5, soft=0},
    {name="Beam Frost Pulse", layer="eff", target="beam", shape="sine", rate=0.65, sx=0.4, sy=0.4, phase=180, wing=2, groups=0, dir=">", wax="x", dty=0.5, soft=0.25}
}

local POSE_PRESETS = {
    {name="Center Home", vals={pan=0.5, tilt=0.5, dim=1, color=0, gobo=0, prism=0, frost=0, focus=0.5, strobe=0, speed=0, int=1, r=1, g=1, b=1, w=1, mr=1, mg=1, mb=1, d1=1, d2=1, d3=1, d4=1, fog=1}},
    {name="Audience Blinder", vals={pan=0.5, tilt=0.15, dim=1, color=0, gobo=0, prism=0, frost=0.3, focus=0.3, strobe=0, speed=0, int=1, r=1, g=0.9, b=0.8, w=1, mr=1, mg=0.9, mb=0.8, d1=1, d2=1, d3=1, d4=1}},
    {name="Sky Beam High", vals={pan=0.5, tilt=0.88, dim=1, color=0, gobo=0, prism=0, frost=0, focus=0.5, strobe=0, speed=0, int=1, r=0.2, g=0.6, b=1, w=0, mr=0.2, mg=0.6, mb=1}},
    {name="Prism 9-Dot Split", vals={pan=0.5, tilt=0.45, dim=1, color=0.35, gobo=0.35, prism=0.6, frost=0, focus=0.4, strobe=0, speed=0}},
    {name="Grid 9-Box Red", vals={pan=0.5, tilt=0.5, dim=1, color=0.62, gobo=0.91, prism=0, frost=0, focus=0.5, strobe=0, speed=0, r=1, g=0, b=0, w=0, mr=1, mg=0, mb=0}},
    {name="Cross Left-Right", vals={pan=0.2, tilt=0.35, dim=1, color=0.2, gobo=0, prism=0, frost=0, focus=0.5, strobe=0, speed=0}},
    {name="Blackout (All 0)", vals={dim=0, int=0, r=0, g=0, b=0, w=0, mr=0, mg=0, mb=0, mdim=0, adim=0, rdim=0, bdim=0, d1=0, d2=0, d3=0, d4=0, dins=0, dref=0, dring=0, fog=0, strobe=0, str=0, shutter=0}}
}

local RGB_COLOR_PRESETS = {
    {name="Pure Red", color=Color3.fromRGB(235, 55, 55), vals={r=1, g=0, b=0, w=0, mr=1, mg=0, mb=0, color=0.15, col1=0.15, acol=0.15, bcol=0.15}},
    {name="Pure Green", color=Color3.fromRGB(50, 210, 95), vals={r=0, g=1, b=0, w=0, mr=0, mg=1, mb=0, color=0.30, col1=0.30, acol=0.30, bcol=0.30}},
    {name="Pure Blue", color=Color3.fromRGB(55, 125, 245), vals={r=0, g=0, b=1, w=0, mr=0, mg=0, mb=1, color=0.45, col1=0.45, acol=0.45, bcol=0.45}},
    {name="Cool White", color=Color3.fromRGB(235, 242, 255), vals={r=1, g=1, b=1, w=1, mr=1, mg=1, mb=1, color=0.0, col1=0.0, acol=0.0, bcol=0.0}},
    {name="Warm White", color=Color3.fromRGB(255, 215, 155), vals={r=1, g=0.78, b=0.45, w=0.85, mr=1, mg=0.78, mb=0.45, color=0.08, col1=0.08, acol=0.08, bcol=0.08}},
    {name="Cyan Aqua", color=Color3.fromRGB(45, 220, 230), vals={r=0, g=1, b=1, w=0, mr=0, mg=1, mb=1, color=0.55, col1=0.55, acol=0.55, bcol=0.55}},
    {name="Magenta Pink", color=Color3.fromRGB(235, 65, 195), vals={r=1, g=0, b=1, w=0, mr=1, mg=0, mb=1, color=0.70, col1=0.70, acol=0.70, bcol=0.70}},
    {name="Yellow Gold", color=Color3.fromRGB(245, 205, 45), vals={r=1, g=0.85, b=0, w=0, mr=1, mg=0.85, mb=0, color=0.22, col1=0.22, acol=0.22, bcol=0.22}},
    {name="Amber Orange", color=Color3.fromRGB(245, 125, 35), vals={r=1, g=0.38, b=0, w=0, mr=1, mg=0.38, mb=0, color=0.12, col1=0.12, acol=0.12, bcol=0.12}},
    {name="UV Purple", color=Color3.fromRGB(135, 60, 240), vals={r=0.45, g=0, b=1, w=0, mr=0.45, mg=0, mb=1, color=0.82, col1=0.82, acol=0.82, bcol=0.82}},
    {name="Hot Coral", color=Color3.fromRGB(250, 95, 110), vals={r=1, g=0.22, b=0.32, w=0.1, mr=1, mg=0.22, mb=0.32, color=0.62, col1=0.62, acol=0.62, bcol=0.62}},
    {name="Mint Lime", color=Color3.fromRGB(125, 245, 130), vals={r=0.35, g=1, b=0.35, w=0.1, mr=0.35, mg=1, mb=0.35, color=0.38, col1=0.38, acol=0.38, bcol=0.38}}
}

local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[deepCopy(k)] = deepCopy(v)
    end
    return copy
end

local function makeFullV(fixtureType, overrides)
    local t = string.lower(tostring(fixtureType or "clara"))
    local base = FIXTURE_DEFAULTS[t] or FIXTURE_DEFAULTS.clara
    local v = deepCopy(base)
    if type(overrides) == "table" then
        for k, val in pairs(overrides) do
            if v[k] ~= nil then
                v[k] = math.clamp(tonumber(val) or 0, 0, 1)
            end
        end
    end
    return v
end

local function makeEmptyEffSlot()
    return {
        dty = 0.5, amt = 0, dep = 1, wmir = true, ca = 1,
        wing = 0, groups = 0, useShut = true, target = "dim",
        block = 1, wax = "x", ph = 0, sval = 0.5, dir = ">",
        phase = 360, on = false, cb = 3, sy = 0.3, sx = 0.3,
        members = {}, soft = 0, shape = "square", unused = true, rate = 0.4
    }
end

local function buildEffObject(cfg, membersList, isActive)
    local eff = makeEmptyEffSlot()
    eff.target = cfg.target or "pos"
    eff.shape = cfg.shape or "circle"
    eff.on = isActive and true or false
    eff.unused = not eff.on
    eff.rate = tonumber(cfg.rate) or 0.3
    eff.sx = math.clamp(tonumber(cfg.sx) or 0.3, 0, 1)
    eff.sy = math.clamp(tonumber(cfg.sy) or 0.3, 0, 1)
    eff.phase = tonumber(cfg.phase) or 360
    eff.wing = math.floor(tonumber(cfg.wing) or 0)
    eff.groups = math.floor(tonumber(cfg.groups) or 0)
    eff.dir = cfg.dir or ">"
    eff.wax = cfg.wax or "x"
    eff.dty = math.clamp(tonumber(cfg.dty) or 0.5, 0, 1)
    eff.soft = math.clamp(tonumber(cfg.soft) or 0, 0, 1)
    eff.members = deepCopy(membersList or {})
    return eff
end

local function normalizeEffArray(effArr)
    local out = {}
    if type(effArr) == "table" then
        for i = 1, math.min(6, #effArr) do
            out[i] = effArr[i]
        end
    end
    while #out < 6 do
        table.insert(out, makeEmptyEffSlot())
    end
    return out
end

local function sanitizeWorkStructure(data)
    data.v = data.v or 3
    data.gm = math.clamp(tonumber(data.gm) or 100, 0, 100)
    data.fade = math.max(0, tonumber(data.fade) or 0)
    data.sg = data.sg or {}
    data.keys = data.keys or {}
    data.rig = data.rig or {}
    for _, fix in ipairs(data.rig) do
        fix.t = string.lower(tostring(fix.t or "clara"))
        fix.a = math.max(1, math.floor(tonumber(fix.a) or 1))
        fix.x = math.clamp(tonumber(fix.x) or 0.5, 0, 1)
        fix.y = math.clamp(tonumber(fix.y) or 0.5, 0, 1)
        fix.v = makeFullV(fix.t, fix.v)
    end
    data.eff = normalizeEffArray(data.eff)
    data.chase = data.chase or {off = 0, seq = false, dir = ">", scope = "all", glide = 0, rate = 1, steps = {}}
    if type(data.cues) ~= "table" then
        data.cues = {}
    end
    return data
end

local function defaultWorkData()
    local rig = {}
    for i = 1, 8 do
        table.insert(rig, {
            a = 1 + ((i - 1) * 16),
            x = math.floor((0.1 + ((i - 1) * 0.11)) * 100 + 0.5) / 100,
            y = 0.5,
            t = "clara",
            v = makeFullV("clara")
        })
    end
    return sanitizeWorkStructure({
        v = 3,
        gm = 100,
        fade = 0,
        sg = {},
        keys = {},
        eff = normalizeEffArray({}),
        chase = {off = 0, seq = false, dir = ">", scope = "all", glide = 0, rate = 1, steps = {}},
        cues = {},
        rig = rig
    })
end

local workData = defaultWorkData()
local showsData = {}

local function loadWorkFile()
    if isfile and readfile and isfile(WORK_FILE) then
        local ok, raw = pcall(readfile, WORK_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if ok2 and type(decoded) == "table" then
                workData = sanitizeWorkStructure(decoded)
                return true, "Loaded " .. WORK_FILE
            end
        end
    end
    return false, "Default memory ready"
end

local function saveWorkFile()
    if not writefile then
        return false, "Executor tidak mendukung writefile"
    end
    workData = sanitizeWorkStructure(workData)
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(workData)
    end)
    if not ok then
        return false, "Gagal encode JSON"
    end
    local minified = string.gsub(encoded, "[\r\n]", "")
    local okWrite, err = pcall(writefile, WORK_FILE, minified)
    if not okWrite then
        return false, tostring(err)
    end
    return true, "Tersimpan MINIFY -> " .. WORK_FILE
end

local function loadShowsFile()
    if isfile and readfile and isfile(SHOWS_FILE) then
        local ok, raw = pcall(readfile, SHOWS_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if ok2 and type(decoded) == "table" then
                showsData = decoded
                return true
            end
        end
    end
    showsData = {}
    return false
end

local function saveShowsFile()
    if not writefile then
        return false, "Executor tidak mendukung writefile"
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(showsData)
    end)
    if not ok then
        return false, "Gagal encode shows JSON"
    end
    local minified = string.gsub(encoded, "[\r\n]", "")
    local okWrite, err = pcall(writefile, SHOWS_FILE, minified)
    if not okWrite then
        return false, tostring(err)
    end
    return true, "Show tersimpan MINIFY -> " .. SHOWS_FILE
end

loadWorkFile()
loadShowsFile()

local selectedMembers = {}
local function resetSelectionAll()
    selectedMembers = {}
    for i = 1, #workData.rig do
        selectedMembers[i] = true
    end
end
resetSelectionAll()

local function getSelectedMemberIndices()
    local list = {}
    for i = 1, #workData.rig do
        if selectedMembers[i] then
            table.insert(list, i)
        end
    end
    if #list == 0 and #workData.rig > 0 then
        table.insert(list, 1)
    end
    return list
end

local function getSelectedFxEmptyMap()
    local map = {}
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            map[tostring(idx)] = {
                t = string.lower(fix.t or "clara"),
                v = {}
            }
        end
    end
    return map
end

local state = {
    cueId = "1",
    layerMode = "mov",
    target = "pos",
    shape = "circle",
    dir = ">",
    wax = "x",
    rate = 0.35,
    sx = 0.35,
    sy = 0.35,
    phase = 360,
    wing = 0,
    groups = 0,
    dty = 0.5,
    soft = 0,
    slotIndex = 1,
    chaseRate = 2,
    chaseGlide = 0.3,
    chaseDir = ">",
    chaseSteps = {},
    editorFixtureType = "clara",
    staticLayerType = "pos",
    editorValues = deepCopy(FIXTURE_DEFAULTS.clara),
    rigType = "clara",
    rigCount = 8,
    rigMode = "independen",
    rigStartAddr = 1,
    previewActive = false
}

local screen = Instance.new("ScreenGui")
screen.Name = "ApexDMXStudio"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = guiParent

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 650, 0, 470)
main.Position = UDim2.new(0.5, -325, 0.5, -235)
main.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
main.BorderSizePixel = 0
main.Parent = screen

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(52, 60, 82)
mainStroke.Thickness = 1.2
mainStroke.Parent = main

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = Color3.fromRGB(23, 27, 36)
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 270, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "APEX DMX MOTION STUDIO  |  RK-512"
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextColor3 = Color3.fromRGB(115, 200, 255)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 280, 1, 0)
statusLbl.Position = UDim2.new(1, -355, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Ready: " .. WORK_FILE
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextColor3 = Color3.fromRGB(150, 230, 165)
statusLbl.TextXAlignment = Enum.TextXAlignment.Right
statusLbl.Parent = topBar

local function setStatus(msg, isErr)
    statusLbl.Text = tostring(msg)
    statusLbl.TextColor3 = isErr and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(150, 230, 165)
end

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 24)
minBtn.Position = UDim2.new(1, -66, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.fromRGB(235, 240, 250)
minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(175, 55, 65)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = minimized and UDim2.new(0, 650, 0, 38) or UDim2.new(0, 650, 0, 470)
    minBtn.Text = minimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    state.previewActive = false
    screen:Destroy()
end)

do
    local dragging, dragInput, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -38)
body.Position = UDim2.new(0, 0, 0, 38)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.Parent = main

local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, -20, 0, 32)
navBar.Position = UDim2.new(0, 10, 0, 8)
navBar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
navBar.BorderSizePixel = 0
navBar.Parent = body
Instance.new("UICorner", navBar).CornerRadius = UDim.new(0, 7)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 5)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Parent = navBar

local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 6)
navPad.Parent = navBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -20, 1, -92)
contentArea.Position = UDim2.new(0, 10, 0, 46)
contentArea.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
contentArea.BorderSizePixel = 0
contentArea.Parent = body
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local footerBar = Instance.new("Frame")
footerBar.Size = UDim2.new(1, -20, 0, 36)
footerBar.Position = UDim2.new(0, 10, 1, -42)
footerBar.BackgroundColor3 = Color3.fromRGB(23, 27, 36)
footerBar.BorderSizePixel = 0
footerBar.Parent = body
Instance.new("UICorner", footerBar).CornerRadius = UDim.new(0, 8)

local pages = {}
local tabButtons = {}

local function switchTab(tabKey)
    for k, page in pairs(pages) do
        page.Visible = (k == tabKey)
    end
    for k, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (k == tabKey) and Color3.fromRGB(48, 115, 220) or Color3.fromRGB(34, 39, 52)
        btn.TextColor3 = (k == tabKey) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 195, 215)
    end
end

local function createTab(key, label, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 98, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(34, 39, 52)
    btn.Text = label
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(185, 195, 215)
    btn.Parent = navBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -12)
    scroll.Position = UDim2.new(0, 6, 0, 6)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.Parent = contentArea

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = scroll

    pages[key] = scroll
    tabButtons[key] = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(key)
    end)

    return scroll
end

local function makeSection(parent, title)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -6, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
    box.BorderSizePixel = 0
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = box

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = box

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 18)
    hdr.BackgroundTransparency = 1
    hdr.Text = title
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 12
    hdr.TextColor3 = Color3.fromRGB(130, 195, 255)
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Parent = box

    return box
end

local function makeSliderRow(parent, labelText, minVal, maxVal, defaultVal, isInt, onChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 155, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(215, 222, 235)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -225, 0, 10)
    track.Position = UDim2.new(0, 160, 0.5, -5)
    track.BackgroundColor3 = Color3.fromRGB(44, 50, 66)
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(65, 145, 250)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(0, 54, 0, 22)
    valBox.Position = UDim2.new(1, -54, 0.5, -11)
    valBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
    valBox.TextColor3 = Color3.fromRGB(240, 245, 255)
    valBox.Font = Enum.Font.GothamSemibold
    valBox.TextSize = 11
    valBox.ClearTextOnFocus = false
    valBox.Parent = row
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 5)

    local currentVal = defaultVal

    local function applyValue(v, fireCallback)
        v = math.clamp(v, minVal, maxVal)
        if isInt then
            v = math.floor(v + 0.5)
        else
            v = math.floor((v * 100) + 0.5) / 100
        end
        currentVal = v
        local alpha = (maxVal > minVal) and ((v - minVal) / (maxVal - minVal)) or 0
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valBox.Text = isInt and tostring(v) or string.format("%.2f", v)
        if fireCallback and onChanged then
            onChanged(v)
        end
    end

    applyValue(defaultVal, false)

    local sliding = false
    local function updateFromInput(input)
        local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X)
        rel = math.clamp(rel, 0, 1)
        local mapped = minVal + (rel * (maxVal - minVal))
        applyValue(mapped, true)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    valBox.FocusLost:Connect(function()
        local num = tonumber(valBox.Text)
        if num then
            applyValue(num, true)
        else
            applyValue(currentVal, false)
        end
    end)

    return {
        row = row,
        setValue = function(v)
            applyValue(v, false)
        end,
        getValue = function()
            return currentVal
        end
    }
end

local function makeChipSelector(parent, labelText, options, initialVal, onSelect)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(185, 195, 215)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 0)
    wrap.Position = UDim2.new(0, 0, 0, 18)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.BackgroundTransparency = 1
    wrap.Parent = holder

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 88, 0, 24)
    grid.CellPadding = UDim2.new(0, 5, 0, 5)
    grid.Parent = wrap

    local chips = {}
    local current = initialVal

    local function refresh(val)
        current = val
        for optVal, btn in pairs(chips) do
            local active = (optVal == current)
            btn.BackgroundColor3 = active and Color3.fromRGB(52, 125, 230) or Color3.fromRGB(38, 44, 58)
            btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(195, 205, 220)
        end
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
        btn.Text = tostring(opt)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(195, 205, 220)
        btn.Parent = wrap
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        chips[opt] = btn

        btn.MouseButton1Click:Connect(function()
            refresh(opt)
            if onSelect then
                onSelect(opt)
            end
        end)
    end

    refresh(initialVal)

    return {
        setSelected = refresh,
        getSelected = function()
            return current
        end
    }
end

local function makeSmallActionBtn(parent, text, posX, width, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width, 0, 24)
    b.Position = UDim2.new(0, posX, 0, 0)
    b.BackgroundColor3 = color
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(callback)
    return b
end

local pageTemplates = createTab("templates", "Templates", 88)
local pageCustom = createTab("custom", "Custom FX", 88)
local pageStatic = createTab("static", "Static / RGB", 94)
local pageChase = createTab("chase", "Chase Seq", 88)
local pageRig = createTab("rig", "Rig & DMX", 88)
local pageShows = createTab("shows", "Cue / Shows", 96)

local refreshMembersUI
local refreshCuesListUI
local refreshRigEditorUI
local refreshChaseStepsUI
local refreshShowsListUI
local rebuildDynamicFixtureSliders
local loadCueIntoEditor

local secMembers = makeSection(pageTemplates, "1. PILIH LAMPU TARGET (MEMBERS INDEKS RIG)")

local memberToolsRow = Instance.new("Frame")
memberToolsRow.Size = UDim2.new(1, 0, 0, 24)
memberToolsRow.BackgroundTransparency = 1
memberToolsRow.Parent = secMembers

makeSmallActionBtn(memberToolsRow, "Pilih Semua", 0, 92, Color3.fromRGB(48, 115, 215), function()
    for i = 1, #workData.rig do selectedMembers[i] = true end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Ganjil (1,3,5..)", 98, 108, Color3.fromRGB(44, 54, 74), function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 1) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Genap (2,4,6..)", 212, 108, Color3.fromRGB(44, 54, 74), function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 0) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Reset", 326, 66, Color3.fromRGB(115, 50, 58), function()
    for i = 1, #workData.rig do selectedMembers[i] = false end
    selectedMembers[1] = true
    if refreshMembersUI then refreshMembersUI() end
end)

local memberGridHolder = Instance.new("Frame")
memberGridHolder.Size = UDim2.new(1, 0, 0, 0)
memberGridHolder.AutomaticSize = Enum.AutomaticSize.Y
memberGridHolder.BackgroundTransparency = 1
memberGridHolder.Parent = secMembers

local memberGrid = Instance.new("UIGridLayout")
memberGrid.CellSize = UDim2.new(0, 82, 0, 26)
memberGrid.CellPadding = UDim2.new(0, 5, 0, 5)
memberGrid.Parent = memberGridHolder

refreshMembersUI = function()
    for _, child in ipairs(memberGridHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for i, fix in ipairs(workData.rig) do
        local b = Instance.new("TextButton")
        local active = selectedMembers[i] == true
        b.BackgroundColor3 = active and Color3.fromRGB(50, 165, 110) or Color3.fromRGB(38, 44, 58)
        b.Text = "#" .. i .. " " .. string.upper(string.sub(fix.t or "?", 1, 4)) .. " (" .. tostring(fix.a) .. ")"
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Parent = memberGridHolder
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

        b.MouseButton1Click:Connect(function()
            selectedMembers[i] = not selectedMembers[i]
            refreshMembersUI()
        end)
    end
end

local secTpl = makeSection(pageTemplates, "2. TEMPLATE GERAKAN & EFEK SIAP PAKAI (16 PRESET)")

local tplGridWrap = Instance.new("Frame")
tplGridWrap.Size = UDim2.new(1, 0, 0, 0)
tplGridWrap.AutomaticSize = Enum.AutomaticSize.Y
tplGridWrap.BackgroundTransparency = 1
tplGridWrap.Parent = secTpl

local tplGrid = Instance.new("UIGridLayout")
tplGrid.CellSize = UDim2.new(0.49, 0, 0, 32)
tplGrid.CellPadding = UDim2.new(0.02, 0, 0, 6)
tplGrid.Parent = tplGridWrap

local function applyEffectToCue(cueKey, layerName, slotIdx, effConfig)
    local members = getSelectedMemberIndices()
    local effObj = buildEffObject(effConfig, members, true)
    local existingCue = workData.cues[cueKey]

    if layerName == "mov" then
        workData.cues[cueKey] = {
            layer = "mov",
            fx = getSelectedFxEmptyMap(),
            eff = {effObj}
        }
    else
        local cueEffArr
        if existingCue and existingCue.layer == "eff" and type(existingCue.eff) == "table" then
            cueEffArr = normalizeEffArray(deepCopy(existingCue.eff))
        else
            cueEffArr = normalizeEffArray(deepCopy(workData.eff))
        end
        local idx = math.clamp(slotIdx or 1, 1, 6)
        cueEffArr[idx] = effObj
        workData.eff[idx] = deepCopy(effObj)
        workData.eff[idx].on = false
        workData.eff[idx].unused = nil
        workData.cues[cueKey] = {
            layer = "eff",
            fx = getSelectedFxEmptyMap(),
            eff = cueEffArr
        }
    end
end

local customControls = {}

for _, tpl in ipairs(EFFECT_TEMPLATES) do
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = (tpl.layer == "mov") and Color3.fromRGB(40, 72, 125) or Color3.fromRGB(68, 52, 112)
    btn.Text = tpl.name .. "  [" .. string.upper(tpl.shape) .. "]"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(240, 245, 255)
    btn.Parent = tplGridWrap
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        state.layerMode = tpl.layer
        state.target = tpl.target
        state.shape = tpl.shape
        state.rate = tpl.rate
        state.sx = tpl.sx
        state.sy = tpl.sy
        state.phase = tpl.phase
        state.wing = tpl.wing
        state.groups = tpl.groups
        state.dir = tpl.dir
        state.wax = tpl.wax
        state.dty = tpl.dty
        state.soft = tpl.soft

        if customControls.syncFromState then
            customControls.syncFromState()
        end

        applyEffectToCue(state.cueId, tpl.layer, state.slotIndex, tpl)
        if refreshCuesListUI then refreshCuesListUI() end
        setStatus("Template '" .. tpl.name .. "' -> Cue " .. state.cueId, false)
    end)
end

local secCustomTop = makeSection(pageCustom, "1. KONFIGURASI LAYER, TARGET & ALGORITMA BENTUK")

local chipLayer = makeChipSelector(secCustomTop, "Mode Layer (mov = Gerak Tunggal, eff = Multi-Slot 6 Efek):", {"mov", "eff"}, state.layerMode, function(v)
    state.layerMode = v
end)

local chipTarget = makeChipSelector(secCustomTop, "Target Parameter:", {"pos", "color", "dim", "strobe", "beam"}, state.target, function(v)
    state.target = v
end)

local chipShape = makeChipSelector(secCustomTop, "Algoritma Bentuk (Shape):", {"circle", "fig8", "sine", "saw", "square", "random"}, state.shape, function(v)
    state.shape = v
end)

local chipDir = makeChipSelector(secCustomTop, "Arah & Sumbu (Dir / Axis):", {">", "<", "<>", "rand"}, state.dir, function(v)
    state.dir = v
end)

local chipWax = makeChipSelector(secCustomTop, "Sumbu Utama (wax):", {"x", "y"}, state.wax, function(v)
    state.wax = v
end)

local secCustomSliders = makeSection(pageCustom, "2. PARAMETER PRESISI (SKALA 0.0 - 1.0 & FASE)")

local sldSlot = makeSliderRow(secCustomSliders, "Slot Effect (Layer eff)", 1, 6, state.slotIndex, true, function(v) state.slotIndex = v end)
local sldRate = makeSliderRow(secCustomSliders, "Rate (Kecepatan)", 0.05, 5.0, state.rate, false, function(v) state.rate = v end)
local sldSx = makeSliderRow(secCustomSliders, "Size X / Pan (sx)", 0.0, 1.0, state.sx, false, function(v) state.sx = v end)
local sldSy = makeSliderRow(secCustomSliders, "Size Y / Tilt (sy)", 0.0, 1.0, state.sy, false, function(v) state.sy = v end)
local sldPhase = makeSliderRow(secCustomSliders, "Phase (0 - 360 Deg)", 0, 360, state.phase, true, function(v) state.phase = v end)
local sldWing = makeSliderRow(secCustomSliders, "Wing (Pantulan)", 0, 8, state.wing, true, function(v) state.wing = v end)
local sldGroups = makeSliderRow(secCustomSliders, "Groups (Grup Fase)", 0, 8, state.groups, true, function(v) state.groups = v end)
local sldDty = makeSliderRow(secCustomSliders, "Duty Cycle (dty)", 0.0, 1.0, state.dty, false, function(v) state.dty = v end)
local sldSoft = makeSliderRow(secCustomSliders, "Softness (soft)", 0.0, 1.0, state.soft, false, function(v) state.soft = v end)

customControls.syncFromState = function()
    chipLayer.setSelected(state.layerMode)
    chipTarget.setSelected(state.target)
    chipShape.setSelected(state.shape)
    chipDir.setSelected(state.dir)
    chipWax.setSelected(state.wax)
    sldSlot.setValue(state.slotIndex)
    sldRate.setValue(state.rate)
    sldSx.setValue(state.sx)
    sldSy.setValue(state.sy)
    sldPhase.setValue(state.phase)
    sldWing.setValue(state.wing)
    sldGroups.setValue(state.groups)
    sldDty.setValue(state.dty)
    sldSoft.setValue(state.soft)
end

local applyCustomBtn = Instance.new("TextButton")
applyCustomBtn.Size = UDim2.new(1, 0, 0, 32)
applyCustomBtn.BackgroundColor3 = Color3.fromRGB(45, 155, 95)
applyCustomBtn.Text = "TERAPKAN CUSTOM EFFECT KE CUE AKTIF"
applyCustomBtn.Font = Enum.Font.GothamBold
applyCustomBtn.TextSize = 12
applyCustomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyCustomBtn.Parent = secCustomSliders
Instance.new("UICorner", applyCustomBtn).CornerRadius = UDim.new(0, 6)

applyCustomBtn.MouseButton1Click:Connect(function()
    applyEffectToCue(state.cueId, state.layerMode, state.slotIndex, state)
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Custom Effect (" .. state.shape .. ") -> Cue " .. state.cueId, false)
end)

local secRgbPalette = makeSection(pageStatic, "1. PALET WARNA RGB & COLOR WHEEL INSTAN (12 WARNA)")

local rgbGridWrap = Instance.new("Frame")
rgbGridWrap.Size = UDim2.new(1, 0, 0, 0)
rgbGridWrap.AutomaticSize = Enum.AutomaticSize.Y
rgbGridWrap.BackgroundTransparency = 1
rgbGridWrap.Parent = secRgbPalette

local rgbGrid = Instance.new("UIGridLayout")
rgbGrid.CellSize = UDim2.new(0.24, 0, 0, 26)
rgbGrid.CellPadding = UDim2.new(0.013, 0, 0, 5)
rgbGrid.Parent = rgbGridWrap

local activeSliderHandles = {}

for _, rgbItem in ipairs(RGB_COLOR_PRESETS) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = rgbItem.color
    b.Text = rgbItem.name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    local lum = (rgbItem.color.R * 0.299) + (rgbItem.color.G * 0.587) + (rgbItem.color.B * 0.114)
    b.TextColor3 = (lum > 0.65) and Color3.fromRGB(15, 20, 30) or Color3.fromRGB(255, 255, 255)
    b.Parent = rgbGridWrap
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Click:Connect(function()
        for k, val in pairs(rgbItem.vals) do
            if state.editorValues[k] ~= nil then
                state.editorValues[k] = val
                if activeSliderHandles[k] then
                    activeSliderHandles[k].setValue(val)
                end
            end
        end
        setStatus("Warna '" .. rgbItem.name .. "' diterapkan ke editor", false)
    end)
end

local secStaticTop = makeSection(pageStatic, "2. EDITOR PARAMETER 12 FIXTURE, POSE & LAYER STATIS")

local chipStaticLayer = makeChipSelector(secStaticTop, "Target Layer Statis Cue:", {"dim", "pos", "beam"}, state.staticLayerType, function(v)
    state.staticLayerType = v
end)

local chipEditorFix = makeChipSelector(secStaticTop, "Tipe Fixture yang Diedit Parameternya:", {
    "clara", "strobe", "mapple", "parled", "fogger", "blinder",
    "flower", "pixel", "retro", "wall", "windmill", "sbar"
}, state.editorFixtureType, function(v)
    state.editorFixtureType = v
    state.editorValues = deepCopy(FIXTURE_DEFAULTS[v] or FIXTURE_DEFAULTS.clara)
    if rebuildDynamicFixtureSliders then
        rebuildDynamicFixtureSliders()
    end
end)

local posePresetWrap = Instance.new("Frame")
posePresetWrap.Size = UDim2.new(1, 0, 0, 0)
posePresetWrap.AutomaticSize = Enum.AutomaticSize.Y
posePresetWrap.BackgroundTransparency = 1
posePresetWrap.Parent = secStaticTop

local poseGrid = Instance.new("UIGridLayout")
poseGrid.CellSize = UDim2.new(0.24, 0, 0, 26)
poseGrid.CellPadding = UDim2.new(0.013, 0, 0, 5)
poseGrid.Parent = posePresetWrap

local dynamicSlidersContainer = Instance.new("Frame")
dynamicSlidersContainer.Size = UDim2.new(1, 0, 0, 0)
dynamicSlidersContainer.AutomaticSize = Enum.AutomaticSize.Y
dynamicSlidersContainer.BackgroundTransparency = 1
dynamicSlidersContainer.Parent = secStaticTop

local dynLayout = Instance.new("UIListLayout")
dynLayout.Padding = UDim.new(0, 4)
dynLayout.Parent = dynamicSlidersContainer

rebuildDynamicFixtureSliders = function()
    for _, child in ipairs(dynamicSlidersContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    activeSliderHandles = {}
    local t = state.editorFixtureType
    local keys = FIXTURE_KEYS_ORDER[t] or FIXTURE_KEYS_ORDER.clara
    for _, k in ipairs(keys) do
        local initVal = state.editorValues[k] or 0
        local handle = makeSliderRow(dynamicSlidersContainer, string.upper(k) .. " (" .. k .. ")", 0, 1, initVal, false, function(v)
            state.editorValues[k] = v
        end)
        activeSliderHandles[k] = handle
    end
end

for _, preset in ipairs(POSE_PRESETS) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 76)
    b.Text = preset.name
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    b.TextColor3 = Color3.fromRGB(235, 240, 250)
    b.Parent = posePresetWrap
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    b.MouseButton1Click:Connect(function()
        for k, val in pairs(preset.vals) do
            if state.editorValues[k] ~= nil then
                state.editorValues[k] = val
                if activeSliderHandles[k] then
                    activeSliderHandles[k].setValue(val)
                end
            end
        end
        setStatus("Pose '" .. preset.name .. "' dimuat ke slider", false)
    end)
end

local staticBtnRow = Instance.new("Frame")
staticBtnRow.Size = UDim2.new(1, 0, 0, 30)
staticBtnRow.BackgroundTransparency = 1
staticBtnRow.Parent = secStaticTop

makeSmallActionBtn(staticBtnRow, "Simpan sebagai Cue Statis", 0, 210, Color3.fromRGB(45, 155, 95), function()
    local fxMap = {}
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            local fType = string.lower(fix.t or "clara")
            fxMap[tostring(idx)] = {
                t = fType,
                v = makeFullV(fType, state.editorValues)
            }
        end
    end
    workData.cues[state.cueId] = {
        layer = state.staticLayerType,
        fx = fxMap,
        eff = {}
    }
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Cue Statis [" .. state.staticLayerType .. "] -> Cue " .. state.cueId, false)
end)

makeSmallActionBtn(staticBtnRow, "Terapkan ke Default Rig", 218, 185, Color3.fromRGB(48, 115, 215), function()
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            fix.v = makeFullV(fix.t, state.editorValues)
        end
    end
    setStatus("Nilai default rig diperbarui untuk lampu terpilih", false)
end)

local secChase = makeSection(pageChase, "1. CHASE SEQUENCER (REKAM STEP DARI TAB STATIC / RGB)")

makeSliderRow(secChase, "Chase Rate (Kecepatan)", 0.1, 10, state.chaseRate, false, function(v) state.chaseRate = v end)
makeSliderRow(secChase, "Chase Glide (0 Patah - 1 Halus)", 0, 1, state.chaseGlide, false, function(v) state.chaseGlide = v end)
makeChipSelector(secChase, "Chase Direction (dir):", {">", "<", "<>", "rand"}, state.chaseDir, function(v) state.chaseDir = v end)

local chaseStatusLbl = Instance.new("TextLabel")
chaseStatusLbl.Size = UDim2.new(1, 0, 0, 18)
chaseStatusLbl.BackgroundTransparency = 1
chaseStatusLbl.Text = "Total Step Terekam: 0 Step"
chaseStatusLbl.Font = Enum.Font.GothamSemibold
chaseStatusLbl.TextSize = 11
chaseStatusLbl.TextColor3 = Color3.fromRGB(245, 205, 110)
chaseStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
chaseStatusLbl.Parent = secChase

refreshChaseStepsUI = function()
    chaseStatusLbl.Text = "Total Step Terekam: " .. tostring(#state.chaseSteps) .. " Step"
end

local chaseBtnRow = Instance.new("Frame")
chaseBtnRow.Size = UDim2.new(1, 0, 0, 28)
chaseBtnRow.BackgroundTransparency = 1
chaseBtnRow.Parent = secChase

makeSmallActionBtn(chaseBtnRow, "+ Rekam Step dari Editor", 0, 175, Color3.fromRGB(48, 125, 225), function()
    local frame = {}
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            local fType = string.lower(fix.t or "clara")
            frame[tostring(idx)] = {
                t = fType,
                v = makeFullV(fType, state.editorValues)
            }
        end
    end
    table.insert(state.chaseSteps, frame)
    refreshChaseStepsUI()
    setStatus("Step #" .. #state.chaseSteps .. " ditambahkan ke Chase", false)
end)

makeSmallActionBtn(chaseBtnRow, "Terapkan Chase ke Cue", 182, 165, Color3.fromRGB(45, 155, 95), function()
    if #state.chaseSteps == 0 then
        setStatus("Rekam minimal 1 step dulu!", true)
        return
    end
    workData.cues[state.cueId] = {
        layer = "chs",
        fx = {},
        eff = {},
        chase = {
            glide = state.chaseGlide,
            dir = state.chaseDir,
            seq = false,
            off = 0,
            rate = state.chaseRate,
            steps = deepCopy(state.chaseSteps)
        }
    }
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Chase (" .. #state.chaseSteps .. " step) -> Cue " .. state.cueId, false)
end)

makeSmallActionBtn(chaseBtnRow, "Hapus Semua Step", 354, 130, Color3.fromRGB(165, 55, 65), function()
    state.chaseSteps = {}
    refreshChaseStepsUI()
    setStatus("Buffer Chase dikosongkan", false)
end)

local secGlobal = makeSection(pageChase, "2. PENGATURAN GLOBAL WORKSPACE (FADE & GRAND MASTER)")

local sldFade = makeSliderRow(secGlobal, "Global Fade Time (fade)", 0, 10, workData.fade, false, function(v)
    workData.fade = v
end)

local sldGm = makeSliderRow(secGlobal, "Grand Master (gm 0-100)", 0, 100, workData.gm, true, function(v)
    workData.gm = v
end)

local secRigGen = makeSection(pageRig, "1. AUTO-PATCH GENERATOR & CHANNEL FOOTPRINT")

makeChipSelector(secRigGen, "Pilih Jenis Fixture:", {
    "clara", "strobe", "mapple", "parled", "fogger", "blinder",
    "flower", "pixel", "retro", "wall", "windmill", "sbar"
}, state.rigType, function(v)
    state.rigType = v
end)

makeSliderRow(secRigGen, "Jumlah Unit Lampu", 1, 32, state.rigCount, true, function(v)
    state.rigCount = v
end)

makeSliderRow(secRigGen, "Alamat DMX Awal (Start Addr)", 1, 512, state.rigStartAddr, true, function(v)
    state.rigStartAddr = v
end)

makeChipSelector(secRigGen, "Mode Alamat DMX:", {"independen", "multi"}, state.rigMode, function(v)
    state.rigMode = v
end)

local rigBtnRow = Instance.new("Frame")
rigBtnRow.Size = UDim2.new(1, 0, 0, 28)
rigBtnRow.BackgroundTransparency = 1
rigBtnRow.Parent = secRigGen

makeSmallActionBtn(rigBtnRow, "Generate Rig Baru", 0, 145, Color3.fromRGB(48, 125, 225), function()
    local newRig = {}
    local t = string.lower(state.rigType)
    local step = FIXTURE_FOOTPRINTS[t] or 16
    local currentAddr = state.rigStartAddr
    for i = 1, state.rigCount do
        local posX = (state.rigCount == 1) and 0.5 or (0.08 + ((i - 1) * (0.84 / math.max(1, state.rigCount - 1))))
        table.insert(newRig, {
            a = currentAddr,
            x = math.floor(posX * 100 + 0.5) / 100,
            y = 0.5,
            t = t,
            v = makeFullV(t)
        })
        if state.rigMode == "independen" then
            currentAddr = currentAddr + step
        end
    end
    workData.rig = newRig
    resetSelectionAll()
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("Auto-Patch: " .. state.rigCount .. "x " .. t .. " (" .. state.rigMode .. ")", false)
end)

makeSmallActionBtn(rigBtnRow, "+ Tambah 1 Unit", 152, 125, Color3.fromRGB(45, 155, 95), function()
    local t = string.lower(state.rigType)
    local nextAddr = state.rigStartAddr
    for _, fix in ipairs(workData.rig) do
        local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
        local endAddr = (fix.a or 1) + fp
        if endAddr > nextAddr then
            nextAddr = endAddr
        end
    end
    if state.rigMode == "multi" and #workData.rig > 0 then
        nextAddr = workData.rig[#workData.rig].a or 1
    end
    table.insert(workData.rig, {
        a = nextAddr,
        x = math.clamp(0.1 + (#workData.rig * 0.08), 0.05, 0.95),
        y = 0.5,
        t = t,
        v = makeFullV(t)
    })
    selectedMembers[#workData.rig] = true
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("Ditambahkan " .. t .. " di DMX #" .. nextAddr, false)
end)

makeSmallActionBtn(rigBtnRow, "Re-Patch Otomatis Semua", 284, 175, Color3.fromRGB(115, 85, 195), function()
    local addr = state.rigStartAddr
    for _, fix in ipairs(workData.rig) do
        fix.a = addr
        if state.rigMode == "independen" then
            local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
            addr = addr + fp
        end
    end
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("Seluruh alamat DMX di-patch ulang", false)
end)

local secRigManual = makeSection(pageRig, "2. EDITOR MANUAL ALAMAT DMX & POSISI PANGGUNG PER UNIT")

local rigEditorContainer = Instance.new("Frame")
rigEditorContainer.Size = UDim2.new(1, 0, 0, 0)
rigEditorContainer.AutomaticSize = Enum.AutomaticSize.Y
rigEditorContainer.BackgroundTransparency = 1
rigEditorContainer.Parent = secRigManual

local rigEdLayout = Instance.new("UIListLayout")
rigEdLayout.Padding = UDim.new(0, 4)
rigEdLayout.Parent = rigEditorContainer

refreshRigEditorUI = function()
    for _, child in ipairs(rigEditorContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    for i, fix in ipairs(workData.rig) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundColor3 = Color3.fromRGB(21, 24, 33)
        row.BorderSizePixel = 0
        row.Parent = rigEditorContainer
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(0, 175, 1, 0)
        info.Position = UDim2.new(0, 8, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = string.format("#%02d %-8s (%dch)", i, fix.t, fp)
        info.Font = Enum.Font.GothamBold
        info.TextSize = 11
        info.TextColor3 = Color3.fromRGB(220, 230, 245)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Parent = row

        local addrLbl = Instance.new("TextLabel")
        addrLbl.Size = UDim2.new(0, 34, 1, 0)
        addrLbl.Position = UDim2.new(0, 185, 0, 0)
        addrLbl.BackgroundTransparency = 1
        addrLbl.Text = "DMX:"
        addrLbl.Font = Enum.Font.Gotham
        addrLbl.TextSize = 10
        addrLbl.TextColor3 = Color3.fromRGB(165, 180, 205)
        addrLbl.Parent = row

        local addrBox = Instance.new("TextBox")
        addrBox.Size = UDim2.new(0, 46, 0, 20)
        addrBox.Position = UDim2.new(0, 220, 0.5, -10)
        addrBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
        addrBox.Text = tostring(fix.a)
        addrBox.Font = Enum.Font.GothamBold
        addrBox.TextSize = 11
        addrBox.TextColor3 = Color3.fromRGB(120, 215, 255)
        addrBox.ClearTextOnFocus = false
        addrBox.Parent = row
        Instance.new("UICorner", addrBox).CornerRadius = UDim.new(0, 4)

        addrBox.FocusLost:Connect(function()
            local n = tonumber(addrBox.Text)
            if n and n >= 1 and n <= 512 then
                fix.a = math.floor(n)
                addrBox.Text = tostring(fix.a)
                if refreshMembersUI then refreshMembersUI() end
                setStatus("Unit #" .. i .. " DMX diubah ke " .. fix.a, false)
            else
                addrBox.Text = tostring(fix.a)
            end
        end)

        local xLbl = Instance.new("TextLabel")
        xLbl.Size = UDim2.new(0, 18, 1, 0)
        xLbl.Position = UDim2.new(0, 274, 0, 0)
        xLbl.BackgroundTransparency = 1
        xLbl.Text = "X:"
        xLbl.Font = Enum.Font.Gotham
        xLbl.TextSize = 10
        xLbl.TextColor3 = Color3.fromRGB(165, 180, 205)
        xLbl.Parent = row

        local xBox = Instance.new("TextBox")
        xBox.Size = UDim2.new(0, 42, 0, 20)
        xBox.Position = UDim2.new(0, 292, 0.5, -10)
        xBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
        xBox.Text = string.format("%.2f", fix.x or 0.5)
        xBox.Font = Enum.Font.Gotham
        xBox.TextSize = 11
        xBox.TextColor3 = Color3.fromRGB(235, 240, 250)
        xBox.ClearTextOnFocus = false
        xBox.Parent = row
        Instance.new("UICorner", xBox).CornerRadius = UDim.new(0, 4)

        xBox.FocusLost:Connect(function()
            local n = tonumber(xBox.Text)
            if n then
                fix.x = math.clamp(math.floor(n * 100 + 0.5) / 100, 0, 1)
                xBox.Text = string.format("%.2f", fix.x)
            else
                xBox.Text = string.format("%.2f", fix.x or 0.5)
            end
        end)

        local yLbl = Instance.new("TextLabel")
        yLbl.Size = UDim2.new(0, 18, 1, 0)
        yLbl.Position = UDim2.new(0, 340, 0, 0)
        yLbl.BackgroundTransparency = 1
        yLbl.Text = "Y:"
        yLbl.Font = Enum.Font.Gotham
        yLbl.TextSize = 10
        yLbl.TextColor3 = Color3.fromRGB(165, 180, 205)
        yLbl.Parent = row

        local yBox = Instance.new("TextBox")
        yBox.Size = UDim2.new(0, 42, 0, 20)
        yBox.Position = UDim2.new(0, 358, 0.5, -10)
        yBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
        yBox.Text = string.format("%.2f", fix.y or 0.5)
        yBox.Font = Enum.Font.Gotham
        yBox.TextSize = 11
        yBox.TextColor3 = Color3.fromRGB(235, 240, 250)
        yBox.ClearTextOnFocus = false
        yBox.Parent = row
        Instance.new("UICorner", yBox).CornerRadius = UDim.new(0, 4)

        yBox.FocusLost:Connect(function()
            local n = tonumber(yBox.Text)
            if n then
                fix.y = math.clamp(math.floor(n * 100 + 0.5) / 100, 0, 1)
                yBox.Text = string.format("%.2f", fix.y)
            else
                yBox.Text = string.format("%.2f", fix.y or 0.5)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 44, 0, 20)
        delBtn.Position = UDim2.new(1, -50, 0.5, -10)
        delBtn.BackgroundColor3 = Color3.fromRGB(155, 52, 62)
        delBtn.Text = "Hapus"
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 10
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Parent = row
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        delBtn.MouseButton1Click:Connect(function()
            if #workData.rig > 1 then
                table.remove(workData.rig, i)
                resetSelectionAll()
                refreshMembersUI()
                refreshRigEditorUI()
                setStatus("Unit #" .. i .. " dihapus dari Rig", false)
            else
                setStatus("Minimal harus ada 1 unit di Rig!", true)
            end
        end)
    end
end

local secCueMgr = makeSection(pageShows, "1. INTERACTIVE CUE MANAGER (KLIK CUE = PILIH & MUAT KE SLIDER)")

local cueQuickRow = Instance.new("Frame")
cueQuickRow.Size = UDim2.new(1, 0, 0, 26)
cueQuickRow.BackgroundTransparency = 1
cueQuickRow.Parent = secCueMgr

makeSmallActionBtn(cueQuickRow, "+ Cue Baru Kosong", 0, 130, Color3.fromRGB(45, 155, 95), function()
    local maxId = 0
    for k in pairs(workData.cues) do
        local n = tonumber(k)
        if n and n > maxId then
            maxId = n
        end
    end
    local nextKey = tostring(maxId + 1)
    state.cueId = nextKey
    applyEffectToCue(nextKey, "mov", 1, EFFECT_TEMPLATES[1])
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Cue [" .. nextKey .. "] dibuat & dipilih", false)
end)

makeSmallActionBtn(cueQuickRow, "Duplikat Cue Aktif", 136, 135, Color3.fromRGB(48, 115, 215), function()
    local src = workData.cues[state.cueId]
    if not src then
        setStatus("Cue " .. state.cueId .. " masih kosong!", true)
        return
    end
    local nextNum = (tonumber(state.cueId) or 1) + 1
    while workData.cues[tostring(nextNum)] ~= nil do
        nextNum = nextNum + 1
    end
    local nextKey = tostring(nextNum)
    workData.cues[nextKey] = deepCopy(src)
    state.cueId = nextKey
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Cue diduplikat ke Cue [" .. nextKey .. "]", false)
end)

makeSmallActionBtn(cueQuickRow, "Hapus Cue Aktif", 277, 125, Color3.fromRGB(165, 55, 65), function()
    workData.cues[state.cueId] = nil
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Cue " .. state.cueId .. " dihapus", false)
end)

local cueListContainer = Instance.new("Frame")
cueListContainer.Size = UDim2.new(1, 0, 0, 0)
cueListContainer.AutomaticSize = Enum.AutomaticSize.Y
cueListContainer.BackgroundTransparency = 1
cueListContainer.Parent = secCueMgr

local cueListLayout = Instance.new("UIListLayout")
cueListLayout.Padding = UDim.new(0, 4)
cueListLayout.Parent = cueListContainer

loadCueIntoEditor = function(cueKey)
    state.cueId = tostring(cueKey)
    local c = workData.cues[state.cueId]
    if not c then
        if refreshCuesListUI then refreshCuesListUI() end
        return
    end
    if (c.layer == "mov" or c.layer == "eff") and type(c.eff) == "table" then
        local foundIdx = 1
        local targetEff = nil
        for idx, ef in ipairs(c.eff) do
            if ef.on then
                foundIdx = idx
                targetEff = ef
                break
            end
        end
        targetEff = targetEff or c.eff[1]
        if targetEff then
            state.layerMode = c.layer
            state.slotIndex = foundIdx
            state.target = targetEff.target or "pos"
            state.shape = targetEff.shape or "circle"
            state.rate = tonumber(targetEff.rate) or 0.35
            state.sx = tonumber(targetEff.sx) or 0.35
            state.sy = tonumber(targetEff.sy) or 0.35
            state.phase = tonumber(targetEff.phase) or 360
            state.wing = tonumber(targetEff.wing) or 0
            state.groups = tonumber(targetEff.groups) or 0
            state.dir = targetEff.dir or ">"
            state.wax = targetEff.wax or "x"
            state.dty = tonumber(targetEff.dty) or 0.5
            state.soft = tonumber(targetEff.soft) or 0
            if type(targetEff.members) == "table" and #targetEff.members > 0 then
                selectedMembers = {}
                for _, mIdx in ipairs(targetEff.members) do
                    selectedMembers[mIdx] = true
                end
                if refreshMembersUI then refreshMembersUI() end
            end
            if customControls.syncFromState then
                customControls.syncFromState()
            end
        end
    elseif c.layer == "chs" and type(c.chase) == "table" then
        state.chaseRate = tonumber(c.chase.rate) or 2
        state.chaseGlide = tonumber(c.chase.glide) or 0.3
        state.chaseDir = c.chase.dir or ">"
        state.chaseSteps = deepCopy(c.chase.steps or {})
        if refreshChaseStepsUI then refreshChaseStepsUI() end
    elseif (c.layer == "dim" or c.layer == "pos" or c.layer == "beam") and type(c.fx) == "table" then
        state.staticLayerType = c.layer
        chipStaticLayer.setSelected(c.layer)
        for kIdx, fxData in pairs(c.fx) do
            if type(fxData) == "table" and type(fxData.v) == "table" then
                local fType = string.lower(fxData.t or "clara")
                state.editorFixtureType = fType
                chipEditorFix.setSelected(fType)
                state.editorValues = makeFullV(fType, fxData.v)
                rebuildDynamicFixtureSliders()
                break
            end
        end
    end
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("Cue [" .. state.cueId .. "] (" .. tostring(c.layer) .. ") dimuat ke slider", false)
end

local secShowsMgr = makeSection(pageShows, "2. SHOW LIBRARY MANAGER (dmx_ui_shows.json)")

local showInputRow = Instance.new("Frame")
showInputRow.Size = UDim2.new(1, 0, 0, 28)
showInputRow.BackgroundTransparency = 1
showInputRow.Parent = secShowsMgr

local showNameBox = Instance.new("TextBox")
showNameBox.Size = UDim2.new(0, 195, 0, 26)
showNameBox.Position = UDim2.new(0, 0, 0, 0)
showNameBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
showNameBox.PlaceholderText = "Nama Show (contoh: show_utama)"
showNameBox.Text = ""
showNameBox.Font = Enum.Font.Gotham
showNameBox.TextSize = 11
showNameBox.TextColor3 = Color3.fromRGB(245, 248, 255)
showNameBox.ClearTextOnFocus = false
showNameBox.Parent = showInputRow
Instance.new("UICorner", showNameBox).CornerRadius = UDim.new(0, 5)

makeSmallActionBtn(showInputRow, "Simpan ke Shows", 202, 125, Color3.fromRGB(45, 155, 95), function()
    local name = string.gsub(showNameBox.Text, "^%s*(.-)%s*$", "%1")
    if #name == 0 then
        setStatus("Isi nama show terlebih dahulu!", true)
        return
    end
    loadShowsFile()
    workData = sanitizeWorkStructure(workData)
    showsData[name] = {
        data = deepCopy(workData),
        ts = os.time()
    }
    local ok, msg = saveShowsFile()
    if refreshShowsListUI then refreshShowsListUI() end
    setStatus(ok and ("Show '" .. name .. "' disimpan ke " .. SHOWS_FILE) or msg, not ok)
end)

makeSmallActionBtn(showInputRow, "Muat ke Work", 334, 110, Color3.fromRGB(48, 115, 215), function()
    local name = string.gsub(showNameBox.Text, "^%s*(.-)%s*$", "%1")
    loadShowsFile()
    if showsData[name] and type(showsData[name].data) == "table" then
        workData = sanitizeWorkStructure(deepCopy(showsData[name].data))
        sldFade.setValue(workData.fade)
        sldGm.setValue(workData.gm)
        resetSelectionAll()
        refreshMembersUI()
        refreshRigEditorUI()
        refreshCuesListUI()
        setStatus("Show '" .. name .. "' dimuat ke Workspace aktif", false)
    else
        setStatus("Show '" .. name .. "' tidak ditemukan di " .. SHOWS_FILE, true)
    end
end)

makeSmallActionBtn(showInputRow, "Hapus Show", 450, 95, Color3.fromRGB(165, 55, 65), function()
    local name = string.gsub(showNameBox.Text, "^%s*(.-)%s*$", "%1")
    loadShowsFile()
    if showsData[name] then
        showsData[name] = nil
        saveShowsFile()
        if refreshShowsListUI then refreshShowsListUI() end
        setStatus("Show '" .. name .. "' dihapus", false)
    else
        setStatus("Show tidak ditemukan", true)
    end
end)

local showsListLabel = Instance.new("TextLabel")
showsListLabel.Size = UDim2.new(1, 0, 0, 0)
showsListLabel.AutomaticSize = Enum.AutomaticSize.Y
showsListLabel.BackgroundColor3 = Color3.fromRGB(20, 23, 31)
showsListLabel.TextColor3 = Color3.fromRGB(205, 215, 235)
showsListLabel.Font = Enum.Font.Code
showsListLabel.TextSize = 11
showsListLabel.TextXAlignment = Enum.TextXAlignment.Left
showsListLabel.TextYAlignment = Enum.TextYAlignment.Top
showsListLabel.TextWrapped = true
showsListLabel.Parent = secShowsMgr
Instance.new("UICorner", showsListLabel).CornerRadius = UDim.new(0, 6)
local showsPad = Instance.new("UIPadding", showsListLabel)
showsPad.PaddingTop = UDim.new(0, 6)
showsPad.PaddingBottom = UDim.new(0, 6)
showsPad.PaddingLeft = UDim.new(0, 8)
showsPad.PaddingRight = UDim.new(0, 8)

refreshShowsListUI = function()
    local names = {}
    for k in pairs(showsData) do
        table.insert(names, tostring(k))
    end
    table.sort(names)
    if #names == 0 then
        showsListLabel.Text = "Belum ada show tersimpan di dmx_ui_shows.json."
        return
    end
    local lines = {}
    for _, n in ipairs(names) do
        local entry = showsData[n]
        local rigCount = (entry.data and entry.data.rig) and #entry.data.rig or 0
        table.insert(lines, string.format("• %-18s | Rig: %d unit | ts: %s", n, rigCount, tostring(entry.ts or 0)))
    end
    showsListLabel.Text = table.concat(lines, "\n")
end

local secPreview = makeSection(pageShows, "3. LIVE VISUAL SIMULATOR (PREVIEW GERAKAN X/Y DI UI)")

local previewCanvas = Instance.new("Frame")
previewCanvas.Size = UDim2.new(1, 0, 0, 120)
previewCanvas.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
previewCanvas.BorderSizePixel = 0
previewCanvas.Parent = secPreview
Instance.new("UICorner", previewCanvas).CornerRadius = UDim.new(0, 6)

local previewDots = {}
local function rebuildPreviewDots()
    for _, d in ipairs(previewDots) do
        d:Destroy()
    end
    previewDots = {}
    for i = 1, #workData.rig do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3 = Color3.fromRGB(90, 200, 255)
        dot.BorderSizePixel = 0
        dot.Parent = previewCanvas
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local num = Instance.new("TextLabel")
        num.Size = UDim2.new(1, 0, 1, 0)
        num.BackgroundTransparency = 1
        num.Text = tostring(i)
        num.Font = Enum.Font.GothamBold
        num.TextSize = 9
        num.TextColor3 = Color3.fromRGB(10, 15, 25)
        num.Parent = dot

        previewDots[i] = dot
    end
end

local previewToggleBtn = Instance.new("TextButton")
previewToggleBtn.Size = UDim2.new(0, 190, 0, 26)
previewToggleBtn.BackgroundColor3 = Color3.fromRGB(48, 115, 215)
previewToggleBtn.Text = "Mulai Live Preview Gerakan"
previewToggleBtn.Font = Enum.Font.GothamSemibold
previewToggleBtn.TextSize = 11
previewToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
previewToggleBtn.Parent = secPreview
Instance.new("UICorner", previewToggleBtn).CornerRadius = UDim.new(0, 5)

previewToggleBtn.MouseButton1Click:Connect(function()
    state.previewActive = not state.previewActive
    previewToggleBtn.Text = state.previewActive and "Hentikan Live Preview" or "Mulai Live Preview Gerakan"
    previewToggleBtn.BackgroundColor3 = state.previewActive and Color3.fromRGB(185, 65, 75) or Color3.fromRGB(48, 115, 215)
    rebuildPreviewDots()
end)

RunService.RenderStepped:Connect(function()
    if not state.previewActive or not pageShows.Visible then return end
    local t = os.clock() * (state.rate * 2.5)
    for i, dot in ipairs(previewDots) do
        local spread = (state.phase / 360) * ((i - 1) / math.max(1, #previewDots)) * math.pi * 2
        if state.wing > 0 and i > (#previewDots / 2) then
            spread = -spread
        end
        local ang = (state.dir == "<") and (-t + spread) or (t + spread)
        local ox, oy = 0, 0
        if state.shape == "circle" then
            ox = math.cos(ang) * state.sx * 0.42
            oy = math.sin(ang) * state.sy * 0.42
        elseif state.shape == "fig8" then
            ox = math.sin(ang) * state.sx * 0.42
            oy = math.sin(ang * 2) * state.sy * 0.42
        elseif state.shape == "sine" then
            if state.wax == "y" then
                oy = math.sin(ang) * state.sy * 0.42
            else
                ox = math.sin(ang) * state.sx * 0.42
            end
        elseif state.shape == "saw" then
            local saw = ((ang / (math.pi * 2)) % 1) * 2 - 1
            ox = saw * state.sx * 0.42
        elseif state.shape == "square" then
            local sq = (math.sin(ang) >= 0) and 1 or -1
            ox = sq * state.sx * 0.42
            oy = sq * state.sy * 0.25
        else
            ox = math.sin(ang * 1.3 + i) * state.sx * 0.4
            oy = math.cos(ang * 1.7 - i) * state.sy * 0.4
        end
        dot.Position = UDim2.new(math.clamp(0.5 + ox, 0.06, 0.94), 0, math.clamp(0.5 + oy, 0.12, 0.88), 0)
    end
end)

local cueLabelFooter = Instance.new("TextLabel")
cueLabelFooter.Size = UDim2.new(0, 62, 1, 0)
cueLabelFooter.Position = UDim2.new(0, 10, 0, 0)
cueLabelFooter.BackgroundTransparency = 1
cueLabelFooter.Text = "Cue ID:"
cueLabelFooter.Font = Enum.Font.GothamBold
cueLabelFooter.TextSize = 11
cueLabelFooter.TextColor3 = Color3.fromRGB(220, 228, 245)
cueLabelFooter.TextXAlignment = Enum.TextXAlignment.Left
cueLabelFooter.Parent = footerBar

local cueIdBox = Instance.new("TextBox")
cueIdBox.Size = UDim2.new(0, 48, 0, 24)
cueIdBox.Position = UDim2.new(0, 64, 0.5, -12)
cueIdBox.BackgroundColor3 = Color3.fromRGB(36, 42, 56)
cueIdBox.Text = state.cueId
cueIdBox.Font = Enum.Font.GothamBold
cueIdBox.TextSize = 12
cueIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cueIdBox.ClearTextOnFocus = false
cueIdBox.Parent = footerBar
Instance.new("UICorner", cueIdBox).CornerRadius = UDim.new(0, 5)

cueIdBox.FocusLost:Connect(function()
    local clean = string.gsub(cueIdBox.Text, "%s+", "")
    if #clean > 0 then
        state.cueId = clean
    else
        cueIdBox.Text = state.cueId
    end
    if refreshCuesListUI then refreshCuesListUI() end
end)

refreshCuesListUI = function()
    cueIdBox.Text = state.cueId
    for _, child in ipairs(cueListContainer:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local keys = {}
    for k in pairs(workData.cues) do
        table.insert(keys, tostring(k))
    end
    table.sort(keys, function(a, b)
        local na, nb = tonumber(a), tonumber(b)
        if na and nb then return na < nb end
        return a < b
    end)

    if #keys == 0 then
        local emptyLbl = Instance.new("TextLabel")
        emptyLbl.Size = UDim2.new(1, 0, 0, 24)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.Text = "Belum ada Cue tersimpan di dmx_ui_work.json."
        emptyLbl.Font = Enum.Font.Gotham
        emptyLbl.TextSize = 11
        emptyLbl.TextColor3 = Color3.fromRGB(165, 175, 195)
        emptyLbl.TextXAlignment = Enum.TextXAlignment.Left
        emptyLbl.Parent = cueListContainer
        return
    end

    for _, k in ipairs(keys) do
        local c = workData.cues[k]
        local isSelected = (k == state.cueId)
        local detail = ""
        if c.layer == "chs" and c.chase and c.chase.steps then
            detail = "Chase (" .. #c.chase.steps .. " steps, rate " .. tostring(c.chase.rate) .. ")"
        elseif c.layer == "dim" or c.layer == "pos" or c.layer == "beam" then
            detail = "Static Snapshot (" .. tostring(c.layer) .. ")"
        elseif type(c.eff) == "table" then
            local activeNames = {}
            for sIdx, ef in ipairs(c.eff) do
                if ef.on then
                    table.insert(activeNames, "S" .. sIdx .. ":" .. tostring(ef.target) .. "/" .. tostring(ef.shape))
                end
            end
            detail = (#activeNames > 0) and table.concat(activeNames, ", ") or "Off"
        end

        local rowBtn = Instance.new("TextButton")
        rowBtn.Size = UDim2.new(1, 0, 0, 26)
        rowBtn.BackgroundColor3 = isSelected and Color3.fromRGB(42, 95, 175) or Color3.fromRGB(21, 24, 33)
        rowBtn.Text = string.format("  %s Cue [%s]  |  Layer: %-4s  |  %s", isSelected and "●" or "○", k, tostring(c.layer), detail)
        rowBtn.Font = Enum.Font.GothamSemibold
        rowBtn.TextSize = 11
        rowBtn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(205, 215, 230)
        rowBtn.TextXAlignment = Enum.TextXAlignment.Left
        rowBtn.Parent = cueListContainer
        Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 5)

        rowBtn.MouseButton1Click:Connect(function()
            loadCueIntoEditor(k)
        end)
    end
end

local reloadBtn = Instance.new("TextButton")
reloadBtn.Size = UDim2.new(0, 125, 0, 26)
reloadBtn.Position = UDim2.new(1, -302, 0.5, -13)
reloadBtn.BackgroundColor3 = Color3.fromRGB(52, 62, 84)
reloadBtn.Text = "Reload JSON"
reloadBtn.Font = Enum.Font.GothamSemibold
reloadBtn.TextSize = 11
reloadBtn.TextColor3 = Color3.fromRGB(235, 242, 255)
reloadBtn.Parent = footerBar
Instance.new("UICorner", reloadBtn).CornerRadius = UDim.new(0, 6)

reloadBtn.MouseButton1Click:Connect(function()
    local ok, msg = loadWorkFile()
    loadShowsFile()
    sldFade.setValue(workData.fade)
    sldGm.setValue(workData.gm)
    resetSelectionAll()
    refreshMembersUI()
    refreshRigEditorUI()
    refreshCuesListUI()
    refreshShowsListUI()
    setStatus(msg, not ok)
end)

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 162, 0, 26)
saveBtn.Position = UDim2.new(1, -170, 0.5, -13)
saveBtn.BackgroundColor3 = Color3.fromRGB(42, 165, 98)
saveBtn.Text = "SIMPAN KE WORK.JSON"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 11
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Parent = footerBar
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

saveBtn.MouseButton1Click:Connect(function()
    local ok, msg = saveWorkFile()
    setStatus(msg, not ok)
end)

rebuildDynamicFixtureSliders()
refreshMembersUI()
refreshRigEditorUI()
refreshCuesListUI()
refreshShowsListUI()
switchTab("templates")
