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
                  if head then
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

-- ESP Toggle Button (now properly visible)
local EspButton = MainTab:CreateButton({
   Name = "ESP Toggle",
   Callback = toggleESP
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
