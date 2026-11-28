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
pcall(function()
    if Lighting:FindFirstChild("ApexDMXBlur") then
        Lighting:FindFirstChild("ApexDMXBlur"):Destroy()
    end
end)

local LANGS = {
    ["Indonesia"] = {
        tab_preset = "Preset Step", tab_custom = "Custom Step", tab_preview = "Live Preview",
        tab_static = "Static / RGB", tab_rig = "Rig & DMX", tab_cue = "Simpan Cue", tab_settings = "Settings",
        btn_guide = "? PANDUAN", btn_save_cue = "SIMPAN KE CUE", btn_export = "EXPORT WORK.JSON",
        lbl_pan = "Pan (Kiri - Kanan)", lbl_tilt = "Tilt (Bawah - Atas)", lbl_dim = "Dimmer (Terang)",
        lbl_color = "Warna (Color)", lbl_strobe = "Strobe (Kedip)", lbl_rate = "Kecepatan (Rate)", lbl_glide = "Kehalusan (Glide)",
        btn_rec_step = "+ REKAM STEP", btn_del_all = "HAPUS SEMUA",
        btn_mirror_off = "CERMIN KIRI-KANAN: MATI", btn_mirror_on = "CERMIN KIRI-KANAN: AKTIF",
        hint_empty = "LANGKAH 1: PILIH LAMPU TARGET, WARNA/EFEK & PRESET ATAU REKAM STEP.",
        hint_ready = "LANGKAH 2: CEK PREVIEW / GABUNG GRUP / TEKAN 'SIMPAN KE CUE'.",
        hint_edit = "MODE GESER AKTIF: SERET LAMPU / PAKAI D-PAD / PILIH BENTUK FORMASI."
    },
    ["Sehari-hari"] = {
        tab_preset = "Gerak Instan", tab_custom = "Bikin Sendiri", tab_preview = "Lihat Panggung",
        tab_static = "Warna & Pose", tab_rig = "Atur Lampu", tab_cue = "Slot Cue", tab_settings = "Pengaturan",
        btn_guide = "? CARA PAKAI", btn_save_cue = "MASUKIN KE CUE", btn_export = "SIMPAN FILE",
        lbl_pan = "Geser Kiri - Kanan", lbl_tilt = "Dongak Atas - Bawah", lbl_dim = "Terang Lampu",
        lbl_color = "Ganti Warna", lbl_strobe = "Kedip Cepat", lbl_rate = "Seberapa Cepat", lbl_glide = "Biar Gerak Mulus",
        btn_rec_step = "+ CATAT GERAKAN", btn_del_all = "HAPUS SEMUA",
        btn_mirror_off = "MIRROR SIMETRIS: MATI", btn_mirror_on = "MIRROR SIMETRIS: NYALA",
        hint_empty = "PILIH LAMPU & WARNA DULU, LALU KLIK SALAH SATU DARI 30 POLA GERAK.",
        hint_ready = "GERAKAN UDAH JADI! BISA GABUNG BEDA GERAK GRUP ATAU SIMPAN CUE.",
        hint_edit = "TINGGAL SERET LAMPU PAKAI JARI ATAU PILIH BENTUK KOTAK/LINGKARAN/KATA."
    },
    ["Jawa"] = {
        tab_preset = "Gerak Cepet", tab_custom = "Gawe Dewe", tab_preview = "Delok Panggung",
        tab_static = "Werno & Diam", tab_rig = "Atur Lampu", tab_cue = "Simpen Cue", tab_settings = "Setelan",
        btn_guide = "? CARANE", btn_save_cue = "SIMPEN NING CUE", btn_export = "SIMPEN JSON",
        lbl_pan = "Kiwo - Tengen (Pan)", lbl_tilt = "Ngisor - Duwur (Tilt)", lbl_dim = "Padange Lampu",
        lbl_color = "Werno Lampu", lbl_strobe = "Kedip Cepet", lbl_rate = "Cepete Gerak", lbl_glide = "Aluse Gerak",
        btn_rec_step = "+ CATET GERAK", btn_del_all = "BUSEK KABEH",
        btn_mirror_off = "KOCO KIWO-TENGEN: MATI", btn_mirror_on = "KOCO KIWO-TENGEN: URIP",
        hint_empty = "LANGKAH 1: PILIH LAMPU, WERNO KARO POLA GERAK CEPET NING NGISOR.",
        hint_ready = "WES DADI STEP-E! ISO GABUNG GRUP MANEH UTAWA SIMPEN NING CUE.",
        hint_edit = "GESER LAMPUNE NANG LAYAR UTAWA PILIH BENTUK BUNDER/KOTAK/TULISAN."
    },
    ["Sunda"] = {
        tab_preset = "Gerak Instan", tab_custom = "Jieun Sorangan", tab_preview = "Tingali Panggung",
        tab_static = "Warna & Cicing", tab_rig = "Atur Lampu", tab_cue = "Simpen Cue", tab_settings = "Setelan",
        btn_guide = "? PITUDUH", btn_save_cue = "SIMPEN KANA CUE", btn_export = "SIMPEN JSON",
        lbl_pan = "Kenca - Katuhu (Pan)", lbl_tilt = "Handap - Luhur (Tilt)", lbl_dim = "Caangna Lampu",
        lbl_color = "Warna Lampu", lbl_strobe = "Kiceup Gancang", lbl_rate = "Gancangna Gerak", lbl_glide = "Lemesna Gerak",
        btn_rec_step = "+ CATET GERAK", btn_del_all = "HAPUS KABEH",
        btn_mirror_off = "EUNTEUNG KENCA-KATUHU: PAEH", btn_mirror_on = "EUNTEUNG KENCA-KATUHU: HURUNG",
        hint_empty = "LENGKAH 1: PILIH LAMPU, WARNA JEUNG GERAK INSTAN DI HANDAP.",
        hint_ready = "GEUS JADI! TIASA GABUNG GRUP DEUI ATAWA SIMPEN KANA CUE.",
        hint_edit = "GESER LAMPU DINA LAYAR ATAWA PILIH BENTUK BULEUD/KOTAK/KECAP."
    },
    ["English"] = {
        tab_preset = "Step Presets", tab_custom = "Custom Step", tab_preview = "Live Preview",
        tab_static = "Static / RGB", tab_rig = "Rig & DMX", tab_cue = "Save Cue", tab_settings = "Settings",
        btn_guide = "? GUIDE", btn_save_cue = "STORE TO CUE", btn_export = "EXPORT WORK.JSON",
        lbl_pan = "Pan (Left - Right)", lbl_tilt = "Tilt (Down - Up)", lbl_dim = "Dimmer Intensity",
        lbl_color = "Color Wheel / RGB", lbl_strobe = "Strobe Shutter", lbl_rate = "Step Speed (Rate)", lbl_glide = "Smooth Glide",
        btn_rec_step = "+ RECORD STEP", btn_del_all = "CLEAR ALL",
        btn_mirror_off = "MIRROR PAN: OFF", btn_mirror_on = "MIRROR PAN: ON",
        hint_empty = "STEP 1: PICK FIXTURES, COLOR/FX & CLICK ANY OF 30 PRESETS.",
        hint_ready = "STEP 2: MERGE ANOTHER GROUP OR CLICK 'STORE TO CUE' & 'EXPORT WORK.JSON'.",
        hint_edit = "LAYOUT EDIT: DRAG FIXTURES / USE D-PAD / APPLY SHAPE OR WORD FORMATION."
    }
}

local WALKTHROUGH_MISSIONS = {
    {
        id = "dmx_universe",
        title = "MISI 1: PAHAM UNIVERSE (U1-U16) & ADDRESS DMX",
        desc = "Cara atur Universe & Address (1, 17, 33..) serta auto-pindah ke Universe 2 jika lewat 512ch.",
        steps = {
            {tab = "rig", target = "rig_patch", text = "INFO UNIVERSE: 1 Universe = 512 channel. Clara butuh 16ch, jadi alamatnya 1, 17, 33... Jika pasang >32 unit Clara, unit ke-33 otomatis masuk Universe 2 Address 1 (maks Universe 16)."},
            {tab = "rig", target = "rig_add_group", text = "MULTI KELOMPOK: Mau gabung beberapa jenis lampu di 1 panggung? Atur tipe lampu baru lalu klik '+ TAMBAH KELOMPOK' agar tidak menimpa lampu lama."},
            {tab = "rig", target = "rig_manual", text = "EDIT MANUAL: Kamu bisa ubah kolom U (Universe 1-16), A (Address 1-512), serta posisi X/Y tiap lampu langsung di daftar ini."}
        }
    },
    {
        id = "multi_group_cue",
        title = "MISI 2: BEDA GERAKAN DALAM 1 CUE (6 MUTER + 2 NAIK-TURUN)",
        desc = "Trik menggabungkan gerakan berbeda untuk kelompok lampu berbeda ke dalam 1 Cue.",
        steps = {
            {tab = "presets", target = "preset_members", text = "LANGKAH 1: Centang lampu grup pertama saja (misal klik unit #1 sampai #6, matikan #7 & #8)."},
            {tab = "presets", target = "preset_grid", text = "LANGKAH 2: Klik preset gerakan pertama (misal 'CIRCLE PUTAR'). Sekarang lampu #1-#6 sudah berputar."},
            {tab = "presets", target = "preset_members", text = "LANGKAH 3: Sekarang matikan #1-#6, lalu centang lampu #7 & #8 saja sebagai grup kedua."},
            {tab = "presets", target = "preset_chain", text = "LANGKAH 4: Klik tombol '+ GABUNG BERSAMA' sampai menyala, lalu klik preset 'OMBAK NAIK-TURUN' di bawah!"},
            {tab = "presets", target = "footer_save", text = "LANGKAH 5: Tekan SIMPAN KE CUE! Sekarang dalam 1 Cue, lampu #1-#6 berputar bersamaan dengan #7-#8 naik-turun."}
        }
    },
    {
        id = "preset_fx_flow",
        title = "MISI 3: PRESET DINAMIS, WARNA RGB & PRISM/GOBO",
        desc = "Memakai preset yang tiba-tiba berubah menjadi Prism, Strobe, atau ganti warna RGB.",
        steps = {
            {tab = "presets", target = "preset_colors", text = "LANGKAH 1: Pilih warna statis, RAINBOW, atau RGB CUSTOM (geser slider R, G, B & Color Wheel)."},
            {tab = "presets", target = "preset_fx", text = "LANGKAH 2: Nyalakan PRISM (0.05 = 9 titik), GOBO (0.35 / 0.62 / 0.91), BLUR (Focus Clara), atau MOTIF FX (lampu selain Clara)."},
            {tab = "presets", target = "preset_grid", text = "LANGKAH 3: Coba preset '[FX] BEAM -> PRISM DROP' atau '[FX] SWEEP -> STROBE DROP' untuk gerakan yang otomatis berubah efek di tengah jalan!"}
        }
    },
    {
        id = "preview_flow",
        title = "MISI 4: TATA LETAK PANGGUNG (BENTUK & KATA 8 HURUF)",
        desc = "Menyusun posisi lampu menjadi Lingkaran, Kotak, Segitiga, hingga tulisan 8 huruf.",
        steps = {
            {tab = "preview", target = "pv_drag", text = "LANGKAH 1: Klik tombol 'GESER: OFF' hingga menjadi 'GESER: ON' agar lampu bisa digeser bebas."},
            {tab = "preview", target = "pv_canvas", text = "LANGKAH 2: Seret nomor lampu di kanvas ini ke atas, bawah, kiri, kanan, atau pakai tombol D-Pad di bawahnya."},
            {tab = "preview", target = "pv_shapes", text = "LANGKAH 3: Atau klik template otomatis (Lingkaran, Kotak, Segitiga, Segi 5/6/7) & ketik kata maksimal 8 huruf!"}
        }
    }
}

local DMX_DOC_SUMMARY = "DOKUMENTASI UNIVERSE & ADDRESS: Address (A: 1-512) adalah nomor channel awal tiap lampu (Clara 16ch = A1, A17, A33...). Universe (U: 1-16) adalah jalur paket 512 channel. Jika 1 Universe penuh (32 unit Clara = 512ch), unit ke-33 otomatis pindah ke U2:A1 sampai batas U16."

local THEMES = {
    ["SYD Console"] = {
        bg = Color3.fromRGB(23, 25, 30),
        surface = Color3.fromRGB(32, 35, 42),
        header = Color3.fromRGB(38, 42, 52),
        accent = Color3.fromRGB(46, 168, 255),
        secondary = Color3.fromRGB(245, 166, 35),
        danger = Color3.fromRGB(224, 68, 78),
        ink = Color3.fromRGB(238, 241, 246),
        subInk = Color3.fromRGB(152, 160, 175),
        chipBg = Color3.fromRGB(44, 48, 58),
        canvas = Color3.fromRGB(14, 16, 20),
        btnText = Color3.fromRGB(12, 14, 18),
        headerText = Color3.fromRGB(240, 244, 250),
        stroke = Color3.fromRGB(58, 63, 75),
        corner = 6,
        isBrutal = false
    },
    ["SYD Emerald"] = {
        bg = Color3.fromRGB(20, 24, 24),
        surface = Color3.fromRGB(29, 35, 35),
        header = Color3.fromRGB(34, 44, 42),
        accent = Color3.fromRGB(16, 215, 145),
        secondary = Color3.fromRGB(250, 195, 50),
        danger = Color3.fromRGB(235, 70, 75),
        ink = Color3.fromRGB(238, 245, 242),
        subInk = Color3.fromRGB(150, 168, 162),
        chipBg = Color3.fromRGB(40, 49, 48),
        canvas = Color3.fromRGB(12, 15, 15),
        btnText = Color3.fromRGB(10, 14, 12),
        headerText = Color3.fromRGB(238, 245, 242),
        stroke = Color3.fromRGB(54, 68, 65),
        corner = 6,
        isBrutal = false
    },
    ["OLED Midnight"] = {
        bg = Color3.fromRGB(10, 10, 13),
        surface = Color3.fromRGB(20, 21, 26),
        header = Color3.fromRGB(26, 28, 36),
        accent = Color3.fromRGB(0, 212, 255),
        secondary = Color3.fromRGB(255, 110, 180),
        danger = Color3.fromRGB(245, 55, 65),
        ink = Color3.fromRGB(242, 244, 250),
        subInk = Color3.fromRGB(155, 160, 175),
        chipBg = Color3.fromRGB(32, 34, 42),
        canvas = Color3.fromRGB(5, 5, 8),
        btnText = Color3.fromRGB(10, 10, 10),
        headerText = Color3.fromRGB(242, 244, 250),
        stroke = Color3.fromRGB(48, 52, 66),
        corner = 6,
        isBrutal = false
    },
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
        btnText = Color3.fromRGB(12, 12, 12),
        headerText = Color3.fromRGB(12, 12, 12),
        stroke = Color3.fromRGB(0, 0, 0),
        corner = 0,
        isBrutal = true
    }
}

local uiPrefs = {
    themeName = "SYD Console",
    langName = "Sehari-hari",
    uiScale = 1.0,
    winWidth = 540,
    winHeight = 355,
    borderThickness = 1,
    autoSaveOnSaveCue = true,
    bubbleSize = 46,
    promptRigOnNewCue = true,
    bgTransparency = 0.08,
    enableBlur = true
}

local function loadPrefs()
    if isfile and readfile and isfile(PREFS_FILE) then
        local ok, raw = pcall(readfile, PREFS_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, dec = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(dec) == "table" then
                if THEMES[dec.themeName] then uiPrefs.themeName = dec.themeName end
                if LANGS[dec.langName] then uiPrefs.langName = dec.langName end
                if tonumber(dec.uiScale) then uiPrefs.uiScale = math.clamp(tonumber(dec.uiScale), 0.20, 1.30) end
                if tonumber(dec.winWidth) then uiPrefs.winWidth = math.clamp(math.floor(tonumber(dec.winWidth)), 320, 950) end
                if tonumber(dec.winHeight) then uiPrefs.winHeight = math.clamp(math.floor(tonumber(dec.winHeight)), 220, 700) end
                if tonumber(dec.borderThickness) then uiPrefs.borderThickness = math.clamp(math.floor(tonumber(dec.borderThickness)), 1, 3) end
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
        if ok then pcall(writefile, PREFS_FILE, string.gsub(enc, "[\r\n]", "")) end
    end
end

loadPrefs()

local function tr(key)
    local dict = LANGS[uiPrefs.langName] or LANGS["Indonesia"]
    return dict[key] or LANGS["Indonesia"][key] or key
end

local GLYPH_5X7 = {
    A={"01110","10001","10001","11111","10001","10001","10001"}, B={"11110","10001","10001","11110","10001","10001","11110"},
    C={"01111","10000","10000","10000","10000","10000","01111"}, D={"11110","10001","10001","10001","10001","10001","11110"},
    E={"11111","10000","10000","11110","10000","10000","11111"}, F={"11111","10000","10000","11110","10000","10000","10000"},
    G={"01111","10000","10000","10111","10001","10001","01111"}, H={"10001","10001","10001","11111","10001","10001","10001"},
    I={"11111","00100","00100","00100","00100","00100","11111"}, J={"00111","00010","00010","00010","10010","10010","01100"},
    K={"10001","10010","10100","11000","10100","10010","10001"}, L={"10000","10000","10000","10000","10000","10000","11111"},
    M={"10001","11011","10101","10001","10001","10001","10001"}, N={"10001","11001","10101","10011","10001","10001","10001"},
    O={"01110","10001","10001","10001","10001","10001","01110"}, P={"11110","10001","10001","11110","10000","10000","10000"},
    Q={"01110","10001","10001","10001","10101","10010","01101"}, R={"11110","10001","10001","11110","10100","10010","10001"},
    S={"01111","10000","10000","01110","00001","00001","11110"}, T={"11111","00100","00100","00100","00100","00100","00100"},
    U={"10001","10001","10001","10001","10001","10001","01110"}, V={"10001","10001","10001","10001","10001","01010","00100"},
    W={"10001","10001","10001","10001","10101","11011","10001"}, X={"10001","10001","01010","00100","01010","10001","10001"},
    Y={"10001","10001","01010","00100","00100","00100","00100"}, Z={"11111","00001","00010","00100","01000","10000","11111"},
    ["0"]={"01110","10001","10011","10101","11001","10001","01110"}, ["1"]={"00100","01100","00100","00100","00100","00100","01110"},
    ["2"]={"01110","10001","00001","00110","01000","10000","11111"}, ["3"]={"11110","00001","00001","01110","00001","00001","11110"},
    ["4"]={"00010","00110","01010","10010","11111","00010","00010"}, ["5"]={"11111","10000","11110","00001","00001","10001","01110"},
    ["6"]={"01110","10000","10000","11110","10001","10001","01110"}, ["7"]={"11111","00001","00010","00100","01000","01000","01000"},
    ["8"]={"01110","10001","10001","01110","10001","10001","01110"}, ["9"]={"01110","10001","10001","01111","00001","00001","01110"}
}

local function samplePolygonPerimeter(vertices, count)
    local pts = {}
    local n = #vertices
    if n == 0 or count <= 0 then return pts end
    if count == 1 then return {{x = vertices[1].x, y = vertices[1].y}} end
    local segLens, totalLen = {}, 0
    for i = 1, n do
        local a, b = vertices[i], vertices[(i % n) + 1]
        local d = math.sqrt((b.x - a.x)^2 + (b.y - a.y)^2)
        segLens[i] = d; totalLen = totalLen + d
    end
    for k = 0, count - 1 do
        local targetDist, acc = (k / count) * totalLen, 0
        for i = 1, n do
            local d = segLens[i]
            if acc + d >= targetDist or i == n then
                local a, b = vertices[i], vertices[(i % n) + 1]
                local t = (d > 0) and ((targetDist - acc) / d) or 0
                table.insert(pts, {x = a.x + (b.x - a.x) * t, y = a.y + (b.y - a.y) * t})
                break
            end
            acc = acc + d
        end
    end
    return pts
end

local function makeRegularPolygon(sides, radiusX, radiusY, startAngleDeg)
    local verts = {}
    for i = 0, sides - 1 do
        local rad = math.rad(startAngleDeg + (i * (360 / sides)))
        table.insert(verts, {x = 0.5 + math.cos(rad) * radiusX, y = 0.5 + math.sin(rad) * radiusY})
    end
    return verts
end

local function generateWordPoints(wordStr, maxPoints)
    local clean = string.upper(string.sub(string.gsub(tostring(wordStr or ""), "[^%w]", ""), 1, 8))
    if #clean == 0 then return {} end
    local rawDots, charW, gap = {}, 5, 1
    local totalCols = (#clean * charW) + ((#clean - 1) * gap)
    for cIdx = 1, #clean do
        local glyph = GLYPH_5X7[string.sub(clean, cIdx, cIdx)]
        if glyph then
            local colOffset = (cIdx - 1) * (charW + gap)
            for row = 1, 7 do
                local line = glyph[row]
                for col = 1, 5 do
                    if string.sub(line, col, col) == "1" then
                        table.insert(rawDots, {gx = colOffset + (col - 1), gy = row - 1})
                    end
                end
            end
        end
    end
    if #rawDots == 0 then return {} end
    table.sort(rawDots, function(a, b) if a.gx == b.gx then return a.gy < b.gy end return a.gx < b.gx end)
    local out, count = {}, math.min(maxPoints, #rawDots)
    for i = 1, count do
        local pickIdx = math.clamp(math.floor(((i - 0.5) / count) * #rawDots) + 1, 1, #rawDots)
        local d = rawDots[pickIdx]
        table.insert(out, {
            x = 0.08 + ((d.gx / math.max(1, totalCols - 1)) * 0.84),
            y = 0.18 + ((d.gy / 6) * 0.64)
        })
    end
    return out
end

local FIXTURE_FOOTPRINTS = {
    clara = 16, strobe = 8, mapple = 16, parled = 6, fogger = 1, blinder = 4,
    flower = 18, pixel = 20, retro = 12, wall = 8, windmill = 8, sbar = 8
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
    {name="Circle Zoom In/Out", pattern="circle_zoom", glide=0.45, rate=2.4},
    {name="Figure-8 Angka 8", pattern="fig8", glide=0.45, rate=2.0},
    {name="Figure-8 Cermin", pattern="fig8_mirror", glide=0.45, rate=2.1},
    {name="Sapu Kiri-Kanan", pattern="wave_pan", glide=0.40, rate=2.5},
    {name="Kipas Cermin", pattern="fan_io", glide=0.40, rate=2.4},
    {name="Kipas Silang X", pattern="cross_x", glide=0.35, rate=2.6},
    {name="Ombak Naik-Turun", pattern="wave_tilt", glide=0.40, rate=2.5},
    {name="Tilt Cermin Wing", pattern="tilt_mirror", glide=0.40, rate=2.5},
    {name="Tangga Tilt Naik", pattern="stair_tilt", glide=0.30, rate=2.8},
    {name="Fly-Out Tembak Atas", pattern="fly_out", glide=0.25, rate=3.0},
    {name="Diamond Wajik", pattern="diamond", glide=0.40, rate=2.3},
    {name="Kotak Square Path", pattern="box_path", glide=0.30, rate=2.4},
    {name="Zig-Zag Tajam", pattern="zigzag", glide=0.15, rate=3.2},
    {name="Spiral Putar", pattern="spiral", glide=0.45, rate=2.2},
    {name="Heart / Hati", pattern="heart", glide=0.45, rate=2.0},
    {name="V-Shape Wave", pattern="v_wave", glide=0.40, rate=2.4},
    {name="Center Focus Pinch", pattern="center_pinch", glide=0.40, rate=2.3},
    {name="Silang Ping-Pong", pattern="pingpong", glide=0.25, rate=3.0},
    {name="Ballyhoo Acak", pattern="ballyhoo", glide=0.35, rate=2.6},
    {name="Kedip Ganjil-Genap", pattern="odd_even", glide=0.0, rate=4.0},
    {name="Lampu Lari (Runner)", pattern="runner", glide=0.10, rate=4.5},
    {name="Bounce Kiri-Kanan", pattern="bounce_lr", glide=0.15, rate=4.0},
    {name="Twinkle Bintang", pattern="twinkle", glide=0.05, rate=5.0},
    {name="Police Strobe Split", pattern="police_split", glide=0.0, rate=6.0},
    {name="[FX] Beam -> Prism Drop", pattern="dyn_prism_drop", glide=0.35, rate=2.4},
    {name="[FX] Sweep -> Strobe Drop", pattern="dyn_strobe_drop", glide=0.30, rate=2.8},
    {name="[FX] RGB Shift Circle", pattern="dyn_rgb_circle", glide=0.40, rate=2.5},
    {name="[FX] Gobo & Blur Morph", pattern="dyn_gobo_morph", glide=0.35, rate=2.2}
}

local PRESET_COLOR_SWATCHES = {
    {id="none", name="Default", swatch=Color3.fromRGB(220, 225, 235), r=1, g=1, b=1, cw=0.0},
    {id="red", name="Merah", swatch=Color3.fromRGB(240, 50, 50), r=1, g=0, b=0, cw=0.15},
    {id="green", name="Hijau", swatch=Color3.fromRGB(45, 215, 90), r=0, g=1, b=0, cw=0.30},
    {id="blue", name="Biru", swatch=Color3.fromRGB(50, 120, 250), r=0, g=0, b=1, cw=0.45},
    {id="cyan", name="Cyan", swatch=Color3.fromRGB(40, 225, 235), r=0, g=1, b=1, cw=0.55},
    {id="magenta", name="Ungu/Pink", swatch=Color3.fromRGB(235, 60, 200), r=1, g=0, b=1, cw=0.70},
    {id="yellow", name="Kuning", swatch=Color3.fromRGB(250, 210, 40), r=1, g=0.85, b=0, cw=0.22},
    {id="amber", name="Oranye", swatch=Color3.fromRGB(250, 120, 30), r=1, g=0.38, b=0, cw=0.12},
    {id="uv", name="UV Ungu", swatch=Color3.fromRGB(130, 55, 245), r=0.45, g=0, b=1, cw=0.82},
    {id="rainbow", name="Rainbow", swatch=Color3.fromRGB(255, 140, 220), r=1, g=1, b=1, cw=0.5, isRainbow=true},
    {id="custom", name="RGB Custom", swatch=Color3.fromRGB(46, 168, 255), r=1, g=1, b=1, cw=0.5, isCustom=true}
}

local GOBO_CALIBRATED = {
    {label = "Normal (0.0)", val = 0.0},
    {label = "Putih-Ungu (0.35)", val = 0.35},
    {label = "Putih-Merah (0.62)", val = 0.62},
    {label = "Grid 9-Box (0.91)", val = 0.91}
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
    {name="Prism 9-Dot", color=Color3.fromRGB(90, 185, 215), vals={prism=0.05, gobo=0.35, color=0.35, focus=0.4}},
    {name="Grid 9-Box", color=Color3.fromRGB(215, 75, 95), vals={gobo=0.91, color=0.62, prism=0, focus=0.5}}
}

local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do copy[deepCopy(k)] = deepCopy(v) end
    return copy
end

local function makeFullV(fixtureType, overrides)
    local t = string.lower(tostring(fixtureType or "clara"))
    local base = FIXTURE_DEFAULTS[t] or FIXTURE_DEFAULTS.clara
    local v = deepCopy(base)
    if type(overrides) == "table" then
        for k, val in pairs(overrides) do
            if v[k] ~= nil then v[k] = math.clamp(tonumber(val) or 0, 0, 1) end
        end
    end
    return v
end

local function makeEmptyEffSlot()
    return {
        dty = 0.5, amt = 0, dep = 1, wmir = true, ca = 1, wing = 0, groups = 0,
        useShut = true, target = "dim", block = 1, wax = "x", ph = 0, sval = 0.5,
        dir = ">", phase = 360, on = false, cb = 3, sy = 0.3, sx = 0.3,
        members = {}, soft = 0, shape = "square", unused = true, rate = 0.4
    }
end

local function normalizeEffArray(effArr)
    local out = {}
    if type(effArr) == "table" then
        for i = 1, math.min(6, #effArr) do out[i] = effArr[i] end
    end
    while #out < 6 do table.insert(out, makeEmptyEffSlot()) end
    return out
end

local function advanceUniverseAddress(curU, curA, footprint)
    local u = math.clamp(math.floor(tonumber(curU) or 1), 1, 16)
    local a = math.clamp(math.floor(tonumber(curA) or 1), 1, 512)
    local fp = math.max(1, math.floor(tonumber(footprint) or 16))
    if (a + fp - 1) > 512 then
        if u < 16 then
            u = u + 1; a = 1
        else
            a = math.max(1, 512 - fp + 1)
        end
    end
    local assignedU, assignedA = u, a
    local nextA, nextU = a + fp, u
    if nextA > 512 then
        if nextU < 16 then nextU = nextU + 1; nextA = 1 else nextA = 512 end
    end
    return assignedU, assignedA, nextU, nextA
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
        fix.u = math.clamp(math.floor(tonumber(fix.u) or 1), 1, 16)
        fix.a = math.clamp(math.floor(tonumber(fix.a) or 1), 1, 512)
        fix.x = math.clamp(tonumber(fix.x) or 0.5, 0, 1)
        fix.y = math.clamp(tonumber(fix.y) or 0.5, 0, 1)
        fix.v = makeFullV(fix.t, fix.v)
    end
    data.eff = normalizeEffArray(data.eff)
    data.chase = data.chase or {off = 0, seq = false, dir = ">", scope = "all", glide = 0, rate = 1, steps = {}}
    if type(data.cues) ~= "table" then data.cues = {} end
    return data
end

local function buildAutoPatchedRig(fixtureType, count, startUniv, startAddr, mode, existingRig)
    local newRig = existingRig and deepCopy(existingRig) or {}
    local startIdx = #newRig
    local t = string.lower(tostring(fixtureType or "clara"))
    local fp = FIXTURE_FOOTPRINTS[t] or 16
    local u = math.clamp(math.floor(tonumber(startUniv) or 1), 1, 16)
    local a = math.clamp(math.floor(tonumber(startAddr) or 1), 1, 512)
    local qty = math.clamp(math.floor(tonumber(count) or 8), 1, 64)
    local isMulti = (mode == "multi")
    local rowY = (startIdx == 0) and 0.25 or math.clamp(0.25 + (math.floor(startIdx / 8) * 0.16), 0.15, 0.85)
    for i = 1, qty do
        local posX = (qty == 1) and 0.5 or (0.10 + ((i - 1) * (0.80 / math.max(1, qty - 1))))
        local useU, useA, nextU, nextA = u, a, u, a
        if not isMulti then
            useU, useA, nextU, nextA = advanceUniverseAddress(u, a, fp)
            u, a = nextU, nextA
        end
        table.insert(newRig, {
            u = useU, a = useA,
            x = math.floor(posX * 100 + 0.5) / 100, y = rowY,
            t = t, v = makeFullV(t)
        })
    end
    return newRig
end

local workData = sanitizeWorkStructure({
    v = 3, gm = 100, fade = 0, sg = {}, keys = {},
    eff = normalizeEffArray({}),
    chase = {off = 0, seq = false, dir = ">", scope = "all", glide = 0, rate = 1, steps = {}},
    cues = {},
    rig = buildAutoPatchedRig("clara", 8, 1, 1, "independen", nil)
})

local function loadWorkFile()
    if isfile and readfile and isfile(WORK_FILE) then
        local ok, raw = pcall(readfile, WORK_FILE)
        if ok and type(raw) == "string" and #raw > 0 then
            local ok2, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(decoded) == "table" then
                workData = sanitizeWorkStructure(decoded)
                return true, "LOADED: " .. WORK_FILE
            end
        end
    end
    return false, "DEFAULT RIG READY"
end

local function saveWorkFile()
    if not writefile then return false, "NO WRITEFILE SUPPORT" end
    workData = sanitizeWorkStructure(workData)
    local ok, encoded = pcall(function() return HttpService:JSONEncode(workData) end)
    if not ok then return false, "JSON ENCODE ERROR" end
    local okWrite, err = pcall(writefile, WORK_FILE, string.gsub(encoded, "[\r\n]", ""))
    if not okWrite then return false, tostring(err) end
    return true, "SAVED -> " .. WORK_FILE
end

loadWorkFile()

local state = {
    cueId = "1",
    presetStepsCount = 8,
    stepRate = 2.5,
    stepGlide = 0.35,
    stepDir = ">",
    customSteps = {},
    presetChainMode = "replace",
    presetColorId = "none",
    presetR = 1.0, presetG = 1.0, presetB = 1.0, presetCW = 0.0,
    presetPrismVal = 0.0, presetPrismRot = 0.35,
    presetGoboIdx = 1, presetFocusBlur = false, presetOtherFxOn = false, presetStrobeVal = 0.0,
    curPan = 0.5, curTilt = 0.5, curDim = 1.0, curColor = 0.0, curStrobe = 0.0, curMirror = false,
    previewActive = true, previewView = "top", layoutEditMode = false, activeLayoutNode = 1, canvasHeight = 200,
    editorFixtureType = "clara", staticLayerType = "pos", editorValues = deepCopy(FIXTURE_DEFAULTS.clara),
    rigType = (#workData.rig > 0 and workData.rig[1].t) or "clara",
    rigCount = math.max(1, #workData.rig),
    rigStartUniverse = (#workData.rig > 0 and workData.rig[1].u) or 1,
    rigStartAddr = (#workData.rig > 0 and workData.rig[1].a) or 1,
    rigMode = "independen",
    rigConfigured = false,
    bpm = 120,
    selectedMembers = {},
    wtActive = false, wtMissionIdx = 1, wtStepIdx = 1
}

local function resetSelectionAll()
    state.selectedMembers = {}
    for i = 1, #workData.rig do state.selectedMembers[i] = true end
end
resetSelectionAll()

local function getSelectedMemberIndices()
    local list = {}
    for i = 1, #workData.rig do
        if state.selectedMembers[i] then table.insert(list, i) end
    end
    if #list == 0 and #workData.rig > 0 then table.insert(list, 1) end
    return list
end

local UI = {
    themeBindings = {}, sectionFrames = {}, chipSelectorsList = {},
    pages = {}, tabButtons = {}, tabLangKeys = {}, activeTabKey = "presets",
    targets = {}, fn = {}
}

local function registerTheme(obj, role, prop)
    table.insert(UI.themeBindings, {obj = obj, role = role, prop = prop})
end

local function getCurrentTheme()
    return THEMES[uiPrefs.themeName] or THEMES["RK Console"]
end

local function applyConsoleStyle(guiObj, customRadius)
    local th = getCurrentTheme()
    local st = guiObj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    st.Color = th.stroke
    st.Thickness = th.isBrutal and 2 or uiPrefs.borderThickness
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = guiObj

    local cr = guiObj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, customRadius or th.corner or 6)
    cr.Parent = guiObj
end

pcall(function()
    local b = Instance.new("BlurEffect")
    b.Name = "ApexDMXBlur"
    b.Size = uiPrefs.enableBlur and 8 or 0
    b.Enabled = uiPrefs.enableBlur
    b.Parent = Lighting
    UI.blurEffect = b
end)

local screen = Instance.new("ScreenGui")
screen.Name = "ApexDMXStudio"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = guiParent
UI.screen = screen

local uiScaleObj = Instance.new("UIScale", screen)
uiScaleObj.Scale = uiPrefs.uiScale
UI.uiScaleObj = uiScaleObj

local main = Instance.new("Frame", screen)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.BackgroundTransparency = uiPrefs.bgTransparency
main.BorderSizePixel = 0
main.ZIndex = 2
registerTheme(main, "bg", "BackgroundColor3")
applyConsoleStyle(main, 8)
UI.main = main

local function makeDraggableFrame(handleObj, targetObj, onClickIfNotDragged)
    local dragging, dragInput, dragStart, startPos, moved
    handleObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; dragStart = input.Position; startPos = targetObj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onClickIfNotDragged then onClickIfNotDragged() end
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
            if delta.Magnitude > 5 then moved = true end
            targetObj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + (delta.X / math.max(0.1, uiScaleObj.Scale)),
                startPos.Y.Scale, startPos.Y.Offset + (delta.Y / math.max(0.1, uiScaleObj.Scale))
            )
        end
    end)
end

local function setStatus(msg, isErr)
    if UI.statusLbl then
        UI.statusLbl.Text = string.upper(tostring(msg))
        local th = getCurrentTheme()
        UI.statusLbl.TextColor3 = isErr and Color3.fromRGB(255, 95, 95) or th.headerText
    end
end

local function makeSection(parent, title)
    local box = Instance.new("Frame", parent)
    box.Size = UDim2.new(1, -6, 0, 0)
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.BackgroundTransparency = uiPrefs.bgTransparency
    box.BorderSizePixel = 0
    box.ZIndex = 4
    registerTheme(box, "bg", "BackgroundColor3")
    applyConsoleStyle(box)
    table.insert(UI.sectionFrames, box)

    local pad = Instance.new("UIPadding", box)
    pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8)

    local layout = Instance.new("UIListLayout", box)
    layout.Padding = UDim.new(0, 5); layout.SortOrder = Enum.SortOrder.LayoutOrder

    local hdr = Instance.new("TextLabel", box)
    hdr.Size = UDim2.new(1, 0, 0, 15)
    hdr.BackgroundTransparency = 1
    hdr.Text = string.upper(title)
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 10
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.ZIndex = 5
    registerTheme(hdr, "subInk", "TextColor3")
    return box
end

local function makeSliderRow(parent, labelText, minVal, maxVal, defaultVal, isInt, onChanged)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 23); row.BackgroundTransparency = 1; row.ZIndex = 5

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 134, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd; lbl.ZIndex = 5
    registerTheme(lbl, "ink", "TextColor3")

    local track = Instance.new("TextButton", row)
    track.Size = UDim2.new(1, -192, 0, 10); track.Position = UDim2.new(0, 138, 0.5, -5)
    track.Text = ""; track.AutoButtonColor = false; track.BorderSizePixel = 0; track.ZIndex = 5
    registerTheme(track, "surface", "BackgroundColor3")
    applyConsoleStyle(track, 5)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0); fill.BorderSizePixel = 0; fill.ZIndex = 6
    registerTheme(fill, "accent", "BackgroundColor3")
    local fCr = Instance.new("UICorner", fill); fCr.CornerRadius = UDim.new(0, 5)

    local valBox = Instance.new("TextBox", row)
    valBox.Size = UDim2.new(0, 48, 0, 19); valBox.Position = UDim2.new(1, -48, 0.5, -9)
    valBox.Font = Enum.Font.Code; valBox.TextSize = 10; valBox.ClearTextOnFocus = false
    valBox.BorderSizePixel = 0; valBox.ZIndex = 5
    registerTheme(valBox, "surface", "BackgroundColor3"); registerTheme(valBox, "ink", "TextColor3")
    applyConsoleStyle(valBox, 4)

    local currentVal = defaultVal
    local function applyValue(v, fireCallback)
        v = math.clamp(v, minVal, maxVal)
        v = isInt and math.floor(v + 0.5) or (math.floor((v * 100) + 0.5) / 100)
        currentVal = v
        local alpha = (maxVal > minVal) and ((v - minVal) / (maxVal - minVal)) or 0
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valBox.Text = isInt and tostring(v) or string.format("%.2f", v)
        if fireCallback and onChanged then onChanged(v) end
    end
    applyValue(defaultVal, false)

    local sliding = false
    local function updateFromInput(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        applyValue(minVal + (rel * (maxVal - minVal)), true)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true; updateFromInput(input)
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
        if num then applyValue(num, true) else applyValue(currentVal, false) end
    end)

    return {row = row, label = lbl, setValue = function(v) applyValue(v, false) end, getValue = function() return currentVal end}
end

local function makeChipSelector(parent, labelText, options, initialVal, onSelect)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 0); holder.AutomaticSize = Enum.AutomaticSize.Y; holder.BackgroundTransparency = 1; holder.ZIndex = 5

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, 0, 0, 14); lbl.BackgroundTransparency = 1; lbl.Text = labelText
    lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
    registerTheme(lbl, "subInk", "TextColor3")

    local wrap = Instance.new("Frame", holder)
    wrap.Size = UDim2.new(1, 0, 0, 0); wrap.Position = UDim2.new(0, 0, 0, 16); wrap.AutomaticSize = Enum.AutomaticSize.Y
    wrap.BackgroundTransparency = 1; wrap.ZIndex = 5
    local grid = Instance.new("UIGridLayout", wrap)
    grid.CellSize = UDim2.new(0, 74, 0, 21); grid.CellPadding = UDim2.new(0, 4, 0, 4)

    local chips, current = {}, initialVal
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
        local btn = Instance.new("TextButton", wrap)
        btn.Text = tostring(opt); btn.Font = Enum.Font.GothamBold; btn.TextSize = 10
        btn.BorderSizePixel = 0; btn.ZIndex = 5
        applyConsoleStyle(btn, 5)
        chips[opt] = btn
        btn.MouseButton1Click:Connect(function() refresh(opt); if onSelect then onSelect(opt) end end)
    end
    refresh(initialVal)
    local ctrl = {setSelected = refresh, getSelected = function() return current end, retheme = function() refresh(current) end}
    table.insert(UI.chipSelectorsList, ctrl)
    return ctrl
end

local function makeSmallActionBtn(parent, text, posX, width, roleKey, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, width, 0, 21); b.Position = UDim2.new(0, posX, 0, 0)
    b.Text = string.upper(text); b.Font = Enum.Font.GothamBold; b.TextSize = 9
    b.BorderSizePixel = 0; b.ZIndex = 5
    registerTheme(b, roleKey, "BackgroundColor3")
    if roleKey == "danger" then b.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif roleKey == "surface" or roleKey == "chipBg" then registerTheme(b, "ink", "TextColor3")
    else registerTheme(b, "btnText", "TextColor3") end
    applyConsoleStyle(b, 5)
    b.MouseButton1Click:Connect(callback)
    return b
end

do
    local bubbleBtn = Instance.new("TextButton", screen)
    bubbleBtn.Name = "FloatingBubble"
    bubbleBtn.Size = UDim2.new(0, uiPrefs.bubbleSize, 0, uiPrefs.bubbleSize)
    bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
    bubbleBtn.Text = "RK512"; bubbleBtn.Font = Enum.Font.GothamBlack; bubbleBtn.TextSize = 10
    bubbleBtn.BorderSizePixel = 0; bubbleBtn.Visible = false; bubbleBtn.ZIndex = 20
    registerTheme(bubbleBtn, "accent", "BackgroundColor3"); registerTheme(bubbleBtn, "btnText", "TextColor3")
    applyConsoleStyle(bubbleBtn, 24)
    UI.bubbleBtn = bubbleBtn

    makeDraggableFrame(bubbleBtn, bubbleBtn, function()
        bubbleBtn.Visible = false; main.Visible = true
        if UI.blurEffect then UI.blurEffect.Enabled = uiPrefs.enableBlur end
    end)

    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 30)
    topBar.BackgroundTransparency = math.clamp(uiPrefs.bgTransparency * 0.4, 0, 0.4)
    topBar.BorderSizePixel = 0; topBar.ZIndex = 3
    registerTheme(topBar, "header", "BackgroundColor3")
    applyConsoleStyle(topBar, 8)
    UI.topBar = topBar
    makeDraggableFrame(topBar, main, nil)

    local titleLbl = Instance.new("TextLabel", topBar)
    titleLbl.Size = UDim2.new(0, 145, 1, 0); titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = "APEX CONSOLE // RK-512"
    titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 11; titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 4
    registerTheme(titleLbl, "headerText", "TextColor3")

    local guideTopBtn = Instance.new("TextButton", topBar)
    guideTopBtn.Size = UDim2.new(0, 76, 0, 20); guideTopBtn.Position = UDim2.new(0, 158, 0, 5)
    guideTopBtn.Text = tr("btn_guide"); guideTopBtn.Font = Enum.Font.GothamBold; guideTopBtn.TextSize = 9
    guideTopBtn.BorderSizePixel = 0; guideTopBtn.ZIndex = 4
    registerTheme(guideTopBtn, "secondary", "BackgroundColor3"); registerTheme(guideTopBtn, "btnText", "TextColor3")
    applyConsoleStyle(guideTopBtn, 5)
    UI.guideTopBtn = guideTopBtn

    local statusLbl = Instance.new("TextLabel", topBar)
    statusLbl.Size = UDim2.new(1, -298, 1, 0); statusLbl.Position = UDim2.new(0, 238, 0, 0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "READY"
    statusLbl.Font = Enum.Font.Code; statusLbl.TextSize = 9; statusLbl.TextXAlignment = Enum.TextXAlignment.Right
    statusLbl.TextTruncate = Enum.TextTruncate.AtEnd; statusLbl.ZIndex = 4
    registerTheme(statusLbl, "headerText", "TextColor3")
    UI.statusLbl = statusLbl

    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Size = UDim2.new(0, 24, 0, 20); minBtn.Position = UDim2.new(1, -56, 0, 5)
    minBtn.Text = "_"; minBtn.Font = Enum.Font.GothamBold; minBtn.TextSize = 12; minBtn.BorderSizePixel = 0; minBtn.ZIndex = 4
    registerTheme(minBtn, "surface", "BackgroundColor3"); registerTheme(minBtn, "ink", "TextColor3")
    applyConsoleStyle(minBtn, 5)

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 24, 0, 20); closeBtn.Position = UDim2.new(1, -28, 0, 5)
    closeBtn.Text = "X"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 11
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.BorderSizePixel = 0; closeBtn.ZIndex = 4
    registerTheme(closeBtn, "danger", "BackgroundColor3")
    applyConsoleStyle(closeBtn, 5)

    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false; bubbleBtn.Visible = true
        if UI.blurEffect then UI.blurEffect.Enabled = false end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        state.previewActive = false; state.wtActive = false
        if UI.blurEffect then UI.blurEffect:Destroy() end
        screen:Destroy()
    end)

    local body = Instance.new("Frame", main)
    body.Size = UDim2.new(1, 0, 1, -30); body.Position = UDim2.new(0, 0, 0, 30)
    body.BackgroundTransparency = 1; body.ClipsDescendants = true; body.ZIndex = 3

    local navBar = Instance.new("ScrollingFrame", body)
    navBar.Size = UDim2.new(1, -16, 0, 28); navBar.Position = UDim2.new(0, 8, 0, 5)
    navBar.BackgroundTransparency = uiPrefs.bgTransparency; navBar.BorderSizePixel = 0; navBar.ScrollBarThickness = 0
    navBar.ScrollingDirection = Enum.ScrollingDirection.X; navBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    navBar.CanvasSize = UDim2.new(0, 0, 0, 0); navBar.ZIndex = 3
    registerTheme(navBar, "surface", "BackgroundColor3")
    applyConsoleStyle(navBar, 6)
    UI.navBar = navBar

    local navLayout = Instance.new("UIListLayout", navBar)
    navLayout.FillDirection = Enum.FillDirection.Horizontal; navLayout.Padding = UDim.new(0, 4); navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local navPad = Instance.new("UIPadding", navBar); navPad.PaddingLeft = UDim.new(0, 4); navPad.PaddingRight = UDim.new(0, 4)

    local contentArea = Instance.new("Frame", body)
    contentArea.Size = UDim2.new(1, -16, 1, -96); contentArea.Position = UDim2.new(0, 8, 0, 37)
    contentArea.BackgroundTransparency = uiPrefs.bgTransparency; contentArea.BorderSizePixel = 0; contentArea.ZIndex = 3
    registerTheme(contentArea, "surface", "BackgroundColor3")
    applyConsoleStyle(contentArea, 6)
    UI.contentArea = contentArea

    local hintBanner = Instance.new("Frame", body)
    hintBanner.Size = UDim2.new(1, -16, 0, 20); hintBanner.Position = UDim2.new(0, 8, 1, -56)
    hintBanner.BackgroundTransparency = uiPrefs.bgTransparency; hintBanner.BorderSizePixel = 0; hintBanner.ZIndex = 3
    registerTheme(hintBanner, "chipBg", "BackgroundColor3")
    applyConsoleStyle(hintBanner, 5)
    UI.hintBanner = hintBanner

    local hintTextLbl = Instance.new("TextLabel", hintBanner)
    hintTextLbl.Size = UDim2.new(1, -78, 1, 0); hintTextLbl.Position = UDim2.new(0, 6, 0, 0)
    hintTextLbl.BackgroundTransparency = 1; hintTextLbl.Text = tr("hint_empty")
    hintTextLbl.Font = Enum.Font.Code; hintTextLbl.TextSize = 8; hintTextLbl.TextXAlignment = Enum.TextXAlignment.Left
    hintTextLbl.TextTruncate = Enum.TextTruncate.AtEnd; hintTextLbl.ZIndex = 4
    registerTheme(hintTextLbl, "ink", "TextColor3")
    UI.hintTextLbl = hintTextLbl

    local hintOpenGuideBtn = Instance.new("TextButton", hintBanner)
    hintOpenGuideBtn.Size = UDim2.new(0, 68, 0, 16); hintOpenGuideBtn.Position = UDim2.new(1, -70, 0.5, -8)
    hintOpenGuideBtn.Text = "TUTORIAL"; hintOpenGuideBtn.Font = Enum.Font.GothamBold; hintOpenGuideBtn.TextSize = 8
    hintOpenGuideBtn.BorderSizePixel = 0; hintOpenGuideBtn.ZIndex = 4
    registerTheme(hintOpenGuideBtn, "accent", "BackgroundColor3"); registerTheme(hintOpenGuideBtn, "btnText", "TextColor3")
    applyConsoleStyle(hintOpenGuideBtn, 4)
    UI.hintOpenGuideBtn = hintOpenGuideBtn

    local footerBar = Instance.new("Frame", body)
    footerBar.Size = UDim2.new(1, -16, 0, 30); footerBar.Position = UDim2.new(0, 8, 1, -33)
    footerBar.BackgroundTransparency = uiPrefs.bgTransparency; footerBar.BorderSizePixel = 0; footerBar.ZIndex = 3
    registerTheme(footerBar, "surface", "BackgroundColor3")
    applyConsoleStyle(footerBar, 6)
    UI.footerBar = footerBar
    makeDraggableFrame(footerBar, main, nil)
end

UI.fn.refreshSmartHint = function()
    if state.layoutEditMode then UI.hintTextLbl.Text = tr("hint_edit")
    elseif #state.customSteps == 0 then UI.hintTextLbl.Text = tr("hint_empty")
    else UI.hintTextLbl.Text = tr("hint_ready") end
end

UI.fn.refreshTabStyles = function()
    local th = getCurrentTheme()
    for k, btn in pairs(UI.tabButtons) do
        local isAct = (k == UI.activeTabKey)
        btn.BackgroundColor3 = isAct and th.accent or th.chipBg
        btn.TextColor3 = isAct and th.btnText or th.ink
        if UI.tabLangKeys[k] then btn.Text = string.upper(tr(UI.tabLangKeys[k])) end
    end
end

UI.fn.switchTab = function(tabKey)
    UI.activeTabKey = tabKey
    for k, page in pairs(UI.pages) do page.Visible = (k == tabKey) end
    UI.fn.refreshTabStyles()
end

local function createTab(key, langKey, width)
    local btn = Instance.new("TextButton", UI.navBar)
    btn.Size = UDim2.new(0, width or 84, 0, 20); btn.Text = string.upper(tr(langKey))
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.BorderSizePixel = 0; btn.ZIndex = 4
    applyConsoleStyle(btn, 5)

    local scroll = Instance.new("ScrollingFrame", UI.contentArea)
    scroll.Size = UDim2.new(1, -8, 1, -8); scroll.Position = UDim2.new(0, 4, 0, 4)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible = false; scroll.ZIndex = 4

    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 6); list.SortOrder = Enum.SortOrder.LayoutOrder

    UI.pages[key] = scroll; UI.tabButtons[key] = btn; UI.tabLangKeys[key] = langKey
    btn.MouseButton1Click:Connect(function() UI.fn.switchTab(key) end)
    return scroll
end

local pagePresets = createTab("presets", "tab_preset", 84)
local pageCustom = createTab("custom", "tab_custom", 86)
local pagePreview = createTab("preview", "tab_preview", 88)
local pageStatic = createTab("static", "tab_static", 84)
local pageRig = createTab("rig", "tab_rig", 76)
local pageCues = createTab("cues", "tab_cue", 82)
local pageSettings = createTab("settings", "tab_settings", 76)

do
    local missionPickerOverlay = Instance.new("Frame", main)
    missionPickerOverlay.Size = UDim2.new(1, 0, 1, 0)
    missionPickerOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0); missionPickerOverlay.BackgroundTransparency = 0.42
    missionPickerOverlay.BorderSizePixel = 0; missionPickerOverlay.Visible = false; missionPickerOverlay.ZIndex = 45

    local pickerBox = Instance.new("Frame", missionPickerOverlay)
    pickerBox.Size = UDim2.new(0.88, 0, 0.84, 0); pickerBox.Position = UDim2.new(0.06, 0, 0.08, 0)
    pickerBox.BorderSizePixel = 0; pickerBox.ZIndex = 46
    registerTheme(pickerBox, "bg", "BackgroundColor3")
    applyConsoleStyle(pickerBox, 8)

    local pickerHdr = Instance.new("Frame", pickerBox)
    pickerHdr.Size = UDim2.new(1, 0, 0, 28); pickerHdr.BorderSizePixel = 0; pickerHdr.ZIndex = 47
    registerTheme(pickerHdr, "header", "BackgroundColor3")
    applyConsoleStyle(pickerHdr, 8)

    local pickerTitle = Instance.new("TextLabel", pickerHdr)
    pickerTitle.Size = UDim2.new(1, -38, 1, 0); pickerTitle.Position = UDim2.new(0, 8, 0, 0)
    pickerTitle.BackgroundTransparency = 1; pickerTitle.Text = "PANDUAN INTERAKTIF & DOKUMENTASI UNIVERSE DMX"
    pickerTitle.Font = Enum.Font.GothamBold; pickerTitle.TextSize = 10; pickerTitle.TextXAlignment = Enum.TextXAlignment.Left; pickerTitle.ZIndex = 48
    registerTheme(pickerTitle, "headerText", "TextColor3")

    local pickerClose = Instance.new("TextButton", pickerHdr)
    pickerClose.Size = UDim2.new(0, 24, 0, 20); pickerClose.Position = UDim2.new(1, -28, 0, 4)
    pickerClose.Text = "X"; pickerClose.Font = Enum.Font.GothamBold; pickerClose.TextSize = 11
    pickerClose.TextColor3 = Color3.fromRGB(255, 255, 255); pickerClose.BorderSizePixel = 0; pickerClose.ZIndex = 48
    registerTheme(pickerClose, "danger", "BackgroundColor3")
    applyConsoleStyle(pickerClose, 5)

    local pickerScroll = Instance.new("ScrollingFrame", pickerBox)
    pickerScroll.Size = UDim2.new(1, -12, 1, -36); pickerScroll.Position = UDim2.new(0, 6, 0, 32)
    pickerScroll.BackgroundTransparency = 1; pickerScroll.BorderSizePixel = 0; pickerScroll.ScrollBarThickness = 4
    pickerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; pickerScroll.CanvasSize = UDim2.new(0, 0, 0, 0); pickerScroll.ZIndex = 47
    local pickerLay = Instance.new("UIListLayout", pickerScroll); pickerLay.Padding = UDim.new(0, 6)

    local spotBox = Instance.new("Frame", screen)
    spotBox.Name = "TutorialSpotlight"; spotBox.BackgroundTransparency = 1; spotBox.Visible = false; spotBox.ZIndex = 60
    local spotStroke = Instance.new("UIStroke", spotBox); spotStroke.Color = Color3.fromRGB(255, 214, 0); spotStroke.Thickness = 3
    local spotCorner = Instance.new("UICorner", spotBox); spotCorner.CornerRadius = UDim.new(0, 6)

    local spotArrow = Instance.new("TextLabel", spotBox)
    spotArrow.Size = UDim2.new(0, 96, 0, 18); spotArrow.Position = UDim2.new(0.5, -48, 0, -20)
    spotArrow.BackgroundColor3 = Color3.fromRGB(255, 214, 0); spotArrow.Text = "▼ LIHAT DI SINI ▼"
    spotArrow.Font = Enum.Font.GothamBold; spotArrow.TextSize = 8; spotArrow.TextColor3 = Color3.fromRGB(12, 12, 12)
    spotArrow.BorderSizePixel = 0; spotArrow.ZIndex = 61
    applyConsoleStyle(spotArrow, 4)

    local dialogCard = Instance.new("Frame", screen)
    dialogCard.Name = "TutorialDialog"; dialogCard.AnchorPoint = Vector2.new(0.5, 0)
    dialogCard.Size = UDim2.new(0, 350, 0, 112); dialogCard.Position = UDim2.new(0.5, 0, 0.04, 0)
    dialogCard.BorderSizePixel = 0; dialogCard.Visible = false; dialogCard.ZIndex = 65
    registerTheme(dialogCard, "bg", "BackgroundColor3")
    applyConsoleStyle(dialogCard, 8)

    local dlgHdr = Instance.new("Frame", dialogCard)
    dlgHdr.Size = UDim2.new(1, 0, 0, 22); dlgHdr.BorderSizePixel = 0; dlgHdr.ZIndex = 66
    registerTheme(dlgHdr, "secondary", "BackgroundColor3")
    applyConsoleStyle(dlgHdr, 8)

    local dlgStepLbl = Instance.new("TextLabel", dlgHdr)
    dlgStepLbl.Size = UDim2.new(1, -12, 1, 0); dlgStepLbl.Position = UDim2.new(0, 6, 0, 0)
    dlgStepLbl.BackgroundTransparency = 1; dlgStepLbl.Text = "TUTORIAL (1/5)"
    dlgStepLbl.Font = Enum.Font.GothamBold; dlgStepLbl.TextSize = 9; dlgStepLbl.TextXAlignment = Enum.TextXAlignment.Left; dlgStepLbl.ZIndex = 67
    registerTheme(dlgStepLbl, "btnText", "TextColor3")

    local dlgBodyTxt = Instance.new("TextLabel", dialogCard)
    dlgBodyTxt.Size = UDim2.new(1, -16, 0, 52); dlgBodyTxt.Position = UDim2.new(0, 8, 0, 25)
    dlgBodyTxt.BackgroundTransparency = 1; dlgBodyTxt.Text = ""
    dlgBodyTxt.Font = Enum.Font.GothamMedium; dlgBodyTxt.TextSize = 10; dlgBodyTxt.TextWrapped = true
    dlgBodyTxt.TextXAlignment = Enum.TextXAlignment.Left; dlgBodyTxt.TextYAlignment = Enum.TextYAlignment.Top; dlgBodyTxt.ZIndex = 66
    registerTheme(dlgBodyTxt, "ink", "TextColor3")

    local dlgFoot = Instance.new("Frame", dialogCard)
    dlgFoot.Size = UDim2.new(1, -16, 0, 22); dlgFoot.Position = UDim2.new(0, 8, 1, -28); dlgFoot.BackgroundTransparency = 1; dlgFoot.ZIndex = 66

    local btnWtSkip = makeSmallActionBtn(dlgFoot, "LEWATI TUTORIAL", 0, 108, "danger", function()
        state.wtActive = false; spotBox.Visible = false; dialogCard.Visible = false; setStatus("TUTORIAL DILEWATI", false)
    end)
    btnWtSkip.ZIndex = 67

    local btnWtPrev = makeSmallActionBtn(dlgFoot, "◄ KEMBALI", 156, 76, "surface", function()
        if state.wtStepIdx > 1 then state.wtStepIdx = state.wtStepIdx - 1; UI.fn.updateWalkthroughStep() end
    end)
    btnWtPrev.ZIndex = 67

    local btnWtNext = makeSmallActionBtn(dlgFoot, "LANJUT ►", 238, 96, "accent", function()
        local mission = WALKTHROUGH_MISSIONS[state.wtMissionIdx]
        if mission and state.wtStepIdx < #mission.steps then
            state.wtStepIdx = state.wtStepIdx + 1; UI.fn.updateWalkthroughStep()
        else
            state.wtActive = false; spotBox.Visible = false; dialogCard.Visible = false; setStatus("TUTORIAL SELESAI!", false)
        end
    end)
    btnWtNext.ZIndex = 67

    UI.fn.updateWalkthroughStep = function()
        local mission = WALKTHROUGH_MISSIONS[state.wtMissionIdx]
        if not mission then return end
        local stepData = mission.steps[state.wtStepIdx]
        if not stepData then return end

        state.wtActive = true; missionPickerOverlay.Visible = false; dialogCard.Visible = true; spotBox.Visible = true
        if stepData.tab and UI.fn.switchTab then UI.fn.switchTab(stepData.tab) end

        local targetObj = UI.targets[stepData.target]
        if targetObj and targetObj:IsA("GuiObject") then
            local scrollParent = targetObj:FindFirstAncestorOfClass("ScrollingFrame")
            if scrollParent then
                local relY = targetObj.AbsolutePosition.Y - scrollParent.AbsolutePosition.Y + scrollParent.CanvasPosition.Y
                scrollParent.CanvasPosition = Vector2.new(0, math.max(0, relY - 10))
            end
        end

        dlgStepLbl.Text = mission.title .. "  [" .. state.wtStepIdx .. "/" .. #mission.steps .. "]"
        dlgBodyTxt.Text = stepData.text
        btnWtPrev.Visible = (state.wtStepIdx > 1)
        btnWtNext.Text = (state.wtStepIdx < #mission.steps) and "LANJUT ►" or "SELESAI ✓"
    end

    RunService.RenderStepped:Connect(function()
        if not state.wtActive or not main.Visible then spotBox.Visible = false; return end
        local mission = WALKTHROUGH_MISSIONS[state.wtMissionIdx]
        local stepData = mission and mission.steps[state.wtStepIdx]
        local targetObj = stepData and UI.targets[stepData.target]
        if targetObj and targetObj:IsA("GuiObject") and targetObj.Visible then
            local sc = math.max(0.1, uiScaleObj.Scale)
            local pos = targetObj.AbsolutePosition / sc
            local sz = targetObj.AbsoluteSize / sc
            spotBox.Visible = true
            spotBox.Position = UDim2.new(0, pos.X - 3, 0, pos.Y - 3)
            spotBox.Size = UDim2.new(0, sz.X + 6, 0, sz.Y + 6)
            local pulse = 0.5 + 0.5 * math.sin(os.clock() * 8)
            spotStroke.Color = Color3.fromRGB(255, math.floor(180 + pulse * 75), 0)
            dialogCard.Position = (pos.Y < 135) and UDim2.new(0.5, 0, 0.72, 0) or UDim2.new(0.5, 0, 0.04, 0)
        else
            spotBox.Visible = false
        end
    end)

    for mIdx, mData in ipairs(WALKTHROUGH_MISSIONS) do
        local mCard = Instance.new("Frame", pickerScroll)
        mCard.Size = UDim2.new(1, -6, 0, 48); mCard.BorderSizePixel = 0; mCard.ZIndex = 48
        registerTheme(mCard, "surface", "BackgroundColor3")
        applyConsoleStyle(mCard, 6)

        local mTitle = Instance.new("TextLabel", mCard)
        mTitle.Size = UDim2.new(1, -96, 0, 18); mTitle.Position = UDim2.new(0, 8, 0, 4)
        mTitle.BackgroundTransparency = 1; mTitle.Text = mData.title
        mTitle.Font = Enum.Font.GothamBold; mTitle.TextSize = 10; mTitle.TextXAlignment = Enum.TextXAlignment.Left; mTitle.ZIndex = 49
        registerTheme(mTitle, "accent", "TextColor3")

        local mDesc = Instance.new("TextLabel", mCard)
        mDesc.Size = UDim2.new(1, -96, 0, 22); mDesc.Position = UDim2.new(0, 8, 0, 22)
        mDesc.BackgroundTransparency = 1; mDesc.Text = mData.desc
        mDesc.Font = Enum.Font.Gotham; mDesc.TextSize = 8; mDesc.TextWrapped = true
        mDesc.TextXAlignment = Enum.TextXAlignment.Left; mDesc.ZIndex = 49
        registerTheme(mDesc, "ink", "TextColor3")

        local startBtn = makeSmallActionBtn(mCard, "MULAI ►", 0, 80, "accent", function()
            state.wtMissionIdx = mIdx; state.wtStepIdx = 1; UI.fn.updateWalkthroughStep()
        end)
        startBtn.Position = UDim2.new(1, -86, 0.5, -10); startBtn.ZIndex = 49
    end

    local docCard = Instance.new("Frame", pickerScroll)
    docCard.Size = UDim2.new(1, -6, 0, 0); docCard.AutomaticSize = Enum.AutomaticSize.Y; docCard.BorderSizePixel = 0; docCard.ZIndex = 48
    registerTheme(docCard, "chipBg", "BackgroundColor3")
    applyConsoleStyle(docCard, 6)
    local dPad = Instance.new("UIPadding", docCard); dPad.PaddingTop = UDim.new(0, 6); dPad.PaddingBottom = UDim.new(0, 6); dPad.PaddingLeft = UDim.new(0, 8); dPad.PaddingRight = UDim.new(0, 8)
    local dTxt = Instance.new("TextLabel", docCard)
    dTxt.Size = UDim2.new(1, 0, 0, 0); dTxt.AutomaticSize = Enum.AutomaticSize.Y; dTxt.BackgroundTransparency = 1
    dTxt.Text = DMX_DOC_SUMMARY; dTxt.Font = Enum.Font.Gotham; dTxt.TextSize = 8; dTxt.TextWrapped = true
    dTxt.TextXAlignment = Enum.TextXAlignment.Left; dTxt.ZIndex = 49
    registerTheme(dTxt, "subInk", "TextColor3")

    UI.guideTopBtn.MouseButton1Click:Connect(function() missionPickerOverlay.Visible = not missionPickerOverlay.Visible end)
    UI.hintOpenGuideBtn.MouseButton1Click:Connect(function() missionPickerOverlay.Visible = true end)
    pickerClose.MouseButton1Click:Connect(function() missionPickerOverlay.Visible = false end)
end

do
    local rigModalOverlay = Instance.new("Frame", main)
    rigModalOverlay.Size = UDim2.new(1, 0, 1, 0); rigModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    rigModalOverlay.BackgroundTransparency = 0.45; rigModalOverlay.BorderSizePixel = 0; rigModalOverlay.Visible = false; rigModalOverlay.ZIndex = 30

    local rigModalBox = Instance.new("Frame", rigModalOverlay)
    rigModalBox.Size = UDim2.new(0.88, 0, 0.84, 0); rigModalBox.Position = UDim2.new(0.06, 0, 0.08, 0)
    rigModalBox.BorderSizePixel = 0; rigModalBox.ZIndex = 31
    registerTheme(rigModalBox, "bg", "BackgroundColor3")
    applyConsoleStyle(rigModalBox, 8)

    local rigModalHeader = Instance.new("Frame", rigModalBox)
    rigModalHeader.Size = UDim2.new(1, 0, 0, 28); rigModalHeader.BorderSizePixel = 0; rigModalHeader.ZIndex = 32
    registerTheme(rigModalHeader, "header", "BackgroundColor3")
    applyConsoleStyle(rigModalHeader, 8)

    local rigModalTitle = Instance.new("TextLabel", rigModalHeader)
    rigModalTitle.Size = UDim2.new(1, -38, 1, 0); rigModalTitle.Position = UDim2.new(0, 8, 0, 0)
    rigModalTitle.BackgroundTransparency = 1; rigModalTitle.Text = "SETUP UNIVERSE (1-16) & ADDRESS DMX (1-512)"
    rigModalTitle.Font = Enum.Font.GothamBold; rigModalTitle.TextSize = 10; rigModalTitle.TextXAlignment = Enum.TextXAlignment.Left; rigModalTitle.ZIndex = 33
    registerTheme(rigModalTitle, "headerText", "TextColor3")

    local rigModalCloseBtn = Instance.new("TextButton", rigModalHeader)
    rigModalCloseBtn.Size = UDim2.new(0, 24, 0, 20); rigModalCloseBtn.Position = UDim2.new(1, -28, 0, 4)
    rigModalCloseBtn.Text = "X"; rigModalCloseBtn.Font = Enum.Font.GothamBold; rigModalCloseBtn.TextSize = 11
    rigModalCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rigModalCloseBtn.BorderSizePixel = 0; rigModalCloseBtn.ZIndex = 34
    registerTheme(rigModalCloseBtn, "danger", "BackgroundColor3")
    applyConsoleStyle(rigModalCloseBtn, 5)

    local rigModalScroll = Instance.new("ScrollingFrame", rigModalBox)
    rigModalScroll.Size = UDim2.new(1, -12, 1, -68); rigModalScroll.Position = UDim2.new(0, 6, 0, 32)
    rigModalScroll.BackgroundTransparency = 1; rigModalScroll.BorderSizePixel = 0; rigModalScroll.ScrollBarThickness = 4
    rigModalScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; rigModalScroll.CanvasSize = UDim2.new(0, 0, 0, 0); rigModalScroll.ZIndex = 32
    local rigModalList = Instance.new("UIListLayout", rigModalScroll); rigModalList.Padding = UDim.new(0, 6)

    local pendingAfterRigCallback = nil
    rigModalCloseBtn.MouseButton1Click:Connect(function() rigModalOverlay.Visible = false; pendingAfterRigCallback = nil; setStatus("SETUP DMX DITUTUP", false) end)

    local modalChipFix = makeChipSelector(rigModalScroll, "1. Pilih Tipe Lampu:", {
        "clara", "strobe", "mapple", "parled", "fogger", "blinder",
        "flower", "pixel", "retro", "wall", "windmill", "sbar"
    }, state.rigType, function(v) state.rigType = v end)
    local modalSldCount = makeSliderRow(rigModalScroll, "2. Jumlah Unit (32+ Auto U2)", 1, 64, state.rigCount, true, function(v) state.rigCount = v end)
    local modalSldUniv = makeSliderRow(rigModalScroll, "3. Universe Awal (1 - 16)", 1, 16, state.rigStartUniverse, true, function(v) state.rigStartUniverse = v end)
    local modalSldStart = makeSliderRow(rigModalScroll, "4. Address DMX Awal (1-512)", 1, 512, state.rigStartAddr, true, function(v) state.rigStartAddr = v end)
    local modalChipMode = makeChipSelector(rigModalScroll, "5. Mode Address:", {"independen", "multi"}, state.rigMode, function(v) state.rigMode = v end)

    for _, desc in ipairs(rigModalScroll:GetDescendants()) do
        if desc:IsA("GuiObject") then desc.ZIndex = math.max(33, desc.ZIndex + 28) end
    end

    local modalFoot = Instance.new("Frame", rigModalBox)
    modalFoot.Size = UDim2.new(1, -12, 0, 28); modalFoot.Position = UDim2.new(0, 6, 1, -32); modalFoot.BackgroundTransparency = 1; modalFoot.ZIndex = 32

    local modalConfirmBtn = Instance.new("TextButton", modalFoot)
    modalConfirmBtn.Size = UDim2.new(0.54, 0, 0, 24); modalConfirmBtn.Position = UDim2.new(0, 0, 0, 2)
    modalConfirmBtn.Text = "TERAPKAN DMX & LANJUT"; modalConfirmBtn.Font = Enum.Font.GothamBold; modalConfirmBtn.TextSize = 9; modalConfirmBtn.BorderSizePixel = 0; modalConfirmBtn.ZIndex = 33
    registerTheme(modalConfirmBtn, "accent", "BackgroundColor3"); registerTheme(modalConfirmBtn, "btnText", "TextColor3")
    applyConsoleStyle(modalConfirmBtn, 5)

    local modalSkipBtn = Instance.new("TextButton", modalFoot)
    modalSkipBtn.Size = UDim2.new(0.28, 0, 0, 24); modalSkipBtn.Position = UDim2.new(0.56, 0, 0, 2)
    modalSkipBtn.Text = "PAKAI SAAT INI"; modalSkipBtn.Font = Enum.Font.GothamBold; modalSkipBtn.TextSize = 9; modalSkipBtn.BorderSizePixel = 0; modalSkipBtn.ZIndex = 33
    registerTheme(modalSkipBtn, "surface", "BackgroundColor3"); registerTheme(modalSkipBtn, "ink", "TextColor3")
    applyConsoleStyle(modalSkipBtn, 5)

    local modalExitBtn = Instance.new("TextButton", modalFoot)
    modalExitBtn.Size = UDim2.new(0.14, 0, 0, 24); modalExitBtn.Position = UDim2.new(0.86, 0, 0, 2)
    modalExitBtn.Text = "KELUAR"; modalExitBtn.Font = Enum.Font.GothamBold; modalExitBtn.TextSize = 9; modalExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255); modalExitBtn.BorderSizePixel = 0; modalExitBtn.ZIndex = 33
    registerTheme(modalExitBtn, "danger", "BackgroundColor3")
    applyConsoleStyle(modalExitBtn, 5)

    modalConfirmBtn.MouseButton1Click:Connect(function()
        workData.rig = buildAutoPatchedRig(state.rigType, state.rigCount, state.rigStartUniverse, state.rigStartAddr, state.rigMode, nil)
        state.rigConfigured = true
        resetSelectionAll()
        rigModalOverlay.Visible = false
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
        if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
        local cb = pendingAfterRigCallback; pendingAfterRigCallback = nil
        if cb then cb() else setStatus("DMX SET: " .. state.rigCount .. "X " .. string.upper(state.rigType), false) end
    end)
    modalSkipBtn.MouseButton1Click:Connect(function()
        state.rigConfigured = true; rigModalOverlay.Visible = false
        local cb = pendingAfterRigCallback; pendingAfterRigCallback = nil
        if cb then cb() end
    end)
    modalExitBtn.MouseButton1Click:Connect(function()
        rigModalOverlay.Visible = false; pendingAfterRigCallback = nil; setStatus("BATAL SETUP DMX", false)
    end)

    UI.fn.openRigSetupModal = function(onDoneCallback)
        pendingAfterRigCallback = onDoneCallback
        modalChipFix.setSelected(state.rigType)
        modalSldCount.setValue(state.rigCount)
        modalSldUniv.setValue(state.rigStartUniverse)
        modalSldStart.setValue(state.rigStartAddr)
        modalChipMode.setSelected(state.rigMode)
        rigModalOverlay.Visible = true
    end
end

UI.fn.executeWithRigCheck = function(cueKey, actionFn)
    local isNewCue = (workData.cues[cueKey] == nil)
    if uiPrefs.promptRigOnNewCue and isNewCue and not state.rigConfigured then
        UI.fn.openRigSetupModal(actionFn)
    else
        actionFn()
    end
end

UI.fn.saveCurrentStepsToCue = function(cueKey)
    if #state.customSteps == 0 then
        setStatus("BELUM ADA STEP! PILIH PRESET ATAU REKAM STEP DULU", true)
        return
    end
    UI.fn.executeWithRigCheck(cueKey, function()
        workData.cues[cueKey] = {
            layer = "chs", fx = {}, eff = {},
            chase = {
                glide = state.stepGlide, dir = state.stepDir, seq = false, off = 0,
                rate = state.stepRate, steps = deepCopy(state.customSteps)
            }
        }
        if uiPrefs.autoSaveOnSaveCue then saveWorkFile() end
        if UI.fn.refreshCueGridUI then UI.fn.refreshCueGridUI() end
        UI.fn.refreshSmartHint()
        setStatus("TERSIMPAN KE CUE " .. cueKey .. " (" .. #state.customSteps .. " STEP)", false)
    end)
end

do
    local secMembers = makeSection(pagePresets, "1. PILIH KELOMPOK LAMPU TARGET & TAP TEMPO BPM")
    UI.targets["preset_members"] = secMembers

    local memberToolsRow = Instance.new("Frame", secMembers)
    memberToolsRow.Size = UDim2.new(1, 0, 0, 21); memberToolsRow.BackgroundTransparency = 1; memberToolsRow.ZIndex = 5

    makeSmallActionBtn(memberToolsRow, "Semua", 0, 48, "accent", function()
        for i = 1, #workData.rig do state.selectedMembers[i] = true end
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
    end)
    makeSmallActionBtn(memberToolsRow, "Ganjil", 52, 48, "surface", function()
        for i = 1, #workData.rig do state.selectedMembers[i] = (i % 2 == 1) end
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
    end)
    makeSmallActionBtn(memberToolsRow, "Genap", 104, 48, "surface", function()
        for i = 1, #workData.rig do state.selectedMembers[i] = (i % 2 == 0) end
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
    end)
    makeSmallActionBtn(memberToolsRow, "Setup DMX", 156, 74, "secondary", function()
        UI.fn.openRigSetupModal(function() setStatus("DMX RIG: " .. #workData.rig .. " UNIT", false) end)
    end)

    local tapTimes = {}
    local tapTempoBtn = makeSmallActionBtn(memberToolsRow, "TAP BPM: 120", 234, 96, "accent", function()
        local now = os.clock()
        if #tapTimes > 0 and (now - tapTimes[#tapTimes]) > 2.0 then tapTimes = {} end
        table.insert(tapTimes, now)
        if #tapTimes > 6 then table.remove(tapTimes, 1) end
        if #tapTimes >= 2 then
            local sum = 0
            for i = 2, #tapTimes do sum = sum + (tapTimes[i] - tapTimes[i - 1]) end
            local bpm = math.clamp(math.floor((60 / math.max(0.15, sum / (#tapTimes - 1))) + 0.5), 40, 240)
            local chsRate = math.clamp(math.floor((bpm / 60) * 100 + 0.5) / 100, 0.2, 10.0)
            state.bpm = bpm; state.stepRate = chsRate
            if UI.sldPresetRate then UI.sldPresetRate.setValue(chsRate) end
            setStatus("SYNC " .. bpm .. " BPM | STEP RATE: " .. string.format("%.2f", chsRate), false)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if tapTempoBtn and tapTempoBtn.Parent then tapTempoBtn.Text = "TAP BPM: " .. tostring(state.bpm) end
    end)

    local memberGridHolder = Instance.new("Frame", secMembers)
    memberGridHolder.Size = UDim2.new(1, 0, 0, 0); memberGridHolder.AutomaticSize = Enum.AutomaticSize.Y; memberGridHolder.BackgroundTransparency = 1; memberGridHolder.ZIndex = 5
    local memberGrid = Instance.new("UIGridLayout", memberGridHolder)
    memberGrid.CellSize = UDim2.new(0, 82, 0, 22); memberGrid.CellPadding = UDim2.new(0, 4, 0, 4)

    UI.fn.refreshMembersUI = function()
        local th = getCurrentTheme()
        for _, child in ipairs(memberGridHolder:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, fix in ipairs(workData.rig) do
            local b = Instance.new("TextButton", memberGridHolder)
            local active = state.selectedMembers[i] == true
            b.BackgroundColor3 = active and th.accent or th.surface
            b.Text = "#" .. i .. " " .. string.upper(string.sub(fix.t or "?", 1, 3)) .. " U" .. tostring(fix.u or 1) .. ":" .. tostring(fix.a)
            b.Font = Enum.Font.GothamBold; b.TextSize = 8
            b.TextColor3 = active and th.btnText or th.ink
            b.BorderSizePixel = 0; b.ZIndex = 5
            applyConsoleStyle(b, 5)
            b.MouseButton1Click:Connect(function()
                state.selectedMembers[i] = not state.selectedMembers[i]
                UI.fn.refreshMembersUI()
            end)
        end
    end

    local secPresetBeamColor = makeSection(pagePresets, "2. WARNA & EFEK OPTIK (PRISM / GOBO / FOCUS BLUR / MOTIF FX)")
    UI.targets["preset_colors"] = secPresetBeamColor

    local colorGridWrap = Instance.new("Frame", secPresetBeamColor)
    colorGridWrap.Size = UDim2.new(1, 0, 0, 0); colorGridWrap.AutomaticSize = Enum.AutomaticSize.Y; colorGridWrap.BackgroundTransparency = 1; colorGridWrap.ZIndex = 5
    local colorGrid = Instance.new("UIGridLayout", colorGridWrap)
    colorGrid.CellSize = UDim2.new(0.24, 0, 0, 22); colorGrid.CellPadding = UDim2.new(0.013, 0, 0, 4)

    local customRgbBox = Instance.new("Frame", secPresetBeamColor)
    customRgbBox.Size = UDim2.new(1, 0, 0, 0); customRgbBox.AutomaticSize = Enum.AutomaticSize.Y
    customRgbBox.BackgroundTransparency = 1; customRgbBox.Visible = false; customRgbBox.ZIndex = 5
    local customRgbLayout = Instance.new("UIListLayout", customRgbBox); customRgbLayout.Padding = UDim.new(0, 4)

    makeSliderRow(customRgbBox, "Merah (Red R)", 0, 1, state.presetR, false, function(v) state.presetR = v end)
    makeSliderRow(customRgbBox, "Hijau (Green G)", 0, 1, state.presetG, false, function(v) state.presetG = v end)
    makeSliderRow(customRgbBox, "Biru (Blue B)", 0, 1, state.presetB, false, function(v) state.presetB = v end)
    makeSliderRow(customRgbBox, "Color Wheel (Clara)", 0, 1, state.presetCW, false, function(v) state.presetCW = v end)

    local colorBtns = {}
    local function refreshColorSwatches()
        for _, sw in ipairs(PRESET_COLOR_SWATCHES) do
            local btn = colorBtns[sw.id]
            if btn then
                local isSel = (state.presetColorId == sw.id)
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = isSel and Color3.fromRGB(255, 255, 255) or getCurrentTheme().stroke
                    st.Thickness = isSel and 2 or uiPrefs.borderThickness
                end
            end
        end
        customRgbBox.Visible = (state.presetColorId == "custom")
    end

    for _, sw in ipairs(PRESET_COLOR_SWATCHES) do
        local cb = Instance.new("TextButton", colorGridWrap)
        cb.BackgroundColor3 = sw.swatch; cb.Text = string.upper(sw.name)
        cb.Font = Enum.Font.GothamBold; cb.TextSize = 8
        local lum = (sw.swatch.R * 0.299) + (sw.swatch.G * 0.587) + (sw.swatch.B * 0.114)
        cb.TextColor3 = (lum > 0.65) and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(255, 255, 255)
        cb.BorderSizePixel = 0; cb.ZIndex = 5
        applyConsoleStyle(cb, 5)
        colorBtns[sw.id] = cb
        cb.MouseButton1Click:Connect(function()
            state.presetColorId = sw.id
            if not sw.isCustom then state.presetR = sw.r; state.presetG = sw.g; state.presetB = sw.b; state.presetCW = sw.cw end
            refreshColorSwatches(); setStatus("WARNA PRESET: " .. string.upper(sw.name), false)
        end)
    end
    refreshColorSwatches()

    local beamFxRow = Instance.new("Frame", secPresetBeamColor)
    beamFxRow.Size = UDim2.new(1, 0, 0, 22); beamFxRow.BackgroundTransparency = 1; beamFxRow.ZIndex = 5
    UI.targets["preset_fx"] = beamFxRow

    local btnPrism = makeSmallActionBtn(beamFxRow, "PRISM: OFF", 0, 82, "surface", function() end)
    local btnGobo = makeSmallActionBtn(beamFxRow, "GOBO: 0.0", 86, 86, "surface", function() end)
    local btnFocusBlur = makeSmallActionBtn(beamFxRow, "BLUR: OFF", 176, 74, "surface", function() end)
    local btnOtherFx = makeSmallActionBtn(beamFxRow, "MOTIF FX: OFF", 254, 92, "surface", function() end)

    local sldPrismVal = makeSliderRow(secPresetBeamColor, "Sebaran Prism (0.05 = 9 Titik)", 0.05, 1.0, 0.05, false, function(v) state.presetPrismVal = v end)
    sldPrismVal.row.Visible = false
    local sldPrismRot = makeSliderRow(secPresetBeamColor, "Putaran Prism (prot)", 0, 1, state.presetPrismRot, false, function(v) state.presetPrismRot = v end)
    sldPrismRot.row.Visible = false
    makeSliderRow(secPresetBeamColor, "Strobe (0 = Mati, 1 = Cepat)", 0, 1, state.presetStrobeVal, false, function(v) state.presetStrobeVal = v end)

    local function refreshBeamToggles()
        local th = getCurrentTheme()
        local pOn = state.presetPrismVal > 0
        btnPrism.Text = pOn and string.format("PRISM: %.2f", state.presetPrismVal) or "PRISM: OFF"
        btnPrism.BackgroundColor3 = pOn and th.accent or th.surface
        btnPrism.TextColor3 = pOn and th.btnText or th.ink
        sldPrismVal.row.Visible = pOn; sldPrismRot.row.Visible = pOn

        local gInfo = GOBO_CALIBRATED[state.presetGoboIdx] or GOBO_CALIBRATED[1]
        btnGobo.Text = (gInfo.val > 0) and string.format("GOBO: %.2f", gInfo.val) or "GOBO: NORM"
        btnGobo.BackgroundColor3 = (gInfo.val > 0) and th.secondary or th.surface
        btnGobo.TextColor3 = (gInfo.val > 0) and th.btnText or th.ink

        btnFocusBlur.Text = state.presetFocusBlur and "BLUR: ON" or "BLUR: OFF"
        btnFocusBlur.BackgroundColor3 = state.presetFocusBlur and th.accent or th.surface
        btnFocusBlur.TextColor3 = state.presetFocusBlur and th.btnText or th.ink

        btnOtherFx.Text = state.presetOtherFxOn and "MOTIF FX: ON" or "MOTIF FX: OFF"
        btnOtherFx.BackgroundColor3 = state.presetOtherFxOn and th.secondary or th.surface
        btnOtherFx.TextColor3 = state.presetOtherFxOn and th.btnText or th.ink
    end

    btnPrism.MouseButton1Click:Connect(function()
        if state.presetPrismVal <= 0 then state.presetPrismVal = 0.05; sldPrismVal.setValue(0.05) else state.presetPrismVal = 0 end
        refreshBeamToggles()
    end)
    btnGobo.MouseButton1Click:Connect(function()
        state.presetGoboIdx = (state.presetGoboIdx % #GOBO_CALIBRATED) + 1
        setStatus("GOBO: " .. GOBO_CALIBRATED[state.presetGoboIdx].label, false); refreshBeamToggles()
    end)
    btnFocusBlur.MouseButton1Click:Connect(function()
        state.presetFocusBlur = not state.presetFocusBlur
        setStatus(state.presetFocusBlur and "FOCUS BLUR CLARA AKTIF (FOCUS = 0.1)" or "FOCUS NORMAL (0.5)", false); refreshBeamToggles()
    end)
    btnOtherFx.MouseButton1Click:Connect(function()
        state.presetOtherFxOn = not state.presetOtherFxOn
        setStatus(state.presetOtherFxOn and "FROST / MOTIF FX LAMPU NON-CLARA AKTIF" or "MOTIF FX MATI", false); refreshBeamToggles()
    end)
    UI.fn.refreshBeamToggles = refreshBeamToggles

    local secPresetOpt = makeSection(pagePresets, "3. ATUR JUMLAH STEP, KECEPATAN & KEHALUSAN")
    makeChipSelector(secPresetOpt, "Jumlah Step Otomatis (steps):", {4, 8, 12, 16}, state.presetStepsCount, function(v) state.presetStepsCount = v end)
    UI.sldPresetRate = makeSliderRow(secPresetOpt, tr("lbl_rate"), 0.2, 10.0, state.stepRate, false, function(v) state.stepRate = v end)
    UI.sldPresetGlide = makeSliderRow(secPresetOpt, tr("lbl_glide"), 0.0, 1.0, state.stepGlide, false, function(v) state.stepGlide = v end)
    UI.chipPresetDir = makeChipSelector(secPresetOpt, "Arah Jalan Step (dir):", {">", "<", "<>", "rand"}, state.stepDir, function(v) state.stepDir = v end)

    local secPresetGrid = makeSection(pagePresets, "4. KLIK PRESET (30 POLA + DINAMIS [FX]) & GABUNG GRUP DALAM 1 CUE")
    local chainRow = Instance.new("Frame", secPresetGrid)
    chainRow.Size = UDim2.new(1, 0, 0, 22); chainRow.BackgroundTransparency = 1; chainRow.ZIndex = 5
    UI.targets["preset_chain"] = chainRow

    local btnChainAppend = makeSmallActionBtn(chainRow, "+ SAMBUNG URUTAN", 0, 128, "surface", function() end)
    local btnChainMerge = makeSmallActionBtn(chainRow, "+ GABUNG BERSAMA", 132, 128, "surface", function() end)
    makeSmallActionBtn(chainRow, "RESET", 264, 56, "danger", function()
        state.customSteps = {}; state.presetChainMode = "replace"
        if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
        UI.fn.refreshSmartHint(); setStatus("STEP DIRESET KOSONG", false)
    end)

    local function refreshChainButtons()
        local th = getCurrentTheme()
        local isApp = (state.presetChainMode == "append")
        local isMrg = (state.presetChainMode == "merge")
        btnChainAppend.BackgroundColor3 = isApp and th.secondary or th.surface
        btnChainAppend.TextColor3 = isApp and th.btnText or th.ink
        btnChainAppend.Text = isApp and "PILIH PRESET SAMBUNG" or "+ SAMBUNG URUTAN"

        btnChainMerge.BackgroundColor3 = isMrg and th.accent or th.surface
        btnChainMerge.TextColor3 = isMrg and th.btnText or th.ink
        btnChainMerge.Text = isMrg and "PILIH PRESET GABUNG" or "+ GABUNG BERSAMA"
    end

    btnChainAppend.MouseButton1Click:Connect(function()
        state.presetChainMode = (state.presetChainMode == "append") and "replace" or "append"
        refreshChainButtons()
        if state.presetChainMode == "append" then setStatus("KLIK 1 PRESET UNTUK DISAMBUNG KE STEP BERIKUTNYA", false) end
    end)
    btnChainMerge.MouseButton1Click:Connect(function()
        state.presetChainMode = (state.presetChainMode == "merge") and "replace" or "merge"
        refreshChainButtons()
        if state.presetChainMode == "merge" then setStatus("KLIK 1 PRESET UNTUK DIGABUNG BERSAMAAN (MULTI-GRUP / EFEK)", false) end
    end)
    UI.fn.refreshChainButtons = refreshChainButtons

    local presetGridWrap = Instance.new("Frame", secPresetGrid)
    presetGridWrap.Size = UDim2.new(1, 0, 0, 0); presetGridWrap.AutomaticSize = Enum.AutomaticSize.Y; presetGridWrap.BackgroundTransparency = 1; presetGridWrap.ZIndex = 5
    UI.targets["preset_grid"] = presetGridWrap
    local presetGrid = Instance.new("UIGridLayout", presetGridWrap)
    presetGrid.CellSize = UDim2.new(0.49, 0, 0, 26); presetGrid.CellPadding = UDim2.new(0.02, 0, 0, 5)

    local function applyColorToOv(ov, r, g, b, cw)
        ov.color = cw; ov.col1 = cw; ov.acol = cw; ov.bcol = cw
        ov.r = r; ov.g = g; ov.b = b; ov.mr = r; ov.mg = g; ov.mb = b
        ov.r1 = r; ov.g1 = g; ov.b1 = b; ov.r2 = r; ov.g2 = g; ov.b2 = b
    end

    local function applyOtherFxToOv(ov, active)
        if not active then return end
        ov.frost = 0.85; ov.fx2 = 0.65; ov.macro1 = 0.55; ov.macro2 = 0.55
        ov.rmac = 0.65; ov.amac = 0.65; ov.bmac = 0.65; ov.mmode = 0.5
        ov.m1 = 0.65; ov.m2 = 0.65; ov.ms1 = 0.55; ov.ms2 = 0.55; ov.mo1 = 0.5; ov.mo2 = 0.5
        ov.meff = 0.65; ov.aeff = 0.65; ov.teff = 0.65; ov.mespd = 0.55; ov.aespd = 0.55; ov.tspd = 0.55
        ov.mref = 0.65; ov.mring = 0.65; ov.eref = 0.55; ov.ering = 0.55
        ov.eff = 0.65; ov.spd = 0.55; ov.ei = 0.65; ov.eo = 0.65; ov.rot = 0.55
    end

    local function applyStrobeToOv(ov, val)
        ov.strobe = val; ov.str = val; ov.shutter = val
        ov.astrobe = val; ov.rstrobe = val; ov.mstrb = val; ov.astrb = val
    end

    local function injectColorAndBeamToOv(ov, fType, prog, phaseOff)
        if state.presetColorId == "rainbow" then
            local hue = (prog + phaseOff) % 1
            local c3 = Color3.fromHSV(hue, 1, 1)
            applyColorToOv(ov, c3.R, c3.G, c3.B, hue)
        elseif state.presetColorId ~= "none" then
            applyColorToOv(ov, state.presetR, state.presetG, state.presetB, state.presetCW)
        end
        if fType == "clara" then
            if state.presetPrismVal > 0 then ov.prism = state.presetPrismVal; ov.prism2 = state.presetPrismVal; ov.prot = state.presetPrismRot end
            local gInfo = GOBO_CALIBRATED[state.presetGoboIdx]
            if gInfo and gInfo.val > 0 then ov.gobo = gInfo.val; ov.gobor = 0.25 end
            if state.presetFocusBlur then ov.focus = 0.10 end
        else
            applyOtherFxToOv(ov, state.presetOtherFxOn)
        end
        if state.presetStrobeVal > 0 then applyStrobeToOv(ov, state.presetStrobeVal) end
    end

    local function buildStepsFromPreset(preset)
        local indices = getSelectedMemberIndices()
        local totalSel = math.max(1, #indices)
        local numSteps = state.presetStepsCount or 8
        local generatedSteps = {}
        local modeUsed = state.presetChainMode

        state.layoutEditMode = false
        if UI.fn.refreshPreviewToolbar then UI.fn.refreshPreviewToolbar() end

        if modeUsed == "replace" then
            state.stepRate = preset.rate or 2.5; state.stepGlide = preset.glide or 0.35
            UI.sldPresetRate.setValue(state.stepRate); UI.sldPresetGlide.setValue(state.stepGlide)
        end

        for s = 1, numSteps do
            local frame = {}
            local prog = (s - 1) / numSteps
            local isSecondHalf = (s > math.floor(numSteps / 2))
            for posIdx, rigIdx in ipairs(indices) do
                local fix = workData.rig[rigIdx]
                if fix then
                    local fType = string.lower(fix.t or "clara")
                    local phaseOff = (posIdx - 1) / totalSel
                    local ang = (prog + phaseOff) * math.pi * 2
                    local ov = {}

                    injectColorAndBeamToOv(ov, fType, prog, phaseOff)

                    if preset.pattern == "circle" then
                        ov.pan = 0.5 + (math.cos(ang) * 0.35); ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                    elseif preset.pattern == "circle_mirror" then
                        local sign = (posIdx > (totalSel / 2)) and -1 or 1
                        ov.pan = 0.5 + (math.cos(ang) * 0.35 * sign); ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                    elseif preset.pattern == "circle_zoom" then
                        local rad = 0.15 + (0.25 * (0.5 + 0.5 * math.sin(prog * math.pi * 2)))
                        ov.pan = 0.5 + (math.cos(ang) * rad); ov.tilt = 0.5 + (math.sin(ang) * rad)
                    elseif preset.pattern == "fig8" then
                        ov.pan = 0.5 + (math.sin(ang) * 0.40); ov.tilt = 0.5 + (math.sin(ang * 2) * 0.30)
                    elseif preset.pattern == "fig8_mirror" then
                        local sign = (posIdx > (totalSel / 2)) and -1 or 1
                        ov.pan = 0.5 + (math.sin(ang) * 0.40 * sign); ov.tilt = 0.5 + (math.sin(ang * 2) * 0.30)
                    elseif preset.pattern == "wave_pan" then
                        ov.pan = 0.5 + (math.sin(ang) * 0.42); ov.tilt = 0.5
                    elseif preset.pattern == "fan_io" then
                        local mid = (totalSel + 1) / 2
                        local dist = (posIdx - mid) / math.max(1, totalSel / 2)
                        local wave = math.sin(prog * math.pi * 2)
                        ov.pan = 0.5 + (dist * 0.40 * wave); ov.tilt = 0.5 + (0.25 * math.cos(prog * math.pi * 2))
                    elseif preset.pattern == "cross_x" then
                        local sign = (posIdx % 2 == 1) and 1 or -1
                        ov.pan = 0.5 + (math.sin(ang) * 0.38 * sign); ov.tilt = 0.5 + (math.cos(ang) * 0.35)
                    elseif preset.pattern == "wave_tilt" then
                        ov.pan = 0.5; ov.tilt = 0.5 + (math.sin(ang) * 0.40)
                    elseif preset.pattern == "tilt_mirror" then
                        local sign = (posIdx % 2 == 1) and 1 or -1
                        ov.pan = 0.5; ov.tilt = 0.5 + (math.sin(ang) * 0.38 * sign)
                    elseif preset.pattern == "stair_tilt" then
                        ov.pan = 0.5; ov.tilt = 0.18 + (((prog + phaseOff) % 1) * 0.68)
                    elseif preset.pattern == "fly_out" then
                        local stepCycle = (prog + phaseOff) % 1
                        ov.pan = 0.5; ov.tilt = 0.20 + (stepCycle * 0.68)
                        local dimVal = (stepCycle < 0.72) and 1 or 0
                        ov.dim = dimVal; ov.int = dimVal
                    elseif preset.pattern == "diamond" then
                        local t4 = ((prog + phaseOff) % 1) * 4
                        local seg = math.floor(t4); local f = t4 - seg
                        local pts = {{0.5, 0.85}, {0.85, 0.5}, {0.5, 0.15}, {0.15, 0.5}}
                        local pA = pts[seg + 1]; local pB = pts[((seg + 1) % 4) + 1]
                        ov.pan = pA[1] + (pB[1] - pA[1]) * f; ov.tilt = pA[2] + (pB[2] - pA[2]) * f
                    elseif preset.pattern == "box_path" then
                        local t4 = ((prog + phaseOff) % 1) * 4
                        local seg = math.floor(t4); local f = t4 - seg
                        local pts = {{0.18, 0.82}, {0.82, 0.82}, {0.82, 0.18}, {0.18, 0.18}}
                        local pA = pts[seg + 1]; local pB = pts[((seg + 1) % 4) + 1]
                        ov.pan = pA[1] + (pB[1] - pA[1]) * f; ov.tilt = pA[2] + (pB[2] - pA[2]) * f
                    elseif preset.pattern == "zigzag" then
                        local z = ((prog + phaseOff) % 1)
                        ov.pan = 0.15 + (z * 0.70); ov.tilt = (s % 2 == 1) and 0.75 or 0.25
                    elseif preset.pattern == "spiral" then
                        local rMod = 0.12 + (((prog * 2) % 1) * 0.30)
                        ov.pan = 0.5 + (math.cos(ang * 2) * rMod); ov.tilt = 0.5 + (math.sin(ang * 2) * rMod)
                    elseif preset.pattern == "heart" then
                        local ht = ang
                        local hx = 16 * (math.sin(ht)^3)
                        local hy = 13 * math.cos(ht) - 5 * math.cos(2 * ht) - 2 * math.cos(3 * ht) - math.cos(4 * ht)
                        ov.pan = 0.5 + ((hx / 16) * 0.36); ov.tilt = 0.52 + ((hy / 16) * 0.34)
                    elseif preset.pattern == "v_wave" then
                        local mid = (totalSel + 1) / 2
                        local dist = math.abs(posIdx - mid) / math.max(1, totalSel / 2)
                        ov.pan = 0.5 + (((posIdx - mid) / math.max(1, totalSel / 2)) * 0.28)
                        ov.tilt = 0.35 + (dist * 0.45 * (0.5 + 0.5 * math.sin(prog * math.pi * 2)))
                    elseif preset.pattern == "center_pinch" then
                        local mid = (totalSel + 1) / 2
                        local norm = (posIdx - mid) / math.max(1, totalSel / 2)
                        local pinch = 0.5 + 0.5 * math.cos(prog * math.pi * 2)
                        ov.pan = 0.5 + (norm * 0.42 * pinch); ov.tilt = 0.45 + (0.25 * (1 - pinch))
                    elseif preset.pattern == "pingpong" then
                        local dir = (s % 2 == 1) and 1 or -1
                        local side = (posIdx % 2 == 1) and 1 or -1
                        ov.pan = 0.5 + (0.36 * dir * side); ov.tilt = 0.5 + (0.26 * dir)
                    elseif preset.pattern == "ballyhoo" then
                        ov.pan = 0.5 + (math.sin(ang * 1.5 + rigIdx) * 0.40); ov.tilt = 0.5 + (math.cos(ang * 2.1 - rigIdx) * 0.38)
                    elseif preset.pattern == "odd_even" then
                        local isOdd = (posIdx % 2 == 1)
                        local active = ((s % 2 == 1) and isOdd) or ((s % 2 == 0) and not isOdd)
                        local val = active and 1 or 0
                        ov.dim = val; ov.int = val; ov.r = val; ov.g = val; ov.b = val
                        ov.d1 = val; ov.d2 = val; ov.d3 = val; ov.d4 = val
                        ov.mdim = val; ov.adim = val; ov.rdim = val; ov.bdim = val
                        ov.dins = val; ov.dref = val; ov.dring = val
                    elseif preset.pattern == "runner" then
                        local activePos = ((s - 1) % totalSel) + 1
                        local val = (posIdx == activePos) and 1 or 0
                        ov.dim = val; ov.int = val; ov.r = val; ov.g = val; ov.b = val
                        ov.d1 = val; ov.d2 = val; ov.d3 = val; ov.d4 = val
                        ov.mdim = val; ov.adim = val; ov.rdim = val; ov.bdim = val
                    elseif preset.pattern == "bounce_lr" then
                        local span = math.max(1, totalSel - 1)
                        local cycle = (s - 1) % (span * 2)
                        local targetPos = (cycle <= span) and (cycle + 1) or ((span * 2 - cycle) + 1)
                        local val = (posIdx == targetPos) and 1 or 0
                        ov.dim = val; ov.int = val; ov.r = val; ov.g = val; ov.b = val
                    elseif preset.pattern == "twinkle" then
                        local active = (((s * 3 + posIdx * 5) % 4) == 0)
                        local val = active and 1 or 0.12
                        ov.dim = val; ov.int = val
                    elseif preset.pattern == "police_split" then
                        local isLeft = (posIdx <= (totalSel / 2))
                        local flashLeft = (s % 2 == 1)
                        local active = (isLeft and flashLeft) or ((not isLeft) and (not flashLeft))
                        local val = active and 1 or 0
                        ov.dim = val; ov.int = val
                        if isLeft then applyColorToOv(ov, val, 0, 0, 0.15) else applyColorToOv(ov, 0, 0, val, 0.45) end
                    elseif preset.pattern == "dyn_prism_drop" then
                        ov.pan = 0.5 + (math.cos(ang) * 0.35); ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                        if isSecondHalf then
                            if fType == "clara" then ov.prism = 0.25; ov.prism2 = 0.25; ov.prot = 0.45 else applyOtherFxToOv(ov, true) end
                        else
                            ov.prism = 0; ov.prot = 0
                        end
                    elseif preset.pattern == "dyn_strobe_drop" then
                        ov.pan = 0.5 + (math.sin(ang) * 0.40); ov.tilt = 0.5 + (math.cos(ang) * 0.25)
                        if isSecondHalf then applyStrobeToOv(ov, 0.85) else ov.strobe = 0; ov.str = 0; ov.shutter = 0 end
                    elseif preset.pattern == "dyn_rgb_circle" then
                        ov.pan = 0.5 + (math.cos(ang) * 0.35); ov.tilt = 0.5 + (math.sin(ang) * 0.35)
                        local palette = {{1, 0, 0, 0.15}, {0, 1, 0, 0.30}, {0, 0, 1, 0.45}, {1, 0, 1, 0.70}}
                        local pick = palette[((s - 1) % #palette) + 1]
                        applyColorToOv(ov, pick[1], pick[2], pick[3], pick[4])
                    elseif preset.pattern == "dyn_gobo_morph" then
                        local mid = (totalSel + 1) / 2
                        local dist = (posIdx - mid) / math.max(1, totalSel / 2)
                        ov.pan = 0.5 + (dist * 0.38 * math.sin(prog * math.pi * 2))
                        ov.tilt = 0.5 + (0.28 * math.cos(prog * math.pi * 2))
                        if fType == "clara" then
                            if isSecondHalf then ov.gobo = 0.91; ov.focus = 0.12 else ov.gobo = 0.35; ov.focus = 0.50 end
                        else
                            applyOtherFxToOv(ov, isSecondHalf)
                        end
                    end

                    frame[tostring(rigIdx)] = {t = fType, v = makeFullV(fType, ov), _ov = ov}
                end
            end
            table.insert(generatedSteps, frame)
        end

        if modeUsed == "append" and #state.customSteps > 0 then
            for _, frm in ipairs(generatedSteps) do frm._ov = nil; table.insert(state.customSteps, frm) end
            setStatus("DISAMBUNG +" .. #generatedSteps .. " STEP (TOTAL " .. #state.customSteps .. " STEP)", false)
        elseif modeUsed == "merge" and #state.customSteps > 0 then
            for sIdx, baseFrm in ipairs(state.customSteps) do
                local ovFrm = generatedSteps[((sIdx - 1) % #generatedSteps) + 1]
                if ovFrm then
                    for rKey, rData in pairs(ovFrm) do
                        if baseFrm[rKey] and baseFrm[rKey].v and rData._ov then
                            for chK, chV in pairs(rData._ov) do
                                if baseFrm[rKey].v[chK] ~= nil then baseFrm[rKey].v[chK] = chV end
                            end
                        else
                            local cleanCopy = deepCopy(rData); cleanCopy._ov = nil; baseFrm[rKey] = cleanCopy
                        end
                    end
                end
            end
            setStatus("DIGABUNG GRUP/EFEK KE " .. #state.customSteps .. " STEP", false)
        else
            for _, frm in ipairs(generatedSteps) do frm._ov = nil end
            state.customSteps = generatedSteps
            setStatus("JADI " .. #generatedSteps .. " STEP (" .. string.upper(preset.name) .. ")", false)
        end

        state.presetChainMode = "replace"
        refreshChainButtons()
        if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
        UI.fn.refreshSmartHint()
    end

    for _, tpl in ipairs(STEP_PRESETS) do
        local btn = Instance.new("TextButton", presetGridWrap)
        btn.Text = string.upper(tpl.name); btn.Font = Enum.Font.GothamBold; btn.TextSize = 9
        btn.TextTruncate = Enum.TextTruncate.AtEnd; btn.BorderSizePixel = 0; btn.ZIndex = 5
        registerTheme(btn, "surface", "BackgroundColor3"); registerTheme(btn, "ink", "TextColor3")
        applyConsoleStyle(btn, 5)
        btn.MouseButton1Click:Connect(function() buildStepsFromPreset(tpl) end)
    end
end

do
    local secCustomPad = makeSection(pageCustom, "1. ATUR POSISI LAMPU (GESER KOTAK XY & REKAM STEP)")
    local xyPad = Instance.new("TextButton", secCustomPad)
    xyPad.Size = UDim2.new(1, 0, 0, 88); xyPad.Text = ""; xyPad.AutoButtonColor = false; xyPad.BorderSizePixel = 0; xyPad.ZIndex = 5
    registerTheme(xyPad, "canvas", "BackgroundColor3")
    applyConsoleStyle(xyPad, 6)
    UI.targets["custom_xypad"] = xyPad

    local padCrossH = Instance.new("Frame", xyPad); padCrossH.Size = UDim2.new(1, 0, 0, 1); padCrossH.Position = UDim2.new(0, 0, 0.5, 0); padCrossH.BackgroundColor3 = Color3.fromRGB(65, 68, 80); padCrossH.BorderSizePixel = 0; padCrossH.ZIndex = 6
    local padCrossV = Instance.new("Frame", xyPad); padCrossV.Size = UDim2.new(0, 1, 1, 0); padCrossV.Position = UDim2.new(0.5, 0, 0, 0); padCrossV.BackgroundColor3 = Color3.fromRGB(65, 68, 80); padCrossV.BorderSizePixel = 0; padCrossV.ZIndex = 6

    local xyCursor = Instance.new("Frame", xyPad)
    xyCursor.Size = UDim2.new(0, 16, 0, 16); xyCursor.AnchorPoint = Vector2.new(0.5, 0.5); xyCursor.Position = UDim2.new(0.5, 0, 0.5, 0); xyCursor.BorderSizePixel = 0; xyCursor.ZIndex = 7
    registerTheme(xyCursor, "accent", "BackgroundColor3")
    applyConsoleStyle(xyCursor, 8)

    local function syncPadFromPanTilt()
        xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0)
        if UI.sldCustomPan then UI.sldCustomPan.setValue(state.curPan) end
        if UI.sldCustomTilt then UI.sldCustomTilt.setValue(state.curTilt) end
    end

    local padDragging = false
    local function updatePad(input)
        local rx = math.clamp((input.Position.X - xyPad.AbsolutePosition.X) / math.max(1, xyPad.AbsoluteSize.X), 0, 1)
        local ry = math.clamp((input.Position.Y - xyPad.AbsolutePosition.Y) / math.max(1, xyPad.AbsoluteSize.Y), 0, 1)
        state.curPan = math.floor(rx * 100 + 0.5) / 100; state.curTilt = math.floor((1 - ry) * 100 + 0.5) / 100
        syncPadFromPanTilt()
    end
    xyPad.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then padDragging = true; updatePad(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if padDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updatePad(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then padDragging = false end
    end)

    UI.sldCustomPan = makeSliderRow(secCustomPad, tr("lbl_pan"), 0, 1, state.curPan, false, function(v) state.curPan = v; xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0) end)
    UI.sldCustomTilt = makeSliderRow(secCustomPad, tr("lbl_tilt"), 0, 1, state.curTilt, false, function(v) state.curTilt = v; xyCursor.Position = UDim2.new(state.curPan, 0, 1 - state.curTilt, 0) end)
    UI.sldCustomDim = makeSliderRow(secCustomPad, tr("lbl_dim"), 0, 1, state.curDim, false, function(v) state.curDim = v end)
    UI.sldCustomColor = makeSliderRow(secCustomPad, tr("lbl_color"), 0, 1, state.curColor, false, function(v) state.curColor = v end)
    UI.sldCustomStrobe = makeSliderRow(secCustomPad, tr("lbl_strobe"), 0, 1, state.curStrobe, false, function(v) state.curStrobe = v end)

    local mirrorBtn = Instance.new("TextButton", secCustomPad)
    mirrorBtn.Size = UDim2.new(1, 0, 0, 22); mirrorBtn.Text = tr("btn_mirror_off"); mirrorBtn.Font = Enum.Font.GothamBold; mirrorBtn.TextSize = 9; mirrorBtn.BorderSizePixel = 0; mirrorBtn.ZIndex = 5
    registerTheme(mirrorBtn, "surface", "BackgroundColor3"); registerTheme(mirrorBtn, "ink", "TextColor3")
    applyConsoleStyle(mirrorBtn, 5)
    UI.mirrorBtn = mirrorBtn

    mirrorBtn.MouseButton1Click:Connect(function()
        state.curMirror = not state.curMirror
        local th = getCurrentTheme()
        mirrorBtn.Text = state.curMirror and tr("btn_mirror_on") or tr("btn_mirror_off")
        mirrorBtn.BackgroundColor3 = state.curMirror and th.secondary or th.surface
        mirrorBtn.TextColor3 = state.curMirror and th.btnText or th.ink
    end)

    local secCustomSteps = makeSection(pageCustom, "2. URUTAN STEP & SIMPAN KE CUE")
    local stepActionRow = Instance.new("Frame", secCustomSteps)
    stepActionRow.Size = UDim2.new(1, 0, 0, 22); stepActionRow.BackgroundTransparency = 1; stepActionRow.ZIndex = 5

    UI.btnRecStep = makeSmallActionBtn(stepActionRow, tr("btn_rec_step"), 0, 108, "accent", function()
        local frame = {}
        local indices = getSelectedMemberIndices()
        local totalSel = math.max(1, #indices)
        for posIdx, rigIdx in ipairs(indices) do
            local fix = workData.rig[rigIdx]
            if fix then
                local fType = string.lower(fix.t or "clara")
                local pVal = state.curPan
                if state.curMirror and posIdx > (totalSel / 2) then pVal = 1 - pVal end
                frame[tostring(rigIdx)] = {
                    t = fType,
                    v = makeFullV(fType, {
                        pan = pVal, tilt = state.curTilt, dim = state.curDim, int = state.curDim,
                        r = state.curDim, g = state.curDim, b = state.curDim,
                        d1 = state.curDim, d2 = state.curDim, d3 = state.curDim, d4 = state.curDim,
                        color = state.curColor, col1 = state.curColor,
                        strobe = state.curStrobe, str = state.curStrobe, shutter = state.curStrobe
                    })
                }
            end
        end
        table.insert(state.customSteps, frame)
        if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
        UI.fn.refreshSmartHint(); setStatus("STEP #" .. #state.customSteps .. " DIREKAM", false)
    end)
    UI.targets["custom_rec"] = UI.btnRecStep

    UI.btnSaveCueMid = makeSmallActionBtn(stepActionRow, tr("btn_save_cue"), 113, 108, "secondary", function() UI.fn.saveCurrentStepsToCue(state.cueId) end)
    UI.btnDelAllSteps = makeSmallActionBtn(stepActionRow, tr("btn_del_all"), 226, 88, "danger", function()
        state.customSteps = {}
        if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
        UI.fn.refreshSmartHint(); setStatus("SEMUA STEP DIHAPUS", false)
    end)

    local stepsListContainer = Instance.new("Frame", secCustomSteps)
    stepsListContainer.Size = UDim2.new(1, 0, 0, 0); stepsListContainer.AutomaticSize = Enum.AutomaticSize.Y; stepsListContainer.BackgroundTransparency = 1; stepsListContainer.ZIndex = 5
    local stepsListLayout = Instance.new("UIListLayout", stepsListContainer); stepsListLayout.Padding = UDim.new(0, 4)

    UI.fn.refreshCustomStepsListUI = function()
        local th = getCurrentTheme()
        for _, child in ipairs(stepsListContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end
        if #state.customSteps == 0 then
            local emp = Instance.new("TextLabel", stepsListContainer)
            emp.Size = UDim2.new(1, 0, 0, 20); emp.BackgroundTransparency = 1
            emp.Text = "BELUM ADA STEP. KLIK PRESET DI TAB 1 ATAU '+ REKAM STEP'."
            emp.Font = Enum.Font.Code; emp.TextSize = 9; emp.TextColor3 = th.subInk; emp.TextXAlignment = Enum.TextXAlignment.Left; emp.ZIndex = 5
            return
        end
        for sIdx, frame in ipairs(state.customSteps) do
            local row = Instance.new("Frame", stepsListContainer)
            row.Size = UDim2.new(1, 0, 0, 22); row.BackgroundColor3 = th.surface; row.BorderSizePixel = 0; row.ZIndex = 5
            applyConsoleStyle(row, 5)

            local samplePan, sampleTilt, sampleDim = 0.5, 0.5, 1
            for _, fData in pairs(frame) do
                if type(fData) == "table" and type(fData.v) == "table" then
                    samplePan = fData.v.pan or 0.5; sampleTilt = fData.v.tilt or 0.5; sampleDim = fData.v.dim or fData.v.int or 1
                    break
                end
            end
            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -104, 1, 0); lbl.Position = UDim2.new(0, 6, 0, 0); lbl.BackgroundTransparency = 1
            lbl.Text = string.format("STEP %02d  |  PAN: %.2f  TILT: %.2f  DIM: %.2f", sIdx, samplePan, sampleTilt, sampleDim)
            lbl.Font = Enum.Font.Code; lbl.TextSize = 9; lbl.TextColor3 = th.ink; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5

            local upBtn = Instance.new("TextButton", row)
            upBtn.Size = UDim2.new(0, 24, 0, 18); upBtn.Position = UDim2.new(1, -96, 0.5, -9)
            upBtn.BackgroundColor3 = th.chipBg; upBtn.Text = "▲"; upBtn.Font = Enum.Font.GothamBold; upBtn.TextSize = 8; upBtn.TextColor3 = th.ink; upBtn.BorderSizePixel = 0; upBtn.ZIndex = 5
            applyConsoleStyle(upBtn, 4)
            upBtn.MouseButton1Click:Connect(function()
                if sIdx > 1 then state.customSteps[sIdx], state.customSteps[sIdx - 1] = state.customSteps[sIdx - 1], state.customSteps[sIdx]; UI.fn.refreshCustomStepsListUI() end
            end)

            local dnBtn = Instance.new("TextButton", row)
            dnBtn.Size = UDim2.new(0, 24, 0, 18); dnBtn.Position = UDim2.new(1, -68, 0.5, -9)
            dnBtn.BackgroundColor3 = th.chipBg; dnBtn.Text = "▼"; dnBtn.Font = Enum.Font.GothamBold; dnBtn.TextSize = 8; dnBtn.TextColor3 = th.ink; dnBtn.BorderSizePixel = 0; dnBtn.ZIndex = 5
            applyConsoleStyle(dnBtn, 4)
            dnBtn.MouseButton1Click:Connect(function()
                if sIdx < #state.customSteps then state.customSteps[sIdx], state.customSteps[sIdx + 1] = state.customSteps[sIdx + 1], state.customSteps[sIdx]; UI.fn.refreshCustomStepsListUI() end
            end)

            local del = Instance.new("TextButton", row)
            del.Size = UDim2.new(0, 34, 0, 18); del.Position = UDim2.new(1, -38, 0.5, -9)
            del.BackgroundColor3 = th.danger; del.Text = "X"; del.Font = Enum.Font.GothamBold; del.TextSize = 9; del.TextColor3 = Color3.fromRGB(255, 255, 255); del.BorderSizePixel = 0; del.ZIndex = 5
            applyConsoleStyle(del, 4)
            del.MouseButton1Click:Connect(function()
                table.remove(state.customSteps, sIdx); UI.fn.refreshCustomStepsListUI(); UI.fn.refreshSmartHint(); setStatus("STEP #" .. sIdx .. " DIHAPUS", false)
            end)
        end
    end
end

do
    local secPvMain = makeSection(pagePreview, "1. LIVE STAGE PREVIEW (ATAS / DEPAN + GESER BEBAS)")
    local pvToolRow1 = Instance.new("Frame", secPvMain)
    pvToolRow1.Size = UDim2.new(1, 0, 0, 22); pvToolRow1.BackgroundTransparency = 1; pvToolRow1.ZIndex = 5

    local pvViewTopBtn = Instance.new("TextButton", pvToolRow1)
    pvViewTopBtn.Size = UDim2.new(0, 74, 0, 21); pvViewTopBtn.Position = UDim2.new(0, 0, 0, 0); pvViewTopBtn.Text = "VIEW: ATAS"; pvViewTopBtn.Font = Enum.Font.GothamBold; pvViewTopBtn.TextSize = 9; pvViewTopBtn.BorderSizePixel = 0; pvViewTopBtn.ZIndex = 5
    applyConsoleStyle(pvViewTopBtn, 5)

    local pvViewFrontBtn = Instance.new("TextButton", pvToolRow1)
    pvViewFrontBtn.Size = UDim2.new(0, 80, 0, 21); pvViewFrontBtn.Position = UDim2.new(0, 78, 0, 0); pvViewFrontBtn.Text = "VIEW: DEPAN"; pvViewFrontBtn.Font = Enum.Font.GothamBold; pvViewFrontBtn.TextSize = 9; pvViewFrontBtn.BorderSizePixel = 0; pvViewFrontBtn.ZIndex = 5
    applyConsoleStyle(pvViewFrontBtn, 5)

    local pvDragToggleBtn = Instance.new("TextButton", pvToolRow1)
    pvDragToggleBtn.Size = UDim2.new(0, 88, 0, 21); pvDragToggleBtn.Position = UDim2.new(0, 162, 0, 0); pvDragToggleBtn.Text = "GESER: OFF"; pvDragToggleBtn.Font = Enum.Font.GothamBold; pvDragToggleBtn.TextSize = 9; pvDragToggleBtn.BorderSizePixel = 0; pvDragToggleBtn.ZIndex = 5
    applyConsoleStyle(pvDragToggleBtn, 5)
    UI.targets["pv_drag"] = pvDragToggleBtn

    local previewCanvas = Instance.new("Frame", secPvMain)
    previewCanvas.Size = UDim2.new(1, 0, 0, state.canvasHeight); previewCanvas.ClipsDescendants = true; previewCanvas.BorderSizePixel = 0; previewCanvas.ZIndex = 5
    registerTheme(previewCanvas, "canvas", "BackgroundColor3")
    applyConsoleStyle(previewCanvas, 6)
    UI.targets["pv_canvas"] = previewCanvas

    makeSmallActionBtn(pvToolRow1, "PANJANG +", 254, 62, "surface", function()
        state.canvasHeight = math.clamp(state.canvasHeight + 45, 150, 420); previewCanvas.Size = UDim2.new(1, 0, 0, state.canvasHeight)
    end)
    makeSmallActionBtn(pvToolRow1, "PENDEK -", 320, 62, "surface", function()
        state.canvasHeight = math.clamp(state.canvasHeight - 45, 150, 420); previewCanvas.Size = UDim2.new(1, 0, 0, state.canvasHeight)
    end)

    local guideTopLbl = Instance.new("TextLabel", previewCanvas); guideTopLbl.Size = UDim2.new(1, 0, 0, 14); guideTopLbl.Position = UDim2.new(0, 0, 0, 2); guideTopLbl.BackgroundTransparency = 1; guideTopLbl.Text = "BELAKANG PANGGUNG (TRUSS)"; guideTopLbl.Font = Enum.Font.Code; guideTopLbl.TextSize = 9; guideTopLbl.TextColor3 = Color3.fromRGB(130, 135, 150); guideTopLbl.ZIndex = 6
    local guideBotLbl = Instance.new("TextLabel", previewCanvas); guideBotLbl.Size = UDim2.new(1, 0, 0, 14); guideBotLbl.Position = UDim2.new(0, 0, 1, -15); guideBotLbl.BackgroundTransparency = 1; guideBotLbl.Text = "DEPAN / PENONTON"; guideBotLbl.Font = Enum.Font.Code; guideBotLbl.TextSize = 9; guideBotLbl.TextColor3 = Color3.fromRGB(130, 135, 150); guideBotLbl.ZIndex = 6

    local dpadRow = Instance.new("Frame", secPvMain); dpadRow.Size = UDim2.new(1, 0, 0, 24); dpadRow.BackgroundTransparency = 1; dpadRow.ZIndex = 5
    local dpadTargetLbl = Instance.new("TextLabel", dpadRow); dpadTargetLbl.Size = UDim2.new(0, 130, 1, 0); dpadTargetLbl.BackgroundTransparency = 1; dpadTargetLbl.Text = "UNIT #1 (X:0.10 Y:0.25)"; dpadTargetLbl.Font = Enum.Font.Code; dpadTargetLbl.TextSize = 9; dpadTargetLbl.TextXAlignment = Enum.TextXAlignment.Left; dpadTargetLbl.ZIndex = 5
    registerTheme(dpadTargetLbl, "ink", "TextColor3")

    local function nudgeActiveFixture(dx, dy)
        local idx = math.clamp(state.activeLayoutNode, 1, math.max(1, #workData.rig))
        local fix = workData.rig[idx]
        if not fix then return end
        fix.x = math.clamp(math.floor(((fix.x or 0.5) + dx) * 100 + 0.5) / 100, 0.05, 0.95)
        fix.y = math.clamp(math.floor(((fix.y or 0.25) + dy) * 100 + 0.5) / 100, 0.08, 0.92)
        dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", idx, fix.x, fix.y)
        if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
    end

    makeSmallActionBtn(dpadRow, "◄ KIRI", 132, 48, "surface", function() nudgeActiveFixture(-0.04, 0) end)
    makeSmallActionBtn(dpadRow, "► KANAN", 184, 54, "surface", function() nudgeActiveFixture(0.04, 0) end)
    makeSmallActionBtn(dpadRow, "▲ ATAS", 242, 48, "surface", function() nudgeActiveFixture(0, -0.04) end)
    makeSmallActionBtn(dpadRow, "▼ BAWAH", 294, 54, "surface", function() nudgeActiveFixture(0, 0.04) end)

    UI.fn.refreshPreviewToolbar = function()
        local th = getCurrentTheme()
        local isTop = (state.previewView == "top")
        pvViewTopBtn.BackgroundColor3 = isTop and th.accent or th.surface; pvViewTopBtn.TextColor3 = isTop and th.btnText or th.ink
        pvViewFrontBtn.BackgroundColor3 = (not isTop) and th.accent or th.surface; pvViewFrontBtn.TextColor3 = (not isTop) and th.btnText or th.ink
        pvDragToggleBtn.BackgroundColor3 = state.layoutEditMode and th.secondary or th.surface; pvDragToggleBtn.TextColor3 = state.layoutEditMode and th.btnText or th.ink
        pvDragToggleBtn.Text = state.layoutEditMode and "GESER: ON" or "GESER: OFF"
        if isTop then
            guideTopLbl.Text = state.layoutEditMode and "GESER BEBAS (ATAS/BAWAH/KIRI/KANAN) - BELAKANG" or "TAMPAK ATAS (DENAH X/Y) - BELAKANG"
            guideBotLbl.Text = "DEPAN / PENONTON"
        else
            guideTopLbl.Text = state.layoutEditMode and "GESER BEBAS POSISI & TINGGI LAMPU - ATAS" or "TAMPAK DEPAN (PANGGUNG)"
            guideBotLbl.Text = "LANTAI PANGGUNG / PENONTON"
        end
    end

    local secFormations = makeSection(pagePreview, "2. TEMPLATE BENTUK FORMASI & HURUF / ANGKA / KATA (MAX 8)")
    UI.targets["pv_shapes"] = secFormations

    local function applyFormationPoints(pts, labelName)
        local total = #workData.rig
        if total == 0 or #pts == 0 then return end
        for i = 1, total do
            local p = pts[((i - 1) % #pts) + 1]
            workData.rig[i].x = math.clamp(math.floor(p.x * 100 + 0.5) / 100, 0.05, 0.95)
            workData.rig[i].y = math.clamp(math.floor(p.y * 100 + 0.5) / 100, 0.08, 0.92)
        end
        state.layoutEditMode = true; UI.fn.refreshPreviewToolbar(); UI.fn.refreshSmartHint()
        if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
        setStatus("FORMASI: " .. string.upper(labelName), false)
    end

    local shapeGridWrap = Instance.new("Frame", secFormations)
    shapeGridWrap.Size = UDim2.new(1, 0, 0, 0); shapeGridWrap.AutomaticSize = Enum.AutomaticSize.Y; shapeGridWrap.BackgroundTransparency = 1; shapeGridWrap.ZIndex = 5
    local shapeGrid = Instance.new("UIGridLayout", shapeGridWrap); shapeGrid.CellSize = UDim2.new(0.24, 0, 0, 24); shapeGrid.CellPadding = UDim2.new(0.013, 0, 0, 4)

    local SHAPE_FORMATIONS = {
        {name = "Baris Lurus", build = function(n)
            local pts = {}; for i = 1, n do table.insert(pts, {x = (n == 1) and 0.5 or (0.08 + ((i - 1) * (0.84 / math.max(1, n - 1)))), y = 0.25}) end; return pts
        end},
        {name = "Busur", build = function(n)
            local pts = {}; for i = 1, n do local norm = (n == 1) and 0 or (((i - 1) / math.max(1, n - 1)) * 2 - 1); table.insert(pts, {x = 0.5 + norm * 0.42, y = 0.22 + ((1 - norm * norm) * 0.50)}) end; return pts
        end},
        {name = "Lingkaran", build = function(n) return samplePolygonPerimeter(makeRegularPolygon(32, 0.36, 0.36, -90), n) end},
        {name = "Kotak", build = function(n) return samplePolygonPerimeter({{x=0.16,y=0.16},{x=0.84,y=0.16},{x=0.84,y=0.84},{x=0.16,y=0.84}}, n) end},
        {name = "Segitiga", build = function(n) return samplePolygonPerimeter(makeRegularPolygon(3, 0.40, 0.40, -90), n) end},
        {name = "Segi Lima", build = function(n) return samplePolygonPerimeter(makeRegularPolygon(5, 0.38, 0.38, -90), n) end},
        {name = "Segi Enam", build = function(n) return samplePolygonPerimeter(makeRegularPolygon(6, 0.38, 0.38, 0), n) end},
        {name = "Segi Tujuh", build = function(n) return samplePolygonPerimeter(makeRegularPolygon(7, 0.38, 0.38, -90), n) end}
    }

    for _, sf in ipairs(SHAPE_FORMATIONS) do
        local b = Instance.new("TextButton", shapeGridWrap)
        b.Text = string.upper(sf.name); b.Font = Enum.Font.GothamBold; b.TextSize = 8; b.BorderSizePixel = 0; b.ZIndex = 5
        registerTheme(b, "surface", "BackgroundColor3"); registerTheme(b, "ink", "TextColor3")
        applyConsoleStyle(b, 5)
        b.MouseButton1Click:Connect(function() applyFormationPoints(sf.build(#workData.rig), sf.name) end)
    end

    local wordRow = Instance.new("Frame", secFormations); wordRow.Size = UDim2.new(1, 0, 0, 24); wordRow.BackgroundTransparency = 1; wordRow.ZIndex = 5
    local wordBox = Instance.new("TextBox", wordRow)
    wordBox.Size = UDim2.new(0, 175, 0, 22); wordBox.PlaceholderText = "Huruf / Angka / Kata (Max 8)"; wordBox.Text = ""; wordBox.Font = Enum.Font.Code; wordBox.TextSize = 10; wordBox.ClearTextOnFocus = false; wordBox.BorderSizePixel = 0; wordBox.ZIndex = 5
    registerTheme(wordBox, "surface", "BackgroundColor3"); registerTheme(wordBox, "ink", "TextColor3")
    applyConsoleStyle(wordBox, 5)

    wordBox:GetPropertyChangedSignal("Text"):Connect(function()
        if #wordBox.Text > 8 then wordBox.Text = string.sub(wordBox.Text, 1, 8) end
    end)

    makeSmallActionBtn(wordRow, "Bentuk Kata / Huruf", 181, 145, "accent", function()
        local txt = string.sub(wordBox.Text, 1, 8)
        if #txt == 0 then setStatus("KETIK HURUF/ANGKA/KATA DULU (MAX 8)", true); return end
        local pts = generateWordPoints(txt, #workData.rig)
        if #pts > 0 then applyFormationPoints(pts, "KATA: " .. string.upper(txt)) else setStatus("KARAKTER TIDAK VALID (A-Z / 0-9)", true) end
    end)

    local previewFixtures = {}
    UI.fn.rebuildPreviewDots = function()
        local th = getCurrentTheme()
        for _, item in ipairs(previewFixtures) do
            if item.head then item.head:Destroy() end
            if item.beam then item.beam:Destroy() end
            if item.spot then item.spot:Destroy() end
            if item.prismRing then item.prismRing:Destroy() end
        end
        previewFixtures = {}
        local total = math.max(1, #workData.rig)
        for i = 1, total do
            local fix = workData.rig[i]
            local fx = math.clamp(tonumber(fix.x) or 0.5, 0.05, 0.95)
            local fy = math.clamp(tonumber(fix.y) or 0.25, 0.08, 0.92)
            local isSelectedNode = (i == state.activeLayoutNode)

            local beam = Instance.new("Frame", previewCanvas)
            beam.Size = UDim2.new(0, 12, 0, 50); beam.AnchorPoint = Vector2.new(0.5, 0.5); beam.BackgroundColor3 = th.accent; beam.BackgroundTransparency = 0.65; beam.BorderSizePixel = 0; beam.ZIndex = 6

            local head = Instance.new("TextButton", previewCanvas)
            head.Size = UDim2.new(0, 22, 0, 22); head.AnchorPoint = Vector2.new(0.5, 0.5); head.Text = tostring(i); head.Font = Enum.Font.GothamBold; head.TextSize = 10
            head.TextColor3 = th.btnText
            head.BackgroundColor3 = isSelectedNode and th.accent or (state.layoutEditMode and th.secondary or th.chipBg)
            if not isSelectedNode and not state.layoutEditMode then head.TextColor3 = th.ink end
            head.AutoButtonColor = false; head.BorderSizePixel = 0; head.ZIndex = 8
            applyConsoleStyle(head, 6)

            local spot = Instance.new("Frame", previewCanvas)
            spot.Size = UDim2.new(0, 12, 0, 12); spot.AnchorPoint = Vector2.new(0.5, 0.5); spot.BackgroundColor3 = th.accent; spot.BorderSizePixel = 0; spot.ZIndex = 7
            applyConsoleStyle(spot, 6)

            local prismRing = Instance.new("Frame", previewCanvas)
            prismRing.Size = UDim2.new(0, 24, 0, 24); prismRing.AnchorPoint = Vector2.new(0.5, 0.5); prismRing.BackgroundTransparency = 1; prismRing.Visible = false; prismRing.ZIndex = 7
            local prStroke = Instance.new("UIStroke", prismRing); prStroke.Color = Color3.fromRGB(255, 255, 255); prStroke.Thickness = 2

            head.Position = UDim2.new(fx, 0, fy, 0); spot.Position = UDim2.new(fx, 0, fy, 0); prismRing.Position = UDim2.new(fx, 0, fy, 0); beam.Position = UDim2.new(fx, 0, fy, 0)

            local draggingNode = false
            head.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    state.activeLayoutNode = i
                    dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", i, fix.x, fix.y)
                    if state.layoutEditMode then draggingNode = true end
                    for idxN, itN in ipairs(previewFixtures) do
                        local isN = (idxN == state.activeLayoutNode)
                        itN.head.BackgroundColor3 = isN and th.accent or (state.layoutEditMode and th.secondary or th.chipBg)
                        itN.head.TextColor3 = (isN or state.layoutEditMode) and th.btnText or th.ink
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingNode and state.layoutEditMode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local rx = math.clamp((input.Position.X - previewCanvas.AbsolutePosition.X) / math.max(1, previewCanvas.AbsoluteSize.X), 0.05, 0.95)
                    local ry = math.clamp((input.Position.Y - previewCanvas.AbsolutePosition.Y) / math.max(1, previewCanvas.AbsoluteSize.Y), 0.08, 0.92)
                    fix.x = math.floor(rx * 100 + 0.5) / 100; fix.y = math.floor(ry * 100 + 0.5) / 100
                    head.Position = UDim2.new(fix.x, 0, fix.y, 0); spot.Position = UDim2.new(fix.x, 0, fix.y, 0)
                    prismRing.Position = UDim2.new(fix.x, 0, fix.y, 0); beam.Position = UDim2.new(fix.x, 0, fix.y, 0)
                    dpadTargetLbl.Text = string.format("UNIT #%d (X:%.2f Y:%.2f)", i, fix.x, fix.y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingNode then
                        draggingNode = false
                        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
                        setStatus(string.format("POSISI #%d DISIMPAN (X:%.2f Y:%.2f)", i, fix.x, fix.y), false)
                    end
                end
            end)
            previewFixtures[i] = {head = head, beam = beam, spot = spot, prismRing = prismRing, fix = fix}
        end
    end

    pvViewTopBtn.MouseButton1Click:Connect(function() state.previewView = "top"; UI.fn.refreshPreviewToolbar(); UI.fn.rebuildPreviewDots() end)
    pvViewFrontBtn.MouseButton1Click:Connect(function() state.previewView = "front"; UI.fn.refreshPreviewToolbar(); UI.fn.rebuildPreviewDots() end)
    pvDragToggleBtn.MouseButton1Click:Connect(function()
        state.layoutEditMode = not state.layoutEditMode; UI.fn.refreshPreviewToolbar(); UI.fn.refreshSmartHint(); UI.fn.rebuildPreviewDots()
        setStatus(state.layoutEditMode and "MODE GESER LAYOUT AKTIF (SENTUH / D-PAD)" or "MODE SIMULASI STEP AKTIF", false)
    end)

    RunService.RenderStepped:Connect(function()
        if not pagePreview.Visible or not main.Visible then return end
        if #previewFixtures ~= #workData.rig then UI.fn.rebuildPreviewDots() end
        local th = getCurrentTheme()
        local totalSteps = #state.customSteps
        local activeFrame, nextFrame, frac = nil, nil, 0

        if not state.layoutEditMode and totalSteps > 0 then
            local rawPos = (os.clock() * state.stepRate) % totalSteps
            local idx1 = math.floor(rawPos) + 1
            local idx2 = (idx1 % totalSteps) + 1
            frac = rawPos - math.floor(rawPos)
            activeFrame = state.customSteps[idx1]; nextFrame = state.customSteps[idx2]
        end

        local totalFix = math.max(1, #previewFixtures)
        local cw = math.max(1, previewCanvas.AbsoluteSize.X)
        local ch = math.max(1, previewCanvas.AbsoluteSize.Y)

        for i, item in ipairs(previewFixtures) do
            local isSel = state.selectedMembers[i] == true
            item.head.Visible = isSel or state.layoutEditMode
            item.beam.Visible = isSel and (not state.layoutEditMode)
            item.spot.Visible = isSel and (not state.layoutEditMode)
            item.prismRing.Visible = false

            local fx = math.clamp(tonumber(item.fix.x) or 0.5, 0.05, 0.95)
            local fy = math.clamp(tonumber(item.fix.y) or 0.25, 0.08, 0.92)

            if state.layoutEditMode then
                item.head.Rotation = 0; item.head.Position = UDim2.new(fx, 0, fy, 0)
            elseif isSel then
                local panVal, tiltVal, dimVal, colVal = state.curPan, state.curTilt, state.curDim, state.curColor
                local rVal, gVal, bVal = state.presetR, state.presetG, state.presetB
                local hasRgb = false
                local hasPrism = (state.presetPrismVal > 0)
                local hasBlurOrFx = state.presetFocusBlur or state.presetOtherFxOn

                if state.curMirror and i > (totalFix / 2) then panVal = 1 - panVal end

                if activeFrame and activeFrame[tostring(i)] and activeFrame[tostring(i)].v then
                    local v1 = activeFrame[tostring(i)].v
                    panVal = v1.pan or 0.5; tiltVal = v1.tilt or 0.5
                    dimVal = v1.dim or v1.int or v1.r or v1.d1 or 1
                    colVal = v1.color or v1.col1 or 0
                    if v1.r ~= nil and v1.g ~= nil and v1.b ~= nil then rVal = v1.r; gVal = v1.g; bVal = v1.b; hasRgb = true end
                    hasPrism = (v1.prism and v1.prism > 0.01) or false
                    hasBlurOrFx = (v1.focus and v1.focus < 0.25) or (v1.frost and v1.frost > 0.1) or false
                    if state.stepGlide > 0 and nextFrame and nextFrame[tostring(i)] and nextFrame[tostring(i)].v then
                        local v2 = nextFrame[tostring(i)].v
                        local g = frac * state.stepGlide
                        panVal = panVal + (((v2.pan or panVal) - panVal) * g)
                        tiltVal = tiltVal + (((v2.tilt or tiltVal) - tiltVal) * g)
                    end
                end

                local startX, startY, targetX, targetY = fx, fy, fx, fy
                if state.previewView == "top" then
                    targetX = math.clamp(startX + ((panVal - 0.5) * 0.36), 0.04, 0.96)
                    targetY = math.clamp(startY + 0.16 + ((0.5 - tiltVal) * 0.42), 0.08, 0.92)
                else
                    targetX = math.clamp(startX + ((panVal - 0.5) * 0.44), 0.04, 0.96)
                    targetY = math.clamp(startY + 0.48 - (tiltVal * 0.42), 0.15, 0.92)
                end

                item.head.Position = UDim2.new(startX, 0, startY, 0)
                item.spot.Position = UDim2.new(targetX, 0, targetY, 0)
                item.prismRing.Position = UDim2.new(targetX, 0, targetY, 0)

                local dx = (targetX - startX) * cw
                local dy = (targetY - startY) * ch
                local dist = math.sqrt((dx * dx) + (dy * dy))
                local deg = math.deg(math.atan2(dy, dx)) - 90

                local beamWidth = hasBlurOrFx and 22 or (hasPrism and 16 or 11)
                item.beam.Position = UDim2.new(startX, dx * 0.5, startY, dy * 0.5)
                item.beam.Size = UDim2.new(0, beamWidth, 0, math.max(10, dist))
                item.beam.Rotation = deg; item.head.Rotation = deg

                if dimVal <= 0.05 then
                    item.beam.BackgroundTransparency = 0.96; item.spot.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                else
                    item.beam.BackgroundTransparency = hasBlurOrFx and 0.72 or 0.55
                    local beamCol = th.accent
                    if hasRgb and not (rVal == 1 and gVal == 1 and bVal == 1 and colVal == 0) then
                        beamCol = Color3.new(rVal, gVal, bVal)
                    elseif colVal > 0.02 then
                        beamCol = Color3.fromHSV(colVal % 1, 0.95, 1)
                    end
                    item.beam.BackgroundColor3 = beamCol; item.spot.BackgroundColor3 = beamCol
                    if hasPrism then
                        item.prismRing.Visible = true; item.prismRing.Rotation = (os.clock() * 140) % 360
                        local st = item.prismRing:FindFirstChildOfClass("UIStroke"); if st then st.Color = beamCol end
                    end
                end
            end
        end
    end)
end

do
    local secRgbPalette = makeSection(pageStatic, "1. PALET WARNA RGB & GOBO/PRISM INSTAN")
    local rgbGridWrap = Instance.new("Frame", secRgbPalette)
    rgbGridWrap.Size = UDim2.new(1, 0, 0, 0); rgbGridWrap.AutomaticSize = Enum.AutomaticSize.Y; rgbGridWrap.BackgroundTransparency = 1; rgbGridWrap.ZIndex = 5
    local rgbGrid = Instance.new("UIGridLayout", rgbGridWrap); rgbGrid.CellSize = UDim2.new(0.24, 0, 0, 24); rgbGrid.CellPadding = UDim2.new(0.013, 0, 0, 4)

    local activeSliderHandles = {}
    for _, rgbItem in ipairs(RGB_COLOR_PRESETS) do
        local b = Instance.new("TextButton", rgbGridWrap)
        b.BackgroundColor3 = rgbItem.color; b.Text = string.upper(rgbItem.name); b.Font = Enum.Font.GothamBold; b.TextSize = 8
        local lum = (rgbItem.color.R * 0.299) + (rgbItem.color.G * 0.587) + (rgbItem.color.B * 0.114)
        b.TextColor3 = (lum > 0.65) and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(255, 255, 255)
        b.BorderSizePixel = 0; b.ZIndex = 5
        applyConsoleStyle(b, 5)
        b.MouseButton1Click:Connect(function()
            for k, val in pairs(rgbItem.vals) do
                if state.editorValues[k] ~= nil then
                    state.editorValues[k] = val
                    if activeSliderHandles[k] then activeSliderHandles[k].setValue(val) end
                end
            end
            setStatus("WARNA/EFEK '" .. rgbItem.name .. "' DITERAPKAN", false)
        end)
    end

    local secStaticTop = makeSection(pageStatic, "2. EDITOR PARAMETER 12 FIXTURE & SIMPAN CUE STATIS")
    makeChipSelector(secStaticTop, "Target Layer Statis Cue:", {"dim", "pos", "beam"}, state.staticLayerType, function(v) state.staticLayerType = v end)
    makeChipSelector(secStaticTop, "Tipe Fixture:", {
        "clara", "strobe", "mapple", "parled", "fogger", "blinder",
        "flower", "pixel", "retro", "wall", "windmill", "sbar"
    }, state.editorFixtureType, function(v)
        state.editorFixtureType = v; state.editorValues = deepCopy(FIXTURE_DEFAULTS[v] or FIXTURE_DEFAULTS.clara)
        if UI.fn.rebuildDynamicFixtureSliders then UI.fn.rebuildDynamicFixtureSliders() end
    end)

    local dynamicSlidersContainer = Instance.new("Frame", secStaticTop)
    dynamicSlidersContainer.Size = UDim2.new(1, 0, 0, 0); dynamicSlidersContainer.AutomaticSize = Enum.AutomaticSize.Y; dynamicSlidersContainer.BackgroundTransparency = 1; dynamicSlidersContainer.ZIndex = 5
    local dynLayout = Instance.new("UIListLayout", dynamicSlidersContainer); dynLayout.Padding = UDim.new(0, 4)

    UI.fn.rebuildDynamicFixtureSliders = function()
        for _, child in ipairs(dynamicSlidersContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        activeSliderHandles = {}
        local keys = FIXTURE_KEYS_ORDER[state.editorFixtureType] or FIXTURE_KEYS_ORDER.clara
        for _, k in ipairs(keys) do
            activeSliderHandles[k] = makeSliderRow(dynamicSlidersContainer, string.upper(k) .. " (" .. k .. ")", 0, 1, state.editorValues[k] or 0, false, function(v)
                state.editorValues[k] = v
            end)
        end
    end

    local staticBtnRow = Instance.new("Frame", secStaticTop); staticBtnRow.Size = UDim2.new(1, 0, 0, 24); staticBtnRow.BackgroundTransparency = 1; staticBtnRow.ZIndex = 5
    makeSmallActionBtn(staticBtnRow, "Simpan Cue Statis", 0, 145, "accent", function()
        UI.fn.executeWithRigCheck(state.cueId, function()
            local fxMap = {}
            for _, idx in ipairs(getSelectedMemberIndices()) do
                local fix = workData.rig[idx]
                if fix then local fType = string.lower(fix.t or "clara"); fxMap[tostring(idx)] = {t = fType, v = makeFullV(fType, state.editorValues)} end
            end
            workData.cues[state.cueId] = {layer = state.staticLayerType, fx = fxMap, eff = {}}
            if uiPrefs.autoSaveOnSaveCue then saveWorkFile() end
            if UI.fn.refreshCueGridUI then UI.fn.refreshCueGridUI() end
            setStatus("STATIC [" .. state.staticLayerType .. "] -> CUE " .. state.cueId, false)
        end)
    end)
    makeSmallActionBtn(staticBtnRow, "Set Default Rig", 151, 135, "secondary", function()
        for _, idx in ipairs(getSelectedMemberIndices()) do
            local fix = workData.rig[idx]; if fix then fix.v = makeFullV(fix.t, state.editorValues) end
        end
        setStatus("DEFAULT RIG DIPERBARUI", false)
    end)
end

do
    local secRigGen = makeSection(pageRig, "1. UNIVERSE (U1-U16) & ADDRESS DMX (1-512) GENERATOR")
    UI.targets["rig_patch"] = secRigGen

    makeChipSelector(secRigGen, "Pilih Jenis Fixture:", {
        "clara", "strobe", "mapple", "parled", "fogger", "blinder",
        "flower", "pixel", "retro", "wall", "windmill", "sbar"
    }, state.rigType, function(v) state.rigType = v end)
    makeSliderRow(secRigGen, "Jumlah Unit (32+ Auto U2)", 1, 64, state.rigCount, true, function(v) state.rigCount = v end)
    makeSliderRow(secRigGen, "Universe Awal (1 - 16)", 1, 16, state.rigStartUniverse, true, function(v) state.rigStartUniverse = v end)
    makeSliderRow(secRigGen, "Address DMX Awal (1-512)", 1, 512, state.rigStartAddr, true, function(v) state.rigStartAddr = v end)
    makeChipSelector(secRigGen, "Mode Address DMX:", {"independen", "multi"}, state.rigMode, function(v) state.rigMode = v end)

    local rigBtnRow = Instance.new("Frame", secRigGen); rigBtnRow.Size = UDim2.new(1, 0, 0, 22); rigBtnRow.BackgroundTransparency = 1; rigBtnRow.ZIndex = 5

    makeSmallActionBtn(rigBtnRow, "Ganti Semua Rig", 0, 114, "accent", function()
        workData.rig = buildAutoPatchedRig(state.rigType, state.rigCount, state.rigStartUniverse, state.rigStartAddr, state.rigMode, nil)
        state.rigConfigured = true; resetSelectionAll()
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
        if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
        setStatus("RIG BARU: " .. #workData.rig .. " UNIT", false)
    end)

    local btnAddGroup = makeSmallActionBtn(rigBtnRow, "+ Tambah Kelompok", 119, 132, "secondary", function()
        local lastU, lastA = state.rigStartUniverse, state.rigStartAddr
        if #workData.rig > 0 then
            local lastFix = workData.rig[#workData.rig]
            local fp = FIXTURE_FOOTPRINTS[string.lower(lastFix.t or "clara")] or 16
            _, _, lastU, lastA = advanceUniverseAddress(lastFix.u or 1, lastFix.a or 1, fp)
        end
        workData.rig = buildAutoPatchedRig(state.rigType, state.rigCount, lastU, lastA, state.rigMode, workData.rig)
        state.rigConfigured = true; resetSelectionAll()
        if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
        if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
        if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
        setStatus("+ " .. state.rigCount .. " " .. string.upper(state.rigType) .. " (TOTAL " .. #workData.rig .. ")", false)
    end)
    UI.targets["rig_add_group"] = btnAddGroup

    local secRigManual = makeSection(pageRig, "2. EDITOR MANUAL UNIVERSE (U), ADDRESS (A) & POSISI X/Y")
    UI.targets["rig_manual"] = secRigManual

    local rigEditorContainer = Instance.new("Frame", secRigManual)
    rigEditorContainer.Size = UDim2.new(1, 0, 0, 0); rigEditorContainer.AutomaticSize = Enum.AutomaticSize.Y; rigEditorContainer.BackgroundTransparency = 1; rigEditorContainer.ZIndex = 5
    local rigEdLayout = Instance.new("UIListLayout", rigEditorContainer); rigEdLayout.Padding = UDim.new(0, 4)

    UI.fn.refreshRigEditorUI = function()
        local th = getCurrentTheme()
        for _, child in ipairs(rigEditorContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for i, fix in ipairs(workData.rig) do
            local row = Instance.new("Frame", rigEditorContainer)
            row.Size = UDim2.new(1, 0, 0, 23); row.BackgroundColor3 = th.surface; row.BorderSizePixel = 0; row.ZIndex = 5
            applyConsoleStyle(row, 5)

            local fp = FIXTURE_FOOTPRINTS[string.lower(fix.t or "clara")] or 16
            local info = Instance.new("TextLabel", row)
            info.Size = UDim2.new(0, 102, 1, 0); info.Position = UDim2.new(0, 6, 0, 0); info.BackgroundTransparency = 1
            info.Text = string.format("#%02d %-6s(%dc)", i, string.upper(fix.t), fp)
            info.Font = Enum.Font.GothamBold; info.TextSize = 9; info.TextColor3 = th.ink; info.TextXAlignment = Enum.TextXAlignment.Left; info.ZIndex = 5

            local uBox = Instance.new("TextBox", row)
            uBox.Size = UDim2.new(0, 28, 0, 18); uBox.Position = UDim2.new(0, 110, 0.5, -9)
            uBox.BackgroundColor3 = th.secondary; uBox.Text = tostring(fix.u or 1); uBox.Font = Enum.Font.Code; uBox.TextSize = 10; uBox.TextColor3 = th.btnText
            uBox.ClearTextOnFocus = false; uBox.BorderSizePixel = 0; uBox.ZIndex = 5
            applyConsoleStyle(uBox, 4)
            uBox.FocusLost:Connect(function()
                local n = tonumber(uBox.Text)
                if n and n >= 1 and n <= 16 then fix.u = math.floor(n); uBox.Text = tostring(fix.u); if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
                else uBox.Text = tostring(fix.u or 1) end
            end)

            local addrBox = Instance.new("TextBox", row)
            addrBox.Size = UDim2.new(0, 36, 0, 18); addrBox.Position = UDim2.new(0, 142, 0.5, -9)
            addrBox.BackgroundColor3 = th.accent; addrBox.Text = tostring(fix.a); addrBox.Font = Enum.Font.Code; addrBox.TextSize = 10; addrBox.TextColor3 = th.btnText
            addrBox.ClearTextOnFocus = false; addrBox.BorderSizePixel = 0; addrBox.ZIndex = 5
            applyConsoleStyle(addrBox, 4)
            addrBox.FocusLost:Connect(function()
                local n = tonumber(addrBox.Text)
                if n and n >= 1 and n <= 512 then fix.a = math.floor(n); addrBox.Text = tostring(fix.a); if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
                else addrBox.Text = tostring(fix.a) end
            end)

            local xBox = Instance.new("TextBox", row)
            xBox.Size = UDim2.new(0, 36, 0, 18); xBox.Position = UDim2.new(0, 182, 0.5, -9)
            xBox.BackgroundColor3 = th.chipBg; xBox.Text = string.format("%.2f", fix.x or 0.5); xBox.Font = Enum.Font.Code; xBox.TextSize = 9; xBox.TextColor3 = th.ink
            xBox.ClearTextOnFocus = false; xBox.BorderSizePixel = 0; xBox.ZIndex = 5
            applyConsoleStyle(xBox, 4)
            xBox.FocusLost:Connect(function()
                local n = tonumber(xBox.Text)
                if n then fix.x = math.clamp(math.floor(n * 100 + 0.5) / 100, 0.05, 0.95); xBox.Text = string.format("%.2f", fix.x); if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
                else xBox.Text = string.format("%.2f", fix.x or 0.5) end
            end)

            local yBox = Instance.new("TextBox", row)
            yBox.Size = UDim2.new(0, 36, 0, 18); yBox.Position = UDim2.new(0, 222, 0.5, -9)
            yBox.BackgroundColor3 = th.chipBg; yBox.Text = string.format("%.2f", fix.y or 0.25); yBox.Font = Enum.Font.Code; yBox.TextSize = 9; yBox.TextColor3 = th.ink
            yBox.ClearTextOnFocus = false; yBox.BorderSizePixel = 0; yBox.ZIndex = 5
            applyConsoleStyle(yBox, 4)
            yBox.FocusLost:Connect(function()
                local n = tonumber(yBox.Text)
                if n then fix.y = math.clamp(math.floor(n * 100 + 0.5) / 100, 0.08, 0.92); yBox.Text = string.format("%.2f", fix.y); if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
                else yBox.Text = string.format("%.2f", fix.y or 0.25) end
            end)

            local delBtn = Instance.new("TextButton", row)
            delBtn.Size = UDim2.new(0, 34, 0, 18); delBtn.Position = UDim2.new(1, -38, 0.5, -9)
            delBtn.BackgroundColor3 = th.danger; delBtn.Text = "DEL"; delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 8; delBtn.TextColor3 = Color3.fromRGB(255, 255, 255); delBtn.BorderSizePixel = 0; delBtn.ZIndex = 5
            applyConsoleStyle(delBtn, 4)
            delBtn.MouseButton1Click:Connect(function()
                if #workData.rig > 1 then
                    table.remove(workData.rig, i); resetSelectionAll()
                    UI.fn.refreshMembersUI(); UI.fn.refreshRigEditorUI(); UI.fn.rebuildPreviewDots()
                end
            end)
        end
    end
end

do
    local secCueGrid = makeSection(pageCues, "PILIH & SIMPAN KE SLOT CUE 1 - 24 (RKDESIGN)")
    local cueQuickRow = Instance.new("Frame", secCueGrid); cueQuickRow.Size = UDim2.new(1, 0, 0, 22); cueQuickRow.BackgroundTransparency = 1; cueQuickRow.ZIndex = 5

    makeSmallActionBtn(cueQuickRow, "Simpan ke Cue Aktif", 0, 125, "accent", function() UI.fn.saveCurrentStepsToCue(state.cueId) end)
    makeSmallActionBtn(cueQuickRow, "Atur DMX", 130, 74, "secondary", function() UI.fn.openRigSetupModal(function() setStatus("DMX DIPERBARUI", false) end) end)
    makeSmallActionBtn(cueQuickRow, "Hapus Cue", 209, 76, "danger", function()
        workData.cues[state.cueId] = nil
        if uiPrefs.autoSaveOnSaveCue then saveWorkFile() end
        UI.fn.refreshCueGridUI(); setStatus("CUE " .. state.cueId .. " DIHAPUS", false)
    end)

    local cueGridWrap = Instance.new("Frame", secCueGrid)
    cueGridWrap.Size = UDim2.new(1, 0, 0, 0); cueGridWrap.AutomaticSize = Enum.AutomaticSize.Y; cueGridWrap.BackgroundTransparency = 1; cueGridWrap.ZIndex = 5
    local cueGridLayout = Instance.new("UIGridLayout", cueGridWrap); cueGridLayout.CellSize = UDim2.new(0.24, 0, 0, 30); cueGridLayout.CellPadding = UDim2.new(0.013, 0, 0, 4)

    UI.fn.refreshCueGridUI = function()
        local th = getCurrentTheme()
        for _, child in ipairs(cueGridWrap:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i = 1, 24 do
            local k = tostring(i)
            local c = workData.cues[k]
            local isSelCue = (k == state.cueId)
            local sub = "kosong"
            if c then
                if c.layer == "chs" and c.chase and c.chase.steps then sub = #c.chase.steps .. " STEP"
                else sub = string.upper(tostring(c.layer)) end
            end
            local cb = Instance.new("TextButton", cueGridWrap)
            cb.BackgroundColor3 = isSelCue and th.accent or (c and th.secondary or th.surface)
            cb.Text = "Cue " .. i .. "\n" .. sub; cb.Font = Enum.Font.GothamBold; cb.TextSize = 8
            cb.TextColor3 = (isSelCue or c) and th.btnText or th.ink
            cb.BorderSizePixel = 0; cb.ZIndex = 5
            applyConsoleStyle(cb, 5)
            cb.MouseButton1Click:Connect(function()
                state.cueId = k
                if UI.cueIdBox then UI.cueIdBox.Text = k end
                if c and c.layer == "chs" and type(c.chase) == "table" then
                    state.customSteps = deepCopy(c.chase.steps or {})
                    state.stepRate = tonumber(c.chase.rate) or 2.5
                    state.stepGlide = tonumber(c.chase.glide) or 0.35
                    state.stepDir = c.chase.dir or ">"
                    if UI.sldPresetRate then UI.sldPresetRate.setValue(state.stepRate) end
                    if UI.sldPresetGlide then UI.sldPresetGlide.setValue(state.stepGlide) end
                    if UI.chipPresetDir then UI.chipPresetDir.setSelected(state.stepDir) end
                    if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
                    UI.fn.refreshSmartHint(); setStatus("CUE " .. k .. " (" .. #state.customSteps .. " STEP) DIMUAT", false)
                elseif not c and uiPrefs.promptRigOnNewCue then
                    UI.fn.openRigSetupModal(function() setStatus("CUE " .. k .. " DIPILIH (SIAP SIMPAN)", false) end)
                else
                    setStatus("CUE " .. k .. " DIPILIH", false)
                end
                UI.fn.refreshCueGridUI()
            end)
        end
    end
end

do
    local secSetLang = makeSection(pageSettings, "1. PILIH BAHASA TAMPILAN (5 BAHASA)")
    makeChipSelector(secSetLang, "Bahasa Menu & Panduan:", {"Sehari-hari", "Indonesia", "Jawa", "Sunda", "English"}, uiPrefs.langName, function(v)
        uiPrefs.langName = v; savePrefs(); UI.fn.applyLanguageTexts(); setStatus("BAHASA: " .. string.upper(v), false)
    end)

    local secSetScale = makeSection(pageSettings, "2. UKURAN JENDELA (PANJANG/LEBAR/TINGGI) & SKALA (0.20 - 1.30)")
    local sldUiScale = makeSliderRow(secSetScale, "Skala UI (0.20 - 1.30)", 0.20, 1.30, uiPrefs.uiScale, false, function(v) uiPrefs.uiScale = v; uiScaleObj.Scale = v; savePrefs() end)
    local sldWinW = makeSliderRow(secSetScale, "Lebar Jendela (320 - 950)", 320, 950, uiPrefs.winWidth, true, function(v) uiPrefs.winWidth = v; main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight); savePrefs() end)
    local sldWinH = makeSliderRow(secSetScale, "Tinggi Jendela (220 - 700)", 220, 700, uiPrefs.winHeight, true, function(v) uiPrefs.winHeight = v; main.Size = UDim2.new(0, uiPrefs.winWidth, 0, uiPrefs.winHeight); savePrefs() end)
    makeSliderRow(secSetScale, "Ukuran Bubble (36 - 66 px)", 36, 66, uiPrefs.bubbleSize, true, function(v) uiPrefs.bubbleSize = v; UI.bubbleBtn.Size = UDim2.new(0, v, 0, v); savePrefs() end)

    local secSetTheme = makeSection(pageSettings, "3. GAYA CONSOLE (RK CONSOLE DEFAULT), TRANSPARANSI & BLUR")
    makeChipSelector(secSetTheme, "Tema Tampilan UI:", {"RK Console", "RK Emerald", "OLED Midnight", "Brutal Dark"}, uiPrefs.themeName, function(v)
        uiPrefs.themeName = v; savePrefs(); UI.fn.applyFullTheme(); setStatus("TEMA: " .. v, false)
    end)
    makeSliderRow(secSetTheme, "Transparansi UI (0.00 - 0.75)", 0.0, 0.75, uiPrefs.bgTransparency, false, function(v) uiPrefs.bgTransparency = v; savePrefs(); UI.fn.applyFullTheme() end)

    local blurToggleBtn = Instance.new("TextButton", secSetTheme)
    blurToggleBtn.Size = UDim2.new(1, 0, 0, 24); blurToggleBtn.Text = uiPrefs.enableBlur and "EFEK BLUR LAYAR BELAKANG: AKTIF (ON)" or "EFEK BLUR LAYAR BELAKANG: MATI (OFF)"
    blurToggleBtn.Font = Enum.Font.GothamBold; blurToggleBtn.TextSize = 9; blurToggleBtn.BorderSizePixel = 0; blurToggleBtn.ZIndex = 5
    registerTheme(blurToggleBtn, uiPrefs.enableBlur and "accent" or "surface", "BackgroundColor3"); registerTheme(blurToggleBtn, uiPrefs.enableBlur and "btnText" or "ink", "TextColor3")
    applyConsoleStyle(blurToggleBtn, 5)
    UI.blurToggleBtn = blurToggleBtn

    blurToggleBtn.MouseButton1Click:Connect(function()
        uiPrefs.enableBlur = not uiPrefs.enableBlur
        if UI.blurEffect then UI.blurEffect.Size = uiPrefs.enableBlur and 8 or 0; UI.blurEffect.Enabled = uiPrefs.enableBlur and main.Visible end
        blurToggleBtn.Text = uiPrefs.enableBlur and "EFEK BLUR LAYAR BELAKANG: AKTIF (ON)" or "EFEK BLUR LAYAR BELAKANG: MATI (OFF)"
        local th = getCurrentTheme(); blurToggleBtn.BackgroundColor3 = uiPrefs.enableBlur and th.accent or th.surface; blurToggleBtn.TextColor3 = uiPrefs.enableBlur and th.btnText or th.ink; savePrefs()
    end)

    local secSetOpt = makeSection(pageSettings, "4. OPTIMASI PROMPT DMX & RESET")
    local promptRigBtn = Instance.new("TextButton", secSetOpt)
    promptRigBtn.Size = UDim2.new(1, 0, 0, 24); promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA UNIVERSE/DMX SAAT SIMPAN CUE BARU: AKTIF" or "TANYA UNIVERSE/DMX SAAT SIMPAN CUE BARU: MATI"
    promptRigBtn.Font = Enum.Font.GothamBold; promptRigBtn.TextSize = 9; promptRigBtn.BorderSizePixel = 0; promptRigBtn.ZIndex = 5
    registerTheme(promptRigBtn, uiPrefs.promptRigOnNewCue and "accent" or "surface", "BackgroundColor3"); registerTheme(promptRigBtn, uiPrefs.promptRigOnNewCue and "btnText" or "ink", "TextColor3")
    applyConsoleStyle(promptRigBtn, 5)
    UI.promptRigBtn = promptRigBtn

    promptRigBtn.MouseButton1Click:Connect(function()
        uiPrefs.promptRigOnNewCue = not uiPrefs.promptRigOnNewCue
        promptRigBtn.Text = uiPrefs.promptRigOnNewCue and "TANYA UNIVERSE/DMX SAAT SIMPAN CUE BARU: AKTIF" or "TANYA UNIVERSE/DMX SAAT SIMPAN CUE BARU: MATI"
        local th = getCurrentTheme(); promptRigBtn.BackgroundColor3 = uiPrefs.promptRigOnNewCue and th.accent or th.surface; promptRigBtn.TextColor3 = uiPrefs.promptRigOnNewCue and th.btnText or th.ink; savePrefs()
    end)

    local setBtnRow = Instance.new("Frame", secSetOpt); setBtnRow.Size = UDim2.new(1, 0, 0, 22); setBtnRow.BackgroundTransparency = 1; setBtnRow.ZIndex = 5
    makeSmallActionBtn(setBtnRow, "Salin JSON Minify", 0, 125, "secondary", function()
        if setclipboard then
            workData = sanitizeWorkStructure(workData)
            local ok, enc = pcall(function() return HttpService:JSONEncode(workData) end)
            if ok then setclipboard(string.gsub(enc, "[\r\n]", "")); setStatus("JSON MINIFY DISALIN", false) end
        else setStatus("NO SETCLIPBOARD", true) end
    end)
    makeSmallActionBtn(setBtnRow, "Reset Ukuran & Posisi", 131, 145, "surface", function()
        uiPrefs.uiScale = 1.0; uiPrefs.winWidth = 540; uiPrefs.winHeight = 355; uiScaleObj.Scale = 1.0
        main.Size = UDim2.new(0, 540, 0, 355); main.Position = UDim2.new(0.5, 0, 0.52, 0); UI.bubbleBtn.Position = UDim2.new(0.03, 0, 0.25, 0)
        sldUiScale.setValue(1.0); sldWinW.setValue(540); sldWinH.setValue(355); savePrefs(); setStatus("UKURAN & POSISI DIRESET", false)
    end)
end

do
    local cueLabelFooter = Instance.new("TextLabel", UI.footerBar)
    cueLabelFooter.Size = UDim2.new(0, 44, 1, 0); cueLabelFooter.Position = UDim2.new(0, 8, 0, 0); cueLabelFooter.BackgroundTransparency = 1
    cueLabelFooter.Text = "CUE:"; cueLabelFooter.Font = Enum.Font.GothamBold; cueLabelFooter.TextSize = 10; cueLabelFooter.TextXAlignment = Enum.TextXAlignment.Left; cueLabelFooter.ZIndex = 4
    registerTheme(cueLabelFooter, "ink", "TextColor3")

    local cueIdBox = Instance.new("TextBox", UI.footerBar)
    cueIdBox.Size = UDim2.new(0, 38, 0, 20); cueIdBox.Position = UDim2.new(0, 44, 0.5, -10); cueIdBox.Text = state.cueId
    cueIdBox.Font = Enum.Font.Code; cueIdBox.TextSize = 11; cueIdBox.ClearTextOnFocus = false; cueIdBox.BorderSizePixel = 0; cueIdBox.ZIndex = 4
    registerTheme(cueIdBox, "accent", "BackgroundColor3"); registerTheme(cueIdBox, "btnText", "TextColor3")
    applyConsoleStyle(cueIdBox, 5)
    UI.cueIdBox = cueIdBox

    cueIdBox.FocusLost:Connect(function()
        local clean = string.gsub(cueIdBox.Text, "%s+", "")
        if #clean > 0 then state.cueId = clean else cueIdBox.Text = state.cueId end
        if UI.fn.refreshCueGridUI then UI.fn.refreshCueGridUI() end
    end)

    local saveCueFooterBtn = Instance.new("TextButton", UI.footerBar)
    saveCueFooterBtn.Size = UDim2.new(0, 114, 0, 20); saveCueFooterBtn.Position = UDim2.new(1, -254, 0.5, -10); saveCueFooterBtn.Text = tr("btn_save_cue")
    saveCueFooterBtn.Font = Enum.Font.GothamBold; saveCueFooterBtn.TextSize = 10; saveCueFooterBtn.BorderSizePixel = 0; saveCueFooterBtn.ZIndex = 4
    registerTheme(saveCueFooterBtn, "secondary", "BackgroundColor3"); registerTheme(saveCueFooterBtn, "btnText", "TextColor3")
    applyConsoleStyle(saveCueFooterBtn, 5)
    UI.saveCueFooterBtn = saveCueFooterBtn
    UI.targets["footer_save"] = saveCueFooterBtn
    saveCueFooterBtn.MouseButton1Click:Connect(function() UI.fn.saveCurrentStepsToCue(state.cueId) end)

    local saveWorkFooterBtn = Instance.new("TextButton", UI.footerBar)
    saveWorkFooterBtn.Size = UDim2.new(0, 130, 0, 20); saveWorkFooterBtn.Position = UDim2.new(1, -134, 0.5, -10); saveWorkFooterBtn.Text = tr("btn_export")
    saveWorkFooterBtn.Font = Enum.Font.GothamBold; saveWorkFooterBtn.TextSize = 10; saveWorkFooterBtn.BorderSizePixel = 0; saveWorkFooterBtn.ZIndex = 4
    registerTheme(saveWorkFooterBtn, "accent", "BackgroundColor3"); registerTheme(saveWorkFooterBtn, "btnText", "TextColor3")
    applyConsoleStyle(saveWorkFooterBtn, 5)
    UI.saveWorkFooterBtn = saveWorkFooterBtn
    UI.targets["footer_export"] = saveWorkFooterBtn
    saveWorkFooterBtn.MouseButton1Click:Connect(function()
        local ok, msg = saveWorkFile(); setStatus(msg, not ok)
    end)
end

UI.fn.applyLanguageTexts = function()
    UI.guideTopBtn.Text = tr("btn_guide"); UI.saveCueFooterBtn.Text = tr("btn_save_cue"); UI.saveWorkFooterBtn.Text = tr("btn_export")
    UI.btnSaveCueMid.Text = tr("btn_save_cue"); UI.btnRecStep.Text = tr("btn_rec_step"); UI.btnDelAllSteps.Text = tr("btn_del_all")
    UI.mirrorBtn.Text = state.curMirror and tr("btn_mirror_on") or tr("btn_mirror_off")
    if UI.sldPresetRate and UI.sldPresetRate.label then UI.sldPresetRate.label.Text = tr("lbl_rate") end
    if UI.sldPresetGlide and UI.sldPresetGlide.label then UI.sldPresetGlide.label.Text = tr("lbl_glide") end
    if UI.sldCustomPan and UI.sldCustomPan.label then UI.sldCustomPan.label.Text = tr("lbl_pan") end
    if UI.sldCustomTilt and UI.sldCustomTilt.label then UI.sldCustomTilt.label.Text = tr("lbl_tilt") end
    if UI.sldCustomDim and UI.sldCustomDim.label then UI.sldCustomDim.label.Text = tr("lbl_dim") end
    if UI.sldCustomColor and UI.sldCustomColor.label then UI.sldCustomColor.label.Text = tr("lbl_color") end
    if UI.sldCustomStrobe and UI.sldCustomStrobe.label then UI.sldCustomStrobe.label.Text = tr("lbl_strobe") end
    UI.fn.refreshTabStyles(); UI.fn.refreshSmartHint()
end

UI.fn.applyFullTheme = function()
    local th = getCurrentTheme()
    for _, item in ipairs(UI.themeBindings) do
        if item.obj and item.obj.Parent then item.obj[item.prop] = th[item.role] end
    end
    main.BackgroundTransparency = uiPrefs.bgTransparency; UI.navBar.BackgroundTransparency = uiPrefs.bgTransparency
    UI.contentArea.BackgroundTransparency = uiPrefs.bgTransparency; UI.hintBanner.BackgroundTransparency = uiPrefs.bgTransparency
    UI.footerBar.BackgroundTransparency = uiPrefs.bgTransparency; UI.topBar.BackgroundTransparency = math.clamp(uiPrefs.bgTransparency * 0.4, 0, 0.4)
    for _, sec in ipairs(UI.sectionFrames) do if sec and sec.Parent then sec.BackgroundTransparency = uiPrefs.bgTransparency end end
    for _, desc in ipairs(screen:GetDescendants()) do
        if desc:IsA("UIStroke") and desc.Parent and desc.Parent.Name ~= "TutorialSpotlight" then
            desc.Thickness = th.isBrutal and 2 or uiPrefs.borderThickness; desc.Color = th.stroke
        elseif desc:IsA("UICorner") and desc.Parent and desc.Parent.Name ~= "TutorialSpotlight" then
            desc.CornerRadius = UDim.new(0, th.corner or 6)
        end
    end
    UI.blurToggleBtn.BackgroundColor3 = uiPrefs.enableBlur and th.accent or th.surface; UI.blurToggleBtn.TextColor3 = uiPrefs.enableBlur and th.btnText or th.ink
    UI.promptRigBtn.BackgroundColor3 = uiPrefs.promptRigOnNewCue and th.accent or th.surface; UI.promptRigBtn.TextColor3 = uiPrefs.promptRigOnNewCue and th.btnText or th.ink
    UI.mirrorBtn.BackgroundColor3 = state.curMirror and th.secondary or th.surface; UI.mirrorBtn.TextColor3 = state.curMirror and th.btnText or th.ink
    if UI.fn.refreshBeamToggles then UI.fn.refreshBeamToggles() end
    if UI.fn.refreshChainButtons then UI.fn.refreshChainButtons() end
    UI.fn.refreshPreviewToolbar(); UI.fn.refreshTabStyles()
    for _, cs in ipairs(UI.chipSelectorsList) do cs.retheme() end
    if UI.fn.refreshMembersUI then UI.fn.refreshMembersUI() end
    if UI.fn.refreshCustomStepsListUI then UI.fn.refreshCustomStepsListUI() end
    if UI.fn.refreshCueGridUI then UI.fn.refreshCueGridUI() end
    if UI.fn.refreshRigEditorUI then UI.fn.refreshRigEditorUI() end
    if UI.fn.rebuildPreviewDots then UI.fn.rebuildPreviewDots() end
end

UI.fn.rebuildDynamicFixtureSliders()
UI.fn.refreshMembersUI()
UI.fn.refreshCustomStepsListUI()
UI.fn.refreshCueGridUI()
UI.fn.refreshRigEditorUI()
UI.fn.rebuildPreviewDots()
UI.fn.applyLanguageTexts()
UI.fn.applyFullTheme()
UI.fn.switchTab("presets")
