local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local WORK_FILE = "dmx_ui_work.json"
local PREFS_FILE = "apex_dmx_prefs.json"

local guiParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("ApexDMXStudio") then
    guiParent:FindFirstChild("ApexDMXStudio"):Destroy()
end
if Lighting:FindFirstChild("ApexDMXBlur") then
    Lighting:FindFirstChild("ApexDMXBlur"):Destroy()
end

local THEMES = {
    ["Brutal Dark"] = {
        bg = Color3.fromRGB(18, 18, 22),
        surface = Color3.fromRGB(30, 30, 36),
        header = Color3.fromRGB(255, 102, 0),
        accent = Color3.fromRGB(0, 245, 155),
        secondary = Color3.fromRGB(255, 214, 0),
        danger = Color3.fromRGB(255, 68, 68),
        ink = Color3.fromRGB(245, 245, 248),
        subInk = Color3.fromRGB(175, 178, 190),
        chipBg = Color3.fromRGB(44, 44, 52),
        canvas = Color3.fromRGB(10, 10, 14),
        btnText = Color3.fromRGB(12, 12, 12)
    },
    ["OLED Midnight"] = {
        bg = Color3.fromRGB(10, 10, 13),
        surface = Color3.fromRGB(22, 22, 28),
        header = Color3.fromRGB(0, 212, 255),
        accent = Color3.fromRGB(185, 255, 0),
        secondary = Color3.fromRGB(255, 110, 180),
        danger = Color3.fromRGB(245, 55, 65),
        ink = Color3.fromRGB(242, 244, 250),
        subInk = Color3.fromRGB(160, 165, 180),
        chipBg = Color3.fromRGB(34, 34, 42),
        canvas = Color3.fromRGB(5, 5, 8),
        btnText = Color3.fromRGB(10, 10, 10)
    },
    ["Obsidian Neon"] = {
        bg = Color3.fromRGB(22, 20, 28),
        surface = Color3.fromRGB(35, 32, 44),
        header = Color3.fromRGB(175, 95, 255),
        accent = Color3.fromRGB(0, 235, 215),
        secondary = Color3.fromRGB(255, 195, 45),
        danger = Color3.fromRGB(255, 65, 85),
        ink = Color3.fromRGB(248, 245, 255),
        subInk = Color3.fromRGB(185, 178, 200),
        chipBg = Color3.fromRGB(50, 46, 62),
        canvas = Color3.fromRGB(12, 10, 16),
        btnText = Color3.fromRGB(12, 12, 12)
    },
    ["Acid Lime"] = {
        bg = Color3.fromRGB(244, 241, 232),
        surface = Color3.fromRGB(255, 255, 255),
        header = Color3.fromRGB(205, 255, 0),
        accent = Color3.fromRGB(205, 255, 0),
        secondary = Color3.fromRGB(255, 198, 41),
        danger = Color3.fromRGB(255, 77, 77),
        ink = Color3.fromRGB(15, 15, 15),
        subInk = Color3.fromRGB(60, 60, 60),
        chipBg = Color3.fromRGB(232, 229, 218),
        canvas = Color3.fromRGB(20, 20, 24),
        btnText = Color3.fromRGB(15, 15, 15)
    }
}

local uiPrefs = {
    themeName = "Brutal Dark",
    uiScale = 1.0,
    borderThickness = 2,
    autoSaveOnApply = true,
    bubbleSize = 46,
    promptRigOnNewCue = true,
    bgTransparency = 0.14,
    enableBlur = true
}

local function loadPrefs()
    if isfile and readfile and isfile(PREFS_FILE) then
        local ok, raw = pcall(readfile, PREFS_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(dec) == "table" then
                if THEMES[dec.themeName] then uiPrefs.themeName = dec.themeName end
                if tonumber(dec.uiScale) then uiPrefs.uiScale = math.clamp(tonumber(dec.uiScale), 0.75, 1.30) end
                if tonumber(dec.borderThickness) then uiPrefs.borderThickness = math.clamp(math.floor(tonumber(dec.borderThickness)), 1, 4) end
                if type(dec.autoSaveOnApply) == "boolean" then uiPrefs.autoSaveOnApply = dec.autoSaveOnApply end
                if tonumber(dec.bubbleSize) then uiPrefs.bubbleSize = math.clamp(math.floor(tonumber(dec.bubbleSize)), 36, 66) end
                if type(dec.promptRigOnNewCue) == "boolean" then uiPrefs.promptRigOnNewCue = dec.promptRigOnNewCue end
                if tonumber(dec.bgTransparency) then uiPrefs.bgTransparency = math.clamp(tonumber(dec.bgTransparency), 0, 0.75) end
                if type(dec.enableBlur) == "boolean" then uiPrefs.enableBlur = dec.enableBlur end
            end
        end
    end
end

local function savePrefs()
    if writefile then
        local ok, enc = pcall(function() return HttpService:JSONEncode(uiPrefs) end)
        if ok then
            pcall(writefile, PREFS_FILE, string.gsub(enc, "[\r\n]", ""))
        end
    end
end

loadPrefs()

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

local MOTION_PRESETS = {
    {name="Circle Smooth", cat="GERAK", layer="mov", target="pos", shape="circle", rate=0.35, sx=0.35, sy=0.35, phase=0, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Circle Fan 360", cat="GERAK", layer="mov", target="pos", shape="circle", rate=0.35, sx=0.35, sy=0.35, phase=360, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Circle Cermin", cat="GERAK", layer="mov", target="pos", shape="circle", rate=0.40, sx=0.35, sy=0.35, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
    {name="Figure-8 Wide", cat="GERAK", layer="mov", target="pos", shape="fig8", rate=0.30, sx=0.45, sy=0.30, phase=180, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Figure-8 Cermin", cat="GERAK", layer="mov", target="pos", shape="fig8", rate=0.35, sx=0.40, sy=0.35, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
    {name="Sapu Pan (Kiri-Kanan)", cat="GERAK", layer="mov", target="pos", shape="sine", rate=0.45, sx=0.45, sy=0.0, phase=0, wing=0, groups=0, dir=">", wax="x", dty=0.5, soft=0},
    {name="Kipas Pan (Cermin)", cat="GERAK", layer="mov", target="pos", shape="sine", rate=0.45, sx=0.45, sy=0.0, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
    {name="Tilt Wave (Ombak)", cat="GERAK", layer="mov", target="pos", shape="sine", rate=0.50, sx=0.0, sy=0.40, phase=360, wing=0, groups=0, dir=">", wax="y", dty=0.5, soft=0},
    {name="Tilt Cermin Wing", cat="GERAK", layer="mov", target="pos", shape="sine", rate=0.50, sx=0.0, sy=0.40, phase=180, wing=2, groups=1, dir=">", wax="y", dty=0.5, soft=0},
    {name="Tilt Fly-Up Saw", cat="GERAK", layer="mov", target="pos", shape="saw", rate=0.60, sx=0.0, sy=0.45, phase=360, wing=0, groups=0, dir=">", wax="y", dty=0.5, soft=0.1},
    {name="Silang 2-Grup", cat="GERAK", layer="mov", target="pos", shape="square", rate=0.70, sx=0.40, sy=0.30, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.5, soft=0},
    {name="Ballyhoo Acak", cat="GERAK", layer="mov", target="pos", shape="random", rate=0.60, sx=0.40, sy=0.40, phase=360, wing=0, groups=0, dir="<>", wax="x", dty=0.5, soft=0.15},

    {name="Rainbow Saw Wave", cat="EFEK", layer="eff", target="color", shape="saw", rate=0.60, sx=0.30, sy=0.30, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.55, soft=0.25},
    {name="Color Snap 2-Grup", cat="EFEK", layer="eff", target="color", shape="square", rate=1.00, sx=0.30, sy=0.30, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.50, soft=0},
    {name="Color Sine Bounce", cat="EFEK", layer="eff", target="color", shape="sine", rate=0.50, sx=0.40, sy=0.40, phase=360, wing=2, groups=0, dir="<>", wax="x", dty=0.50, soft=0.3},
    {name="Dimmer Chase Gelombang", cat="EFEK", layer="eff", target="dim", shape="sine", rate=1.20, sx=0.50, sy=0.50, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.50, soft=0.2},
    {name="Dimmer Kedip Ganjil-Genap", cat="EFEK", layer="eff", target="dim", shape="square", rate=2.00, sx=0.50, sy=0.50, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.35, soft=0},
    {name="Strobe Burst PingPong", cat="EFEK", layer="eff", target="strobe", shape="square", rate=1.50, sx=0.30, sy=0.30, phase=360, wing=0, groups=0, dir="<>", wax="x", dty=0.20, soft=0.1},
    {name="Beam Prism/Gobo Flip", cat="EFEK", layer="eff", target="beam", shape="square", rate=0.80, sx=0.30, sy=0.30, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.50, soft=0},
    {name="Beam Frost Pulse", cat="EFEK", layer="eff", target="beam", shape="sine", rate=0.65, sx=0.40, sy=0.40, phase=180, wing=2, groups=0, dir=">", wax="x", dty=0.50, soft=0.25}
}

local LAYER_STACK_COMBOS = {
    {
        name = "Circle + Rainbow + Pulse",
        s1 = {target="pos", shape="circle", rate=0.40, sx=0.35, sy=0.35, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
        s2 = {target="color", shape="saw", rate=0.60, sx=0.30, sy=0.30, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.55, soft=0.25},
        s3 = {target="dim", shape="sine", rate=1.20, sx=0.50, sy=0.50, phase=360, wing=2, groups=0, dir=">", wax="x", dty=0.5, soft=0.2}
    },
    {
        name = "Fig8 + Color Snap + Strobe",
        s1 = {target="pos", shape="fig8", rate=0.35, sx=0.42, sy=0.32, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
        s2 = {target="color", shape="square", rate=1.00, sx=0.30, sy=0.30, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.5, soft=0},
        s3 = {target="strobe", shape="square", rate=1.50, sx=0.30, sy=0.30, phase=360, wing=0, groups=0, dir="<>", wax="x", dty=0.2, soft=0.1}
    },
    {
        name = "Kipas Pan + Color + Hard Flash",
        s1 = {target="pos", shape="sine", rate=0.45, sx=0.45, sy=0.0, phase=180, wing=2, groups=1, dir=">", wax="x", dty=0.5, soft=0},
        s2 = {target="color", shape="sine", rate=0.50, sx=0.40, sy=0.40, phase=360, wing=2, groups=0, dir="<>", wax="x", dty=0.5, soft=0.3},
        s3 = {target="dim", shape="square", rate=2.00, sx=0.50, sy=0.50, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.35, soft=0}
    },
    {
        name = "Tilt Wave + Prism + Dimmer",
        s1 = {target="pos", shape="sine", rate=0.50, sx=0.0, sy=0.42, phase=360, wing=0, groups=0, dir=">", wax="y", dty=0.5, soft=0},
        s2 = {target="beam", shape="square", rate=0.80, sx=0.30, sy=0.30, phase=180, wing=0, groups=2, dir=">", wax="x", dty=0.5, soft=0},
        s3 = {target="dim", shape="sine", rate=1.00, sx=0.50, sy=0.50, phase=180, wing=2, groups=0, dir=">", wax="x", dty=0.5, soft=0.2}
    }
}

local CHASE_STEP_TEMPLATES = {
    {name="Wave Pan Sweep", pattern="wave_pan"},
    {name="Ping-Pong Silang", pattern="pingpong"},
    {name="Staircase Tilt Naik", pattern="stair_tilt"},
    {name="Ganjil-Genap Flash", pattern="odd_even"},
    {name="Fan Out - Fan In", pattern="fan_io"},
    {name="Pelangi Berjalan", pattern="color_run"}
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
    eff.rate = tonumber(cfg.rate) or 0.35
    eff.sx = math.clamp(tonumber(cfg.sx) or 0.35, 0, 1)
    eff.sy = math.clamp(tonumber(cfg.sy) or 0.35, 0, 1)
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

local function buildAutoPatchedRig(fixtureType, count, startAddr, mode)
    local newRig = {}
    local t = string.lower(tostring(fixtureType or "clara"))
    local fp = FIXTURE_FOOTPRINTS[t] or 16
    local addr = math.max(1, math.floor(tonumber(startAddr) or 1))
    local qty = math.clamp(math.floor(tonumber(count) or 8), 1, 64)
    local isMulti = (mode == "multi")
    for i = 1, qty do
        local posX = (qty == 1) and 0.5 or (0.08 + ((i - 1) * (0.84 / math.max(1, qty - 1))))
        table.insert(newRig, {
            a = addr,
            x = math.floor(posX * 100 + 0.5) / 100,
            y = 0.5,
            t = t,
            v = makeFullV(t)
        })
        if not isMulti then
            addr = addr + fp
        end
    end
    return newRig
end

local function defaultWorkData()
    return sanitizeWorkStructure({
        v = 3,
        gm = 100,
        fade = 0,
        sg = {},
        keys = {},
        eff = normalizeEffArray({}),
        chase = {off = 0, seq = false, dir = ">", scope = "all", glide = 0, rate = 1, steps = {}},
        cues = {},
        rig = buildAutoPatchedRig("clara", 8, 1, "independen")
    })
end

local workData = defaultWorkData()

local function loadWorkFile()
    if isfile and readfile and isfile(WORK_FILE) then
        local ok, raw = pcall(readfile, WORK_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if ok2 and type(decoded) == "table" then
                workData = sanitizeWorkStructure(decoded)
                return true, "LOADED: " .. WORK_FILE
            end
        end
    end
    return false, "DEFAULT RIG READY"
end

local function saveWorkFile()
    if not writefile then
        return false, "NO WRITEFILE SUPPORT"
    end
    workData = sanitizeWorkStructure(workData)
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(workData)
    end)
    if not ok then
        return false, "JSON ENCODE ERROR"
    end
    local minified = string.gsub(encoded, "[\r\n]", "")
    local okWrite, err = pcall(writefile, WORK_FILE, minified)
    if not okWrite then
        return false, tostring(err)
    end
    return true, "SAVED -> " .. WORK_FILE
end

loadWorkFile()

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
    previewActive = true,
    rigType = (#workData.rig > 0 and workData.rig[1].t) or "clara",
    rigCount = math.max(1, #workData.rig),
    rigStartAddr = (#workData.rig > 0 and workData.rig[1].a) or 1,
    rigMode = "independen",
    rigConfigured = false,
    chaseStepsCount = 8,
    chaseRate = 2.5,
    chaseGlide = 0.35,
    chaseDir = ">",
    bpm = 120
}

local themeBindings = {}
local function registerTheme(obj, role, prop)
    table.insert(themeBindings, {obj = obj, role = role, prop = prop})
end

local function getCurrentTheme()
    return THEMES[uiPrefs.themeName] or THEMES["Brutal Dark"]
end

local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "ApexDMXBlur"
blurEffect.Size = uiPrefs.enableBlur and 8 or 0
blurEffect.Enabled = uiPrefs.enableBlur
blurEffect.Parent = Lighting

local screen = Instance.new("ScreenGui")
screen.Name = "ApexDMXStudio"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = guiParent

local uiScaleObj = Instance.new("UIScale")
uiScaleObj.Scale = uiPrefs.uiScale
uiScaleObj.Parent = screen

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Size = UDim2.new(0.84, 0, 0.80, 0)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.BackgroundTransparency = uiPrefs.bgTransparency
main.BorderSizePixel = 0
main.ZIndex = 2
main.Parent = screen
registerTheme(main, "bg", "BackgroundColor3")

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(350, 235)
sizeConstraint.MaxSize = Vector2.new(530, 335)
sizeConstraint.Parent = main

local function applyBrutalBorder(guiObj)
    local st = guiObj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    st.Color = Color3.fromRGB(0, 0, 0)
    st.Thickness = uiPrefs.borderThickness
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = guiObj
end

applyBrutalBorder(main)

local function makeDraggableFrame(handleObj, targetObj, onClickIfNotDragged)
    local dragging, dragInput, dragStart, startPos, moved
    handleObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = targetObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onClickIfNotDragged then
                        onClickIfNotDragged()
                    end
                end
            end)
        end
    end)
    handleObj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                moved = true
            end
            targetObj.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + (delta.X / math.max(0.1, uiScaleObj.Scale)),
                startPos.Y.Scale,
                startPos.Y.Offset + (delta.Y / math.max(0.1, uiScaleObj.Scale))
            )
        end
    end)
end

local bubbleBtn = Instance.new("TextButton")
bubbleBtn.Name = "FloatingBubble"
bubbleBtn.Size = UDim2.new(0, uiPrefs.bubbleSize, 0, uiPrefs.bubbleSize)
bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
bubbleBtn.Text = "DMX"
bubbleBtn.Font = Enum.Font.GothamBlack
bubbleBtn.TextSize = 13
bubbleBtn.BorderSizePixel = 0
bubbleBtn.Visible = false
bubbleBtn.ZIndex = 20
bubbleBtn.Parent = screen
registerTheme(bubbleBtn, "header", "BackgroundColor3")
registerTheme(bubbleBtn, "btnText", "TextColor3")
applyBrutalBorder(bubbleBtn)

makeDraggableFrame(bubbleBtn, bubbleBtn, function()
    bubbleBtn.Visible = false
    main.Visible = true
    blurEffect.Enabled = uiPrefs.enableBlur
end)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundTransparency = math.clamp(uiPrefs.bgTransparency * 0.5, 0, 0.5)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = main
registerTheme(topBar, "header", "BackgroundColor3")
applyBrutalBorder(topBar)

makeDraggableFrame(topBar, main, nil)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 175, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "APEX DMX // RK-512"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 12
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 4
titleLbl.Parent = topBar
registerTheme(titleLbl, "btnText", "TextColor3")

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -255, 1, 0)
statusLbl.Position = UDim2.new(0, 185, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "READY // " .. WORK_FILE
statusLbl.Font = Enum.Font.Code
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Right
statusLbl.TextTruncate = Enum.TextTruncate.AtEnd
statusLbl.ZIndex = 4
statusLbl.Parent = topBar
registerTheme(statusLbl, "btnText", "TextColor3")

local function setStatus(msg, isErr)
    statusLbl.Text = string.upper(tostring(msg))
    local th = getCurrentTheme()
    statusLbl.TextColor3 = isErr and Color3.fromRGB(235, 25, 25) or th.btnText
end

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 22)
minBtn.Position = UDim2.new(1, -56, 0, 5)
minBtn.Text = "_"
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 12
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 4
minBtn.Parent = topBar
registerTheme(minBtn, "surface", "BackgroundColor3")
registerTheme(minBtn, "ink", "TextColor3")
applyBrutalBorder(minBtn)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 11
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 4
closeBtn.Parent = topBar
registerTheme(closeBtn, "danger", "BackgroundColor3")
applyBrutalBorder(closeBtn)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    bubbleBtn.Visible = true
    blurEffect.Enabled = false
end)

closeBtn.MouseButton1Click:Connect(function()
    state.previewActive = false
    if blurEffect then blurEffect:Destroy() end
    screen:Destroy()
end)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -32)
body.Position = UDim2.new(0, 0, 0, 32)
body.BackgroundTransparency = 1
body.ClipsDescendants = true
body.ZIndex = 3
body.Parent = main

local navBar = Instance.new("ScrollingFrame")
navBar.Size = UDim2.new(1, -16, 0, 28)
navBar.Position = UDim2.new(0, 8, 0, 6)
navBar.BackgroundTransparency = uiPrefs.bgTransparency
navBar.BorderSizePixel = 0
navBar.ScrollBarThickness = 0
navBar.ScrollingDirection = Enum.ScrollingDirection.X
navBar.AutomaticCanvasSize = Enum.AutomaticSize.X
navBar.CanvasSize = UDim2.new(0, 0, 0, 0)
navBar.ZIndex = 3
navBar.Parent = body
registerTheme(navBar, "surface", "BackgroundColor3")
applyBrutalBorder(navBar)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 5)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Parent = navBar

local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 5)
navPad.PaddingRight = UDim.new(0, 5)
navPad.Parent = navBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -78)
contentArea.Position = UDim2.new(0, 8, 0, 38)
contentArea.BackgroundTransparency = uiPrefs.bgTransparency
contentArea.BorderSizePixel = 0
contentArea.ZIndex = 3
contentArea.Parent = body
registerTheme(contentArea, "surface", "BackgroundColor3")
applyBrutalBorder(contentArea)

local footerBar = Instance.new("Frame")
footerBar.Size = UDim2.new(1, -16, 0, 32)
footerBar.Position = UDim2.new(0, 8, 1, -36)
footerBar.BackgroundTransparency = uiPrefs.bgTransparency
footerBar.BorderSizePixel = 0
footerBar.ZIndex = 3
footerBar.Parent = body
registerTheme(footerBar, "surface", "BackgroundColor3")
applyBrutalBorder(footerBar)

makeDraggableFrame(footerBar, main, nil)

local pages = {}
local tabButtons = {}
local activeTabKey = "presets"

local function refreshTabStyles()
    local th = getCurrentTheme()
    for k, btn in pairs(tabButtons) do
        local isAct = (k == activeTabKey)
        btn.BackgroundColor3 = isAct and th.accent or th.chipBg
        btn.TextColor3 = isAct and th.btnText or th.ink
    end
end

local function switchTab(tabKey)
    activeTabKey = tabKey
    for k, page in pairs(pages) do
        page.Visible = (k == tabKey)
    end
    refreshTabStyles()
end

local function createTab(key, label, width)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 90, 0, 20)
    btn.Text = string.upper(label)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = navBar
    applyBrutalBorder(btn)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -8)
    scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false
    scroll.ZIndex = 4
    scroll.Parent = contentArea

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = scroll

    pages[key] = scroll
    tabButtons[key] = btn

    btn.MouseButton1Click:Connect(function()
        switchTab(key)
    end)

    return scroll
end

local sectionFrames = {}

local function makeSection(parent, title)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -6, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundTransparency = uiPrefs.bgTransparency
    box.BorderSizePixel = 0
    box.ZIndex = 4
    box.Parent = parent
    registerTheme(box, "bg", "BackgroundColor3")
    applyBrutalBorder(box)
    table.insert(sectionFrames, box)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = box

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = box

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, 0, 0, 16)
    hdr.BackgroundTransparency = 1
    hdr.Text = string.upper(title)
    hdr.Font = Enum.Font.GothamBlack
    hdr.TextSize = 10
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.ZIndex = 5
    hdr.Parent = box
    registerTheme(hdr, "ink", "TextColor3")

    return box
end

local function makeSliderRow(parent, labelText, minVal, maxVal, defaultVal, isInt, onChanged)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.ZIndex = 5
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 132, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 5
    lbl.Parent = row
    registerTheme(lbl, "ink", "TextColor3")

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -190, 0, 12)
    track.Position = UDim2.new(0, 136, 0.5, -6)
    track.Text = ""
    track.AutoButtonColor = false
    track.BorderSizePixel = 0
    track.ZIndex = 5
    track.Parent = row
    registerTheme(track, "surface", "BackgroundColor3")
    applyBrutalBorder(track)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = track
    registerTheme(fill, "accent", "BackgroundColor3")

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(0, 48, 0, 20)
    valBox.Position = UDim2.new(1, -48, 0.5, -10)
    valBox.Font = Enum.Font.Code
    valBox.TextSize = 10
    valBox.ClearTextOnFocus = false
    valBox.BorderSizePixel = 0
    valBox.ZIndex = 5
    valBox.Parent = row
    registerTheme(valBox, "surface", "BackgroundColor3")
    registerTheme(valBox, "ink", "TextColor3")
    applyBrutalBorder(valBox)

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

local chipSelectorsList = {}

local function makeChipSelector(parent, labelText, options, initialVal, onSelect)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = holder
    registerTheme(lbl, "subInk", "TextColor3")

    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 0)
    wrap.Position = UDim2.new(0, 0, 0, 16)
    wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 5
    wrap.Parent = holder

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 74, 0, 22)
    grid.CellPadding = UDim2.new(0, 4, 0, 4)
    grid.Parent = wrap

    local chips = {}
    local current = initialVal

    local function refresh(val)
        current = val
        local th = getCurrentTheme()
        for optVal, btn in pairs(chips) do
            local active = (optVal == current)
            btn.BackgroundColor3 = active and th.accent or th.surface
            btn.TextColor3 = active and th.btnText or th.ink
        end
    end

    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Text = tostring(opt)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        btn.ZIndex = 5
        btn.Parent = wrap
        applyBrutalBorder(btn)
        chips[opt] = btn

        btn.MouseButton1Click:Connect(function()
            refresh(opt)
            if onSelect then
                onSelect(opt)
            end
        end)
    end

    refresh(initialVal)

    local ctrl = {
        setSelected = refresh,
        getSelected = function()
            return current
        end,
        retheme = function()
            refresh(current)
        end
    }
    table.insert(chipSelectorsList, ctrl)
    return ctrl
end

local function makeSmallActionBtn(parent, text, posX, width, roleKey, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, width, 0, 22)
    b.Position = UDim2.new(0, posX, 0, 0)
    b.Text = string.upper(text)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 9
    b.BorderSizePixel = 0
    b.ZIndex = 5
    b.Parent = parent
    registerTheme(b, roleKey, "BackgroundColor3")
    if roleKey == "danger" then
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif roleKey == "surface" or roleKey == "chipBg" then
        registerTheme(b, "ink", "TextColor3")
    else
        registerTheme(b, "btnText", "TextColor3")
    end
    applyBrutalBorder(b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local pagePresets = createTab("presets", "Preset & Stack", 94)
local pageCustom = createTab("custom", "Custom Gerakan", 98)
local pageSlots = createTab("slots", "Cue & 6-Slot", 88)
local pageSettings = createTab("settings", "Settings", 72)

local refreshMembersUI
local refreshSlotsAndCuesUI
local loadCueIntoEditor
local openRigSetupModal
local rebuildPreviewDots

local function autoSaveTrigger()
    if uiPrefs.autoSaveOnApply then
        saveWorkFile()
    end
end

local rigModalOverlay = Instance.new("Frame")
rigModalOverlay.Name = "RigSetupModal"
rigModalOverlay.Size = UDim2.new(1, 0, 1, 0)
rigModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rigModalOverlay.BackgroundTransparency = 0.45
rigModalOverlay.BorderSizePixel = 0
rigModalOverlay.Visible = false
rigModalOverlay.ZIndex = 30
rigModalOverlay.Parent = main

local rigModalBox = Instance.new("Frame")
rigModalBox.Size = UDim2.new(0.88, 0, 0.84, 0)
rigModalBox.Position = UDim2.new(0.06, 0, 0.08, 0)
rigModalBox.BorderSizePixel = 0
rigModalBox.ZIndex = 31
rigModalBox.Parent = rigModalOverlay
registerTheme(rigModalBox, "bg", "BackgroundColor3")
applyBrutalBorder(rigModalBox)

local rigModalHeader = Instance.new("Frame")
rigModalHeader.Size = UDim2.new(1, 0, 0, 28)
rigModalHeader.BorderSizePixel = 0
rigModalHeader.ZIndex = 32
rigModalHeader.Parent = rigModalBox
registerTheme(rigModalHeader, "header", "BackgroundColor3")
applyBrutalBorder(rigModalHeader)

local rigModalTitle = Instance.new("TextLabel")
rigModalTitle.Size = UDim2.new(1, -38, 1, 0)
rigModalTitle.Position = UDim2.new(0, 8, 0, 0)
rigModalTitle.BackgroundTransparency = 1
rigModalTitle.Text = "SETUP JUMLAH & ALAMAT DMX SEBELUM MEMBUAT CUE"
rigModalTitle.Font = Enum.Font.GothamBlack
rigModalTitle.TextSize = 10
rigModalTitle.TextXAlignment = Enum.TextXAlignment.Left
rigModalTitle.ZIndex = 33
rigModalTitle.Parent = rigModalHeader
registerTheme(rigModalTitle, "btnText", "TextColor3")

local rigModalCloseBtn = Instance.new("TextButton")
rigModalCloseBtn.Size = UDim2.new(0, 24, 0, 20)
rigModalCloseBtn.Position = UDim2.new(1, -28, 0, 4)
rigModalCloseBtn.Text = "X"
rigModalCloseBtn.Font = Enum.Font.GothamBlack
rigModalCloseBtn.TextSize = 11
rigModalCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rigModalCloseBtn.BorderSizePixel = 0
rigModalCloseBtn.ZIndex = 34
rigModalCloseBtn.Parent = rigModalHeader
registerTheme(rigModalCloseBtn, "danger", "BackgroundColor3")
applyBrutalBorder(rigModalCloseBtn)

local rigModalScroll = Instance.new("ScrollingFrame")
rigModalScroll.Size = UDim2.new(1, -12, 1, -68)
rigModalScroll.Position = UDim2.new(0, 6, 0, 32)
rigModalScroll.BackgroundTransparency = 1
rigModalScroll.BorderSizePixel = 0
rigModalScroll.ScrollBarThickness = 4
rigModalScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
rigModalScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
rigModalScroll.ZIndex = 32
rigModalScroll.Parent = rigModalBox

local rigModalList = Instance.new("UIListLayout")
rigModalList.Padding = UDim.new(0, 6)
rigModalList.Parent = rigModalScroll

local pendingAfterRigCallback = nil

rigModalCloseBtn.MouseButton1Click:Connect(function()
    rigModalOverlay.Visible = false
    pendingAfterRigCallback = nil
    setStatus("SETUP DMX DITUTUP", false)
end)

local modalChipFix = makeChipSelector(rigModalScroll, "1. Pilih Tipe Fixture (Clara / Lainnya):", {
    "clara", "strobe", "mapple", "parled", "fogger", "blinder",
    "flower", "pixel", "retro", "wall", "windmill", "sbar"
}, state.rigType, function(v)
    state.rigType = v
end)

local modalSldCount = makeSliderRow(rigModalScroll, "2. Jumlah Unit Lampu", 1, 32, state.rigCount, true, function(v)
    state.rigCount = v
end)

local modalSldStart = makeSliderRow(rigModalScroll, "3. Alamat DMX Awal", 1, 512, state.rigStartAddr, true, function(v)
    state.rigStartAddr = v
end)

local modalChipMode = makeChipSelector(rigModalScroll, "4. Mode Alamat (Independen = Pisah Ch, Multi = Sama):", {"independen", "multi"}, state.rigMode, function(v)
    state.rigMode = v
end)

for _, desc in ipairs(rigModalScroll:GetDescendants()) do
    if desc:IsA("GuiObject") then
        desc.ZIndex = math.max(33, desc.ZIndex + 28)
    end
end

local modalFoot = Instance.new("Frame")
modalFoot.Size = UDim2.new(1, -12, 0, 28)
modalFoot.Position = UDim2.new(0, 6, 1, -32)
modalFoot.BackgroundTransparency = 1
modalFoot.ZIndex = 32
modalFoot.Parent = rigModalBox

local modalConfirmBtn = Instance.new("TextButton")
modalConfirmBtn.Size = UDim2.new(0.54, 0, 0, 24)
modalConfirmBtn.Position = UDim2.new(0, 0, 0, 2)
modalConfirmBtn.Text = "TERAPKAN DMX & LANJUT"
modalConfirmBtn.Font = Enum.Font.GothamBlack
modalConfirmBtn.TextSize = 9
modalConfirmBtn.BorderSizePixel = 0
modalConfirmBtn.ZIndex = 33
modalConfirmBtn.Parent = modalFoot
registerTheme(modalConfirmBtn, "accent", "BackgroundColor3")
registerTheme(modalConfirmBtn, "btnText", "TextColor3")
applyBrutalBorder(modalConfirmBtn)

local modalSkipBtn = Instance.new("TextButton")
modalSkipBtn.Size = UDim2.new(0.28, 0, 0, 24)
modalSkipBtn.Position = UDim2.new(0.56, 0, 0, 2)
modalSkipBtn.Text = "PAKAI SAAT INI"
modalSkipBtn.Font = Enum.Font.GothamBlack
modalSkipBtn.TextSize = 9
modalSkipBtn.BorderSizePixel = 0
modalSkipBtn.ZIndex = 33
modalSkipBtn.Parent = modalFoot
registerTheme(modalSkipBtn, "surface", "BackgroundColor3")
registerTheme(modalSkipBtn, "ink", "TextColor3")
applyBrutalBorder(modalSkipBtn)

local modalExitBtn = Instance.new("TextButton")
modalExitBtn.Size = UDim2.new(0.14, 0, 0, 24)
modalExitBtn.Position = UDim2.new(0.86, 0, 0, 2)
modalExitBtn.Text = "KELUAR"
modalExitBtn.Font = Enum.Font.GothamBlack
modalExitBtn.TextSize = 9
modalExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modalExitBtn.BorderSizePixel = 0
modalExitBtn.ZIndex = 33
modalExitBtn.Parent = modalFoot
registerTheme(modalExitBtn, "danger", "BackgroundColor3")
applyBrutalBorder(modalExitBtn)

modalConfirmBtn.MouseButton1Click:Connect(function()
    workData.rig = buildAutoPatchedRig(state.rigType, state.rigCount, state.rigStartAddr, state.rigMode)
    state.rigConfigured = true
    resetSelectionAll()
    rigModalOverlay.Visible = false
    if refreshMembersUI then refreshMembersUI() end
    if rebuildPreviewDots then rebuildPreviewDots() end
    local cb = pendingAfterRigCallback
    pendingAfterRigCallback = nil
    if cb then
        cb()
    else
        autoSaveTrigger()
        setStatus("DMX SET: " .. state.rigCount .. "X " .. string.upper(state.rigType), false)
    end
end)

modalSkipBtn.MouseButton1Click:Connect(function()
    state.rigConfigured = true
    rigModalOverlay.Visible = false
    local cb = pendingAfterRigCallback
    pendingAfterRigCallback = nil
    if cb then
        cb()
    end
end)

modalExitBtn.MouseButton1Click:Connect(function()
    rigModalOverlay.Visible = false
    pendingAfterRigCallback = nil
    setStatus("BATAL SETUP DMX", false)
end)

openRigSetupModal = function(onDoneCallback)
    pendingAfterRigCallback = onDoneCallback
    modalChipFix.setSelected(state.rigType)
    modalSldCount.setValue(state.rigCount)
    modalSldStart.setValue(state.rigStartAddr)
    modalChipMode.setSelected(state.rigMode)
    rigModalOverlay.Visible = true
end

local function executeWithRigCheck(cueKey, actionFn)
    local isNewCue = (workData.cues[cueKey] == nil)
    if uiPrefs.promptRigOnNewCue and isNewCue and not state.rigConfigured then
        openRigSetupModal(actionFn)
    else
        actionFn()
    end
end

local function applyEffectToCue(cueKey, layerName, slotIdx, effConfig)
    executeWithRigCheck(cueKey, function()
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
        autoSaveTrigger()
        if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
        setStatus("TERSIMPAN -> CUE " .. cueKey .. " (" .. string.upper(effConfig.shape or "FX") .. ")", false)
    end)
end

local function applyLayerStackToCue(cueKey, combo)
    executeWithRigCheck(cueKey, function()
        local members = getSelectedMemberIndices()
        local cueEffArr = normalizeEffArray({})
        cueEffArr[1] = buildEffObject(combo.s1, members, true)
        cueEffArr[2] = buildEffObject(combo.s2, members, true)
        cueEffArr[3] = buildEffObject(combo.s3, members, true)

        for i = 1, 3 do
            workData.eff[i] = deepCopy(cueEffArr[i])
            workData.eff[i].on = false
            workData.eff[i].unused = nil
        end

        workData.cues[cueKey] = {
            layer = "eff",
            fx = getSelectedFxEmptyMap(),
            eff = cueEffArr
        }
        autoSaveTrigger()
        if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
        setStatus("STACK 3-LAYER -> CUE " .. cueKey, false)
    end)
end

local function generateChaseFromPattern(cueKey, patternKey, patternName)
    executeWithRigCheck(cueKey, function()
        local indices = getSelectedMemberIndices()
        local totalSel = math.max(1, #indices)
        local numSteps = state.chaseStepsCount or 8
        local stepsArr = {}

        for s = 1, numSteps do
            local frame = {}
            local prog = (s - 1) / numSteps
            for posIdx, rigIdx in ipairs(indices) do
                local fix = workData.rig[rigIdx]
                if fix then
                    local fType = string.lower(fix.t or "clara")
                    local phaseOff = (posIdx - 1) / totalSel
                    local ang = (prog + phaseOff) * math.pi * 2
                    local ov = {}

                    if patternKey == "wave_pan" then
                        ov.pan = 0.5 + (math.sin(ang) * 0.4)
                        ov.tilt = 0.5
                    elseif patternKey == "pingpong" then
                        local dir = (s % 2 == 1) and 1 or -1
                        local side = (posIdx % 2 == 1) and 1 or -1
                        ov.pan = 0.5 + (0.35 * dir * side)
                        ov.tilt = 0.5 + (0.25 * dir)
                    elseif patternKey == "stair_tilt" then
                        ov.pan = 0.5
                        ov.tilt = 0.2 + (((prog + phaseOff) % 1) * 0.65)
                    elseif patternKey == "odd_even" then
                        local isOdd = (posIdx % 2 == 1)
                        local active = ((s % 2 == 1) and isOdd) or ((s % 2 == 0) and not isOdd)
                        local val = active and 1 or 0
                        ov.dim = val
                        ov.int = val
                        ov.r = val
                        ov.g = val
                        ov.b = val
                        ov.d1 = val
                        ov.d2 = val
                        ov.d3 = val
                        ov.d4 = val
                        ov.mdim = val
                        ov.adim = val
                        ov.rdim = val
                        ov.bdim = val
                    elseif patternKey == "fan_io" then
                        local mid = (totalSel + 1) / 2
                        local dist = (posIdx - mid) / math.max(1, totalSel / 2)
                        local wave = math.sin(prog * math.pi * 2)
                        ov.pan = 0.5 + (dist * 0.38 * wave)
                        ov.tilt = 0.5 + (0.25 * math.cos(prog * math.pi * 2))
                    elseif patternKey == "color_run" then
                        ov.color = (prog + phaseOff) % 1
                        ov.col1 = (prog + phaseOff) % 1
                        ov.acol = (prog + phaseOff) % 1
                        ov.bcol = (prog + phaseOff) % 1
                        ov.r = 0.5 + 0.5 * math.sin(ang)
                        ov.g = 0.5 + 0.5 * math.sin(ang + 2.09)
                        ov.b = 0.5 + 0.5 * math.sin(ang + 4.18)
                    end

                    frame[tostring(rigIdx)] = {
                        t = fType,
                        v = makeFullV(fType, ov)
                    }
                end
            end
            table.insert(stepsArr, frame)
        end

        workData.cues[cueKey] = {
            layer = "chs",
            fx = {},
            eff = {},
            chase = {
                glide = state.chaseGlide,
                dir = state.chaseDir,
                seq = false,
                off = 0,
                rate = state.chaseRate,
                steps = stepsArr
            }
        }
        autoSaveTrigger()
        if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
        setStatus("CHASE '" .. patternName .. "' (" .. numSteps .. " STEP) -> CUE " .. cueKey, false)
    end)
end

local secMembers = makeSection(pagePresets, "1. PILIH LAMPU TARGET (INDEKS RIG) & TAP TEMPO BPM")

local memberToolsRow = Instance.new("Frame")
memberToolsRow.Size = UDim2.new(1, 0, 0, 22)
memberToolsRow.BackgroundTransparency = 1
memberToolsRow.ZIndex = 5
memberToolsRow.Parent = secMembers

makeSmallActionBtn(memberToolsRow, "Semua", 0, 48, "accent", function()
    for i = 1, #workData.rig do selectedMembers[i] = true end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Ganjil", 52, 48, "surface", function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 1) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Genap", 104, 48, "surface", function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 0) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Setup DMX", 156, 74, "secondary", function()
    openRigSetupModal(function()
        autoSaveTrigger()
        setStatus("DMX RIG: " .. #workData.rig .. " UNIT", false)
    end)
end)

local tapTimes = {}
local customControls = {}

local tapTempoBtn = makeSmallActionBtn(memberToolsRow, "TAP BPM: 120", 234, 96, "accent", function()
    local now = os.clock()
    if #tapTimes > 0 and (now - tapTimes[#tapTimes]) > 2.0 then
        tapTimes = {}
    end
    table.insert(tapTimes, now)
    if #tapTimes > 6 then
        table.remove(tapTimes, 1)
    end
    if #tapTimes >= 2 then
        local sum = 0
        for i = 2, #tapTimes do
            sum = sum + (tapTimes[i] - tapTimes[i - 1])
        end
        local avgInterval = sum / (#tapTimes - 1)
        local bpm = math.clamp(math.floor((60 / math.max(0.15, avgInterval)) + 0.5), 40, 240)
        local hzRate = math.clamp(math.floor(((bpm / 60) * 0.5) * 100 + 0.5) / 100, 0.1, 5.0)
        local chsRate = math.clamp(math.floor((bpm / 60) * 100 + 0.5) / 100, 0.2, 10.0)
        state.bpm = bpm
        state.rate = hzRate
        state.chaseRate = chsRate
        if customControls.syncFromState then
            customControls.syncFromState()
        end
        setStatus("SYNC " .. bpm .. " BPM | RATE: " .. string.format("%.2f", hzRate), false)
    end
end)

RunService.Heartbeat:Connect(function()
    if tapTempoBtn and tapTempoBtn.Parent then
        tapTempoBtn.Text = "TAP BPM: " .. tostring(state.bpm)
    end
end)

local memberGridHolder = Instance.new("Frame")
memberGridHolder.Size = UDim2.new(1, 0, 0, 0)
memberGridHolder.AutomaticSize = Enum.AutomaticSize.Y
memberGridHolder.BackgroundTransparency = 1
memberGridHolder.ZIndex = 5
memberGridHolder.Parent = secMembers

local memberGrid = Instance.new("UIGridLayout")
memberGrid.CellSize = UDim2.new(0, 74, 0, 24)
memberGrid.CellPadding = UDim2.new(0, 4, 0, 4)
memberGrid.Parent = memberGridHolder

refreshMembersUI = function()
    local th = getCurrentTheme()
    for _, child in ipairs(memberGridHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for i, fix in ipairs(workData.rig) do
        local b = Instance.new("TextButton")
        local active = selectedMembers[i] == true
        b.BackgroundColor3 = active and th.accent or th.surface
        b.Text = "#" .. i .. " " .. string.upper(string.sub(fix.t or "?", 1, 3)) .. "(" .. tostring(fix.a) .. ")"
        b.Font = Enum.Font.GothamBlack
        b.TextSize = 9
        b.TextColor3 = active and th.btnText or th.ink
        b.BorderSizePixel = 0
        b.ZIndex = 5
        b.Parent = memberGridHolder
        applyBrutalBorder(b)

        b.MouseButton1Click:Connect(function()
            selectedMembers[i] = not selectedMembers[i]
            refreshMembersUI()
        end)
    end
end

local secLayerStack = makeSection(pagePresets, "2. LAYER STACKER (GABUNG GERAK + WARNA + DIMMER 1 KLIK)")

local stackGridWrap = Instance.new("Frame")
stackGridWrap.Size = UDim2.new(1, 0, 0, 0)
stackGridWrap.AutomaticSize = Enum.AutomaticSize.Y
stackGridWrap.BackgroundTransparency = 1
stackGridWrap.ZIndex = 5
stackGridWrap.Parent = secLayerStack

local stackGrid = Instance.new("UIGridLayout")
stackGrid.CellSize = UDim2.new(0.49, 0, 0, 28)
stackGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
stackGrid.Parent = stackGridWrap

for _, combo in ipairs(LAYER_STACK_COMBOS) do
    local btn = Instance.new("TextButton")
    btn.Text = string.upper(combo.name)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 9
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Parent = stackGridWrap
    registerTheme(btn, "accent", "BackgroundColor3")
    registerTheme(btn, "btnText", "TextColor3")
    applyBrutalBorder(btn)

    btn.MouseButton1Click:Connect(function()
        applyLayerStackToCue(state.cueId, combo)
    end)
end

local secMotionTpl = makeSection(pagePresets, "3. PRESET GERAKAN PAN / TILT (12 POLA GERAK)")

local movGridWrap = Instance.new("Frame")
movGridWrap.Size = UDim2.new(1, 0, 0, 0)
movGridWrap.AutomaticSize = Enum.AutomaticSize.Y
movGridWrap.BackgroundTransparency = 1
movGridWrap.ZIndex = 5
movGridWrap.Parent = secMotionTpl

local movGrid = Instance.new("UIGridLayout")
movGrid.CellSize = UDim2.new(0.49, 0, 0, 28)
movGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
movGrid.Parent = movGridWrap

local secEffTpl = makeSection(pagePresets, "4. PRESET EFFECT WARNA / DIMMER / BEAM (8 POLA)")

local effGridWrap = Instance.new("Frame")
effGridWrap.Size = UDim2.new(1, 0, 0, 0)
effGridWrap.AutomaticSize = Enum.AutomaticSize.Y
effGridWrap.BackgroundTransparency = 1
effGridWrap.ZIndex = 5
effGridWrap.Parent = secEffTpl

local effGrid = Instance.new("UIGridLayout")
effGrid.CellSize = UDim2.new(0.49, 0, 0, 28)
effGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
effGrid.Parent = effGridWrap

for _, tpl in ipairs(MOTION_PRESETS) do
    local isMov = (tpl.cat == "GERAK")
    local btn = Instance.new("TextButton")
    btn.Text = string.upper(tpl.name) .. " [" .. string.upper(tpl.shape) .. "]"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Parent = isMov and movGridWrap or effGridWrap
    registerTheme(btn, isMov and "surface" or "secondary", "BackgroundColor3")
    registerTheme(btn, isMov and "ink" or "btnText", "TextColor3")
    applyBrutalBorder(btn)

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
    end)
end

local secChaseTpl = makeSection(pagePresets, "5. CUSTOM STEP BUILDER MINI (AUTO-CHASE GENERATOR)")

makeChipSelector(secChaseTpl, "Jumlah Step Otomatis (steps):", {4, 8, 16, 32}, state.chaseStepsCount, function(v)
    state.chaseStepsCount = v
end)

local sldChsRate = makeSliderRow(secChaseTpl, "Kecepatan Step (rate)", 0.2, 10.0, state.chaseRate, false, function(v)
    state.chaseRate = v
end)

local sldChsGlide = makeSliderRow(secChaseTpl, "Kehalusan Transisi (glide)", 0.0, 1.0, state.chaseGlide, false, function(v)
    state.chaseGlide = v
end)

makeChipSelector(secChaseTpl, "Arah Step Chase (dir):", {">", "<", "<>", "rand"}, state.chaseDir, function(v)
    state.chaseDir = v
end)

local chsGridWrap = Instance.new("Frame")
chsGridWrap.Size = UDim2.new(1, 0, 0, 0)
chsGridWrap.AutomaticSize = Enum.AutomaticSize.Y
chsGridWrap.BackgroundTransparency = 1
chsGridWrap.ZIndex = 5
chsGridWrap.Parent = secChaseTpl

local chsGrid = Instance.new("UIGridLayout")
chsGrid.CellSize = UDim2.new(0.49, 0, 0, 28)
chsGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
chsGrid.Parent = chsGridWrap

for _, chsTpl in ipairs(CHASE_STEP_TEMPLATES) do
    local btn = Instance.new("TextButton")
    btn.Text = "GENERATE: " .. string.upper(chsTpl.name)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Parent = chsGridWrap
    registerTheme(btn, "chipBg", "BackgroundColor3")
    registerTheme(btn, "ink", "TextColor3")
    applyBrutalBorder(btn)

    btn.MouseButton1Click:Connect(function()
        generateChaseFromPattern(state.cueId, chsTpl.pattern, chsTpl.name)
    end)
end

local secPreviewBox = makeSection(pageCustom, "1. LIVE STAGE PREVIEW (SIMULASI MODEL BEAM CLARA)")

local previewTopRow = Instance.new("Frame")
previewTopRow.Size = UDim2.new(1, 0, 0, 22)
previewTopRow.BackgroundTransparency = 1
previewTopRow.ZIndex = 5
previewTopRow.Parent = secPreviewBox

local previewToggleBtn = Instance.new("TextButton")
previewToggleBtn.Size = UDim2.new(0, 138, 0, 22)
previewToggleBtn.Text = "STAGE PREVIEW: ON"
previewToggleBtn.Font = Enum.Font.GothamBlack
previewToggleBtn.TextSize = 9
previewToggleBtn.BorderSizePixel = 0
previewToggleBtn.ZIndex = 5
previewToggleBtn.Parent = previewTopRow
registerTheme(previewToggleBtn, "accent", "BackgroundColor3")
registerTheme(previewToggleBtn, "btnText", "TextColor3")
applyBrutalBorder(previewToggleBtn)

local previewInfoLbl = Instance.new("TextLabel")
previewInfoLbl.Size = UDim2.new(1, -145, 1, 0)
previewInfoLbl.Position = UDim2.new(0, 145, 0, 0)
previewInfoLbl.BackgroundTransparency = 1
previewInfoLbl.Text = "CLARA BEAM | CIRCLE"
previewInfoLbl.Font = Enum.Font.Code
previewInfoLbl.TextSize = 9
previewInfoLbl.TextXAlignment = Enum.TextXAlignment.Right
previewInfoLbl.ZIndex = 5
previewInfoLbl.Parent = previewTopRow
registerTheme(previewInfoLbl, "subInk", "TextColor3")

local previewCanvas = Instance.new("Frame")
previewCanvas.Size = UDim2.new(1, 0, 0, 110)
previewCanvas.ClipsDescendants = true
previewCanvas.BorderSizePixel = 0
previewCanvas.ZIndex = 5
previewCanvas.Parent = secPreviewBox
registerTheme(previewCanvas, "canvas", "BackgroundColor3")
applyBrutalBorder(previewCanvas)

local stageTruss = Instance.new("Frame")
stageTruss.Size = UDim2.new(0.92, 0, 0, 4)
stageTruss.Position = UDim2.new(0.04, 0, 0.14, 0)
stageTruss.BackgroundColor3 = Color3.fromRGB(70, 72, 85)
stageTruss.BorderSizePixel = 0
stageTruss.ZIndex = 6
stageTruss.Parent = previewCanvas

local stageFloor = Instance.new("Frame")
stageFloor.Size = UDim2.new(1, 0, 0, 2)
stageFloor.Position = UDim2.new(0, 0, 0.88, 0)
stageFloor.BackgroundColor3 = Color3.fromRGB(55, 58, 70)
stageFloor.BorderSizePixel = 0
stageFloor.ZIndex = 6
stageFloor.Parent = previewCanvas

local previewFixtures = {}
rebuildPreviewDots = function()
    local th = getCurrentTheme()
    for _, item in ipairs(previewFixtures) do
        if item.head then item.head:Destroy() end
        if item.beam then item.beam:Destroy() end
        if item.spot then item.spot:Destroy() end
    end
    previewFixtures = {}
    local total = math.max(1, #workData.rig)
    for i = 1, total do
        local baseX = (total == 1) and 0.5 or (0.10 + ((i - 1) * (0.80 / math.max(1, total - 1))))

        local beam = Instance.new("Frame")
        beam.Size = UDim2.new(0, 10, 0, 72)
        beam.AnchorPoint = Vector2.new(0.5, 0)
        beam.Position = UDim2.new(baseX, 0, 0.16, 0)
        beam.BackgroundColor3 = th.accent
        beam.BackgroundTransparency = 0.68
        beam.BorderSizePixel = 0
        beam.ZIndex = 6
        beam.Parent = previewCanvas

        local head = Instance.new("Frame")
        head.Size = UDim2.new(0, 14, 0, 10)
        head.AnchorPoint = Vector2.new(0.5, 0.5)
        head.Position = UDim2.new(baseX, 0, 0.14, 0)
        head.BackgroundColor3 = th.header
        head.BorderSizePixel = 0
        head.ZIndex = 8
        head.Parent = previewCanvas
        applyBrutalBorder(head)

        local spot = Instance.new("Frame")
        spot.Size = UDim2.new(0, 14, 0, 14)
        spot.AnchorPoint = Vector2.new(0.5, 0.5)
        spot.Position = UDim2.new(baseX, 0, 0.78, 0)
        spot.BackgroundColor3 = th.accent
        spot.BorderSizePixel = 0
        spot.ZIndex = 7
        spot.Parent = previewCanvas
        applyBrutalBorder(spot)

        local num = Instance.new("TextLabel")
        num.Size = UDim2.new(1, 0, 1, 0)
        num.BackgroundTransparency = 1
        num.Text = tostring(i)
        num.Font = Enum.Font.GothamBlack
        num.TextSize = 8
        num.TextColor3 = Color3.fromRGB(10, 10, 10)
        num.ZIndex = 9
        num.Parent = spot

        previewFixtures[i] = {head = head, beam = beam, spot = spot, baseX = baseX}
    end
end

previewToggleBtn.MouseButton1Click:Connect(function()
    state.previewActive = not state.previewActive
    local th = getCurrentTheme()
    previewToggleBtn.Text = state.previewActive and "STAGE PREVIEW: ON" or "STAGE PREVIEW: OFF"
    previewToggleBtn.BackgroundColor3 = state.previewActive and th.accent or th.surface
    previewToggleBtn.TextColor3 = state.previewActive and th.btnText or th.ink
    if state.previewActive then
        rebuildPreviewDots()
    end
end)

RunService.RenderStepped:Connect(function()
    if not state.previewActive or not pageCustom.Visible or not main.Visible then return end
    if #previewFixtures ~= #workData.rig then
        rebuildPreviewDots()
    end
    previewInfoLbl.Text = "CLARA SIM | " .. string.upper(state.shape) .. " | RATE:" .. string.format("%.2f", state.rate)
    local t = os.clock() * (state.rate * 2.5)
    local total = math.max(1, #previewFixtures)
    local th = getCurrentTheme()

    for i, item in ipairs(previewFixtures) do
        local isSel = selectedMembers[i] == true
        item.head.Visible = isSel
        item.beam.Visible = isSel
        item.spot.Visible = isSel
        if isSel then
            local idxPos = i
            if state.groups > 1 then
                idxPos = ((i - 1) % state.groups) + 1
            end
            local denom = (state.groups > 1) and state.groups or total
            local spread = (state.phase / 360) * ((idxPos - 1) / math.max(1, denom)) * math.pi * 2
            if state.wing > 0 and i > (total / 2) then
                spread = -spread
            end
            local ang = (state.dir == "<") and (-t + spread) or (t + spread)
            if state.dir == "<>" then
                ang = math.sin(t) * math.pi + spread
            end
            local ox, oy = 0, 0
            if state.shape == "circle" then
                ox = math.cos(ang) * state.sx * 0.36
                oy = math.sin(ang) * state.sy * 0.28
            elseif state.shape == "fig8" then
                ox = math.sin(ang) * state.sx * 0.36
                oy = math.sin(ang * 2) * state.sy * 0.28
            elseif state.shape == "sine" then
                if state.wax == "y" then
                    oy = math.sin(ang) * state.sy * 0.28
                else
                    ox = math.sin(ang) * state.sx * 0.36
                end
            elseif state.shape == "saw" then
                local saw = ((ang / (math.pi * 2)) % 1) * 2 - 1
                if state.wax == "y" then
                    oy = saw * state.sy * 0.28
                else
                    ox = saw * state.sx * 0.36
                end
            elseif state.shape == "square" then
                local sq = (math.sin(ang) >= 0) and 1 or -1
                ox = sq * state.sx * 0.34
                oy = sq * state.sy * 0.20
            else
                ox = math.sin(ang * 1.3 + i) * state.sx * 0.35
                oy = math.cos(ang * 1.7 - i) * state.sy * 0.26
            end

            local targetX = math.clamp(item.baseX + ox, 0.06, 0.94)
            local targetY = math.clamp(0.66 + oy, 0.36, 0.88)
            item.spot.Position = UDim2.new(targetX, 0, targetY, 0)

            local dx = (targetX - item.baseX) * previewCanvas.AbsoluteSize.X
            local dy = (targetY - 0.14) * previewCanvas.AbsoluteSize.Y
            local dist = math.sqrt((dx * dx) + (dy * dy))
            local deg = math.deg(math.atan2(dy, dx)) - 90

            item.beam.Position = UDim2.new(item.baseX, dx * 0.5, 0.14, dy * 0.5)
            item.beam.AnchorPoint = Vector2.new(0.5, 0.5)
            item.beam.Size = UDim2.new(0, 12, 0, math.max(10, dist))
            item.beam.Rotation = deg
            item.head.Rotation = deg

            if state.target == "color" then
                local hue = ((ang / (math.pi * 2)) % 1)
                local col = Color3.fromHSV(hue, 0.9, 1)
                item.beam.BackgroundColor3 = col
                item.spot.BackgroundColor3 = col
            elseif state.target == "dim" or state.target == "strobe" then
                local pulse = 0.5 + 0.5 * math.sin(ang)
                item.beam.BackgroundTransparency = 0.25 + ((1 - pulse) * 0.70)
                item.spot.BackgroundColor3 = th.accent
            else
                item.beam.BackgroundColor3 = th.accent
                item.beam.BackgroundTransparency = 0.65
                item.spot.BackgroundColor3 = th.accent
            end
        end
    end
end)

local secCustomTop = makeSection(pageCustom, "2. ATUR LAYER, TARGET & BENTUK GELOMBANG")

local chipLayer = makeChipSelector(secCustomTop, "Mode Layer (mov = Gerak Tunggal, eff = Multi-Slot 6 Efek):", {"mov", "eff"}, state.layerMode, function(v)
    state.layerMode = v
end)

local chipTarget = makeChipSelector(secCustomTop, "Target Parameter:", {"pos", "color", "dim", "strobe", "beam"}, state.target, function(v)
    state.target = v
end)

local chipShape = makeChipSelector(secCustomTop, "Bentuk Gerakan / Gelombang (Shape):", {"circle", "fig8", "sine", "saw", "square", "random"}, state.shape, function(v)
    state.shape = v
end)

local chipDir = makeChipSelector(secCustomTop, "Arah Gerakan (Dir):", {">", "<", "<>", "rand"}, state.dir, function(v)
    state.dir = v
end)

local chipWax = makeChipSelector(secCustomTop, "Sumbu Utama (wax):", {"x", "y"}, state.wax, function(v)
    state.wax = v
end)

local secCustomSliders = makeSection(pageCustom, "3. PARAMETER GERAKAN & SEBARAN (SKALA 0.0 - 1.0)")

local sldSlot = makeSliderRow(secCustomSliders, "Slot Effect (Layer eff 1-6)", 1, 6, state.slotIndex, true, function(v) state.slotIndex = v end)
local sldRate = makeSliderRow(secCustomSliders, "Kecepatan (rate)", 0.05, 5.0, state.rate, false, function(v) state.rate = v end)
local sldSx = makeSliderRow(secCustomSliders, "Ukuran Pan / X (sx)", 0.0, 1.0, state.sx, false, function(v) state.sx = v end)
local sldSy = makeSliderRow(secCustomSliders, "Ukuran Tilt / Y (sy)", 0.0, 1.0, state.sy, false, function(v) state.sy = v end)
local sldPhase = makeSliderRow(secCustomSliders, "Sebaran Fase (0 - 360 Deg)", 0, 360, state.phase, true, function(v) state.phase = v end)
local sldWing = makeSliderRow(secCustomSliders, "Wing / Cermin (wing)", 0, 8, state.wing, true, function(v) state.wing = v end)
local sldGroups = makeSliderRow(secCustomSliders, "Groups / Kelompok (groups)", 0, 8, state.groups, true, function(v) state.groups = v end)
local sldDty = makeSliderRow(secCustomSliders, "Duty Cycle (dty)", 0.0, 1.0, state.dty, false, function(v) state.dty = v end)
local sldSoft = makeSliderRow(secCustomSliders, "Softness / Halus (soft)", 0.0, 1.0, state.soft, false, function(v) state.soft = v end)

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
    sldChsRate.setValue(state.chaseRate)
end

local applyCustomBtn = Instance.new("TextButton")
applyCustomBtn.Size = UDim2.new(1, 0, 0, 28)
applyCustomBtn.Text = "TERAPKAN CUSTOM GERAKAN KE CUE AKTIF"
applyCustomBtn.Font = Enum.Font.GothamBlack
applyCustomBtn.TextSize = 10
applyCustomBtn.BorderSizePixel = 0
applyCustomBtn.ZIndex = 5
applyCustomBtn.Parent = secCustomSliders
registerTheme(applyCustomBtn, "accent", "BackgroundColor3")
registerTheme(applyCustomBtn, "btnText", "TextColor3")
applyBrutalBorder(applyCustomBtn)

applyCustomBtn.MouseButton1Click:Connect(function()
    applyEffectToCue(state.cueId, state.layerMode, state.slotIndex, state)
end)

local secSlotsMgr = makeSection(pageSlots, "1. INSPEKTOR 6 SLOT EFFECT DI CUE AKTIF (LAYER 'eff')")

local slotGridWrap = Instance.new("Frame")
slotGridWrap.Size = UDim2.new(1, 0, 0, 0)
slotGridWrap.AutomaticSize = Enum.AutomaticSize.Y
slotGridWrap.BackgroundTransparency = 1
slotGridWrap.ZIndex = 5
slotGridWrap.Parent = secSlotsMgr

local slotGrid = Instance.new("UIGridLayout")
slotGrid.CellSize = UDim2.new(0.49, 0, 0, 32)
slotGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
slotGrid.Parent = slotGridWrap

local slotActionRow = Instance.new("Frame")
slotActionRow.Size = UDim2.new(1, 0, 0, 24)
slotActionRow.BackgroundTransparency = 1
slotActionRow.ZIndex = 5
slotActionRow.Parent = secSlotsMgr

makeSmallActionBtn(slotActionRow, "Toggle ON/OFF Slot", 0, 135, "secondary", function()
    local c = workData.cues[state.cueId]
    if c and c.layer == "eff" and type(c.eff) == "table" and c.eff[state.slotIndex] then
        local ef = c.eff[state.slotIndex]
        ef.on = not ef.on
        ef.unused = not ef.on
        autoSaveTrigger()
        refreshSlotsAndCuesUI()
        setStatus("SLOT " .. state.slotIndex .. (ef.on and " ON" or " OFF"), false)
    else
        setStatus("CUE AKTIF BUKAN LAYER 'eff'", true)
    end
end)

makeSmallActionBtn(slotActionRow, "Kosongkan Slot Ini", 141, 130, "danger", function()
    local c = workData.cues[state.cueId]
    if c and c.layer == "eff" and type(c.eff) == "table" then
        c.eff[state.slotIndex] = makeEmptyEffSlot()
        autoSaveTrigger()
        refreshSlotsAndCuesUI()
        setStatus("SLOT " .. state.slotIndex .. " DIRESET", false)
    end
end)

local secCueGrid = makeSection(pageSlots, "2. GRID CUE 1 - 24 (KLIK CUE BARU = SETUP DMX)")

local cueQuickRow = Instance.new("Frame")
cueQuickRow.Size = UDim2.new(1, 0, 0, 24)
cueQuickRow.BackgroundTransparency = 1
cueQuickRow.ZIndex = 5
cueQuickRow.Parent = secCueGrid

makeSmallActionBtn(cueQuickRow, "Atur DMX Rig", 0, 95, "accent", function()
    openRigSetupModal(function()
        autoSaveTrigger()
        setStatus("DMX RIG DIPERBARUI", false)
    end)
end)

makeSmallActionBtn(cueQuickRow, "Duplikat Cue+1", 101, 105, "secondary", function()
    local src = workData.cues[state.cueId]
    if not src then
        setStatus("CUE " .. state.cueId .. " KOSONG!", true)
        return
    end
    local nextNum = (tonumber(state.cueId) or 1) + 1
    while workData.cues[tostring(nextNum)] ~= nil do
        nextNum = nextNum + 1
    end
    local nextKey = tostring(nextNum)
    workData.cues[nextKey] = deepCopy(src)
    state.cueId = nextKey
    autoSaveTrigger()
    refreshSlotsAndCuesUI()
    setStatus("DUPLIKAT -> CUE " .. nextKey, false)
end)

makeSmallActionBtn(cueQuickRow, "Hapus Cue", 212, 82, "danger", function()
    workData.cues[state.cueId] = nil
    autoSaveTrigger()
    refreshSlotsAndCuesUI()
    setStatus("CUE " .. state.cueId .. " DIHAPUS", false)
end)

local cueGridWrap = Instance.new("Frame")
cueGridWrap.Size = UDim2.new(1, 0, 0, 0)
cueGridWrap.AutomaticSize = Enum.AutomaticSize.Y
cueGridWrap.BackgroundTransparency = 1
cueGridWrap.ZIndex = 5
cueGridWrap.Parent = secCueGrid

local cueGridLayout = Instance.new("UIGridLayout")
cueGridLayout.CellSize = UDim2.new(0.24, 0, 0, 32)
cueGridLayout.CellPadding = UDim2.new(0.013, 0, 0, 4)
cueGridLayout.Parent = cueGridWrap

loadCueIntoEditor = function(cueKey)
    state.cueId = tostring(cueKey)
    local c = workData.cues[state.cueId]
    if not c then
        if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
        if uiPrefs.promptRigOnNewCue then
            openRigSetupModal(function()
                setStatus("CUE " .. state.cueId .. " SIAP DIISI (" .. #workData.rig .. " UNIT)", false)
            end)
        else
            setStatus("CUE " .. state.cueId .. " DIPILIH (KOSONG)", false)
        end
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
    end
    if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
    setStatus("CUE " .. state.cueId .. " (" .. string.upper(tostring(c.layer)) .. ") DIMUAT", false)
end

local applyFullTheme

local secSetTheme = makeSection(pageSettings, "1. PILIH TEMA GELAP & TRANSPARANSI / BLUR")

makeChipSelector(secSetTheme, "Palet Warna UI (Default Gelap):", {
    "Brutal Dark", "OLED Midnight", "Obsidian Neon", "Acid Lime"
}, uiPrefs.themeName, function(v)
    uiPrefs.themeName = v
    savePrefs()
    applyFullTheme()
    setStatus("TEMA: " .. v, false)
end)

makeSliderRow(secSetTheme, "Transparansi UI (0.00 - 0.75)", 0.0, 0.75, uiPrefs.bgTransparency, false, function(v)
    uiPrefs.bgTransparency = v
    savePrefs()
    applyFullTheme()
end)

local blurToggleBtn = Instance.new("TextButton")
blurToggleBtn.Size = UDim2.new(1, 0, 0, 26)
blurToggleBtn.Text = uiPrefs.enableBlur and "EFEK BLUR LAYAR BELAKANG: AKTIF (ON)" or "EFEK BLUR LAYAR BELAKANG: MATI (OFF)"
blurToggleBtn.Font = Enum.Font.GothamBlack
blurToggleBtn.TextSize = 9
blurToggleBtn.BorderSizePixel = 0
blurToggleBtn.ZIndex = 5
blurToggleBtn.Parent = secSetTheme
registerTheme(blurToggleBtn, uiPrefs.enableBlur and "accent" or "surface", "BackgroundColor3")
registerTheme(blurToggleBtn, uiPrefs.enableBlur and "btnText" or "ink", "TextColor3")
applyBrutalBorder(blurToggleBtn)

blurToggleBtn.MouseButton1Click:Connect(function()
    uiPrefs.enableBlur = not uiPrefs.enableBlur
    blurEffect.Size = uiPrefs.enableBlur and 8 or 0
    blurEffect.Enabled = uiPrefs.enableBlur and main.Visible
    blurToggleBtn.Text = uiPrefs.enableBlur and "EFEK BLUR LAYAR BELAKANG: AKTIF (ON)" or "EFEK BLUR LAYAR BELAKANG: MATI (OFF)"
    local th = getCurrentTheme()
    blurToggleBtn.BackgroundColor3 = uiPrefs.enableBlur and th.accent or th.surface
    blurToggleBtn.TextColor3 = uiPrefs.enableBlur and th.btnText or th.ink
    savePrefs()
end)

local secSetScale = makeSection(pageSettings, "2. UKURAN UI, BUBBLE & KETEBALAN GARIS")

makeSliderRow(secSetScale, "Skala Ukuran UI (0.75 - 1.30)", 0.75, 1.30, uiPrefs.uiScale, false, function(v)
    uiPrefs.uiScale = v
    uiScaleObj.Scale = v
    savePrefs()
end)

makeSliderRow(secSetScale, "Ketebalan Border (1 - 4 px)", 1, 4, uiPrefs.borderThickness, true, function(v)
    uiPrefs.borderThickness = v
    savePrefs()
    applyFullTheme()
end)

makeSliderRow(secSetScale, "Ukuran Bubble (36 - 66 px)", 36, 66, uiPrefs.bubbleSize, true, function(v)
    uiPrefs.bubbleSize = v
    bubbleBtn.Size = UDim2.new(0, v, 0, v)
    savePrefs()
end)

local secSetOpt = makeSection(pageSettings, "3. OPTIMASI PROMPT DMX, AUTO-SAVE & CLIPBOARD")

local promptRigBtn = Instance.new("TextButton")
promptRigBtn.Size = UDim2.new(1, 0, 0, 26)
promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA JUMLAH DMX SAAT BUAT CUE BARU: AKTIF" or "TANYA JUMLAH DMX SAAT BUAT CUE BARU: MATI"
promptRigBtn.Font = Enum.Font.GothamBlack
promptRigBtn.TextSize = 9
promptRigBtn.BorderSizePixel = 0
promptRigBtn.ZIndex = 5
promptRigBtn.Parent = secSetOpt
registerTheme(promptRigBtn, uiPrefs.promptRigOnNewCue and "accent" or "surface", "BackgroundColor3")
registerTheme(promptRigBtn, uiPrefs.promptRigOnNewCue and "btnText" or "ink", "TextColor3")
applyBrutalBorder(promptRigBtn)

promptRigBtn.MouseButton1Click:Connect(function()
    uiPrefs.promptRigOnNewCue = not uiPrefs.promptRigOnNewCue
    promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA JUMLAH DMX SAAT BUAT CUE BARU: AKTIF" or "TANYA JUMLAH DMX SAAT BUAT CUE BARU: MATI"
    local th = getCurrentTheme()
    promptRigBtn.BackgroundColor3 = uiPrefs.promptRigOnNewCue and th.accent or th.surface
    promptRigBtn.TextColor3 = uiPrefs.promptRigOnNewCue and th.btnText or th.ink
    savePrefs()
end)

local autoSaveBtn = Instance.new("TextButton")
autoSaveBtn.Size = UDim2.new(1, 0, 0, 26)
autoSaveBtn.Text = uiPrefs.autoSaveOnApply and "AUTO-SAVE KE WORK.JSON: AKTIF (ON)" or "AUTO-SAVE KE WORK.JSON: MATI (OFF)"
autoSaveBtn.Font = Enum.Font.GothamBlack
autoSaveBtn.TextSize = 9
autoSaveBtn.BorderSizePixel = 0
autoSaveBtn.ZIndex = 5
autoSaveBtn.Parent = secSetOpt
registerTheme(autoSaveBtn, uiPrefs.autoSaveOnApply and "secondary" or "surface", "BackgroundColor3")
registerTheme(autoSaveBtn, uiPrefs.autoSaveOnApply and "btnText" or "ink", "TextColor3")
applyBrutalBorder(autoSaveBtn)

autoSaveBtn.MouseButton1Click:Connect(function()
    uiPrefs.autoSaveOnApply = not uiPrefs.autoSaveOnApply
    autoSaveBtn.Text = uiPrefs.autoSaveOnApply and "AUTO-SAVE KE WORK.JSON: AKTIF (ON)" or "AUTO-SAVE KE WORK.JSON: MATI (OFF)"
    local th = getCurrentTheme()
    autoSaveBtn.BackgroundColor3 = uiPrefs.autoSaveOnApply and th.secondary or th.surface
    autoSaveBtn.TextColor3 = uiPrefs.autoSaveOnApply and th.btnText or th.ink
    savePrefs()
    setStatus("AUTO-SAVE: " .. (uiPrefs.autoSaveOnApply and "ON" or "OFF"), false)
end)

local setBtnRow = Instance.new("Frame")
setBtnRow.Size = UDim2.new(1, 0, 0, 24)
setBtnRow.BackgroundTransparency = 1
setBtnRow.ZIndex = 5
setBtnRow.Parent = secSetOpt

makeSmallActionBtn(setBtnRow, "Salin JSON Minify", 0, 125, "secondary", function()
    if setclipboard then
        workData = sanitizeWorkStructure(workData)
        local ok, enc = pcall(function() return HttpService:JSONEncode(workData) end)
        if ok then
            setclipboard(string.gsub(enc, "[\r\n]", ""))
            setStatus("JSON MINIFY DISALIN", false)
        end
    else
        setStatus("NO SETCLIPBOARD", true)
    end
end)

makeSmallActionBtn(setBtnRow, "Reset Posisi UI", 131, 115, "surface", function()
    main.Position = UDim2.new(0.5, 0, 0.52, 0)
    bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    setStatus("POSISI UI DIRESET", false)
end)

local cueLabelFooter = Instance.new("TextLabel")
cueLabelFooter.Size = UDim2.new(0, 44, 1, 0)
cueLabelFooter.Position = UDim2.new(0, 8, 0, 0)
cueLabelFooter.BackgroundTransparency = 1
cueLabelFooter.Text = "CUE:"
cueLabelFooter.Font = Enum.Font.GothamBlack
cueLabelFooter.TextSize = 10
cueLabelFooter.TextXAlignment = Enum.TextXAlignment.Left
cueLabelFooter.ZIndex = 4
cueLabelFooter.Parent = footerBar
registerTheme(cueLabelFooter, "ink", "TextColor3")

local cueIdBox = Instance.new("TextBox")
cueIdBox.Size = UDim2.new(0, 38, 0, 22)
cueIdBox.Position = UDim2.new(0, 44, 0.5, -11)
cueIdBox.Text = state.cueId
cueIdBox.Font = Enum.Font.Code
cueIdBox.TextSize = 11
cueIdBox.ClearTextOnFocus = false
cueIdBox.BorderSizePixel = 0
cueIdBox.ZIndex = 4
cueIdBox.Parent = footerBar
registerTheme(cueIdBox, "accent", "BackgroundColor3")
registerTheme(cueIdBox, "btnText", "TextColor3")
applyBrutalBorder(cueIdBox)

cueIdBox.FocusLost:Connect(function()
    local clean = string.gsub(cueIdBox.Text, "%s+", "")
    if #clean > 0 then
        state.cueId = clean
        if workData.cues[state.cueId] == nil and uiPrefs.promptRigOnNewCue then
            openRigSetupModal(function()
                setStatus("CUE " .. state.cueId .. " SIAP (" .. #workData.rig .. " UNIT)", false)
            end)
        end
    else
        cueIdBox.Text = state.cueId
    end
    if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
end)

refreshSlotsAndCuesUI = function()
    local th = getCurrentTheme()
    cueIdBox.Text = state.cueId

    for _, child in ipairs(slotGridWrap:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local activeCue = workData.cues[state.cueId]
    local effList = (activeCue and type(activeCue.eff) == "table") and activeCue.eff or workData.eff

    for sIdx = 1, 6 do
        local ef = effList[sIdx] or makeEmptyEffSlot()
        local isSelSlot = (sIdx == state.slotIndex)
        local statusTxt = ef.on and (string.upper(tostring(ef.target)) .. ":" .. string.upper(tostring(ef.shape))) or "MATI"
        local sb = Instance.new("TextButton")
        sb.BackgroundColor3 = isSelSlot and th.accent or (ef.on and th.secondary or th.surface)
        sb.Text = "SLOT " .. sIdx .. " [" .. statusTxt .. "]"
        sb.Font = Enum.Font.GothamBlack
        sb.TextSize = 9
        sb.TextColor3 = (isSelSlot or ef.on) and th.btnText or th.ink
        sb.TextTruncate = Enum.TextTruncate.AtEnd
        sb.BorderSizePixel = 0
        sb.ZIndex = 5
        sb.Parent = slotGridWrap
        applyBrutalBorder(sb)

        sb.MouseButton1Click:Connect(function()
            state.slotIndex = sIdx
            sldSlot.setValue(sIdx)
            if ef.on then
                state.target = ef.target or state.target
                state.shape = ef.shape or state.shape
                state.rate = tonumber(ef.rate) or state.rate
                state.sx = tonumber(ef.sx) or state.sx
                state.sy = tonumber(ef.sy) or state.sy
                state.phase = tonumber(ef.phase) or state.phase
                state.wing = tonumber(ef.wing) or state.wing
                state.groups = tonumber(ef.groups) or state.groups
                state.dir = ef.dir or state.dir
                state.wax = ef.wax or state.wax
                state.dty = tonumber(ef.dty) or state.dty
                state.soft = tonumber(ef.soft) or state.soft
                if customControls.syncFromState then
                    customControls.syncFromState()
                end
            end
            refreshSlotsAndCuesUI()
            setStatus("SLOT " .. sIdx .. " DIPILIH", false)
        end)
    end

    for _, child in ipairs(cueGridWrap:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for i = 1, 24 do
        local k = tostring(i)
        local c = workData.cues[k]
        local isSelCue = (k == state.cueId)
        local sub = "kosong"
        if c then
            if c.layer == "mov" and type(c.eff) == "table" and c.eff[1] then
                sub = string.upper(tostring(c.eff[1].shape or "MOV"))
            elseif c.layer == "eff" then
                sub = "EFF-SLOT"
            elseif c.layer == "chs" then
                sub = "CHASE"
            else
                sub = string.upper(tostring(c.layer))
            end
        end

        local cb = Instance.new("TextButton")
        cb.BackgroundColor3 = isSelCue and th.accent or (c and th.secondary or th.surface)
        cb.Text = "Cue " .. i .. "\n" .. sub
        cb.Font = Enum.Font.GothamBold
        cb.TextSize = 8
        cb.TextColor3 = (isSelCue or c) and th.btnText or th.ink
        cb.BorderSizePixel = 0
        cb.ZIndex = 5
        cb.Parent = cueGridWrap
        applyBrutalBorder(cb)

        cb.MouseButton1Click:Connect(function()
            loadCueIntoEditor(k)
        end)
    end
end

applyFullTheme = function()
    local th = getCurrentTheme()
    for _, item in ipairs(themeBindings) do
        if item.obj and item.obj.Parent then
            item.obj[item.prop] = th[item.role]
        end
    end
    main.BackgroundTransparency = uiPrefs.bgTransparency
    navBar.BackgroundTransparency = uiPrefs.bgTransparency
    contentArea.BackgroundTransparency = uiPrefs.bgTransparency
    footerBar.BackgroundTransparency = uiPrefs.bgTransparency
    topBar.BackgroundTransparency = math.clamp(uiPrefs.bgTransparency * 0.5, 0, 0.5)
    for _, sec in ipairs(sectionFrames) do
        if sec and sec.Parent then
            sec.BackgroundTransparency = uiPrefs.bgTransparency
        end
    end
    for _, desc in ipairs(screen:GetDescendants()) do
        if desc:IsA("UIStroke") then
            desc.Thickness = uiPrefs.borderThickness
            desc.Color = Color3.fromRGB(0, 0, 0)
        end
    end
    blurToggleBtn.BackgroundColor3 = uiPrefs.enableBlur and th.accent or th.surface
    blurToggleBtn.TextColor3 = uiPrefs.enableBlur and th.btnText or th.ink
    promptRigBtn.BackgroundColor3 = uiPrefs.promptRigOnNewCue and th.accent or th.surface
    promptRigBtn.TextColor3 = uiPrefs.promptRigOnNewCue and th.btnText or th.ink
    autoSaveBtn.BackgroundColor3 = uiPrefs.autoSaveOnApply and th.secondary or th.surface
    autoSaveBtn.TextColor3 = uiPrefs.autoSaveOnApply and th.btnText or th.ink
    previewToggleBtn.BackgroundColor3 = state.previewActive and th.accent or th.surface
    previewToggleBtn.TextColor3 = state.previewActive and th.btnText or th.ink
    refreshTabStyles()
    for _, cs in ipairs(chipSelectorsList) do
        cs.retheme()
    end
    if refreshMembersUI then refreshMembersUI() end
    if refreshSlotsAndCuesUI then refreshSlotsAndCuesUI() end
    rebuildPreviewDots()
end

local reloadBtn = Instance.new("TextButton")
reloadBtn.Size = UDim2.new(0, 82, 0, 22)
reloadBtn.Position = UDim2.new(1, -222, 0.5, -11)
reloadBtn.Text = "RELOAD"
reloadBtn.Font = Enum.Font.GothamBlack
reloadBtn.TextSize = 10
reloadBtn.BorderSizePixel = 0
reloadBtn.ZIndex = 4
reloadBtn.Parent = footerBar
registerTheme(reloadBtn, "secondary", "BackgroundColor3")
registerTheme(reloadBtn, "btnText", "TextColor3")
applyBrutalBorder(reloadBtn)

reloadBtn.MouseButton1Click:Connect(function()
    local ok, msg = loadWorkFile()
    resetSelectionAll()
    refreshMembersUI()
    refreshSlotsAndCuesUI()
    rebuildPreviewDots()
    setStatus(msg, not ok)
end)

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 130, 0, 22)
saveBtn.Position = UDim2.new(1, -134, 0.5, -11)
saveBtn.Text = "SIMPAN WORK.JSON"
saveBtn.Font = Enum.Font.GothamBlack
saveBtn.TextSize = 10
saveBtn.BorderSizePixel = 0
saveBtn.ZIndex = 4
saveBtn.Parent = footerBar
registerTheme(saveBtn, "accent", "BackgroundColor3")
registerTheme(saveBtn, "btnText", "TextColor3")
applyBrutalBorder(saveBtn)

saveBtn.MouseButton1Click:Connect(function()
    local ok, msg = saveWorkFile()
    setStatus(msg, not ok)
end)

refreshMembersUI()
refreshSlotsAndCuesUI()
rebuildPreviewDots()
applyFullTheme()
switchTab("presets")
