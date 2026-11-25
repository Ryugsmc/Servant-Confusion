local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local WORK_FILE = "dmx_ui_work.json"
local SHOWS_FILE = "dmx_ui_shows.json"
local PREFS_FILE = "apex_dmx_prefs.json"

local guiParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("ApexDMXStudio") then
    guiParent:FindFirstChild("ApexDMXStudio"):Destroy()
end

local THEMES = {
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
        canvas = Color3.fromRGB(22, 22, 22)
    },
    ["Cyber Yellow"] = {
        bg = Color3.fromRGB(238, 236, 230),
        surface = Color3.fromRGB(255, 255, 255),
        header = Color3.fromRGB(255, 214, 0),
        accent = Color3.fromRGB(0, 212, 255),
        secondary = Color3.fromRGB(255, 112, 166),
        danger = Color3.fromRGB(255, 65, 65),
        ink = Color3.fromRGB(12, 12, 12),
        subInk = Color3.fromRGB(55, 55, 55),
        chipBg = Color3.fromRGB(228, 226, 220),
        canvas = Color3.fromRGB(18, 18, 22)
    },
    ["Hyper Pink"] = {
        bg = Color3.fromRGB(246, 238, 242),
        surface = Color3.fromRGB(255, 255, 255),
        header = Color3.fromRGB(255, 107, 178),
        accent = Color3.fromRGB(125, 249, 255),
        secondary = Color3.fromRGB(255, 222, 89),
        danger = Color3.fromRGB(240, 50, 50),
        ink = Color3.fromRGB(15, 15, 15),
        subInk = Color3.fromRGB(60, 55, 60),
        chipBg = Color3.fromRGB(235, 225, 230),
        canvas = Color3.fromRGB(20, 18, 22)
    },
    ["Brutal Dark"] = {
        bg = Color3.fromRGB(24, 24, 27),
        surface = Color3.fromRGB(36, 36, 42),
        header = Color3.fromRGB(255, 102, 0),
        accent = Color3.fromRGB(0, 245, 155),
        secondary = Color3.fromRGB(255, 214, 0),
        danger = Color3.fromRGB(255, 68, 68),
        ink = Color3.fromRGB(245, 245, 245),
        subInk = Color3.fromRGB(185, 185, 195),
        chipBg = Color3.fromRGB(48, 48, 56),
        canvas = Color3.fromRGB(14, 14, 16)
    }
}

local uiPrefs = {
    themeName = "Acid Lime",
    uiScale = 1.0,
    borderThickness = 2,
    autoSaveOnApply = false,
    bubbleSize = 48,
    compactRows = false
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
                if tonumber(dec.bubbleSize) then uiPrefs.bubbleSize = math.clamp(math.floor(tonumber(dec.bubbleSize)), 38, 68) end
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
                return true, "LOADED: " .. WORK_FILE
            end
        end
    end
    return false, "DEFAULT MEMORY READY"
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
    return true, "SAVED MINIFY -> " .. WORK_FILE
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
        return false, "NO WRITEFILE SUPPORT"
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(showsData)
    end)
    if not ok then
        return false, "JSON ENCODE ERROR"
    end
    local minified = string.gsub(encoded, "[\r\n]", "")
    local okWrite, err = pcall(writefile, SHOWS_FILE, minified)
    if not okWrite then
        return false, tostring(err)
    end
    return true, "SAVED -> " .. SHOWS_FILE
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

local themeBindings = {}
local function registerTheme(obj, role, prop)
    table.insert(themeBindings, {obj = obj, role = role, prop = prop})
end

local function getCurrentTheme()
    return THEMES[uiPrefs.themeName] or THEMES["Acid Lime"]
end

local screen = Instance.new("ScreenGui")
screen.Name = "ApexDMXStudio"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = guiParent

local uiScaleObj = Instance.new("UIScale")
uiScaleObj.Scale = uiPrefs.uiScale
uiScaleObj.Parent = screen

local mainShadow = Instance.new("Frame")
mainShadow.Name = "MainShadow"
mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
mainShadow.Size = UDim2.new(0.84, 0, 0.80, 0)
mainShadow.Position = UDim2.new(0.5, 5, 0.52, 5)
mainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.BorderSizePixel = 0
mainShadow.ZIndex = 1
mainShadow.Parent = screen

local shadowConstraint = Instance.new("UISizeConstraint")
shadowConstraint.MinSize = Vector2.new(350, 235)
shadowConstraint.MaxSize = Vector2.new(530, 335)
shadowConstraint.Parent = mainShadow

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Size = UDim2.new(0.84, 0, 0.80, 0)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.BorderSizePixel = 0
main.ZIndex = 2
main.Parent = screen
registerTheme(main, "bg", "BackgroundColor3")

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(350, 235)
sizeConstraint.MaxSize = Vector2.new(530, 335)
sizeConstraint.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 0, 0)
mainStroke.Thickness = uiPrefs.borderThickness
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

local function applyBrutalBorder(guiObj, withHardShadow)
    local st = guiObj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    st.Color = Color3.fromRGB(0, 0, 0)
    st.Thickness = uiPrefs.borderThickness
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = guiObj
    if withHardShadow and guiObj.Parent then
        local sh = guiObj.Parent:FindFirstChild(guiObj.Name .. "_Shd")
        if not sh then
            sh = Instance.new("Frame")
            sh.Name = guiObj.Name .. "_Shd"
            sh.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            sh.BorderSizePixel = 0
            sh.ZIndex = math.max(1, guiObj.ZIndex - 1)
            sh.Parent = guiObj.Parent
        end
        sh.Size = guiObj.Size
        sh.Position = UDim2.new(guiObj.Position.X.Scale, guiObj.Position.X.Offset + 3, guiObj.Position.Y.Scale, guiObj.Position.Y.Offset + 3)
        sh.Visible = guiObj.Visible
    end
end

local bubbleShadow = Instance.new("Frame")
bubbleShadow.Size = UDim2.new(0, uiPrefs.bubbleSize, 0, uiPrefs.bubbleSize)
bubbleShadow.Position = UDim2.new(0.03, 4, 0.25, 4)
bubbleShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bubbleShadow.BorderSizePixel = 0
bubbleShadow.Visible = false
bubbleShadow.ZIndex = 19
bubbleShadow.Parent = screen

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
registerTheme(bubbleBtn, "ink", "TextColor3")
applyBrutalBorder(bubbleBtn, false)

do
    local bDragging, bDragInput, bDragStart, bStartPos, bMoved
    bubbleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bDragging = true
            bMoved = false
            bDragStart = input.Position
            bStartPos = bubbleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    bDragging = false
                    if not bMoved then
                        bubbleBtn.Visible = false
                        bubbleShadow.Visible = false
                        main.Visible = true
                        mainShadow.Visible = true
                    end
                end
            end)
        end
    end)
    bubbleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            bDragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == bDragInput and dragging then return end
        if input == bDragInput and bDragging then
            local delta = input.Position - bDragStart
            if delta.Magnitude > 6 then
                bMoved = true
            end
            local nx = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, bStartPos.Y.Scale, bStartPos.Y.Offset + delta.Y)
            bubbleBtn.Position = nx
            bubbleShadow.Position = UDim2.new(nx.X.Scale, nx.X.Offset + 4, nx.Y.Scale, nx.Y.Offset + 4)
        end
    end)
end

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = main
registerTheme(topBar, "header", "BackgroundColor3")
applyBrutalBorder(topBar, false)

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
registerTheme(titleLbl, "ink", "TextColor3")

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
registerTheme(statusLbl, "ink", "TextColor3")

local function setStatus(msg, isErr)
    statusLbl.Text = string.upper(tostring(msg))
    local th = getCurrentTheme()
    statusLbl.TextColor3 = isErr and Color3.fromRGB(220, 20, 20) or th.ink
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
applyBrutalBorder(minBtn, false)

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
applyBrutalBorder(closeBtn, false)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    mainShadow.Visible = false
    bubbleBtn.Visible = true
    bubbleShadow.Visible = true
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
            local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            main.Position = np
            mainShadow.Position = UDim2.new(np.X.Scale, np.X.Offset + 5, np.Y.Scale, np.Y.Offset + 5)
        end
    end)
end

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
navBar.BorderSizePixel = 0
navBar.ScrollBarThickness = 0
navBar.ScrollingDirection = Enum.ScrollingDirection.X
navBar.AutomaticCanvasSize = Enum.AutomaticSize.X
navBar.CanvasSize = UDim2.new(0, 0, 0, 0)
navBar.ZIndex = 3
navBar.Parent = body
registerTheme(navBar, "surface", "BackgroundColor3")
applyBrutalBorder(navBar, false)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 4)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Parent = navBar

local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 4)
navPad.PaddingRight = UDim.new(0, 4)
navPad.Parent = navBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -78)
contentArea.Position = UDim2.new(0, 8, 0, 38)
contentArea.BorderSizePixel = 0
contentArea.ZIndex = 3
contentArea.Parent = body
registerTheme(contentArea, "surface", "BackgroundColor3")
applyBrutalBorder(contentArea, false)

local footerBar = Instance.new("Frame")
footerBar.Size = UDim2.new(1, -16, 0, 32)
footerBar.Position = UDim2.new(0, 8, 1, -36)
footerBar.BorderSizePixel = 0
footerBar.ZIndex = 3
footerBar.Parent = body
registerTheme(footerBar, "surface", "BackgroundColor3")
applyBrutalBorder(footerBar, false)

local pages = {}
local tabButtons = {}
local activeTabKey = "templates"

local function refreshTabStyles()
    local th = getCurrentTheme()
    for k, btn in pairs(tabButtons) do
        local isAct = (k == activeTabKey)
        btn.BackgroundColor3 = isAct and th.accent or th.chipBg
        btn.TextColor3 = th.ink
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
    btn.Size = UDim2.new(0, width or 76, 0, 20)
    btn.Text = string.upper(label)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = navBar
    applyBrutalBorder(btn, false)

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

local function makeSection(parent, title)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -6, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BorderSizePixel = 0
    box.ZIndex = 4
    box.Parent = parent
    registerTheme(box, "bg", "BackgroundColor3")
    applyBrutalBorder(box, false)

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
    applyBrutalBorder(track, false)

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
    applyBrutalBorder(valBox, false)

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
            btn.TextColor3 = th.ink
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
        applyBrutalBorder(btn, false)
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
    else
        registerTheme(b, "ink", "TextColor3")
    end
    applyBrutalBorder(b, false)
    b.MouseButton1Click:Connect(callback)
    return b
end

local pageTemplates = createTab("templates", "Templates", 72)
local pageCustom = createTab("custom", "Custom FX", 72)
local pageStatic = createTab("static", "Static/RGB", 76)
local pageChase = createTab("chase", "Chase Seq", 72)
local pageRig = createTab("rig", "Rig & DMX", 72)
local pageShows = createTab("shows", "Cue/Shows", 76)
local pageSettings = createTab("settings", "Settings", 70)

local refreshMembersUI
local refreshCuesListUI
local refreshRigEditorUI
local refreshChaseStepsUI
local refreshShowsListUI
local rebuildDynamicFixtureSliders
local loadCueIntoEditor

local function autoSaveTrigger()
    if uiPrefs.autoSaveOnApply then
        saveWorkFile()
    end
end

local secMembers = makeSection(pageTemplates, "1. PILIH LAMPU TARGET (MEMBERS INDEKS RIG)")

local memberToolsRow = Instance.new("Frame")
memberToolsRow.Size = UDim2.new(1, 0, 0, 22)
memberToolsRow.BackgroundTransparency = 1
memberToolsRow.ZIndex = 5
memberToolsRow.Parent = secMembers

makeSmallActionBtn(memberToolsRow, "Semua", 0, 58, "accent", function()
    for i = 1, #workData.rig do selectedMembers[i] = true end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Ganjil", 62, 58, "surface", function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 1) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Genap", 124, 58, "surface", function()
    for i = 1, #workData.rig do selectedMembers[i] = (i % 2 == 0) end
    if refreshMembersUI then refreshMembersUI() end
end)

makeSmallActionBtn(memberToolsRow, "Reset", 186, 54, "danger", function()
    for i = 1, #workData.rig do selectedMembers[i] = false end
    selectedMembers[1] = true
    if refreshMembersUI then refreshMembersUI() end
end)

local memberGridHolder = Instance.new("Frame")
memberGridHolder.Size = UDim2.new(1, 0, 0, 0)
memberGridHolder.AutomaticSize = Enum.AutomaticSize.Y
memberGridHolder.BackgroundTransparency = 1
memberGridHolder.ZIndex = 5
memberGridHolder.Parent = secMembers

local memberGrid = Instance.new("UIGridLayout")
memberGrid.CellSize = UDim2.new(0, 72, 0, 24)
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
        b.TextColor3 = th.ink
        b.BorderSizePixel = 0
        b.ZIndex = 5
        b.Parent = memberGridHolder
        applyBrutalBorder(b, false)

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
tplGridWrap.ZIndex = 5
tplGridWrap.Parent = secTpl

local tplGrid = Instance.new("UIGridLayout")
tplGrid.CellSize = UDim2.new(0.49, 0, 0, 28)
tplGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
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
    autoSaveTrigger()
end

local customControls = {}

for _, tpl in ipairs(EFFECT_TEMPLATES) do
    local btn = Instance.new("TextButton")
    btn.Text = string.upper(tpl.name) .. " [" .. string.upper(tpl.shape) .. "]"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Parent = tplGridWrap
    registerTheme(btn, (tpl.layer == "mov") and "surface" or "secondary", "BackgroundColor3")
    registerTheme(btn, "ink", "TextColor3")
    applyBrutalBorder(btn, false)

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
        setStatus("TPL '" .. tpl.name .. "' -> CUE " .. state.cueId, false)
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
applyCustomBtn.Size = UDim2.new(1, 0, 0, 28)
applyCustomBtn.Text = "TERAPKAN CUSTOM EFFECT KE CUE AKTIF"
applyCustomBtn.Font = Enum.Font.GothamBlack
applyCustomBtn.TextSize = 10
applyCustomBtn.BorderSizePixel = 0
applyCustomBtn.ZIndex = 5
applyCustomBtn.Parent = secCustomSliders
registerTheme(applyCustomBtn, "accent", "BackgroundColor3")
registerTheme(applyCustomBtn, "ink", "TextColor3")
applyBrutalBorder(applyCustomBtn, false)

applyCustomBtn.MouseButton1Click:Connect(function()
    applyEffectToCue(state.cueId, state.layerMode, state.slotIndex, state)
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("CUSTOM (" .. state.shape .. ") -> CUE " .. state.cueId, false)
end)

local secRgbPalette = makeSection(pageStatic, "1. PALET WARNA RGB & COLOR WHEEL INSTAN (12 WARNA)")

local rgbGridWrap = Instance.new("Frame")
rgbGridWrap.Size = UDim2.new(1, 0, 0, 0)
rgbGridWrap.AutomaticSize = Enum.AutomaticSize.Y
rgbGridWrap.BackgroundTransparency = 1
rgbGridWrap.ZIndex = 5
rgbGridWrap.Parent = secRgbPalette

local rgbGrid = Instance.new("UIGridLayout")
rgbGrid.CellSize = UDim2.new(0.24, 0, 0, 24)
rgbGrid.CellPadding = UDim2.new(0.013, 0, 0, 4)
rgbGrid.Parent = rgbGridWrap

local activeSliderHandles = {}

for _, rgbItem in ipairs(RGB_COLOR_PRESETS) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = rgbItem.color
    b.Text = string.upper(rgbItem.name)
    b.Font = Enum.Font.GothamBlack
    b.TextSize = 9
    local lum = (rgbItem.color.R * 0.299) + (rgbItem.color.G * 0.587) + (rgbItem.color.B * 0.114)
    b.TextColor3 = (lum > 0.65) and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    b.ZIndex = 5
    b.Parent = rgbGridWrap
    applyBrutalBorder(b, false)

    b.MouseButton1Click:Connect(function()
        for k, val in pairs(rgbItem.vals) do
            if state.editorValues[k] ~= nil then
                state.editorValues[k] = val
                if activeSliderHandles[k] then
                    activeSliderHandles[k].setValue(val)
                end
            end
        end
        setStatus("WARNA '" .. rgbItem.name .. "' DITERAPKAN", false)
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
posePresetWrap.ZIndex = 5
posePresetWrap.Parent = secStaticTop

local poseGrid = Instance.new("UIGridLayout")
poseGrid.CellSize = UDim2.new(0.24, 0, 0, 24)
poseGrid.CellPadding = UDim2.new(0.013, 0, 0, 4)
poseGrid.Parent = posePresetWrap

local dynamicSlidersContainer = Instance.new("Frame")
dynamicSlidersContainer.Size = UDim2.new(1, 0, 0, 0)
dynamicSlidersContainer.AutomaticSize = Enum.AutomaticSize.Y
dynamicSlidersContainer.BackgroundTransparency = 1
dynamicSlidersContainer.ZIndex = 5
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
    b.Text = string.upper(preset.name)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    b.ZIndex = 5
    b.Parent = posePresetWrap
    registerTheme(b, "surface", "BackgroundColor3")
    registerTheme(b, "ink", "TextColor3")
    applyBrutalBorder(b, false)

    b.MouseButton1Click:Connect(function()
        for k, val in pairs(preset.vals) do
            if state.editorValues[k] ~= nil then
                state.editorValues[k] = val
                if activeSliderHandles[k] then
                    activeSliderHandles[k].setValue(val)
                end
            end
        end
        setStatus("POSE '" .. preset.name .. "' DIMUAT", false)
    end)
end

local staticBtnRow = Instance.new("Frame")
staticBtnRow.Size = UDim2.new(1, 0, 0, 26)
staticBtnRow.BackgroundTransparency = 1
staticBtnRow.ZIndex = 5
staticBtnRow.Parent = secStaticTop

makeSmallActionBtn(staticBtnRow, "Simpan Cue Statis", 0, 155, "accent", function()
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
    autoSaveTrigger()
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("STATIC [" .. state.staticLayerType .. "] -> CUE " .. state.cueId, false)
end)

makeSmallActionBtn(staticBtnRow, "Set Default Rig", 161, 145, "secondary", function()
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            fix.v = makeFullV(fix.t, state.editorValues)
        end
    end
    autoSaveTrigger()
    setStatus("DEFAULT RIG DIPERBARUI", false)
end)

local secChase = makeSection(pageChase, "1. CHASE SEQUENCER (REKAM STEP DARI TAB STATIC / RGB)")

makeSliderRow(secChase, "Chase Rate (Kecepatan)", 0.1, 10, state.chaseRate, false, function(v) state.chaseRate = v end)
makeSliderRow(secChase, "Chase Glide (0 Patah - 1 Halus)", 0, 1, state.chaseGlide, false, function(v) state.chaseGlide = v end)
makeChipSelector(secChase, "Chase Direction (dir):", {">", "<", "<>", "rand"}, state.chaseDir, function(v) state.chaseDir = v end)

local chaseStatusLbl = Instance.new("TextLabel")
chaseStatusLbl.Size = UDim2.new(1, 0, 0, 16)
chaseStatusLbl.BackgroundTransparency = 1
chaseStatusLbl.Text = "TOTAL STEP TEREKAM: 0 STEP"
chaseStatusLbl.Font = Enum.Font.Code
chaseStatusLbl.TextSize = 10
chaseStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
chaseStatusLbl.ZIndex = 5
chaseStatusLbl.Parent = secChase
registerTheme(chaseStatusLbl, "ink", "TextColor3")

refreshChaseStepsUI = function()
    chaseStatusLbl.Text = "TOTAL STEP TEREKAM: " .. tostring(#state.chaseSteps) .. " STEP"
end

local chaseBtnRow = Instance.new("Frame")
chaseBtnRow.Size = UDim2.new(1, 0, 0, 24)
chaseBtnRow.BackgroundTransparency = 1
chaseBtnRow.ZIndex = 5
chaseBtnRow.Parent = secChase

makeSmallActionBtn(chaseBtnRow, "+ Rekam Step", 0, 100, "secondary", function()
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
    setStatus("STEP #" .. #state.chaseSteps .. " DIREKAM", false)
end)

makeSmallActionBtn(chaseBtnRow, "Simpan ke Cue", 105, 105, "accent", function()
    if #state.chaseSteps == 0 then
        setStatus("REKAM MINIMAL 1 STEP!", true)
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
    autoSaveTrigger()
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("CHASE (" .. #state.chaseSteps .. " STEP) -> CUE " .. state.cueId, false)
end)

makeSmallActionBtn(chaseBtnRow, "Hapus Step", 215, 85, "danger", function()
    state.chaseSteps = {}
    refreshChaseStepsUI()
    setStatus("BUFFER CHASE KOSONG", false)
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
rigBtnRow.Size = UDim2.new(1, 0, 0, 24)
rigBtnRow.BackgroundTransparency = 1
rigBtnRow.ZIndex = 5
rigBtnRow.Parent = secRigGen

makeSmallActionBtn(rigBtnRow, "Generate Rig", 0, 100, "accent", function()
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
    autoSaveTrigger()
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("PATCH: " .. state.rigCount .. "X " .. t, false)
end)

makeSmallActionBtn(rigBtnRow, "+ 1 Unit", 105, 76, "secondary", function()
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
    autoSaveTrigger()
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("TAMBAH " .. t .. " DMX #" .. nextAddr, false)
end)

makeSmallActionBtn(rigBtnRow, "Re-Patch Semua", 186, 110, "surface", function()
    local addr = state.rigStartAddr
    for _, fix in ipairs(workData.rig) do
        fix.a = addr
        if state.rigMode == "independen" then
            local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
            addr = addr + fp
        end
    end
    autoSaveTrigger()
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("DMX DI-PATCH ULANG", false)
end)

local secRigManual = makeSection(pageRig, "2. EDITOR MANUAL ALAMAT DMX & POSISI PANGGUNG PER UNIT")

local rigEditorContainer = Instance.new("Frame")
rigEditorContainer.Size = UDim2.new(1, 0, 0, 0)
rigEditorContainer.AutomaticSize = Enum.AutomaticSize.Y
rigEditorContainer.BackgroundTransparency = 1
rigEditorContainer.ZIndex = 5
rigEditorContainer.Parent = secRigManual

local rigEdLayout = Instance.new("UIListLayout")
rigEdLayout.Padding = UDim.new(0, 4)
rigEdLayout.Parent = rigEditorContainer

refreshRigEditorUI = function()
    local th = getCurrentTheme()
    for _, child in ipairs(rigEditorContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    for i, fix in ipairs(workData.rig) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = th.surface
        row.BorderSizePixel = 0
        row.ZIndex = 5
        row.Parent = rigEditorContainer
        applyBrutalBorder(row, false)

        local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(0, 120, 1, 0)
        info.Position = UDim2.new(0, 6, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = string.format("#%02d %-7s (%dc)", i, string.upper(fix.t), fp)
        info.Font = Enum.Font.GothamBlack
        info.TextSize = 9
        info.TextColor3 = th.ink
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.ZIndex = 5
        info.Parent = row

        local addrLbl = Instance.new("TextLabel")
        addrLbl.Size = UDim2.new(0, 28, 1, 0)
        addrLbl.Position = UDim2.new(0, 126, 0, 0)
        addrLbl.BackgroundTransparency = 1
        addrLbl.Text = "DMX:"
        addrLbl.Font = Enum.Font.GothamBold
        addrLbl.TextSize = 9
        addrLbl.TextColor3 = th.subInk
        addrLbl.ZIndex = 5
        addrLbl.Parent = row

        local addrBox = Instance.new("TextBox")
        addrBox.Size = UDim2.new(0, 38, 0, 18)
        addrBox.Position = UDim2.new(0, 154, 0.5, -9)
        addrBox.BackgroundColor3 = th.accent
        addrBox.Text = tostring(fix.a)
        addrBox.Font = Enum.Font.Code
        addrBox.TextSize = 10
        addrBox.TextColor3 = th.ink
        addrBox.ClearTextOnFocus = false
        addrBox.BorderSizePixel = 0
        addrBox.ZIndex = 5
        addrBox.Parent = row
        applyBrutalBorder(addrBox, false)

        addrBox.FocusLost:Connect(function()
            local n = tonumber(addrBox.Text)
            if n and n >= 1 and n <= 512 then
                fix.a = math.floor(n)
                addrBox.Text = tostring(fix.a)
                autoSaveTrigger()
                if refreshMembersUI then refreshMembersUI() end
                setStatus("UNIT #" .. i .. " DMX -> " .. fix.a, false)
            else
                addrBox.Text = tostring(fix.a)
            end
        end)

        local xLbl = Instance.new("TextLabel")
        xLbl.Size = UDim2.new(0, 14, 1, 0)
        xLbl.Position = UDim2.new(0, 196, 0, 0)
        xLbl.BackgroundTransparency = 1
        xLbl.Text = "X:"
        xLbl.Font = Enum.Font.GothamBold
        xLbl.TextSize = 9
        xLbl.TextColor3 = th.subInk
        xLbl.ZIndex = 5
        xLbl.Parent = row

        local xBox = Instance.new("TextBox")
        xBox.Size = UDim2.new(0, 36, 0, 18)
        xBox.Position = UDim2.new(0, 210, 0.5, -9)
        xBox.BackgroundColor3 = th.chipBg
        xBox.Text = string.format("%.2f", fix.x or 0.5)
        xBox.Font = Enum.Font.Code
        xBox.TextSize = 10
        xBox.TextColor3 = th.ink
        xBox.ClearTextOnFocus = false
        xBox.BorderSizePixel = 0
        xBox.ZIndex = 5
        xBox.Parent = row
        applyBrutalBorder(xBox, false)

        xBox.FocusLost:Connect(function()
            local n = tonumber(xBox.Text)
            if n then
                fix.x = math.clamp(math.floor(n * 100 + 0.5) / 100, 0, 1)
                xBox.Text = string.format("%.2f", fix.x)
                autoSaveTrigger()
            else
                xBox.Text = string.format("%.2f", fix.x or 0.5)
            end
        end)

        local yLbl = Instance.new("TextLabel")
        yLbl.Size = UDim2.new(0, 14, 1, 0)
        yLbl.Position = UDim2.new(0, 250, 0, 0)
        yLbl.BackgroundTransparency = 1
        yLbl.Text = "Y:"
        yLbl.Font = Enum.Font.GothamBold
        yLbl.TextSize = 9
        yLbl.TextColor3 = th.subInk
        yLbl.ZIndex = 5
        yLbl.Parent = row

        local yBox = Instance.new("TextBox")
        yBox.Size = UDim2.new(0, 36, 0, 18)
        yBox.Position = UDim2.new(0, 264, 0.5, -9)
        yBox.BackgroundColor3 = th.chipBg
        yBox.Text = string.format("%.2f", fix.y or 0.5)
        yBox.Font = Enum.Font.Code
        yBox.TextSize = 10
        yBox.TextColor3 = th.ink
        yBox.ClearTextOnFocus = false
        yBox.BorderSizePixel = 0
        yBox.ZIndex = 5
        yBox.Parent = row
        applyBrutalBorder(yBox, false)

        yBox.FocusLost:Connect(function()
            local n = tonumber(yBox.Text)
            if n then
                fix.y = math.clamp(math.floor(n * 100 + 0.5) / 100, 0, 1)
                yBox.Text = string.format("%.2f", fix.y)
                autoSaveTrigger()
            else
                yBox.Text = string.format("%.2f", fix.y or 0.5)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 42, 0, 18)
        delBtn.Position = UDim2.new(1, -46, 0.5, -9)
        delBtn.BackgroundColor3 = th.danger
        delBtn.Text = "DEL"
        delBtn.Font = Enum.Font.GothamBlack
        delBtn.TextSize = 9
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.BorderSizePixel = 0
        delBtn.ZIndex = 5
        delBtn.Parent = row
        applyBrutalBorder(delBtn, false)

        delBtn.MouseButton1Click:Connect(function()
            if #workData.rig > 1 then
                table.remove(workData.rig, i)
                resetSelectionAll()
                autoSaveTrigger()
                refreshMembersUI()
                refreshRigEditorUI()
                setStatus("UNIT #" .. i .. " DIHAPUS", false)
            else
                setStatus("MINIMAL 1 UNIT DI RIG!", true)
            end
        end)
    end
end

local secCueMgr = makeSection(pageShows, "1. INTERACTIVE CUE MANAGER (KLIK CUE = PILIH & MUAT KE SLIDER)")

local cueQuickRow = Instance.new("Frame")
cueQuickRow.Size = UDim2.new(1, 0, 0, 24)
cueQuickRow.BackgroundTransparency = 1
cueQuickRow.ZIndex = 5
cueQuickRow.Parent = secCueMgr

makeSmallActionBtn(cueQuickRow, "+ Cue Baru", 0, 84, "accent", function()
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
    setStatus("CUE [" .. nextKey .. "] DIBUAT", false)
end)

makeSmallActionBtn(cueQuickRow, "Duplikat Cue", 89, 92, "secondary", function()
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
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("DUPLIKAT -> CUE [" .. nextKey .. "]", false)
end)

makeSmallActionBtn(cueQuickRow, "Hapus Cue", 186, 82, "danger", function()
    workData.cues[state.cueId] = nil
    autoSaveTrigger()
    if refreshCuesListUI then refreshCuesListUI() end
    setStatus("CUE " .. state.cueId .. " DIHAPUS", false)
end)

local cueListContainer = Instance.new("Frame")
cueListContainer.Size = UDim2.new(1, 0, 0, 0)
cueListContainer.AutomaticSize = Enum.AutomaticSize.Y
cueListContainer.BackgroundTransparency = 1
cueListContainer.ZIndex = 5
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
    setStatus("CUE [" .. state.cueId .. "] DIMUAT KE SLIDER", false)
end

local secShowsMgr = makeSection(pageShows, "2. SHOW LIBRARY MANAGER (dmx_ui_shows.json)")

local showInputRow = Instance.new("Frame")
showInputRow.Size = UDim2.new(1, 0, 0, 24)
showInputRow.BackgroundTransparency = 1
showInputRow.ZIndex = 5
showInputRow.Parent = secShowsMgr

local showNameBox = Instance.new("TextBox")
showNameBox.Size = UDim2.new(0, 136, 0, 22)
showNameBox.Position = UDim2.new(0, 0, 0, 0)
showNameBox.PlaceholderText = "Nama Show"
showNameBox.Text = ""
showNameBox.Font = Enum.Font.Code
showNameBox.TextSize = 10
showNameBox.ClearTextOnFocus = false
showNameBox.BorderSizePixel = 0
showNameBox.ZIndex = 5
showNameBox.Parent = showInputRow
registerTheme(showNameBox, "surface", "BackgroundColor3")
registerTheme(showNameBox, "ink", "TextColor3")
applyBrutalBorder(showNameBox, false)

makeSmallActionBtn(showInputRow, "Simpan", 141, 62, "accent", function()
    local name = string.gsub(showNameBox.Text, "^%s*(.-)%s*$", "%1")
    if #name == 0 then
        setStatus("ISI NAMA SHOW DULU!", true)
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
    setStatus(ok and ("SHOW '" .. name .. "' TERSIMPAN") or msg, not ok)
end)

makeSmallActionBtn(showInputRow, "Muat", 208, 56, "secondary", function()
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
        setStatus("SHOW '" .. name .. "' DIMUAT", false)
    else
        setStatus("SHOW TIDAK DITEMUKAN", true)
    end
end)

makeSmallActionBtn(showInputRow, "Hapus", 269, 56, "danger", function()
    local name = string.gsub(showNameBox.Text, "^%s*(.-)%s*$", "%1")
    loadShowsFile()
    if showsData[name] then
        showsData[name] = nil
        saveShowsFile()
        if refreshShowsListUI then refreshShowsListUI() end
        setStatus("SHOW '" .. name .. "' DIHAPUS", false)
    else
        setStatus("SHOW TIDAK DITEMUKAN", true)
    end
end)

local showsListLabel = Instance.new("TextLabel")
showsListLabel.Size = UDim2.new(1, 0, 0, 0)
showsListLabel.AutomaticSize = Enum.AutomaticSize.Y
showsListLabel.Font = Enum.Font.Code
showsListLabel.TextSize = 10
showsListLabel.TextXAlignment = Enum.TextXAlignment.Left
showsListLabel.TextYAlignment = Enum.TextYAlignment.Top
showsListLabel.TextWrapped = true
showsListLabel.BorderSizePixel = 0
showsListLabel.ZIndex = 5
showsListLabel.Parent = secShowsMgr
registerTheme(showsListLabel, "surface", "BackgroundColor3")
registerTheme(showsListLabel, "ink", "TextColor3")
applyBrutalBorder(showsListLabel, false)
local showsPad = Instance.new("UIPadding", showsListLabel)
showsPad.PaddingTop = UDim.new(0, 5)
showsPad.PaddingBottom = UDim.new(0, 5)
showsPad.PaddingLeft = UDim.new(0, 6)
showsPad.PaddingRight = UDim.new(0, 6)

refreshShowsListUI = function()
    local names = {}
    for k in pairs(showsData) do
        table.insert(names, tostring(k))
    end
    table.sort(names)
    if #names == 0 then
        showsListLabel.Text = "BELUM ADA SHOW TERSIMPAN DI DMX_UI_SHOWS.JSON."
        return
    end
    local lines = {}
    for _, n in ipairs(names) do
        local entry = showsData[n]
        local rigCount = (entry.data and entry.data.rig) and #entry.data.rig or 0
        table.insert(lines, string.format("> %-14s | RIG: %d UNIT", string.upper(n), rigCount))
    end
    showsListLabel.Text = table.concat(lines, "\n")
end

local secPreview = makeSection(pageShows, "3. LIVE VISUAL SIMULATOR (PREVIEW GERAKAN X/Y DI UI)")

local previewCanvas = Instance.new("Frame")
previewCanvas.Size = UDim2.new(1, 0, 0, 95)
previewCanvas.BorderSizePixel = 0
previewCanvas.ZIndex = 5
previewCanvas.Parent = secPreview
registerTheme(previewCanvas, "canvas", "BackgroundColor3")
applyBrutalBorder(previewCanvas, false)

local previewDots = {}
local function rebuildPreviewDots()
    local th = getCurrentTheme()
    for _, d in ipairs(previewDots) do
        d:Destroy()
    end
    previewDots = {}
    for i = 1, #workData.rig do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3 = th.accent
        dot.BorderSizePixel = 0
        dot.ZIndex = 6
        dot.Parent = previewCanvas
        applyBrutalBorder(dot, false)

        local num = Instance.new("TextLabel")
        num.Size = UDim2.new(1, 0, 1, 0)
        num.BackgroundTransparency = 1
        num.Text = tostring(i)
        num.Font = Enum.Font.GothamBlack
        num.TextSize = 8
        num.TextColor3 = Color3.fromRGB(10, 10, 10)
        num.ZIndex = 7
        num.Parent = dot

        previewDots[i] = dot
    end
end

local previewToggleBtn = Instance.new("TextButton")
previewToggleBtn.Size = UDim2.new(0, 165, 0, 24)
previewToggleBtn.Text = "MULAI LIVE PREVIEW"
previewToggleBtn.Font = Enum.Font.GothamBlack
previewToggleBtn.TextSize = 9
previewToggleBtn.BorderSizePixel = 0
previewToggleBtn.ZIndex = 5
previewToggleBtn.Parent = secPreview
registerTheme(previewToggleBtn, "secondary", "BackgroundColor3")
registerTheme(previewToggleBtn, "ink", "TextColor3")
applyBrutalBorder(previewToggleBtn, false)

previewToggleBtn.MouseButton1Click:Connect(function()
    state.previewActive = not state.previewActive
    previewToggleBtn.Text = state.previewActive and "HENTIKAN PREVIEW" or "MULAI LIVE PREVIEW"
    rebuildPreviewDots()
end)

RunService.RenderStepped:Connect(function()
    if not state.previewActive or not pageShows.Visible or not main.Visible then return end
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

local applyFullTheme

local secSetTheme = makeSection(pageSettings, "1. TEMA NEO-BRUTALIST (WARNA KONTRAS & GARIS TEGAS)")

makeChipSelector(secSetTheme, "Pilih Palet Tema UI:", {"Acid Lime", "Cyber Yellow", "Hyper Pink", "Brutal Dark"}, uiPrefs.themeName, function(v)
    uiPrefs.themeName = v
    savePrefs()
    applyFullTheme()
    setStatus("TEMA: " .. v, false)
end)

local secSetScale = makeSection(pageSettings, "2. UKURAN UI, BUBBLE & KETEBALAN GARIS")

local sldUiScale = makeSliderRow(secSetScale, "Skala Ukuran UI (0.75 - 1.30)", 0.75, 1.30, uiPrefs.uiScale, false, function(v)
    uiPrefs.uiScale = v
    uiScaleObj.Scale = v
    savePrefs()
end)

local sldBorder = makeSliderRow(secSetScale, "Ketebalan Border (1 - 4 px)", 1, 4, uiPrefs.borderThickness, true, function(v)
    uiPrefs.borderThickness = v
    savePrefs()
    applyFullTheme()
end)

local sldBubble = makeSliderRow(secSetScale, "Ukuran Bubble (38 - 68 px)", 38, 68, uiPrefs.bubbleSize, true, function(v)
    uiPrefs.bubbleSize = v
    bubbleBtn.Size = UDim2.new(0, v, 0, v)
    bubbleShadow.Size = UDim2.new(0, v, 0, v)
    savePrefs()
end)

local secSetOpt = makeSection(pageSettings, "3. OPTIMASI ALUR KERJA & BACKUP JSON")

local autoSaveBtn = Instance.new("TextButton")
autoSaveBtn.Size = UDim2.new(1, 0, 0, 26)
autoSaveBtn.Text = uiPrefs.autoSaveOnApply and "AUTO-SAVE KE WORK.JSON: AKTIF (ON)" or "AUTO-SAVE KE WORK.JSON: MATI (OFF)"
autoSaveBtn.Font = Enum.Font.GothamBlack
autoSaveBtn.TextSize = 10
autoSaveBtn.BorderSizePixel = 0
autoSaveBtn.ZIndex = 5
autoSaveBtn.Parent = secSetOpt
registerTheme(autoSaveBtn, uiPrefs.autoSaveOnApply and "accent" or "surface", "BackgroundColor3")
registerTheme(autoSaveBtn, "ink", "TextColor3")
applyBrutalBorder(autoSaveBtn, false)

autoSaveBtn.MouseButton1Click:Connect(function()
    uiPrefs.autoSaveOnApply = not uiPrefs.autoSaveOnApply
    autoSaveBtn.Text = uiPrefs.autoSaveOnApply and "AUTO-SAVE KE WORK.JSON: AKTIF (ON)" or "AUTO-SAVE KE WORK.JSON: MATI (OFF)"
    local th = getCurrentTheme()
    autoSaveBtn.BackgroundColor3 = uiPrefs.autoSaveOnApply and th.accent or th.surface
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
            setStatus("JSON MINIFY DISALIN KE CLIPBOARD", false)
        end
    else
        setStatus("EXECUTOR TANPA SETCLIPBOARD", true)
    end
end)

makeSmallActionBtn(setBtnRow, "Reset Posisi UI", 130, 110, "surface", function()
    main.Position = UDim2.new(0.5, 0, 0.52, 0)
    mainShadow.Position = UDim2.new(0.5, 5, 0.52, 5)
    bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    bubbleShadow.Position = UDim2.new(0.03, 4, 0.25, 4)
    setStatus("POSISI UI DIRESET KE TENGAH", false)
end)

makeSmallActionBtn(setBtnRow, "Reset Workspace", 245, 115, "danger", function()
    workData = defaultWorkData()
    resetSelectionAll()
    sldFade.setValue(workData.fade)
    sldGm.setValue(workData.gm)
    refreshMembersUI()
    refreshRigEditorUI()
    refreshCuesListUI()
    setStatus("WORKSPACE DIRESET KE DEFAULT", false)
end)

applyFullTheme = function()
    local th = getCurrentTheme()
    for _, item in ipairs(themeBindings) do
        if item.obj and item.obj.Parent then
            item.obj[item.prop] = th[item.role]
        end
    end
    for _, desc in ipairs(screen:GetDescendants()) do
        if desc:IsA("UIStroke") then
            desc.Thickness = uiPrefs.borderThickness
            desc.Color = Color3.fromRGB(0, 0, 0)
        end
    end
    autoSaveBtn.BackgroundColor3 = uiPrefs.autoSaveOnApply and th.accent or th.surface
    refreshTabStyles()
    for _, cs in ipairs(chipSelectorsList) do
        cs.retheme()
    end
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    if refreshCuesListUI then refreshCuesListUI() end
end

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
registerTheme(cueIdBox, "ink", "TextColor3")
applyBrutalBorder(cueIdBox, false)

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
    local th = getCurrentTheme()
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
        emptyLbl.Size = UDim2.new(1, 0, 0, 22)
        emptyLbl.BackgroundTransparency = 1
        emptyLbl.Text = "BELUM ADA CUE TERSIMPAN DI DMX_UI_WORK.JSON."
        emptyLbl.Font = Enum.Font.Code
        emptyLbl.TextSize = 10
        emptyLbl.TextColor3 = th.subInk
        emptyLbl.TextXAlignment = Enum.TextXAlignment.Left
        emptyLbl.ZIndex = 5
        emptyLbl.Parent = cueListContainer
        return
    end

    for _, k in ipairs(keys) do
        local c = workData.cues[k]
        local isSelected = (k == state.cueId)
        local detail = ""
        if c.layer == "chs" and c.chase and c.chase.steps then
            detail = "CHASE (" .. #c.chase.steps .. " STEPS)"
        elseif c.layer == "dim" or c.layer == "pos" or c.layer == "beam" then
            detail = "STATIC (" .. string.upper(tostring(c.layer)) .. ")"
        elseif type(c.eff) == "table" then
            local activeNames = {}
            for sIdx, ef in ipairs(c.eff) do
                if ef.on then
                    table.insert(activeNames, "S" .. sIdx .. ":" .. string.upper(tostring(ef.target)) .. "/" .. string.upper(tostring(ef.shape)))
                end
            end
            detail = (#activeNames > 0) and table.concat(activeNames, ", ") or "OFF"
        end

        local rowBtn = Instance.new("TextButton")
        rowBtn.Size = UDim2.new(1, 0, 0, 24)
        rowBtn.BackgroundColor3 = isSelected and th.accent or th.surface
        rowBtn.Text = string.format(" %s CUE [%s] | %-4s | %s", isSelected and ">" or "-", k, string.upper(tostring(c.layer)), detail)
        rowBtn.Font = Enum.Font.GothamBold
        rowBtn.TextSize = 10
        rowBtn.TextColor3 = th.ink
        rowBtn.TextXAlignment = Enum.TextXAlignment.Left
        rowBtn.TextTruncate = Enum.TextTruncate.AtEnd
        rowBtn.BorderSizePixel = 0
        rowBtn.ZIndex = 5
        rowBtn.Parent = cueListContainer
        applyBrutalBorder(rowBtn, false)

        rowBtn.MouseButton1Click:Connect(function()
            loadCueIntoEditor(k)
        end)
    end
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
registerTheme(reloadBtn, "ink", "TextColor3")
applyBrutalBorder(reloadBtn, false)

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
saveBtn.Size = UDim2.new(0, 130, 0, 22)
saveBtn.Position = UDim2.new(1, -134, 0.5, -11)
saveBtn.Text = "SIMPAN WORK.JSON"
saveBtn.Font = Enum.Font.GothamBlack
saveBtn.TextSize = 10
saveBtn.BorderSizePixel = 0
saveBtn.ZIndex = 4
saveBtn.Parent = footerBar
registerTheme(saveBtn, "accent", "BackgroundColor3")
registerTheme(saveBtn, "ink", "TextColor3")
applyBrutalBorder(saveBtn, false)

saveBtn.MouseButton1Click:Connect(function()
    local ok, msg = saveWorkFile()
    setStatus(msg, not ok)
end)

rebuildDynamicFixtureSliders()
refreshMembersUI()
refreshRigEditorUI()
refreshCuesListUI()
refreshShowsListUI()
applyFullTheme()
switchTab("templates")
