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
    winWidth = 520,
    winHeight = 330,
    borderThickness = 2,
    autoSaveOnSaveCue = true,
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
                if tonumber(dec.uiScale) then uiPrefs.uiScale = math.clamp(tonumber(dec.uiScale), 0.20, 1.30) end
                if tonumber(dec.winWidth) then uiPrefs.winWidth = math.clamp(math.floor(tonumber(dec.winWidth)), 320, 900) end
                if tonumber(dec.winHeight) then uiPrefs.winHeight = math.clamp(math.floor(tonumber(dec.winHeight)), 220, 650) end
                if tonumber(dec.borderThickness) then uiPrefs.borderThickness = math.clamp(math.floor(tonumber(dec.borderThickness)), 1, 4) end
                if type(dec.autoSaveOnSaveCue) == "boolean" then uiPrefs.autoSaveOnSaveCue = dec.autoSaveOnSaveCue end
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

local STEP_PRESETS = {
    {name="Circle Putar", pattern="circle", glide=0.45, rate=2.2},
    {name="Circle Cermin", pattern="circle_mirror", glide=0.45, rate=2.2},
    {name="Figure-8 Angka 8", pattern="fig8", glide=0.45, rate=2.0},
    {name="Sapu Kiri-Kanan", pattern="wave_pan", glide=0.40, rate=2.5},
    {name="Kipas Cermin", pattern="fan_io", glide=0.40, rate=2.4},
    {name="Ombak Naik-Turun", pattern="wave_tilt", glide=0.40, rate=2.5},
    {name="Tangga Tilt Naik", pattern="stair_tilt", glide=0.30, rate=2.8},
    {name="Silang Ping-Pong", pattern="pingpong", glide=0.25, rate=3.0},
    {name="Ballyhoo Acak", pattern="ballyhoo", glide=0.35, rate=2.6},
    {name="Kedip Ganjil-Genap", pattern="odd_even", glide=0.0, rate=4.0},
    {name="Lampu Lari (Runner)", pattern="runner", glide=0.10, rate=4.5},
    {name="Pelangi Berjalan", pattern="color_run", glide=0.20, rate=3.0}
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
    {name="Prism 9-Dot", color=Color3.fromRGB(90, 185, 215), vals={prism=0.6, gobo=0.35, color=0.35, focus=0.4}},
    {name="Grid 9-Box", color=Color3.fromRGB(215, 75, 95), vals={gobo=0.91, color=0.62, prism=0, focus=0.5}}
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
        local posX = (qty == 1) and 0.5 or (0.10 + ((i - 1) * (0.80 / math.max(1, qty - 1))))
        table.insert(newRig, {
            a = addr,
            x = math.floor(posX * 100 + 0.5) / 100,
            y = 0.25,
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

local state = {
    cueId = "1",
    presetStepsCount = 8,
    stepRate = 2.5,
    stepGlide = 0.35,
    stepDir = ">",
    customSteps = {},
    curPan = 0.5,
    curTilt = 0.5,
    curDim = 1.0,
    curColor = 0.0,
    curStrobe = 0.0,
    curMirror = false,
    previewActive = true,
    previewView = "top",
    layoutEditMode = false,
    activeLayoutNode = 1,
    editorFixtureType = "clara",
    staticLayerType = "pos",
    editorValues = deepCopy(FIXTURE_DEFAULTS.clara),
    rigType = (#workData.rig > 0 and workData.rig[1].t) or "clara",
    rigCount = math.max(1, #workData.rig),
    rigStartAddr = (#workData.rig > 0 and workData.rig[1].a) or 1,
    rigMode = "independen",
    rigConfigured = false,
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
main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.BackgroundTransparency = uiPrefs.bgTransparency
main.BorderSizePixel = 0
main.ZIndex = 2
main.Parent = screen
registerTheme(main, "bg", "BackgroundColor3")

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
bubbleBtn.Text = "APEX"
bubbleBtn.Font = Enum.Font.GothamBlack
bubbleBtn.TextSize = 11
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
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundTransparency = math.clamp(uiPrefs.bgTransparency * 0.5, 0, 0.5)
topBar.BorderSizePixel = 0
topBar.ZIndex = 3
topBar.Parent = main
registerTheme(topBar, "header", "BackgroundColor3")
applyBrutalBorder(topBar)

makeDraggableFrame(topBar, main, nil)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 165, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "APEX STEP // RK-512"
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 12
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 4
titleLbl.Parent = topBar
registerTheme(titleLbl, "btnText", "TextColor3")

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -245, 1, 0)
statusLbl.Position = UDim2.new(0, 175, 0, 0)
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
minBtn.Size = UDim2.new(0, 24, 0, 20)
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
closeBtn.Size = UDim2.new(0, 24, 0, 20)
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
body.Size = UDim2.new(1, 0, 1, -30)
body.Position = UDim2.new(0, 0, 0, 30)
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
navLayout.Padding = UDim.new(0, 4)
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Parent = navBar

local navPad = Instance.new("UIPadding")
navPad.PaddingLeft = UDim.new(0, 4)
navPad.PaddingRight = UDim.new(0, 4)
navPad.Parent = navBar

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -76)
contentArea.Position = UDim2.new(0, 8, 0, 38)
contentArea.BackgroundTransparency = uiPrefs.bgTransparency
contentArea.BorderSizePixel = 0
contentArea.ZIndex = 3
contentArea.Parent = body
registerTheme(contentArea, "surface", "BackgroundColor3")
applyBrutalBorder(contentArea)

local footerBar = Instance.new("Frame")
footerBar.Size = UDim2.new(1, -16, 0, 30)
footerBar.Position = UDim2.new(0, 8, 1, -34)
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
    btn.Size = UDim2.new(0, width or 80, 0, 20)
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
    hdr.Size = UDim2.new(1, 0, 0, 15)
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
    row.Size = UDim2.new(1, 0, 0, 23)
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
    track.Size = UDim2.new(1, -190, 0, 11)
    track.Position = UDim2.new(0, 136, 0.5, -5)
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
    valBox.Size = UDim2.new(0, 48, 0, 19)
    valBox.Position = UDim2.new(1, -48, 0.5, -9)
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
    grid.CellSize = UDim2.new(0, 74, 0, 21)
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
    b.Size = UDim2.new(0, width, 0, 21)
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

local pagePresets = createTab("presets", "Preset Step", 78)
local pageCustom = createTab("custom", "Custom Step", 80)
local pagePreview = createTab("preview", "Live Preview", 84)
local pageStatic = createTab("static", "Static / RGB", 80)
local pageRig = createTab("rig", "Rig & DMX", 72)
local pageCues = createTab("cues", "Simpan Cue", 78)
local pageSettings = createTab("settings", "Settings", 68)

local refreshMembersUI
local refreshCustomStepsListUI
local refreshCueGridUI
local refreshRigEditorUI
local rebuildDynamicFixtureSliders
local rebuildPreviewDots
local openRigSetupModal

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
rigModalTitle.Text = "SETUP JUMLAH & ALAMAT DMX LAMPU"
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

local modalChipFix = makeChipSelector(rigModalScroll, "1. Pilih Tipe Lampu (Clara / Lainnya):", {
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
    if refreshRigEditorUI then refreshRigEditorUI() end
    if rebuildPreviewDots then rebuildPreviewDots() end
    local cb = pendingAfterRigCallback
    pendingAfterRigCallback = nil
    if cb then
        cb()
    else
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

local function saveCurrentStepsToCue(cueKey)
    if #state.customSteps == 0 then
        setStatus("BELUM ADA STEP! PILIH PRESET ATAU REKAM STEP DULU", true)
        return
    end
    executeWithRigCheck(cueKey, function()
        workData.cues[cueKey] = {
            layer = "chs",
            fx = {},
            eff = {},
            chase = {
                glide = state.stepGlide,
                dir = state.stepDir,
                seq = false,
                off = 0,
                rate = state.stepRate,
                steps = deepCopy(state.customSteps)
            }
        }
        if uiPrefs.autoSaveOnSaveCue then
            saveWorkFile()
        end
        if refreshCueGridUI then refreshCueGridUI() end
        setStatus("TERSIMPAN KE CUE " .. cueKey .. " (" .. #state.customSteps .. " STEP)", false)
    end)
end

local sldPresetRate, sldPresetGlide, chipPresetDir
local refreshPreviewToolbar

local function buildStepsFromPreset(preset)
    local indices = getSelectedMemberIndices()
    local totalSel = math.max(1, #indices)
    local numSteps = state.presetStepsCount or 8
    local newSteps = {}

    state.layoutEditMode = false
    if refreshPreviewToolbar then refreshPreviewToolbar() end

    state.stepRate = preset.rate or 2.5
    state.stepGlide = preset.glide or 0.35
    if sldPresetRate then sldPresetRate.setValue(state.stepRate) end
    if sldPresetGlide then sldPresetGlide.setValue(state.stepGlide) end

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

                if preset.pattern == "circle" then
                    ov.pan = 0.5 + (math.cos(ang) * 0.35)
                    ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                elseif preset.pattern == "circle_mirror" then
                    local sign = (posIdx > (totalSel / 2)) and -1 or 1
                    ov.pan = 0.5 + (math.cos(ang) * 0.35 * sign)
                    ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                elseif preset.pattern == "fig8" then
                    ov.pan = 0.5 + (math.sin(ang) * 0.40)
                    ov.tilt = 0.5 + (math.sin(ang * 2) * 0.30)
                elseif preset.pattern == "wave_pan" then
                    ov.pan = 0.5 + (math.sin(ang) * 0.42)
                    ov.tilt = 0.5
                elseif preset.pattern == "fan_io" then
                    local mid = (totalSel + 1) / 2
                    local dist = (posIdx - mid) / math.max(1, totalSel / 2)
                    local wave = math.sin(prog * math.pi * 2)
                    ov.pan = 0.5 + (dist * 0.40 * wave)
                    ov.tilt = 0.5 + (0.25 * math.cos(prog * math.pi * 2))
                elseif preset.pattern == "wave_tilt" then
                    ov.pan = 0.5
                    ov.tilt = 0.5 + (math.sin(ang) * 0.40)
                elseif preset.pattern == "stair_tilt" then
                    ov.pan = 0.5
                    ov.tilt = 0.18 + (((prog + phaseOff) % 1) * 0.68)
                elseif preset.pattern == "pingpong" then
                    local dir = (s % 2 == 1) and 1 or -1
                    local side = (posIdx % 2 == 1) and 1 or -1
                    ov.pan = 0.5 + (0.36 * dir * side)
                    ov.tilt = 0.5 + (0.26 * dir)
                elseif preset.pattern == "ballyhoo" then
                    ov.pan = 0.5 + (math.sin(ang * 1.5 + rigIdx) * 0.40)
                    ov.tilt = 0.5 + (math.cos(ang * 2.1 - rigIdx) * 0.38)
                elseif preset.pattern == "odd_even" then
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
                elseif preset.pattern == "runner" then
                    local activePos = ((s - 1) % totalSel) + 1
                    local val = (posIdx == activePos) and 1 or 0
                    ov.dim = val
                    ov.int = val
                    ov.r = val
                    ov.g = val
                    ov.b = val
                    ov.d1 = val
                    ov.d2 = val
                    ov.d3 = val
                    ov.d4 = val
                elseif preset.pattern == "color_run" then
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
        table.insert(newSteps, frame)
    end

    state.customSteps = newSteps
    if refreshCustomStepsListUI then refreshCustomStepsListUI() end
    setStatus("JADI " .. #newSteps .. " STEP (" .. string.upper(preset.name) .. ") -> CEK PREVIEW / SIMPAN", false)
end

local secMembers = makeSection(pagePresets, "1. PILIH LAMPU TARGET & TAP TEMPO BPM")

local memberToolsRow = Instance.new("Frame")
memberToolsRow.Size = UDim2.new(1, 0, 0, 21)
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
        setStatus("DMX RIG: " .. #workData.rig .. " UNIT", false)
    end)
end)

local tapTimes = {}
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
        local chsRate = math.clamp(math.floor((bpm / 60) * 100 + 0.5) / 100, 0.2, 10.0)
        state.bpm = bpm
        state.stepRate = chsRate
        if sldPresetRate then sldPresetRate.setValue(chsRate) end
        setStatus("SYNC " .. bpm .. " BPM | STEP RATE: " .. string.format("%.2f", chsRate), false)
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
memberGrid.CellSize = UDim2.new(0, 74, 0, 22)
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

local secPresetOpt = makeSection(pagePresets, "2. ATUR JUMLAH STEP, KECEPATAN & KEHALUSAN")

makeChipSelector(secPresetOpt, "Jumlah Step Otomatis (steps):", {4, 8, 12, 16}, state.presetStepsCount, function(v)
    state.presetStepsCount = v
end)

sldPresetRate = makeSliderRow(secPresetOpt, "Kecepatan Step (rate)", 0.2, 10.0, state.stepRate, false, function(v)
    state.stepRate = v
end)

sldPresetGlide = makeSliderRow(secPresetOpt, "Kehalusan Gerak (glide)", 0.0, 1.0, state.stepGlide, false, function(v)
    state.stepGlide = v
end)

chipPresetDir = makeChipSelector(secPresetOpt, "Arah Jalan Step (dir):", {">", "<", "<>", "rand"}, state.stepDir, function(v)
    state.stepDir = v
end)

local secPresetGrid = makeSection(pagePresets, "3. KLIK PRESET = OTOMATIS JADI STEP (12 POLA)")

local presetGridWrap = Instance.new("Frame")
presetGridWrap.Size = UDim2.new(1, 0, 0, 0)
presetGridWrap.AutomaticSize = Enum.AutomaticSize.Y
presetGridWrap.BackgroundTransparency = 1
presetGridWrap.ZIndex = 5
presetGridWrap.Parent = secPresetGrid

local presetGrid = Instance.new("UIGridLayout")
presetGrid.CellSize = UDim2.new(0.49, 0, 0, 26)
presetGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)
presetGrid.Parent = presetGridWrap

for _, tpl in ipairs(STEP_PRESETS) do
    local btn = Instance.new("TextButton")
    btn.Text = string.upper(tpl.name)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 9
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.ZIndex = 5
    btn.Parent = presetGridWrap
    registerTheme(btn, "surface", "BackgroundColor3")
    registerTheme(btn, "ink", "TextColor3")
    applyBrutalBorder(btn)

    btn.MouseButton1Click:Connect(function()
        buildStepsFromPreset(tpl)
    end)
end

local secCustomPad = makeSection(pageCustom, "1. ATUR POSISI LAMPU (GESER KOTAK XY & REKAM STEP)")

local xyPad = Instance.new("TextButton")
xyPad.Size = UDim2.new(1, 0, 0, 88)
xyPad.Text = ""
xyPad.AutoButtonColor = false
xyPad.BorderSizePixel = 0
xyPad.ZIndex = 5
xyPad.Parent = secCustomPad
registerTheme(xyPad, "canvas", "BackgroundColor3")
applyBrutalBorder(xyPad)

local padCrossH = Instance.new("Frame")
padCrossH.Size = UDim2.new(1, 0, 0, 1)
padCrossH.Position = UDim2.new(0, 0, 0.5, 0)
padCrossH.BackgroundColor3 = Color3.fromRGB(65, 68, 80)
padCrossH.BorderSizePixel = 0
padCrossH.ZIndex = 6
padCrossH.Parent = xyPad

local padCrossV = Instance.new("Frame")
padCrossV.Size = UDim2.new(0, 1, 1, 0)
padCrossV.Position = UDim2.new(0.5, 0, 0, 0)
padCrossV.BackgroundColor3 = Color3.fromRGB(65, 68, 80)
padCrossV.BorderSizePixel = 0
padCrossV.ZIndex = 6
padCrossV.Parent = xyPad

local xyCursor = Instance.new("Frame")
xyCursor.Size = UDim2.new(0, 16, 0, 16)
xyCursor.AnchorPoint = Vector2.new(0.5, 0.5)
xyCursor.Position = UDim2.new(0.5, 0, 0.5, 0)
xyCursor.BorderSizePixel = 0
xyCursor.ZIndex = 7
xyCursor.Parent = xyPad
registerTheme(xyCursor, "accent", "BackgroundColor3")
applyBrutalBorder(xyCursor)

local sldCustomPan, sldCustomTilt

local function syncPadFromPanTilt()
    xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0)
    if sldCustomPan then sldCustomPan.setValue(state.curPan) end
    if sldCustomTilt then sldCustomTilt.setValue(state.curTilt) end
end

do
    local padDragging = false
    local function updatePad(input)
        local rx = math.clamp((input.Position.X - xyPad.AbsolutePosition.X) / math.max(1, xyPad.AbsoluteSize.X), 0, 1)
        local ry = math.clamp((input.Position.Y - xyPad.AbsolutePosition.Y) / math.max(1, xyPad.AbsoluteSize.Y), 0, 1)
        state.curPan = math.floor(rx * 100 + 0.5) / 100
        state.curTilt = math.floor((1 - ry) * 100 + 0.5) / 100
        syncPadFromPanTilt()
    end
    xyPad.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            padDragging = true
            updatePad(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if padDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updatePad(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            padDragging = false
        end
    end)
end

sldCustomPan = makeSliderRow(secCustomPad, "Pan (0.1 Kiri - 0.9 Kanan)", 0, 1, state.curPan, false, function(v)
    state.curPan = v
    xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0)
end)

sldCustomTilt = makeSliderRow(secCustomPad, "Tilt (0.1 Bawah - 0.9 Atas)", 0, 1, state.curTilt, false, function(v)
    state.curTilt = v
    xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0)
end)

makeSliderRow(secCustomPad, "Dimmer / Terang (dim)", 0, 1, state.curDim, false, function(v) state.curDim = v end)
makeSliderRow(secCustomPad, "Warna (color)", 0, 1, state.curColor, false, function(v) state.curColor = v end)
makeSliderRow(secCustomPad, "Strobe / Kedip (strobe)", 0, 1, state.curStrobe, false, function(v) state.curStrobe = v end)

local mirrorBtn = Instance.new("TextButton")
mirrorBtn.Size = UDim2.new(1, 0, 0, 22)
mirrorBtn.Text = "MODE CERMIN KIRI-KANAN (MIRROR PAN): MATI"
mirrorBtn.Font = Enum.Font.GothamBlack
mirrorBtn.TextSize = 9
mirrorBtn.BorderSizePixel = 0
mirrorBtn.ZIndex = 5
mirrorBtn.Parent = secCustomPad
registerTheme(mirrorBtn, "surface", "BackgroundColor3")
registerTheme(mirrorBtn, "ink", "TextColor3")
applyBrutalBorder(mirrorBtn)

mirrorBtn.MouseButton1Click:Connect(function()
    state.curMirror = not state.curMirror
    local th = getCurrentTheme()
    mirrorBtn.Text = state.curMirror and "MODE CERMIN KIRI-KANAN (MIRROR PAN): AKTIF" or "MODE CERMIN KIRI-KANAN (MIRROR PAN): MATI"
    mirrorBtn.BackgroundColor3 = state.curMirror and th.secondary or th.surface
    mirrorBtn.TextColor3 = state.curMirror and th.btnText or th.ink
end)

local secCustomSteps = makeSection(pageCustom, "2. URUTAN STEP & SIMPAN KE CUE")

local stepActionRow = Instance.new("Frame")
stepActionRow.Size = UDim2.new(1, 0, 0, 22)
stepActionRow.BackgroundTransparency = 1
stepActionRow.ZIndex = 5
stepActionRow.Parent = secCustomSteps

makeSmallActionBtn(stepActionRow, "+ Rekam Step", 0, 102, "accent", function()
    local frame = {}
    local indices = getSelectedMemberIndices()
    local totalSel = math.max(1, #indices)
    for posIdx, rigIdx in ipairs(indices) do
        local fix = workData.rig[rigIdx]
        if fix then
            local fType = string.lower(fix.t or "clara")
            local pVal = state.curPan
            if state.curMirror and posIdx > (totalSel / 2) then
                pVal = 1 - pVal
            end
            frame[tostring(rigIdx)] = {
                t = fType,
                v = makeFullV(fType, {
                    pan = pVal,
                    tilt = state.curTilt,
                    dim = state.curDim,
                    int = state.curDim,
                    r = state.curDim,
                    g = state.curDim,
                    b = state.curDim,
                    d1 = state.curDim,
                    d2 = state.curDim,
                    d3 = state.curDim,
                    d4 = state.curDim,
                    color = state.curColor,
                    col1 = state.curColor,
                    strobe = state.curStrobe,
                    str = state.curStrobe,
                    shutter = state.curStrobe
                })
            }
        end
    end
    table.insert(state.customSteps, frame)
    if refreshCustomStepsListUI then refreshCustomStepsListUI() end
    setStatus("STEP #" .. #state.customSteps .. " DIREKAM", false)
end)

makeSmallActionBtn(stepActionRow, "Simpan ke Cue", 107, 108, "secondary", function()
    saveCurrentStepsToCue(state.cueId)
end)

makeSmallActionBtn(stepActionRow, "Hapus Semua", 220, 88, "danger", function()
    state.customSteps = {}
    if refreshCustomStepsListUI then refreshCustomStepsListUI() end
    setStatus("SEMUA STEP DIHAPUS", false)
end)

local stepsListContainer = Instance.new("Frame")
stepsListContainer.Size = UDim2.new(1, 0, 0, 0)
stepsListContainer.AutomaticSize = Enum.AutomaticSize.Y
stepsListContainer.BackgroundTransparency = 1
stepsListContainer.ZIndex = 5
stepsListContainer.Parent = secCustomSteps

local stepsListLayout = Instance.new("UIListLayout")
stepsListLayout.Padding = UDim.new(0, 4)
stepsListLayout.Parent = stepsListContainer

refreshCustomStepsListUI = function()
    local th = getCurrentTheme()
    for _, child in ipairs(stepsListContainer:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    if #state.customSteps == 0 then
        local emp = Instance.new("TextLabel")
        emp.Size = UDim2.new(1, 0, 0, 20)
        emp.BackgroundTransparency = 1
        emp.Text = "BELUM ADA STEP. KLIK PRESET DI TAB 1 ATAU '+ REKAM STEP'."
        emp.Font = Enum.Font.Code
        emp.TextSize = 9
        emp.TextColor3 = th.subInk
        emp.TextXAlignment = Enum.TextXAlignment.Left
        emp.ZIndex = 5
        emp.Parent = stepsListContainer
        return
    end

    for sIdx, frame in ipairs(state.customSteps) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundColor3 = th.surface
        row.BorderSizePixel = 0
        row.ZIndex = 5
        row.Parent = stepsListContainer
        applyBrutalBorder(row)

        local samplePan, sampleTilt, sampleDim = 0.5, 0.5, 1
        for _, fData in pairs(frame) do
            if type(fData) == "table" and type(fData.v) == "table" then
                samplePan = fData.v.pan or 0.5
                sampleTilt = fData.v.tilt or 0.5
                sampleDim = fData.v.dim or fData.v.int or 1
                break
            end
        end

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -46, 1, 0)
        lbl.Position = UDim2.new(0, 6, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("STEP %02d  |  PAN: %.2f  TILT: %.2f  DIM: %.2f", sIdx, samplePan, sampleTilt, sampleDim)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 9
        lbl.TextColor3 = th.ink
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 5
        lbl.Parent = row

        local del = Instance.new("TextButton")
        del.Size = UDim2.new(0, 34, 0, 18)
        del.Position = UDim2.new(1, -38, 0.5, -9)
        del.BackgroundColor3 = th.danger
        del.Text = "X"
        del.Font = Enum.Font.GothamBlack
        del.TextSize = 9
        del.TextColor3 = Color3.fromRGB(255, 255, 255)
        del.BorderSizePixel = 0
        del.ZIndex = 5
        del.Parent = row
        applyBrutalBorder(del)

        del.MouseButton1Click:Connect(function()
            table.remove(state.customSteps, sIdx)
            refreshCustomStepsListUI()
            setStatus("STEP #" .. sIdx .. " DIHAPUS", false)
        end)
    end
end

local secPvMain = makeSection(pagePreview, "LIVE STAGE PREVIEW (ATAS / DEPAN + GESER SENTUH & D-PAD)")

local pvToolRow1 = Instance.new("Frame")
pvToolRow1.Size = UDim2.new(1, 0, 0, 22)
pvToolRow1.BackgroundTransparency = 1
pvToolRow1.ZIndex = 5
pvToolRow1.Parent = secPvMain

local pvViewTopBtn = Instance.new("TextButton")
pvViewTopBtn.Size = UDim2.new(0, 74, 0, 21)
pvViewTopBtn.Position = UDim2.new(0, 0, 0, 0)
pvViewTopBtn.Text = "VIEW: ATAS"
pvViewTopBtn.Font = Enum.Font.GothamBlack
pvViewTopBtn.TextSize = 9
pvViewTopBtn.BorderSizePixel = 0
pvViewTopBtn.ZIndex = 5
pvViewTopBtn.Parent = pvToolRow1
applyBrutalBorder(pvViewTopBtn)

local pvViewFrontBtn = Instance.new("TextButton")
pvViewFrontBtn.Size = UDim2.new(0, 80, 0, 21)
pvViewFrontBtn.Position = UDim2.new(0, 78, 0, 0)
pvViewFrontBtn.Text = "VIEW: DEPAN"
pvViewFrontBtn.Font = Enum.Font.GothamBlack
pvViewFrontBtn.TextSize = 9
pvViewFrontBtn.BorderSizePixel = 0
pvViewFrontBtn.ZIndex = 5
pvViewFrontBtn.Parent = pvToolRow1
applyBrutalBorder(pvViewFrontBtn)

local pvDragToggleBtn = Instance.new("TextButton")
pvDragToggleBtn.Size = UDim2.new(0, 88, 0, 21)
pvDragToggleBtn.Position = UDim2.new(0, 162, 0, 0)
pvDragToggleBtn.Text = "GESER: OFF"
pvDragToggleBtn.Font = Enum.Font.GothamBlack
pvDragToggleBtn.TextSize = 9
pvDragToggleBtn.BorderSizePixel = 0
pvDragToggleBtn.ZIndex = 5
pvDragToggleBtn.Parent = pvToolRow1
applyBrutalBorder(pvDragToggleBtn)

local pvShapeBarBtn = Instance.new("TextButton")
pvShapeBarBtn.Size = UDim2.new(0, 48, 0, 21)
pvShapeBarBtn.Position = UDim2.new(0, 254, 0, 0)
pvShapeBarBtn.Text = "BARIS"
pvShapeBarBtn.Font = Enum.Font.GothamBold
pvShapeBarBtn.TextSize = 9
pvShapeBarBtn.BorderSizePixel = 0
pvShapeBarBtn.ZIndex = 5
pvShapeBarBtn.Parent = pvToolRow1
registerTheme(pvShapeBarBtn, "surface", "BackgroundColor3")
registerTheme(pvShapeBarBtn, "ink", "TextColor3")
applyBrutalBorder(pvShapeBarBtn)

local pvShapeArcBtn = Instance.new("TextButton")
pvShapeArcBtn.Size = UDim2.new(0, 48, 0, 21)
pvShapeArcBtn.Position = UDim2.new(0, 306, 0, 0)
pvShapeArcBtn.Text = "BUSUR"
pvShapeArcBtn.Font = Enum.Font.GothamBold
pvShapeArcBtn.TextSize = 9
pvShapeArcBtn.BorderSizePixel = 0
pvShapeArcBtn.ZIndex = 5
pvShapeArcBtn.Parent = pvToolRow1
registerTheme(pvShapeArcBtn, "surface", "BackgroundColor3")
registerTheme(pvShapeArcBtn, "ink", "TextColor3")
applyBrutalBorder(pvShapeArcBtn)

local previewCanvas = Instance.new("Frame")
previewCanvas.Size = UDim2.new(1, 0, 0, 175)
previewCanvas.ClipsDescendants = true
previewCanvas.BorderSizePixel = 0
previewCanvas.ZIndex = 5
previewCanvas.Parent = secPvMain
registerTheme(previewCanvas, "canvas", "BackgroundColor3")
applyBrutalBorder(previewCanvas)

local guideTopLbl = Instance.new("TextLabel")
guideTopLbl.Size = UDim2.new(1, 0, 0, 14)
guideTopLbl.Position = UDim2.new(0, 0, 0, 2)
guideTopLbl.BackgroundTransparency = 1
guideTopLbl.Text = "BELAKANG PANGGUNG (TRUSS)"
guideTopLbl.Font = Enum.Font.Code
guideTopLbl.TextSize = 9
guideTopLbl.TextColor3 = Color3.fromRGB(130, 135, 150)
guideTopLbl.ZIndex = 6
guideTopLbl.Parent = previewCanvas

local guideBotLbl = Instance.new("TextLabel")
guideBotLbl.Size = UDim2.new(1, 0, 0, 14)
guideBotLbl.Position = UDim2.new(0, 0, 1, -15)
guideBotLbl.BackgroundTransparency = 1
guideBotLbl.Text = "DEPAN / PENONTON"
guideBotLbl.Font = Enum.Font.Code
guideBotLbl.TextSize = 9
guideBotLbl.TextColor3 = Color3.fromRGB(130, 135, 150)
guideBotLbl.ZIndex = 6
guideBotLbl.Parent = previewCanvas

local dpadRow = Instance.new("Frame")
dpadRow.Size = UDim2.new(1, 0, 0, 24)
dpadRow.BackgroundTransparency = 1
dpadRow.ZIndex = 5
dpadRow.Parent = secPvMain

local dpadTargetLbl = Instance.new("TextLabel")
dpadTargetLbl.Size = UDim2.new(0, 130, 1, 0)
dpadTargetLbl.Position = UDim2.new(0, 0, 0, 0)
dpadTargetLbl.BackgroundTransparency = 1
dpadTargetLbl.Text = "UNIT #1 (X:0.10 Y:0.25)"
dpadTargetLbl.Font = Enum.Font.Code
dpadTargetLbl.TextSize = 9
dpadTargetLbl.TextXAlignment = Enum.TextXAlignment.Left
dpadTargetLbl.ZIndex = 5
dpadTargetLbl.Parent = dpadRow
registerTheme(dpadTargetLbl, "ink", "TextColor3")

local function nudgeActiveFixture(dx, dy)
    local idx = math.clamp(state.activeLayoutNode, 1, math.max(1, #workData.rig))
    local fix = workData.rig[idx]
    if not fix then return end
    fix.x = math.clamp(math.floor(((fix.x or 0.5) + dx) * 100 + 0.5) / 100, 0.05, 0.95)
    fix.y = math.clamp(math.floor(((fix.y or 0.25) + dy) * 100 + 0.5) / 100, 0.10, 0.90)
    dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", idx, fix.x, fix.y)
    if rebuildPreviewDots then rebuildPreviewDots() end
    if refreshRigEditorUI then refreshRigEditorUI() end
end

makeSmallActionBtn(dpadRow, "◄ KIRI", 132, 48, "surface", function() nudgeActiveFixture(-0.04, 0) end)
makeSmallActionBtn(dpadRow, "► KANAN", 184, 54, "surface", function() nudgeActiveFixture(0.04, 0) end)
makeSmallActionBtn(dpadRow, "▲ ATAS", 242, 48, "surface", function() nudgeActiveFixture(0, -0.04) end)
makeSmallActionBtn(dpadRow, "▼ BAWAH", 294, 54, "surface", function() nudgeActiveFixture(0, 0.04) end)

local previewFixtures = {}

refreshPreviewToolbar = function()
    local th = getCurrentTheme()
    local isTop = (state.previewView == "top")
    pvViewTopBtn.BackgroundColor3 = isTop and th.accent or th.surface
    pvViewTopBtn.TextColor3 = isTop and th.btnText or th.ink
    pvViewFrontBtn.BackgroundColor3 = (not isTop) and th.accent or th.surface
    pvViewFrontBtn.TextColor3 = (not isTop) and th.btnText or th.ink

    pvDragToggleBtn.BackgroundColor3 = state.layoutEditMode and th.secondary or th.surface
    pvDragToggleBtn.TextColor3 = state.layoutEditMode and th.btnText or th.ink
    pvDragToggleBtn.Text = state.layoutEditMode and "GESER: ON" or "GESER: OFF"

    if isTop then
        guideTopLbl.Text = state.layoutEditMode and "GESER BEBAS (ATAS/BAWAH/KIRI/KANAN) - BELAKANG" or "TAMPAK ATAS (DENAH X/Y) - BELAKANG"
        guideBotLbl.Text = "DEPAN / PENONTON"
    else
        guideTopLbl.Text = state.layoutEditMode and "GESER BEBAS POSISI & TINGGI LAMPU - ATAS" or "TAMPAK DEPAN (PANGGUNG)"
        guideBotLbl.Text = "LANTAI PANGGUNG / PENONTON"
    end
end

pvViewTopBtn.MouseButton1Click:Connect(function()
    state.previewView = "top"
    refreshPreviewToolbar()
    if rebuildPreviewDots then rebuildPreviewDots() end
end)

pvViewFrontBtn.MouseButton1Click:Connect(function()
    state.previewView = "front"
    refreshPreviewToolbar()
    if rebuildPreviewDots then rebuildPreviewDots() end
end)

pvDragToggleBtn.MouseButton1Click:Connect(function()
    state.layoutEditMode = not state.layoutEditMode
    refreshPreviewToolbar()
    if rebuildPreviewDots then rebuildPreviewDots() end
    setStatus(state.layoutEditMode and "MODE GESER LAYOUT AKTIF (SENTUH / D-PAD)" or "MODE SIMULASI STEP AKTIF", false)
end)

pvShapeBarBtn.MouseButton1Click:Connect(function()
    local total = math.max(1, #workData.rig)
    for i, fix in ipairs(workData.rig) do
        local px = (total == 1) and 0.5 or (0.10 + ((i - 1) * (0.80 / math.max(1, total - 1))))
        fix.x = math.floor(px * 100 + 0.5) / 100
        fix.y = 0.25
    end
    if rebuildPreviewDots then rebuildPreviewDots() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("TATA LETAK: 1 BARIS LURUS", false)
end)

pvShapeArcBtn.MouseButton1Click:Connect(function()
    local total = math.max(1, #workData.rig)
    for i, fix in ipairs(workData.rig) do
        local norm = (total == 1) and 0 or (((i - 1) / math.max(1, total - 1)) * 2 - 1)
        local px = 0.5 + (norm * 0.42)
        local py = 0.22 + ((1 - (norm * norm)) * 0.48)
        fix.x = math.floor(px * 100 + 0.5) / 100
        fix.y = math.floor(py * 100 + 0.5) / 100
    end
    if rebuildPreviewDots then rebuildPreviewDots() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    setStatus("TATA LETAK: BUSUR MELENGKUNG", false)
end)

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
        local fix = workData.rig[i]
        local fx = math.clamp(tonumber(fix.x) or 0.5, 0.05, 0.95)
        local fy = math.clamp(tonumber(fix.y) or 0.25, 0.10, 0.90)
        local isSelectedNode = (i == state.activeLayoutNode)

        local beam = Instance.new("Frame")
        beam.Size = UDim2.new(0, 12, 0, 50)
        beam.AnchorPoint = Vector2.new(0.5, 0.5)
        beam.BackgroundColor3 = th.accent
        beam.BackgroundTransparency = 0.65
        beam.BorderSizePixel = 0
        beam.ZIndex = 6
        beam.Parent = previewCanvas

        local head = Instance.new("TextButton")
        head.Size = UDim2.new(0, 22, 0, 22)
        head.AnchorPoint = Vector2.new(0.5, 0.5)
        head.Text = tostring(i)
        head.Font = Enum.Font.GothamBlack
        head.TextSize = 10
        head.TextColor3 = th.btnText
        head.BackgroundColor3 = isSelectedNode and th.accent or (state.layoutEditMode and th.secondary or th.header)
        head.AutoButtonColor = false
        head.BorderSizePixel = 0
        head.ZIndex = 8
        head.Parent = previewCanvas
        applyBrutalBorder(head)

        local spot = Instance.new("Frame")
        spot.Size = UDim2.new(0, 12, 0, 12)
        spot.AnchorPoint = Vector2.new(0.5, 0.5)
        spot.BackgroundColor3 = th.accent
        spot.BorderSizePixel = 0
        spot.ZIndex = 7
        spot.Parent = previewCanvas
        applyBrutalBorder(spot)

        head.Position = UDim2.new(fx, 0, fy, 0)
        spot.Position = UDim2.new(fx, 0, fy, 0)
        beam.Position = UDim2.new(fx, 0, fy, 0)

        do
            local draggingNode = false
            head.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    state.activeLayoutNode = i
                    dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", i, fix.x, fix.y)
                    if state.layoutEditMode then
                        draggingNode = true
                    end
                    for idxN, itN in ipairs(previewFixtures) do
                        itN.head.BackgroundColor3 = (idxN == state.activeLayoutNode) and th.accent or (state.layoutEditMode and th.secondary or th.header)
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingNode and state.layoutEditMode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local rx = math.clamp((input.Position.X - previewCanvas.AbsolutePosition.X) / math.max(1, previewCanvas.AbsoluteSize.X), 0.05, 0.95)
                    local ry = math.clamp((input.Position.Y - previewCanvas.AbsolutePosition.Y) / math.max(1, previewCanvas.AbsoluteSize.Y), 0.10, 0.90)
                    fix.x = math.floor(rx * 100 + 0.5) / 100
                    fix.y = math.floor(ry * 100 + 0.5) / 100
                    head.Position = UDim2.new(fix.x, 0, fix.y, 0)
                    spot.Position = UDim2.new(fix.x, 0, fix.y, 0)
                    beam.Position = UDim2.new(fix.x, 0, fix.y, 0)
                    dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", i, fix.x, fix.y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingNode then
                        draggingNode = false
                        if refreshRigEditorUI then refreshRigEditorUI() end
                        setStatus(string.format("POSISI #%d DISIMPAN (X:%.2f Y:%.2f)", i, fix.x, fix.y), false)
                    end
                end
            end)
        end

        previewFixtures[i] = {head = head, beam = beam, spot = spot, fix = fix}
    end
end

RunService.RenderStepped:Connect(function()
    if not pagePreview.Visible or not main.Visible then return end
    if #previewFixtures ~= #workData.rig then
        rebuildPreviewDots()
    end
    local th = getCurrentTheme()
    local totalSteps = #state.customSteps
    local activeFrame = nil
    local nextFrame = nil
    local frac = 0

    if not state.layoutEditMode and totalSteps > 0 then
        local rawPos = (os.clock() * state.stepRate) % totalSteps
        local idx1 = math.floor(rawPos) + 1
        local idx2 = (idx1 % totalSteps) + 1
        frac = rawPos - math.floor(rawPos)
        activeFrame = state.customSteps[idx1]
        nextFrame = state.customSteps[idx2]
    end

    local totalFix = math.max(1, #previewFixtures)
    local cw = math.max(1, previewCanvas.AbsoluteSize.X)
    local ch = math.max(1, previewCanvas.AbsoluteSize.Y)

    for i, item in ipairs(previewFixtures) do
        local isSel = selectedMembers[i] == true
        item.head.Visible = isSel or state.layoutEditMode
        item.beam.Visible = isSel and (not state.layoutEditMode)
        item.spot.Visible = isSel and (not state.layoutEditMode)

        local fx = math.clamp(tonumber(item.fix.x) or 0.5, 0.05, 0.95)
        local fy = math.clamp(tonumber(item.fix.y) or 0.25, 0.10, 0.90)

        if state.layoutEditMode then
            item.head.Rotation = 0
            item.head.Position = UDim2.new(fx, 0, fy, 0)
        elseif isSel then
            local panVal = state.curPan
            local tiltVal = state.curTilt
            local dimVal = state.curDim
            local colVal = state.curColor

            if state.curMirror and i > (totalFix / 2) then
                panVal = 1 - panVal
            end

            if activeFrame and activeFrame[tostring(i)] and activeFrame[tostring(i)].v then
                local v1 = activeFrame[tostring(i)].v
                panVal = v1.pan or 0.5
                tiltVal = v1.tilt or 0.5
                dimVal = v1.dim or v1.int or v1.r or 1
                colVal = v1.color or v1.col1 or 0
                if state.stepGlide > 0 and nextFrame and nextFrame[tostring(i)] and nextFrame[tostring(i)].v then
                    local v2 = nextFrame[tostring(i)].v
                    local g = frac * state.stepGlide
                    panVal = panVal + (((v2.pan or panVal) - panVal) * g)
                    tiltVal = tiltVal + (((v2.tilt or tiltVal) - tiltVal) * g)
                end
            end

            local startX, startY, targetX, targetY
            if state.previewView == "top" then
                startX = fx
                startY = fy
                local offX = (panVal - 0.5) * 0.36
                local offY = (0.5 - tiltVal) * 0.42
                targetX = math.clamp(startX + offX, 0.04, 0.96)
                targetY = math.clamp(startY + 0.16 + offY, 0.08, 0.92)
            else
                startX = fx
                startY = fy
                targetX = math.clamp(startX + ((panVal - 0.5) * 0.44), 0.04, 0.96)
                targetY = math.clamp(startY + 0.48 - (tiltVal * 0.42), 0.15, 0.92)
            end

            item.head.Position = UDim2.new(startX, 0, startY, 0)
            item.spot.Position = UDim2.new(targetX, 0, targetY, 0)

            local dx = (targetX - startX) * cw
            local dy = (targetY - startY) * ch
            local dist = math.sqrt((dx * dx) + (dy * dy))
            local deg = math.deg(math.atan2(dy, dx)) - 90

            item.beam.Position = UDim2.new(startX, dx * 0.5, startY, dy * 0.5)
            item.beam.Size = UDim2.new(0, 12, 0, math.max(10, dist))
            item.beam.Rotation = deg
            item.head.Rotation = deg

            if dimVal <= 0.05 then
                item.beam.BackgroundTransparency = 0.96
                item.spot.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            else
                item.beam.BackgroundTransparency = 0.58
                if colVal > 0.02 then
                    local c = Color3.fromHSV(colVal % 1, 0.9, 1)
                    item.beam.BackgroundColor3 = c
                    item.spot.BackgroundColor3 = c
                else
                    item.beam.BackgroundColor3 = th.accent
                    item.spot.BackgroundColor3 = th.accent
                end
            end
        end
    end
end)

local secRgbPalette = makeSection(pageStatic, "1. PALET WARNA RGB & GOBO/PRISM INSTAN")

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
    b.TextSize = 8
    local lum = (rgbItem.color.R * 0.299) + (rgbItem.color.G * 0.587) + (rgbItem.color.B * 0.114)
    b.TextColor3 = (lum > 0.65) and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(255, 255, 255)
    b.BorderSizePixel = 0
    b.ZIndex = 5
    b.Parent = rgbGridWrap
    applyBrutalBorder(b)

    b.MouseButton1Click:Connect(function()
        for k, val in pairs(rgbItem.vals) do
            if state.editorValues[k] ~= nil then
                state.editorValues[k] = val
                if activeSliderHandles[k] then
                    activeSliderHandles[k].setValue(val)
                end
            end
        end
        setStatus("WARNA/EFEK '" .. rgbItem.name .. "' DITERAPKAN", false)
    end)
end

local secStaticTop = makeSection(pageStatic, "2. EDITOR PARAMETER 12 FIXTURE & SIMPAN CUE STATIS")

local chipStaticLayer = makeChipSelector(secStaticTop, "Target Layer Statis Cue:", {"dim", "pos", "beam"}, state.staticLayerType, function(v)
    state.staticLayerType = v
end)

local chipEditorFix = makeChipSelector(secStaticTop, "Tipe Fixture:", {
    "clara", "strobe", "mapple", "parled", "fogger", "blinder",
    "flower", "pixel", "retro", "wall", "windmill", "sbar"
}, state.editorFixtureType, function(v)
    state.editorFixtureType = v
    state.editorValues = deepCopy(FIXTURE_DEFAULTS[v] or FIXTURE_DEFAULTS.clara)
    if rebuildDynamicFixtureSliders then
        rebuildDynamicFixtureSliders()
    end
end)

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

local staticBtnRow = Instance.new("Frame")
staticBtnRow.Size = UDim2.new(1, 0, 0, 24)
staticBtnRow.BackgroundTransparency = 1
staticBtnRow.ZIndex = 5
staticBtnRow.Parent = secStaticTop

makeSmallActionBtn(staticBtnRow, "Simpan Cue Statis", 0, 145, "accent", function()
    executeWithRigCheck(state.cueId, function()
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
        if uiPrefs.autoSaveOnSaveCue then saveWorkFile() end
        if refreshCueGridUI then refreshCueGridUI() end
        setStatus("STATIC [" .. state.staticLayerType .. "] -> CUE " .. state.cueId, false)
    end)
end)

makeSmallActionBtn(staticBtnRow, "Set Default Rig", 151, 135, "secondary", function()
    local indices = getSelectedMemberIndices()
    for _, idx in ipairs(indices) do
        local fix = workData.rig[idx]
        if fix then
            fix.v = makeFullV(fix.t, state.editorValues)
        end
    end
    setStatus("DEFAULT RIG DIPERBARUI", false)
end)

local secRigGen = makeSection(pageRig, "1. AUTO-PATCH GENERATOR 12 FIXTURE")

makeChipSelector(secRigGen, "Pilih Jenis Fixture:", {
    "clara", "strobe", "mapple", "parled", "fogger", "blinder",
    "flower", "pixel", "retro", "wall", "windmill", "sbar"
}, state.rigType, function(v)
    state.rigType = v
end)

makeSliderRow(secRigGen, "Jumlah Unit Lampu", 1, 32, state.rigCount, true, function(v) state.rigCount = v end)
makeSliderRow(secRigGen, "Alamat DMX Awal", 1, 512, state.rigStartAddr, true, function(v) state.rigStartAddr = v end)
makeChipSelector(secRigGen, "Mode Alamat DMX:", {"independen", "multi"}, state.rigMode, function(v) state.rigMode = v end)

local rigBtnRow = Instance.new("Frame")
rigBtnRow.Size = UDim2.new(1, 0, 0, 22)
rigBtnRow.BackgroundTransparency = 1
rigBtnRow.ZIndex = 5
rigBtnRow.Parent = secRigGen

makeSmallActionBtn(rigBtnRow, "Generate Rig", 0, 102, "accent", function()
    workData.rig = buildAutoPatchedRig(state.rigType, state.rigCount, state.rigStartAddr, state.rigMode)
    state.rigConfigured = true
    resetSelectionAll()
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    if rebuildPreviewDots then rebuildPreviewDots() end
    setStatus("PATCH: " .. state.rigCount .. "X " .. string.upper(state.rigType), false)
end)

makeSmallActionBtn(rigBtnRow, "+ 1 Unit", 107, 78, "secondary", function()
    local t = string.lower(state.rigType)
    local nextAddr = state.rigStartAddr
    for _, fix in ipairs(workData.rig) do
        local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
        local endAddr = (fix.a or 1) + fp
        if endAddr > nextAddr then nextAddr = endAddr end
    end
    if state.rigMode == "multi" and #workData.rig > 0 then
        nextAddr = workData.rig[#workData.rig].a or 1
    end
    table.insert(workData.rig, {
        a = nextAddr,
        x = math.clamp(0.1 + (#workData.rig * 0.08), 0.05, 0.95),
        y = 0.25,
        t = t,
        v = makeFullV(t)
    })
    selectedMembers[#workData.rig] = true
    if refreshMembersUI then refreshMembersUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    if rebuildPreviewDots then rebuildPreviewDots() end
    setStatus("TAMBAH " .. string.upper(t) .. " DMX #" .. nextAddr, false)
end)

local secRigManual = makeSection(pageRig, "2. EDITOR MANUAL ALAMAT DMX & POSISI X/Y PER UNIT")

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
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, fix in ipairs(workData.rig) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 23)
        row.BackgroundColor3 = th.surface
        row.BorderSizePixel = 0
        row.ZIndex = 5
        row.Parent = rigEditorContainer
        applyBrutalBorder(row)

        local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(0, 118, 1, 0)
        info.Position = UDim2.new(0, 6, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = string.format("#%02d %-7s(%dc)", i, string.upper(fix.t), fp)
        info.Font = Enum.Font.GothamBlack
        info.TextSize = 9
        info.TextColor3 = th.ink
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.ZIndex = 5
        info.Parent = row

        local addrBox = Instance.new("TextBox")
        addrBox.Size = UDim2.new(0, 38, 0, 18)
        addrBox.Position = UDim2.new(0, 128, 0.5, -9)
        addrBox.BackgroundColor3 = th.accent
        addrBox.Text = tostring(fix.a)
        addrBox.Font = Enum.Font.Code
        addrBox.TextSize = 10
        addrBox.TextColor3 = th.btnText
        addrBox.ClearTextOnFocus = false
        addrBox.BorderSizePixel = 0
        addrBox.ZIndex = 5
        addrBox.Parent = row
        applyBrutalBorder(addrBox)

        addrBox.FocusLost:Connect(function()
            local n = tonumber(addrBox.Text)
            if n and n >= 1 and n <= 512 then
                fix.a = math.floor(n)
                addrBox.Text = tostring(fix.a)
                if refreshMembersUI then refreshMembersUI() end
            else
                addrBox.Text = tostring(fix.a)
            end
        end)

        local xBox = Instance.new("TextBox")
        xBox.Size = UDim2.new(0, 38, 0, 18)
        xBox.Position = UDim2.new(0, 172, 0.5, -9)
        xBox.BackgroundColor3 = th.chipBg
        xBox.Text = string.format("%.2f", fix.x or 0.5)
        xBox.Font = Enum.Font.Code
        xBox.TextSize = 10
        xBox.TextColor3 = th.ink
        xBox.ClearTextOnFocus = false
        xBox.BorderSizePixel = 0
        xBox.ZIndex = 5
        xBox.Parent = row
        applyBrutalBorder(xBox)

        xBox.FocusLost:Connect(function()
            local n = tonumber(xBox.Text)
            if n then
                fix.x = math.clamp(math.floor(n * 100 + 0.5) / 100, 0.05, 0.95)
                xBox.Text = string.format("%.2f", fix.x)
                if rebuildPreviewDots then rebuildPreviewDots() end
            else
                xBox.Text = string.format("%.2f", fix.x or 0.5)
            end
        end)

        local yBox = Instance.new("TextBox")
        yBox.Size = UDim2.new(0, 38, 0, 18)
        yBox.Position = UDim2.new(0, 215, 0.5, -9)
        yBox.BackgroundColor3 = th.chipBg
        yBox.Text = string.format("%.2f", fix.y or 0.25)
        yBox.Font = Enum.Font.Code
        yBox.TextSize = 10
        yBox.TextColor3 = th.ink
        yBox.ClearTextOnFocus = false
        yBox.BorderSizePixel = 0
        yBox.ZIndex = 5
        yBox.Parent = row
        applyBrutalBorder(yBox)

        yBox.FocusLost:Connect(function()
            local n = tonumber(yBox.Text)
            if n then
                fix.y = math.clamp(math.floor(n * 100 + 0.5) / 100, 0.10, 0.90)
                yBox.Text = string.format("%.2f", fix.y)
                if rebuildPreviewDots then rebuildPreviewDots() end
            else
                yBox.Text = string.format("%.2f", fix.y or 0.25)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 36, 0, 18)
        delBtn.Position = UDim2.new(1, -40, 0.5, -9)
        delBtn.BackgroundColor3 = th.danger
        delBtn.Text = "DEL"
        delBtn.Font = Enum.Font.GothamBlack
        delBtn.TextSize = 9
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.BorderSizePixel = 0
        delBtn.ZIndex = 5
        delBtn.Parent = row
        applyBrutalBorder(delBtn)

        delBtn.MouseButton1Click:Connect(function()
            if #workData.rig > 1 then
                table.remove(workData.rig, i)
                resetSelectionAll()
                refreshMembersUI()
                refreshRigEditorUI()
                rebuildPreviewDots()
            end
        end)
    end
end

local secCueGrid = makeSection(pageCues, "PILIH & SIMPAN KE SLOT CUE 1 - 24 (RKDESIGN)")

local cueQuickRow = Instance.new("Frame")
cueQuickRow.Size = UDim2.new(1, 0, 0, 22)
cueQuickRow.BackgroundTransparency = 1
cueQuickRow.ZIndex = 5
cueQuickRow.Parent = secCueGrid

makeSmallActionBtn(cueQuickRow, "Simpan ke Cue Aktif", 0, 125, "accent", function()
    saveCurrentStepsToCue(state.cueId)
end)

makeSmallActionBtn(cueQuickRow, "Atur DMX", 130, 74, "secondary", function()
    openRigSetupModal(function()
        setStatus("DMX DIPERBARUI", false)
    end)
end)

makeSmallActionBtn(cueQuickRow, "Hapus Cue", 209, 76, "danger", function()
    workData.cues[state.cueId] = nil
    if uiPrefs.autoSaveOnSaveCue then
        saveWorkFile()
    end
    refreshCueGridUI()
    setStatus("CUE " .. state.cueId .. " DIHAPUS", false)
end)

local cueGridWrap = Instance.new("Frame")
cueGridWrap.Size = UDim2.new(1, 0, 0, 0)
cueGridWrap.AutomaticSize = Enum.AutomaticSize.Y
cueGridWrap.BackgroundTransparency = 1
cueGridWrap.ZIndex = 5
cueGridWrap.Parent = secCueGrid

local cueGridLayout = Instance.new("UIGridLayout")
cueGridLayout.CellSize = UDim2.new(0.24, 0, 0, 30)
cueGridLayout.CellPadding = UDim2.new(0.013, 0, 0, 4)
cueGridLayout.Parent = cueGridWrap

refreshCueGridUI = function()
    local th = getCurrentTheme()
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
            if c.layer == "chs" and c.chase and c.chase.steps then
                sub = #c.chase.steps .. " STEP"
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
            state.cueId = k
            if c and c.layer == "chs" and type(c.chase) == "table" then
                state.customSteps = deepCopy(c.chase.steps or {})
                state.stepRate = tonumber(c.chase.rate) or 2.5
                state.stepGlide = tonumber(c.chase.glide) or 0.35
                state.stepDir = c.chase.dir or ">"
                if sldPresetRate then sldPresetRate.setValue(state.stepRate) end
                if sldPresetGlide then sldPresetGlide.setValue(state.stepGlide) end
                if chipPresetDir then chipPresetDir.setSelected(state.stepDir) end
                refreshCustomStepsListUI()
                setStatus("CUE " .. k .. " (" .. #state.customSteps .. " STEP) DIMUAT", false)
            elseif not c and uiPrefs.promptRigOnNewCue then
                openRigSetupModal(function()
                    setStatus("CUE " .. k .. " DIPILIH (SIAP SIMPAN)", false)
                end)
            else
                setStatus("CUE " .. k .. " DIPILIH", false)
            end
            refreshCueGridUI()
        end)
    end
end

local applyFullTheme

local secSetScale = makeSection(pageSettings, "1. UKURAN JENDELA (PANJANG/LEBAR/TINGGI) & SKALA (0.20 - 1.30)")

local sldUiScale = makeSliderRow(secSetScale, "Skala UI (0.20 - 1.30)", 0.20, 1.30, uiPrefs.uiScale, false, function(v)
    uiPrefs.uiScale = v
    uiScaleObj.Scale = v
    savePrefs()
end)

local sldWinW = makeSliderRow(secSetScale, "Lebar Jendela (320 - 900)", 320, 900, uiPrefs.winWidth, true, function(v)
    uiPrefs.winWidth = v
    main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight)
    savePrefs()
end)

local sldWinH = makeSliderRow(secSetScale, "Tinggi Jendela (220 - 650)", 220, 650, uiPrefs.winHeight, true, function(v)
    uiPrefs.winHeight = v
    main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight)
    savePrefs()
end)

makeSliderRow(secSetScale, "Ukuran Bubble (36 - 66 px)", 36, 66, uiPrefs.bubbleSize, true, function(v)
    uiPrefs.bubbleSize = v
    bubbleBtn.Size = UDim2.new(0, v, 0, v)
    savePrefs()
end)

local secSetTheme = makeSection(pageSettings, "2. TEMA GELAP, TRANSPARANSI & EFEK BLUR")

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
blurToggleBtn.Size = UDim2.new(1, 0, 0, 24)
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

local secSetOpt = makeSection(pageSettings, "3. OPTIMASI PROMPT DMX & RESET")

local promptRigBtn = Instance.new("TextButton")
promptRigBtn.Size = UDim2.new(1, 0, 0, 24)
promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA JUMLAH DMX SAAT SIMPAN CUE BARU: AKTIF" or "TANYA JUMLAH DMX SAAT SIMPAN CUE BARU: MATI"
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
    promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA JUMLAH DMX SAAT SIMPAN CUE BARU: AKTIF" or "TANYA JUMLAH DMX SAAT SIMPAN CUE BARU: MATI"
    local th = getCurrentTheme()
    promptRigBtn.BackgroundColor3 = uiPrefs.promptRigOnNewCue and th.accent or th.surface
    promptRigBtn.TextColor3 = uiPrefs.promptRigOnNewCue and th.btnText or th.ink
    savePrefs()
end)

local setBtnRow = Instance.new("Frame")
setBtnRow.Size = UDim2.new(1, 0, 0, 22)
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

makeSmallActionBtn(setBtnRow, "Reset Ukuran & Posisi", 131, 145, "surface", function()
    uiPrefs.uiScale = 1.0
    uiPrefs.winWidth = 520
    uiPrefs.winHeight = 330
    uiScaleObj.Scale = 1.0
    main.Size = UDim2.new(0, 520, 0, 330)
    main.Position = UDim2.new(0.5, 0, 0.52, 0)
    bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    sldUiScale.setValue(1.0)
    sldWinW.setValue(520)
    sldWinH.setValue(330)
    savePrefs()
    setStatus("UKURAN & POSISI DIRESET", false)
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
cueIdBox.Size = UDim2.new(0, 38, 0, 20)
cueIdBox.Position = UDim2.new(0, 44, 0.5, -10)
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
    else
        cueIdBox.Text = state.cueId
    end
    if refreshCueGridUI then refreshCueGridUI() end
end)

local saveCueFooterBtn = Instance.new("TextButton")
saveCueFooterBtn.Size = UDim2.new(0, 108, 0, 20)
saveCueFooterBtn.Position = UDim2.new(1, -248, 0.5, -10)
saveCueFooterBtn.Text = "SIMPAN KE CUE"
saveCueFooterBtn.Font = Enum.Font.GothamBlack
saveCueFooterBtn.TextSize = 10
saveCueFooterBtn.BorderSizePixel = 0
saveCueFooterBtn.ZIndex = 4
saveCueFooterBtn.Parent = footerBar
registerTheme(saveCueFooterBtn, "secondary", "BackgroundColor3")
registerTheme(saveCueFooterBtn, "btnText", "TextColor3")
applyBrutalBorder(saveCueFooterBtn)

saveCueFooterBtn.MouseButton1Click:Connect(function()
    saveCurrentStepsToCue(state.cueId)
end)

local saveWorkFooterBtn = Instance.new("TextButton")
saveWorkFooterBtn.Size = UDim2.new(0, 130, 0, 20)
saveWorkFooterBtn.Position = UDim2.new(1, -134, 0.5, -10)
saveWorkFooterBtn.Text = "EXPORT WORK.JSON"
saveWorkFooterBtn.Font = Enum.Font.GothamBlack
saveWorkFooterBtn.TextSize = 10
saveWorkFooterBtn.BorderSizePixel = 0
saveWorkFooterBtn.ZIndex = 4
saveWorkFooterBtn.Parent = footerBar
registerTheme(saveWorkFooterBtn, "accent", "BackgroundColor3")
registerTheme(saveWorkFooterBtn, "btnText", "TextColor3")
applyBrutalBorder(saveWorkFooterBtn)

saveWorkFooterBtn.MouseButton1Click:Connect(function()
    local ok, msg = saveWorkFile()
    setStatus(msg, not ok)
end)

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
    mirrorBtn.BackgroundColor3 = state.curMirror and th.secondary or th.surface
    mirrorBtn.TextColor3 = state.curMirror and th.btnText or th.ink
    refreshPreviewToolbar()
    refreshTabStyles()
    for _, cs in ipairs(chipSelectorsList) do
        cs.retheme()
    end
    if refreshMembersUI then refreshMembersUI() end
    if refreshCustomStepsListUI then refreshCustomStepsListUI() end
    if refreshCueGridUI then refreshCueGridUI() end
    if refreshRigEditorUI then refreshRigEditorUI() end
    rebuildPreviewDots()
end

rebuildDynamicFixtureSliders()
refreshMembersUI()
refreshCustomStepsListUI()
refreshCueGridUI()
refreshRigEditorUI()
rebuildPreviewDots()
applyFullTheme()
switchTab("presets")
