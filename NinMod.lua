--[[
    NINMOD V8 — 100% LOCALSCRIPT, SEM USER ID
    LocalScript para uso dentro da sua própria experiência no Roblox Studio.

    Instalação:
    StarterPlayer > StarterPlayerScripts > LocalScript

    Esta versão não exige Script em ServerScriptService, RemoteEvents nem lista de UserIds.
    Fly, ESP, mira, velocidade, noclip, imortalidade local, teleporte do próprio
    personagem e câmera de espectador são executados apenas no cliente.

    Ações que alteravam outros jogadores (trazer, fling e dano/aura) foram
    removidas porque não são confiáveis nem seguras sem autoridade do servidor.

    Para ativar ou desativar todo o painel, altere somente o retorno da função
    painelEstaAtivado() no início do arquivo. Quando desativado, o jogador verá
    uma mensagem informando que o painel está em atualização.
]]

--============================================================--
-- CONFIGURAÇÃO
--============================================================--

-- Altere somente o retorno desta função:
-- true  = painel liberado
-- false = painel desativado e mensagem de atualização exibida
local function painelEstaAtivado()
    return true
end

local BRAND_NAME = "NinMod"
local BRAND_CREATOR = "Nindo"
local OPEN_KEY = Enum.KeyCode.RightShift

local RENDER_BINDING = "NinModV8_Render"

--============================================================--
-- SERVIÇOS
--============================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

RunService:UnbindFromRenderStep(RENDER_BINDING)
ContextActionService:UnbindAction("NinModFlyUp")
ContextActionService:UnbindAction("NinModFlyDown")
ContextActionService:UnbindAction("NinModFlyTurbo")

local function mostrarMensagemDeAtualizacao()
    local previousPanel = PlayerGui:FindFirstChild("NinMod")
    if previousPanel then
        previousPanel:Destroy()
    end

    local previousUpdate = PlayerGui:FindFirstChild("NinModUpdateMessage")
    if previousUpdate then
        previousUpdate:Destroy()
    end

    local updateGui = Instance.new("ScreenGui")
    updateGui.Name = "NinModUpdateMessage"
    updateGui.ResetOnSpawn = false
    updateGui.IgnoreGuiInset = true
    updateGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    updateGui.DisplayOrder = 1000
    updateGui.Parent = PlayerGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(7, 8, 12)
    overlay.BackgroundTransparency = 0.28
    overlay.BorderSizePixel = 0
    overlay.Parent = updateGui

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(430, 190)
    card.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    card.BorderSizePixel = 0
    card.Parent = overlay

    local cardScale = Instance.new("UIScale")
    local currentCamera = Workspace.CurrentCamera
    local viewportWidth = currentCamera and currentCamera.ViewportSize.X or 900
    cardScale.Scale = math.clamp(viewportWidth / 900, 0.72, 1)
    cardScale.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(72, 61, 124)
    stroke.Transparency = 0.2
    stroke.Thickness = 1
    stroke.Parent = card

    local accent = Instance.new("Frame")
    accent.Position = UDim2.fromOffset(18, 18)
    accent.Size = UDim2.fromOffset(6, 154)
    accent.BackgroundColor3 = Color3.fromRGB(123, 92, 255)
    accent.BorderSizePixel = 0
    accent.Parent = card

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent

    local statusDot = Instance.new("Frame")
    statusDot.Position = UDim2.fromOffset(45, 29)
    statusDot.Size = UDim2.fromOffset(12, 12)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 194, 77)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = card

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    local title = Instance.new("TextLabel")
    title.Position = UDim2.fromOffset(68, 20)
    title.Size = UDim2.new(1, -92, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = string.upper(BRAND_NAME) .. " EM ATUALIZAÇÃO"
    title.TextColor3 = Color3.fromRGB(244, 245, 250)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.Parent = card

    local message = Instance.new("TextLabel")
    message.Position = UDim2.fromOffset(45, 63)
    message.Size = UDim2.new(1, -75, 0, 68)
    message.BackgroundTransparency = 1
    message.Text = BRAND_NAME .. " está temporariamente indisponível enquanto recebe melhorias. Tente novamente mais tarde."
    message.TextColor3 = Color3.fromRGB(170, 175, 190)
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextYAlignment = Enum.TextYAlignment.Top
    message.TextWrapped = true
    message.Font = Enum.Font.Gotham
    message.TextSize = 13
    message.Parent = card

    local footer = Instance.new("TextLabel")
    footer.Position = UDim2.fromOffset(45, 143)
    footer.Size = UDim2.new(1, -75, 0, 24)
    footer.BackgroundTransparency = 1
    footer.Text = "Criado por " .. BRAND_CREATOR .. " • manutenção em andamento"
    footer.TextColor3 = Color3.fromRGB(158, 134, 255)
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Font = Enum.Font.GothamSemibold
    footer.TextSize = 11
    footer.Parent = card
end

if not painelEstaAtivado() then
    mostrarMensagemDeAtualizacao()
    return
end

local previousUpdate = PlayerGui:FindFirstChild("NinModUpdateMessage")
if previousUpdate then
    previousUpdate:Destroy()
end

--============================================================--
-- ESTADO
--============================================================--

local State = {
    GodMode = false,
    Speed = false,
    Jump = false,
    Noclip = false,
    Fly = false,

    ESP = false,
    ESPNames = true,
    ESPHealth = true,
    ESPDistance = true,

    Aim = false,
    AimHead = true,
    TeamCheck = true,
    WallCheck = true,

    WalkSpeed = 50,
    JumpPower = 100,

    FlySpeed = 80,
    FlyVerticalMultiplier = 1.0,
    FlyAcceleration = 8,
    FlyDeceleration = 11,
    FlyTurboMultiplier = 1.8,
    FlyTilt = 16,
    FlyRotationResponse = 28,
    FlyTiltResponse = 10,
    FlyCameraVertical = true,

    AimFOV = 180,
    AimSmoothness = 5,
    AimPrediction = 0.03,

    SelectedUserId = nil,
    SpectatingUserId = nil,

    GoToOffsetX = 0,
    GoToOffsetY = 1,
    GoToOffsetZ = 4,
    TeleportFaceTarget = true,
}

local Character
local Humanoid
local RootPart
local Camera = Workspace.CurrentCamera

local Original = {
    WalkSpeed = 16,
    JumpPower = 50,
    MaxHealth = 100,
    BreakJointsOnDeath = true,
    AutoRotate = true,
    UseJumpPower = true,
}

local CharacterConnections = {}
local CollisionCache = {}
local ESPObjects = {}

local FlyAttachment
local FlyVelocity
local FlyOrientation
local FlyCurrentVelocity = Vector3.zero
local FlyCurrentTilt = Vector2.zero
local FlyInput = {
    Up = false,
    Down = false,
    Turbo = false,
}
local FlyTouchButtons = {}

local FLY_ACTION_UP = "NinModFlyUp"
local FLY_ACTION_DOWN = "NinModFlyDown"
local FLY_ACTION_TURBO = "NinModFlyTurbo"

local AimHolding = false
local CurrentTarget = nil
local GodHealthGuard = false

-- Slider global: evita criar várias conexões InputChanged/InputEnded.
local ActiveSlider = nil

--============================================================--
-- CORES
--============================================================--

local Colors = {
    Background = Color3.fromRGB(12, 14, 20),
    Sidebar = Color3.fromRGB(15, 17, 24),
    Card = Color3.fromRGB(22, 25, 34),
    CardHover = Color3.fromRGB(28, 32, 43),

    Accent = Color3.fromRGB(123, 92, 255),
    AccentLight = Color3.fromRGB(158, 134, 255),
    AccentDark = Color3.fromRGB(79, 57, 188),

    Text = Color3.fromRGB(242, 243, 248),
    MutedText = Color3.fromRGB(147, 153, 169),
    Border = Color3.fromRGB(43, 47, 61),

    Enabled = Color3.fromRGB(123, 92, 255),
    Disabled = Color3.fromRGB(55, 59, 72),

    Green = Color3.fromRGB(80, 220, 145),
    Red = Color3.fromRGB(245, 82, 105),
}

--============================================================--
-- UTILITÁRIOS
--============================================================--

local function disconnectList(list)
    for _, connection in ipairs(list) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(list)
end

local function tween(instance, duration, properties)
    local animation = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )
    animation:Play()
    return animation
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function createPadding(parent, left, right, top, bottom)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.Parent = parent
    return padding
end

local function getMouseViewportPosition()
    local rawPosition = UserInputService:GetMouseLocation()
    local topLeftInset = select(1, GuiService:GetGuiInset())
    return rawPosition - topLeftInset
end

local function getAliveHumanoid(character)
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return humanoid
    end

    return nil
end

--============================================================--
-- LIMPEZA DE INSTÂNCIAS ANTIGAS
--============================================================--

local previousGui = PlayerGui:FindFirstChild("NinMod")
if previousGui then
    previousGui:Destroy()
end

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        for _, object in ipairs(player.Character:GetChildren()) do
            if object.Name == "NinModESPHighlight"
                or object.Name == "NinModESPBillboard" then
                object:Destroy()
            end
        end
    end
end

--============================================================--
-- FUNÇÕES DO PERSONAGEM
--============================================================--

local function restoreCollisions()
    for part, originalValue in pairs(CollisionCache) do
        if part and part.Parent then
            part.CanCollide = originalValue
        end
    end
    table.clear(CollisionCache)
end

local function updateNoclip()
    if not Character then
        return
    end

    for _, object in ipairs(Character:GetDescendants()) do
        if object:IsA("BasePart") then
            if CollisionCache[object] == nil then
                CollisionCache[object] = object.CanCollide
            end
            object.CanCollide = false
        end
    end
end

local function applyGodMode()
    if not Humanoid then
        return
    end

    if State.GodMode then
        Humanoid.BreakJointsOnDeath = false

        pcall(function()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        end)

        Humanoid.MaxHealth = math.max(Original.MaxHealth, 1e9)
        Humanoid.Health = Humanoid.MaxHealth
    else
        pcall(function()
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end)

        Humanoid.BreakJointsOnDeath = Original.BreakJointsOnDeath
        Humanoid.MaxHealth = Original.MaxHealth
        Humanoid.Health = math.min(Humanoid.Health, Original.MaxHealth)
    end
end

local function setFlyTouchButtonPressed(actionName, pressed)
    local button = FlyTouchButtons[actionName]
    if not button or not button.Parent then
        return
    end

    tween(button, 0.1, {
        BackgroundColor3 = pressed and Colors.Accent or Colors.Card,
        BackgroundTransparency = pressed and 0 or 0.08,
        Size = pressed and UDim2.fromOffset(58, 58) or UDim2.fromOffset(64, 64),
    })
end

local function styleFlyTouchButton(actionName, labelText, position, isTurbo)
    if not UserInputService.TouchEnabled then
        return
    end

    ContextActionService:SetTitle(actionName, "")
    ContextActionService:SetPosition(actionName, position)

    task.spawn(function()
        local button

        for _ = 1, 20 do
            button = ContextActionService:GetButton(actionName)
            if button then
                break
            end
            task.wait(0.05)
        end

        if not button then
            return
        end

        FlyTouchButtons[actionName] = button
        button.Name = actionName .. "Button"
        button.AnchorPoint = Vector2.new(0.5, 0.5)
        button.Size = UDim2.fromOffset(64, 64)
        button.BackgroundColor3 = Colors.Card
        button.BackgroundTransparency = 0.08
        button.ImageTransparency = 1
        button.AutoButtonColor = false
        button.ZIndex = 50

        local oldCorner = button:FindFirstChild("NinModCorner")
        if not oldCorner then
            local corner = Instance.new("UICorner")
            corner.Name = "NinModCorner"
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = button
        end

        local oldStroke = button:FindFirstChild("NinModStroke")
        if not oldStroke then
            local stroke = Instance.new("UIStroke")
            stroke.Name = "NinModStroke"
            stroke.Color = Colors.AccentLight
            stroke.Transparency = 0.2
            stroke.Thickness = 1.5
            stroke.Parent = button
        end

        local label = button:FindFirstChild("NinModTouchLabel")
        if not label then
            label = Instance.new("TextLabel")
            label.Name = "NinModTouchLabel"
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundTransparency = 1
            label.TextColor3 = Colors.Text
            label.TextStrokeColor3 = Color3.new(0, 0, 0)
            label.TextStrokeTransparency = 0.55
            label.Font = Enum.Font.GothamBold
            label.ZIndex = button.ZIndex + 2
            label.Parent = button
        end

        label.Text = labelText
        label.TextSize = isTurbo and 10 or 28
        label.TextWrapped = true

        local scale = button:FindFirstChild("NinModTouchScale")
        if not scale then
            scale = Instance.new("UIScale")
            scale.Name = "NinModTouchScale"
            scale.Scale = 1
            scale.Parent = button
        end
    end)
end

local function updateFlyAction(actionName, inputState)
    local pressed = inputState == Enum.UserInputState.Begin
        or inputState == Enum.UserInputState.Change

    if inputState == Enum.UserInputState.End
        or inputState == Enum.UserInputState.Cancel then
        pressed = false
    end

    if actionName == FLY_ACTION_UP then
        FlyInput.Up = pressed
    elseif actionName == FLY_ACTION_DOWN then
        FlyInput.Down = pressed
    elseif actionName == FLY_ACTION_TURBO then
        FlyInput.Turbo = pressed
    end

    setFlyTouchButtonPressed(actionName, pressed)

    return State.Fly
        and Enum.ContextActionResult.Sink
        or Enum.ContextActionResult.Pass
end

local function unbindFlyActions()
    ContextActionService:UnbindAction(FLY_ACTION_UP)
    ContextActionService:UnbindAction(FLY_ACTION_DOWN)
    ContextActionService:UnbindAction(FLY_ACTION_TURBO)

    FlyInput.Up = false
    FlyInput.Down = false
    FlyInput.Turbo = false
    table.clear(FlyTouchButtons)
end

local function bindFlyActions()
    unbindFlyActions()

    ContextActionService:BindActionAtPriority(
        FLY_ACTION_UP,
        updateFlyAction,
        true,
        3000,
        Enum.KeyCode.Space,
        Enum.KeyCode.E,
        Enum.KeyCode.ButtonA
    )

    ContextActionService:BindActionAtPriority(
        FLY_ACTION_DOWN,
        updateFlyAction,
        true,
        3000,
        Enum.KeyCode.LeftControl,
        Enum.KeyCode.Q,
        Enum.KeyCode.ButtonB
    )

    ContextActionService:BindActionAtPriority(
        FLY_ACTION_TURBO,
        updateFlyAction,
        true,
        3000,
        Enum.KeyCode.LeftShift,
        Enum.KeyCode.ButtonL3
    )

    styleFlyTouchButton(
        FLY_ACTION_UP,
        "↑",
        UDim2.new(1, -142, 1, -302),
        false
    )

    styleFlyTouchButton(
        FLY_ACTION_DOWN,
        "↓",
        UDim2.new(1, -142, 1, -212),
        false
    )

    styleFlyTouchButton(
        FLY_ACTION_TURBO,
        "TURBO",
        UDim2.new(1, -235, 1, -257),
        true
    )
end

local function stopFly()
    unbindFlyActions()

    FlyCurrentVelocity = Vector3.zero
    FlyCurrentTilt = Vector2.zero

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyOrientation then
        FlyOrientation:Destroy()
        FlyOrientation = nil
    end

    if FlyAttachment then
        FlyAttachment:Destroy()
        FlyAttachment = nil
    end

    if Humanoid then
        Humanoid.PlatformStand = false
        Humanoid.AutoRotate = Original.AutoRotate

        if Humanoid.Health > 0 then
            pcall(function()
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end

    if RootPart then
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
    end
end

local function startFly()
    stopFly()

    if not RootPart or not Humanoid or Humanoid.Health <= 0 then
        return
    end

    FlyCurrentVelocity = Vector3.zero
    FlyCurrentTilt = Vector2.zero

    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Name = "NinModFlyAttachment"
    FlyAttachment.Parent = RootPart

    FlyVelocity = Instance.new("LinearVelocity")
    FlyVelocity.Name = "NinModFlyVelocity"
    FlyVelocity.Attachment0 = FlyAttachment
    FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    FlyVelocity.VectorVelocity = Vector3.zero
    FlyVelocity.MaxForce = 1e9
    FlyVelocity.Parent = RootPart

    pcall(function()
        FlyVelocity.ForceLimitsEnabled = false
    end)

    FlyOrientation = Instance.new("AlignOrientation")
    FlyOrientation.Name = "NinModFlyOrientation"
    FlyOrientation.Attachment0 = FlyAttachment
    FlyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    FlyOrientation.RigidityEnabled = false
    FlyOrientation.MaxTorque = 1e9
    FlyOrientation.Responsiveness = State.FlyRotationResponse
    FlyOrientation.Parent = RootPart

    Humanoid.PlatformStand = true
    Humanoid.AutoRotate = false
    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero

    bindFlyActions()
end

local function getKeyboardFlyAxes()
    local forwardAxis = 0
    local rightAxis = 0

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        forwardAxis += 1
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        forwardAxis -= 1
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        rightAxis += 1
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        rightAxis -= 1
    end

    return forwardAxis, rightAxis
end

local function getFlyMovementAxes(flatForward, flatRight)
    local keyboardForward, keyboardRight = getKeyboardFlyAxes()

    if math.abs(keyboardForward) > 0 or math.abs(keyboardRight) > 0 then
        return keyboardForward, keyboardRight
    end

    local moveDirection = Humanoid and Humanoid.MoveDirection or Vector3.zero
    if moveDirection.Magnitude <= 0.001 then
        return 0, 0
    end

    return moveDirection:Dot(flatForward), moveDirection:Dot(flatRight)
end

local function updateFly(deltaTime)
    if not State.Fly
        or not FlyVelocity
        or not FlyOrientation
        or not RootPart
        or not Humanoid
        or Humanoid.Health <= 0 then
        return
    end

    Camera = Workspace.CurrentCamera
    if not Camera then
        return
    end

    Humanoid.PlatformStand = true
    Humanoid.AutoRotate = false
    RootPart.AssemblyAngularVelocity = Vector3.zero

    local cameraLook = Camera.CFrame.LookVector
    local cameraRight = Camera.CFrame.RightVector

    local flatForward = Vector3.new(cameraLook.X, 0, cameraLook.Z)
    if flatForward.Magnitude <= 0.001 then
        flatForward = Vector3.new(0, 0, -1)
    else
        flatForward = flatForward.Unit
    end

    local flatRight = Vector3.new(cameraRight.X, 0, cameraRight.Z)
    if flatRight.Magnitude <= 0.001 then
        flatRight = Vector3.new(1, 0, 0)
    else
        flatRight = flatRight.Unit
    end

    local forwardAxis, rightAxis = getFlyMovementAxes(flatForward, flatRight)
    local verticalAxis = (FlyInput.Up and 1 or 0) - (FlyInput.Down and 1 or 0)

    local forwardVector = State.FlyCameraVertical and cameraLook or flatForward
    local directionalMovement = (forwardVector * forwardAxis)
        + (flatRight * rightAxis)

    if directionalMovement.Magnitude > 1 then
        directionalMovement = directionalMovement.Unit
    end

    local speedMultiplier = FlyInput.Turbo and State.FlyTurboMultiplier or 1
    local horizontalVelocity = directionalMovement
        * State.FlySpeed
        * speedMultiplier
    local verticalVelocity = Vector3.yAxis
        * verticalAxis
        * State.FlySpeed
        * State.FlyVerticalMultiplier
        * speedMultiplier
    local targetVelocity = horizontalVelocity + verticalVelocity

    local response = targetVelocity.Magnitude > FlyCurrentVelocity.Magnitude
        and State.FlyAcceleration
        or State.FlyDeceleration

    local velocityAlpha = 1 - math.exp(-math.max(response, 0.1) * deltaTime)
    FlyCurrentVelocity = FlyCurrentVelocity:Lerp(
        targetVelocity,
        math.clamp(velocityAlpha, 0, 1)
    )

    if targetVelocity.Magnitude <= 0.01 and FlyCurrentVelocity.Magnitude < 0.08 then
        FlyCurrentVelocity = Vector3.zero
    end

    FlyVelocity.VectorVelocity = FlyCurrentVelocity

    local desiredTilt = Vector2.new(forwardAxis, rightAxis)
    local tiltAlpha = 1 - math.exp(-State.FlyTiltResponse * deltaTime)
    FlyCurrentTilt = FlyCurrentTilt:Lerp(
        desiredTilt,
        math.clamp(tiltAlpha, 0, 1)
    )

    local pitch = math.rad(-FlyCurrentTilt.X * State.FlyTilt)
    local roll = math.rad(-FlyCurrentTilt.Y * State.FlyTilt)
    local facing = CFrame.lookAt(Vector3.zero, flatForward, Vector3.yAxis)

    FlyOrientation.Responsiveness = State.FlyRotationResponse
    FlyOrientation.CFrame = facing * CFrame.Angles(pitch, 0, roll)
end

local function applyCharacterStates()
    if not Humanoid then
        return
    end

    if State.GodMode then
        applyGodMode()
    end

    Humanoid.WalkSpeed = State.Speed and State.WalkSpeed or Original.WalkSpeed

    if State.Jump then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = State.JumpPower
    else
        Humanoid.UseJumpPower = Original.UseJumpPower
        Humanoid.JumpPower = Original.JumpPower
    end

    if State.Fly then
        startFly()
    end
end

local function bindCharacter(character)
    disconnectList(CharacterConnections)
    stopFly()
    restoreCollisions()

    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")

    Original.WalkSpeed = Humanoid.WalkSpeed
    Original.JumpPower = Humanoid.JumpPower
    Original.MaxHealth = Humanoid.MaxHealth
    Original.BreakJointsOnDeath = Humanoid.BreakJointsOnDeath
    Original.AutoRotate = Humanoid.AutoRotate
    Original.UseJumpPower = Humanoid.UseJumpPower

    table.insert(CharacterConnections, Humanoid.HealthChanged:Connect(function(health)
        if State.GodMode and health < Humanoid.MaxHealth and not GodHealthGuard then
            GodHealthGuard = true
            Humanoid.Health = Humanoid.MaxHealth
            GodHealthGuard = false
        end
    end))

    table.insert(CharacterConnections, character.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            stopFly()
            restoreCollisions()
        end
    end))

    task.defer(applyCharacterStates)
end

bindCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

--============================================================--
-- ESP
--============================================================--

local function removeESP(player)
    local data = ESPObjects[player]
    if not data then
        return
    end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" and object.Parent then
            object:Destroy()
        end
    end

    ESPObjects[player] = nil
end

local function removeAllESP()
    local playersToRemove = {}
    for player in pairs(ESPObjects) do
        table.insert(playersToRemove, player)
    end

    for _, player in ipairs(playersToRemove) do
        removeESP(player)
    end
end

local function isSameTeam(player)
    return State.TeamCheck
        and LocalPlayer.Team ~= nil
        and player.Team == LocalPlayer.Team
end

local function validESPPlayer(player)
    if player == LocalPlayer or isSameTeam(player) then
        return false
    end

    return player.Character ~= nil
        and getAliveHumanoid(player.Character) ~= nil
end

local function createESP(player)
    removeESP(player)

    if not State.ESP or not validESPPlayer(player) then
        return
    end

    local character = player.Character
    local targetHumanoid = getAliveHumanoid(character)
    local head = character and character:FindFirstChild("Head")

    if not character or not targetHumanoid or not head then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NinModESPHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Colors.Red
    highlight.FillTransparency = 0.72
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.08
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NinModESPBillboard"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(180, 58)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = character

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.25
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Humanoid = targetHumanoid,
        Head = head,
        Character = character,
    }
end

local function refreshESP()
    removeAllESP()

    if not State.ESP then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        createESP(player)
    end
end

local function updateESP()
    if not State.ESP then
        return
    end

    local playersToRebuild = {}

    for player, data in pairs(ESPObjects) do
        local needsRebuild = not validESPPlayer(player)
            or player.Character ~= data.Character
            or not data.Head
            or not data.Head.Parent
            or not data.Humanoid
            or not data.Humanoid.Parent

        if needsRebuild then
            table.insert(playersToRebuild, player)
        else
            local information = {}

            if State.ESPNames then
                table.insert(information, player.DisplayName)
            end

            if State.ESPHealth then
                table.insert(
                    information,
                    string.format("%d HP", math.max(0, math.floor(data.Humanoid.Health)))
                )
            end

            if State.ESPDistance and RootPart then
                local distance = (RootPart.Position - data.Head.Position).Magnitude
                table.insert(information, string.format("%d studs", math.floor(distance)))
            end

            data.Label.Text = table.concat(information, "\n")
            data.Billboard.Enabled = #information > 0
        end
    end

    for _, player in ipairs(playersToRebuild) do
        createESP(player)
    end

    -- Cria ESP para jogadores que ainda não estão registrados.
    for _, player in ipairs(Players:GetPlayers()) do
        if ESPObjects[player] == nil and validESPPlayer(player) then
            createESP(player)
        end
    end
end

--============================================================--
-- MIRA ADMINISTRATIVA
--============================================================--

local function getAimPart(character)
    if not character then
        return nil
    end

    if State.AimHead then
        return character:FindFirstChild("Head")
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
end

local function canSeeTarget(part)
    if not State.WallCheck then
        return true
    end

    if not Character or not Camera or not part then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local parameters = RaycastParams.new()
    parameters.FilterType = Enum.RaycastFilterType.Exclude
    parameters.FilterDescendantsInstances = {Character, Camera}
    parameters.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, parameters)

    return result == nil
        or result.Instance:IsDescendantOf(part.Parent)
end

local function validAimPlayer(player)
    if player == LocalPlayer or isSameTeam(player) then
        return false
    end

    local character = player.Character
    local humanoid = getAliveHumanoid(character)

    return humanoid ~= nil and getAimPart(character) ~= nil
end

local function getScreenDistanceFromMouse(part)
    if not Camera or not part then
        return math.huge, false
    end

    local viewportPosition, visible = Camera:WorldToViewportPoint(part.Position)
    if not visible or viewportPosition.Z <= 0 then
        return math.huge, false
    end

    local mousePosition = getMouseViewportPosition()
    local targetPosition = Vector2.new(viewportPosition.X, viewportPosition.Y)
    return (targetPosition - mousePosition).Magnitude, true
end

local function targetStillValid(player)
    if not player or not validAimPlayer(player) then
        return false
    end

    local part = getAimPart(player.Character)
    if not part or not canSeeTarget(part) then
        return false
    end

    local distance, visible = getScreenDistanceFromMouse(part)
    return visible and distance <= State.AimFOV
end

local function findClosestTarget()
    local closestPlayer = nil
    local closestDistance = State.AimFOV

    for _, player in ipairs(Players:GetPlayers()) do
        if validAimPlayer(player) then
            local part = getAimPart(player.Character)

            if part and canSeeTarget(part) then
                local distance, visible = getScreenDistanceFromMouse(part)

                if visible and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

--============================================================--
-- INTERFACE
--============================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NinMod"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5)
Shadow.Size = UDim2.fromOffset(720, 490)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.35
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(680, 450)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
createCorner(Main, 13)
createStroke(Main, Colors.Border, 0.15, 1)

local Scale = Instance.new("UIScale")
Scale.Scale = 1
Scale.Parent = Main

local ShadowScale = Instance.new("UIScale")
ShadowScale.Scale = 1
ShadowScale.Parent = Shadow

local function updateUIScale()
    Camera = Workspace.CurrentCamera
    if not Camera then
        return
    end

    local viewport = Camera.ViewportSize
    local scale = math.min(viewport.X / 760, viewport.Y / 540, 1)
    scale = math.clamp(scale, 0.45, 1)

    Scale.Scale = scale
    ShadowScale.Scale = scale
end

local CameraViewportConnection

local function bindCameraViewport()
    if CameraViewportConnection and CameraViewportConnection.Connected then
        CameraViewportConnection:Disconnect()
    end

    Camera = Workspace.CurrentCamera
    updateUIScale()

    if Camera then
        CameraViewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
    end
end

bindCameraViewport()

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 56)
Topbar.BackgroundColor3 = Colors.Background
Topbar.BorderSizePixel = 0
Topbar.Active = true
Topbar.Parent = Main

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.new(0, 16, 0.5, -17)
Logo.BackgroundColor3 = Colors.Accent
Logo.BorderSizePixel = 0
Logo.Parent = Topbar
createCorner(Logo, 9)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.BackgroundTransparency = 1
LogoText.Text = string.sub(BRAND_NAME, 1, 1)
LogoText.TextColor3 = Color3.new(1, 1, 1)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 18
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Position = UDim2.new(0, 62, 0, 10)
Title.Size = UDim2.fromOffset(260, 20)
Title.BackgroundTransparency = 1
Title.Text = string.upper(BRAND_NAME)
Title.TextColor3 = Colors.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Topbar

local Subtitle = Instance.new("TextLabel")
Subtitle.Position = UDim2.new(0, 62, 0, 30)
Subtitle.Size = UDim2.fromOffset(300, 16)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Criado por " .. BRAND_CREATOR
Subtitle.TextColor3 = Colors.MutedText
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.Parent = Topbar

local function makeTopButton(text, rightOffset)
    local button = Instance.new("TextButton")
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.Position = UDim2.new(1, rightOffset, 0.5, 0)
    button.Size = UDim2.fromOffset(30, 30)
    button.BackgroundColor3 = Colors.Card
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Colors.MutedText
    button.Font = Enum.Font.GothamBold
    button.TextSize = text == "×" and 18 or 15
    button.AutoButtonColor = false
    button.Parent = Topbar
    createCorner(button, 7)
    return button
end

local MinimizeButton = makeTopButton("—", -48)
local CloseButton = makeTopButton("×", -12)

CloseButton.MouseEnter:Connect(function()
    tween(CloseButton, 0.12, {
        BackgroundColor3 = Colors.Red,
        TextColor3 = Color3.new(1, 1, 1),
    })
end)

CloseButton.MouseLeave:Connect(function()
    tween(CloseButton, 0.12, {
        BackgroundColor3 = Colors.Card,
        TextColor3 = Colors.MutedText,
    })
end)

local TopDivider = Instance.new("Frame")
TopDivider.Position = UDim2.new(0, 0, 0, 55)
TopDivider.Size = UDim2.new(1, 0, 0, 1)
TopDivider.BackgroundColor3 = Colors.Border
TopDivider.BackgroundTransparency = 0.25
TopDivider.BorderSizePixel = 0
TopDivider.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.new(0, 0, 0, 56)
Sidebar.Size = UDim2.new(0, 160, 1, -56)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarDivider = Instance.new("Frame")
SidebarDivider.AnchorPoint = Vector2.new(1, 0)
SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.BackgroundColor3 = Colors.Border
SidebarDivider.BackgroundTransparency = 0.25
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local Navigation = Instance.new("Frame")
Navigation.Position = UDim2.new(0, 10, 0, 14)
Navigation.Size = UDim2.new(1, -20, 1, -80)
Navigation.BackgroundTransparency = 1
Navigation.Parent = Sidebar

local NavigationLayout = Instance.new("UIListLayout")
NavigationLayout.Padding = UDim.new(0, 6)
NavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavigationLayout.Parent = Navigation

local UserCard = Instance.new("Frame")
UserCard.AnchorPoint = Vector2.new(0, 1)
UserCard.Position = UDim2.new(0, 10, 1, -10)
UserCard.Size = UDim2.new(1, -20, 0, 52)
UserCard.BackgroundColor3 = Colors.Card
UserCard.BorderSizePixel = 0
UserCard.Parent = Sidebar
createCorner(UserCard, 9)
createStroke(UserCard, Colors.Border, 0.3, 1)

local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Position = UDim2.new(0, 8, 0.5, -17)
UserAvatar.Size = UDim2.fromOffset(34, 34)
UserAvatar.BackgroundColor3 = Colors.AccentDark
UserAvatar.BorderSizePixel = 0
UserAvatar.Image = string.format(
    "rbxthumb://type=AvatarHeadShot&id=%d&w=100&h=100",
    LocalPlayer.UserId
)
UserAvatar.Parent = UserCard
createCorner(UserAvatar, 17)

local UserName = Instance.new("TextLabel")
UserName.Position = UDim2.new(0, 50, 0, 9)
UserName.Size = UDim2.new(1, -56, 0, 17)
UserName.BackgroundTransparency = 1
UserName.Text = LocalPlayer.DisplayName
UserName.TextColor3 = Colors.Text
UserName.TextXAlignment = Enum.TextXAlignment.Left
UserName.TextTruncate = Enum.TextTruncate.AtEnd
UserName.Font = Enum.Font.GothamSemibold
UserName.TextSize = 11
UserName.Parent = UserCard

local UserRole = Instance.new("TextLabel")
UserRole.Position = UDim2.new(0, 50, 0, 27)
UserRole.Size = UDim2.new(1, -56, 0, 15)
UserRole.BackgroundTransparency = 1
UserRole.Text = "Administrador"
UserRole.TextColor3 = Colors.AccentLight
UserRole.TextXAlignment = Enum.TextXAlignment.Left
UserRole.Font = Enum.Font.Gotham
UserRole.TextSize = 9
UserRole.Parent = UserCard

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.new(0, 160, 0, 56)
Content.Size = UDim2.new(1, -160, 1, -56)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local Pages = {}
local Tabs = {}
local SelectedTab = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.Accent
    page.ScrollBarImageTransparency = 0.25
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content

    createPadding(page, 18, 18, 16, 18)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    Pages[name] = page
    return page
end

local function selectTab(name)
    SelectedTab = name

    for tabName, tabData in pairs(Tabs) do
        local selected = tabName == name
        Pages[tabName].Visible = selected

        tween(tabData.Button, 0.15, {
            BackgroundColor3 = selected and Colors.Accent or Colors.Sidebar,
            TextColor3 = selected and Color3.new(1, 1, 1) or Colors.MutedText,
        })

        tabData.Indicator.Visible = selected
    end
end

local function createTab(name, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = Colors.Sidebar
    button.BorderSizePixel = 0
    button.Text = icon .. "   " .. name
    button.TextColor3 = Colors.MutedText
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 11
    button.AutoButtonColor = false
    button.Parent = Navigation
    createCorner(button, 8)
    createPadding(button, 13, 8, 0, 0)

    local indicator = Instance.new("Frame")
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.Position = UDim2.new(0, -10, 0.5, 0)
    indicator.Size = UDim2.fromOffset(3, 20)
    indicator.BackgroundColor3 = Color3.new(1, 1, 1)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = button
    createCorner(indicator, 2)

    button.MouseEnter:Connect(function()
        if SelectedTab ~= name then
            tween(button, 0.12, {
                BackgroundColor3 = Colors.Card,
                TextColor3 = Colors.Text,
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if SelectedTab ~= name then
            tween(button, 0.12, {
                BackgroundColor3 = Colors.Sidebar,
                TextColor3 = Colors.MutedText,
            })
        end
    end)

    button.MouseButton1Click:Connect(function()
        selectTab(name)
    end)

    Tabs[name] = {
        Button = button,
        Indicator = indicator,
    }
end

local function createSection(page, titleText, descriptionText)
    local section = Instance.new("Frame")
    section.Name = titleText
    section.Size = UDim2.new(1, 0, 0, 58)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Colors.Card
    section.BorderSizePixel = 0
    section.Parent = page
    createCorner(section, 10)
    createStroke(section, Colors.Border, 0.35, 1)
    createPadding(section, 12, 12, 12, 12)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = section

    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1, 0, 0, 18)
    heading.BackgroundTransparency = 1
    heading.Text = titleText
    heading.TextColor3 = Colors.Text
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 12
    heading.Parent = section

    if descriptionText then
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, 0, 0, 16)
        description.BackgroundTransparency = 1
        description.Text = descriptionText
        description.TextColor3 = Colors.MutedText
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Font = Enum.Font.Gotham
        description.TextSize = 9
        description.Parent = section
    end

    return section
end

local function createToggle(parent, text, defaultValue, callback)
    local enabled = defaultValue == true

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Colors.Background
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = parent
    createCorner(row, 8)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 11, 0, 0)
    label.Size = UDim2.new(1, -66, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.Parent = row

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -10, 0.5, 0)
    switch.Size = UDim2.fromOffset(38, 20)
    switch.BackgroundColor3 = enabled and Colors.Enabled or Colors.Disabled
    switch.BorderSizePixel = 0
    switch.Parent = row
    createCorner(switch, 10)

    local circle = Instance.new("Frame")
    circle.AnchorPoint = Vector2.new(0.5, 0.5)
    circle.Position = enabled and UDim2.new(1, -10, 0.5, 0)
        or UDim2.new(0, 10, 0.5, 0)
    circle.Size = UDim2.fromOffset(14, 14)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.BorderSizePixel = 0
    circle.Parent = switch
    createCorner(circle, 7)

    local controller = {}

    function controller:Set(value, silent)
        enabled = value == true

        tween(switch, 0.15, {
            BackgroundColor3 = enabled and Colors.Enabled or Colors.Disabled,
        })

        tween(circle, 0.15, {
            Position = enabled and UDim2.new(1, -10, 0.5, 0)
                or UDim2.new(0, 10, 0.5, 0),
        })

        if not silent and callback then
            task.spawn(callback, enabled)
        end
    end

    function controller:Get()
        return enabled
    end

    row.MouseButton1Click:Connect(function()
        controller:Set(not enabled)
    end)

    row.MouseEnter:Connect(function()
        tween(row, 0.12, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Colors.CardHover,
        })
    end)

    row.MouseLeave:Connect(function()
        tween(row, 0.12, {
            BackgroundTransparency = 0.35,
            BackgroundColor3 = Colors.Background,
        })
    end)

    return controller
end

local function createSlider(parent, text, minimum, maximum, defaultValue, callback, options)
    options = options or {}

    local step = math.max(options.Step or 1, 0.0001)
    local formatter = options.Formatter or function(currentValue)
        return tostring(currentValue)
    end

    local function normalizeValue(rawValue)
        local stepsFromMinimum = math.floor(((rawValue - minimum) / step) + 0.5)
        local normalized = minimum + (stepsFromMinimum * step)
        normalized = math.clamp(normalized, minimum, maximum)

        -- Evita números como 1.7999999998 em sliders decimais.
        return tonumber(string.format("%.4f", normalized))
    end

    local value = normalizeValue(defaultValue)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 55)
    row.BackgroundColor3 = Colors.Background
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.Parent = parent
    createCorner(row, 8)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 11, 0, 7)
    label.Size = UDim2.new(1, -86, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 10
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -11, 0, 7)
    valueLabel.Size = UDim2.fromOffset(72, 18)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = formatter(value)
    valueLabel.TextColor3 = Colors.AccentLight
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 10
    valueLabel.Parent = row

    local bar = Instance.new("Frame")
    bar.Position = UDim2.new(0, 11, 1, -19)
    bar.Size = UDim2.new(1, -22, 0, 5)
    bar.BackgroundColor3 = Colors.Disabled
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.Parent = row
    createCorner(bar, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    createCorner(fill, 3)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(12, 12)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = fill
    createCorner(knob, 6)

    local controller = {}

    function controller:Set(newValue, silent)
        value = normalizeValue(newValue)
        local percentage = (value - minimum) / (maximum - minimum)

        valueLabel.Text = formatter(value)
        fill.Size = UDim2.new(percentage, 0, 1, 0)

        if not silent and callback then
            callback(value)
        end
    end

    function controller:Get()
        return value
    end

    function controller:UpdateFromX(xPosition)
        if bar.AbsoluteSize.X <= 0 then
            return
        end

        local percentage = math.clamp(
            (xPosition - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0,
            1
        )
        controller:Set(minimum + ((maximum - minimum) * percentage))
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            ActiveSlider = controller
            controller:UpdateFromX(input.Position.X)
        end
    end)

    return controller
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = Colors.Accent
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 10
    button.AutoButtonColor = false
    button.Parent = parent
    createCorner(button, 8)

    button.MouseEnter:Connect(function()
        tween(button, 0.12, {BackgroundColor3 = Colors.AccentLight})
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, {BackgroundColor3 = Colors.Accent})
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback, button)
        end
    end)

    return button
end


local function createCycleSelector(parent, text, initialItems, callback)
    local items = initialItems or {}
    local index = #items > 0 and 1 or 0

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = Colors.Background
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.Parent = parent
    createCorner(row, 8)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Position = UDim2.new(0, 11, 0, 5)
    titleLabel.Size = UDim2.new(1, -22, 0, 16)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = text
    titleLabel.TextColor3 = Colors.MutedText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 9
    titleLabel.Parent = row

    local previousButton = Instance.new("TextButton")
    previousButton.Position = UDim2.new(0, 8, 0, 24)
    previousButton.Size = UDim2.fromOffset(30, 24)
    previousButton.BackgroundColor3 = Colors.Card
    previousButton.BorderSizePixel = 0
    previousButton.Text = "‹"
    previousButton.TextColor3 = Colors.Text
    previousButton.Font = Enum.Font.GothamBold
    previousButton.TextSize = 18
    previousButton.AutoButtonColor = false
    previousButton.Parent = row
    createCorner(previousButton, 6)

    local nextButton = Instance.new("TextButton")
    nextButton.AnchorPoint = Vector2.new(1, 0)
    nextButton.Position = UDim2.new(1, -8, 0, 24)
    nextButton.Size = UDim2.fromOffset(30, 24)
    nextButton.BackgroundColor3 = Colors.Card
    nextButton.BorderSizePixel = 0
    nextButton.Text = "›"
    nextButton.TextColor3 = Colors.Text
    nextButton.Font = Enum.Font.GothamBold
    nextButton.TextSize = 18
    nextButton.AutoButtonColor = false
    nextButton.Parent = row
    createCorner(nextButton, 6)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Position = UDim2.new(0, 44, 0, 24)
    valueLabel.Size = UDim2.new(1, -88, 0, 24)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Colors.AccentLight
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 10
    valueLabel.Parent = row

    local controller = {}

    local function getItemLabel(item)
        if typeof(item) == "table" then
            return tostring(item.Label or item.Value or "Sem opção")
        end
        return tostring(item or "Sem opção")
    end

    local function getItemValue(item)
        if typeof(item) == "table" then
            return item.Value
        end
        return item
    end

    local function updateLabel(silent)
        if index <= 0 or #items == 0 then
            valueLabel.Text = "Nenhuma opção disponível"
            if not silent and callback then
                callback(nil, nil)
            end
            return
        end

        local item = items[index]
        local label = getItemLabel(item)
        local value = getItemValue(item)
        valueLabel.Text = label

        if not silent and callback then
            callback(value, label)
        end
    end

    function controller:SetItems(newItems, preserveValue)
        local previousValue = preserveValue and controller:GetValue() or nil
        items = newItems or {}
        index = #items > 0 and 1 or 0

        if previousValue ~= nil then
            for itemIndex, item in ipairs(items) do
                if getItemValue(item) == previousValue then
                    index = itemIndex
                    break
                end
            end
        end

        updateLabel(false)
    end

    function controller:SetValue(targetValue, silent)
        for itemIndex, item in ipairs(items) do
            if getItemValue(item) == targetValue then
                index = itemIndex
                updateLabel(silent)
                return true
            end
        end
        return false
    end

    function controller:GetValue()
        if index <= 0 or not items[index] then
            return nil
        end
        return getItemValue(items[index])
    end

    function controller:GetLabel()
        if index <= 0 or not items[index] then
            return nil
        end
        return getItemLabel(items[index])
    end

    function controller:Next()
        if #items == 0 then
            return
        end
        index = (index % #items) + 1
        updateLabel(false)
    end

    function controller:Previous()
        if #items == 0 then
            return
        end
        index -= 1
        if index < 1 then
            index = #items
        end
        updateLabel(false)
    end

    previousButton.MouseButton1Click:Connect(function()
        controller:Previous()
    end)

    nextButton.MouseButton1Click:Connect(function()
        controller:Next()
    end)

    updateLabel(true)
    return controller
end

local function createStatus(parent, titleText, valueText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Colors.Background
    row.BackgroundTransparency = 0.35
    row.BorderSizePixel = 0
    row.Parent = parent
    createCorner(row, 8)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Position = UDim2.new(0, 11, 0, 0)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Colors.MutedText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 10
    titleLabel.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -11, 0, 0)
    valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = valueText
    valueLabel.TextColor3 = Colors.AccentLight
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 10
    valueLabel.Parent = row

    return valueLabel
end

local function notify(titleText, messageText, duration)
    duration = duration or 3

    local notification = Instance.new("Frame")
    notification.AnchorPoint = Vector2.new(1, 1)
    notification.Position = UDim2.new(1, 340, 1, -20)
    notification.Size = UDim2.fromOffset(300, 72)
    notification.BackgroundColor3 = Colors.Card
    notification.BorderSizePixel = 0
    notification.Parent = ScreenGui
    createCorner(notification, 10)
    createStroke(notification, Colors.Border, 0.1, 1)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -16)
    accent.Position = UDim2.new(0, 8, 0, 8)
    accent.BackgroundColor3 = Colors.Accent
    accent.BorderSizePixel = 0
    accent.Parent = notification
    createCorner(accent, 2)

    local notificationTitle = Instance.new("TextLabel")
    notificationTitle.Position = UDim2.new(0, 23, 0, 11)
    notificationTitle.Size = UDim2.new(1, -34, 0, 20)
    notificationTitle.BackgroundTransparency = 1
    notificationTitle.Text = titleText
    notificationTitle.TextColor3 = Colors.Text
    notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
    notificationTitle.Font = Enum.Font.GothamBold
    notificationTitle.TextSize = 11
    notificationTitle.Parent = notification

    local notificationMessage = Instance.new("TextLabel")
    notificationMessage.Position = UDim2.new(0, 23, 0, 32)
    notificationMessage.Size = UDim2.new(1, -34, 0, 30)
    notificationMessage.BackgroundTransparency = 1
    notificationMessage.Text = messageText
    notificationMessage.TextColor3 = Colors.MutedText
    notificationMessage.TextXAlignment = Enum.TextXAlignment.Left
    notificationMessage.TextYAlignment = Enum.TextYAlignment.Top
    notificationMessage.TextWrapped = true
    notificationMessage.Font = Enum.Font.Gotham
    notificationMessage.TextSize = 9
    notificationMessage.Parent = notification

    tween(notification, 0.3, {Position = UDim2.new(1, -20, 1, -20)})

    task.delay(duration, function()
        if notification.Parent then
            tween(notification, 0.3, {Position = UDim2.new(1, 340, 1, -20)})
            task.delay(0.35, function()
                if notification.Parent then
                    notification:Destroy()
                end
            end)
        end
    end)
end


--============================================================--
-- PÁGINAS
--============================================================--

local PlayerPage = createPage("Jogador")
local VisualPage = createPage("Visual")
local AimPage = createPage("Mira")
local AdminPage = createPage("Admin")
local SettingsPage = createPage("Configurações")

createTab("Jogador", "◆")
createTab("Visual", "◉")
createTab("Mira", "⌖")
createTab("Admin", "✦")
createTab("Configurações", "⚙")

local MovementSection = createSection(
    PlayerPage,
    "Movimentação",
    "Controles locais do seu personagem."
)

local GodToggle
local SpeedToggle
local JumpToggle
local NoclipToggle
local FlyToggle
local ESPToggle
local AimToggle
local PlayerSelector

GodToggle = createToggle(MovementSection, "Imortalidade local", State.GodMode, function(value)
    State.GodMode = value
    applyGodMode()
    notify("Imortalidade", value and "Imortalidade ativada." or "Imortalidade desativada.")
end)

SpeedToggle = createToggle(MovementSection, "Velocidade personalizada", State.Speed, function(value)
    State.Speed = value
    if Humanoid then
        Humanoid.WalkSpeed = value and State.WalkSpeed or Original.WalkSpeed
    end
end)

createSlider(MovementSection, "Velocidade", 16, 200, State.WalkSpeed, function(value)
    State.WalkSpeed = value
    if State.Speed and Humanoid then
        Humanoid.WalkSpeed = value
    end
end)

JumpToggle = createToggle(MovementSection, "Pulo personalizado", State.Jump, function(value)
    State.Jump = value
    if Humanoid then
        if value then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = State.JumpPower
        else
            Humanoid.UseJumpPower = Original.UseJumpPower
            Humanoid.JumpPower = Original.JumpPower
        end
    end
end)

createSlider(MovementSection, "Força do pulo", 50, 250, State.JumpPower, function(value)
    State.JumpPower = value
    if State.Jump and Humanoid then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = value
    end
end)

NoclipToggle = createToggle(MovementSection, "Noclip", State.Noclip, function(value)
    State.Noclip = value
    if not value then
        restoreCollisions()
    end
end)

FlyToggle = createToggle(MovementSection, "Fly multiplataforma", State.Fly, function(value)
    State.Fly = value
    if value then
        startFly()
        notify(
            "Fly ativado",
            UserInputService.TouchEnabled
                and "Use o joystick e os botões ↑, ↓ e TURBO."
                or "WASD move, Espaço/E sobe, Ctrl/Q desce e Shift ativa o turbo."
        )
    else
        stopFly()
    end
end)

local FlySection = createSection(
    PlayerPage,
    "Fly multiplataforma",
    "Controles de voo para computador, controle e celular."
)

createStatus(FlySection, "PC", "WASD · Espaço/Ctrl · Shift")
createStatus(FlySection, "Celular", "Joystick · ↑/↓ · TURBO · botão R")
createStatus(FlySection, "Ajustes avançados", "Aba Configurações")

createButton(FlySection, "Abrir configurações do fly", function()
    selectTab("Configurações")
end)

local CharacterSection = createSection(
    PlayerPage,
    "Personagem",
    "Ações rápidas para o administrador."
)

createButton(CharacterSection, "Curar completamente", function()
    if Humanoid then
        Humanoid.Health = Humanoid.MaxHealth
        notify("Personagem", "Vida restaurada.")
    end
end)

createButton(CharacterSection, "Destravar personagem", function()
    if RootPart and Humanoid then
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        RootPart.CFrame += Vector3.new(0, 4, 0)
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

local ESPSection = createSection(
    VisualPage,
    "ESP administrativo",
    "Destaca jogadores e apresenta informações."
)

ESPToggle = createToggle(ESPSection, "Ativar ESP", State.ESP, function(value)
    State.ESP = value
    refreshESP()
end)

createToggle(ESPSection, "Mostrar nomes", State.ESPNames, function(value)
    State.ESPNames = value
end)

createToggle(ESPSection, "Mostrar vida", State.ESPHealth, function(value)
    State.ESPHealth = value
end)

createToggle(ESPSection, "Mostrar distância", State.ESPDistance, function(value)
    State.ESPDistance = value
end)

local VisualInfoSection = createSection(
    VisualPage,
    "Informações",
    "O ESP existe apenas na tela do administrador."
)

local PlayerCountStatus = createStatus(
    VisualInfoSection,
    "Jogadores no servidor",
    tostring(#Players:GetPlayers())
)

createStatus(VisualInfoSection, "Renderização", "Cliente local")

local AimSection = createSection(
    AimPage,
    "Assistência de mira",
    "Segure o botão direito para acompanhar o alvo."
)

AimToggle = createToggle(AimSection, "Ativar assistência", State.Aim, function(value)
    State.Aim = value
    if not value then
        CurrentTarget = nil
    end
end)

local AimModeStatus

local AimModeButton = createButton(AimSection, "Alvo atual: cabeça", function(button)
    State.AimHead = not State.AimHead
    CurrentTarget = nil
    button.Text = State.AimHead and "Alvo atual: cabeça" or "Alvo atual: corpo"

    if AimModeStatus then
        AimModeStatus.Text = State.AimHead and "Cabeça" or "Corpo"
    end
end)

createToggle(AimSection, "Ignorar jogadores do mesmo time", State.TeamCheck, function(value)
    State.TeamCheck = value
    CurrentTarget = nil
    refreshESP()
end)

createToggle(AimSection, "Verificar paredes", State.WallCheck, function(value)
    State.WallCheck = value
    CurrentTarget = nil
end)

createSlider(AimSection, "Área da mira — FOV", 40, 400, State.AimFOV, function(value)
    State.AimFOV = value
end)

createSlider(AimSection, "Suavização — 1 é instantânea", 1, 30, State.AimSmoothness, function(value)
    State.AimSmoothness = value
end)

local PrecisionSection = createSection(
    AimPage,
    "Precisão",
    "Predição leve para alvos em movimento."
)

createSlider(
    PrecisionSection,
    "Predição",
    0,
    20,
    math.floor(State.AimPrediction * 100),
    function(value)
        State.AimPrediction = value / 100
    end
)

AimModeStatus = createStatus(
    PrecisionSection,
    "Modo atual",
    State.AimHead and "Cabeça" or "Corpo"
)


local AdminTargetSection = createSection(
    AdminPage,
    "Jogador selecionado",
    "Escolha um jogador para teleporte local ou modo espectador."
)

local function buildPlayerSelectorItems()
    local playerItems = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerItems, {
                Label = player.DisplayName .. "  @" .. player.Name,
                Value = player.UserId,
            })
        end
    end

    table.sort(playerItems, function(a, b)
        return string.lower(a.Label) < string.lower(b.Label)
    end)

    return playerItems
end

local function refreshPlayerSelector()
    if not PlayerSelector then
        return
    end

    PlayerSelector:SetItems(buildPlayerSelectorItems(), true)
    State.SelectedUserId = PlayerSelector:GetValue()
end

PlayerSelector = createCycleSelector(
    AdminTargetSection,
    "Alvo",
    buildPlayerSelectorItems(),
    function(value)
        State.SelectedUserId = value
    end
)
State.SelectedUserId = PlayerSelector:GetValue()

createButton(AdminTargetSection, "Atualizar lista de jogadores", function()
    refreshPlayerSelector()
    notify("Jogadores", "Lista de jogadores atualizada.")
end)

local LocalModeStatus = createStatus(
    AdminTargetSection,
    "Modo de execução",
    "100% LocalScript"
)
LocalModeStatus.TextColor3 = Colors.Green

local function getSelectedPlayer()
    local selectedUserId = PlayerSelector and PlayerSelector:GetValue() or nil
    State.SelectedUserId = selectedUserId

    if not selectedUserId then
        notify("Jogador", "Não há outro jogador selecionado.")
        return nil
    end

    local player = Players:GetPlayerByUserId(selectedUserId)
    if not player or player == LocalPlayer then
        notify("Jogador", "O jogador selecionado não está disponível.")
        return nil
    end

    return player
end

local function getPlayerCharacterData(player)
    local character = player and player.Character
    if not character or not character.Parent then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart or humanoid.Health <= 0 then
        return nil
    end

    return character, humanoid, rootPart
end

local function stopSpectating()
    State.SpectatingUserId = nil
    Camera = Workspace.CurrentCamera

    if Camera and Humanoid and Humanoid.Parent then
        Camera.CameraSubject = Humanoid
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local AdminActionsSection = createSection(
    AdminPage,
    "Ações locais",
    "Estas ações não precisam de servidor e afetam somente seu cliente/personagem."
)

createButton(AdminActionsSection, "Ir até o jogador selecionado", function()
    local target = getSelectedPlayer()
    if not target then
        return
    end

    local _, _, targetRoot = getPlayerCharacterData(target)
    if not targetRoot or not Character or not RootPart then
        notify("Teleporte", "O personagem selecionado não está disponível.")
        return
    end

    local destination = targetRoot.CFrame * CFrame.new(
        State.GoToOffsetX,
        State.GoToOffsetY,
        State.GoToOffsetZ
    )

    if State.TeleportFaceTarget then
        local position = destination.Position
        local targetPosition = Vector3.new(
            targetRoot.Position.X,
            position.Y,
            targetRoot.Position.Z
        )

        if (targetPosition - position).Magnitude > 0.01 then
            destination = CFrame.lookAt(position, targetPosition)
        end
    end

    FlyCurrentVelocity = Vector3.zero
    RootPart.AssemblyLinearVelocity = Vector3.zero
    RootPart.AssemblyAngularVelocity = Vector3.zero
    Character:PivotTo(destination)

    notify("Teleporte local", "Você foi até " .. target.DisplayName .. ".")
end)

createButton(AdminActionsSection, "Espectar jogador selecionado", function()
    local target = getSelectedPlayer()
    if not target then
        return
    end

    local _, targetHumanoid = getPlayerCharacterData(target)
    Camera = Workspace.CurrentCamera

    if not Camera or not targetHumanoid then
        notify("Espectador", "O personagem selecionado não está disponível.")
        return
    end

    State.SpectatingUserId = target.UserId
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = targetHumanoid
    notify("Espectador", "Agora observando " .. target.DisplayName .. ".")
end)

createButton(AdminActionsSection, "Parar de espectar", function()
    stopSpectating()
    notify("Espectador", "Câmera restaurada para seu personagem.")
end)

local LocalLimitSection = createSection(
    AdminPage,
    "Limite do modo local",
    "Trazer, fling e dano em outros jogadores exigem autoridade do servidor e foram removidos."
)

createStatus(LocalLimitSection, "Teleporte próprio", "Disponível")
createStatus(LocalLimitSection, "Espectador", "Disponível")
createStatus(LocalLimitSection, "Alterar outros jogadores", "Indisponível localmente")

local PanelSection = createSection(
    SettingsPage,
    "Painel",
    "Personalização e controles do painel."
)

createStatus(PanelSection, "Tecla para abrir", "Right Shift")
createStatus(PanelSection, "Acesso", "Livre — sem UserId")
createStatus(
    PanelSection,
    "Ambiente",
    RunService:IsStudio() and "Roblox Studio" or "Jogo publicado"
)

local FlySettingsSection = createSection(
    SettingsPage,
    "Configurações do fly",
    "Os ajustes são aplicados imediatamente, mesmo durante o voo."
)

local FlyTurboSpeedStatus

local function updateFlyTurboSpeedStatus()
    if FlyTurboSpeedStatus then
        FlyTurboSpeedStatus.Text = tostring(
            math.floor((State.FlySpeed * State.FlyTurboMultiplier) + 0.5)
        ) .. " studs/s"
    end
end

local FlySpeedSlider = createSlider(
    FlySettingsSection,
    "Velocidade horizontal",
    20,
    300,
    State.FlySpeed,
    function(value)
        State.FlySpeed = value
        updateFlyTurboSpeedStatus()
    end,
    {
        Step = 5,
        Formatter = function(value)
            return tostring(math.floor(value)) .. " studs/s"
        end,
    }
)

local FlyVerticalSlider = createSlider(
    FlySettingsSection,
    "Velocidade para subir e descer",
    0.5,
    2.5,
    State.FlyVerticalMultiplier,
    function(value)
        State.FlyVerticalMultiplier = value
    end,
    {
        Step = 0.1,
        Formatter = function(value)
            return string.format("%.1fx", value)
        end,
    }
)

local FlyTurboSlider = createSlider(
    FlySettingsSection,
    "Multiplicador do turbo",
    1.0,
    3.0,
    State.FlyTurboMultiplier,
    function(value)
        State.FlyTurboMultiplier = value
        updateFlyTurboSpeedStatus()
    end,
    {
        Step = 0.1,
        Formatter = function(value)
            return string.format("%.1fx", value)
        end,
    }
)

local FlyAccelerationSlider = createSlider(
    FlySettingsSection,
    "Aceleração",
    1,
    30,
    State.FlyAcceleration,
    function(value)
        State.FlyAcceleration = value
    end,
    {
        Step = 1,
        Formatter = function(value)
            return tostring(math.floor(value))
        end,
    }
)

local FlyDecelerationSlider = createSlider(
    FlySettingsSection,
    "Frenagem",
    1,
    30,
    State.FlyDeceleration,
    function(value)
        State.FlyDeceleration = value
    end,
    {
        Step = 1,
        Formatter = function(value)
            return tostring(math.floor(value))
        end,
    }
)

local FlyTiltSlider = createSlider(
    FlySettingsSection,
    "Inclinação do personagem",
    0,
    35,
    State.FlyTilt,
    function(value)
        State.FlyTilt = value
    end,
    {
        Step = 1,
        Formatter = function(value)
            return tostring(math.floor(value)) .. "°"
        end,
    }
)

local FlyRotationSlider = createSlider(
    FlySettingsSection,
    "Resposta da rotação",
    5,
    50,
    State.FlyRotationResponse,
    function(value)
        State.FlyRotationResponse = value

        if FlyOrientation then
            FlyOrientation.Responsiveness = value
        end
    end,
    {
        Step = 1,
        Formatter = function(value)
            return tostring(math.floor(value))
        end,
    }
)

local FlyTiltResponseSlider = createSlider(
    FlySettingsSection,
    "Suavidade da inclinação",
    2,
    25,
    State.FlyTiltResponse,
    function(value)
        State.FlyTiltResponse = value
    end,
    {
        Step = 1,
        Formatter = function(value)
            return tostring(math.floor(value))
        end,
    }
)

FlyTurboSpeedStatus = createStatus(
    FlySettingsSection,
    "Velocidade horizontal com turbo",
    tostring(math.floor((State.FlySpeed * State.FlyTurboMultiplier) + 0.5)) .. " studs/s"
)

local FlyCameraVerticalToggle = createToggle(
    FlySettingsSection,
    "W/S também sobe e desce pela direção da câmera",
    State.FlyCameraVertical,
    function(value)
        State.FlyCameraVertical = value
    end
)

createButton(FlySettingsSection, "Restaurar configurações padrão", function()
    FlySpeedSlider:Set(80)
    FlyVerticalSlider:Set(1.0)
    FlyTurboSlider:Set(1.8)
    FlyAccelerationSlider:Set(8)
    FlyDecelerationSlider:Set(11)
    FlyTiltSlider:Set(16)
    FlyRotationSlider:Set(28)
    FlyTiltResponseSlider:Set(10)
    FlyCameraVerticalToggle:Set(true)

    notify("Fly", "Configurações padrão restauradas.")
end)


local TeleportSettingsSection = createSection(
    SettingsPage,
    "Configurações de teleporte local",
    "Define onde seu personagem aparece em relação ao jogador selecionado."
)

local GoToOffsetXSlider = createSlider(
    TeleportSettingsSection,
    "Deslocamento lateral",
    -20,
    20,
    State.GoToOffsetX,
    function(value)
        State.GoToOffsetX = value
    end,
    {Step = 1, Formatter = function(value) return tostring(value) end}
)

local GoToOffsetYSlider = createSlider(
    TeleportSettingsSection,
    "Altura",
    -10,
    20,
    State.GoToOffsetY,
    function(value)
        State.GoToOffsetY = value
    end,
    {Step = 1, Formatter = function(value) return tostring(value) end}
)

local GoToOffsetZSlider = createSlider(
    TeleportSettingsSection,
    "Frente/trás",
    -20,
    20,
    State.GoToOffsetZ,
    function(value)
        State.GoToOffsetZ = value
    end,
    {Step = 1, Formatter = function(value) return tostring(value) end}
)

local TeleportFaceTargetToggle = createToggle(
    TeleportSettingsSection,
    "Olhar para o jogador após teleportar",
    State.TeleportFaceTarget,
    function(value)
        State.TeleportFaceTarget = value
    end
)

createButton(TeleportSettingsSection, "Restaurar teleporte padrão", function()
    GoToOffsetXSlider:Set(0)
    GoToOffsetYSlider:Set(1)
    GoToOffsetZSlider:Set(4)
    TeleportFaceTargetToggle:Set(true)
    notify("Teleporte", "Configurações padrão restauradas.")
end)

local ResetSection = createSection(
    SettingsPage,
    "Desativação rápida",
    "Desliga todos os recursos ativos."
)

createButton(ResetSection, "Desativar todos os recursos", function()
    GodToggle:Set(false)
    SpeedToggle:Set(false)
    JumpToggle:Set(false)
    NoclipToggle:Set(false)
    FlyToggle:Set(false)
    ESPToggle:Set(false)
    AimToggle:Set(false)

    CurrentTarget = nil
    restoreCollisions()
    stopFly()
    removeAllESP()
    stopSpectating()

    notify("Painel resetado", "Todos os recursos foram desativados.")
end)

-- Círculo do FOV criado após os controles para ficar acima da interface.
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "AimFOV"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(State.AimFOV * 2, State.AimFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.ZIndex = 100
FOVCircle.Parent = ScreenGui
createCorner(FOVCircle, 999)
createStroke(FOVCircle, Colors.AccentLight, 0.25, 1)

--============================================================--
-- JANELA: ARRASTAR, MINIMIZAR E ABRIR
--============================================================--

local draggingWindow = false
local dragStart
local startPosition

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

local PanelVisible = true
local Minimized = false

local MobilePanelButton = Instance.new("TextButton")
MobilePanelButton.Name = "MobileAdminToggle"
MobilePanelButton.AnchorPoint = Vector2.new(1, 0)
MobilePanelButton.Position = UDim2.new(1, -16, 0, 68)
MobilePanelButton.Size = UDim2.fromOffset(56, 56)
MobilePanelButton.BackgroundColor3 = Colors.Card
MobilePanelButton.BackgroundTransparency = 0.06
MobilePanelButton.BorderSizePixel = 0
MobilePanelButton.Text = ""
MobilePanelButton.AutoButtonColor = false
MobilePanelButton.Visible = UserInputService.TouchEnabled
MobilePanelButton.ZIndex = 220
MobilePanelButton.Parent = ScreenGui
createCorner(MobilePanelButton, 16)
createStroke(MobilePanelButton, Colors.AccentLight, 0.12, 1.5)

local MobilePanelLogo = Instance.new("TextLabel")
MobilePanelLogo.Position = UDim2.new(0, 0, 0, 5)
MobilePanelLogo.Size = UDim2.new(1, 0, 0, 30)
MobilePanelLogo.BackgroundTransparency = 1
MobilePanelLogo.Text = string.sub(BRAND_NAME, 1, 1)
MobilePanelLogo.TextColor3 = Colors.AccentLight
MobilePanelLogo.Font = Enum.Font.GothamBold
MobilePanelLogo.TextSize = 22
MobilePanelLogo.ZIndex = MobilePanelButton.ZIndex + 1
MobilePanelLogo.Parent = MobilePanelButton

local MobilePanelCaption = Instance.new("TextLabel")
MobilePanelCaption.Position = UDim2.new(0, 0, 1, -20)
MobilePanelCaption.Size = UDim2.new(1, 0, 0, 14)
MobilePanelCaption.BackgroundTransparency = 1
MobilePanelCaption.Text = "ADMIN"
MobilePanelCaption.TextColor3 = Colors.MutedText
MobilePanelCaption.Font = Enum.Font.GothamBold
MobilePanelCaption.TextSize = 8
MobilePanelCaption.ZIndex = MobilePanelButton.ZIndex + 1
MobilePanelCaption.Parent = MobilePanelButton

local function setPanelVisible(value)
    PanelVisible = value
    Main.Visible = value
    Shadow.Visible = value

    if MobilePanelButton.Visible then
        tween(MobilePanelButton, 0.12, {
            BackgroundColor3 = value and Colors.Card or Colors.Accent,
            BackgroundTransparency = value and 0.06 or 0,
        })
        MobilePanelLogo.TextColor3 = value and Colors.AccentLight or Colors.Text
        MobilePanelCaption.TextColor3 = value and Colors.MutedText or Colors.Text
    end
end

MobilePanelButton.MouseButton1Click:Connect(function()
    setPanelVisible(not PanelVisible)
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    if Minimized then
        Sidebar.Visible = false
        Content.Visible = false
        MinimizeButton.Text = "+"

        tween(Main, 0.2, {Size = UDim2.fromOffset(680, 56)})
        tween(Shadow, 0.2, {Size = UDim2.fromOffset(720, 96)})
    else
        MinimizeButton.Text = "—"
        tween(Main, 0.2, {Size = UDim2.fromOffset(680, 450)})
        tween(Shadow, 0.2, {Size = UDim2.fromOffset(720, 490)})

        task.delay(0.08, function()
            if not Minimized then
                Sidebar.Visible = true
                Content.Visible = true
            end
        end)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    setPanelVisible(false)
end)

--============================================================--
-- INPUT GLOBAL
--============================================================--

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- O botão direito é tratado antes do gameProcessed porque o sistema de câmera
    -- do Roblox pode marcar esse input como processado.
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimHolding = true
    end

    if gameProcessed then
        return
    end

    if input.KeyCode == OPEN_KEY then
        setPanelVisible(not PanelVisible)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if ActiveSlider
        and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
        ActiveSlider:UpdateFromX(input.Position.X)
    end

    if draggingWindow
        and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

        Shadow.Position = Main.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        ActiveSlider = nil
        draggingWindow = false
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimHolding = false
        CurrentTarget = nil
    end
end)

--============================================================--
-- JOGADORES E RESPAWN
--============================================================--

local function connectPlayer(player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)

        if State.ESP then
            createESP(player)
        end

        if State.SpectatingUserId == player.UserId then
            local targetHumanoid = character:FindFirstChildOfClass("Humanoid")
            Camera = Workspace.CurrentCamera

            if Camera and targetHumanoid then
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CameraSubject = targetHumanoid
            end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    connectPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    PlayerCountStatus.Text = tostring(#Players:GetPlayers())
    task.defer(refreshPlayerSelector)
    connectPlayer(player)

    if State.ESP then
        task.delay(0.7, function()
            createESP(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    PlayerCountStatus.Text = tostring(math.max(0, #Players:GetPlayers() - 1))
    task.defer(refreshPlayerSelector)

    if CurrentTarget == player then
        CurrentTarget = nil
    end

    if State.SpectatingUserId == player.UserId then
        stopSpectating()
        notify("Espectador", "O jogador observado saiu do servidor.")
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.2)
    bindCharacter(character)

    if not State.SpectatingUserId then
        stopSpectating()
    end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCameraViewport)

--============================================================--
-- LOOPS
--============================================================--

RunService.Stepped:Connect(function()
    if not Character or not Character.Parent or not Humanoid or not RootPart then
        return
    end

    if State.Noclip then
        updateNoclip()
    end

    if State.Speed and Humanoid.WalkSpeed ~= State.WalkSpeed then
        Humanoid.WalkSpeed = State.WalkSpeed
    end

    if State.Jump then
        Humanoid.UseJumpPower = true
        if Humanoid.JumpPower ~= State.JumpPower then
            Humanoid.JumpPower = State.JumpPower
        end
    end

    if State.GodMode and not GodHealthGuard then
        Humanoid.BreakJointsOnDeath = false

        if Humanoid.MaxHealth < 1e9 then
            Humanoid.MaxHealth = 1e9
        end

        if Humanoid.Health < Humanoid.MaxHealth then
            GodHealthGuard = true
            Humanoid.Health = Humanoid.MaxHealth
            GodHealthGuard = false
        end
    end
end)

local lastESPUpdate = 0

RunService:BindToRenderStep(
    RENDER_BINDING,
    Enum.RenderPriority.Camera.Value + 1,
    function(deltaTime)
        Camera = Workspace.CurrentCamera
        if not Camera then
            return
        end

        updateFly(deltaTime)

        local mousePosition = getMouseViewportPosition()
        FOVCircle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
        FOVCircle.Size = UDim2.fromOffset(State.AimFOV * 2, State.AimFOV * 2)
        FOVCircle.Visible = State.Aim

        if State.Aim and AimHolding and not UserInputService:GetFocusedTextBox() then
            if not targetStillValid(CurrentTarget) then
                CurrentTarget = findClosestTarget()
            end

            if CurrentTarget and CurrentTarget.Character then
                local targetPart = getAimPart(CurrentTarget.Character)

                if targetPart then
                    local targetPosition = targetPart.Position
                        + (targetPart.AssemblyLinearVelocity * State.AimPrediction)

                    local desiredCFrame = CFrame.lookAt(
                        Camera.CFrame.Position,
                        targetPosition
                    )

                    local alpha
                    if State.AimSmoothness <= 1 then
                        alpha = 1
                    else
                        alpha = 1 - math.exp(
                            -deltaTime * (42 / State.AimSmoothness)
                        )
                    end

                    Camera.CFrame = Camera.CFrame:Lerp(
                        desiredCFrame,
                        math.clamp(alpha, 0.02, 1)
                    )
                end
            end
        else
            CurrentTarget = nil
        end

        local now = os.clock()
        if now - lastESPUpdate >= 0.08 then
            lastESPUpdate = now
            updateESP()
        end
    end
)

--============================================================--
-- INICIALIZAÇÃO
--============================================================--

selectTab("Jogador")

notify(
    BRAND_NAME .. " carregado",
    UserInputService.TouchEnabled
        and "Use o botão R para abrir. Nenhum Script de servidor é necessário."
        or "Right Shift abre o painel. Nenhum Script de servidor é necessário.",
    5
)
