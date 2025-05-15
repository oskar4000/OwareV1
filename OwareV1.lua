-- Advanced Aimbot with GUI Configuration
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local camera = Workspace.CurrentCamera

-- Default Configuration
local settings = {
    enabled = true,
    highlightColor = Color3.fromRGB(170, 0, 255),
    transparency = 0.3,
    aimlockKey = Enum.UserInputType.MouseButton2,
    aimlockRange = 1000,
    smoothness = 0.3,
    wallCheck = true,
    fovCircle = true,
    fovSize = 100,
    glowEffect = true,
    teamCheck = true
}

local highlights = {}
local currentTarget = nil
local aimlocking = false
local fovCircleVisual = nil
local glowCircles = {}
local guiEnabled = false
local gui

-- Create GUI
local function createGUI()
    -- Destroy existing GUI if it exists
    if gui then
        gui:Destroy()
    end

    -- Main GUI frame
    gui = Instance.new("ScreenGui")
    gui.Name = "AimbotGUI"
    gui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aimbot Configuration"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = titleBar

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    closeButton.MouseButton1Click:Connect(function()
        guiEnabled = false
        gui.Enabled = false
    end)

    -- Make draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Scroll frame for options
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 150)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
    scrollFrame.Parent = mainFrame

    -- Create toggle option function
    local function createToggleOption(name, text, defaultValue, yPosition, callback)
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = name .. "Option"
        optionFrame.Size = UDim2.new(1, -20, 0, 30)
        optionFrame.Position = UDim2.new(0, 10, 0, yPosition)
        optionFrame.BackgroundTransparency = 1
        optionFrame.Parent = scrollFrame

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = optionFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 50, 0, 20)
        toggleButton.Position = UDim2.new(0.7, 0, 0.5, -10)
        toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = defaultValue and "ON" or "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.TextSize = 12
        toggleButton.Parent = optionFrame

        toggleButton.MouseButton1Click:Connect(function()
            local newValue = not defaultValue
            defaultValue = newValue
            toggleButton.BackgroundColor3 = newValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
            toggleButton.Text = newValue and "ON" or "OFF"
            if callback then callback(newValue) end
        end)

        return defaultValue
    end

    -- Create slider option function
    local function createSliderOption(name, text, minValue, maxValue, defaultValue, yPosition, callback)
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = name .. "Option"
        optionFrame.Size = UDim2.new(1, -20, 0, 50)
        optionFrame.Position = UDim2.new(0, 10, 0, yPosition)
        optionFrame.BackgroundTransparency = 1
        optionFrame.Parent = scrollFrame

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = optionFrame

        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "SliderFrame"
        sliderFrame.Size = UDim2.new(1, 0, 0, 20)
        sliderFrame.Position = UDim2.new(0, 0, 0, 25)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = optionFrame

        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderFrame

        local sliderValue = Instance.new("TextLabel")
        sliderValue.Name = "SliderValue"
        sliderValue.Size = UDim2.new(1, 0, 1, 0)
        sliderValue.BackgroundTransparency = 1
        sliderValue.Text = tostring(defaultValue)
        sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderValue.Font = Enum.Font.GothamBold
        sliderValue.TextSize = 12
        sliderValue.Parent = sliderFrame

        local isSliding = false

        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = true
                local mousePosition = UserInputService:GetMouseLocation().X
                local framePosition = sliderFrame.AbsolutePosition.X
                local frameSize = sliderFrame.AbsoluteSize.X
                local relativePosition = math.clamp(mousePosition - framePosition, 0, frameSize)
                local value = minValue + (relativePosition / frameSize) * (maxValue - minValue)
                value = math.floor(value * 10) / 10
                sliderFill.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
                sliderValue.Text = tostring(value)
                if callback then callback(value) end
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePosition = UserInputService:GetMouseLocation().X
                local framePosition = sliderFrame.AbsolutePosition.X
                local frameSize = sliderFrame.AbsoluteSize.X
                local relativePosition = math.clamp(mousePosition - framePosition, 0, frameSize)
                local value = minValue + (relativePosition / frameSize) * (maxValue - minValue)
                value = math.floor(value * 10) / 10
                sliderFill.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
                sliderValue.Text = tostring(value)
                if callback then callback(value) end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = false
            end
        end)

        return defaultValue
    end

    -- Create color picker function
    local function createColorOption(name, text, defaultColor, yPosition, callback)
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = name .. "Option"
        optionFrame.Size = UDim2.new(1, -20, 0, 30)
        optionFrame.Position = UDim2.new(0, 10, 0, yPosition)
        optionFrame.BackgroundTransparency = 1
        optionFrame.Parent = scrollFrame

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = optionFrame

        local colorButton = Instance.new("TextButton")
        colorButton.Name = "ColorButton"
        colorButton.Size = UDim2.new(0, 50, 0, 20)
        colorButton.Position = UDim2.new(0.7, 0, 0.5, -10)
        colorButton.BackgroundColor3 = defaultColor
        colorButton.BorderSizePixel = 0
        colorButton.Text = ""
        colorButton.Parent = optionFrame

        colorButton.MouseButton1Click:Connect(function()
            local colorPicker = Instance.new("Frame")
            colorPicker.Name = "ColorPicker"
            colorPicker.Size = UDim2.new(0, 150, 0, 150)
            colorPicker.Position = UDim2.new(0, 0, 1, 5)
            colorPicker.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            colorPicker.BorderSizePixel = 0
            colorPicker.Parent = colorButton

            local hueSlider = Instance.new("Frame")
            hueSlider.Name = "HueSlider"
            hueSlider.Size = UDim2.new(0, 20, 0, 130)
            hueSlider.Position = UDim2.new(1, -25, 0, 10)
            hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueSlider.BorderSizePixel = 0
            hueSlider.Parent = colorPicker

            local hueGradient = Instance.new("UIGradient")
            hueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            hueGradient.Rotation = 90
            hueGradient.Parent = hueSlider

            local colorSquare = Instance.new("Frame")
            colorSquare.Name = "ColorSquare"
            colorSquare.Size = UDim2.new(0, 100, 0, 100)
            colorSquare.Position = UDim2.new(0, 10, 0, 10)
            colorSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            colorSquare.BorderSizePixel = 0
            colorSquare.Parent = colorPicker

            local saturationGradient = Instance.new("UIGradient")
            saturationGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            saturationGradient.Parent = colorSquare

            local valueGradient = Instance.new("UIGradient")
            valueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
            })
            valueGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
            })
            valueGradient.Parent = colorSquare

            local selector = Instance.new("Frame")
            selector.Name = "Selector"
            selector.Size = UDim2.new(0, 5, 0, 5)
            selector.Position = UDim2.new(0, 50, 0, 50)
            selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            selector.BorderSizePixel = 1
            selector.BorderColor3 = Color3.fromRGB(0, 0, 0)
            selector.Parent = colorSquare

            local hueSelector = Instance.new("Frame")
            hueSelector.Name = "HueSelector"
            hueSelector.Size = UDim2.new(0, 15, 0, 3)
            hueSelector.Position = UDim2.new(0, 2, 0, 50)
            hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            hueSelector.BorderSizePixel = 1
            hueSelector.BorderColor3 = Color3.fromRGB(0, 0, 0)
            hueSelector.Parent = hueSlider

            local currentHue = 0
            local currentSaturation = 1
            local currentValue = 1

            local function updateColor()
                local color = Color3.fromHSV(currentHue, currentSaturation, currentValue)
                colorButton.BackgroundColor3 = color
                if callback then callback(color) end
            end

            colorSquare.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePosition = UserInputService:GetMouseLocation()
                    local squarePosition = colorSquare.AbsolutePosition
                    local squareSize = colorSquare.AbsoluteSize
                    local relativeX = math.clamp(mousePosition.X - squarePosition.X, 0, squareSize.X)
                    local relativeY = math.clamp(mousePosition.Y - squarePosition.Y, 0, squareSize.Y)
                    currentSaturation = relativeX / squareSize.X
                    currentValue = 1 - (relativeY / squareSize.Y)
                    selector.Position = UDim2.new(0, relativeX - 2, 0, relativeY - 2)
                    updateColor()
                end
            end)

            hueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePosition = UserInputService:GetMouseLocation()
                    local sliderPosition = hueSlider.AbsolutePosition
                    local sliderSize = hueSlider.AbsoluteSize
                    local relativeY = math.clamp(mousePosition.Y - sliderPosition.Y, 0, sliderSize.Y)
                    currentHue = 1 - (relativeY / sliderSize.Y)
                    hueSelector.Position = UDim2.new(0, 2, 0, relativeY - 1)
                    updateColor()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if colorSquare:IsMouseOver() then
                        local mousePosition = UserInputService:GetMouseLocation()
                        local squarePosition = colorSquare.AbsolutePosition
                        local squareSize = colorSquare.AbsoluteSize
                        local relativeX = math.clamp(mousePosition.X - squarePosition.X, 0, squareSize.X)
                        local relativeY = math.clamp(mousePosition.Y - squarePosition.Y, 0, squareSize.Y)
                        currentSaturation = relativeX / squareSize.X
                        currentValue = 1 - (relativeY / squareSize.Y)
                        selector.Position = UDim2.new(0, relativeX - 2, 0, relativeY - 2)
                        updateColor()
                    elseif hueSlider:IsMouseOver() then
                        local mousePosition = UserInputService:GetMouseLocation()
                        local sliderPosition = hueSlider.AbsolutePosition
                        local sliderSize = hueSlider.AbsoluteSize
                        local relativeY = math.clamp(mousePosition.Y - sliderPosition.Y, 0, sliderSize.Y)
                        currentHue = 1 - (relativeY / sliderSize.Y)
                        hueSelector.Position = UDim2.new(0, 2, 0, relativeY - 1)
                        updateColor()
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    wait(0.5)
                    colorPicker:Destroy()
                end
            end)
        end)
    end

    -- Create all options
    local yOffset = 10

    -- Enable/Disable toggle
    settings.enabled = createToggleOption("Enabled", "Enable Aimbot", settings.enabled, yOffset, function(value)
        settings.enabled = value
        if not value then
            clearHighlights()
            if fovCircleVisual then
                fovCircleVisual.Visible = false
                for _, circle in ipairs(glowCircles) do
                    circle.Visible = false
                end
            end
        else
            if fovCircleVisual then
                fovCircleVisual.Visible = settings.fovCircle
                for _, circle in ipairs(glowCircles) do
                    circle.Visible = settings.fovCircle and settings.glowEffect
                end
            end
        end
    end)
    yOffset = yOffset + 35

    -- Team Check toggle
    settings.teamCheck = createToggleOption("TeamCheck", "Team Check", settings.teamCheck, yOffset, function(value)
        settings.teamCheck = value
        clearHighlights()
    end)
    yOffset = yOffset + 35

    -- Wall Check toggle
    settings.wallCheck = createToggleOption("WallCheck", "Wall Check", settings.wallCheck, yOffset, function(value)
        settings.wallCheck = value
    end)
    yOffset = yOffset + 35

    -- FOV Circle toggle
    settings.fovCircle = createToggleOption("FOVCircle", "FOV Circle", settings.fovCircle, yOffset, function(value)
        settings.fovCircle = value
        if fovCircleVisual then
            fovCircleVisual.Visible = value and settings.enabled
            for _, circle in ipairs(glowCircles) do
                circle.Visible = value and settings.enabled and settings.glowEffect
            end
        end
    end)
    yOffset = yOffset + 35

    -- Glow Effect toggle
    settings.glowEffect = createToggleOption("GlowEffect", "Glow Effect", settings.glowEffect, yOffset, function(value)
        settings.glowEffect = value
        clearHighlights()
        if fovCircleVisual and glowCircles then
            for _, circle in ipairs(glowCircles) do
                circle.Visible = value and settings.fovCircle and settings.enabled
            end
        end
    end)
    yOffset = yOffset + 35

    -- FOV Size slider
    settings.fovSize = createSliderOption("FOVSize", "FOV Size", 50, 300, settings.fovSize, yOffset, function(value)
        settings.fovSize = value
        if fovCircleVisual then
            fovCircleVisual.Radius = value
            if glowCircles then
                glowCircles[1].Radius = value + 2
                glowCircles[2].Radius = value + 4
            end
        end
    end)
    yOffset = yOffset + 60

    -- Aimlock Range slider
    settings.aimlockRange = createSliderOption("AimlockRange", "Aimlock Range", 100, 2000, settings.aimlockRange, yOffset, function(value)
        settings.aimlockRange = value
    end)
    yOffset = yOffset + 60

    -- Smoothness slider
    settings.smoothness = createSliderOption("Smoothness", "Aim Smoothness", 0.1, 0.9, settings.smoothness, yOffset, function(value)
        settings.smoothness = value
    end)
    yOffset = yOffset + 60

    -- Transparency slider
    settings.transparency = createSliderOption("Transparency", "ESP Transparency", 0, 0.9, settings.transparency, yOffset, function(value)
        settings.transparency = value
        clearHighlights()
    end)
    yOffset = yOffset + 60

    -- Color picker
    createColorOption("Color", "ESP Color", settings.highlightColor, yOffset, function(color)
        settings.highlightColor = color
        clearHighlights()
    end)
    yOffset = yOffset + 35

    -- Keybind info
    local keybindInfo = Instance.new("TextLabel")
    keybindInfo.Name = "KeybindInfo"
    keybindInfo.Size = UDim2.new(1, -20, 0, 40)
    keybindInfo.Position = UDim2.new(0, 10, 0, yOffset)
    keybindInfo.BackgroundTransparency = 1
    keybindInfo.Text = "Press 'U' to toggle GUI\nRight Click to aimlock"
    keybindInfo.TextColor3 = Color3.fromRGB(170, 0, 255)
    keybindInfo.Font = Enum.Font.GothamBold
    keybindInfo.TextSize = 12
    keybindInfo.TextYAlignment = Enum.TextYAlignment.Top
    keybindInfo.Parent = scrollFrame
end

-- Create FOV circle visualization with purple glow
local function createFOVCircle()
    if not settings.fovCircle then return end
    
    fovCircleVisual = Drawing.new("Circle")
    fovCircleVisual.Visible = settings.enabled
    fovCircleVisual.Radius = settings.fovSize
    fovCircleVisual.Color = settings.highlightColor
    fovCircleVisual.Thickness = 2
    fovCircleVisual.Filled = false
    fovCircleVisual.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    -- Add glow effect by creating multiple circles
    if settings.glowEffect then
        local glowCircle1 = Drawing.new("Circle")
        glowCircle1.Visible = settings.enabled
        glowCircle1.Radius = fovCircleVisual.Radius + 2
        glowCircle1.Color = settings.highlightColor
        glowCircle1.Transparency = 0.7
        glowCircle1.Thickness = 1
        glowCircle1.Filled = false
        glowCircle1.Position = fovCircleVisual.Position
        
        local glowCircle2 = Drawing.new("Circle")
        glowCircle2.Visible = settings.enabled
        glowCircle2.Radius = fovCircleVisual.Radius + 4
        glowCircle2.Color = settings.highlightColor
        glowCircle2.Transparency = 0.85
        glowCircle2.Thickness = 1
        glowCircle2.Filled = false
        glowCircle2.Position = fovCircleVisual.Position
        
        table.insert(glowCircles, glowCircle1)
        table.insert(glowCircles, glowCircle2)
    end
end

-- Create glowing highlight for enemy
local function createHighlight(character)
    if not character or highlights[character] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "EnemyHighlight"
    highlight.FillColor = settings.highlightColor
    highlight.FillTransparency = settings.transparency
    highlight.OutlineColor = settings.highlightColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Add glow effect
    if settings.glowEffect then
        highlight.FillTransparency = settings.transparency + 0.4
        highlight.OutlineTransparency = 0.3
        
        local glowHighlight = Instance.new("Highlight")
        glowHighlight.FillColor = settings.highlightColor
        glowHighlight.FillTransparency = settings.transparency + 0.55
        glowHighlight.OutlineColor = settings.highlightColor
        glowHighlight.OutlineTransparency = 0.5
        glowHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        glowHighlight.Adornee = character
        glowHighlight.Parent = character
        
        highlights[character] = {
            main = highlight,
            glow = glowHighlight
        }
    else
        highlights[character] = {
            main = highlight
        }
    end
    
    highlight.Adornee = character
    highlight.Parent = character
    return highlight
end

-- Clear all highlights
local function clearHighlights()
    for character, highlightData in pairs(highlights) do
        if highlightData.main and highlightData.main.Parent then
            highlightData.main:Destroy()
        end
        if highlightData.glow and highlightData.glow.Parent then
            highlightData.glow:Destroy()
        end
    end
    highlights = {}
end

-- Check if player is on the same team
local function isEnemy(player)
    if not settings.teamCheck then return true end
    if not game:GetService("Teams"):FindFirstChildOfClass("Team") then
        return true -- No teams, everyone is enemy
    end
    
    if localPlayer.Team and player.Team and localPlayer.Team == player.Team then
        return false
    end
    
    return true
end

-- Find the closest enemy within FOV
local function findClosestEnemy()
    local closestPlayer = nil
    local closestDistance = math.huge
    local closestScreenDistance = math.huge
    local cameraPosition = camera.CFrame.Position
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and isEnemy(player) then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if humanoidRootPart and head then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    -- Wall check
                    if settings.wallCheck then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {localPlayer.Character, character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        local raycastResult = Workspace:Raycast(cameraPosition, (head.Position - cameraPosition).Unit * settings.aimlockRange, raycastParams)
                        if raycastResult and raycastResult.Instance and not raycastResult.Instance:IsDescendantOf(character) then
                            continue -- Wall is blocking
                        end
                    end
                    
                    local distance = (humanoidRootPart.Position - cameraPosition).Magnitude
                    if distance <= settings.aimlockRange then
                        local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                        
                        if onScreen then
                            local mousePosition = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                            local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                            local screenDistance = (mousePosition - screenPosition).Magnitude
                            
                            if screenDistance <= (fovCircleVisual and fovCircleVisual.Radius or 150) then
                                if screenDistance < closestScreenDistance then
                                    closestScreenDistance = screenDistance
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Smooth aim function
local function smoothAim(targetPosition)
    local cameraCFrame = camera.CFrame
    local direction = (targetPosition - cameraCFrame.Position).Unit
    local lookAt = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + direction)
    
    for i = 1, 3 do
        camera.CFrame = cameraCFrame:Lerp(lookAt, 1 - settings.smoothness)
        cameraCFrame = camera.CFrame
        task.wait()
    end
end

-- Handle character added
local function onCharacterAdded(character)
    if not settings.enabled then return end
    local player = Players:GetPlayerFromCharacter(character)
    if player and player ~= localPlayer and isEnemy(player) then
        createHighlight(character)
    end
end

-- Initialize
local function initialize()
    -- Set up player connections
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if player.Character then
                onCharacterAdded(player.Character)
            end
            player.CharacterAdded:Connect(onCharacterAdded)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(onCharacterAdded)
        if player.Character then
            onCharacterAdded(player.Character)
        end
    end)
    
    -- Create FOV circle
    createFOVCircle()
end

-- Mouse input for aimlock
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not settings.enabled then return end
    
    if input.UserInputType == settings.aimlockKey then
        currentTarget = findClosestEnemy()
        if currentTarget then
            aimlocking = true
            createHighlight(currentTarget.Character)
            
            local head = currentTarget.Character:FindFirstChild("Head")
            if head then
                smoothAim(head.Position)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == settings.aimlockKey then
        aimlocking = false
        currentTarget = nil
    end
end)

-- Toggle GUI with U key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.U then
        guiEnabled = not guiEnabled
        if guiEnabled then
            if not gui then
                createGUI()
            else
                gui.Enabled = true
            end
            -- Move GUI to mouse position
            local mousePos = UserInputService:GetMouseLocation()
            gui.MainFrame.Position = UDim2.new(0, mousePos.X - 150, 0, mousePos.Y - 200)
        elseif gui then
            gui.Enabled = false
        end
    end
end)

-- Main loop
local connection
connection = RunService.RenderStepped:Connect(function()
    -- Update FOV circle position and glow
    if fovCircleVisual and settings.enabled and settings.fovCircle then
        fovCircleVisual.Visible = true
        fovCircleVisual.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        fovCircleVisual.Color = settings.highlightColor
        
        if settings.glowEffect then
            for i, circle in ipairs(glowCircles) do
                circle.Visible = true
                circle.Position = fovCircleVisual.Position
                circle.Color = settings.highlightColor
                if i == 1 then
                    circle.Radius = fovCircleVisual.Radius + 2
                else
                    circle.Radius = fovCircleVisual.Radius + 4
                end
            end
        end
    elseif fovCircleVisual then
        fovCircleVisual.Visible = false
        for _, circle in ipairs(glowCircles) do
            circle.Visible = false
        end
    end
    
    -- Update highlights
    if settings.enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and not highlights[player.Character] and isEnemy(player) then
                createHighlight(player.Character)
            end
        end
    end
    
    -- Handle continuous aimlock if needed
    if aimlocking and currentTarget and currentTarget.Character and settings.enabled then
        local head = currentTarget.Character:FindFirstChild("Head")
        if head then
            smoothAim(head.Position)
        end
    end
end)

-- Initialize when ready
if localPlayer.Character then
    initialize()
end
localPlayer.CharacterAdded:Connect(initialize)

-- Cleanup function
return function()
    connection:Disconnect()
    clearHighlights()
    if fovCircleVisual then
        fovCircleVisual:Remove()
    end
    for _, circle in ipairs(glowCircles) do
        circle:Remove()
    end
    if gui then
        gui:Destroy()
    end
    print("Script unloaded")
end
