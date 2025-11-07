if getgenv().Thing then
    warn("ALREADY LOADED THE HUB")
    return
end

local RunService = game:GetService("RunService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()

local Ingame = workspace:WaitForChild("Map").Ingame
local Survivors = workspace.Players.Survivors
local Killers = workspace.Players.Killers

local Player = Players.LocalPlayer
local PlayerUI = Player.PlayerGui

local UI = {}
local Connections = {}
local Flags = {
    ["Player"] = {
        ["CFrame"] = nil,
        ["TPOnSlash"] = false,
        ["NoFootstep"] = false,
        ["SprintEnabled"] = false,
        ["SprintSpeed"] = 0,
        ["Data"] = {},
    },
    ["Generator"] = {
        ["Delay"] = 3,
        ["AutoSolve"] = false
    },
    ["Visuals"] = {
        ["ESP"] = {
            ["Item"] = false,
            ["Generator"] = false,
            ["Survivor"] = false,
            ["Killer"] = false,
            ["Colors"] = {
                ["Survivor"] = Color3.fromRGB(0, 255, 0),
                ["Killer"] = Color3.fromRGB(255, 0, 0),
                ["Generator"] = Color3.fromRGB(250, 169, 82),
                ["Item"] = {
                    ["BloxyCola"] = Color3.fromRGB(165, 164, 56),
                    ["Medkit"] = Color3.fromRGB(158, 11, 10),
                },
            }
        }
    }
}
--
local function inMap()
    local Map = Ingame:FindFirstChild("Map")
    return Map ~= nil
end
local function findNearestGenerator()
    local Data = Flags.Player.Data
    if Data and Data.Root then
        local pos = Data.Root.Position
        local nearest, maxDist = nil, 10
        for i, v in Ingame.Map:GetDescendants() do
            if v.Name == "Generator" then
                local main = v:FindFirstChild("Main")
                if main then
                    local dist = (main.Position - pos).Magnitude
                    if dist < maxDist then
                        nearest = v
                        maxDist = dist
                    end
                end
            end
        end
        return nearest
    end
    return nil
end
local function findPuzzleGenerator()
    local PuzzleUI = PlayerUI:FindFirstChild("PuzzleUI")
    return PuzzleUI ~= nil
end
--
function Respawn()
    local Data = {}
    --
    Data.Character = Player.Character
    Data.Humanoid = Data.Character:WaitForChild("Humanoid")
    Data.Root = Data.Character:WaitForChild("HumanoidRootPart")
    --
    local SpeedMultipliers = Data.Character:WaitForChild("SpeedMultipliers")
    --
    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.zero
    BodyGyro.Parent = Root
    --
    table.insert(Connections, Ingame.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            if child.Name == "BloxyCola" or child.Name == "Medkit" then
                if Flags.Visuals.ESP.Item then
                    ESP:AddESP({
                        Object = child,
                        Text = child.Name,
                        Color = Flags.Visuals.ESP.Colors.Item[child.Name]
                    })
                end
            end
        end
    end))
    table.insert(Connections, Ingame.DescendantAdded:Connect(function(child)
        if child:IsA("Model") then
            if child.Name == "Generator" then
                if Flags.Visuals.ESP.Generator then
                    ESPLibrary:AddESP({
                        Object = child,
                        Text = child.Name,
                        Color = Flags.Visuals.ESP.Colors.Generator
                    })
                end
            end
        end
    end))
    table.insert(Connections, Survivors.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            if Flags.Visuals.ESP.Survivor then
                ESPLibrary:AddESP({
                    Object = child,
                    Text = child.Name .. "\n" .. child:GetAttribute("Username"),
                    Color = Flags.Visuals.ESP.Colors.Survivor
                })
            end
        end
    end))
    table.insert(Connections, Killers.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            if Flags.Visuals.ESP.Killer then
                ESPLibrary:AddESP({
                    Object = child,
                    Text = child.Name .. "\n" .. child:GetAttribute("Username"),
                    Color = Flags.Visuals.ESP.Colors.Killer
                })
            end
        end
    end))
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if not Data.Character or not Data.Character.Parent or not SpeedMultipliers or not SpeedMultipliers.Parent then
            Destroy()
        end
        if Flags.Player.SprintEnabled then
            SpeedMultipliers.Sprinting.Value = Flags.Player.SprintSpeed
        end
        if Flags.Player.CFrame then
            BodyGyro.MaxTorque = Vector3.new(10000, 0, 10000)
            BodyGyro.CFrame = Flags.CFrame
        else
            BodyGyro.MaxTorque = Vector3.zero
        end
        Data.Character:SetAttribute("FootstepsMuted", Flags.Player.NoFootstep or false)
    end))
    --
    Flags.Player.Data = Data
end
function Destroy()
    for i, v in ESP.Objects do
        ESP:RemoveESP(v)
    end
    for i, v in Connections do
        v:Disconnect()
    end
    table.clear(Flags.Player.Data)
    table.clear(Connections)
end

do
    getgenv().Thing = true
    --
    UI.Window = Rayfield:CreateWindow({
        Name = "Forsaken Hub",
        Icon = 11289930484,
        LoadingTitle = "Loading..",
        LoadingSubtitle = "by Labbers em Kappers",
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        KeySystem = false,
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = false,
            FolderName = "",
            FileName = ""
        },
    })
    --tabs
    UI.MainTab = UI.Window:CreateTab("Main", 0)
    --SECTION ACT 1
    UI.MainSection = UI.MainTab:CreateSection("Player")
    UI.MainTab:CreateToggle({
        Name = "Enable Walk Speed Multiplier",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Player.SprintEnabled = Value
            if not Value then
                if Player.Character then
                    Player.Character.SpeedMultipliers.Sprinting.Value = 1
                end
            end
        end
    })
    UI.MainTab:CreateSlider({
        Name = "Walk Speed",
        Range = {0, 5},
        Increment = 1,
        CurrentValue = 1,
        Callback = function(Value)
            Flags.Player.SprintSpeed = Value
        end
    })
    UI.MainTab:CreateSlider({
        Name = "Jump Power",
        Range = {0, 200},
        Increment = 50,
        CurrentValue = 0,
        Callback = function(Value)
            if Player.Character then
                Player.Character.Humanoid.JumpPower = Value
            end
        end
    })
    UI.MainTab:CreateToggle({
        Name = "Disable Footsteps",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Player.NoFootstep = Value
        end
    })
    --SECTION ACT 2
    UI.MainSection = UI.MainTab:CreateSection("Set-up")
    UI.MainTab:CreateToggle({
        Name = "Enable Generator Auto-Solve",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Generator.Solve = Value
            while Flags.Generator.Solve do
                local inPuzzle = findPuzzleGenerator()
                if inPuzzle then
                    local generator = findNearestGenerator()
                    if generator then
                        task.wait(Flags.Generator.Delay)
                        if generator then --for sure
                            v.Remotes.RE:FireServer()
                        end
                    end
                end
                task.wait(0.1)
            end
        end
    })
    UI.MainTab:CreateSlider({
        Name = "Auto-Solve Delay",
        Range = {3, 5},
        Increment = 1,
        CurrentValue = 3,
        Callback = function(Value)
            Flags.Generator.Delay = Value
        end
    })
    --SECTION ACT 3
    UI.MainSection = UI.MainTab:CreateSection("niche stuff :3")
    UI.MainTab:CreateToggle({
        Name = "Enable TP on Slash (WIP, DOESNT WORK YET)",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Player.TPOnSlash = Value
        end
    })
    --TUSK ACT 4!
    UI.MainSection = UI.MainTab:CreateSection("ESP")
    UI.MainTab:CreateToggle({
        Name = "Enable Item ESP",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Visuals.ESP.Item = Value
            --
            local inMap = inMap()
            if inMap then
                for i, v in Ingame.Map:GetChildren() do
                    if v.Name == "BloxyCola" or v.Name == "Medkit" then
                        if Value then
                            ESP:AddESP({
                                Object = v,
                                Text = v.Name,
                                Color = Flags.Visuals.ESP.Colors.Item[v.Name]
                            })
                        else
                            ESP:RemoveESP(v)
                        end
                    end
                end
            end
        end
    })
    UI.MainTab:CreateToggle({
        Name = "Enable Generator ESP",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Visuals.ESP.Generator = Value
            --
            local inMap = inMap()
            if inMap then
                for i, v in Ingame.Map:GetChildren() do
                    if v.Name == "Generator" then
                        if Value then
                            ESP:AddESP({
                                Object = v,
                                Text = v.Name,
                                Color = Flags.Visuals.ESP.Colors.Generator
                            })
                        else
                            ESP:RemoveESP(v)
                        end
                    end
                end
            end
        end
    })
    UI.MainTab:CreateToggle({
        Name = "Enable Survivor ESP",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Visuals.ESP.Survivor = Value
            --
            local inMap = inMap()
            if inMap then
                for i, v in Survivors:GetChildren() do
                    if v:IsA("Model") then
                        if Value then
                            ESP:AddESP({
                                Object = v,
                                Text = v.Name .. "\n" .. v:GetAttribute("Username"),
                                Color = Flags.Visuals.ESP.Colors.Survivor
                            })
                        else
                            ESP:RemoveESP(v)
                        end
                    end
                end
            end
        end
    })
    UI.MainTab:CreateToggle({
        Name = "Enable Killer ESP",
        CurrentValue = false,
        Callback = function(Value)
            Flags.Visuals.ESP.Killer = Value
            --
            local inMap = inMap()
            if inMap then
                for i, v in Killers:GetChildren() do
                    if v:IsA("Model") then
                        if Value then
                            ESP:AddESP({
                                Object = v,
                                Text = v.Name .. "\n" .. v:GetAttribute("Username"),
                                Color = Flags.Visuals.ESP.Colors.Killer
                            })
                        else
                            ESP:RemoveESP(v)
                        end
                    end
                end
            end
        end
    })
    --
    UI.MiscTab = UI.Window:CreateTab("Misc", 0)
    UI.MiscTab:CreateButton({
        Name = "Unload Hub",
        Callback = function()
            getgenv().Thing = nil
            Destroy()
            Rayfield:Destroy()
        end
    })
    --
    UI.CreditTab = UI.Window:CreateTab("Credits", 0)
    UI.CreditTab:CreateLabel("Creator: Labber's Kapper")
    UI.CreditTab:CreateLabel("Assistant: Dall's Ass")
    UI.CreditTab:CreateLabel("Testers: You and many other people ;D")
    --
    if Player.Character then
        task.spawn(Respawn)
    end
end

Player.CharacterAdded:Connect(Respawn)
Player.CharacterRemoving:Connect(Destroy)