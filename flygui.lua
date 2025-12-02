local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaFlyGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 90)
mainFrame.Position = UDim2.new(0, 20, 0.4, -40)  -- LEFT SIDE FOR ANDROID
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim2.new(0, 12, 0, 12)
frameCorner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Delta Fly"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- X Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -38, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim2.new(0, 8, 0, 8)
closeCorner.Parent = closeButton

-- Fly Toggle Button
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.85, 0, 0, 45)
flyButton.Position = UDim2.new(0.075, 0, 0.45, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
flyButton.Text = "FLY OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextScaled = true
flyButton.Font = Enum.Font.GothamSemibold
flyButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim2.new(0, 10, 0, 10)
buttonCorner.Parent = flyButton

-- Fly Variables
local flying = false
local flySpeed = 50
local flyConnection
local bodyVelocity
local bodyAngularVelocity

-- Notification
StarterGui:SetCore("SendNotification", {
    Title = "Delta Fly Loaded!";
    Text = "Tap FLY ON • Use thumbstick to move • Drag GUI";
    Duration = 4;
})

-- Toggle Fly Function
local function toggleFly()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    flying = not flying
    
    if flying then
        -- Enable Fly
        flyButton.Text = "FLY ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Disable states & gravity
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            humanoid:SetStateEnabled(state, state == Enum.HumanoidStateType.Physics)
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Create Body Movers
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        -- Fly Loop (Thumbstick + Camera direction)
        flyConnection = RunService.Heartbeat:Connect(function()
            if character and character.Parent and rootPart and rootPart.Parent and bodyVelocity then
                local moveVector = humanoid.MoveDirection
                if moveVector.Magnitude > 0 then
                    local camera = workspace.CurrentCamera
                    local cameraCFrame = camera.CFrame
                    local moveDirection = (cameraCFrame.LookVector * moveVector.Z + cameraCFrame.RightVector * moveVector.X)
                    bodyVelocity.Velocity = moveDirection * flySpeed
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
        
    else
        -- Disable Fly
        flyButton.Text = "FLY OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
        
        -- Re-enable states
        for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
            humanoid:SetStateEnabled(state, true)
        end
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- Button Connections
flyButton.MouseButton1Click:Connect(toggleFly)
closeButton.MouseButton1Click:Connect(function()
    if flyConnection then flyConnection:Disconnect() end
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
    screenGui:Destroy()
end)

-- Cleanup on death/respawn
player.CharacterAdded:Connect(function()
    if flying then
        wait(1)
        toggleFly()
        toggleFly()
    end
end)
