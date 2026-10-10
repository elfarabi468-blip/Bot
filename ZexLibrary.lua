-- ===================================================
-- ZexHub - Soft Turquoise MacOS Style UI Library v2
-- ===================================================

local ZexHub = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function ZexHub:CreateWindow(hubTitle)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZexHubUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Main Frame (Soft Turquoise Window)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 520, 0, 360)
    Main.Position = UDim2.new(0.5, -260, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(235, 248, 248)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    -- Açılış Animasyonu İçin Başlangıç Ayarları
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundTransparency = 1

    -- Animasyonla Açılma (Scale & Fade In)
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 360),
        Position = UDim2.new(0.5, -260, 0.5, -180),
        BackgroundTransparency = 0
    }):Play()

    -- Rounded Corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = Main

    -- Soft Shadow / Stroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(168, 220, 222)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = Main

    -- Topbar (MacBook Style)
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Color3.fromRGB(220, 242, 242)
    Topbar.BorderSizePixel = 0
    Topbar.Parent = Main

    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 16)
    TopbarCorner.Parent = Topbar

    -- Window Dots (MacBook Red, Yellow, Green)
    local function createDot(color, posX)
        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 12, 0, 12)
        Dot.Position = UDim2.new(0, posX, 0.5, -6)
        Dot.BackgroundColor3 = color
        Dot.BorderSizePixel = 0
        Dot.Parent = Topbar
        
        local DotCorner = Instance.new("UICorner")
        DotCorner.CornerRadius = UDim.new(1, 0)
        DotCorner.Parent = Dot
    end

    createDot(Color3.fromRGB(255, 95, 87), 16)  -- Kırmızı
    createDot(Color3.fromRGB(254, 188, 46), 34) -- Sarı
    createDot(Color3.fromRGB(40, 200, 64), 52)  -- Yeşil

    -- Title Text
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 80, 0, 0)
    Title.Text = hubTitle or "ZexHub"
    Title.TextColor3 = Color3.fromRGB(45, 95, 100)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Topbar

    -- Window Dragging Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Container ScrollingFrame for Elements
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -55)
    Container.Position = UDim2.new(0, 10, 0, 48)
    Container.BackgroundTransparency = 1
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.ScrollBarThickness = 4
    Container.Parent = Main

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = Container

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local Elements = {}

    -- Soft Button
    function Elements:CreateButton(btnText, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 36)
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.Text = btnText
        Button.TextColor3 = Color3.fromRGB(35, 80, 85)
        Button.Font = Enum.Font.GothamMedium
        Button.TextSize = 14
        Button.AutoButtonColor = false
        Button.Parent = Container

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 10)
        BtnCorner.Parent = Button

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Color3.fromRGB(180, 230, 232)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Button

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(200, 240, 242)}):Play()
        end)

        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        Button.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    -- iOS Style Toggle Button (Görseldeki Gibi)
    function Elements:CreateToggle(toggleText, defaultState, callback)
        local toggled = defaultState or false

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleFrame.Parent = Container

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 10)
        FrameCorner.Parent = ToggleFrame

        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromRGB(180, 230, 232)
        FrameStroke.Thickness = 1
        FrameStroke.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Position = UDim2.new(0, 12, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = toggleText
        Label.TextColor3 = Color3.fromRGB(35, 80, 85)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        -- Switch Background (iOS Capsule)
        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0, 48, 0, 26)
        SwitchBg.Position = UDim2.new(1, -58, 0.5, -13)
        SwitchBg.BackgroundColor3 = toggled and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(218, 225, 225)
        SwitchBg.BorderSizePixel = 0
        SwitchBg.Parent = ToggleFrame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = SwitchBg

        -- Switch Knob (White Circle)
        local SwitchKnob = Instance.new("Frame")
        SwitchKnob.Size = UDim2.new(0, 22, 0, 22)
        SwitchKnob.Position = toggled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SwitchKnob.BorderSizePixel = 0
        SwitchKnob.Parent = SwitchBg

        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = SwitchKnob

        -- Toggle Click Action
        local ClickButton = Instance.new("TextButton")
        ClickButton.Size = UDim2.new(1, 0, 1, 0)
        ClickButton.BackgroundTransparency = 1
        ClickButton.Text = ""
        ClickButton.Parent = ToggleFrame

        ClickButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            local targetColor = toggled and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(218, 225, 225)
            local targetPos = toggled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)

            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()

            callback(toggled)
        end)
    end

    return Elements
end

return ZexHub
