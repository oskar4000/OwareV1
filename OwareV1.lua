local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "👽OwareV1👽",
   LoadingTitle = "Made For FPS Combat",
   LoadingSubtitle = "by 0skar12345_86784 On Discord",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ConfigSave",
      FileName = "OwareV1"
   },
   Discord = {
      Enabled = true,
      Invite = "n7uBZDpV",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Key ! OwareV1",
      Subtitle = "Key System",
      Note = "Key In https://discord.gg/n7uBZDpV",
      FileName = "OwareV1Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/Sge1uUwm"}
   }
})

-- Wait for key verification before creating UI elements
Rayfield:LoadConfiguration()

local MainTab = Window:CreateTab("💢Main💢", nil)
local MainSection = MainTab:CreateSection("Main")

-- ESP Variables
local espEnabled = false
local highlights = {}

-- FOV Circle Variables
local fovCircleEnabled = false
local fovCircleRadius = 100  -- Default FOV radius
local fovCircle
local fovCircleVisible = false

-- Create the FOV circle function
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    
    local player = game:GetService("Players").LocalPlayer
    local camera = workspace.CurrentCamera
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = fovCircleVisible
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(170, 0, 255)  -- Purple to match ESP
    fovCircle.Transparency = 1
    fovCircle.Filled = false
    fovCircle.Radius = fovCircleRadius
    fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    -- Update the circle position and size when viewport changes
    game:GetService("RunService").RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
        end
    end)
end

-- Update the FOV circle function
local function updateFOVCircle()
    if fovCircle then
        fovCircle.Visible = fovCircleVisible
        fovCircle.Radius = fovCircleRadius
    end
end

-- Check if target is within FOV
local function isWithinFOV(position, camera)
    if not fovCircleEnabled then return true end
    
    local screenPoint = camera:WorldToViewportPoint(position)
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    local point = Vector2.new(screenPoint.X, screenPoint.Y)
    
    return (point - screenCenter).Magnitude <= fovCircleRadius
end

local function highlightPlayer(player)
    if not espEnabled or player == game.Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then
        -- If character doesn't exist yet, wait for it
        player.CharacterAdded:Connect(function(char)
            highlightPlayer(player)
        end)
        return
    end
    
    -- Remove existing highlight if any
    if highlights[player] then
        highlights[player]:Destroy()
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = Color3.fromRGB(170, 0, 255)  -- Purple color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)  -- White outline
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.Parent = character
    highlights[player] = highlight
    
    -- Handle respawns
    player.CharacterAdded:Connect(function(newChar)
        if espEnabled then
            task.wait(1) -- Wait for character to fully load
            highlightPlayer(player)
        end
    end)
end

local function removeHighlights()
    for player, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
    end
    highlights = {}
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- Highlight existing players
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            highlightPlayer(player)
        end
        
        -- Connect to new players
        game:GetService("Players").PlayerAdded:Connect(highlightPlayer)
        
        Rayfield:Notify({
            Title = "ESP Enabled",
            Content = "Players are now highlighted in purple",
            Duration = 3,
            Image = nil
        })
    else
        removeHighlights()
        Rayfield:Notify({
            Title = "ESP Disabled",
            Content = "Player highlights removed",
            Duration = 3,
            Image = nil
        })
    end
end

-- Aimbot Variables
local aimbotEnabled = false
local lockedPart = nil
local connection = nil
local mouseButton2DownConnection = nil
local mouseButton2UpConnection = nil

-- Create buttons after key verification
local AimbotButton = MainTab:CreateButton({
   Name = "Aimbot Toggle",
   Callback = function()
      aimbotEnabled = not aimbotEnabled
      
      if aimbotEnabled then
         Rayfield:Notify({
            Title = "Aimbot Enabled",
            Content = "Hold MB2 to lock onto heads",
            Duration = 3,
            Image = nil
         })
         
         local player = game:GetService("Players").LocalPlayer
         local mouse = player:GetMouse()
         local camera = workspace.CurrentCamera
         
         -- Disconnect any existing connections first
         if mouseButton2DownConnection then
            mouseButton2DownConnection:Disconnect()
            mouseButton2DownConnection = nil
         end
         if mouseButton2UpConnection then
            mouseButton2UpConnection:Disconnect()
            mouseButton2UpConnection = nil
         end
         
         mouseButton2DownConnection = mouse.Button2Down:Connect(function()
            local closestDistance = math.huge
            local closestHead = nil
            
            for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
               if otherPlayer ~= player and otherPlayer.Character then
                  local head = otherPlayer.Character:FindFirstChild("Head")
                  if head and isWithinFOV(head.Position, camera) then
                     local distance = (head.Position - camera.CFrame.Position).Magnitude
                     if distance < closestDistance then
                        closestDistance = distance
                        closestHead = head
                     end
                  end
               end
            end
            
            if closestHead then
               lockedPart = closestHead
               connection = game:GetService("RunService").RenderStepped:Connect(function()
                  if lockedPart and lockedPart.Parent then
                     camera.CFrame = CFrame.new(camera.CFrame.Position, lockedPart.Position)
                  else
                     if connection then
                        connection:Disconnect()
                        connection = nil
                     end
                     lockedPart = nil
                  end
               end)
            end
         end)
         
         mouseButton2UpConnection = mouse.Button2Up:Connect(function()
            if connection then
               connection:Disconnect()
               connection = nil
            end
            lockedPart = nil
         end)
      else
         if connection then
            connection:Disconnect()
            connection = nil
         end
         if mouseButton2DownConnection then
            mouseButton2DownConnection:Disconnect()
            mouseButton2DownConnection = nil
         end
         if mouseButton2UpConnection then
            mouseButton2UpConnection:Disconnect()
            mouseButton2UpConnection = nil
         end
         lockedPart = nil
         Rayfield:Notify({
            Title = "Aimbot Disabled",
            Content = "Aimbot is now off",
            Duration = 3,
            Image = nil
         })
      end
   end
})

-- ESP Toggle Button
local EspButton = MainTab:CreateButton({
   Name = "ESP Toggle",
   Callback = toggleESP
})

-- FOV Circle Toggle
local FOVCircleToggle = MainTab:CreateToggle({
   Name = "FOV Circle",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
       fovCircleEnabled = Value
       fovCircleVisible = Value
       if Value then
           createFOVCircle()
       else
           if fovCircle then
               fovCircle:Remove()
               fovCircle = nil
           end
       end
   end,
})

-- FOV Radius Slider
local FOVRadiusSlider = MainTab:CreateSlider({
   Name = "FOV Circle Radius",
   Range = {50, 300},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "Slider1",
   Callback = function(Value)
       fovCircleRadius = Value
       if fovCircle then
           fovCircle.Radius = Value
       end
   end,
})

-- TriggerBot Toggle (Updated Implementation)
local TriggerBotToggle = MainTab:CreateToggle({
   Name = "TriggerBot",
   CurrentValue = false,
   Flag = "Toggle2",
   Callback = function(Value)
       -- TriggerBot variables
       local triggerBotEnabled = Value
       local triggerBotActive = false
       local triggerBotConnection = nil
       local mouse = game:GetService("Players").LocalPlayer:GetMouse()

       -- Function to check if mouse is over enemy
       local function isMouseOverEnemy()
           local player = game:GetService("Players").LocalPlayer
           local target = mouse.Target
           if not target then return false end
           
           local model = target:FindFirstAncestorOfClass("Model")
           if not model then return false end
           
           local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(model)
           if not targetPlayer or targetPlayer == player then return false end
           
           local validParts = {
               "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
               "UpperTorso", "LowerTorso", "HumanoidRootPart"
           }
           
           for _, partName in ipairs(validParts) do
               if target.Name == partName then
                   return true
               end
           end
           
           return false
       end

       -- Function to simulate mouse click
       local function simulateMouseClick()
           mouse.Button1Down:Fire()
           task.wait(0.05)
           mouse.Button1Up:Fire()
       end

       if triggerBotEnabled then
           Rayfield:Notify({
               Title = "TriggerBot Enabled",
               Content = "Hold MB4 to auto-shoot when aiming at enemies",
               Duration = 3,
               Image = nil
           })

           -- Mouse button 4 detection
           mouse.Button4Down:Connect(function()
               triggerBotActive = true
               triggerBotConnection = game:GetService("RunService").RenderStepped:Connect(function()
                   if isMouseOverEnemy() then
                       simulateMouseClick()
                   end
               end)
           end)

           mouse.Button4Up:Connect(function()
               triggerBotActive = false
               if triggerBotConnection then
                   triggerBotConnection:Disconnect()
                   triggerBotConnection = nil
               end
           end)
       else
           if triggerBotConnection then
               triggerBotConnection:Disconnect()
               triggerBotConnection = nil
           end
           triggerBotActive = false
           Rayfield:Notify({
               Title = "TriggerBot Disabled",
               Content = "TriggerBot is now off",
               Duration = 3,
               Image = nil
           })
       end
   end,
})

-- Initial notification
Rayfield:Notify({
   Title = "👽OwareV1👽 Loaded",
   Content = "Key verified successfully!",
   Duration = 5,
   Image = nil,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function()
            print("Script initialized")
         end
      },
   },
})

-- FOV Changer Variables
local fovChangerEnabled = false
local defaultFOV = 70  -- Default game FOV
local currentFOV = 70
local fovChanged = false

-- FOV Changer Toggle
local FOVChangerToggle = MainTab:CreateToggle({
   Name = "FOV Changer",
   CurrentValue = false,
   Flag = "Toggle4",
   Callback = function(Value)
       fovChangerEnabled = Value
       if fovChangerEnabled then
           -- Apply the FOV change
           game:GetService("Workspace").CurrentCamera.FieldOfView = currentFOV
           fovChanged = true
           Rayfield:Notify({
               Title = "FOV Changer Enabled",
               Content = "Field of View has been modified",
               Duration = 3,
               Image = nil
           })
       else
           -- Reset to default FOV
           game:GetService("Workspace").CurrentCamera.FieldOfView = defaultFOV
           fovChanged = false
           Rayfield:Notify({
               Title = "FOV Changer Disabled",
               Content = "Field of View reset to default",
               Duration = 3,
               Image = nil
           })
       end
   end,
})

-- FOV Value Slider (matches the style of FOV Circle slider)
local FOVSlider = MainTab:CreateSlider({
   Name = "FOV Value",
   Range = {50, 120},  -- Common FOV range for games
   Increment = 5,
   Suffix = "°",
   CurrentValue = defaultFOV,
   Flag = "Slider2",
   Callback = function(Value)
       currentFOV = Value
       if fovChangerEnabled and fovChanged then
           -- Only update if the changer is active
           game:GetService("Workspace").CurrentCamera.FieldOfView = currentFOV
       end
   end,
})

-- Reset FOV when script ends or is disabled
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if not fovChanged then
        game:GetService("Workspace").CurrentCamera.FieldOfView = defaultFOV
    end
end)
