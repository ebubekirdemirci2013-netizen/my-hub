--[[
    ███╗   ███╗██╗   ██╗    ██╗  ██╗██╗   ██╗██████╗
    ████╗ ████║╚██╗ ██╔╝    ██║  ██║██║   ██║██╔══██╗
    ██╔████╔██║ ╚████╔╝     ███████║██║   ██║██████╔╝
    ██║╚██╔╝██║  ╚██╔╝      ██╔══██║██║   ██║██╔══██╗
    ██║ ╚═╝ ██║   ██║       ██║  ██║╚██████╔╝██████╔╝
    ╚═╝     ╚═╝   ╚═╝       ╚═╝  ╚═╝ ╚═════╝ ╚═════╝

    Professional Roblox Utility Hub  •  v1.0.0
    ─────────────────────────────────────────────
    Loader (paste in any executor):
      loadstring(game:HttpGet("https://raw.githubusercontent.com/ebubekirdemirci2013-netizen/my-hub/main/hub.lua"))()

    Tabs:  Home · Calculator · Text Tools · JSON · Settings · Logs
]]

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Destroy any previous instance to allow re-execution
if PlayerGui:FindFirstChild("MyHub") then
    PlayerGui.MyHub:Destroy()
end

-- ════════════════════════════════════════════════════════════════
--  THEME  (Catppuccin Mocha palette)
-- ════════════════════════════════════════════════════════════════

local T = {
    base     = Color3.fromHex("1e1e2e"),
    mantle   = Color3.fromHex("181825"),
    surface0 = Color3.fromHex("313244"),
    surface1 = Color3.fromHex("45475a"),
    overlay  = Color3.fromHex("6c7086"),
    text     = Color3.fromHex("cdd6f4"),
    subtext  = Color3.fromHex("a6adc8"),
    blue     = Color3.fromHex("89b4fa"),
    lavender = Color3.fromHex("b4befe"),
    green    = Color3.fromHex("a6e3a1"),
    yellow   = Color3.fromHex("f9e2af"),
    red      = Color3.fromHex("f38ba8"),
    pink     = Color3.fromHex("f5c2e7"),
    teal     = Color3.fromHex("94e2d5"),
    peach    = Color3.fromHex("fab387"),
    mauve    = Color3.fromHex("cba6f7"),
}

-- ════════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════════

local function new(cls, props, parent)
    local inst = Instance.new(cls)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(r, parent)
    return new("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(col, thick, parent)
    return new("UIStroke", { Color = col, Thickness = thick }, parent)
end

local function pad(l, r, t, b, parent)
    return new("UIPadding", {
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
    }, parent)
end

local function tw(inst, info, goal)
    TweenService:Create(inst, info, goal):Play()
end

local FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
local MED  = TweenInfo.new(0.30, Enum.EasingStyle.Quad)
local BACK = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- ════════════════════════════════════════════════════════════════
--  ROOT GUI
-- ════════════════════════════════════════════════════════════════

local ScreenGui = new("ScreenGui", {
    Name           = "MyHub",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local Main = new("Frame", {
    Name             = "Main",
    Size             = UDim2.new(0, 530, 0, 390),
    Position         = UDim2.new(0.5, -265, 0.5, -195),
    BackgroundColor3 = T.base,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, ScreenGui)
corner(10, Main)
stroke(T.surface1, 1.2, Main)

-- ════════════════════════════════════════════════════════════════
--  TITLE BAR
-- ════════════════════════════════════════════════════════════════

local TitleBar = new("Frame", {
    Size             = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = T.mantle,
    BorderSizePixel  = 0,
}, Main)
corner(10, TitleBar)
-- Square off bottom corners
new("Frame", {
    Size             = UDim2.new(1, 0, 0.5, 0),
    Position         = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = T.mantle,
    BorderSizePixel  = 0,
}, TitleBar)

new("TextLabel", {
    Size                   = UDim2.new(0, 24, 1, 0),
    Position               = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "⚡",
    TextColor3             = T.blue,
    TextSize               = 18,
    Font                   = Enum.Font.GothamBold,
}, TitleBar)

new("TextLabel", {
    Size                   = UDim2.new(1, -130, 1, 0),
    Position               = UDim2.new(0, 38, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "My Hub",
    TextColor3             = T.text,
    TextSize               = 15,
    Font                   = Enum.Font.GothamBold,
    TextXAlignment         = Enum.TextXAlignment.Left,
}, TitleBar)

local function win_btn(icon, col, offset)
    local b = new("TextButton", {
        Size             = UDim2.new(0, 22, 0, 22),
        Position         = UDim2.new(1, offset, 0.5, -11),
        BackgroundColor3 = col,
        Text             = icon,
        TextColor3       = T.mantle,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
    }, TitleBar)
    corner(6, b)
    return b
end

local CloseBtn = win_btn("✕", T.red,    -30)
local MinBtn   = win_btn("─", T.yellow, -58)

-- ── Drag ─────────────────────────────────────────────────────

local _drag, _dragInput, _dragStart, _startPos

TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        _drag      = true
        _dragStart = i.Position
        _startPos  = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then _drag = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then _dragInput = i end
end)
UserInputService.InputChanged:Connect(function(i)
    if i == _dragInput and _drag then
        local d = i.Position - _dragStart
        Main.Position = UDim2.new(
            _startPos.X.Scale, _startPos.X.Offset + d.X,
            _startPos.Y.Scale, _startPos.Y.Offset + d.Y)
    end
end)

-- ── Close / minimise ─────────────────────────────────────────

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local minimised = false
MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    tw(Main, MED, { Size = minimised
        and UDim2.new(0, 530, 0, 38)
        or  UDim2.new(0, 530, 0, 390) })
end)

-- ════════════════════════════════════════════════════════════════
--  SIDEBAR
-- ════════════════════════════════════════════════════════════════

local Sidebar = new("Frame", {
    Size             = UDim2.new(0, 128, 1, -38),
    Position         = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = T.mantle,
    BorderSizePixel  = 0,
}, Main)
corner(10, Sidebar)
-- Square off top-right and bottom-right corners
new("Frame", {
    Size             = UDim2.new(0, 10, 1, 0),
    Position         = UDim2.new(1, -10, 0, 0),
    BackgroundColor3 = T.mantle,
    BorderSizePixel  = 0,
}, Sidebar)
new("Frame", {
    Size             = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = T.mantle,
    BorderSizePixel  = 0,
}, Sidebar)

local SideList = new("Frame", {
    Size                   = UDim2.new(1, 0, 1, -8),
    Position               = UDim2.new(0, 0, 0, 8),
    BackgroundTransparency = 1,
}, Sidebar)
new("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding   = UDim.new(0, 3),
}, SideList)
pad(6, 6, 0, 6, SideList)

-- ════════════════════════════════════════════════════════════════
--  CONTENT AREA
-- ════════════════════════════════════════════════════════════════

local Content = new("Frame", {
    Size                   = UDim2.new(1, -128, 1, -38),
    Position               = UDim2.new(0, 128, 0, 38),
    BackgroundTransparency = 1,
    ClipsDescendants       = true,
}, Main)

-- ════════════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ════════════════════════════════════════════════════════════════

local tabs        = {}
local activetab   = nil

local TAB_DEFS = {
    { id = "home",   label = "Home",       icon = "🏠" },
    { id = "calc",   label = "Calculator", icon = "🔢" },
    { id = "text",   label = "Text Tools", icon = "📝" },
    { id = "json",   label = "JSON",       icon = "{ }" },
    { id = "set",    label = "Settings",   icon = "⚙" },
    { id = "logs",   label = "Logs",       icon = "📋" },
}

local function make_scroll_frame(name)
    local f = new("ScrollingFrame", {
        Name                 = name,
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.surface1,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        Visible              = false,
    }, Content)
    pad(12, 12, 10, 12, f)
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 8),
    }, f)
    return f
end

local function switch_tab(id)
    for _, t in ipairs(tabs) do
        local active = t.id == id
        t.frame.Visible          = active
        t.btn.BackgroundColor3   = active and T.blue     or T.surface0
        t.btn.TextColor3         = active and T.mantle   or T.subtext
        if active then activetab = id end
    end
end

for i, def in ipairs(TAB_DEFS) do
    local frame = make_scroll_frame(def.id)

    local btn = new("TextButton", {
        Name             = def.id,
        Size             = UDim2.new(1, 0, 0, 33),
        BackgroundColor3 = T.surface0,
        Text             = def.icon .. "  " .. def.label,
        TextColor3       = T.subtext,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        BorderSizePixel  = 0,
        LayoutOrder      = i,
    }, SideList)
    corner(6, btn)
    pad(9, 0, 0, 0, btn)

    btn.MouseEnter:Connect(function()
        if activetab ~= def.id then
            tw(btn, FAST, { BackgroundColor3 = T.surface1 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if activetab ~= def.id then
            tw(btn, FAST, { BackgroundColor3 = T.surface0 })
        end
    end)
    btn.MouseButton1Click:Connect(function() switch_tab(def.id) end)

    tabs[i] = { id = def.id, frame = frame, btn = btn }
end

-- ════════════════════════════════════════════════════════════════
--  COMPONENT FACTORIES
-- ════════════════════════════════════════════════════════════════

local function section(parent, text, order)
    local lbl = new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = T.blue,
        TextSize               = 11,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Left,
        LayoutOrder            = order,
    }, parent)
    new("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.surface0,
        BorderSizePixel  = 0,
        LayoutOrder      = order + 0.1,
    }, parent)
    return lbl
end

local function label(parent, text, order, col, size)
    return new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                   = text,
        TextColor3             = col  or T.subtext,
        TextSize               = size or 13,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        LayoutOrder            = order,
    }, parent)
end

local function textbox(parent, placeholder, order, multiline, height)
    local box = new("TextBox", {
        Size              = UDim2.new(1, 0, 0, height or 32),
        BackgroundColor3  = T.surface0,
        Text              = "",
        PlaceholderText   = placeholder or "",
        TextColor3        = T.text,
        PlaceholderColor3 = T.overlay,
        TextSize          = 12,
        Font              = Enum.Font.Gotham,
        BorderSizePixel   = 0,
        TextXAlignment    = Enum.TextXAlignment.Left,
        TextYAlignment    = Enum.TextYAlignment.Top,
        ClearTextOnFocus  = false,
        MultiLine         = multiline or false,
        LayoutOrder       = order,
    }, parent)
    corner(6, box)
    pad(8, 8, 6, 6, box)
    return box
end

local function output(parent, order, height, font)
    local lbl = new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, height or 60),
        BackgroundColor3       = T.mantle,
        Text                   = "",
        TextColor3             = T.green,
        TextSize               = 12,
        Font                   = font or Enum.Font.Code,
        BorderSizePixel        = 0,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Top,
        TextWrapped            = true,
        LayoutOrder            = order,
    }, parent)
    corner(6, lbl)
    pad(8, 8, 6, 6, lbl)
    return lbl
end

local function button(parent, text, col, order, w)
    local btn = new("TextButton", {
        Size             = w or UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = col or T.blue,
        Text             = text,
        TextColor3       = T.mantle,
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
        LayoutOrder      = order,
    }, parent)
    corner(6, btn)
    local base = col or T.blue
    btn.MouseEnter:Connect(function() tw(btn, FAST, { BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.12) }) end)
    btn.MouseLeave:Connect(function() tw(btn, FAST, { BackgroundColor3 = base }) end)
    return btn
end

local function hrow(parent, order, height)
    local f = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, height or 32),
        BackgroundTransparency = 1,
        LayoutOrder            = order,
    }, parent)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 6),
    }, f)
    return f
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATIONS  (toast + in-hub log)
-- ════════════════════════════════════════════════════════════════

local log_lines   = {}
local LogOutput   -- assigned when Logs tab is built

local function notify(msg, kind)
    kind = kind or "info"
    local icons  = { ok="✔", warn="⚠", error="✖", info="ℹ" }
    local colors = { ok=T.green, warn=T.yellow, error=T.red, info=T.blue }

    -- Append to log
    local ts_ok, ts = pcall(function()
        return DateTime.now():FormatLocalTime("HH:mm:ss", "en-us")
    end)
    local ts_str = ts_ok and ("[" .. ts .. "] ") or ("[" .. string.format("%05d", math.floor(tick() % 86400)) .. "] ")
    local line = ts_str .. (icons[kind] or "") .. " " .. msg
    table.insert(log_lines, 1, line)
    if #log_lines > 200 then table.remove(log_lines) end
    if LogOutput then
        LogOutput.Text      = table.concat(log_lines, "\n")
        LogOutput.TextColor3 = T.subtext
    end

    -- Toast card
    local card = new("Frame", {
        Size             = UDim2.new(0, 270, 0, 48),
        Position         = UDim2.new(1, -280, 1, 14),
        BackgroundColor3 = T.surface0,
        BorderSizePixel  = 0,
        ZIndex           = 20,
    }, ScreenGui)
    corner(8, card)
    stroke(colors[kind] or T.blue, 1.2, card)

    new("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = colors[kind] or T.blue,
        BorderSizePixel  = 0,
        ZIndex           = 21,
    }, card):ClearAllChildren()
    corner(4, card:FindFirstChild("Frame") or card)

    new("TextLabel", {
        Size                   = UDim2.new(1, -14, 1, 0),
        Position               = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text                   = (icons[kind] or "") .. "  " .. msg,
        TextColor3             = T.text,
        TextSize               = 12,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        ZIndex                 = 21,
    }, card)

    tw(card, MED, { Position = UDim2.new(1, -280, 1, -60) })
    task.delay(3.2, function()
        tw(card, MED, { Position = UDim2.new(1, -280, 1, 14) })
        task.delay(0.35, function() card:Destroy() end)
    end)
end

-- ════════════════════════════════════════════════════════════════
--  TAB: HOME
-- ════════════════════════════════════════════════════════════════

local H = tabs[1].frame

label(H, "Welcome to My Hub  ⚡", 1, T.text, 17)
label(H, "A professional Roblox utility hub.", 2, T.subtext, 12)

section(H, "PLAYER INFO", 3)

local infoCard = new("Frame", {
    Size             = UDim2.new(1, 0, 0, 92),
    BackgroundColor3 = T.surface0,
    BorderSizePixel  = 0,
    LayoutOrder      = 4,
}, H)
corner(8, infoCard)
pad(12, 0, 8, 8, infoCard)
new("UIListLayout", { Padding = UDim.new(0, 4) }, infoCard)

local function info_row(txt)
    new("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text                   = txt,
        TextColor3             = T.subtext,
        TextSize               = 12,
        Font                   = Enum.Font.Gotham,
        TextXAlignment         = Enum.TextXAlignment.Left,
    }, infoCard)
end

local ok_name, gameName = pcall(function()
    return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

info_row("👤  " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")
info_row("🎮  " .. (ok_name and gameName or "Unknown Game"))
info_row("🔑  User ID: "  .. LocalPlayer.UserId)
info_row("📍  Place ID: " .. game.PlaceId)

section(H, "TOOLS", 5)

local tool_rows = {
    { "🔢  Calculator",  "Evaluate expressions, memory slots, history"  },
    { "📝  Text Tools",  "Case, reverse, ROT-13, Base64, word count"    },
    { "{ }  JSON",       "Parse, pretty-print, navigate & search JSON"  },
    { "⚙   Settings",   "Theme, transparency, notifications"           },
    { "📋  Logs",        "Full activity log for this session"           },
}

for idx, row in ipairs(tool_rows) do
    local f = new("Frame", {
        Size                   = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder            = 5 + idx,
    }, H)
    new("TextLabel", {
        Size=UDim2.new(0,126,1,0), BackgroundTransparency=1,
        Text=row[1], TextColor3=T.blue, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
    new("TextLabel", {
        Size=UDim2.new(1,-130,1,0), Position=UDim2.new(0,130,0,0),
        BackgroundTransparency=1, Text=row[2], TextColor3=T.subtext,
        TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
end

-- ════════════════════════════════════════════════════════════════
--  TAB: CALCULATOR
-- ════════════════════════════════════════════════════════════════

local C = tabs[2].frame

local calc_hist   = {}
local calc_memory = {}  -- named slots (ans is always stored here)

section(C, "EXPRESSION", 1)
local calcIn  = textbox(C, "e.g.  2+3*sqrt(9)   factorial(5)   gcd(12,8)", 2)
calcIn.Size   = UDim2.new(1, 0, 0, 34)
local calcOut = output(C, 3, 42)
calcOut.Text      = "Result will appear here"
calcOut.TextColor3 = T.overlay

local calcRow  = hrow(C, 4)
local calcEval = button(calcRow, "= Evaluate", T.blue, 1, UDim2.new(0.65, -3, 1, 0))
local calcClr  = button(calcRow, "Clear",      T.surface0, 2, UDim2.new(0.35, -3, 1, 0))
calcClr.TextColor3 = T.text

-- Safe math sandbox
local function calc_env()
    local base = {
        abs=math.abs, sqrt=math.sqrt, floor=math.floor, ceil=math.ceil,
        round=function(x) return math.floor(x+0.5) end,
        sin=math.sin, cos=math.cos, tan=math.tan,
        asin=math.asin, acos=math.acos, atan=math.atan,
        log=math.log, exp=math.exp, max=math.max, min=math.min,
        pi=math.pi, e=math.exp(1), inf=math.huge,
        log10 = function(x) return math.log(x)/math.log(10) end,
        factorial = function(n)
            n = math.floor(n)
            assert(n >= 0 and n <= 20, "factorial: domain 0–20")
            local r = 1; for i = 2, n do r = r * i end; return r
        end,
        gcd = function(a, b)
            a, b = math.abs(math.floor(a)), math.abs(math.floor(b))
            while b ~= 0 do a, b = b, a % b end; return a
        end,
    }
    -- Inject memory slots
    for k, v in pairs(calc_memory) do base[k] = v end
    setmetatable(base, {
        __index    = function(_, k) error("undefined: " .. tostring(k)) end,
        __newindex = function()     error("assignment not allowed")       end,
    })
    return base
end

local function calc_fmt(n)
    if n ~= n          then return "NaN"       end
    if n ==  math.huge then return "∞"         end
    if n == -math.huge then return "-∞"        end
    if math.floor(n) == n and math.abs(n) < 1e15 then
        return tostring(math.floor(n))
    end
    return string.format("%.10g", n)
end

local function calc_eval(expr)
    expr = expr:gsub("//", "__idiv__")
    local env = calc_env()
    env.__idiv__ = function(a, b) return math.floor(a / b) end
    local fn, err = load("return (" .. expr .. ")", "calc", "t", env)
    if not fn then fn, err = load("return " .. expr, "calc", "t", env) end
    if not fn then return nil, err end
    local ok, val = pcall(fn)
    if not ok then return nil, val end
    if type(val) ~= "number" then return nil, "expression must return a number" end
    return val
end

local function do_eval()
    local expr = calcIn.Text:match("^%s*(.-)%s*$")
    if expr == "" then return end
    local val, err = calc_eval(expr)
    if err then
        calcOut.Text       = "✖  " .. tostring(err):gsub("^.+:%d+:%s*", "")
        calcOut.TextColor3 = T.red
        notify("Error in expression", "error")
    else
        local ans = calc_fmt(val)
        calcOut.Text       = "=  " .. ans
        calcOut.TextColor3 = T.green
        calc_memory["ans"] = val
        table.insert(calc_hist, 1, expr .. "  =  " .. ans)
        if #calc_hist > 50 then table.remove(calc_hist) end
        notify(expr .. " = " .. ans, "ok")
    end
end

calcEval.MouseButton1Click:Connect(do_eval)
calcIn.FocusLost:Connect(function(enter) if enter then do_eval() end end)
calcClr.MouseButton1Click:Connect(function()
    calcIn.Text         = ""
    calcOut.Text        = "Result will appear here"
    calcOut.TextColor3  = T.overlay
end)

section(C, "MEMORY  (use variable names in expressions)", 5)
label(C, "Last result is always stored as  ans", 6, T.subtext, 11)

local memIn  = textbox(C, "name = expression   e.g.  r = 5", 7)
memIn.Size   = UDim2.new(1, 0, 0, 30)
local memBtn = button(C, "Store in Memory", T.teal, 8)
memBtn.MouseButton1Click:Connect(function()
    local txt  = memIn.Text:match("^%s*(.-)%s*$")
    local name, expr = txt:match("^([%a_][%w_]*)%s*=%s*(.+)$")
    if not name then notify("Format: name = expression", "warn"); return end
    local val, err = calc_eval(expr)
    if err then notify("Error: " .. tostring(err):gsub("^.+:%d+:%s*",""), "error"); return end
    calc_memory[name] = val
    notify(name .. " = " .. calc_fmt(val), "ok")
end)

section(C, "HISTORY", 9)
local histOut = output(C, 10, 80)
histOut.Text      = "(no calculations yet)"
histOut.TextColor3 = T.overlay

local function refresh_hist()
    if #calc_hist > 0 then
        histOut.Text      = table.concat(calc_hist, "\n")
        histOut.TextColor3 = T.subtext
    end
end
calcEval.MouseButton1Click:Connect(refresh_hist)
memBtn.MouseButton1Click:Connect(refresh_hist)

-- ════════════════════════════════════════════════════════════════
--  TAB: TEXT TOOLS
-- ════════════════════════════════════════════════════════════════

local TX = tabs[3].frame

section(TX, "INPUT", 1)
local txIn = textbox(TX, "Enter text here...", 2, true, 72)

section(TX, "TRANSFORM", 3)

local function apply_transform(fn, name)
    local t = txIn.Text
    if t == "" then notify("Input is empty", "warn"); return end
    txIn.Text = fn(t)
    notify(name .. " applied", "ok")
end

-- 2-column button grid
local gridFrame = new("Frame", {
    Size                   = UDim2.new(1, 0, 0, 110),
    BackgroundTransparency = 1,
    LayoutOrder            = 4,
}, TX)
new("UIGridLayout", {
    CellSize    = UDim2.new(0.5, -3, 0, 30),
    CellPadding = UDim2.new(0, 3, 0, 3),
    SortOrder   = Enum.SortOrder.LayoutOrder,
}, gridFrame)

local transforms = {
    { "UPPER CASE",  T.blue,     function(s) return s:upper() end },
    { "lower case",  T.teal,     function(s) return s:lower() end },
    { "Title Case",  T.lavender, function(s) return s:gsub("(%a)([%w_']*)", function(f,r) return f:upper()..r:lower() end) end },
    { "Reverse",     T.peach,    function(s) return s:reverse() end },
    { "Trim Spaces", T.green,    function(s)
        local lines = {}
        for ln in (s.."\n"):gmatch("([^\n]*)\n") do
            lines[#lines+1] = ln:match("^%s*(.-)%s*$")
        end
        return table.concat(lines, "\n")
    end},
    { "ROT-13",      T.pink,     function(s)
        return s:gsub("[A-Za-z]", function(c)
            local b = c:lower()==c and string.byte("a") or string.byte("A")
            return string.char((string.byte(c)-b+13)%26+b)
        end)
    end},
}

for i, tr in ipairs(transforms) do
    local b = new("TextButton", {
        BackgroundColor3 = tr[2], Text = tr[1], TextColor3 = T.mantle,
        TextSize = 11, Font = Enum.Font.GothamBold, BorderSizePixel = 0,
        LayoutOrder = i,
    }, gridFrame)
    corner(6, b)
    b.MouseButton1Click:Connect(function() apply_transform(tr[3], tr[1]) end)
end

section(TX, "STATISTICS", 5)
local statsOut = output(TX, 6, 44, Enum.Font.Gotham)
statsOut.Text      = "Click Count to analyse"
statsOut.TextColor3 = T.overlay

local cntBtn = button(TX, "Count Words & Characters", T.surface0, 7)
cntBtn.TextColor3 = T.text
cntBtn.MouseButton1Click:Connect(function()
    local s = txIn.Text
    local chars  = #s
    local space_count = select(2, s:gsub("%s",""))
    local words   = select(2, s:gsub("%S+",""))
    local lines   = select(2, s:gsub("\n","\n")) + 1
    statsOut.Text      = string.format("Chars: %d   No-space: %d   Words: %d   Lines: %d",
                              chars, chars - space_count, words, lines)
    statsOut.TextColor3 = T.text
    notify("Word count complete", "ok")
end)

section(TX, "BASE64", 8)
local b64row = hrow(TX, 9)

-- Base64 implementation
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64_encode(s)
    local out, pad = {}, (3 - #s % 3) % 3
    s = s .. ("\0"):rep(pad)
    for i = 1, #s, 3 do
        local a, b, c = s:byte(i, i+2)
        local n = a*65536 + b*256 + c
        out[#out+1] = B64:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
        out[#out+1] = B64:sub(math.floor(n/4096)%64+1,   math.floor(n/4096)%64+1)
        out[#out+1] = B64:sub(math.floor(n/64)%64+1,     math.floor(n/64)%64+1)
        out[#out+1] = B64:sub(n%64+1, n%64+1)
    end
    for i = 1, pad do out[#out - pad + i] = "=" end
    return table.concat(out)
end

local function b64_decode(s)
    s = s:gsub("[^" .. B64 .. "=]", "")
    if #s % 4 ~= 0 then return nil, "invalid length" end
    local dec = {}
    for i = 1, #B64 do dec[B64:sub(i,i)] = i-1 end
    dec["="] = 0
    local out = {}
    for i = 1, #s, 4 do
        local a,b,c,d = dec[s:sub(i,i)], dec[s:sub(i+1,i+1)], dec[s:sub(i+2,i+2)], dec[s:sub(i+3,i+3)]
        if not(a and b and c and d) then return nil, "invalid character" end
        local n = a*262144 + b*4096 + c*64 + d
        out[#out+1] = string.char(math.floor(n/65536)%256)
        if s:sub(i+2,i+2) ~= "=" then out[#out+1] = string.char(math.floor(n/256)%256) end
        if s:sub(i+3,i+3) ~= "=" then out[#out+1] = string.char(n%256) end
    end
    return table.concat(out)
end

local encBtn = button(b64row, "Encode →", T.blue, 1, UDim2.new(0.5, -3, 1, 0))
local decBtn = button(b64row, "← Decode", T.teal, 2, UDim2.new(0.5, -3, 1, 0))

encBtn.MouseButton1Click:Connect(function()
    if txIn.Text == "" then notify("Input is empty", "warn"); return end
    txIn.Text = b64_encode(txIn.Text); notify("Base64 encoded", "ok")
end)
decBtn.MouseButton1Click:Connect(function()
    if txIn.Text == "" then notify("Input is empty", "warn"); return end
    local r, err = b64_decode(txIn.Text)
    if err then notify("Decode error: " .. err, "error")
    else txIn.Text = r; notify("Base64 decoded", "ok") end
end)

-- ════════════════════════════════════════════════════════════════
--  TAB: JSON VIEWER
-- ════════════════════════════════════════════════════════════════

local J = tabs[4].frame
local jsonDoc = nil

-- Inline JSON encoder/decoder (self-contained for Roblox)
local function json_encode(val, indent, cur)
    indent = indent or ""
    cur    = cur    or ""
    local t = type(val)
    if val == nil or val == "null"       then return "null"
    elseif t == "boolean"               then return tostring(val)
    elseif t == "number"                then
        if val ~= val then return '"NaN"' end
        if val == math.huge then return '"Infinity"' end
        if math.floor(val)==val and math.abs(val)<1e15 then return tostring(math.floor(val)) end
        return string.format("%.14g", val)
    elseif t == "string" then
        return '"' .. val:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\t','\\t') .. '"'
    elseif t == "table" then
        -- Detect array
        local is_arr, n = true, 0
        for k in pairs(val) do
            n = n + 1
            if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then is_arr = false; break end
        end
        if n ~= #val then is_arr = false end
        local child = cur .. indent
        if is_arr then
            if n == 0 then return "[]" end
            local parts = {}
            for _, v in ipairs(val) do
                parts[#parts+1] = (indent~="" and ("\n"..child) or "") .. json_encode(v, indent, child)
            end
            return "[" .. table.concat(parts,",") .. (indent~="" and ("\n"..cur) or "") .. "]"
        else
            local keys = {}
            for k in pairs(val) do keys[#keys+1] = k end
            table.sort(keys, function(a,b) return tostring(a)<tostring(b) end)
            if #keys == 0 then return "{}" end
            local parts = {}
            for _, k in ipairs(keys) do
                local ks = '"' .. tostring(k) .. '"'
                parts[#parts+1] = (indent~="" and ("\n"..child) or "") ..
                    ks .. ":" .. (indent~="" and " " or "") .. json_encode(val[k], indent, child)
            end
            return "{" .. table.concat(parts,",") .. (indent~="" and ("\n"..cur) or "") .. "}"
        end
    end
    return tostring(val)
end

local function json_decode(s)
    local pos = 1
    local function skip() while pos<=#s and s:sub(pos,pos):match("%s") do pos=pos+1 end end
    local function eat(c) skip(); assert(s:sub(pos,pos)==c,"expected "..c); pos=pos+1 end
    local decode_val
    local function dstr()
        eat('"'); local buf={}
        while pos<=#s do
            local c=s:sub(pos,pos)
            if c=='"' then pos=pos+1; return table.concat(buf) end
            if c=="\\" then
                pos=pos+1; local e=s:sub(pos,pos); pos=pos+1
                local m={['"']='"',['\\']='\\',['/']=   '/',b='\b',f='\f',n='\n',r='\r',t='\t'}
                if m[e] then buf[#buf+1]=m[e]
                elseif e=='u' then
                    local h=s:sub(pos,pos+3); pos=pos+4
                    local cp=tonumber(h,16) or 63
                    if cp<0x80 then buf[#buf+1]=string.char(cp)
                    elseif cp<0x800 then buf[#buf+1]=string.char(0xC0+math.floor(cp/64), 0x80+cp%64)
                    else buf[#buf+1]=string.char(0xE0+math.floor(cp/4096),0x80+math.floor(cp%4096/64),0x80+cp%64) end
                end
            else buf[#buf+1]=c; pos=pos+1 end
        end
        error("unterminated string")
    end
    local function dnum()
        skip(); local n=s:match("^-?%d+%.?%d*[eE]?[+-]?%d*",pos)
        assert(n,"bad number"); pos=pos+#n; return tonumber(n)
    end
    local function darr()
        eat("["); skip(); local a={}
        if s:sub(pos,pos)=="]" then pos=pos+1; return a end
        repeat a[#a+1]=decode_val(); skip()
               if s:sub(pos,pos)=="," then pos=pos+1 end
        until s:sub(pos,pos)=="]"
        pos=pos+1; return a
    end
    local function dobj()
        eat("{"); skip(); local o={}
        if s:sub(pos,pos)=="}" then pos=pos+1; return o end
        repeat skip(); local k=dstr(); skip(); eat(":"); o[k]=decode_val(); skip()
               if s:sub(pos,pos)=="," then pos=pos+1 end
        until s:sub(pos,pos)=="}"
        pos=pos+1; return o
    end
    decode_val = function()
        skip(); local c=s:sub(pos,pos)
        if c=='"' then return dstr()
        elseif c=="{" then return dobj()
        elseif c=="[" then return darr()
        elseif c=="t" then pos=pos+4; return true
        elseif c=="f" then pos=pos+5; return false
        elseif c=="n" then pos=pos+4; return nil
        elseif c:match("[%-0-9]") then return dnum()
        else error("unexpected '"..c.."' at pos "..pos) end
    end
    return decode_val()
end

section(J, "INPUT", 1)
local jsonIn = textbox(J, 'Paste JSON here…  {"key":"value","list":[1,2,3]}', 2, true, 84)
jsonIn.Font  = Enum.Font.Code

local jsonBtnRow  = hrow(J, 3)
local jsonParse   = button(jsonBtnRow, "Parse & View",   T.blue,    1, UDim2.new(0.4,-3,1,0))
local jsonFmt     = button(jsonBtnRow, "Pretty-Print",   T.teal,    2, UDim2.new(0.3,-3,1,0))
local jsonMinify  = button(jsonBtnRow, "Minify",         T.lavender,3, UDim2.new(0.3,-3,1,0))

section(J, "OUTPUT", 4)
local jsonOut = output(J, 5, 110)
jsonOut.Text       = "Parse JSON above to see the output here"
jsonOut.TextColor3 = T.overlay
jsonOut.Font       = Enum.Font.Code

jsonParse.MouseButton1Click:Connect(function()
    local txt = jsonIn.Text:match("^%s*(.-)%s*$")
    if txt == "" then notify("No JSON to parse", "warn"); return end
    local ok, res = pcall(json_decode, txt)
    if not ok then
        jsonOut.Text      = "✖ Parse error:\n" .. tostring(res)
        jsonOut.TextColor3 = T.red
        notify("JSON parse error", "error")
    else
        jsonDoc = res
        jsonOut.Text      = json_encode(res, "  ")
        jsonOut.TextColor3 = T.text
        notify("JSON parsed successfully", "ok")
    end
end)

jsonFmt.MouseButton1Click:Connect(function()
    if not jsonDoc then notify("Parse JSON first", "warn"); return end
    local pretty = json_encode(jsonDoc, "  ")
    jsonIn.Text      = pretty
    jsonOut.Text     = pretty
    jsonOut.TextColor3 = T.text
    notify("JSON formatted", "ok")
end)

jsonMinify.MouseButton1Click:Connect(function()
    if not jsonDoc then notify("Parse JSON first", "warn"); return end
    local mini = json_encode(jsonDoc)
    jsonIn.Text       = mini
    jsonOut.Text      = mini
    jsonOut.TextColor3 = T.text
    notify("JSON minified", "ok")
end)

section(J, "SEARCH KEYS / VALUES", 6)
local jsonSearchIn  = textbox(J, "Search key or value...", 7)
local jsonSearchBtn = button(J, "Search", T.peach, 8)

jsonSearchBtn.MouseButton1Click:Connect(function()
    if not jsonDoc then notify("Parse JSON first", "warn"); return end
    local q = jsonSearchIn.Text:match("^%s*(.-)%s*$"):lower()
    if q == "" then notify("Enter a search query", "warn"); return end

    local results = {}
    local function search(node, path)
        if type(node) ~= "table" then
            if type(node)=="string" and node:lower():find(q,1,true) then
                results[#results+1] = path .. " = " .. json_encode(node)
            end
            return
        end
        for k, v in pairs(node) do
            local cp = path .. (type(k)=="number" and ("["..k.."]") or ("."..tostring(k)))
            if tostring(k):lower():find(q,1,true) then
                results[#results+1] = cp .. "  (key)"
            end
            search(v, cp)
        end
    end
    search(jsonDoc, "$")

    if #results == 0 then
        jsonOut.Text      = "No matches for: " .. q
        jsonOut.TextColor3 = T.yellow
    else
        jsonOut.Text      = table.concat(results, "\n")
        jsonOut.TextColor3 = T.text
        notify(#results .. " match(es) for \"" .. q .. "\"", "ok")
    end
end)

-- ════════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ════════════════════════════════════════════════════════════════

local S = tabs[5].frame

section(S, "HUB INFO", 1)
local function srow(lbl, val, order)
    local f = new("Frame", {
        Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, LayoutOrder=order,
    }, S)
    new("TextLabel", {
        Size=UDim2.new(0.42,0,1,0), BackgroundTransparency=1,
        Text=lbl, TextColor3=T.subtext, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
    local v = new("TextLabel", {
        Size=UDim2.new(0.58,0,1,0), Position=UDim2.new(0.42,0,0,0),
        BackgroundTransparency=1, Text=tostring(val), TextColor3=T.text,
        TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
    }, f)
    return v
end

srow("Version",    "1.0.0",            2)
srow("Player",     LocalPlayer.Name,   3)
srow("User ID",    LocalPlayer.UserId, 4)
srow("Theme",      "Catppuccin Mocha", 5)

section(S, "NOTIFICATIONS", 6)
local notifOn = true
local notifBtn = new("TextButton", {
    Size=UDim2.new(1,0,0,32), BackgroundColor3=T.green, LayoutOrder=7,
    Text="✔  Notifications ON", TextColor3=T.mantle,
    TextSize=12, Font=Enum.Font.GothamBold, BorderSizePixel=0,
}, S)
corner(6, notifBtn)
notifBtn.MouseButton1Click:Connect(function()
    notifOn = not notifOn
    notifBtn.BackgroundColor3 = notifOn and T.green    or T.surface0
    notifBtn.TextColor3       = notifOn and T.mantle   or T.subtext
    notifBtn.Text             = notifOn and "✔  Notifications ON" or "✖  Notifications OFF"
end)

section(S, "WINDOW TRANSPARENCY", 8)
local transpLbl = label(S, "Drag the slider to adjust transparency", 9, T.subtext, 11)

local sliderCont = new("Frame", {
    Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, LayoutOrder=10,
}, S)
local sliderTrack = new("Frame", {
    Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,0.5,-3),
    BackgroundColor3=T.surface1, BorderSizePixel=0,
}, sliderCont)
corner(4, sliderTrack)
local sliderFill = new("Frame", {
    Size=UDim2.new(0,0,1,0), BackgroundColor3=T.blue, BorderSizePixel=0,
}, sliderTrack)
corner(4, sliderFill)
local sliderKnob = new("Frame", {
    Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,-7,0.5,-7),
    BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
}, sliderFill)
corner(8, sliderKnob)

local sliding = false
sliderTrack.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
        local pct = math.clamp((i.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        Main.BackgroundTransparency = pct * 0.75
    end
end)

section(S, "ACTIONS", 11)

local resetPos = button(S, "Reset Window Position", T.surface0, 12)
resetPos.TextColor3 = T.text
resetPos.MouseButton1Click:Connect(function()
    tw(Main, BACK, { Position = UDim2.new(0.5,-265,0.5,-195) })
    notify("Window position reset", "ok")
end)

local clearData = button(S, "Clear Calculator Memory", T.surface0, 13)
clearData.TextColor3 = T.text
clearData.MouseButton1Click:Connect(function()
    for k in pairs(calc_memory) do calc_memory[k] = nil end
    notify("Calculator memory cleared", "ok")
end)

-- ════════════════════════════════════════════════════════════════
--  TAB: LOGS
-- ════════════════════════════════════════════════════════════════

local L = tabs[6].frame

section(L, "ACTIVITY LOG", 1)

LogOutput = output(L, 2, 230, Enum.Font.Code)
LogOutput.Text       = "(no log entries yet)"
LogOutput.TextColor3 = T.overlay
LogOutput.TextSize   = 11

local logBtnRow = hrow(L, 3)
local clearLog  = button(logBtnRow, "Clear Log",  T.red,    1, UDim2.new(0.45,-3,1,0))
local copyLog   = button(logBtnRow, "Copy to Clipboard", T.surface0, 2, UDim2.new(0.55,-3,1,0))
copyLog.TextColor3 = T.text

clearLog.MouseButton1Click:Connect(function()
    log_lines = {}
    LogOutput.Text      = "(log cleared)"
    LogOutput.TextColor3 = T.overlay
    notify("Log cleared", "ok")
end)

copyLog.MouseButton1Click:Connect(function()
    if #log_lines == 0 then notify("Log is empty", "warn"); return end
    local ok, _ = pcall(function()
        setclipboard(table.concat(log_lines, "\n"))
    end)
    notify(ok and "Log copied to clipboard" or "setclipboard not supported", ok and "ok" or "warn")
end)

-- ════════════════════════════════════════════════════════════════
--  STARTUP
-- ════════════════════════════════════════════════════════════════

switch_tab("home")
notify("My Hub v1.0.0 loaded  ⚡", "ok")
