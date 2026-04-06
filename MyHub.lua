-- ============================================================
--  MyHub  |  Roblox Script Hub
--  Einfacher, sauberer Hub mit mehreren Funktionen.
--  Einfügen in einen LocalScript unter StarterPlayerScripts.
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Lighting       = game:GetService("Lighting")

local player         = Players.LocalPlayer
local character      = player.Character or player.CharacterAdded:Wait()
local humanoid       = character:WaitForChild("Humanoid")
local rootPart       = character:WaitForChild("HumanoidRootPart")

-- ============================================================
--  Einstellungen
-- ============================================================
local SETTINGS = {
    WalkSpeed     = 16,
    JumpPower     = 50,
    FlySpeed      = 50,
    ESPColor      = Color3.fromRGB(255, 50, 50),
}

-- ============================================================
--  Hilfsfunktionen
-- ============================================================
local function notify(title, text, duration)
    duration = duration or 3
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title    = title,
        Text     = text,
        Duration = duration,
    })
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25), props):Play()
end

-- ============================================================
--  GUI aufbauen
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name            = "MyHub"
screenGui.ResetOnSpawn    = false
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling

-- Exploit-Umgebungen blockieren oft PlayerGui; CoreGui ist zuverlässiger
local guiParent
if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    guiParent = game:GetService("CoreGui")
elseif gethui then
    guiParent = gethui()
else
    guiParent = player.PlayerGui
end
screenGui.Parent = guiParent

-- Hauptfenster
local mainFrame = Instance.new("Frame")
mainFrame.Name            = "MainFrame"
mainFrame.Size            = UDim2.new(0, 380, 0, 460)
mainFrame.Position        = UDim2.new(0.5, -190, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active          = true
mainFrame.Draggable       = true
mainFrame.Parent          = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Titelleiste
local titleBar = Instance.new("Frame")
titleBar.Size              = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3  = Color3.fromRGB(30, 30, 50)
titleBar.BorderSizePixel   = 0
titleBar.Parent            = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size            = UDim2.new(1, -50, 1, 0)
titleLabel.Position        = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text            = "⚡ MyHub"
titleLabel.TextColor3      = Color3.fromRGB(200, 180, 255)
titleLabel.TextSize        = 18
titleLabel.Font            = Enum.Font.GothamBold
titleLabel.TextXAlignment  = Enum.TextXAlignment.Left
titleLabel.Parent          = titleBar

-- Schließen-Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size              = UDim2.new(0, 30, 0, 30)
closeBtn.Position          = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3  = Color3.fromRGB(200, 50, 50)
closeBtn.Text              = "✕"
closeBtn.TextColor3        = Color3.white
closeBtn.TextSize          = 14
closeBtn.Font              = Enum.Font.GothamBold
closeBtn.Parent            = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    task.delay(0.35, function() screenGui:Destroy() end)
end)

-- Scroll-Container für Buttons
local scroll = Instance.new("ScrollingFrame")
scroll.Size               = UDim2.new(1, -20, 1, -55)
scroll.Position           = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel    = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 100, 200)
scroll.CanvasSize         = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent             = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding            = UDim.new(0, 8)
layout.Parent             = scroll

-- ============================================================
--  Button-Fabrik
-- ============================================================
local function makeSection(labelText)
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "  " .. labelText
    lbl.TextColor3         = Color3.fromRGB(160, 140, 220)
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.Parent             = scroll
end

local function makeToggle(labelText, callback)
    local active = false

    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3   = Color3.fromRGB(30, 30, 50)
    btn.Text               = "[ OFF ]  " .. labelText
    btn.TextColor3         = Color3.fromRGB(180, 180, 180)
    btn.TextSize           = 14
    btn.Font               = Enum.Font.Gotham
    btn.TextXAlignment     = Enum.TextXAlignment.Left
    btn.AutoButtonColor    = false
    btn.Parent             = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft        = UDim.new(0, 10)
    pad.Parent             = btn

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text            = "[ ON  ]  " .. labelText
            btn.TextColor3      = Color3.fromRGB(120, 255, 120)
            btn.BackgroundColor3 = Color3.fromRGB(20, 45, 20)
        else
            btn.Text            = "[ OFF ]  " .. labelText
            btn.TextColor3      = Color3.fromRGB(180, 180, 180)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        end
        callback(active)
    end)

    return btn
end

local function makeButton(labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size               = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3   = Color3.fromRGB(40, 40, 65)
    btn.Text               = labelText
    btn.TextColor3         = Color3.fromRGB(210, 210, 255)
    btn.TextSize           = 14
    btn.Font               = Enum.Font.Gotham
    btn.AutoButtonColor    = false
    btn.Parent             = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft        = UDim.new(0, 10)
    pad.Parent             = btn

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 100)})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 65)})
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

-- ============================================================
--  Feature-Logik
-- ============================================================

-- Variablen
local flyActive    = false
local espActive    = false
local noclipActive = false
local espHighlights = {}
local flyConn

-- >> Bewegung
makeSection("🏃 Bewegung")

makeToggle("Speed Hack  (WalkSpeed ×3)", function(on)
    if character and humanoid then
        humanoid.WalkSpeed = on and (SETTINGS.WalkSpeed * 3) or SETTINGS.WalkSpeed
    end
    notify("Speed Hack", on and "Aktiviert" or "Deaktiviert")
end)

makeToggle("High Jump  (JumpPower ×4)", function(on)
    if character and humanoid then
        humanoid.JumpPower = on and (SETTINGS.JumpPower * 4) or SETTINGS.JumpPower
    end
    notify("High Jump", on and "Aktiviert" or "Deaktiviert")
end)

makeToggle("Fliegen", function(on)
    flyActive = on
    notify("Fliegen", on and "Aktiviert" or "Deaktiviert")

    if flyConn then flyConn:Disconnect() end

    if on then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity  = Vector3.zero
        bv.Parent    = rootPart

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P         = 1e4
        bg.Parent    = rootPart

        flyConn = RunService.Heartbeat:Connect(function()
            if not flyActive then
                bv:Destroy()
                bg:Destroy()
                return
            end
            local cam    = workspace.CurrentCamera
            local dir    = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
            bv.Velocity  = dir.Magnitude > 0 and dir.Unit * SETTINGS.FlySpeed or Vector3.zero
            bg.CFrame    = cam.CFrame
        end)
    end
end)

makeToggle("NoClip", function(on)
    noclipActive = on
    notify("NoClip", on and "Aktiviert" or "Deaktiviert")
    RunService.Stepped:Connect(function()
        if noclipActive and character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- >> Spieler
makeSection("👤 Spieler")

makeButton("⚡ Gesundheit auffüllen", function()
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
        notify("Heilung", "HP vollständig aufgefüllt")
    end
end)

makeButton("🌀 Teleport zur Spawn", function()
    if rootPart then
        rootPart.CFrame = CFrame.new(0, 10, 0)
        notify("Teleport", "Zur Spawn teleportiert")
    end
end)

makeButton("🔍 Spieler-Liste drucken", function()
    print("=== Spieler online ===")
    for _, p in ipairs(Players:GetPlayers()) do
        print("  •", p.Name, "| Ping:", p:GetNetworkPing() * 1000 .. "ms")
    end
    notify("Spieler-Liste", "In der Konsole (F9) ausgegeben")
end)

-- >> Visuals
makeSection("👁 Visuals")

makeToggle("ESP – Spieler hervorheben", function(on)
    espActive = on
    notify("ESP", on and "Aktiviert" or "Deaktiviert")

    -- Alte Highlights entfernen
    for _, h in ipairs(espHighlights) do h:Destroy() end
    espHighlights = {}

    if on then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = Instance.new("Highlight")
                h.FillColor    = SETTINGS.ESPColor
                h.OutlineColor = Color3.white
                h.FillTransparency  = 0.5
                h.Parent       = p.Character
                table.insert(espHighlights, h)
            end
        end
    end
end)

makeToggle("Vollmond (Lighting)", function(on)
    Lighting.ClockTime  = on and 0 or 14
    Lighting.Brightness = on and 2 or 1
    notify("Lighting", on and "Vollmond aktiviert" or "Normal")
end)

makeToggle("Regenbogen-Ambient", function(on)
    task.spawn(function()
        local h = 0
        while on do
            h = (h + 1) % 360
            Lighting.Ambient = Color3.fromHSV(h / 360, 0.6, 1)
            task.wait(0.05)
        end
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    end)
    notify("Ambient", on and "Regenbogen an" or "Aus")
end)

-- >> Welt
makeSection("🌍 Welt")

makeButton("💥 Alle Baseplate-Parts entfernen", function()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Baseplate" then
            obj:Destroy()
        end
    end
    notify("Welt", "Baseplate entfernt")
end)

makeButton("🌊 Schwerkraft halbieren", function()
    workspace.Gravity = 98.1 / 2
    notify("Gravitation", "Auf 50 % gesetzt")
end)

makeButton("🔁 Schwerkraft zurücksetzen", function()
    workspace.Gravity = 196.2
    notify("Gravitation", "Zurückgesetzt")
end)

-- ============================================================
--  Open/Close Hotkey (RightAlt)
-- ============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

notify("MyHub", "Geladen! Drücke RAlt um den Hub ein-/auszublenden.", 5)
print("[MyHub] Script geladen ✓")
