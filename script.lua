-- djpjblade_premium_hub_whitelist.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 📜 WHITELIST (BEYAZ LİSTE) AYARI - İSİMLERİ BURAYA YAZACAKSIN:
local whitelist = {
	"dogsnguns", -- Kendi kullanıcı adın
	"djpjbIade", -- İzin vermek istediğin 1. arkadaşın
	"Roblox"  -- İzin vermek istediğin 2. arkadaşın (istediğin kadar ekleyebilirsin)
}

-- Whitelist Kontrol Fonksiyonu
local hasAccess = false
for _, name in pairs(whitelist) do
	if player.Name == name then
		hasAccess = true
		break
	end
end

-- Eğer oyuncu listede yoksa çalışmayı durdurur ve paneli açmaz
if not hasAccess then
	player:Kick("ENTERANCE DENIED NO PREMISSION! (DJPJBLADE'S PREMIUM HUB)")
	return
end

----------------------------------------------------------------
-- BURADAN SONRASI PANELİN KENDİ KODLARIDIR (DOKUNMANA GEREK YOK)
----------------------------------------------------------------
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

local currentWormhole = nil
local wormholePosition = nil
local isMinimized = false
local isGodModeActive = false
local voidConnection = nil
local originalMaxHealth = 100
local isEspActive = false
local isNoclipActive = false
local espConnection = nil
local noclipConnection = nil
local espFolder = nil

local function getEspFolder()
	if not espFolder or not espFolder.Parent then
		espFolder = Instance.new("Folder")
		espFolder.Name = "DjpjbladeHub_ESP"
		espFolder.Parent = CoreGui
	end
	return espFolder
end

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("DjpjbladePremiumHubGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DjpjbladePremiumHubGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 340)
mainFrame.Position = UDim2.new(0.5, -170, 0.4, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✨ DJPJBLADE'S PREMIUM HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(0, 10, 0, 10)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 14
minimizeButton.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeButton

local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, 0, 0, 280)
buttonContainer.Position = UDim2.new(0, 0, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local function createPremiumButton(name, text, color, posX, posY)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 145, 0, 45)
	button.Position = UDim2.new(0, posX, 0, posY)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.AutoButtonColor = false
	button.Parent = buttonContainer
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color:Lerp(Color3.fromRGB(255,255,255), 0.1)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end)
	
	return button
end

local spawnButton = createPremiumButton("SpawnButton", "🌌 Spawn Wormhole", Color3.fromRGB(90, 40, 180), 15, 10)
local teleportButton = createPremiumButton("TeleportButton", "🌀 Teleport", Color3.fromRGB(20, 120, 180), 180, 10)
local speedUpButton = createPremiumButton("SpeedUpButton", "⚡ Speed +15", Color3.fromRGB(210, 140, 20), 15, 65)
local normalSpeedButton = createPremiumButton("NormalSpeedButton", "🚶 Normal Speed", Color3.fromRGB(90, 100, 110), 180, 65)
local godModeOnBtn = createPremiumButton("GodModeOnBtn", "🔱 God Mode ON", Color3.fromRGB(120, 30, 160), 15, 120)
local godModeOffBtn = createPremiumButton("GodModeOffBtn", "☠️ God Mode OFF", Color3.fromRGB(130, 40, 50), 180, 120)
local espOnBtn = createPremiumButton("EspOnBtn", "🚨 Player ESP ON", Color3.fromRGB(180, 40, 40), 15, 175)
local espOffBtn = createPremiumButton("EspOffBtn", "🚫 Player ESP OFF", Color3.fromRGB(100, 50, 50), 180, 175)
local whOnBtn = createPremiumButton("WhOnBtn", "🧱 Wallhack ON", Color3.fromRGB(40, 140, 80), 15, 230)
local whOffBtn = createPremiumButton("WhOffBtn", "🧱 Wallhack OFF", Color3.fromRGB(50, 80, 60), 180, 230)

minimizeButton.MouseButton1Click:Connect(function()
	if isMinimized then
		mainFrame:TweenSize(UDim2.new(0, 340, 0, 340), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		minimizeButton.Text = "-"
		buttonContainer.Visible = true
		isMinimized = false
	else
		mainFrame:TweenSize(UDim2.new(0, 340, 0, 45), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		minimizeButton.Text = "+"
		task.delay(0.2, function()
			if isMinimized then buttonContainer.Visible = false end
		end)
		isMinimized = true
	end
end)

spawnButton.MouseButton1Click:Connect(function()
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		if currentWormhole then currentWormhole:Destroy() end
		wormholePosition = rootPart.Position
		local wormhole = Instance.new("Part")
		wormhole.Name = "PlayerWormhole"
		wormhole.Shape = Enum.PartType.Ball
		wormhole.Size = Vector3.new(5, 5, 5)
		wormhole.Position = wormholePosition
		wormhole.Anchored = true
		wormhole.CanCollide = false
		wormhole.Material = Enum.Material.Neon
		wormhole.Color = Color3.fromRGB(140, 0, 255)
		wormhole.Transparency = 0.4
		
		local attachment = Instance.new("Attachment", wormhole)
		local sparks = Instance.new("ParticleEmitter")
		sparks.Texture = "rbxassetid://241517405"
		sparks.Color = ColorSequence.new(Color3.fromRGB(200, 100, 255))
		sparks.Size = NumberSequence.new(0.5, 0)
		sparks.Speed = NumberRange.new(2, 5)
		sparks.Rate = 50
		sparks.Parent = attachment
		
		wormhole.Parent = workspace
		currentWormhole = wormhole
		spawnButton.Text = "✅ Created!"
		task.wait(1)
		spawnButton.Text = "🌌 Spawn Wormhole"
	end
end)

teleportButton.MouseButton1Click:Connect(function()
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart and wormholePosition then
		rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		rootPart.CFrame = CFrame.new(wormholePosition + Vector3.new(0, 2, 0))
		teleportButton.Text = "🌀 Teleported!"
		task.wait(1)
		teleportButton.Text = "🌀 Teleport"
	else
		teleportButton.Text = "❌ No Wormhole!"
		task.wait(1)
		teleportButton.Text = "🌀 Teleport"
	end
end)

speedUpButton.MouseButton1Click:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 31
		speedUpButton.Text = "⚡ Fast!"
		task.wait(1)
		speedUpButton.Text = "⚡ Speed +15"
	end
end)

normalSpeedButton.MouseButton1Click:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
		normalSpeedButton.Text = "🚶 Reset!"
		task.wait(1)
		normalSpeedButton.Text = "🚶 Normal Speed"
	end
end)

godModeOnBtn.MouseButton1Click:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	
	if humanoid and rootPart and not isGodModeActive then
		isGodModeActive = true
		originalMaxHealth = humanoid.MaxHealth
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		
		voidConnection = RunService.Heartbeat:Connect(function()
			if character and rootPart and rootPart.Parent then
				if rootPart.Position.Y < -400 then
					rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					rootPart.CFrame = CFrame.new(0, 50, 0)
				end
				if humanoid.Health < math.huge then
					humanoid.Health = math.huge
				end
			end
		end)
		godModeOnBtn.Text = "🔱 God Active!"
		task.wait(1)
		godModeOnBtn.Text = "🔱 God Mode ON"
	end
end)

godModeOffBtn.MouseButton1Click:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if isGodModeActive then
		isGodModeActive = false
		if voidConnection then
			voidConnection:Disconnect()
			voidConnection = nil
		end
		if humanoid then
			humanoid.MaxHealth = originalMaxHealth
			humanoid.Health = originalMaxHealth
		end
		godModeOffBtn.Text = "🛑 God Disabled!"
		task.wait(1)
		godModeOffBtn.Text = "☠️ God Mode OFF"
	end
end)

espOnBtn.MouseButton1Click:Connect(function()
	if isEspActive then return end
	isEspActive = true
	local folder = getEspFolder()
	
	espConnection = RunService.RenderStepped:Connect(function()
		folder:ClearAllChildren()
		
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local char = p.Character
				local rpart = char.HumanoidRootPart
				local hum = char:FindFirstChildOfClass("Humanoid")
				
				if hum and hum.Health > 0 then
					local hl = char:FindFirstChild("DjpjbladeEspGlow")
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "DjpjbladeEspGlow"
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.FillTransparency = 0.6
						hl.OutlineColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineTransparency = 0
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = char
					end
					
					local pos, onScreen = camera:WorldToViewportPoint(rpart.Position)
					if onScreen then
						local billboard = Instance.new("BillboardGui")
						billboard.Size = UDim2.new(0, 200, 0, 50)
						billboard.AlwaysOnTop = true
						billboard.ExtentsOffset = Vector3.new(0, 3, 0)
						billboard.Adornee = rpart
						billboard.Parent = folder
						
						local label = Instance.new("TextLabel")
						label.Size = UDim2.new(1, 0, 1, 0)
						label.BackgroundTransparency = 1
						
						local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						local distance = myRoot and math.floor((myRoot.Position - rpart.Position).Magnitude) or 0
						
						label.Text = string.format("%s\n[%d Studs]", p.Name, distance)
						label.TextColor3 = Color3.fromRGB(255, 50, 50)
						label.Font = Enum.Font.GothamBold
						label.TextSize = 12
						label.TextStrokeTransparency = 0
						label.Parent = billboard
					end
				else
					if char:FindFirstChild("DjpjbladeEspGlow") then
						char.DjpjbladeEspGlow:Destroy()
					end
				end
			end
		end
	end)
	
	espOnBtn.Text = "🚨 ESP Active!"
	task.wait(1)
	espOnBtn.Text = "🚨 Player ESP ON"
end)

espOffBtn.MouseButton1Click:Connect(function()
	if isEspActive then
		isEspActive = false
		if espConnection then
			espConnection:Disconnect()
			espConnection = nil
		end
		if espFolder then
			espFolder:ClearAllChildren()
		end
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("DjpjbladeEspGlow") then
				p.Character.DjpjbladeEspGlow:Destroy()
			end
		end
		espOffBtn.Text = "🚫 ESP Disabled!"
		task.wait(1)
		espOffBtn.Text = "🚫 Player ESP OFF"
	end
end)

whOnBtn.MouseButton1Click:Connect(function()
	if isNoclipActive then return end
	isNoclipActive = true
	
	noclipConnection = RunService.Stepped:Connect(function()
		local character = player.Character
		if character and isNoclipActive then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					if part.Name ~= "HumanoidRootPart" and part.Name ~= "LowerTorso" then
						part.CanCollide = false
					end
				end
			end
		end
	end)
	
	whOnBtn.Text = "🧱 Noclip Active!"
	task.wait(1)
	whOnBtn.Text = "🧱 Wallhack ON"
end)

whOffBtn.MouseButton1Click:Connect(function()
	if isNoclipActive then
		isNoclipActive = false
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
		
		local character = player.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
		
		whOffBtn.Text = "🧱 Noclip Disabled!"
		task.wait(1)
		whOffBtn.Text = "🧱 Wallhack OFF"
	end
end)
