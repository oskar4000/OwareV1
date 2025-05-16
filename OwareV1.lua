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
      Note = "Join our [Discord](https://discord.gg/n7uBZDpV) to get the key",
      FileName = "OwareV1Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/Sge1uUwm"}
   }
})

Rayfield:LoadConfiguration()

local MainTab = Window:CreateTab("💢Main💢", nil)

-------------------
-- AIMBOT SECTION --
-------------------
local AimbotSection = MainTab:CreateSection("Aimbot")

-- Aimbot Variables
local aimbotEnabled = false
local lockedPart = nil
local connection = nil
local mouseButton2DownConnection = nil
local mouseButton2UpConnection = nil

-- FOV Circle Variables
local fovCircleEnabled = false
local fovCircleRadius = 100
local fovCircle
local fovCircleVisible = false

-- Create the FOV circle function
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    
    local camera = workspace.CurrentCamera
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = fovCircleVisible
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(170, 0, 255)
    fovCircle.Transparency = 1
    fovCircle.Filled = false
    fovCircle.Radius = fovCircleRadius
    fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
            fovCircle.Radius = fovCircleRadius
        end
    end)
end

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

-- Aimbot Button
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
         
         -- Disconnect previous connections if they exist
         if mouseButton2DownConnection then mouseButton2DownConnection:Disconnect() end
         if mouseButton2UpConnection then mouseButton2UpConnection:Disconnect() end
         if connection then connection:Disconnect() end
         
         mouseButton2DownConnection = mouse.Button2Down:Connect(function()
            local closestDistance = math.huge
            local closestHead = nil
            local playerPosition = camera.CFrame.Position
            
            for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
               if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
                  local head = otherPlayer.Character:FindFirstChild("Head")
                  if head then
                     local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                     local distance = (head.Position - playerPosition).Magnitude
                     
                     -- Check if within FOV circle if enabled
                     if fovCircleEnabled then
                        local screenPoint = camera:WorldToViewportPoint(head.Position)
                        if screenPoint.Z > 0 then -- Only if in front of camera
                            local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                            local circleCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                            local distanceFromCenter = (screenPos - circleCenter).Magnitude
                            if distanceFromCenter > fovCircleRadius then
                               continue -- Skip if outside FOV circle
                            end
                        else
                            continue -- Skip if behind camera
                        end
                     end
                     
                     if onScreen and distance < closestDistance then
                        closestDistance = distance
                        closestHead = head
                     end
                  end
               end
            end
            
            if closestHead then
               lockedPart = closestHead
               connection = game:GetService("RunService").RenderStepped:Connect(function()
                  if lockedPart and lockedPart.Parent and lockedPart.Parent:FindFirstChild("Humanoid") and lockedPart.Parent.Humanoid.Health > 0 then
                     -- Smooth aiming
                     local currentCFrame = camera.CFrame
                     local targetPosition = lockedPart.Position
                     local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                     camera.CFrame = newCFrame:Lerp(newCFrame, 0.7) -- Adjust the lerp value for smoother/stiffer aiming
                  else
                     if connection then connection:Disconnect() end
                     lockedPart = nil
                  end
               end)
            end
         end)
         
         mouseButton2UpConnection = mouse.Button2Up:Connect(function()
            if connection then connection:Disconnect() end
            lockedPart = nil
         end)
      else
         -- Clean up when disabling
         if connection then connection:Disconnect() end
         if mouseButton2DownConnection then mouseButton2DownConnection:Disconnect() end
         if mouseButton2UpConnection then mouseButton2UpConnection:Disconnect() end
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

----------------
-- ESP SECTION --
----------------
local ESPSection = MainTab:CreateSection("ESP")

-- ESP Variables
local espEnabled = false
local highlights = {}
local espColor = Color3.fromRGB(170, 0, 255) -- Default purple color

local function highlightPlayer(player)
    if not espEnabled or player == game.Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then
        player.CharacterAdded:Connect(function(char)
            highlightPlayer(player)
        end)
        return
    end
    
    if highlights[player] then highlights[player]:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = espColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.Parent = character
    highlights[player] = highlight
    
    player.CharacterAdded:Connect(function(newChar)
        if espEnabled then
            task.wait(1)
            highlightPlayer(player)
        end
    end)
end

local function removeHighlights()
    for player, highlight in pairs(highlights) do
        if highlight then highlight:Destroy() end
    end
    highlights = {}
end

local function updateHighlightColors()
    for player, highlight in pairs(highlights) do
        if highlight and highlight:IsA("Highlight") then
            highlight.FillColor = espColor
        end
    end
end

-- ESP Toggle Button
local EspButton = MainTab:CreateButton({
   Name = "ESP Toggle",
   Callback = function()
      espEnabled = not espEnabled
      
      if espEnabled then
         for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            highlightPlayer(player)
         end
         game:GetService("Players").PlayerAdded:Connect(highlightPlayer)
         Rayfield:Notify({
            Title = "ESP Enabled",
            Content = "Players are now highlighted",
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
})

-- ESP Color Picker
local EspColorPicker = MainTab:CreateColorPicker({
    Name = "ESP Color",
    Color = espColor,
    Flag = "ESPColorPicker",
    Callback = function(Value)
        espColor = Value
        updateHighlightColors()
    end
})

-----------------
-- MISC SECTION --
-----------------
local MiscSection = MainTab:CreateSection("Misc")

-- Spin Bot Variables
local spinBotEnabled = false
local spinBotSpeed = 10 -- rotations per second
local spinBotConnection = nil

-- Spin Bot Toggle
local SpinBotToggle = MainTab:CreateToggle({
   Name = "Spin Bot",
   CurrentValue = false,
   Flag = "Toggle5",
   Callback = function(Value)
       spinBotEnabled = Value
       if spinBotEnabled then
           -- Start spinning
           if spinBotConnection then spinBotConnection:Disconnect() end
           
           spinBotConnection = game:GetService("RunService").RenderStepped:Connect(function(delta)
               if spinBotEnabled then
                   local character = game.Players.LocalPlayer.Character
                   if character then
                       local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                       if humanoidRootPart then
                           -- Rotate the character without affecting the camera
                           humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinBotSpeed * 360 * delta), 0)
                       end
                   end
               end
           end)
           
           Rayfield:Notify({
               Title = "Spin Bot Enabled",
               Content = "Your character is now spinning",
               Duration = 3,
               Image = nil
           })
       else
           -- Stop spinning
           if spinBotConnection then
               spinBotConnection:Disconnect()
               spinBotConnection = nil
           end
           Rayfield:Notify({
               Title = "Spin Bot Disabled",
               Content = "Spin bot is now off",
               Duration = 3,
               Image = nil
           })
       end
   end,
})

-- Spin Bot Speed Slider
local SpinBotSpeedSlider = MainTab:CreateSlider({
   Name = "Spin Bot Speed",
   Range = {1, 30},
   Increment = 1,
   Suffix = "rotations/sec",
   CurrentValue = 10,
   Flag = "Slider3",
   Callback = function(Value)
       spinBotSpeed = Value
   end,
})

-- FOV Changer Variables
local fovChangerEnabled = false
local defaultFOV = 70
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
           game:GetService("Workspace").CurrentCamera.FieldOfView = currentFOV
           fovChanged = true
           Rayfield:Notify({
               Title = "FOV Changer Enabled",
               Content = "Field of View has been modified",
               Duration = 3,
               Image = nil
           })
       else
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

-- FOV Value Slider
local FOVSlider = MainTab:CreateSlider({
   Name = "FOV Value",
   Range = {50, 120},
   Increment = 5,
   Suffix = "°",
   CurrentValue = defaultFOV,
   Flag = "Slider2",
   Callback = function(Value)
       currentFOV = Value
       if fovChangerEnabled and fovChanged then
           game:GetService("Workspace").CurrentCamera.FieldOfView = currentFOV
       end
   end,
})

----------------------
-- MOVEMENT SECTION --
----------------------
local MoveTab = Window:CreateTab("🏃‍♀️‍➡️Movement🏃‍♀️‍➡️", nil)
local MovementSection = MoveTab:CreateSection("Movement Modifiers")

-- WalkSpeed Variables
local walkSpeedEnabled = false
local defaultWalkSpeed = 16
local currentWalkSpeed = 50
local walkSpeedConnection = nil

-- WalkSpeed Toggle
local WalkSpeedToggle = MoveTab:CreateToggle({
    Name = "WalkSpeed Modifier",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        walkSpeedEnabled = Value
        local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if walkSpeedEnabled then
            if humanoid then
                humanoid.WalkSpeed = currentWalkSpeed
            end
            walkSpeedConnection = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Wait for character to fully load
                humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = currentWalkSpeed
                end
            end)
            Rayfield:Notify({
                Title = "WalkSpeed Enabled",
                Content = "Your WalkSpeed has been modified to " .. currentWalkSpeed,
                Duration = 3,
                Image = nil
            })
        else
            if walkSpeedConnection then
                walkSpeedConnection:Disconnect()
            end
            if humanoid then
                humanoid.WalkSpeed = defaultWalkSpeed
            end
            Rayfield:Notify({
                Title = "WalkSpeed Disabled",
                Content = "Your WalkSpeed has been reset to default",
                Duration = 3,
                Image = nil
            })
        end
    end,
})

-- WalkSpeed Slider
local WalkSpeedSlider = MoveTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 200},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = currentWalkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        currentWalkSpeed = Value
        if walkSpeedEnabled then
            local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = currentWalkSpeed
            end
        end
    end,
})

-- JumpPower Variables
local jumpPowerEnabled = false
local defaultJumpPower = 50
local currentJumpPower = 100
local jumpPowerConnection = nil

-- JumpPower Toggle
local JumpPowerToggle = MoveTab:CreateToggle({
    Name = "JumpPower Modifier",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        jumpPowerEnabled = Value
        local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        if jumpPowerEnabled then
            if humanoid then
                humanoid.JumpPower = currentJumpPower
            end
            jumpPowerConnection = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Wait for character to fully load
                humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = currentJumpPower
                end
            end)
            Rayfield:Notify({
                Title = "JumpPower Enabled",
                Content = "Your JumpPower has been modified to " .. currentJumpPower,
                Duration = 3,
                Image = nil
            })
        else
            if jumpPowerConnection then
                jumpPowerConnection:Disconnect()
            end
            if humanoid then
                humanoid.JumpPower = defaultJumpPower
            end
            Rayfield:Notify({
                Title = "JumpPower Disabled",
                Content = "Your JumpPower has been reset to default",
                Duration = 3,
                Image = nil
            })
        end
    end,
})

-- JumpPower Slider
local JumpPowerSlider = MoveTab:CreateSlider({
    Name = "JumpPower Value",
    Range = {50, 200},
    Increment = 5,
    Suffix = "power",
    CurrentValue = currentJumpPower,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        currentJumpPower = Value
        if jumpPowerEnabled then
            local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = currentJumpPower
            end
        end
    end,
})

-- Infinite Jump Variables
local infiniteJumpEnabled = false
local infiniteJumpConnection = nil

-- Infinite Jump Toggle
local InfiniteJumpToggle = MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        infiniteJumpEnabled = Value
        
        if infiniteJumpEnabled then
            Rayfield:Notify({
                Title = "Infinite Jump Enabled",
                Content = "You can now jump infinitely!",
                Duration = 3,
                Image = nil
            })
            
            -- Disconnect previous connection if it exists
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
            end
            
            -- Connect to UserInputService
            infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if infiniteJumpEnabled then
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)
        else
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
            end
            Rayfield:Notify({
                Title = "Infinite Jump Disabled",
                Content = "Normal jumping restored",
                Duration = 3,
                Image = nil
            })
        end
    end,
})

-- Handle character respawns for all movement features
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
    -- Handle spin bot
    if spinBotEnabled then
        if spinBotConnection then
            spinBotConnection:Disconnect()
        end
        
        -- Wait for character to fully load
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if humanoidRootPart then
            spinBotConnection = game:GetService("RunService").RenderStepped:Connect(function(delta)
                if spinBotEnabled then
                    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinBotSpeed * 360 * delta), 0)
                end
            end)
        end
    end
    
    -- Handle WalkSpeed
    if walkSpeedEnabled then
        task.wait(0.5)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = currentWalkSpeed
        end
    end
    
    -- Handle JumpPower
    if jumpPowerEnabled then
        task.wait(0.5)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = currentJumpPower
        end
    end
    
    -- Reset FOV when character respawns if not changed
    if not fovChanged then
        game:GetService("Workspace").CurrentCamera.FieldOfView = defaultFOV
    end
end)

-- Clean up connections when character is removed
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if spinBotConnection then
        spinBotConnection:Disconnect()
    end
end)

-- Initial notification
Rayfield:Notify({
   Title = "👽OwareV1👽 Loaded",
   Content = "Key verified successfully!",
   Duration = 5,
   Image = nil,
   Actions = {
      Ignore = {
         Name = "Okay!",
         Callback = function() print("Script initialized") end
      },
   },
})
