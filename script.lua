local ScreenGui = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

Button.Parent = ScreenGui
Button.Size = UDim2.new(0, 180, 0, 60)
Button.Position = UDim2.new(0.4, 0, 0.4, 0) 
Button.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
Button.Text = "EXECUTE"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20
Button.Draggable = true 

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Button

local targetedFruits = {
    "Kitsune Fruit", "Dragon Fruit", "Leopard Fruit", "Dough Fruit", 
    "T-Rex Fruit", "Mammoth Fruit", "Spirit Fruit", "Control Fruit", 
    "Venom Fruit", "Shadow Fruit", "Gravity Fruit", "Portal Fruit", "Buddha Fruit"
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Player = game.Players.LocalPlayer

local function getBestFilteredFruit()
    local inventoryData = CommF:InvokeServer("getInventory")
    local ownedFruits = {}
    
    if inventoryData then
        for _, item in pairs(inventoryData) do
            if item.Type == "Fruit" or (item.Name and string.find(item.Name, "Fruit")) then
                ownedFruits[item.Name] = true
            end
        end
    end
    
    for _, fruit in ipairs(targetedFruits) do
        if ownedFruits[fruit] then
            return fruit
        end
    end
    return nil
end

Button.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    local targetFruit = getBestFilteredFruit()
    
    if not targetFruit then
        Player:Kick("Filter Aborted: No matching Mythical, Portal, or Buddha fruits located in storage.")
        return
    end
    
    CommF:InvokeServer("LoadFruit", targetFruit)
    task.wait(1.2)
    
    local character = Player.Character
    local backpack = Player:WaitForChild("Backpack")
    local fruitTool = backpack:FindFirstChild(targetFruit) or character:FindFirstChild(targetFruit)
    
    if fruitTool and character and character:FindFirstChild("Humanoid") then
        character.Humanoid:EquipTool(fruitTool)
        task.wait(0.6)
        Player:Kick("Processed: " .. targetFruit)
    else
        Player:Kick("Replication Timeout: System could not verify tool equipping.")
    end
end)
