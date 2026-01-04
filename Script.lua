-- Blox Fruits Advanced Penetration Testing Suite v3.5
-- Optimized & Professional Edition
-- Password: LindonDross13!
local Services = {
Players = game:GetService("Players"),
RunService = game:GetService("RunService"),
UserInputService = game:GetService("UserInputService"),
TweenService = game:GetService("TweenService"),
VirtualInputManager = game:GetService("VirtualInputManager"),
ReplicatedStorage = game:GetService("ReplicatedStorage"),
Workspace = game:GetService("Workspace"),
Lighting = game:GetService("Lighting"),
VirtualUser = game:GetService("VirtualUser")
}
local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Config = {
Authenticated = false,
Password = "LindonDross13!",
AutoChest = false,
AutoFruit = false,
AutoBoss = false,
AutoQuest = false,
AutoMastery = false,
KillAura = false,
KillAuraRange = 50,
FastAttack = false,
AutoHaki = false,
AutoObservation = false,
NoStun = false,
InfiniteEnergy = false,
TeleportSpeed = 300,
SpeedRandomization = true,
WalkSpeed = false,
WalkSpeedValue = 16,
InfiniteJump = false,
Flight = false,
FlightSpeed = 100,
NoClip = false,
ESP = false,
ESPChests = true,
ESPFruits = true,
ESPPlayers = false,
ESPBosses = true,
ESPDistance = true,
FullBright = false,
RemoveFog = false,
SafeMode = true,
AntiAFK = true,
AntiKick = true,
AutoRejoin = true,
}
local State = {
Stats = {
SessionStart = tick(),
ChestsCollected = 0,
FruitsCollected = 0,
EnemiesKilled = 0,
BossesKilled = 0,
QuestsCompleted = 0,
MasteryGained = 0
},
Cache = {
Chests = {},
Fruits = {},
Bosses = {},
NPCs = {},
Quests = {}
},
Active = {
Teleporting = false,
Attacking = false,
InQuest = false,
Flying = false
},
Combat = {
LastHakiToggle = 0,
LastObsToggle = 0,
HakiEnabled = false,
ObsEnabled = false
},
ESP = {},
Connections = {},
UI = {}
}
local GameData = {
Workspace = workspace,
NPCs = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Enemies"),
Locations = workspace:FindFirstChild("_WorldOrigin") and workspace.WorldOrigin:FindFirstChild("Locations"),
CombatRemote = Services.ReplicatedStorage:FindFirstChild("Remotes") and Services.ReplicatedStorage.Remotes:FindFirstChild("CommF"),
BossNames = {
"Saber Expert", "The Gorilla King", "Bobby", "Yeti", "Mob Leader",
"Vice Admiral", "Warden", "Chief Warden", "Swan", "rip_indra",
"Awakened Ice Admiral", "Cursed Captain", "Darkbeard", "Order",
"Stone", "Island Empress", "Kilo Admiral", "Captain Elephant",
"Beautiful Pirate", "Cake Queen", "Longma", "Soul Reaper",
"Thunder God", "Cyborg", "Ice Admiral", "Greybeard", "Diamond",
"Jeremy", "Fajita", "Don Swan", "Smoke Admiral"
},
QuestGivers = {
"Bandit", "Jungle", "Desert", "Frozen Village", "Marine", "Skylands",
"Prison", "Colosseum", "Magma", "Underwater", "Fountain City",
"Zombie", "Swan", "Mansion", "Port Town", "Hydra", "Graveyard",
"Snow Mountain", "Hot and Cold", "Cursed Ship", "Ice Castle",
"Forgotten Island", "Dark Arena", "Pirate Raid", "Tiki Outpost",
"Haunted Castle", "Sea of Treats", "Cake Land", "Chocolate"
}
}
local function log(message, color)
print(string.format("[%s] %s", os.date("%H:%M:%S"), message))
end
local function getCharacter()
return LocalPlayer.Character
end
local function getHumanoid()
local char = getCharacter()
return char and char:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
local char = getCharacter()
return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end
local function isAlive()
local humanoid = getHumanoid()
return humanoid and humanoid.Health > 0
end
local function getMagnitude(pos1, pos2)
return (pos1 - pos2).Magnitude
end
local function enableHaki()
if not Config.AutoHaki then return end
if tick() - State.Combat.LastHakiToggle < 5 then return end
local char = getCharacter()
if char then
for _, part in pairs(char:GetDescendants()) do
if part:IsA("BasePart") and part.Color == Color3.fromRGB(0, 0, 0) then
State.Combat.HakiEnabled = true
return
end
end
end
State.Combat.LastHakiToggle = tick()
Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.J, false, game)
task.wait(0.05)
Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.J, false, game)
State.Combat.HakiEnabled = true
end
local function enableObservation()
if not Config.AutoObservation then return end
if tick() - State.Combat.LastObsToggle < 5 then return end
State.Combat.LastObsToggle = tick()
Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
task.wait(0.05)
Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
State.Combat.ObsEnabled = true
end
local lastTeleportTime = 0
local function smoothTeleport(targetCFrame, speed)
if State.Active.Teleporting then return false end
if tick() - lastTeleportTime < 0.2 then return false end
State.Active.Teleporting = true
local root = getRoot()
local humanoid = getHumanoid()
if not root or not isAlive() then
State.Active.Teleporting = false
return false
end
speed = speed or Config.TeleportSpeed
local distance = getMagnitude(root.Position, targetCFrame.Position)
if Config.SafeMode and distance > 15000 then
log("Teleport distance too large: " .. math.floor(distance))
State.Active.Teleporting = false
return false
end
if humanoid then
humanoid:ChangeState(Enum.HumanoidStateType.Flying)
humanoid.PlatformStand = false
end
local char = getCharacter()
for _, part in pairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
local startTime = tick()
local startHeight = root.Position.Y
local targetHeight = targetCFrame.Position.Y
local maintainHeight = math.max(startHeight, targetHeight) + 10
while getMagnitude(root.Position, targetCFrame.Position) > 3 do
if not isAlive() or tick() - startTime > 30 then break end
local remainingDistance = getMagnitude(root.Position, targetCFrame.Position)
local currentSpeed = speed
if remainingDistance < 10 then
currentSpeed = speed * 0.3
elseif remainingDistance < 30 then
currentSpeed = speed * 0.5
elseif remainingDistance < 100 then
currentSpeed = speed * 0.7
end
if Config.SpeedRandomization and math.random(1, 10) <= 3 then
currentSpeed = currentSpeed * (0.9 + math.random() * 0.2)
end
local direction = (targetCFrame.Position - root.Position).Unit
if remainingDistance > 50 then
local adjustedTarget = Vector3.new(
root.Position.X + direction.X * currentSpeed * 0.1,
maintainHeight,
root.Position.Z + direction.Z * currentSpeed * 0.1
)
root.CFrame = CFrame.new(adjustedTarget)
else
root.CFrame = root.CFrame + direction * (currentSpeed * 0.1)
end
root.Velocity = Vector3.new(0, 0, 0)
root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
task.wait()
end
root.CFrame = targetCFrame
root.Velocity = Vector3.new(0, 0, 0)
task.wait(0.15)
for _, part in pairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = true
end
end
if humanoid then
humanoid:ChangeState(Enum.HumanoidStateType.Landed)
end
lastTeleportTime = tick()
State.Active.Teleporting = false
return true
end
local function scanChests()
State.Cache.Chests = {}
for _, obj in pairs(workspace:GetDescendants()) do
if obj:IsA("Model") or obj:IsA("BasePart") then
local name = obj.Name:lower()
if name:find("chest") and not name:find("golden") then
local primaryPart = obj:IsA("Model") and obj.PrimaryPart or obj
if primaryPart and (primaryPart:FindFirstChild("TouchInterest") or obj:FindFirstChildOfClass("ProximityPrompt")) then
table.insert(State.Cache.Chests, {
Object = obj,
Part = primaryPart,
Position = primaryPart.Position
})
end
end
end
end
log("Found " .. #State.Cache.Chests .. " chests")
end
local function scanFruits()
State.Cache.Fruits = {}
local fruitNames = {
"Kitsune", "Leopard", "Dragon", "Spirit", "Dough", "Shadow", "Venom", "Control",
"Soul", "Blizzard", "Mammoth", "T-Rex", "Gravity", "Pain", "Rumble", "Buddha",
"Phoenix", "Love", "Quake", "Light", "Dark", "Spider", "Ice", "Flame", "Magma",
"Sand", "Smoke", "Barrier", "Rubber", "Spring", "Bomb", "Spike", "Chop", "Kilo",
"Spin", "Paw", "Gas", "Portal", "Door", "Sound"
}
for _, obj in pairs(workspace:GetDescendants()) do
local name = obj.Name
local isFruit = false
for _, fruitName in pairs(fruitNames) do
if name == fruitName or name:find(fruitName) then
if not name:lower():find("island") and
not name:lower():find("location") and
not name:lower():find("area") and
not name:lower():find("zone") then
isFruit = true
break
end
end
end
if isFruit then
local part = nil
if obj:IsA("Tool") and obj.Parent == workspace then
part = obj:FindFirstChild("Handle")
elseif obj:IsA("Model") and obj.Parent == workspace then
part = obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("MeshPart") or obj:FindFirstChildWhichIsA("Part")
elseif obj:IsA("BasePart") and obj.Parent and obj.Parent.Parent == workspace then
part = obj
end
if part then
local isValid = true
local checkParent = part.Parent
while checkParent do
if checkParent:IsA("Model") and checkParent:FindFirstChild("Humanoid") then
isValid = false
break
end
if checkParent == workspace then
break
end
checkParent = checkParent.Parent
end
if isValid and part.Parent then
table.insert(State.Cache.Fruits, {
Object = obj,
Part = part,
Position = part.Position,
Name = obj.Name
})
end
end
end
end
log("Found " .. #State.Cache.Fruits .. " fruits")
end
local function scanBosses()
State.Cache.Bosses = {}
local npcs = GameData.NPCs or workspace
for _, mob in pairs(npcs:GetDescendants()) do
if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
local humanoid = mob.Humanoid
local root = mob:FindFirstChild("HumanoidRootPart")
local isBoss = humanoid.MaxHealth >= 5000
for _, bossName in pairs(GameData.BossNames) do
if mob.Name:find(bossName) then
isBoss = true
break
end
end
if isBoss and root and humanoid.Health > 0 then
table.insert(State.Cache.Bosses, {
Model = mob,
Humanoid = humanoid,
Root = root,
Name = mob.Name,
Health = humanoid.Health,
MaxHealth = humanoid.MaxHealth
})
end
end
end
log("Found " .. #State.Cache.Bosses .. " bosses")
end
local function findNearestObject(objectList)
local root = getRoot()
if not root then return nil end
local nearest = nil
local nearestDist = math.huge
for i = #objectList, 1, -1 do
local obj = objectList[i]
local part = obj.Part or obj.Root
if not part or not part.Parent then
table.remove(objectList, i)
else
local dist = getMagnitude(root.Position, part.Position)
if dist < nearestDist then
nearestDist = dist
nearest = obj
end
end
end
return nearest, nearestDist
end
local lastAttackTime = 0
local attackCooldown = 0.1
local function performAttack()
if not isAlive() then return false end
local now = tick()
if now - lastAttackTime < (Config.FastAttack and 0.05 or attackCooldown) then return false end
local tool = getCharacter():FindFirstChildOfClass("Tool")
if tool then
tool:Activate()
lastAttackTime = now
if GameData.CombatRemote then
GameData.CombatRemote:InvokeServer("weaponHit", tool.Name)
end
return true
end
return false
end
local function bringMobs(targetEnemy, radius)
if not targetEnemy or not targetEnemy.Root then return end
local targetName = targetEnemy.Model.Name
local targetPos = targetEnemy.Root.Position
local npcs = GameData.NPCs or workspace
for _, mob in pairs(npcs:GetDescendants()) do
if mob:IsA("Model") and mob.Name == targetName and mob ~= targetEnemy.Model then
local humanoid = mob:FindFirstChild("Humanoid")
local mobRoot = mob:FindFirstChild("HumanoidRootPart")
if humanoid and humanoid.Health > 0 and mobRoot then
local dist = getMagnitude(targetPos, mobRoot.Position)
if dist <= radius then
mobRoot.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
mobRoot.CanCollide = false
humanoid.WalkSpeed = 0
humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end
end
end
end
end
local function attackEnemy(enemy)
if not enemy or not enemy.Humanoid or enemy.Humanoid.Health <= 0 then return false end
local root = getRoot()
local enemyRoot = enemy.Root
if not root or not enemyRoot then return false end
local behindPos = enemyRoot.CFrame * CFrame.new(0, 0, 7)
root.CFrame = behindPos
enableHaki()
enableObservation()
return performAttack()
end
local function chestFarmLoop()
while task.wait(0.5) do
if Config.AutoChest and isAlive() and not State.Active.Teleporting then
if #State.Cache.Chests == 0 then
scanChests()
task.wait(2)
end
local nearest = findNearestObject(State.Cache.Chests)
if nearest and nearest.Part and nearest.Part.Parent then
local success = smoothTeleport(nearest.Part.CFrame + Vector3.new(0, 5, 0))
if success then
task.wait(0.5)
local root = getRoot()
if root and nearest.Part.Parent then
if nearest.Part:FindFirstChild("TouchInterest") then
firetouchinterest(root, nearest.Part, 0)
task.wait(0.1)
firetouchinterest(root, nearest.Part, 1)
end
local prompt = nearest.Object:FindFirstChildOfClass("ProximityPrompt", true)
if prompt then
fireproximityprompt(prompt)
end
local click = nearest.Object:FindFirstChildOfClass("ClickDetector", true)
if click then
fireclickdetector(click)
end
State.Stats.ChestsCollected = State.Stats.ChestsCollected + 1
for i, chest in pairs(State.Cache.Chests) do
if chest == nearest then
table.remove(State.Cache.Chests, i)
break
end
end
end
end
else
task.wait(3)
end
end
end
end
local function fruitFarmLoop()
while task.wait(0.5) do
if Config.AutoFruit and isAlive() and not State.Active.Teleporting then
if #State.Cache.Fruits == 0 then
scanFruits()
task.wait(2)
end
local nearest = findNearestObject(State.Cache.Fruits)
if nearest and nearest.Part and nearest.Part.Parent then
local success = smoothTeleport(nearest.Part.CFrame + Vector3.new(0, 5, 0))
if success then
task.wait(0.5)
local root = getRoot()
if root then
for attempt = 1, 5 do
if not nearest.Part or not nearest.Part.Parent then
State.Stats.FruitsCollected = State.Stats.FruitsCollected + 1
break
end
root.CFrame = nearest.Part.CFrame
if nearest.Part:FindFirstChild("TouchInterest") then
firetouchinterest(root, nearest.Part, 0)
task.wait(0.05)
firetouchinterest(root, nearest.Part, 1)
end
local click = nearest.Object:FindFirstChildOfClass("ClickDetector", true)
if click then
fireclickdetector(click)
end
task.wait(0.2)
end
for i, fruit in pairs(State.Cache.Fruits) do
if fruit == nearest then
table.remove(State.Cache.Fruits, i)
break
end
end
end
end
else
task.wait(3)
end
end
end
end
local function bossFarmLoop()
while task.wait(0.3) do
if Config.AutoBoss and isAlive() then
if #State.Cache.Bosses == 0 then
scanBosses()
task.wait(3)
end
local nearest = findNearestObject(State.Cache.Bosses)
if nearest and nearest.Humanoid.Health > 0 then
smoothTeleport(nearest.Root.CFrame * CFrame.new(0, 0, 10))
task.wait(0.3)
bringMobs(nearest, 200)
while nearest.Humanoid.Health > 0 and Config.AutoBoss and isAlive() do
attackEnemy(nearest)
if math.random(1, 10) == 1 then
bringMobs(nearest, 200)
end
task.wait(0.05)
end
if nearest.Humanoid.Health <= 0 then
State.Stats.BossesKilled = State.Stats.BossesKilled + 1
for i, boss in pairs(State.Cache.Bosses) do
if boss == nearest then
table.remove(State.Cache.Bosses, i)
break
end
end
end
else
task.wait(3)
end
end
end
end
local function masteryFarmLoop()
while task.wait(0.2) do
if Config.AutoMastery and isAlive() then
local npcs = GameData.NPCs or workspace
local root = getRoot()
if not root then return end
local nearestEnemy = nil
local nearestDist = 50
for _, mob in pairs(npcs:GetDescendants()) do
if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
local humanoid = mob.Humanoid
local mobRoot = mob:FindFirstChild("HumanoidRootPart")
if humanoid.Health > 0 and mobRoot and humanoid.MaxHealth < 5000 then
local dist = getMagnitude(root.Position, mobRoot.Position)
if dist < nearestDist then
nearestDist = dist
nearestEnemy = { Model = mob, Humanoid = humanoid, Root = mobRoot }
end
end
end
end
if nearestEnemy then
bringMobs(nearestEnemy, 150)
attackEnemy(nearestEnemy)
if nearestEnemy.Humanoid.Health <= 0 then
State.Stats.EnemiesKilled = State.Stats.EnemiesKilled + 1
State.Stats.MasteryGained = State.Stats.MasteryGained + 1
end
end
end
end
end
local function questFarmLoop()
while task.wait(2) do
if Config.AutoQuest and isAlive() then
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
local hasActiveQuest = false
if playerGui then
local questUI = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Quest")
if questUI and questUI.Visible then
hasActiveQuest = true
end
end
if not hasActiveQuest then
for _, npc in pairs(workspace:GetDescendants()) do
if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
local name = npc.Name
local isQuestGiver = false
for _, giverName in pairs(GameData.QuestGivers) do
if name:find(giverName) or name:find("Quest") then
isQuestGiver = true
break
end
end
if isQuestGiver then
smoothTeleport(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
task.wait(0.5)
local click = npc:FindFirstChildOfClass("ClickDetector", true)
if click then
fireclickdetector(click)
end
local prompt = npc:FindFirstChildOfClass("ProximityPrompt", true)
if prompt then
fireproximityprompt(prompt)
end
break
end
end
end
else
if not Config.AutoMastery then
Config.AutoMastery = true
end
task.wait(5)
if not hasActiveQuest then
Config.AutoMastery = false
State.Stats.QuestsCompleted = State.Stats.QuestsCompleted + 1
end
end
end
end
end
local function killAuraLoop()
while task.wait(0.15) do
if Config.KillAura and isAlive() then
local root = getRoot()
if not root then return end
local npcs = GameData.NPCs or workspace
for _, mob in pairs(npcs:GetDescendants()) do
if mob:IsA("Model") and mob ~= getCharacter() and mob:FindFirstChild("Humanoid") then
local humanoid = mob.Humanoid
local mobRoot = mob:FindFirstChild("HumanoidRootPart")
if humanoid.Health > 0 and mobRoot then
local dist = getMagnitude(root.Position, mobRoot.Position)
if dist <= Config.KillAuraRange then
attackEnemy({ Model = mob, Humanoid = humanoid, Root = mobRoot })
if humanoid.Health <= 0 then
State.Stats.EnemiesKilled = State.Stats.EnemiesKilled + 1
end
end
end
end
end
end
end
end
local walkSpeedConnection
local function setupWalkSpeed()
if walkSpeedConnection then walkSpeedConnection:Disconnect() end
walkSpeedConnection = Services.RunService.Heartbeat:Connect(function()
if Config.WalkSpeed and isAlive() then
local humanoid = getHumanoid()
if humanoid then
humanoid.WalkSpeed = Config.WalkSpeedValue
end
end
end)
table.insert(State.Connections, walkSpeedConnection)
end
local energyConnection
local function setupInfiniteEnergy()
if energyConnection then energyConnection:Disconnect() end
energyConnection = Services.RunService.Heartbeat:Connect(function()
if Config.InfiniteEnergy and isAlive() then
local playerData = LocalPlayer:FindFirstChild("Data")
if playerData then
local energy = playerData:FindFirstChild("Energy")
if energy then
energy.Value = 10000
end
end
end
end)
table.insert(State.Connections, energyConnection)
end
local stunConnection
local function setupNoStun()
if stunConnection then stunConnection:Disconnect() end
stunConnection = Services.RunService.Heartbeat:Connect(function()
if Config.NoStun and isAlive() then
local humanoid = getHumanoid()
if humanoid then
if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
humanoid:ChangeState(Enum.HumanoidStateType.Running)
end
if humanoid.PlatformStand then
humanoid.PlatformStand = false
end
end
end
end)
table.insert(State.Connections, stunConnection)
end
local jumpConnection
local function setupInfiniteJump()
if jumpConnection then jumpConnection:Disconnect() end
jumpConnection = Services.UserInputService.JumpRequest:Connect(function()
if Config.InfiniteJump and isAlive() then
local humanoid = getHumanoid()
if humanoid then
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end
end)
table.insert(State.Connections, jumpConnection)
end
local flightConnection
local function setupFlight()
if flightConnection then flightConnection:Disconnect() end
local flying = false
Services.UserInputService.InputBegan:Connect(function(input, processed)
if processed or not Config.Flight then return end
if input.KeyCode == Enum.KeyCode.Space then
flying = true
end
end)
Services.UserInputService.InputEnded:Connect(function(input)
if input.KeyCode == Enum.KeyCode.Space then
flying = false
end
end)
flightConnection = Services.RunService.Heartbeat:Connect(function()
if Config.Flight and flying and isAlive() then
local root = getRoot()
local humanoid = getHumanoid()
if root and humanoid then
local velocity = Vector3.new(0, Config.FlightSpeed / 10, 0)
if humanoid.MoveDirection.Magnitude > 0 then
velocity = velocity + (humanoid.MoveDirection * Config.FlightSpeed / 10)
end
root.Velocity = velocity
end
end
end)
table.insert(State.Connections, flightConnection)
end
local noclipConnection
local function setupNoClip()
if noclipConnection then noclipConnection:Disconnect() end
noclipConnection = Services.RunService.Stepped:Connect(function()
if Config.NoClip and isAlive() then
local char = getCharacter()
if char then
for _, part in pairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
end
end
end)
table.insert(State.Connections, noclipConnection)
end
local lightingConnection
local function setupFullBright()
if lightingConnection then lightingConnection:Disconnect() end
lightingConnection = Services.RunService.Heartbeat:Connect(function()
if Config.FullBright then
Services.Lighting.Brightness = 2
Services.Lighting.ClockTime = 14
Services.Lighting.GlobalShadows = false
Services.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end
if Config.RemoveFog then
Services.Lighting.FogEnd = 100000
end
end)
table.insert(State.Connections, lightingConnection)
end
local function clearESP()
for _, esp in pairs(State.ESP) do
esp:Destroy()
end
State.ESP = {}
end
local function createESP(part, text, color)
if not part or not part.Parent then return end
local billboard = Instance.new("BillboardGui")
billboard.Adornee = part
billboard.Size = UDim2.new(0, 100, 0, 50)
billboard.StudsOffset = Vector3.new(0, 3, 0)
billboard.AlwaysOnTop = true
billboard.Parent = LocalPlayer.PlayerGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = color
label.TextStrokeTransparency = 0
label.TextStrokeColor3 = Color3.new(0, 0, 0)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 14
label.Parent = billboard
table.insert(State.ESP, billboard)
return billboard
end
local function updateESP()
clearESP()
if not Config.ESP or not isAlive() then return end
local root = getRoot()
if not root then return end
if Config.ESPChests then
for _, chest in pairs(State.Cache.Chests) do
if chest.Part and chest.Part.Parent then
local dist = math.floor(getMagnitude(root.Position, chest.Part.Position))
local text = "Chest"
if Config.ESPDistance then text = text .. "\n[" .. dist .. "m]" end
createESP(chest.Part, text, Color3.fromRGB(255, 255, 0))
end
end
end
if Config.ESPFruits then
for _, fruit in pairs(State.Cache.Fruits) do
if fruit.Part and fruit.Part.Parent then
local dist = math.floor(getMagnitude(root.Position, fruit.Part.Position))
local text = fruit.Name or "Fruit"
if Config.ESPDistance then text = text .. "\n[" .. dist .. "m]" end
createESP(fruit.Part, text, Color3.fromRGB(255, 0, 255))
end
end
end
if Config.ESPBosses then
for _, boss in pairs(State.Cache.Bosses) do
if boss.Root and boss.Root.Parent and boss.Humanoid.Health > 0 then
local dist = math.floor(getMagnitude(root.Position, boss.Root.Position))
local text = boss.Name .. " [BOSS]"
if Config.ESPDistance then text = text .. "\n[" .. dist .. "m] HP:" .. math.floor(boss.Humanoid.Health) end
createESP(boss.Root, text, Color3.fromRGB(255, 0, 0))
end
end
end
if Config.ESPPlayers then
for _, player in pairs(Services.Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
if playerRoot then
local dist = math.floor(getMagnitude(root.Position, playerRoot.Position))
local text = player.Name
if Config.ESPDistance then text = text .. "\n[" .. dist .. "m]" end
createESP(playerRoot, text, Color3.fromRGB(255, 100, 100))
end
end
end
end
end
local function espUpdateLoop()
while task.wait(2) do
if Config.ESP then
updateESP()
end
end
end
local function setupAntiAFK()
LocalPlayer.Idled:Connect(function()
if Config.AntiAFK then
Services.VirtualUser:CaptureController()
Services.VirtualUser:ClickButton2(Vector2.new())
end
end)
end
local function setupAntiKick()
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
local method = getnamecallmethod()
if Config.AntiKick and method == "Kick" then
log("Blocked kick attempt")
return
end
return oldNamecall(self, ...)
end)
setreadonly(mt, true)
end
local function setupAutoRejoin()
game:GetService("CoreGui").DescendantAdded:Connect(function(descendant)
if Config.AutoRejoin and (descendant.Name == "ErrorPrompt" or descendant.Name == "ErrorMessage") then
task.wait(2)
game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end
end)
end
local notifications = {}
local function createNotification(title, message, duration)
duration = duration or 3
local gui = State.UI.ScreenGui
if not gui then return end
local notif = Instance.new("Frame")
notif.Size = UDim2.new(0, 320, 0, 90)
notif.Position = UDim2.new(1, -330, 1, 10)
notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
notif.BorderSizePixel = 0
notif.ZIndex = 1000
notif.Parent = gui
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)) }
gradient.Rotation = 90
gradient.Parent = notif
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Thickness = 1
stroke.Transparency = 0.5
stroke.Parent = notif
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 28)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = title
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 17
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = notif
local msgLabel = Instance.new("TextLabel")
msgLabel.Size = UDim2.new(1, -20, 1, -36)
msgLabel.Position = UDim2.new(0, 10, 0, 32)
msgLabel.BackgroundTransparency = 1
msgLabel.Text = message
msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
msgLabel.Font = Enum.Font.SourceSans
msgLabel.TextSize = 14
msgLabel.TextXAlignment = Enum.TextXAlignment.Left
msgLabel.TextYAlignment = Enum.TextYAlignment.Top
msgLabel.TextWrapped = true
msgLabel.Parent = notif
table.insert(notifications, notif)
Services.TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -330, 1, -100 - (#notifications * 100)) }):Play()
task.delay(duration, function()
Services.TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 10, notif.Position.Y.Scale, notif.Position.Y.Offset) }):Play()
task.wait(0.3)
notif:Destroy()
for i, v in pairs(notifications) do
if v == notif then
table.remove(notifications, i)
break
end
end
end)
end
local function createPasswordScreen()
local gui = Instance.new("ScreenGui")
gui.Name = "PasswordScreen"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer.PlayerGui
local blur = Instance.new("Frame")
blur.Size = UDim2.new(1, 0, 1, 0)
blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blur.BackgroundTransparency = 0.4
blur.BorderSizePixel = 0
blur.Parent = gui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 480, 0, 300)
frame.Position = UDim2.new(0.5, -240, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Thickness = 2
stroke.Parent = frame
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 55)
title.Position = UDim2.new(0, 20, 0, 20)
title.BackgroundTransparency = 1
title.Text = "🔐 Secure Access Required"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.Parent = frame
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 50)
subtitle.Position = UDim2.new(0, 20, 0, 75)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Blox Fruits Penetration Testing Suite v3.5\nEnter password to access premium features"
subtitle.TextColor3 = Color3.fromRGB(160, 160, 160)
subtitle.Font = Enum.Font.SourceSans
subtitle.TextSize = 15
subtitle.TextWrapped = true
subtitle.Parent = frame
local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(1, -40, 0, 55)
textbox.Position = UDim2.new(0, 20, 0, 135)
textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textbox.BorderSizePixel = 0
textbox.Text = ""
textbox.PlaceholderText = "Enter password..."
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
textbox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 17
textbox.ClearTextOnFocus = false
textbox.TextXAlignment = Enum.TextXAlignment.Left
textbox.Parent = frame
Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 10)
Instance.new("UIPadding", textbox).PaddingLeft = UDim.new(0, 15)
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -40, 0, 55)
button.Position = UDim2.new(0, 20, 0, 205)
button.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
button.BorderSizePixel = 0
button.Text = "Submit"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 19
button.Parent = frame
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
local error = Instance.new("TextLabel")
error.Size = UDim2.new(1, -40, 0, 25)
error.Position = UDim2.new(0, 20, 1, -35)
error.BackgroundTransparency = 1
error.Text = ""
error.TextColor3 = Color3.fromRGB(255, 100, 100)
error.Font = Enum.Font.SourceSans
error.TextSize = 14
error.Parent = frame
local function checkPassword()
if textbox.Text == Config.Password then
Config.Authenticated = true
Services.TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundColor3 = Color3.fromRGB(40, 150, 80) }):Play()
error.TextColor3 = Color3.fromRGB(100, 255, 100)
error.Text = "✓ Access Granted - Loading..."
task.wait(0.7)
gui:Destroy()
initializeUI()
else
error.Text = "✗ Incorrect Password"
local originalPos = frame.Position
for i = 1, 4 do
Services.TweenService:Create(frame, TweenInfo.new(0.08), { Position = originalPos + UDim2.new(0, 12 * (i % 2 == 0 and -1 or 1), 0, 0) }):Play()
task.wait(0.08)
end
frame.Position = originalPos
textbox.Text = ""
end
end
button.MouseButton1Click:Connect(checkPassword)
textbox.FocusLost:Connect(function(enterPressed)
if enterPressed then
checkPassword()
end
end)
textbox:CaptureFocus()
end
local function initializeUI()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PenTestUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui
State.UI.ScreenGui = ScreenGui
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 580)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
State.UI.MainFrame = MainFrame
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 200, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.7
mainStroke.Parent = MainFrame
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 55)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = MainFrame
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)), ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18)) }
titleGradient.Rotation = 90
titleGradient.Parent = titleBar
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar
local titleCover = Instance.new("Frame")
titleCover.Size = UDim2.new(1, 0, 0, 28)
titleCover.Position = UDim2.new(0, 0, 1, -28)
titleCover.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
titleCover.BorderSizePixel = 0
titleCover.Parent = titleBar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -130, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Blox Fruits Pen Test Suite v3.5"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 45, 0, 45)
minBtn.Position = UDim2.new(1, -100, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 26
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 10)
minBtn.MouseButton1Click:Connect(function()
MainFrame.Visible = false
end)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 45, 0, 45)
closeBtn.Position = UDim2.new(1, -50, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 30
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)
closeBtn.MouseButton1Click:Connect(function()
ScreenGui:Destroy()
clearESP()
for _, conn in pairs(State.Connections) do
conn:Disconnect()
end
end)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 170, 1, -55)
sidebar.Position = UDim2.new(0, 0, 0, 55)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
sidebar.BorderSizePixel = 0
sidebar.Parent = MainFrame
State.UI.Sidebar = sidebar
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -170, 1, -55)
content.Position = UDim2.new(0, 170, 0, 55)
content.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
content.BorderSizePixel = 0
content.Parent = MainFrame
State.UI.Content = content
local tabs = {}
local function createTab(name, icon, order)
local tabFrame = Instance.new("ScrollingFrame")
tabFrame.Name = name
tabFrame.Size = UDim2.new(1, -25, 1, -25)
tabFrame.Position = UDim2.new(0, 12, 0, 12)
tabFrame.BackgroundTransparency = 1
tabFrame.BorderSizePixel = 0
tabFrame.ScrollBarThickness = 5
tabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tabFrame.Visible = false
tabFrame.Parent = content
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.Parent = tabFrame
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 25)
end)
tabs[name] = tabFrame
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -12, 0, 50)
btn.Position = UDim2.new(0, 6, 0, 6 + (order * 56))
btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
btn.Text = icon .. " " .. name
btn.TextColor3 = Color3.fromRGB(180, 180, 180)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 16
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.Parent = sidebar
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 16)
btn.MouseButton1Click:Connect(function()
for tabName, tabContent in pairs(tabs) do
tabContent.Visible = (tabName == name)
end
for _, child in pairs(sidebar:GetChildren()) do
if child:IsA("TextButton") then
child.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
child.TextColor3 = Color3.fromRGB(180, 180, 180)
end
end
btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)
return tabFrame
end
local function createSection(parent, title)
local section = Instance.new("Frame")
section.Size = UDim2.new(1, 0, 0, 45)
section.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
section.BorderSizePixel = 0
section.Parent = parent
Instance.new("UICorner", section).CornerRadius = UDim.new(0, 10)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, 0)
label.Position = UDim2.new(0, 16, 0, 0)
label.BackgroundTransparency = 1
label.Text = title
label.TextColor3 = Color3.fromRGB(100, 200, 255)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = section
return section
end
local function createToggle(parent, name, configKey, callback)
local toggle = Instance.new("Frame")
toggle.Size = UDim2.new(1, 0, 0, 50)
toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toggle.BorderSizePixel = 0
toggle.Parent = parent
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -85, 1, 0)
label.Position = UDim2.new(0, 16, 0, 0)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Color3.fromRGB(230, 230, 230)
label.Font = Enum.Font.SourceSans
label.TextSize = 16
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = toggle
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 60, 0, 34)
btn.Position = UDim2.new(1, -70, 0.5, -17)
btn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(180, 50, 50)
btn.Text = Config[configKey] and "ON" or "OFF"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 14
btn.Parent = toggle
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
btn.MouseButton1Click:Connect(function()
Config[configKey] = not Config[configKey]
Services.TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(180, 50, 50) }):Play()
btn.Text = Config[configKey] and "ON" or "OFF"
if callback then
callback(Config[configKey])
end
end)
return toggle
end
local function createSlider(parent, name, min, max, configKey, callback)
local slider = Instance.new("Frame")
slider.Size = UDim2.new(1, 0, 0, 75)
slider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
slider.BorderSizePixel = 0
slider.Parent = parent
Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -32, 0, 28)
label.Position = UDim2.new(0, 16, 0, 10)
label.BackgroundTransparency = 1
label.Text = name .. ": " .. Config[configKey]
label.TextColor3 = Color3.fromRGB(230, 230, 230)
label.Font = Enum.Font.SourceSans
label.TextSize = 16
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = slider
local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, -32, 0, 28)
bar.Position = UDim2.new(0, 16, 0, 42)
bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bar.BorderSizePixel = 0
bar.Parent = slider
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)
local fill = Instance.new("Frame")
fill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
fill.BorderSizePixel = 0
fill.Parent = bar
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
local dragging = false
bar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
end
end)
Services.UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
Services.UserInputService.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
fill.Size = UDim2.new(pos, 0, 1, 0)
local value = math.floor(min + (max - min) * pos)
Config[configKey] = value
label.Text = name .. ": " .. value
if callback then
callback(value)
end
end
end)
return slider
end
local function createButton(parent, name, callback)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0, 50)
btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
btn.Text = name
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 16
btn.Parent = parent
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
btn.MouseButton1Click:Connect(callback)
return btn
end
local homeTab = createTab("Home", "🏠", 0)
local farmTab = createTab("Farming", "🌾", 1)
local combatTab = createTab("Combat", "⚔️", 2)
local moveTab = createTab("Movement", "🏃", 3)
local visualTab = createTab("Visual", "👁️", 4)
local miscTab = createTab("Misc", "⚙️", 5)
homeTab.Visible = true
createSection(homeTab, "📊 Session Statistics")
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, 0, 0, 200)
statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = homeTab
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 10)
local statsLayout = Instance.new("UIListLayout")
statsLayout.Padding = UDim.new(0, 6)
statsLayout.Parent = statsFrame
local statLabels = {}
local function createStat(text)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -24, 0, 30)
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = Color3.fromRGB(230, 230, 230)
label.Font = Enum.Font.SourceSans
label.TextSize = 15
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = statsFrame
Instance.new("UIPadding", label).PaddingLeft = UDim.new(0, 16)
return label
end
statLabels.uptime = createStat("⏱️ Uptime: 0s")
statLabels.chests = createStat("📦 Chests: 0")
statLabels.fruits = createStat("🍎 Fruits: 0")
statLabels.kills = createStat("💀 Kills: 0")
statLabels.bosses = createStat("👹 Bosses: 0")
statLabels.quests = createStat("📜 Quests: 0")
createSection(homeTab, "ℹ️ Information")
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 90)
info.BackgroundTransparency = 1
info.Text = "Welcome to the Advanced Penetration Testing Suite v3.5\n\nOptimized teleportation, fixed Haki system, enhanced UI.\nPress Right Ctrl to toggle GUI visibility."
info.TextColor3 = Color3.fromRGB(190, 190, 190)
info.Font = Enum.Font.SourceSans
info.TextSize = 14
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = homeTab
Instance.new("UIPadding", info).PaddingLeft = UDim.new(0, 8)
createSection(farmTab, "🎯 Auto Farming")
createToggle(farmTab, "Auto Chest Farm", "AutoChest", function(enabled)
if enabled then
scanChests()
createNotification("Chest Farm", "Enabled - Hunting for chests!", 2)
end
end)
createToggle(farmTab, "Auto Fruit Finder", "AutoFruit", function(enabled)
if enabled then
scanFruits()
createNotification("Fruit Finder", "Enabled - Searching for fruits!", 2)
end
end)
createToggle(farmTab, "Auto Boss Farm", "AutoBoss", function(enabled)
if enabled then
scanBosses()
createNotification("Boss Farm", "Enabled - Targeting bosses!", 2)
end
end)
createToggle(farmTab, "Auto Quest Farm", "AutoQuest", function(enabled)
if enabled then
createNotification("Quest Farm", "Enabled - Accepting quests!", 2)
end
end)
createToggle(farmTab, "Auto Mastery Farm", "AutoMastery", function(enabled)
if enabled then
createNotification("Mastery Farm", "Enabled - Grinding mastery!", 2)
end
end)
createSection(farmTab, "⚙️ Settings")
createSlider(farmTab, "Teleport Speed", 100, 500, "TeleportSpeed")
createToggle(farmTab, "Speed Randomization", "SpeedRandomization")
createToggle(farmTab, "Safe Mode", "SafeMode")
createSection(farmTab, "🔄 Actions")
createButton(farmTab, "🔄 Refresh All", function()
scanChests()
scanFruits()
scanBosses()
createNotification("Refresh", "All caches refreshed!", 2)
end)
createButton(farmTab, "⏹️ Stop All", function()
Config.AutoChest = false
Config.AutoFruit = false
Config.AutoBoss = false
Config.AutoQuest = false
Config.AutoMastery = false
createNotification("Stop", "All farming stopped!", 2)
end)
createSection(combatTab, "⚔️ Combat Features")
createToggle(combatTab, "Kill Aura", "KillAura")
createSlider(combatTab, "Kill Aura Range", 10, 150, "KillAuraRange")
createToggle(combatTab, "Fast Attack", "FastAttack")
createToggle(combatTab, "Auto Haki (J Key)", "AutoHaki")
createToggle(combatTab, "Auto Observation (E Key)", "AutoObservation")
createToggle(combatTab, "No Stun", "NoStun")
createToggle(combatTab, "Infinite Energy", "InfiniteEnergy")
createSection(moveTab, "🏃 Movement")
createToggle(moveTab, "Custom Walk Speed", "WalkSpeed")
createSlider(moveTab, "Walk Speed", 16, 250, "WalkSpeedValue")
createToggle(moveTab, "Infinite Jump", "InfiniteJump")
createToggle(moveTab, "Flight Mode", "Flight")
createSlider(moveTab, "Flight Speed", 50, 300, "FlightSpeed")
createToggle(moveTab, "No Clip", "NoClip")
createSection(visualTab, "👁️ ESP")
createToggle(visualTab, "Enable ESP", "ESP", function(enabled)
if enabled then
updateESP()
else
clearESP()
end
end)
createToggle(visualTab, "ESP Chests", "ESPChests", updateESP)
createToggle(visualTab, "ESP Fruits", "ESPFruits", updateESP)
createToggle(visualTab, "ESP Players", "ESPPlayers", updateESP)
createToggle(visualTab, "ESP Bosses", "ESPBosses", updateESP)
createToggle(visualTab, "Show Distance", "ESPDistance", updateESP)
createSection(visualTab, "🌟 Effects")
createToggle(visualTab, "Full Bright", "FullBright")
createToggle(visualTab, "Remove Fog", "RemoveFog")
createSection(miscTab, "🛡️ Protection")
createToggle(miscTab, "Anti AFK", "AntiAFK")
createToggle(miscTab, "Anti Kick", "AntiKick")
createToggle(miscTab, "Auto Rejoin", "AutoRejoin")
createSection(miscTab, "🎮 Keybinds")
local keybinds = Instance.new("TextLabel")
keybinds.Size = UDim2.new(1, 0, 0, 110)
keybinds.BackgroundTransparency = 1
keybinds.Text = "⌨️ Keyboard Shortcuts:\n\n• Right Ctrl - Toggle GUI\n• Left Ctrl - Quick NoClip\n• F - Quick Flight"
keybinds.TextColor3 = Color3.fromRGB(190, 190, 190)
keybinds.Font = Enum.Font.SourceSans
keybinds.TextSize = 14
keybinds.TextWrapped = true
keybinds.TextXAlignment = Enum.TextXAlignment.Left
keybinds.TextYAlignment = Enum.TextYAlignment.Top
keybinds.Parent = miscTab
Instance.new("UIPadding", keybinds).PaddingLeft = UDim.new(0, 8)
createSection(miscTab, "⚠️ Danger Zone")
createButton(miscTab, "🔄 Reset Settings", function()
for key, value in pairs(Config) do
if typeof(value) == "boolean" and key ~= "Authenticated" then
Config[key] = false
end
end
createNotification("Reset", "Settings reset!", 2)
end)
createButton(miscTab, "❌ Destroy GUI", function()
ScreenGui:Destroy()
clearESP()
for _, conn in pairs(State.Connections) do
conn:Disconnect()
end
end)
local dragging = false
local dragInput, mousePos, framePos
titleBar.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
mousePos = input.Position
framePos = MainFrame.Position
end
end)
Services.UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
dragInput = input
end
if input == dragInput and dragging then
local delta = input.Position - mousePos
MainFrame.Position = UDim2.new(
framePos.X.Scale,
framePos.X.Offset + delta.X,
framePos.Y.Scale,
framePos.Y.Offset + delta.Y
)
end
end)
Services.UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
end
end)
task.spawn(function()
while ScreenGui and ScreenGui.Parent do
local uptime = math.floor(tick() - State.Stats.SessionStart)
local hours = math.floor(uptime / 3600)
local minutes = math.floor((uptime % 3600) / 60)
local seconds = uptime % 60
statLabels.uptime.Text = string.format("⏱️ Uptime: %02d:%02d:%02d", hours, minutes, seconds)
statLabels.chests.Text = "📦 Chests: " .. State.Stats.ChestsCollected
statLabels.fruits.Text = "🍎 Fruits: " .. State.Stats.FruitsCollected
statLabels.kills.Text = "💀 Kills: " .. State.Stats.EnemiesKilled
statLabels.bosses.Text = "👹 Bosses: " .. State.Stats.BossesKilled
statLabels.quests.Text = "📜 Quests: " .. State.Stats.QuestsCompleted
task.wait(1)
end
end)
setupWalkSpeed()
setupInfiniteEnergy()
setupNoStun()
setupInfiniteJump()
setupFlight()
setupNoClip()
setupFullBright()
setupAntiAFK()
setupAntiKick()
setupAutoRejoin()
createNotification("Welcome", "Suite v3.5 loaded successfully!", 3)
log("UI initialized")
end
Services.UserInputService.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == Enum.KeyCode.RightControl then
if State.UI.MainFrame then
State.UI.MainFrame.Visible = not State.UI.MainFrame.Visible
end
end
if input.KeyCode == Enum.KeyCode.LeftControl then
Config.NoClip = not Config.NoClip
createNotification("NoClip", Config.NoClip and "Enabled" or "Disabled", 2)
end
if input.KeyCode == Enum.KeyCode.F then
Config.Flight = not Config.Flight
createNotification("Flight", Config.Flight and "Enabled" or "Disabled", 2)
end
end)
LocalPlayer.CharacterAdded:Connect(function(character)
character:WaitForChild("Humanoid").Died:Connect(function()
State.Active.Teleporting = false
State.Active.Attacking = false
State.Combat.HakiEnabled = false
State.Combat.ObsEnabled = false
end)
end)
local function startMainLoops()
task.spawn(chestFarmLoop)
task.spawn(fruitFarmLoop)
task.spawn(bossFarmLoop)
task.spawn(questFarmLoop)
task.spawn(masteryFarmLoop)
task.spawn(killAuraLoop)
task.spawn(espUpdateLoop)
log("All systems operational")
end
task.spawn(function()
log("╔════════════════════════════════════════╗")
log("║ Blox Fruits Pen Test Suite v3.5        ║")
log("║ Enhanced & Optimized Edition           ║")
log("╚════════════════════════════════════════╝")
createPasswordScreen()
while not Config.Authenticated do
task.wait(0.5)
end
startMainLoops()
end)
