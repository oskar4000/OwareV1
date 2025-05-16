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

-------------------
-- SILENT AIM SECTION --
-------------------
local SilentAimSection = MainTab:CreateSection("Silent Aim")

-- Silent Aim Variables
local silentAimEnabled = false
local silentAimFOV = 100
local silentAimCircle
local silentAimCircleVisible = false
local silentAimConnection

-- Create the Silent Aim FOV circle
local function createSilentAimFOVCircle()
    if silentAimCircle then silentAimCircle:Remove() end
    
    local camera = workspace.CurrentCamera
    silentAimCircle = Drawing.new("Circle")
    silentAimCircle.Visible = silentAimCircleVisible
    silentAimCircle.Thickness = 2
    silentAimCircle.Color = Color3.fromRGB(255, 0, 0) -- Red color for distinction
    silentAimCircle.Transparency = 1
    silentAimCircle.Filled = false
    silentAimCircle.Radius = silentAimFOV
    silentAimCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if silentAimCircle then
            silentAimCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
            silentAimCircle.Radius = silentAimFOV
        end
    end)
end

-- Silent Aim FOV Circle Toggle
local SilentAimFOVToggle = MainTab:CreateToggle({
   Name = "Silent Aim FOV Circle",
   CurrentValue = false,
   Flag = "Toggle5",
   Callback = function(Value)
       silentAimCircleVisible = Value
       if Value then
           createSilentAimFOVCircle()
       else
           if silentAimCircle then
               silentAimCircle:Remove()
               silentAimCircle = nil
           end
       end
   end,
})

-- Silent Aim FOV Radius Slider
local SilentAimFOVSlider = MainTab:CreateSlider({
   Name = "Silent Aim FOV Radius",
   Range = {50, 300},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 100,
   Flag = "Slider3",
   Callback = function(Value)
       silentAimFOV = Value
       if silentAimCircle then
           silentAimCircle.Radius = Value
       end
   end,
})

-- Silent Aim Toggle Button
local SilentAimButton = MainTab:CreateButton({
   Name = "Silent Aim Toggle",
   Callback = function()
      silentAimEnabled = not silentAimEnabled
      
      if silentAimEnabled then
         Rayfield:Notify({
            Title = "Silent Aim Enabled",
            Content = "Your shots will hit enemies within FOV",
            Duration = 3,
            Image = nil
         })
         
         -- Hook the necessary functions for Silent Aim
         -- Note: This needs to be adapted to the specific game's shooting mechanics
         local mt = getrawmetatable(game)
         local oldNamecall = mt.__namecall
         
         setreadonly(mt, false)
         
         mt.__namecall = newcclosure(function(self, ...)
             local method = getnamecallmethod()
             local args = {...}
             
             if silentAimEnabled and method == "FireServer" then
                 local player = game:GetService("Players").LocalPlayer
                 local camera = workspace.CurrentCamera
                 local closestDistance = math.huge
                 local closestHead = nil
                 
                 -- Find closest head in FOV
                 for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
                     if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
                         local head = otherPlayer.Character:FindFirstChild("Head")
                         if head then
                             local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                             
                             -- Check if within Silent Aim FOV
                             if silentAimCircleVisible then
                                 if screenPoint.Z > 0 then -- Only if in front of camera
                                     local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                                     local circleCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                                     local distanceFromCenter = (screenPos - circleCenter).Magnitude
                                     if distanceFromCenter > silentAimFOV then
                                         continue -- Skip if outside FOV circle
                                     end
                                 else
                                     continue -- Skip if behind camera
                                 end
                             end
                             
                             if onScreen then
                                 local distance = (head.Position - camera.CFrame.Position).Magnitude
                                 if distance < closestDistance then
                                     closestDistance = distance
                                     closestHead = head
                                 end
                             end
                         end
                     end
                 end
                 
                 -- Modify the target if we found a valid head
                 if closestHead then
                     args[1] = closestHead.Position -- Modify the target position
                 end
             end
             
             return oldNamecall(self, unpack(args))
         end)
         
         setreadonly(mt, true)
         
      else
         -- Clean up when disabling
         if silentAimConnection then silentAimConnection:Disconnect() end
         Rayfield:Notify({
            Title = "Silent Aim Disabled",
            Content = "Silent Aim is now off",
            Duration = 3,
            Image = nil
         })
         
         -- Restore original metatable
         local mt = getrawmetatable(game)
         if mt and mt.__namecall then
             setreadonly(mt, false)
             mt.__namecall = nil
             setreadonly(mt, true)
         end
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

-- TriggerBot Toggle
local TriggerBotToggle = MainTab:CreateToggle({
   Name = "TriggerBot",
   CurrentValue = false,
   Flag = "Toggle2",
   Callback = function(Value)
       local triggerBotEnabled = Value
       local triggerBotActive = false
       local triggerBotConnection = nil
       local mouse = game:GetService("Players").LocalPlayer:GetMouse()

       local function isMouseOverEnemy()
           local player = game:GetService("Players").LocalPlayer
           local target = mouse.Target
           if not target then return false end
           
           local model = target:FindFirstAncestorOfClass("Model")
           if not model then return false end
           
           local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(model)
           if not targetPlayer or targetPlayer == player then return false end
           
           local validParts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
           for _, partName in ipairs(validParts) do
               if target.Name == partName then return true end
           end
           return false
       end

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

           mouse.Button4Down:Connect(function()
               triggerBotActive = true
               triggerBotConnection = game:GetService("RunService").RenderStepped:Connect(function()
                   if isMouseOverEnemy() then simulateMouseClick() end
               end)
           end)

           mouse.Button4Up:Connect(function()
               triggerBotActive = false
               if triggerBotConnection then triggerBotConnection:Disconnect() end
           end)
       else
           if triggerBotConnection then triggerBotConnection:Disconnect() end
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

-- Reset FOV when script ends or is disabled
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if not fovChanged then
        game:GetService("Workspace").CurrentCamera.FieldOfView = defaultFOV
    end
end)
