-- ============================================================
--  MyHub  |  Roblox Script Hub  (Mobile-kompatibel)
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

local SETTINGS = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed  = 50,
    ESPColor  = Color3.fromRGB(255, 50, 50),
}

-- ============================================================
--  Hilfsfunktionen
-- ============================================================
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3,
        })
    end)
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25), props):Play()
end

-- ============================================================
--  GUI Parent – pcall-sicher für alle Executors
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "MyHub"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.DisplayOrder   = 999

local ok = false
-- gethui (Delta, Arceus X, Fluxus …)
if not ok then
    ok = pcall(function()
        screenGui.Parent = gethui()
    end)
end
-- Synapse X
if not ok then
    ok = pcall(function()
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    end)
end
-- CoreGui direkt
if not ok then
    ok = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
end
-- Fallback PlayerGui
if not ok then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- ============================================================
--  Hauptfenster
-- ============================================================
local WIN_W = 360
local WIN_H = 460

local mainFrame = Instance.new("Frame")
mainFrame.Name             = "MainFrame"
mainFrame.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
mainFrame.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BorderSizePixel  = 0
mainFrame.Active           = true
mainFrame.Draggable        = true
mainFrame.ZIndex           = 1
mainFrame.Parent           = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Titelleiste
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 40)
titleBar.Position         = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BorderSizePixel  = 0
titleBar.ZIndex           = 2
titleBar.Parent           = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size                 = UDim2.new(1, -50, 1, 0)
titleLabel.Position             = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text                 = "⚡ MyHub"
titleLabel.TextColor3           = Color3.fromRGB(200, 180, 255)
titleLabel.TextSize             = 18
titleLabel.Font                 = Enum.Font.GothamBold
titleLabel.TextXAlignment       = Enum.TextXAlignment.Left
titleLabel.ZIndex               = 3
titleLabel.Parent               = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size             = UDim2.new(0, 30, 0, 30)
closeBtn.Position         = UDim2.new(1, -36, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text             = "✕"
closeBtn.TextColor3       = Color3.new(1, 1, 1)
closeBtn.TextSize         = 14
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.AutoButtonColor  = false
closeBtn.ZIndex           = 3
closeBtn.Parent           = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ============================================================
--  Scroll-System (kein ScrollingFrame, kein AutomaticSize)
-- ============================================================
-- Viewport – zeigt den sichtbaren Ausschnitt
local VIEWPORT_X  = 10
local VIEWPORT_Y  = 46
local VIEWPORT_W  = WIN_W - 20
local VIEWPORT_H  = WIN_H - 56

local viewport = Instance.new("Frame")
viewport.Name                  = "Viewport"
viewport.Size                  = UDim2.new(0, VIEWPORT_W, 0, VIEWPORT_H)
viewport.Position              = UDim2.new(0, VIEWPORT_X, 0, VIEWPORT_Y)
viewport.BackgroundTransparency = 1
viewport.ClipsDescendants      = true
viewport.BorderSizePixel       = 0
viewport.ZIndex                = 2
viewport.Parent                = mainFrame

-- Innerer Rahmen mit allen Buttons – feste große Höhe
-- Jeder Eintrag: Section=22px, Toggle/Button=38px, Padding=8px
-- 4 Sections + 10 Toggles + 6 Buttons + 19 Lücken = 88+380+228+152 = 848px → 900px reicht sicher
local CONTENT_H = 900
local contentFrame = Instance.new("Frame")
contentFrame.Name                   = "Content"
contentFrame.Size                   = UDim2.new(0, VIEWPORT_W - 8, 0, CONTENT_H)
contentFrame.Position               = UDim2.new(0, 0, 0, 4)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel        = 0
contentFrame.ZIndex                 = 2
contentFrame.Parent                 = viewport

local listLayout = Instance.new("UIListLayout")
listLayout.Padding         = UDim.new(0, 8)
listLayout.SortOrder       = Enum.SortOrder.LayoutOrder
listLayout.Parent          = contentFrame

-- Scroll-Offset und Scroll-Buttons
local scrollY    = 0
local STEP       = 100

local function applyScroll()
    local maxScroll = math.max(0, CONTENT_H - VIEWPORT_H)
    scrollY = math.clamp(scrollY, 0, maxScroll)
    contentFrame.Position = UDim2.new(0, 0, 0, 4 - scrollY)
end

local btnUp = Instance.new("TextButton")
btnUp.Size             = UDim2.new(0, 28, 0, 28)
btnUp.Position         = UDim2.new(1, -34, 0, 46)
btnUp.BackgroundColor3 = Color3.fromRGB(55, 55, 85)
btnUp.Text             = "▲"
btnUp.TextColor3       = Color3.new(1, 1, 1)
btnUp.TextSize         = 14
btnUp.Font             = Enum.Font.GothamBold
btnUp.AutoButtonColor  = false
btnUp.ZIndex           = 5
btnUp.Parent           = mainFrame
Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 4)
btnUp.MouseButton1Click:Connect(function()
    scrollY = scrollY - STEP
    applyScroll()
end)

local btnDown = Instance.new("TextButton")
btnDown.Size             = UDim2.new(0, 28, 0, 28)
btnDown.Position         = UDim2.new(1, -34, 1, -34)
btnDown.BackgroundColor3 = Color3.fromRGB(55, 55, 85)
btnDown.Text             = "▼"
btnDown.TextColor3       = Color3.new(1, 1, 1)
btnDown.TextSize         = 14
btnDown.Font             = Enum.Font.GothamBold
btnDown.AutoButtonColor  = false
btnDown.ZIndex           = 5
btnDown.Parent           = mainFrame
Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 4)
btnDown.MouseButton1Click:Connect(function()
    scrollY = scrollY + STEP
    applyScroll()
end)

-- ============================================================
--  Button-Fabrik
-- ============================================================
local itemOrder = 0
local function nextOrder()
    itemOrder = itemOrder + 1
    return itemOrder
end

local function makeSection(label)
    local lbl = Instance.new("TextLabel")
    lbl.Size                  = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text                  = "  " .. label
    lbl.TextColor3            = Color3.fromRGB(160, 140, 220)
    lbl.TextSize              = 13
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.ZIndex                = 3
    lbl.LayoutOrder           = nextOrder()
    lbl.Parent                = contentFrame
end

local function makeToggle(label, callback)
    local active = false
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text             = "[ OFF ]  " .. label
    btn.TextColor3       = Color3.fromRGB(180, 180, 180)
    btn.TextSize         = 14
    btn.Font             = Enum.Font.Gotham
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.AutoButtonColor  = false
    btn.ZIndex           = 3
    btn.LayoutOrder      = nextOrder()
    btn.Parent           = contentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn

    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text             = "[ ON  ]  " .. label
            btn.TextColor3       = Color3.fromRGB(120, 255, 120)
            btn.BackgroundColor3 = Color3.fromRGB(20, 45, 20)
        else
            btn.Text             = "[ OFF ]  " .. label
            btn.TextColor3       = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end
        callback(active)
    end)
    return btn
end

local function makeButton(label, callback)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    btn.Text             = label
    btn.TextColor3       = Color3.fromRGB(210, 210, 255)
    btn.TextSize         = 14
    btn.Font             = Enum.Font.Gotham
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.AutoButtonColor  = false
    btn.ZIndex           = 3
    btn.LayoutOrder      = nextOrder()
    btn.Parent           = contentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================================
--  Features – State-Variablen
-- ============================================================
local speedActive  = false
local jumpActive   = false
local flyActive    = false
local noclipActive = false
local espActive    = false
local rainbowOn    = false
local espHighlights = {}
local flyConn
local flyBv, flyBg, flyAtt
local flyUp        = false
local flyDown      = false
local flyMobileGui = nil
local noclipConn
local espPlayerConns = {}

-- ============================================================
--  Helper-Funktionen (vor den Toggles definiert damit CharacterAdded
--  und PlayerAdded sie aufrufen können)
-- ============================================================
local function destroyFlyMobileGui()
    if flyMobileGui then
        pcall(function() flyMobileGui:Destroy() end)
        flyMobileGui = nil
    end
    flyUp   = false
    flyDown = false
end

local function createFlyMobileGui()
    destroyFlyMobileGui()
    if not UserInputService.TouchEnabled then return end

    local gui = Instance.new("ScreenGui")
    gui.Name         = "MyHubFlyButtons"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.DisplayOrder = 1000
    local guiOk = false
    if not guiOk then guiOk = pcall(function() gui.Parent = gethui() end) end
    if not guiOk then guiOk = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not guiOk then gui.Parent = player:WaitForChild("PlayerGui") end
    flyMobileGui = gui

    local function makeBtn(label, xPos, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 80)
        btn.Position = UDim2.new(xPos, -40, 1, -110)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 36
        btn.Font = Enum.Font.GothamBold
        btn.Text = label
        btn.BorderSizePixel = 0
        btn.ZIndex = 10
        btn.Parent = gui
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
        btn.MouseButton1Down:Connect(function() cb(true) end)
        btn.MouseButton1Up:Connect(function()   cb(false) end)
    end

    makeBtn("▲", 0.30, function(down) flyUp   = down end)
    makeBtn("▼", 0.70, function(down) flyDown = down end)
end

local function startFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBv then pcall(function() flyBv:Destroy() end); flyBv = nil end
    if flyBg then pcall(function() flyBg:Destroy() end); flyBg = nil end

    humanoid.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent   = rootPart
    flyBv = bv

    -- MaxTorque nur auf Y-Achse → kein Pitch/Roll-Kämpfen, kein Drehen
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(0, 1e9, 0)
    bg.P         = 1e6
    bg.D         = 100
    bg.CFrame    = rootPart.CFrame
    bg.Parent    = rootPart
    flyBg = bg

    flyConn = RunService.Heartbeat:Connect(function()
        if not rootPart or not rootPart.Parent then return end
        local cam = workspace.CurrentCamera

        -- Horizontale Richtung: MoveDirection funktioniert für WASD (PC) und
        -- Thumbstick (Mobile) gleichermaßen – auch wenn PlatformStand aktiv ist.
        local md = humanoid.MoveDirection
        local horizontal = Vector3.new(md.X, 0, md.Z)

        -- Vertikale Eingabe: Tastatur (PC) oder On-Screen-Buttons (Mobile)
        local vertical = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = 1
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vertical = -1
        end
        if flyUp   then vertical =  1 end
        if flyDown then vertical = -1 end

        local dir = horizontal + Vector3.new(0, vertical, 0)
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * SETTINGS.FlySpeed or Vector3.new(0, 0, 0)

        -- Nur Yaw: Charakter schaut in Kamerarichtung (horizontal), kein Kippen
        local lv = cam.CFrame.LookVector
        bg.CFrame = CFrame.new(rootPart.Position)
            * CFrame.Angles(0, math.atan2(-lv.X, -lv.Z), 0)
    end)
end

local function startNoClip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    noclipConn = RunService.Stepped:Connect(function()
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function applyESP()
    for _, h in ipairs(espHighlights) do pcall(function() h:Destroy() end) end
    espHighlights = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = Instance.new("Highlight")
            h.FillColor        = SETTINGS.ESPColor
            h.OutlineColor     = Color3.new(1, 1, 1)
            h.FillTransparency = 0.5
            h.Parent           = p.Character
            table.insert(espHighlights, h)
        end
    end
end

-- ============================================================
--  CharacterAdded: character/humanoid/rootPart aktualisieren
--  und alle aktiven Features auf den neuen Character anwenden
-- ============================================================
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid  = newChar:WaitForChild("Humanoid")
    rootPart  = newChar:WaitForChild("HumanoidRootPart")

    if speedActive then
        humanoid.WalkSpeed = SETTINGS.WalkSpeed * 3
    end
    if jumpActive then
        humanoid.JumpPower = SETTINGS.JumpPower * 4
        pcall(function() humanoid.JumpHeight = 50 end)
    end
    if flyActive then
        createFlyMobileGui()
        startFly()
    end
    if noclipActive then
        startNoClip()
    end
end)

-- ============================================================
--  ESP: neue Spieler und Respawns automatisch markieren
-- ============================================================
local function watchPlayer(p)
    if espPlayerConns[p] then return end
    espPlayerConns[p] = p.CharacterAdded:Connect(function()
        if espActive then
            task.wait(0.5)
            applyESP()
        end
    end)
end

Players.PlayerAdded:Connect(function(p)
    watchPlayer(p)
    if espActive then
        task.wait(1)
        applyESP()
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if espPlayerConns[p] then
        espPlayerConns[p]:Disconnect()
        espPlayerConns[p] = nil
    end
    if espActive then applyESP() end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then watchPlayer(p) end
end

-- ============================================================
--  UI-Einträge
-- ============================================================
-- Bewegung
makeSection("🏃 Bewegung")

makeToggle("Speed Hack  (WalkSpeed ×3)", function(on)
    speedActive = on
    humanoid.WalkSpeed = on and (SETTINGS.WalkSpeed * 3) or SETTINGS.WalkSpeed
    notify("Speed Hack", on and "Aktiviert" or "Deaktiviert")
end)

makeToggle("High Jump  (JumpPower ×4)", function(on)
    jumpActive = on
    humanoid.JumpPower = on and (SETTINGS.JumpPower * 4) or SETTINGS.JumpPower
    pcall(function()
        humanoid.JumpHeight = on and 50 or 7.2
    end)
    notify("High Jump", on and "Aktiviert" or "Deaktiviert")
end)

makeToggle("Fliegen", function(on)
    flyActive = on
    notify("Fliegen", on and "Aktiviert" or "Deaktiviert")
    if on then
        createFlyMobileGui()
        startFly()
    else
        destroyFlyMobileGui()
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBv then pcall(function() flyBv:Destroy() end); flyBv = nil end
        if flyBg then pcall(function() flyBg:Destroy() end); flyBg = nil end
        humanoid.PlatformStand = false
    end
end)

makeToggle("NoClip", function(on)
    noclipActive = on
    notify("NoClip", on and "Aktiviert" or "Deaktiviert")
    if on then
        startNoClip()
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end)

-- Spieler
makeSection("👤 Spieler")

makeButton("⚡ Gesundheit auffüllen", function()
    humanoid.Health = humanoid.MaxHealth
    notify("Heilung", "HP vollständig aufgefüllt")
end)

makeButton("🌀 Teleport zur Spawn", function()
    rootPart.CFrame = CFrame.new(0, 10, 0)
    notify("Teleport", "Zur Spawn teleportiert")
end)

makeButton("🔍 Spieler-Liste drucken", function()
    print("=== Spieler online ===")
    for _, p in ipairs(Players:GetPlayers()) do
        local ping = "?"
        pcall(function() ping = math.floor(p:GetNetworkPing() * 1000) .. "ms" end)
        print("  •", p.Name, "| Ping:", ping)
    end
    notify("Spieler-Liste", "Konsole (F9) prüfen")
end)

-- Visuals
makeSection("👁 Visuals")

makeToggle("ESP – Spieler hervorheben", function(on)
    espActive = on
    notify("ESP", on and "Aktiviert" or "Deaktiviert")
    if on then
        applyESP()
    else
        for _, h in ipairs(espHighlights) do pcall(function() h:Destroy() end) end
        espHighlights = {}
    end
end)

makeToggle("Vollmond (Lighting)", function(on)
    Lighting.ClockTime  = on and 0 or 14
    Lighting.Brightness = on and 2 or 1
    notify("Lighting", on and "Vollmond" or "Normal")
end)

makeToggle("Regenbogen-Ambient", function(on)
    rainbowOn = on
    if on then
        task.spawn(function()
            local h = 0
            while rainbowOn do
                h = (h + 1) % 360
                Lighting.Ambient = Color3.fromHSV(h / 360, 0.6, 1)
                task.wait(0.05)
            end
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end)
    end
    notify("Ambient", on and "Regenbogen an" or "Aus")
end)

-- Welt
makeSection("🌍 Welt")

makeButton("💥 Baseplate entfernen", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Baseplate" then obj:Destroy() end
    end
    notify("Welt", "Baseplate entfernt")
end)

makeButton("🌊 Schwerkraft halbieren", function()
    workspace.Gravity = 98.1 / 2
    notify("Gravitation", "50 %")
end)

makeButton("🔁 Schwerkraft zurücksetzen", function()
    workspace.Gravity = 196.2
    notify("Gravitation", "Zurückgesetzt")
end)

-- ============================================================
--  Hotkey RightAlt: Hub ein-/ausblenden
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

notify("MyHub", "Geladen! RAlt = Hub umschalten", 5)
print("[MyHub] Script geladen ✓")
