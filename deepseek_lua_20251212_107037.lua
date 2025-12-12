-- Position Manager Script dengan UI Custom Fixed
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local savedPositions = {}
local currentTeleportIndex = 1
local teleportEnabled = false
local minimized = false
local dragging = false
local dragStart = Vector2.new(0, 0)
local frameStart = UDim2.new(0, 0, 0, 0)
local originalSize = UDim2.new(0, 350, 0, 280) -- Diperbesar untuk fitur tambahan

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game.CoreGui
else
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = originalSize
mainContainer.Position = UDim2.new(0.5, -175, 0.5, -140)
mainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainContainer.BackgroundTransparency = 0.1
mainContainer.ClipsDescendants = true

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = mainContainer

-- Drop shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = mainContainer

-- Title Bar (untuk drag)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BackgroundTransparency = 0.1
titleBar.Active = true
titleBar.Selectable = true

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 10)
titleBarCorner.Parent = titleBar

-- Status indicator di title bar
local statusIndicator = Instance.new("Frame")
statusIndicator.Name = "StatusIndicator"
statusIndicator.Size = UDim2.new(0, 10, 0, 10)
statusIndicator.Position = UDim2.new(0, 15, 0.5, -5)
statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusIndicator

-- Title dengan RGB effect
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Text = "Position Manager | (WaveTerminal)"
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 35, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.Code
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.Code

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

-- Content Frame (akan disembunyikan saat minimize)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Visible = true

-- Section 1: Save Position
local saveSection = Instance.new("Frame")
saveSection.Name = "SaveSection"
saveSection.Size = UDim2.new(1, 0, 0, 50)
saveSection.Position = UDim2.new(0, 0, 0, 0)
saveSection.BackgroundTransparency = 1

local saveLabel = Instance.new("TextLabel")
saveLabel.Name = "SaveLabel"
saveLabel.Text = "Save Current Position"
saveLabel.Size = UDim2.new(1, 0, 0, 25)
saveLabel.Position = UDim2.new(0, 0, 0, 0)
saveLabel.BackgroundTransparency = 1
saveLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
saveLabel.TextSize = 14
saveLabel.Font = Enum.Font.Code
saveLabel.TextXAlignment = Enum.TextXAlignment.Left

local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveBtn"
saveBtn.Text = "SAVE POS"
saveBtn.Size = UDim2.new(1, 0, 0, 25)
saveBtn.Position = UDim2.new(0, 0, 0, 25)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.TextSize = 14
saveBtn.Font = Enum.Font.Code

local saveBtnCorner = Instance.new("UICorner")
saveBtnCorner.CornerRadius = UDim.new(0, 6)
saveBtnCorner.Parent = saveBtn

-- Section 2: Position Controls
local posControlsSection = Instance.new("Frame")
posControlsSection.Name = "PosControlsSection"
posControlsSection.Size = UDim2.new(1, 0, 0, 80)
posControlsSection.Position = UDim2.new(0, 0, 0, 60)
posControlsSection.BackgroundTransparency = 1

local posLabel = Instance.new("TextLabel")
posLabel.Name = "PosLabel"
posLabel.Text = "Position Controls:"
posLabel.Size = UDim2.new(1, 0, 0, 25)
posLabel.Position = UDim2.new(0, 0, 0, 0)
posLabel.BackgroundTransparency = 1
posLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
posLabel.TextSize = 14
posLabel.Font = Enum.Font.Code
posLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Position Display dengan Copy Button
local posDisplayFrame = Instance.new("Frame")
posDisplayFrame.Name = "PosDisplayFrame"
posDisplayFrame.Size = UDim2.new(1, 0, 0, 25)
posDisplayFrame.Position = UDim2.new(0, 0, 0, 25)
posDisplayFrame.BackgroundTransparency = 1

local currentPosLabel = Instance.new("TextLabel")
currentPosLabel.Name = "CurrentPosLabel"
currentPosLabel.Text = "Current: Loading..."
currentPosLabel.Size = UDim2.new(0.7, 0, 1, 0)
currentPosLabel.Position = UDim2.new(0, 0, 0, 0)
currentPosLabel.BackgroundTransparency = 1
currentPosLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
currentPosLabel.TextSize = 12
currentPosLabel.Font = Enum.Font.Code
currentPosLabel.TextXAlignment = Enum.TextXAlignment.Left

local copyPosBtn = Instance.new("TextButton")
copyPosBtn.Name = "CopyPosBtn"
copyPosBtn.Text = "COPY"
copyPosBtn.Size = UDim2.new(0.3, 0, 1, 0)
copyPosBtn.Position = UDim2.new(0.7, 0, 0, 0)
copyPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
copyPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyPosBtn.TextSize = 11
copyPosBtn.Font = Enum.Font.Code

local copyBtnCorner = Instance.new("UICorner")
copyBtnCorner.CornerRadius = UDim.new(0, 6)
copyBtnCorner.Parent = copyPosBtn

-- Teleport Button
local teleportBtn = Instance.new("TextButton")
teleportBtn.Name = "TeleportBtn"
teleportBtn.Text = "TELEPORT TO SELECTED"
teleportBtn.Size = UDim2.new(1, 0, 0, 25)
teleportBtn.Position = UDim2.new(0, 0, 0, 55)
teleportBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.TextSize = 14
teleportBtn.Font = Enum.Font.Code

local teleportBtnCorner = Instance.new("UICorner")
teleportBtnCorner.CornerRadius = UDim.new(0, 6)
teleportBtnCorner.Parent = teleportBtn

-- Section 3: Saved Positions List dengan scrolling
local listSection = Instance.new("Frame")
listSection.Name = "ListSection"
listSection.Size = UDim2.new(1, 0, 0, 90)
listSection.Position = UDim2.new(0, 0, 0, 150)
listSection.BackgroundTransparency = 1

local listLabel = Instance.new("TextLabel")
listLabel.Name = "ListLabel"
listLabel.Text = "Saved Positions:"
listLabel.Size = UDim2.new(1, 0, 0, 25)
listLabel.Position = UDim2.new(0, 0, 0, 0)
listLabel.BackgroundTransparency = 1
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.TextSize = 14
listLabel.Font = Enum.Font.Code
listLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ScrollingFrame untuk list posisi
local positionsList = Instance.new("ScrollingFrame")
positionsList.Name = "PositionsList"
positionsList.Size = UDim2.new(1, 0, 0, 60)
positionsList.Position = UDim2.new(0, 0, 0, 25)
positionsList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
positionsList.BackgroundTransparency = 0.1
positionsList.BorderSizePixel = 0
positionsList.ScrollBarThickness = 8
positionsList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
positionsList.CanvasSize = UDim2.new(0, 0, 0, 0)
positionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Auto resize

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 6)
listCorner.Parent = positionsList

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = positionsList
listLayout.Padding = UDim.new(0, 3)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Parent all elements
titleBar.Parent = mainContainer
titleLabel.Parent = titleBar
statusIndicator.Parent = titleBar
minimizeBtn.Parent = titleBar
contentFrame.Parent = mainContainer

saveSection.Parent = contentFrame
saveLabel.Parent = saveSection
saveBtn.Parent = saveSection

posControlsSection.Parent = contentFrame
posLabel.Parent = posControlsSection
posDisplayFrame.Parent = posControlsSection
currentPosLabel.Parent = posDisplayFrame
copyPosBtn.Parent = posDisplayFrame
teleportBtn.Parent = posControlsSection

listSection.Parent = contentFrame
listLabel.Parent = listSection
positionsList.Parent = listSection

mainContainer.Parent = screenGui

-- Drag functionality untuk semua platform (Windows & Android)
local function onDrag(input)
    if not dragging then return end
    
    local delta = input.Position - dragStart
    mainContainer.Position = UDim2.new(
        frameStart.X.Scale,
        frameStart.X.Offset + delta.X,
        frameStart.Y.Scale,
        frameStart.Y.Offset + delta.Y
    )
end

-- Handle input untuk drag (support touch dan mouse)
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = mainContainer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

-- Handle drag movement
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        onDrag(input)
    end
end)

-- RGB Animation function
local function createRGBAnimation(element, speed, property)
    local hue = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function(delta)
        if not element or not element.Parent then
            connection:Disconnect()
            return
        end
        
        hue = (hue + speed * delta) % 1
        local color = Color3.fromHSV(hue, 0.8, 1)
        
        if property == "TextColor3" then
            element.TextColor3 = color
        elseif property == "BackgroundColor3" then
            element.BackgroundColor3 = color
        end
    end)
    
    return connection
end

-- Apply RGB animations ke title
createRGBAnimation(titleLabel, 0.5, "TextColor3")

-- Fungsi untuk mendapatkan posisi pemain saat ini
local function getCurrentPosition()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart.Position
    end
    return nil
end

-- Fungsi untuk format koordinat
local function formatPosition(pos)
    return string.format("X:%.1f, Y:%.1f, Z:%.1f", pos.X, pos.Y, pos.Z)
end

-- Fungsi untuk mendapatkan string posisi
local function getPositionString(pos)
    return string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
end

-- Fungsi untuk update posisi saat ini secara real-time
local function updateCurrentPosition()
    while true do
        local currentPos = getCurrentPosition()
        if currentPos then
            currentPosLabel.Text = "Current: " .. formatPosition(currentPos)
        else
            currentPosLabel.Text = "Current: No character"
        end
        task.wait(0.5) -- Update setiap 0.5 detik
    end
end

-- Fungsi untuk menyimpan posisi
local function savePosition()
    local currentPos = getCurrentPosition()
    
    if currentPos then
        local posName = "Pos " .. #savedPositions + 1
        local positionData = {
            name = posName,
            position = currentPos,
            timestamp = os.time()
        }
        
        table.insert(savedPositions, positionData)
        
        -- Update status
        statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        task.wait(0.2)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        -- Update list
        updatePositionsList()
        
        print("Position saved: " .. posName .. " " .. formatPosition(currentPos))
    else
        print("Error: No character found!")
    end
end

-- Fungsi untuk copy posisi ke clipboard
local function copyPositionToClipboard()
    local currentPos = getCurrentPosition()
    
    if currentPos then
        local posString = getPositionString(currentPos)
        
        -- Untuk executor yang support setclipboard
        if setclipboard then
            setclipboard(posString)
            copyPosBtn.Text = "COPIED!"
            copyPosBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            task.wait(1)
            copyPosBtn.Text = "COPY"
            copyPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            print("Position copied to clipboard: " .. posString)
        else
            print("Clipboard not available. Position: " .. posString)
            copyPosBtn.Text = "NO CLIPBOARD"
            copyPosBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.wait(1)
            copyPosBtn.Text = "COPY"
            copyPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
    end
end

-- Fungsi untuk update list posisi tersimpan dengan SCROLLING
local function updatePositionsList()
    positionsList:ClearAllChildren()
    
    if #savedPositions == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "No positions saved"
        emptyLabel.Size = UDim2.new(1, -10, 0, 25)
        emptyLabel.Position = UDim2.new(0, 5, 0, 5)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.TextSize = 12
        emptyLabel.Font = Enum.Font.Code
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        emptyLabel.Parent = positionsList
        return
    end
    
    for i, posData in ipairs(savedPositions) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -10, 0, 25)
        itemFrame.Position = UDim2.new(0, 5, 0, (i-1)*28)
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        itemFrame.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 4)
        itemCorner.Parent = itemFrame
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = posData.name
        nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- Position label
        local posLabel = Instance.new("TextLabel")
        posLabel.Text = formatPosition(posData.position)
        posLabel.Size = UDim2.new(0.4, 0, 1, 0)
        posLabel.Position = UDim2.new(0.3, 0, 0, 0)
        posLabel.BackgroundTransparency = 1
        posLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        posLabel.TextSize = 10
        posLabel.Font = Enum.Font.Code
        posLabel.TextXAlignment = Enum.TextXAlignment.Left
        posLabel.Parent = itemFrame
        
        -- Teleport button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Text = "TP"
        tpBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        tpBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.TextSize = 10
        tpBtn.Font = Enum.Font.Code
        
        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 4)
        tpCorner.Parent = tpBtn
        
        tpBtn.MouseButton1Click:Connect(function()
            teleportToPosition(posData.position, posData.name)
        end)
        tpBtn.Parent = itemFrame
        
        -- Delete button
        local delBtn = Instance.new("TextButton")
        delBtn.Text = "X"
        delBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
        delBtn.Position = UDim2.new(0.85, 0, 0.15, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextSize = 10
        delBtn.Font = Enum.Font.Code
        
        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 4)
        delCorner.Parent = delBtn
        
        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedPositions, i)
            updatePositionsList()
            print("Position deleted: " .. posData.name)
        end)
        delBtn.Parent = itemFrame
        
        -- Hover effect
        itemFrame.MouseEnter:Connect(function()
            itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        end)
        
        itemFrame.MouseLeave:Connect(function()
            itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end)
        
        itemFrame.Parent = positionsList
    end
    
    -- Update canvas size untuk scrolling
    positionsList.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 28)
end

-- Fungsi untuk teleport ke posisi tertentu
local function teleportToPosition(position, positionName)
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
        
        -- Flash effect
        teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        task.wait(0.1)
        teleportBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        -- Status indicator effect
        statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(0.3)
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        if positionName then
            print("Teleported to: " .. positionName .. " " .. formatPosition(position))
        else
            print("Teleported to: " .. formatPosition(position))
        end
        return true
    end
    
    return false
end

-- Fungsi untuk teleport ke posisi terakhir yang disimpan
local function teleportToLastSaved()
    if #savedPositions == 0 then
        print("No positions saved!")
        return false
    end
    
    local lastPos = savedPositions[#savedPositions]
    return teleportToPosition(lastPos.position, lastPos.name)
end

-- Additional position utilities
local function getDistanceToPosition(targetPos)
    local currentPos = getCurrentPosition()
    if currentPos and targetPos then
        return (currentPos - targetPos).Magnitude
    end
    return nil
end

local function sortPositionsByDistance()
    local currentPos = getCurrentPosition()
    if not currentPos then return end
    
    table.sort(savedPositions, function(a, b)
        local distA = (currentPos - a.position).Magnitude
        local distB = (currentPos - b.position).Magnitude
        return distA < distB
    end)
    
    updatePositionsList()
    print("Positions sorted by distance")
end

local function clearAllPositions()
    savedPositions = {}
    updatePositionsList()
    print("All positions cleared")
end

-- Button click handlers
saveBtn.MouseButton1Click:Connect(savePosition)

copyPosBtn.MouseButton1Click:Connect(copyPositionToClipboard)

teleportBtn.MouseButton1Click:Connect(teleportToLastSaved)

-- Minimize functionality
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(mainContainer, tweenInfo, {Size = UDim2.new(0, 350, 0, 40)})
        tween:Play()
        
        tween.Completed:Connect(function()
            contentFrame.Visible = false
        end)
        
        minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(mainContainer, tweenInfo, {Size = originalSize})
        tween:Play()
        
        minimizeBtn.Text = "-"
    end
end)

-- Close button (hidden, activated with RightControl)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        screenGui:Destroy()
    end
end)

-- Keybinds untuk fungsi tambahan
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.P then -- Save position dengan P
            savePosition()
        elseif input.KeyCode == Enum.KeyCode.T then -- Teleport dengan T
            teleportToLastSaved()
        elseif input.KeyCode == Enum.KeyCode.C then -- Copy dengan C
            copyPositionToClipboard()
        end
    end
end)

-- Initialize
spawn(updateCurrentPosition) -- Start real-time position updates
updatePositionsList()

print("=== Position Manager Loaded ===")
print("Features:")
print("- Real-time position display")
print("- Save positions (Click or press P)")
print("- Copy position to clipboard (Click or press C)")
print("- Teleport to last saved (Click or press T)")
print("- Scrolling list of saved positions")
print("- Individual TP/Delete buttons for each position")
print("- Keybinds: P=Save, T=Teleport, C=Copy")
print("- Drag title bar to move UI")
print("- Press RightControl to close UI")