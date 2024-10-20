local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local camera = game.Workspace.CurrentCamera
local targetPlayer = nil  -- The player to lock onto
local lockEnabled = false  -- To check if locking is enabled
local notificationDuration = 3  -- Duration for the notification
local zoomDistance = 10  -- Default zoom distance
local zoomStep = 2  -- How much to zoom in or out with each scroll

-- Function to find the closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge  -- Initialize with a large value

    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local distance = (player.Character.HumanoidRootPart.Position - otherPlayer.Character.Head.Position).magnitude
            if distance < shortestDistance then
                closestPlayer = otherPlayer
                shortestDistance = distance
            end
        end
    end

    return closestPlayer
end

-- Function to show a notification
local function showNotification(username)
    -- Create a ScreenGui for the notification
    local notificationGui = Instance.new("ScreenGui")
    local notificationFrame = Instance.new("Frame")
    local titleLabel = Instance.new("TextLabel")
    local descriptionLabel = Instance.new("TextLabel")

    -- Set up the ScreenGui
    notificationGui.Name = "NotificationGui"
    notificationGui.Parent = player:WaitForChild("PlayerGui")

    -- Set up the notification frame
    notificationFrame.Size = UDim2.new(0, 300, 0, 100)
    notificationFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
    notificationFrame.BackgroundColor3 = Color3.new(0, 0, 0)  -- Black background
    notificationFrame.BackgroundTransparency = 0.5
    notificationFrame.Parent = notificationGui

    -- Set up the title label
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Saturn"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)  -- White text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = notificationFrame

    -- Set up the description label
    descriptionLabel.Size = UDim2.new(1, 0, 0, 70)
    descriptionLabel.Position = UDim2.new(0, 0, 0, 30)
    descriptionLabel.Text = "Locked onto " .. username
    descriptionLabel.TextColor3 = Color3.new(1, 1, 1)  -- White text
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Parent = notificationFrame

    -- Destroy the notification after the specified duration
    wait(notificationDuration)
    notificationGui:Destroy()
end

-- Function to lock onto the head of the closest player
local function lockOnHead()
    if lockEnabled and targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            -- Position the camera to lock onto the head with zoom functionality
            local cameraPosition = head.Position + Vector3.new(0, zoomDistance, 0)
            camera.CFrame = CFrame.new(cameraPosition, head.Position)  -- Adjust height if necessary
        end
    end
end

-- Key press detection
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.E then
            lockEnabled = not lockEnabled  -- Toggle lock state
            if lockEnabled then
                targetPlayer = getClosestPlayer()  -- Get the closest player when locking
                if targetPlayer then
                    showNotification(targetPlayer.Name)  -- Show notification with the target player's name
                end
            end
        end
    end
end)

-- Mouse scroll detection for zooming
UserInputService.InputChanged:Connect(function(input)
    if lockEnabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        zoomDistance = math.clamp(zoomDistance - (input.Position.Z > 0 and zoomStep or -zoomStep), 5, 50)  -- Adjust zoom limits as needed
    end
end)

-- RenderStepped connection to update camera position
game:GetService("RunService").RenderStepped:Connect(function()
    lockOnHead()  -- Continuously check to lock onto the player's head
end)
