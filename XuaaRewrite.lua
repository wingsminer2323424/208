-- Defines
local OrbitingLibrary                           = loadstring(game:HttpGet("https://raw.githubusercontent.com/firm0001/uwu/main/dependencies/orbit.lua"))()
local ReplicatedStorage                         = game:GetService("ReplicatedStorage")
local RunService                                = game:GetService("RunService")
local Players                                   = game:GetService("Players")
local Workspace                                 = game:GetService("Workspace")
local UserInputService                          = game:GetService("UserInputService")
local StarterGui                                = game:GetService("StarterGui")
local TweenService                              = game:GetService("TweenService")
local HttpService                               = game:GetService("HttpService")
local TeleportService                           = game:GetService("TeleportService")
local VirtualInputManager                       = game:GetService("VirtualInputManager")
local VirtualUser                               = game:GetService("VirtualUser")
local LocalPlayer                               = game.Players.LocalPlayer

local Mouse, CurrentCamera                      = LocalPlayer:GetMouse(), Workspace.CurrentCamera
local FOVCircle                                 = Drawing.new("Circle")
local EasingStyles                              = Enum.EasingStyle
local Inp                                       = loadstring(game:HttpGet('https://pastebin.com/raw/dYzQv3d8'))()
getgenv().AntiLockEnabled                       = false
local function check()
    return ReplicatedStorage:FindFirstChild("MainEvent") or ReplicatedStorage:FindFirstChild("MAINEVENT")
end

local ME = check()
local EventN = nil
if ME then
    if ME.Name == "MAINEVENT" then
        EventN              = "STOMP"
    else
        EventN              = "Stomp"
    end
end
local task = task or coroutine
FOVCircle.Visible = false
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and FOVCircle.Visible then
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + guiInset.Y)
    end
end)
local TargetPlayer, TargetAimEnabled, SilentAimEnabled, CamlockToggle = nil, false, false, false
local SelectedPart = "HumanoidRootPart"
local ResolverEnabled = false
local repo = 'https://raw.githubusercontent.com/synfulangel/Linoria/main/'
local Library                       = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager                  = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager                   = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local AkaliNotif                    = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/InformantV1/main/libraries/Akali.lua"))()
local Akali                         = AkaliNotif.Notify
local Settings = {
Accent = Color3.fromHex("#6E699B"),
Font = Enum.Font.SourceSans,
IsBackgroundTransparent = true,
Rounded = false,
Dim = false,

ItemColor = Color3.fromRGB(30, 30, 30),
BorderColor = Color3.fromRGB(45, 45, 45),
MinSize = Vector2.new(680, 560),
MaxSize = Vector2.new(1212, 1212)
}

local Menu = {}
local Tabs = {}
local Items = {}
local EventObjects = {} -- For updating items on menu property change
local Notifications = {}

local Scaling = {True = false, Origin = nil, Size = nil}
local Dragging = {Gui = nil, True = false}
local Draggables = {}
local ToolTip = {Enabled = false, Content = "", Item = nil}

local HotkeyRemoveKey = Enum.KeyCode.RightControl
local Selected = {
Frame = nil,
Item = nil,
Offset = UDim2.new(),
Follow = false
}
local SelectedTab
local SelectedTabLines = {}


local wait = task.wait
local delay = task.delay
local spawn = task.spawn
local protect_gui = function(Gui, Parent)
if gethui and syn and syn.protect_gui then 
    Gui.Parent = gethui() 
elseif not gethui and syn and syn.protect_gui then 
    syn.protect_gui(Gui)
    Gui.Parent = Parent 
else 
    Gui.Parent = Parent 
end
end

local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")


local __Menu = {}
setmetatable(Menu, {
__index = function(self, Key) return __Menu[Key] end,
__newindex = function(self, Key, Value)
    __Menu[Key] = Value
    
    if Key == "Hue" or Key == "ScreenSize" then return end

    for _, Object in pairs(EventObjects) do Object:Update() end
    for _, Notification in pairs(Notifications) do Notification:Update() end
end
})


Menu.Accent = Settings.Accent
Menu.Font = Settings.Font
Menu.IsBackgroundTransparent = Settings.IsBackgroundTransparent
Menu.Rounded = Settings.IsRounded
Menu.Dim = Settings.IsDim
Menu.ItemColor = Settings.ItemColor
Menu.BorderColor = Settings.BorderColor
Menu.MinSize = Settings.MinSize
Menu.MaxSize = Settings.MaxSize

Menu.Hue = 0
Menu.IsVisible = false
Menu.ScreenSize = Vector2.new()


local function AddEventListener(self: GuiObject, Update: any)
table.insert(EventObjects, {
    self = self,
    Update = Update
})
end


local function CreateCorner(Parent: Instance, Pixels: number): UICorner
local UICorner = Instance.new("UICorner")
UICorner.Name = "Corner"
UICorner.Parent = Parent
return UICorner
end


local function CreateStroke(Parent: Instance, Color: Color3, Thickness: number, Transparency: number): UIStroke
local UIStroke = Instance.new("UIStroke")
UIStroke.Name = "Stroke"
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
UIStroke.Color = Color or Color3.new()
UIStroke.Thickness = Thickness or 1
UIStroke.Transparency = Transparency or 0
UIStroke.Enabled = true
UIStroke.Parent = Parent
return UIStroke
end 


local function CreateLine(Parent: Instance, Size: UDim2, Position: UDim2, Color: Color3): Frame
local Line = Instance.new("Frame")
Line.Name = "Line"
Line.BackgroundColor3 = typeof(Color) == "Color3" and Color or Menu.Accent
Line.BorderSizePixel = 0
Line.Size = Size or UDim2.new(1, 0, 0, 1)
Line.Position = Position or UDim2.new()
Line.Parent = Parent

if Line.BackgroundColor3 == Menu.Accent then
    AddEventListener(Line, function() Line.BackgroundColor3 = Menu.Accent end)
end

return Line
end


local function CreateLabel(Parent: Instance, Name: string, Text: string, Size: UDim2, Position: UDim2): TextLabel
local Label = Instance.new("TextLabel")
Label.Name = Name
Label.BackgroundTransparency = 1
Label.Size = Size or UDim2.new(1, 0, 0, 15)
Label.Position = Position or UDim2.new()
Label.Font = Enum.Font.SourceSans
Label.Text = Text or ""
Label.TextColor3 = Color3.new(1, 1, 1)
Label.TextSize = 14
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.Parent = Parent
return Label
end


local function UpdateSelected(Frame: Instance, Item: Item, Offset: UDim2)
local Selected_Frame = Selected.Frame
if Selected_Frame then
    Selected_Frame.Visible = false
    Selected_Frame.Parent = nil
end

Selected = {}

if Frame then
    if Selected_Frame == Frame then return end
    Selected = {
        Frame = Frame,
        Item = Item,
        Offset = Offset
    }

    Frame.ZIndex = 3
    Frame.Visible = true
    Frame.Parent = Menu.Screen
end
end


local function SetDraggable(self: GuiObject)
table.insert(Draggables, self)
local DragOrigin
local GuiOrigin

self.InputBegan:Connect(function(Input: InputObject, Process: boolean)
    if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        for _, v in ipairs(Draggables) do
            v.ZIndex = 1
        end
        self.ZIndex = 2

        Dragging = {Gui = self, True = true}
        DragOrigin = Vector2.new(Input.Position.X, Input.Position.Y)
        GuiOrigin = self.Position
    end
end)

UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
    if Dragging.Gui ~= self then return end
    if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
        Dragging = {Gui = nil, True = false}
        return
    end
    if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
        local Delta = Vector2.new(Input.Position.X, Input.Position.Y) - DragOrigin
        local ScreenSize = Menu.ScreenSize

        local ScaleX = (ScreenSize.X * GuiOrigin.X.Scale)
        local ScaleY = (ScreenSize.Y * GuiOrigin.Y.Scale)
        local OffsetX = math.clamp(GuiOrigin.X.Offset + Delta.X + ScaleX,   0, ScreenSize.X - self.AbsoluteSize.X)
        local OffsetY = math.clamp(GuiOrigin.Y.Offset + Delta.Y + ScaleY, -36, ScreenSize.Y - self.AbsoluteSize.Y)
        
        local Position = UDim2.fromOffset(OffsetX, OffsetY)
        self.Position = Position
    end
end)
end


Menu.Screen = Instance.new("ScreenGui")
Menu.Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protect_gui(Menu.Screen, CoreGui)
Menu.ScreenSize = Menu.Screen.AbsoluteSize

local Menu_Frame = Instance.new("Frame")
local MenuScaler_Button = Instance.new("TextButton")
local Title_Label = Instance.new("TextLabel")
local Icon_Image = Instance.new("ImageLabel")
local TabHandler_Frame = Instance.new("Frame")
local TabIndex_Frame = Instance.new("Frame")
local Tabs_Frame = Instance.new("Frame")

local Notifications_Frame = Instance.new("Frame")
local MenuDim_Frame = Instance.new("Frame")
local ToolTip_Label = Instance.new("TextLabel")
local Modal = Instance.new("TextButton")

Menu_Frame.Name = "Menu"
Menu_Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Menu_Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Menu_Frame.BorderMode = Enum.BorderMode.Inset
Menu_Frame.Position = UDim2.new(0.5, -250, 0.5, -275)
Menu_Frame.Size = UDim2.new(0, 500, 0, 550)
Menu_Frame.Visible = false
Menu_Frame.Parent = Menu.Screen
CreateStroke(Menu_Frame, Color3.new(), 2)
CreateLine(Menu_Frame, UDim2.new(1, -8, 0, 1), UDim2.new(0, 4, 0, 15))
SetDraggable(Menu_Frame)

MenuScaler_Button.Name = "MenuScaler"
MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MenuScaler_Button.BorderColor3 = Color3.fromRGB(40, 40, 40)
MenuScaler_Button.BorderSizePixel = 0
MenuScaler_Button.Position = UDim2.new(1, -15, 1, -15)
MenuScaler_Button.Size = UDim2.fromOffset(15, 15)
MenuScaler_Button.Font = Enum.Font.SourceSans
MenuScaler_Button.Text = ""
MenuScaler_Button.TextColor3 = Color3.new(1, 1, 1)
MenuScaler_Button.TextSize = 14
MenuScaler_Button.AutoButtonColor = false
MenuScaler_Button.Parent = Menu_Frame
MenuScaler_Button.InputBegan:Connect(function(Input, Process)
if Process then return end
if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
    UpdateSelected()
    Scaling = {
        True = true,
        Origin = Vector2.new(Input.Position.X, Input.Position.Y),
        Size = Menu_Frame.AbsoluteSize - Vector2.new(0, 36)
    }
end
end)
MenuScaler_Button.InputEnded:Connect(function(Input, Process)
if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
    UpdateSelected()
    Scaling = {
        True = false,
        Origin = nil,
        Size = nil
    }
end
end)

Icon_Image.Name = "Icon"
Icon_Image.BackgroundTransparency = 1
Icon_Image.Position = UDim2.new(0, 5, 0, 0)
Icon_Image.Size = UDim2.fromOffset(15, 15)
Icon_Image.Image = "rbxassetid://"
Icon_Image.Visible = false
Icon_Image.Parent = Menu_Frame

Title_Label.Name = "Title"
Title_Label.BackgroundTransparency = 1
Title_Label.Position = UDim2.new(0, 5, 0, 0)
Title_Label.Size = UDim2.new(1, -10, 0, 15)
Title_Label.Font = Enum.Font.SourceSans
Title_Label.Text = ""
Title_Label.TextColor3 = Color3.new(1, 1, 1)
Title_Label.TextSize = 14
Title_Label.TextXAlignment = Enum.TextXAlignment.Left
Title_Label.RichText = true
Title_Label.Parent = Menu_Frame

TabHandler_Frame.Name = "TabHandler"
TabHandler_Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TabHandler_Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
TabHandler_Frame.BorderMode = Enum.BorderMode.Inset
TabHandler_Frame.Position = UDim2.new(0, 4, 0, 19)
TabHandler_Frame.Size = UDim2.new(1, -8, 1, -25)
TabHandler_Frame.Parent = Menu_Frame
CreateStroke(TabHandler_Frame, Color3.new(), 2)

TabIndex_Frame.Name = "TabIndex"
TabIndex_Frame.BackgroundTransparency = 1
TabIndex_Frame.Position = UDim2.new(0, 1, 0, 1)
TabIndex_Frame.Size = UDim2.new(1, -2, 0, 20)
TabIndex_Frame.Parent = TabHandler_Frame

Tabs_Frame.Name = "Tabs"
Tabs_Frame.BackgroundTransparency = 1
Tabs_Frame.Position = UDim2.new(0, 1, 0, 26)
Tabs_Frame.Size = UDim2.new(1, -2, 1, -25)
Tabs_Frame.Parent = TabHandler_Frame

Notifications_Frame.Name = "Notifications"
Notifications_Frame.BackgroundTransparency = 1
Notifications_Frame.Size = UDim2.new(1, 0, 1, 36)
Notifications_Frame.Position = UDim2.fromOffset(0, -36)
Notifications_Frame.ZIndex = 5
Notifications_Frame.Parent = Menu.Screen

ToolTip_Label.Name = "ToolTip"
ToolTip_Label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToolTip_Label.BorderColor3 = Menu.BorderColor
ToolTip_Label.BorderMode = Enum.BorderMode.Inset
ToolTip_Label.AutomaticSize = Enum.AutomaticSize.XY
ToolTip_Label.Size = UDim2.fromOffset(0, 0, 0, 15)
ToolTip_Label.Text = ""
ToolTip_Label.TextSize = 14
ToolTip_Label.Font = Enum.Font.SourceSans
ToolTip_Label.TextColor3 = Color3.new(1, 1, 1)
ToolTip_Label.ZIndex = 5
ToolTip_Label.Visible = false
ToolTip_Label.Parent = Menu.Screen
CreateStroke(ToolTip_Label, Color3.new(), 1)
AddEventListener(ToolTip_Label, function()
ToolTip_Label.BorderColor3 = Menu.BorderColor
end)

Modal.Name = "Modal"
Modal.BackgroundTransparency = 1
Modal.Modal = true
Modal.Text = ""
Modal.Parent = Menu_Frame


--SelectedTabLines.Top = CreateLine(nil, UDim2.new(1, 0, 0, 1), UDim2.new())
SelectedTabLines.Left = CreateLine(nil, UDim2.new(0, 1, 1, 0), UDim2.new(), Color3.new())
SelectedTabLines.Right = CreateLine(nil, UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), Color3.new())
SelectedTabLines.Bottom = CreateLine(TabIndex_Frame, UDim2.new(), UDim2.new(0, 0, 1, 0), Color3.new())
SelectedTabLines.Bottom2 = CreateLine(TabIndex_Frame, UDim2.new(), UDim2.new(), Color3.new())


local function GetDictionaryLength(Dictionary: table)
local Length = 0
for _ in pairs(Dictionary) do
    Length += 1
end
return Length
end


local function UpdateSelectedTabLines(Tab: Tab)
if not Tab then return end

if (Tab.Button.AbsolutePosition.X > Tab.self.AbsolutePosition.X) then
    SelectedTabLines.Left.Visible = true
else
    SelectedTabLines.Left.Visible = false
end

if (Tab.Button.AbsolutePosition.X + Tab.Button.AbsoluteSize.X < Tab.self.AbsolutePosition.X + Tab.self.AbsoluteSize.X) then
    SelectedTabLines.Right.Visible = true
else
    SelectedTabLines.Right.Visible = false
end

--SelectedTabLines.Top.Parent = Tab.Button
SelectedTabLines.Left.Parent = Tab.Button
SelectedTabLines.Right.Parent = Tab.Button

local FRAME_POSITION = Tab.self.AbsolutePosition
local BUTTON_POSITION = Tab.Button.AbsolutePosition
local BUTTON_SIZE = Tab.Button.AbsoluteSize
local LENGTH = BUTTON_POSITION.X - FRAME_POSITION.X
local OFFSET = (BUTTON_POSITION.X + BUTTON_SIZE.X) - FRAME_POSITION.X

SelectedTabLines.Bottom.Size = UDim2.new(0, LENGTH + 1, 0, 1)
SelectedTabLines.Bottom2.Size = UDim2.new(1, -OFFSET, 0, 1)
SelectedTabLines.Bottom2.Position = UDim2.new(0, OFFSET, 1, 0)
end


local function UpdateTabs()
for _, Tab in pairs(Tabs) do
    Tab.Button.Size = UDim2.new(1 / GetDictionaryLength(Tabs), 0, 1, 0)
    Tab.Button.Position = UDim2.new((1 / GetDictionaryLength(Tabs)) * (Tab.Index - 1), 0, 0, 0)
end
UpdateSelectedTabLines(SelectedTab)
end


local function GetTab(Tab_Name: string): Tab
assert(Tab_Name, "NO TAB_NAME GIVEN")
return Tabs[Tab_Name]
end

local function ChangeTab(Tab_Name: string)
assert(Tabs[Tab_Name], "Tab \"" .. tostring(Tab_Name) .. "\" does not exist!")
for _, Tab in pairs(Tabs) do
    Tab.self.Visible = false
    Tab.Button.BackgroundColor3 = Menu.ItemColor
    Tab.Button.TextColor3 = Color3.fromRGB(205, 205, 205)
end
local Tab = GetTab(Tab_Name)
Tab.self.Visible = true
Tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Tab.Button.TextColor3 = Color3.new(1, 1, 1)

SelectedTab = Tab
UpdateSelected()
UpdateSelectedTabLines(Tab)
end


local function GetContainer(Tab_Name: string, Container_Name: string): Container
assert(Tab_Name, "NO TAB_NAME GIVEN")
assert(Container_Name, "NO CONTAINER NAME GIVEN")
return GetTab(Tab_Name)[Container_Name]
end


local function CheckItemIndex(Item_Index: number, Method: string)
assert(typeof(Item_Index) == "number", "invalid argument #1 to '" .. Method .. "' (number expected, got " .. typeof(Item_Index) .. ")")
assert(Item_Index <= #Items and Item_Index > 0, "invalid argument #1 to '" .. Method .. "' (index out of range")
end


function Menu:GetItem(Index: number): Item
CheckItemIndex(Index, "GetItem")
return Items[Index]
end


function Menu:FindItem(Tab_Name: string, Container_Name: string, Class_Name: string, Name: string): Item
local Result
for Index, Item in ipairs(Items) do
    if Item.Tab == Tab_Name and Item.Container == Container_Name then
        if Item.Name == Name and (Item.Class == Class_Name) then
            Result = Index
            break
        end
    end
end

if Result then
    return Menu:GetItem(Result)
else
    return error("Item " .. tostring(Name) .. " was not found")
end
end


function Menu:SetTitle(Name: string)
Title_Label.Text = tostring(Name)
end


function Menu:SetIcon(Icon: string)
if typeof(Icon) == "string" or typeof(Icon) == "number" then
    Title_Label.Position = UDim2.fromOffset(20, 0)
    Title_Label.Size = UDim2.new(1, -40, 0, 15)
    Icon_Image.Image = "rbxassetid://" .. string.gsub(tostring(Icon), "rbxassetid://", "")
    Icon_Image.Visible = true
else
    Title_Label.Position = UDim2.fromOffset(5, 0)
    Title_Label.Size = UDim2.new(1, -10, 0, 15)
    Icon_Image.Image = ""
    Icon_Image.Visible = false
end
end


function Menu:SetSize(Size: Vector2)
local Size = typeof(Size) == "Vector2" and Size or typeof(Size) == "UDim2" and Vector2.new(Size.X, Size.Y) or Menu.MinSize
local X = Size.X
local Y = Size.Y

if (X > Menu.MinSize.X and X < Menu.MaxSize.X) then
    X = math.clamp(X, Menu.MinSize.X, Menu.MaxSize.X)
end
if (Y > Menu.MinSize.Y and Y < Menu.MaxSize.Y) then
    Y = math.clamp(Y, Menu.MinSize.Y, Menu.MaxSize.Y)
end

Menu_Frame.Size = UDim2.fromOffset(X, Y)
UpdateTabs()
end


function Menu:SetVisible(Visible: boolean)
local IsVisible = typeof(Visible) == "boolean" and Visible
Menu_Frame.Visible = IsVisible
Menu.IsVisible = IsVisible
if IsVisible == false then
    UpdateSelected()
end
end


function Menu:SetTab(Tab_Name: string)
ChangeTab(Tab_Name)
end


-- this function should be private
function Menu:SetToolTip(Enabled: boolean, Content: string, Item: Instance)
ToolTip = {
    Enabled = Enabled,
    Content = Content,
    Item = Item
}

ToolTip_Label.Visible = Enabled
end


function Menu.Line(Parent: Instance, Size: UDim2, Position: UDim2): Line
local Line = {self = CreateLine(Parent, Size, Position)}
Line.Class = "Line"
return Line
end


function Menu.Tab(Tab_Name: string): Tab
assert(Tab_Name and typeof(Tab_Name) == "string", "TAB_NAME REQUIRED")
if Tabs[Tab_Name] then return error("TAB_NAME '" .. tostring(Tab_Name) .. "' ALREADY EXISTS") end
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

local Tab = {self = Frame, Button = Button}
Tab.Class = "Tab"
Tab.Index = GetDictionaryLength(Tabs) + 1


local function CreateSide(Side: string)
    local Frame = Instance.new("ScrollingFrame")
    local ListLayout = Instance.new("UIListLayout")

    Frame.Name = Side
    Frame.Active = true
    Frame.BackgroundTransparency = 1
    Frame.BorderSizePixel = 0
    Frame.Size = Side == "Middle" and UDim2.new(1, -10, 1, -10) or UDim2.new(0.5, -10, 1, -10)
    Frame.Position = (Side == "Left" and UDim2.fromOffset(5, 5)) or (Side == "Right" and UDim2.new(0.5, 5, 0, 5) or Side == "Middle" and UDim2.fromOffset(5, 5))
    Frame.CanvasSize = UDim2.new(0, 0, 0, -10)
    Frame.ScrollBarThickness = 2
    Frame.ScrollBarImageColor3 = Menu.Accent
    Frame.Parent = Tab.self
    AddEventListener(Frame, function()
        Frame.ScrollBarImageColor3 = Menu.Accent
    end)
    Frame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSelected)

    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = Frame
end


Button.Name = "Button"
Button.BackgroundColor3 = Menu.ItemColor
Button.BorderSizePixel = 0
Button.Font = Enum.Font.SourceSans
Button.Text = Tab_Name
Button.TextColor3 = Color3.fromRGB(205, 205, 205)
Button.TextSize = 14
Button.Parent = TabIndex_Frame
AddEventListener(Button, function()
    if Button.TextColor3 == Color3.fromRGB(205, 205, 205) then
        Button.BackgroundColor3 = Menu.ItemColor
    end
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Menu.BorderColor
end)
Button.MouseButton1Click:Connect(function()
    ChangeTab(Tab_Name)
end)

Frame.Name = Tab_Name .. "Tab"
Frame.BackgroundTransparency = 1
Frame.Size = UDim2.new(1, 0, 1, 0)
Frame.Visible = false
Frame.Parent = Tabs_Frame

CreateSide("Middle")
CreateSide("Left")
CreateSide("Right")

Tabs[Tab_Name] = Tab

ChangeTab(Tab_Name)
UpdateTabs()
return Tab
end


function Menu.Container(Tab_Name: string, Container_Name: string, Side: string): Container
local Tab = GetTab(Tab_Name)
assert(typeof(Tab_Name) == "string", "TAB_NAME REQUIRED")
if Tab[Container_Name] then return error("CONTAINER_NAME '" .. tostring(Container_Name) .. "' ALREADY EXISTS") end
local Side = Side or "Left"

local Frame = Instance.new("Frame")
local Label = CreateLabel(Frame, "Title", Container_Name, UDim2.fromOffset(206, 15),  UDim2.fromOffset(5, 0))
local Line = CreateLine(Frame, UDim2.new(1, -10, 0, 1), UDim2.fromOffset(5, 15))

local Container = {self = Frame, Height = 0}
Container.Class = "Container"
Container.Visible = true

function Container:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function Container:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if self.Visible == Visible then return end
    
    Frame.Visible = Visible
    self.Visible = Visible
    self:UpdateSize(Visible and 25 or -25, Frame)
end

function Container:UpdateSize(Height: float, Item: GuiObject)
    self.Height += Height
    Frame.Size += UDim2.fromOffset(0, Height)
    Tab.self[Side].CanvasSize += UDim2.fromOffset(0, Height)

    if Item then
        local ItemY = Item.AbsolutePosition.Y
        if math.sign(Height) == 1 then
            ItemY -= 1
        end

        for _, item in ipairs(Frame:GetChildren()) do
            if (item == Label or item == Line or item == Stroke or Item == item) then continue end -- exlude these
            local item_y = item.AbsolutePosition.Y
            if item_y > ItemY then
                item.Position += UDim2.fromOffset(0, Height)
            end
        end
    end
end

function Container:GetHeight(): number
    return self.Height
end


Frame.Name = "Container"
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderColor3 = Color3.new()
Frame.BorderMode = Enum.BorderMode.Inset
Frame.Size = UDim2.new(1, -6, 0, 0)
Frame.Parent = Tab.self[Side]

Container:UpdateSize(25)
Tab.self[Side].CanvasSize += UDim2.fromOffset(0, 10)
Tab[Container_Name] = Container
return Container
end


function Menu.Label(Tab_Name: string, Container_Name: string, Name: string, ToolTip: string): Label
local Container = GetContainer(Tab_Name, Container_Name)
local GuiLabel = CreateLabel(Container.self, "Label", Name, nil, UDim2.fromOffset(20, Container:GetHeight()))

GuiLabel.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, GuiLabel)
    end
end)
GuiLabel.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

local Label = {self = Label}
Label.Name = Name
Label.Class = "Label"
Label.Index = #Items + 1
Label.Tab = Tab_Name
Label.Container = Container_Name

function Label:SetLabel(Name: string)
    GuiLabel.Text = tostring(Name)
end

function Label:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if GuiLabel.Visible == Visible then return end
    
    GuiLabel.Visible = Visible
    Container:UpdateSize(Visible and 20 or -20, GuiLabel)
end

Container:UpdateSize(20)
table.insert(Items, Label)
return #Items
end


function Menu.Button(Tab_Name: string, Container_Name: string, Name: string, Callback: any, ToolTip: string): Button
local Container = GetContainer(Tab_Name, Container_Name)
local GuiButton = Instance.new("TextButton")

local Button = {self = GuiButton}
Button.Name = Name
Button.Class = "Button"
Button.Tab = Tab_Name
Button.Container = Container_Name
Button.Index = #Items + 1
Button.Callback = typeof(Callback) == "function" and Callback or function() end


function Button:SetLabel(Name: string)
    GuiButton.Text = tostring(Name)
end

function Button:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if GuiButton.Visible == Visible then return end
    
    GuiButton.Visible = Visible
    Container:UpdateSize(Visible and 25 or -25, GuiButton)
end


GuiButton.Name = "Button"
GuiButton.BackgroundColor3 = Menu.ItemColor
GuiButton.BorderColor3 = Menu.BorderColor
GuiButton.BorderMode = Enum.BorderMode.Inset
GuiButton.Position = UDim2.fromOffset(20, Container:GetHeight())
GuiButton.Size = UDim2.new(1, -50, 0, 20)
GuiButton.Font = Enum.Font.SourceSansSemibold
GuiButton.Text = Name
GuiButton.TextColor3 = Color3.new(1, 1, 1)
GuiButton.TextSize = 14
GuiButton.TextTruncate = Enum.TextTruncate.AtEnd
GuiButton.Parent = Container.self
CreateStroke(GuiButton, Color3.new(), 1)
AddEventListener(GuiButton, function()
    GuiButton.BackgroundColor3 = Menu.ItemColor
    GuiButton.BorderColor3 = Menu.BorderColor
end)
GuiButton.MouseButton1Click:Connect(function()
    Button.Callback()
end)
GuiButton.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, GuiButton)
    end
end)
GuiButton.MouseLeave:Connect(function()
    Menu:SetToolTip(false)
end)

Container:UpdateSize(25)
table.insert(Items, Button)
return #Items
end


function Menu.TextBox(Tab_Name: string, Container_Name: string, Name: string, Value: string, Callback: any, ToolTip: string): TextBox
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "TextBox", Name, nil, UDim2.fromOffset(20, Container:GetHeight()))
local GuiTextBox = Instance.new("TextBox")

local TextBox = {self = GuiTextBox}
TextBox.Name = Name
TextBox.Class = "TextBox"
TextBox.Tab = Tab_Name
TextBox.Container = Container_Name
TextBox.Index = #Items + 1
TextBox.Value = typeof(Value) == "string" and Value or ""
TextBox.Callback = typeof(Callback) == "function" and Callback or function() end


function TextBox:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function TextBox:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 45 or -45, Label)
end

function TextBox:GetValue(): string
    return self.Value
end

function TextBox:SetValue(Value: string)
    self.Value = tostring(Value)
    GuiTextBox.Text = self.Value
end


GuiTextBox.Name = "TextBox"
GuiTextBox.BackgroundColor3 = Menu.ItemColor
GuiTextBox.BorderColor3 = Menu.BorderColor
GuiTextBox.BorderMode = Enum.BorderMode.Inset
GuiTextBox.Position = UDim2.fromOffset(0, 20)
GuiTextBox.Size = UDim2.new(1, -50, 0, 20)
GuiTextBox.Font = Enum.Font.SourceSansSemibold
GuiTextBox.Text = TextBox.Value
GuiTextBox.TextColor3 = Color3.new(1, 1, 1)
GuiTextBox.TextSize = 14
GuiTextBox.ClearTextOnFocus = false
GuiTextBox.ClipsDescendants = true
GuiTextBox.Parent = Label
CreateStroke(GuiTextBox, Color3.new(), 1)
AddEventListener(GuiTextBox, function()
    GuiTextBox.BackgroundColor3 = Menu.ItemColor
    GuiTextBox.BorderColor3 = Menu.BorderColor
end)
GuiTextBox.FocusLost:Connect(function()
    TextBox.Value = GuiTextBox.Text
    TextBox.Callback(GuiTextBox.Text)
end)
GuiTextBox.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, GuiTextBox)
    end
end)
GuiTextBox.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Container:UpdateSize(45)
table.insert(Items, TextBox)
return #Items
end


function Menu.CheckBox(Tab_Name: string, Container_Name: string, Name: string, Boolean: boolean, Callback: any, ToolTip: string): CheckBox
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "CheckBox", Name, nil, UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")

local CheckBox = {self = Label}
CheckBox.Name = Name
CheckBox.Class = "CheckBox"
CheckBox.Tab = Tab_Name
CheckBox.Container = Container_Name
CheckBox.Index = #Items + 1
CheckBox.Value = typeof(Boolean) == "boolean" and Boolean or false
CheckBox.Callback = typeof(Callback) == "function" and Callback or function() end


function CheckBox:Update(Value: boolean)
    self.Value = typeof(Value) == "boolean" and Value
    Button.BackgroundColor3 = self.Value and Menu.Accent or Menu.ItemColor
end

function CheckBox:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function CheckBox:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 20 or -20, Label)
end

function CheckBox:GetValue(): boolean
    return self.Value
end

function CheckBox:SetValue(Value: boolean)
    self:Update(Value)
end


Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Button.BackgroundColor3 = Menu.ItemColor
Button.BorderColor3 = Color3.new()
Button.Position = UDim2.fromOffset(-14, 4)
Button.Size = UDim2.fromOffset(8, 8)
Button.Text = ""
Button.Parent = Label
AddEventListener(Button, function()
    Button.BackgroundColor3 = CheckBox.Value and Menu.Accent or Menu.ItemColor
end)
Button.MouseButton1Click:Connect(function()
    CheckBox:Update(not CheckBox.Value)
    CheckBox.Callback(CheckBox.Value)
end)

CheckBox:Update(CheckBox.Value)
Container:UpdateSize(20)
table.insert(Items, CheckBox)
return #Items
end


function Menu.Hotkey(Tab_Name: string, Container_Name: string, Name: string, Key:EnumItem, Callback: any, ToolTip: string): Hotkey
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "Hotkey", Name, nil, UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")
local Selected_Hotkey = Instance.new("Frame")
local HotkeyToggle = Instance.new("TextButton")
local HotkeyHold = Instance.new("TextButton")

local Hotkey = {self = Label}
Hotkey.Name = Name
Hotkey.Class = "Hotkey"
Hotkey.Tab = Tab_Name
Hotkey.Container = Container_Name
Hotkey.Index = #Items + 1
Hotkey.Key = typeof(Key) == "EnumItem" and Key or nil
Hotkey.Callback = typeof(Callback) == "function" and Callback or function() end
Hotkey.Editing = false
Hotkey.Mode = "Toggle"


function Hotkey:Update(Input: EnumItem, Mode: string)
    Button.Text = Input and string.format("[%s]", Input.Name) or "[None]"

    self.Key = Input
    self.Mode = Mode or "Toggle"
    self.Editing = false
end

function Hotkey:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function Hotkey:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 20 or -20, Label)
end

function Hotkey:GetValue(): EnumItem--, string
    return self.Key, self.Mode
end

function Hotkey:SetValue(Key: EnumItem, Mode: string)
    self:Update(Key, Mode)
end


Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Button.Name = "Hotkey"
Button.BackgroundTransparency = 1
Button.Position = UDim2.new(1, -100, 0, 4)
Button.Size = UDim2.fromOffset(75, 8)
Button.Font = Enum.Font.SourceSans
Button.Text = Key and "[" .. Key.Name .. "]" or "[None]"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 12
Button.TextXAlignment = Enum.TextXAlignment.Right
Button.Parent = Label

Selected_Hotkey.Name = "Selected_Hotkey"
Selected_Hotkey.Visible = false
Selected_Hotkey.BackgroundColor3 = Menu.ItemColor
Selected_Hotkey.BorderColor3 = Menu.BorderColor
Selected_Hotkey.Position = UDim2.fromOffset(200, 100)
Selected_Hotkey.Size = UDim2.fromOffset(100, 30)
Selected_Hotkey.Parent = nil
CreateStroke(Selected_Hotkey, Color3.new(), 1)
AddEventListener(Selected_Hotkey, function()
    Selected_Hotkey.BackgroundColor3 = Menu.ItemColor
    Selected_Hotkey.BorderColor3 = Menu.BorderColor
end)

HotkeyToggle.Parent = Selected_Hotkey
HotkeyToggle.BackgroundColor3 = Menu.ItemColor
HotkeyToggle.BorderColor3 = Color3.new()
HotkeyToggle.BorderSizePixel = 0
HotkeyToggle.Position = UDim2.new()
HotkeyToggle.Size = UDim2.new(1, 0, 0, 13)
HotkeyToggle.Font = Enum.Font.SourceSans
HotkeyToggle.Text = "Toggle"
HotkeyToggle.TextColor3 = Menu.Accent
HotkeyToggle.TextSize = 14
AddEventListener(HotkeyToggle, function()
    HotkeyToggle.BackgroundColor3 = Menu.ItemColor
    if Hotkey.Mode == "Toggle" then
        HotkeyToggle.TextColor3 = Menu.Accent
    end
end)
HotkeyToggle.MouseButton1Click:Connect(function()
    Hotkey:Update(Hotkey.Key, "Toggle")
    HotkeyToggle.TextColor3 = Menu.Accent
    HotkeyHold.TextColor3 = Color3.new(1, 1, 1)
    UpdateSelected()
    Hotkey.Callback(Hotkey.Key, Hotkey.Mode)
end)

HotkeyHold.Parent = Selected_Hotkey
HotkeyHold.BackgroundColor3 = Menu.ItemColor
HotkeyHold.BorderColor3 = Color3.new()
HotkeyHold.BorderSizePixel = 0
HotkeyHold.Position = UDim2.new(0, 0, 0, 15)
HotkeyHold.Size = UDim2.new(1, 0, 0, 13)
HotkeyHold.Font = Enum.Font.SourceSans
HotkeyHold.Text = "Hold"
HotkeyHold.TextColor3 = Color3.new(1, 1, 1)
HotkeyHold.TextSize = 14
AddEventListener(HotkeyHold, function()
    HotkeyHold.BackgroundColor3 = Menu.ItemColor
    if Hotkey.Mode == "Hold" then
        HotkeyHold.TextColor3 = Menu.Accent
    end
end)
HotkeyHold.MouseButton1Click:Connect(function()
    Hotkey:Update(Hotkey.Key, "Hold")
    HotkeyHold.TextColor3 = Menu.Accent
    HotkeyToggle.TextColor3 = Color3.new(1, 1, 1)
    UpdateSelected()
    Hotkey.Callback(Hotkey.Key, Hotkey.Mode)
end)

Button.MouseButton1Click:Connect(function()
    Button.Text = "..."
    Hotkey.Editing = true
    if UserInput:IsKeyDown(HotkeyRemoveKey) and Key ~= HotkeyRemoveKey then
        Hotkey:Update()
        Hotkey.Callback(nil, Hotkey.Mode)
    end
end)
Button.MouseButton2Click:Connect(function()
    UpdateSelected(Selected_Hotkey, Button, UDim2.fromOffset(100, 0))
end)

UserInput.InputBegan:Connect(function(Input)
    if Hotkey.Editing then
        local Key = Input.KeyCode
        if Key == Enum.KeyCode.Unknown then
            local InputType = Input.UserInputType
            Hotkey:Update(InputType)
            Hotkey.Callback(InputType, Hotkey.Mode)
        else
            Hotkey:Update(Key)
            Hotkey.Callback(Key, Hotkey.Mode)
        end
    end
end)

Container:UpdateSize(20)
table.insert(Items, Hotkey)
return #Items
end


function Menu.Slider(Tab_Name: string, Container_Name: string, Name: string, Min: number, Max: number, Value: number, Unit: string, Scale: number, Callback: any, ToolTip: string): Slider
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "Slider", Name, UDim2.new(1, -10, 0, 15), UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")
local ValueBar = Instance.new("TextLabel")
local ValueBox = Instance.new("TextBox")
local ValueLabel = Instance.new("TextLabel")

local Slider = {}
Slider.Name = Name
Slider.Class = "Slider"
Slider.Tab = Tab_Name
Slider.Container = Container_Name
Slider.Index = #Items + 1
Slider.Min = typeof(Min) == "number" and math.clamp(Min, Min, Max) or 0
Slider.Max = typeof(Max) == "number" and Max or 100
Slider.Value = typeof(Value) == "number" and Value or 100
Slider.Unit = typeof(Unit) == "string" and Unit or ""
Slider.Scale = typeof(Scale) == "number" and Scale or 0
Slider.Callback = typeof(Callback) == "function" and Callback or function() end


local function UpdateSlider(Percentage: number)
    local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
    local Value = Slider.Min + ((Slider.Max - Slider.Min) * Percentage)
    local Scale = (10 ^ Slider.Scale)
    Slider.Value = math.round(Value * Scale) / Scale

    ValueBar.Size = UDim2.new(Percentage, 0, 0, 5)
    ValueBox.Text = "[" .. Slider.Value .. "]"
    ValueLabel.Text = Slider.Value .. Slider.Unit
end


function Slider:Update(Percentage: number)
    UpdateSlider(Percentage)
end

function Slider:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function Slider:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 30 or -30, Label)
end

function Slider:GetValue(): number
    return self.Value
end

function Slider:SetValue(Value: number)
    self.Value = typeof(Value) == "number" and math.clamp(Value, self.Min, self.Max) or self.Min
    local Percentage = (self.Value - self.Min) / (self.Max - self.Min)
    self:Update(Percentage)
end

Slider.self = Label

Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    Menu:SetToolTip(false)
end)

Button.Name = "Slider"
Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Button.BorderColor3 = Color3.new()
Button.Position = UDim2.fromOffset(0, 20)
Button.Size = UDim2.new(1, -40, 0, 5)
Button.Text = ""
Button.AutoButtonColor = false
Button.Parent = Label

ValueBar.Name = "ValueBar"
ValueBar.BackgroundColor3 = Menu.Accent
ValueBar.BorderSizePixel = 0
ValueBar.Size = UDim2.fromScale(1, 1)
ValueBar.Text = ""
ValueBar.Parent = Button
AddEventListener(ValueBar, function()
    ValueBar.BackgroundColor3 = Menu.Accent
end)

ValueBox.Name = "ValueBox"
ValueBox.BackgroundTransparency = 1
ValueBox.Position = UDim2.new(1, -65, 0, 5)
ValueBox.Size = UDim2.fromOffset(50, 10)
ValueBox.Font = Enum.Font.SourceSans
ValueBox.Text = ""
ValueBox.TextColor3 = Color3.new(1, 1, 1)
ValueBox.TextSize = 12
ValueBox.TextXAlignment = Enum.TextXAlignment.Right
ValueBox.ClipsDescendants = true
ValueBox.Parent = Label
ValueBox.FocusLost:Connect(function()
    Slider.Value = tonumber(ValueBox.Text) or 0
    local Percentage = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
    Slider:Update(Percentage)
    Slider.Callback(Slider.Value)
end)

ValueLabel.Name = "ValueLabel"
ValueLabel.BackgroundTransparency = 1
ValueLabel.Position = UDim2.new(1, 0, 0, 2)
ValueLabel.Size = UDim2.new(0, 0, 1, 0)
ValueLabel.Font = Enum.Font.SourceSansBold
ValueLabel.Text = ""
ValueLabel.TextColor3 = Color3.new(1, 1, 1)
ValueLabel.TextSize = 14
ValueLabel.Parent = ValueBar

Button.InputBegan:Connect(function(Input: InputObject, Process: boolean)
    if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = {Gui = Button, True = true}
        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Percentage = (InputPosition - Button.AbsolutePosition) / Button.AbsoluteSize
        Slider:Update(Percentage.X)
        Slider.Callback(Slider.Value)
    end
end)

UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
    if Dragging.Gui ~= Button then return end
    if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
        Dragging = {Gui = nil, True = false}
        return
    end
    if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Percentage = (InputPosition - Button.AbsolutePosition) / Button.AbsoluteSize
        Slider:Update(Percentage.X)
        Slider.Callback(Slider.Value)
    end
end)


Slider:SetValue(Slider.Value)
Container:UpdateSize(30)
table.insert(Items, Slider)
return #Items
end


function Menu.ColorPicker(Tab_Name: string, Container_Name: string, Name: string, Color: Color3, Alpha: number, Callback: any, ToolTip: string): ColorPicker
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "ColorPicker", Name, UDim2.new(1, -10, 0, 15), UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")
local Selected_ColorPicker = Instance.new("Frame")
local HexBox = Instance.new("TextBox")
local Saturation = Instance.new("ImageButton")
local Alpha = Instance.new("ImageButton")
local Hue = Instance.new("ImageButton")
local SaturationCursor = Instance.new("Frame")
local AlphaCursor = Instance.new("Frame")
local HueCursor = Instance.new("Frame")
local CopyButton = Instance.new("TextButton") -- rbxassetid://9090721920
local PasteButton = Instance.new("TextButton") -- rbxassetid://9090721063
local AlphaColorGradient = Instance.new("UIGradient")

local ColorPicker = {self = Label}
ColorPicker.Name = Name
ColorPicker.Tab = Tab_Name
ColorPicker.Class = "ColorPicker"
ColorPicker.Container = Container_Name
ColorPicker.Index = #Items + 1
ColorPicker.Color = typeof(Color) == "Color3" and Color or Color3.new(1, 1, 1)
ColorPicker.Saturation = {0, 0} -- no i'm not going to use ColorPicker.Value that would confuse people with ColorPicker.Color
ColorPicker.Alpha = typeof(Alpha) == "number" and Alpha or 0
ColorPicker.Hue = 0
ColorPicker.Callback = typeof(Callback) == "function" and Callback or function() end


local function UpdateColor()
    ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2])

    HexBox.Text = "#" .. string.upper(ColorPicker.Color:ToHex()) .. string.upper(string.format("%X", ColorPicker.Alpha * 255))
    Button.BackgroundColor3 = ColorPicker.Color
    Saturation.BackgroundColor3 = ColorPicker.Color
    AlphaColorGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, ColorPicker.Color)}

    SaturationCursor.Position = UDim2.fromScale(math.clamp(ColorPicker.Saturation[1], 0, 0.95), math.clamp(1 - ColorPicker.Saturation[2], 0, 0.95))
    AlphaCursor.Position = UDim2.fromScale(0, math.clamp(ColorPicker.Alpha, 0, 0.98))
    HueCursor.Position = UDim2.fromScale(0, math.clamp(ColorPicker.Hue, 0, 0.98))

    ColorPicker.Callback(ColorPicker.Color, ColorPicker.Alpha)
end


function ColorPicker:Update()
    UpdateColor()
end

function ColorPicker:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function ColorPicker:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 20 or -20, Label)
end

function ColorPicker:SetValue(Color: Color3, Alpha: number)
    self.Color, self.Alpha = typeof(Color) == "Color3" and Color or Color3.new(), typeof(Alpha) == "number" and Alpha or 0
    self.Hue, self.Saturation[1], self.Saturation[2] = self.Color:ToHSV()
    self:Update()
end

function ColorPicker:GetValue(): Color3--, number
    return self.Color, self.Alpha
end


Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Button.Name = "ColorPicker"
Button.BackgroundColor3 = ColorPicker.Color
Button.BorderColor3 = Color3.new()
Button.Position = UDim2.new(1, -35, 0, 4)
Button.Size = UDim2.fromOffset(20, 8)
Button.Font = Enum.Font.SourceSans
Button.Text = ""
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 12
Button.Parent = Label
Button.MouseButton1Click:Connect(function()
    UpdateSelected(Selected_ColorPicker, Button, UDim2.fromOffset(20, 20))
end)

Selected_ColorPicker.Name = "Selected_ColorPicker"
Selected_ColorPicker.Visible = false
Selected_ColorPicker.BackgroundColor3 = Menu.ItemColor
Selected_ColorPicker.BorderColor3 = Menu.BorderColor
Selected_ColorPicker.BorderMode = Enum.BorderMode.Inset
Selected_ColorPicker.Position = UDim2.new(0, 200, 0, 170)
Selected_ColorPicker.Size = UDim2.new(0, 190, 0, 180)
Selected_ColorPicker.Parent = nil
CreateStroke(Selected_ColorPicker, Color3.new(), 1)
AddEventListener(Selected_ColorPicker, function()
    Selected_ColorPicker.BackgroundColor3 = Menu.ItemColor
    Selected_ColorPicker.BorderColor3 = Menu.BorderColor
end)

HexBox.Name = "Hex"
HexBox.BackgroundColor3 = Menu.ItemColor
HexBox.BorderColor3 = Menu.BorderColor
HexBox.BorderMode = Enum.BorderMode.Inset
HexBox.Size = UDim2.new(1, -10, 0, 20)
HexBox.Position = UDim2.fromOffset(5, 150)
HexBox.Text = "#" .. string.upper(ColorPicker.Color:ToHex())
HexBox.Font = Enum.Font.SourceSansSemibold
HexBox.TextSize = 14
HexBox.TextColor3 = Color3.new(1, 1, 1)
HexBox.ClearTextOnFocus = false
HexBox.ClipsDescendants = true
HexBox.Parent = Selected_ColorPicker
CreateStroke(HexBox, Color3.new(), 1)
HexBox.FocusLost:Connect(function()
    pcall(function()
        local Color, Alpha = string.sub(HexBox.Text, 1, 7), string.sub(HexBox.Text, 8, #HexBox.Text)
        ColorPicker.Color = Color3.fromHex(Color)
        ColorPicker.Alpha = tonumber(Alpha, 16) / 255
        ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2] = ColorPicker.Color:ToHSV()
        ColorPicker:Update()
    end)
end)
AddEventListener(HexBox, function()
    HexBox.BackgroundColor3 = Menu.ItemColor
    HexBox.BorderColor3 = Menu.BorderColor
end)

Saturation.Name = "Saturation"
Saturation.BackgroundColor3 = ColorPicker.Color
Saturation.BorderColor3 = Menu.BorderColor
Saturation.Position = UDim2.new(0, 4, 0, 4)
Saturation.Size = UDim2.new(0, 150, 0, 140)
Saturation.Image = "rbxassetid://8180999986"
Saturation.ImageColor3 = Color3.new()
Saturation.AutoButtonColor = false
Saturation.Parent = Selected_ColorPicker
CreateStroke(Saturation, Color3.new(), 1)
AddEventListener(Saturation, function()
    Saturation.BorderColor3 = Menu.BorderColor
end)

Alpha.Name = "Alpha"
Alpha.BorderColor3 = Menu.BorderColor
Alpha.Position = UDim2.new(0, 175, 0, 4)
Alpha.Size = UDim2.new(0, 10, 0, 140)
Alpha.Image = "rbxassetid://8181003956"--"rbxassetid://8181003956"
Alpha.ScaleType = Enum.ScaleType.Crop
Alpha.AutoButtonColor = false
Alpha.Parent = Selected_ColorPicker
CreateStroke(Alpha, Color3.new(), 1)
AddEventListener(Alpha, function()
    Alpha.BorderColor3 = Menu.BorderColor
end)

Hue.Name = "Hue"
Hue.BackgroundColor3 = Color3.new(1, 1, 1)
Hue.BorderColor3 = Menu.BorderColor
Hue.Position = UDim2.new(0, 160, 0, 4)
Hue.Size = UDim2.new(0, 10, 0, 140)
Hue.Image = "rbxassetid://8180989234"
Hue.ScaleType = Enum.ScaleType.Crop
Hue.AutoButtonColor = false
Hue.Parent = Selected_ColorPicker
CreateStroke(Hue, Color3.new(), 1)
AddEventListener(Hue, function()
    Hue.BorderColor3 = Menu.BorderColor
end)

SaturationCursor.Name = "Cursor"
SaturationCursor.BackgroundColor3 = Color3.new(1, 1, 1)
SaturationCursor.BorderColor3 = Color3.new()
SaturationCursor.Size = UDim2.fromOffset(5, 5)
SaturationCursor.Parent = Saturation

AlphaCursor.Name = "Cursor"
AlphaCursor.BackgroundColor3 = Color3.new(1, 1, 1)
AlphaCursor.BorderColor3 = Color3.new()
AlphaCursor.Size = UDim2.new(1, 0, 0, 2)
AlphaCursor.Parent = Alpha

HueCursor.Name = "Cursor"
HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
HueCursor.BorderColor3 = Color3.new()
HueCursor.Size = UDim2.new(1, 0, 0, 2)
HueCursor.Parent = Hue

AlphaColorGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, ColorPicker.Color)}
AlphaColorGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.20), NumberSequenceKeypoint.new(1, 0.2)}
AlphaColorGradient.Offset = Vector2.new(0, -0.1)
AlphaColorGradient.Rotation = -90
AlphaColorGradient.Parent = Alpha

local function UpdateSaturation(PercentageX: number, PercentageY: number)
    local PercentageX = typeof(PercentageX == "number") and math.clamp(PercentageX, 0, 1) or 0
    local PercentageY = typeof(PercentageY == "number") and math.clamp(PercentageY, 0, 1) or 0
    ColorPicker.Saturation[1] = PercentageX
    ColorPicker.Saturation[2] = 1 - PercentageY
    ColorPicker:Update()
end

local function UpdateAlpha(Percentage: number)
    local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
    ColorPicker.Alpha = Percentage
    ColorPicker:Update()
end

local function UpdateHue(Percentage: number)
    local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
    ColorPicker.Hue = Percentage
    ColorPicker:Update()
end

Saturation.InputBegan:Connect(function(Input: InputObject, Process: boolean)
    if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = {Gui = Saturation, True = true}
        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Percentage = (InputPosition - Saturation.AbsolutePosition) / Saturation.AbsoluteSize
        UpdateSaturation(Percentage.X, Percentage.Y)
    end
end)

Alpha.InputBegan:Connect(function(Input: InputObject, Process: boolean)
    if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = {Gui = Alpha, True = true}
        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Percentage = (InputPosition - Alpha.AbsolutePosition) / Alpha.AbsoluteSize
        UpdateAlpha(Percentage.Y)
    end
end)

Hue.InputBegan:Connect(function(Input: InputObject, Process: boolean)
    if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = {Gui = Hue, True = true}
        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        local Percentage = (InputPosition - Hue.AbsolutePosition) / Hue.AbsoluteSize
        UpdateHue(Percentage.Y)
    end
end)

UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
    if (Dragging.Gui ~= Saturation and Dragging.Gui ~= Alpha and Dragging.Gui ~= Hue) then return end
    if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
        Dragging = {Gui = nil, True = false}
        return
    end

    local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
    if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
        if Dragging.Gui == Saturation then
            local Percentage = (InputPosition - Saturation.AbsolutePosition) / Saturation.AbsoluteSize
            UpdateSaturation(Percentage.X, Percentage.Y)
        end
        if Dragging.Gui == Alpha then
            local Percentage = (InputPosition - Alpha.AbsolutePosition) / Alpha.AbsoluteSize
            UpdateAlpha(Percentage.Y)
        end
        if Dragging.Gui == Hue then
            local Percentage = (InputPosition - Hue.AbsolutePosition) / Hue.AbsoluteSize
            UpdateHue(Percentage.Y)
        end
    end
end)


ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2] = ColorPicker.Color:ToHSV()
ColorPicker:Update()
Container:UpdateSize(20)
table.insert(Items, ColorPicker)
return #Items
end


function Menu.ComboBox(Tab_Name: string, Container_Name: string, Name: string, Value: string, Value_Items: table, Callback: any, ToolTip: string): ComboBox
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "ComboBox", Name, UDim2.new(1, -10, 0, 15), UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")
local Symbol = Instance.new("TextLabel")
local List = Instance.new("ScrollingFrame")
local ListLayout = Instance.new("UIListLayout")

local ComboBox = {}
ComboBox.Name = Name
ComboBox.Class = "ComboBox"
ComboBox.Tab = Tab_Name
ComboBox.Container = Container_Name
ComboBox.Index = #Items + 1
ComboBox.Callback = typeof(Callback) == "function" and Callback or function() end
ComboBox.Value = typeof(Value) == "string" and Value or ""
ComboBox.Items = typeof(Value_Items) == "table" and Value_Items or {}

local function UpdateValue(Value: string)
    ComboBox.Value = tostring(Value)
    Button.Text = ComboBox.Value or "[...]"
end

local ItemObjects = {}
local function AddItem(Name: string)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 15)
    Button.Font = Enum.Font.SourceSans
    Button.Text = tostring(Name)
    Button.TextColor3 = ComboBox.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.TextTruncate = Enum.TextTruncate.AtEnd
    Button.Parent = List
    Button.MouseButton1Click:Connect(function()
        for _, v in ipairs(List:GetChildren()) do
            if v:IsA("GuiButton") then
                if v == Button then continue end
                v.TextColor3 = Color3.new(1, 1, 1)
            end
        end
        Button.TextColor3 = Menu.Accent
        UpdateValue(Button.Text)
        UpdateSelected()
        ComboBox.Callback(ComboBox.Value)
    end)
    AddEventListener(Button, function()
        Button.BackgroundColor3 = Menu.ItemColor
        if ComboBox.Value == Button.Text then
            Button.TextColor3 = Menu.Accent
        else
            Button.TextColor3 = Color3.new(1, 1, 1)
        end
    end)
    
    if #ComboBox.Items >= 6 then
        List.CanvasSize += UDim2.fromOffset(0, 15)
    end
    table.insert(ItemObjects, Button)
end


function ComboBox:Update(Value: string, Items: any)
    UpdateValue(Value)
    if typeof(Items) == "table" then
        for _, Button in ipairs(ItemObjects) do
            Button:Destroy()
        end
        table.clear(ItemObjects)

        List.CanvasSize = UDim2.new()
        List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#self.Items * 15, 15, 90))
        for _, Item in ipairs(self.Items) do
            AddItem(tostring(Item))
        end
    else
        for _, Button in ipairs(ItemObjects) do
            Button.TextColor3 = self.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
        end
    end
end

function ComboBox:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function ComboBox:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 40 or -40, Label)
end

function ComboBox:GetValue(): table
    return self.Value
end

function ComboBox:SetValue(Value: string, Items: any)
    if typeof(Items) == "table" then
        self.Items = Items
    end
    self:Update(Value, self.Items)
end


Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Button.Name = "Button"
Button.BackgroundColor3 = Menu.ItemColor
Button.BorderColor3 = Color3.new()
Button.Position = UDim2.new(0, 0, 0, 20)
Button.Size = UDim2.new(1, -40, 0, 15)
Button.Font = Enum.Font.SourceSans
Button.Text = ComboBox.Value
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 14
Button.TextTruncate = Enum.TextTruncate.AtEnd
Button.Parent = Label
Button.MouseButton1Click:Connect(function()
    UpdateSelected(List, Button, UDim2.fromOffset(0, 15))
    List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#ComboBox.Items * 15, 15, 90))
end)
AddEventListener(Button, function()
    Button.BackgroundColor3 = Menu.ItemColor
end)

Symbol.Name = "Symbol"
Symbol.Parent = Button
Symbol.BackgroundColor3 = Color3.new(1, 1, 1)
Symbol.BackgroundTransparency = 1
Symbol.Position = UDim2.new(1, -10, 0, 0)
Symbol.Size = UDim2.new(0, 5, 1, 0)
Symbol.Font = Enum.Font.SourceSans
Symbol.Text = "-"
Symbol.TextColor3 = Color3.new(1, 1, 1)
Symbol.TextSize = 14

List.Visible = false
List.BackgroundColor3 = Menu.ItemColor
List.BorderColor3 = Menu.BorderColor
List.BorderMode = Enum.BorderMode.Inset
List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#ComboBox.Items * 15, 15, 90))
List.Position = UDim2.fromOffset(20, 30)
List.CanvasSize = UDim2.new()
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Menu.Accent
List.Parent = Label
CreateStroke(List, Color3.new(), 1)
AddEventListener(List, function()
    List.BackgroundColor3 = Menu.ItemColor
    List.BorderColor3 = Menu.BorderColor
    List.ScrollBarImageColor3 = Menu.Accent
end)

ListLayout.Parent = List

ComboBox:Update(ComboBox.Value, ComboBox.Items)
Container:UpdateSize(40)
table.insert(Items, ComboBox)
return #Items
end


function Menu.MultiSelect(Tab_Name: string, Container_Name: string, Name: string, Value_Items: table, Callback: any, ToolTip: string): MultiSelect
local Container = GetContainer(Tab_Name, Container_Name)
local Label = CreateLabel(Container.self, "MultiSelect", Name, UDim2.new(1, -10, 0, 15), UDim2.fromOffset(20, Container:GetHeight()))
local Button = Instance.new("TextButton")
local Symbol = Instance.new("TextLabel")
local List = Instance.new("ScrollingFrame")
local ListLayout = Instance.new("UIListLayout")

local MultiSelect = {self = Label}
MultiSelect.Name = Name
MultiSelect.Class = "MultiSelect"
MultiSelect.Tab = Tab_Name
MultiSelect.Container = Container_Name
MultiSelect.Index = #Items + 1
MultiSelect.Callback = typeof(Callback) == "function" and Callback or function() end
MultiSelect.Items = typeof(Value_Items) == "table" and Value_Items or {}
MultiSelect.Value = {}


local function GetSelectedItems(): table
    local Selected = {}
    for k, v in pairs(MultiSelect.Items) do
        if v == true then table.insert(Selected, k) end
    end
    return Selected
end

local function UpdateValue()
    MultiSelect.Value = GetSelectedItems()
    Button.Text = #MultiSelect.Value > 0 and table.concat(MultiSelect.Value, ", ") or "[...]"
end

local ItemObjects = {}
local function AddItem(Name: string, Checked: boolean)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 15)
    Button.Font = Enum.Font.SourceSans
    Button.Text = Name
    Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.Parent = List
    Button.TextTruncate = Enum.TextTruncate.AtEnd
    Button.MouseButton1Click:Connect(function()
        MultiSelect.Items[Name] = not MultiSelect.Items[Name]
        Button.TextColor3 = MultiSelect.Items[Name] and Menu.Accent or Color3.new(1, 1, 1)
        UpdateValue()
        MultiSelect.Callback(MultiSelect.Items) -- don't send value
    end)
    AddEventListener(Button, function()
        Button.BackgroundColor3 = Menu.ItemColor
        Button.TextColor3 = table.find(GetSelectedItems(), Button.Text) and Menu.Accent or Color3.new(1, 1, 1)
    end)

    if GetDictionaryLength(MultiSelect.Items) >= 6 then
        List.CanvasSize += UDim2.fromOffset(0, 15)
    end
    table.insert(ItemObjects, Button)
end


function MultiSelect:Update(Value: any)
    if typeof(Value) == "table" then
        self.Items = Value
        UpdateValue()

        for _, Button in ipairs(ItemObjects) do
            Button:Destroy()
        end
        table.clear(ItemObjects)

        List.CanvasSize = UDim2.new()
        List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(self.Items) * 15, 15, 90))
        for Name, Checked in pairs(self.Items) do
            AddItem(tostring(Name), Checked)
        end
    else
        local Selected = GetSelectedItems()
        for _, Button in ipairs(ItemObjects) do
            local Checked = table.find(Selected, Button.Text)
            Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
        end
    end
end

function MultiSelect:SetLabel(Name: string)
    Label.Text = tostring(Name)
end

function MultiSelect:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if Label.Visible == Visible then return end
    
    Label.Visible = Visible
    Container:UpdateSize(Visible and 40 or -40, Label)
end

function MultiSelect:GetValue(): table
    return self.Items
end

function MultiSelect:SetValue(Value: any)
    self:Update(Value)
end


Label.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, Label)
    end
end)
Label.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)

Button.BackgroundColor3 = Menu.ItemColor
Button.BorderColor3 = Color3.new()
Button.Position = UDim2.new(0, 0, 0, 20)
Button.Size = UDim2.new(1, -40, 0, 15)
Button.Font = Enum.Font.SourceSans
Button.Text = "[...]"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 14
Button.TextTruncate = Enum.TextTruncate.AtEnd
Button.Parent = Label
Button.MouseButton1Click:Connect(function()
    UpdateSelected(List, Button, UDim2.fromOffset(0, 15))
    List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(MultiSelect.Items) * 15, 15, 90))
end)
AddEventListener(Button, function()
    Button.BackgroundColor3 = Menu.ItemColor
end)

Symbol.Name = "Symbol"
Symbol.BackgroundTransparency = 1
Symbol.Position = UDim2.new(1, -10, 0, 0)
Symbol.Size = UDim2.new(0, 5, 1, 0)
Symbol.Font = Enum.Font.SourceSans
Symbol.Text = "-"
Symbol.TextColor3 = Color3.new(1, 1, 1)
Symbol.TextSize = 14
Symbol.Parent = Button

List.Visible = false
List.BackgroundColor3 = Menu.ItemColor
List.BorderColor3 = Menu.BorderColor
List.BorderMode = Enum.BorderMode.Inset
List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(MultiSelect.Items) * 15, 15, 90))
List.Position = UDim2.fromOffset(20, 30)
List.CanvasSize = UDim2.new()
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Menu.Accent
List.Parent = Label
CreateStroke(List, Color3.new(), 1)
AddEventListener(List, function()
    List.BackgroundColor3 = Menu.ItemColor
    List.BorderColor3 = Menu.BorderColor
    List.ScrollBarImageColor3 = Menu.Accent
end)

ListLayout.Parent = List

MultiSelect:Update(MultiSelect.Items)
Container:UpdateSize(40)
table.insert(Items, MultiSelect)
return #Items
end


function Menu.ListBox(Tab_Name: string, Container_Name: string, Name: string, Multi: boolean, Value_Items: table, Callback: any, ToolTip: string): ListBox
local Container = GetContainer(Tab_Name, Container_Name)
local List = Instance.new("ScrollingFrame")
local ListLayout = Instance.new("UIListLayout")

local ListBox = {self = Label}
ListBox.Name = Name
ListBox.Class = "ListBox"
ListBox.Tab = Tab_Name
ListBox.Container = Container_Name
ListBox.Index = #Items + 1
ListBox.Method = Multi and "Multi" or "Default"
ListBox.Items = typeof(Value_Items) == "table" and Value_Items or {}
ListBox.Value = {}
ListBox.Callback = typeof(Callback) == "function" and Callback or function() end

local ItemObjects = {}

local function GetSelectedItems(): table
    local Selected = {}
    for k, v in pairs(ListBox.Items) do
        if v == true then table.insert(Selected, k) end
    end
    return Selected
end

local function UpdateValue(Value: any)
    if ListBox.Method == "Default" then
        ListBox.Value = tostring(Value)
    else
        ListBox.Value = GetSelectedItems()
    end
end

local function AddItem(Name: string, Checked: boolean)
    local Button = Instance.new("TextButton")
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 15)
    Button.Font = Enum.Font.SourceSans
    Button.Text = Name
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.TextTruncate = Enum.TextTruncate.AtEnd
    Button.Parent = List
    if ListBox.Method == "Default" then
        Button.TextColor3 = ListBox.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
        Button.MouseButton1Click:Connect(function()
            for _, v in ipairs(List:GetChildren()) do
                if v:IsA("GuiButton") then
                    if v == Button then continue end
                    v.TextColor3 = Color3.new(1, 1, 1)
                end
            end
            Button.TextColor3 = Menu.Accent
            UpdateValue(Button.Text)
            UpdateSelected()
            ListBox.Callback(ListBox.Value)
        end)
        AddEventListener(Button, function()
            Button.BackgroundColor3 = Menu.ItemColor
            if ListBox.Value == Button.Text then
                Button.TextColor3 = Menu.Accent
            else
                Button.TextColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        if #ListBox.Items >= 6 then
            List.CanvasSize += UDim2.fromOffset(0, 15)
        end
    else
        Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
        Button.MouseButton1Click:Connect(function()
            ListBox.Items[Name] = not ListBox.Items[Name]
            Button.TextColor3 = ListBox.Items[Name] and Menu.Accent or Color3.new(1, 1, 1)
            UpdateValue()
            UpdateSelected()
            ListBox.Callback(ListBox.Value)
        end)
        AddEventListener(Button, function()
            Button.BackgroundColor3 = Menu.ItemColor
            if table.find(ListBox.Value, Name) then
                Button.TextColor3 = Menu.Accent
            else
                Button.TextColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        if GetDictionaryLength(ListBox.Items) >= 10 then
            List.CanvasSize += UDim2.fromOffset(0, 15)
        end
    end
    table.insert(ItemObjects, Button)
end


function ListBox:Update(Value: string, Items: any)
    if self.Method == "Default" then
        UpdateValue(Value)
    end
    if typeof(Items) == "table" then
        if self.Method == "Multi" then
            self.Items = Value
            UpdateValue()
        end
        for _, Button in ipairs(ItemObjects) do
            Button:Destroy()
        end
        table.clear(ItemObjects)

        List.CanvasSize = UDim2.new()
        List.Size = UDim2.new(1, -50, 0, 150)
        if self.Method == "Default" then
            for _, Item in ipairs(self.Items) do
                AddItem(tostring(Item))
            end
        else
            for Name, Checked in pairs(self.Items) do
                AddItem(tostring(Name), Checked)
            end
        end
    else
        if self.Method == "Default" then
            for _, Button in ipairs(ItemObjects) do
                Button.TextColor3 = self.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
            end
        else
            local Selected = GetSelectedItems()
            for _, Button in ipairs(ItemObjects) do
                local Checked = table.find(Selected, Button.Text)
                Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
            end
        end
    end
end

function ListBox:SetVisible(Visible: boolean)
    if typeof(Visible) ~= "boolean" then return end
    if List.Visible == Visible then return end
    
    List.Visible = Visible
    Container:UpdateSize(Visible and 155 or -155, List)
end

function ListBox:SetValue(Value: string, Items: any)
    if self.Method == "Default" then
        if typeof(Items) == "table" then
            self.Items = Items
        end
        self:Update(Value, self.Items)
    else
        self:Update(Value)
    end
end

function ListBox:GetValue(): table
    return self.Value
end


List.Name = "List"
List.Active = true
List.BackgroundColor3 = Menu.ItemColor
List.BorderColor3 = Color3.new()
List.Position = UDim2.fromOffset(20, Container:GetHeight())
List.Size = UDim2.new(1, -50, 0, 150)
List.CanvasSize = UDim2.new()
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Menu.Accent
List.Parent = Container.self
List.MouseEnter:Connect(function()
    if ToolTip then
        Menu:SetToolTip(true, ToolTip, List)
    end
end)
List.MouseLeave:Connect(function()
    if ToolTip then
        Menu:SetToolTip(false)
    end
end)
CreateStroke(List, Color3.new(), 1)
AddEventListener(List, function()
    List.BackgroundColor3 = Menu.ItemColor
    List.ScrollBarImageColor3 = Menu.Accent
end)

ListLayout.Parent = List

if ListBox.Method == "Default" then
    ListBox:Update(ListBox.Value, ListBox.Items)
else
    ListBox:Update(ListBox.Items)
end
Container:UpdateSize(155)
table.insert(Items, ListBox)
return #Items
end


function Menu.Notify(Content: string, Delay: number)
assert(typeof(Content) == "string", "missing argument #1, (string expected got " .. typeof(Content) .. ")")
local Delay = typeof(Delay) == "number" and Delay or 3

local Text = Instance.new("TextLabel")
local Notification = {
    self = Text,
    Class = "Notification"
}

Text.Name = "Notification"
Text.BackgroundTransparency = 1
Text.Position = UDim2.new(0.5, -100, 1, -150 - (GetDictionaryLength(Notifications) * 15))
Text.Size = UDim2.new(0, 0, 0, 15)
Text.Text = Content
Text.Font = Enum.Font.SourceSans
Text.TextSize = 17
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextStrokeTransparency = 0.2
Text.TextTransparency = 1
Text.RichText = true
Text.ZIndex = 4
Text.Parent = Notifications_Frame

local function CustomTweenOffset(Offset: number)
    spawn(function()
        local Steps = 33
        for i = 1, Steps do
            Text.Position += UDim2.fromOffset(Offset / Steps, 0)
            RunService.RenderStepped:Wait()
        end
    end)
end

function Notification:Update()
    
end

function Notification:Destroy()
    Notifications[self] = nil
    Text:Destroy()

    local Index = 1
    for _, v in pairs(Notifications) do
        local self = v.self
        self.Position += UDim2.fromOffset(0, 15)
        Index += 1
    end
end

Notifications[Notification] = Notification

local TweenIn  = TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 0})
local TweenOut = TweenService:Create(Text, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 1})

TweenIn:Play()
CustomTweenOffset(100)

TweenIn.Completed:Connect(function()
    delay(Delay, function()
        TweenOut:Play()
        CustomTweenOffset(100)

        TweenOut.Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end)
end


function Menu.Prompt(Message: string, Callback: any, ...)
do
    local Prompt = Menu.Screen:FindFirstChild("Prompt")
    if Prompt then Prompt:Destroy() end
end

local Prompt = Instance.new("Frame")
local Title = Instance.new("TextLabel")

local Height = -20
local function CreateButton(Text, Callback, ...)
    local Arguments = {...}

    local Callback = typeof(Callback) == "function" and Callback or function() end
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.BorderSizePixel = 0
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.Size = UDim2.fromOffset(100, 20)
    Button.Position = UDim2.new(0.5, -50, 0.5, Height)
    Button.Text = Text
    Button.TextStrokeTransparency = 0.8
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSans
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Parent = Prompt
    Button.MouseButton1Click:Connect(function() Prompt:Destroy() Callback(unpack(Arguments)) end)
    CreateStroke(Button, Color3.new(), 1)
    Height += 25
end

CreateButton("OK", Callback, ...)
CreateButton("Cancel", function() Prompt:Destroy() end)


Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 15)
Title.Position = UDim2.new(0, 0, 0.5, -100)
Title.Text = Message
Title.TextSize = 14
Title.Font = Enum.Font.SourceSans
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = Prompt

Prompt.Name = "Prompt"
Prompt.BackgroundTransparency = 0.5
Prompt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Prompt.BorderSizePixel = 0
Prompt.Size = UDim2.new(1, 0, 1, 36)
Prompt.Position = UDim2.fromOffset(0, -36)
Prompt.Parent = Menu.Screen
end


function Menu.Spectators(): Spectators
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local List = Instance.new("Frame")
local ListLayout = Instance.new("UIListLayout")
local Spectators = {self = Frame}
Spectators.List = {}
Menu.Spectators = Spectators


Frame.Name = "Spectators"
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderMode = Enum.BorderMode.Inset
Frame.Size = UDim2.fromOffset(250, 50)
Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset, -36)
Frame.Visible = false
Frame.Parent = Menu.Screen
CreateStroke(Frame, Color3.new(), 1)
CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
SetDraggable(Frame)

Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Size = UDim2.new(0, 240, 0, 15)
Title.Font = Enum.Font.SourceSansSemibold
Title.Text = "Spectators"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Parent = Frame

List.Name = "List"
List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
List.BorderColor3 = Color3.fromRGB(40, 40, 40)
List.BorderMode = Enum.BorderMode.Inset
List.Position = UDim2.new(0, 4, 0, 30)
List.Size = UDim2.new(0, 240, 0, 10)
List.Parent = Frame

ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = List


local function UpdateFrameSize()
    local Height = ListLayout.AbsoluteContentSize.Y + 5
    Spectators.self:TweenSize(UDim2.fromOffset(250, math.clamp(Height + 50, 50, 5000)), nil, nil, 0.3, true)
    Spectators.self.List:TweenSize(UDim2.fromOffset(240, math.clamp(Height, 10, 5000)), nil, nil, 0.3, true)
end


function Spectators.Add(Name: string, Icon: string)
    Spectators.Remove(Name)
    local Object = Instance.new("Frame")
    local NameLabel = Instance.new("TextLabel")
    local IconImage = Instance.new("ImageLabel")
    local Spectator = {self = Object}

    Object.Name = "Object"
    Object.BackgroundTransparency = 1
    Object.Position = UDim2.new(0, 5, 0, 30)
    Object.Size = UDim2.new(0, 240, 0, 15)
    Object.Parent = List

    NameLabel.Name = "Name"
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 20, 0, 0)
    NameLabel.Size = UDim2.new(0, 230, 1, 0)
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.Text = tostring(Name)
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.TextSize = 14
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Object

    IconImage.Name = "Icon"
    IconImage.BackgroundTransparency = 1
    IconImage.Image = Icon or ""
    IconImage.Size = UDim2.new(0, 15, 0, 15)
    IconImage.Position = UDim2.new(0, 2, 0, 0)
    IconImage.Parent = Object

    Spectators.List[Name] = Spectator
    UpdateFrameSize()
end


function Spectators.Remove(Name: string)
    if Spectators.List[Name] then
        Spectators.List[Name].self:Destroy()
        Spectators.List[Name] = nil
    end
    UpdateFrameSize()
end


function Spectators:SetVisible(Visible: boolean)
    self.self.Visible = Visible
end


return Spectators
end


function Menu.Keybinds(): Keybinds
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local List = Instance.new("Frame")
local ListLayout = Instance.new("UIListLayout")
local Keybinds = {self = Frame}
Keybinds.List = {}
Menu.Keybinds = Keybinds


Frame.Name = "Keybinds"
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderMode = Enum.BorderMode.Inset
Frame.Size = UDim2.fromOffset(250, 45)
Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset, -36)
Frame.Visible = false
Frame.Parent = Menu.Screen
CreateStroke(Frame, Color3.new(), 1)
CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
SetDraggable(Frame)

Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Size = UDim2.new(0, 240, 0, 15)
Title.Font = Enum.Font.SourceSansSemibold
Title.Text = "Key binds"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Parent = Frame

List.Name = "List"
List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
List.BorderColor3 = Color3.fromRGB(40, 40, 40)
List.BorderMode = Enum.BorderMode.Inset
List.Position = UDim2.new(0, 4, 0, 30)
List.Size = UDim2.new(0, 240, 0, 10)
List.Parent = Frame

ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 3)
ListLayout.Parent = List

local function UpdateFrameSize()
    local Height = ListLayout.AbsoluteContentSize.Y + 5
    Keybinds.self:TweenSize(UDim2.fromOffset(250, math.clamp(Height + 45, 45, 5000)), nil, nil, 0.3, true)
    Keybinds.self.List:TweenSize(UDim2.fromOffset(240, math.clamp(Height, 10, 5000)), nil, nil, 0.3, true)
end

function Keybinds.Add(Name: string, State: string): Keybind
    Keybinds.Remove(Name)
    local Object = Instance.new("Frame")
    local NameLabel = Instance.new("TextLabel")
    local StateLabel = Instance.new("TextLabel")
    local Keybind = {self = Object}

    Object.Name = "Object"
    Object.BackgroundTransparency = 1
    Object.Position = UDim2.new(0, 5, 0, 30)
    Object.Size = UDim2.new(0, 230, 0, 15)
    Object.Parent = List

    NameLabel.Name = "Indicator"
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.Size = UDim2.new(0, 180, 1, 0)
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.Text = Name
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.TextSize = 14
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Object

    StateLabel.Name = "State"
    StateLabel.BackgroundTransparency = 1
    StateLabel.Position = UDim2.new(0, 190, 0, 0)
    StateLabel.Size = UDim2.new(0, 40, 1, 0)
    StateLabel.Font = Enum.Font.SourceSans
    StateLabel.Text = "[" .. tostring(State) .. "]"
    StateLabel.TextColor3 = Color3.new(1, 1, 1)
    StateLabel.TextSize = 14
    StateLabel.TextXAlignment = Enum.TextXAlignment.Right
    StateLabel.Parent = Object

    
    function Keybind:Update(State: string)
        StateLabel.Text = "[" .. tostring(State) .. "]"
    end

    function Keybind:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Object.Visible == Visible then return end
    
        Object.Visible = Visible
        UpdateFrameSize()
    end

    
    Keybinds.List[Name] = Keybind
    UpdateFrameSize()

    return Keybind
end

function Keybinds.Remove(Name: string)
    if Keybinds.List[Name] then
        Keybinds.List[Name].self:Destroy()
        Keybinds.List[Name] = nil
    end
    UpdateFrameSize()
end

function Keybinds:SetVisible(Visible: boolean)
    self.self.Visible = Visible
end

function Keybinds:SetPosition(Position: UDim2)
    self.self.Position = Position
end

return Keybinds
end


function Menu.Indicators(): Indicators
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local List = Instance.new("Frame")
local ListLayout = Instance.new("UIListLayout")

local Indicators = {self = Frame}
Indicators.List = {}
Menu.Indicators = Indicators

Frame.Name = "Indicators"
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderMode = Enum.BorderMode.Inset
Frame.Size = UDim2.fromOffset(250, 45)
Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset, -36)
Frame.Visible = false
Frame.Parent = Menu.Screen
CreateStroke(Frame, Color3.new(), 1)
CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
SetDraggable(Frame)

Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Size = UDim2.new(0, 240, 0, 15)
Title.Font = Enum.Font.SourceSansSemibold
Title.Text = "Indicators"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Parent = Frame

List.Name = "List"
List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
List.BorderColor3 = Color3.fromRGB(40, 40, 40)
List.BorderMode = Enum.BorderMode.Inset
List.Position = UDim2.new(0, 4, 0, 30)
List.Size = UDim2.new(0, 240, 0, 10)
List.Parent = Frame

ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 3)
ListLayout.Parent = List

local function UpdateFrameSize()
    local Height = ListLayout.AbsoluteContentSize.Y + 12
    Indicators.self:TweenSize(UDim2.fromOffset(250, math.clamp(Height + 45, 45, 5000)), nil, nil, 0.3, true)
    Indicators.self.List:TweenSize(UDim2.fromOffset(240, math.clamp(Height, 10, 5000)), nil, nil, 0.3, true)
end

function Indicators.Add(Name: string, Type: string, Value: string, ...): Indicator
    Indicators.Remove(Name)
    local Object = Instance.new("Frame")
    local NameLabel = Instance.new("TextLabel")
    local StateLabel = Instance.new("TextLabel")

    local Indicator = {self = Object}
    Indicator.Type = Type
    Indicator.Value = Value

    Object.Name = "Object"
    Object.BackgroundTransparency = 1
    Object.Size = UDim2.new(0, 230, 0, 30)
    Object.Parent = Indicators.self.List
    
    NameLabel.Name = "Indicator"
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.Size = UDim2.new(0, 130, 0, 15)
    NameLabel.Font = Enum.Font.SourceSans
    NameLabel.Text = Name
    NameLabel.TextColor3 = Color3.new(1, 1, 1)
    NameLabel.TextSize = 14
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Indicator.self

    StateLabel.Name = "State"
    StateLabel.BackgroundTransparency = 1
    StateLabel.Position = UDim2.new(0, 180, 0, 0)
    StateLabel.Size = UDim2.new(0, 40, 0, 15)
    StateLabel.Font = Enum.Font.SourceSans
    StateLabel.Text = "[" .. tostring(Value) .. "]"
    StateLabel.TextColor3 = Color3.new(1, 1, 1)
    StateLabel.TextSize = 14
    StateLabel.TextXAlignment = Enum.TextXAlignment.Right
    StateLabel.Parent = Indicator.self


    if Type == "Bar" then
        local ObjectBase = Instance.new("Frame")
        local ValueLabel = Instance.new("TextLabel")

        ObjectBase.Name = "Bar"
        ObjectBase.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        ObjectBase.BorderColor3 = Color3.new()
        ObjectBase.Position = UDim2.new(0, 0, 0, 20)
        ObjectBase.Size = UDim2.new(0, 220, 0, 5)
        ObjectBase.Parent = Indicator.self

        ValueLabel.Name = "Value"
        ValueLabel.BorderSizePixel = 0
        ValueLabel.BackgroundColor3 = Menu.Accent
        ValueLabel.Text = ""
        ValueLabel.Parent = ObjectBase
        AddEventListener(ValueLabel, function()
            ValueLabel.BackgroundColor3 = Menu.Accent
        end)
    else
        Object.Size = UDim2.new(0, 230, 0, 15)
    end


    function Indicator:Update(Value: string, ...)
        if Indicators.List[Name] then
            if Type == "Text" then
                self.Value = Value
                Object.State.Text = Value
            elseif Type == "Bar" then
                local Min, Max = select(1, ...)
                self.Min = typeof(Min) == "number" and Min or self.Min
                self.Max = typeof(Max) == "number" and Max or self.Max

                local Scale = (self.Value - self.Min) / (self.Max - self.Min)
                Object.State.Text = "[" .. tostring(self.Value) .. "]"
                Object.Bar.Value.Size = UDim2.new(math.clamp(Scale, 0, 1), 0, 0, 5)
            end
            self.Value = Value
        end
    end


    function Indicator:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Object.Visible == Visible then return end
        
        Object.Visible = Visible
        UpdateFrameSize()
    end

    
    Indicator:Update(Indicator.Value, ...)
    Indicators.List[Name] = Indicator
    UpdateFrameSize()
    return Indicator
end


function Indicators.Remove(Name: string)
    if Indicators.List[Name] then
        Indicators.List[Name].self:Destroy()
        Indicators.List[Name] = nil
    end
    UpdateFrameSize()
end


function Indicators:SetVisible(Visible: boolean)
    self.self.Visible = Visible
end

function Indicators:SetPosition(Position: UDim2)
    self.self.Position = Position
end


return Indicators
end


function Menu.Watermark(): Watermark
local Watermark = {}
Watermark.Frame = Instance.new("Frame")
Watermark.Title = Instance.new("TextLabel")
Menu.Watermark = Watermark

Watermark.Frame.Name = "Watermark"
Watermark.Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Watermark.Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Watermark.Frame.BorderMode = Enum.BorderMode.Inset
Watermark.Frame.Size = UDim2.fromOffset(250, 20)
Watermark.Frame.Position = UDim2.fromOffset((Menu.ScreenSize.X - Watermark.Frame.Size.X.Offset) - 50, -25)
Watermark.Frame.Visible = false
Watermark.Frame.Parent = Menu.Screen
CreateStroke(Watermark.Frame, Color3.new(), 1)
CreateLine(Watermark.Frame, UDim2.new(0, 245, 0, 1), UDim2.new(0, 2, 0, 15))
SetDraggable(Watermark.Frame)

Watermark.Title.Name = "Title"
Watermark.Title.BackgroundTransparency = 1
Watermark.Title.Position = UDim2.new(0, 5, 0, -1)
Watermark.Title.Size = UDim2.new(0, 240, 0, 15)
Watermark.Title.Font = Enum.Font.SourceSansSemibold
Watermark.Title.Text = ""
Watermark.Title.TextColor3 = Color3.new(1, 1, 1)
Watermark.Title.TextSize = 14
Watermark.Title.RichText = true
Watermark.Title.Parent = Watermark.Frame

function Watermark:Update(Text: string)
    self.Title.Text = tostring(Text)
end

function Watermark:SetVisible(Visible: boolean)
    self.Frame.Visible = Visible
end

return Watermark
end


function Menu:Init()
UserInput.InputBegan:Connect(function(Input: InputObject, Process: boolean) end)
UserInput.InputEnded:Connect(function(Input: InputObject)
    if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        Dragging = {Gui = nil, True = false}
    end
end)
RunService.RenderStepped:Connect(function(Step: number)
    local Menu_Frame = Menu.Screen.Menu
    Menu_Frame.Position = UDim2.fromOffset(
        math.clamp(Menu_Frame.AbsolutePosition.X,   0, math.clamp(Menu.ScreenSize.X - Menu_Frame.AbsoluteSize.X, 0, Menu.ScreenSize.X    )),
        math.clamp(Menu_Frame.AbsolutePosition.Y, -36, math.clamp(Menu.ScreenSize.Y - Menu_Frame.AbsoluteSize.Y, 0, Menu.ScreenSize.Y - 36))
    )
    local Selected_Frame = Selected.Frame
    local Selected_Item = Selected.Item
    if (Selected_Frame and Selected_Item) then
        local Offset = Selected.Offset or UDim2.fromOffset()
        local Position = UDim2.fromOffset(Selected_Item.AbsolutePosition.X, Selected_Item.AbsolutePosition.Y)
        Selected_Frame.Position = Position + Offset
    end

    if Scaling.True then
        MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        local Origin = Scaling.Origin
        local Size = Scaling.Size

        if Origin and Size then
            local Location = UserInput:GetMouseLocation()
            local NewSize = Location + (Size - Origin)

            Menu:SetSize(Vector2.new(
                math.clamp(NewSize.X, Menu.MinSize.X, Menu.MaxSize.X),
                math.clamp(NewSize.Y, Menu.MinSize.Y, Menu.MaxSize.Y)
            ))
        end
    else
        MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    end

    Menu.Hue += math.clamp(Step / 100, 0, 1)
    if Menu.Hue >= 1 then Menu.Hue = 0 end

    if ToolTip.Enabled == true then
        ToolTip_Label.Text = ToolTip.Content
        ToolTip_Label.Position = UDim2.fromOffset(ToolTip.Item.AbsolutePosition.X, ToolTip.Item.AbsolutePosition.Y + 25)
    end
end)
Menu.Screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    Menu.ScreenSize = Menu.Screen.AbsoluteSize
end)
end

getgenv().Skibidi = {
Enabled = false,
Prediction = 0.13772123,
Keybind = nil,
Resolver = false,
MenuKeybind = nil,

}
local settings = {
defaultcolor = Color3.fromRGB(255, 0, 0),
teamcheck = false,
teamcolor = true,
NameESP = true,     -- Toggle for displaying player names
HealthBar = true,   -- Toggle for displaying health bars
Studs = true        -- Toggle for displaying distance/studs
}
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local newVector2 = Vector2.new
local newColor3 = Color3.new
local newDrawing = Drawing.new
local tan = math.tan
local rad = math.rad

local round = function(...)
local a = {}
for i, v in ipairs(table.pack(...)) do
    a[i] = math.round(v)
end
return unpack(a)
end

local wtvp = function(...)
local a, b = camera:WorldToViewportPoint(...)
return newVector2(a.X, a.Y), b, a.Z
end

local espCache = {}

local function createEsp(player)
local drawings = {}

drawings.box = newDrawing("Square")
drawings.box.Filled = true
drawings.box.Transparency = 0.3
drawings.box.Color = settings.defaultcolor
drawings.box.Visible = false
drawings.box.ZIndex = 2

drawings.boxoutline = newDrawing("Square")
drawings.boxoutline.Thickness = 0.4
drawings.boxoutline.Filled = false
drawings.boxoutline.Color = newColor3()
drawings.boxoutline.Visible = false
drawings.boxoutline.ZIndex = 1

drawings.boxinline = newDrawing("Square")
drawings.boxinline.Thickness = 0.4
drawings.boxinline.Filled = false
drawings.boxinline.Color = newColor3()
drawings.boxinline.Visible = false
drawings.boxinline.ZIndex = 1

if settings.NameESP then
    drawings.name = newDrawing("Text")
    drawings.name.Text = ""
    drawings.name.Size = 14
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.Font = 2
    drawings.name.Visible = false
    drawings.name.ZIndex = 2
    drawings.name.Color = newColor3(1, 1, 1)
end

if settings.HealthBar then
    drawings.healthbar = newDrawing("Square")
    drawings.healthbar.Filled = true
    drawings.healthbar.Color = Color3.fromRGB(0, 255, 0)
    drawings.healthbar.Visible = false
    drawings.healthbar.ZIndex = 2
end

if settings.Studs then
    drawings.studs = newDrawing("Text")
    drawings.studs.Text = ""
    drawings.studs.Size = 14
    drawings.studs.Center = false
    drawings.studs.Outline = true
    drawings.studs.Font = 2
    drawings.studs.Visible = false
    drawings.studs.ZIndex = 2
    drawings.studs.Color = newColor3(1, 1, 1)
end

espCache[player] = drawings
end

local function removeEsp(player)
if espCache[player] then
    for _, drawing in pairs(espCache[player]) do
        drawing:Remove()
    end
    espCache[player] = nil
end
end

local function updateEsp(player, esp)
local character = player.Character
if character and getgenv().ESP and character:FindFirstChild("HumanoidRootPart") then
    local position, visible, depth = wtvp(character.HumanoidRootPart.Position)
    
    for _, drawing in pairs(esp) do
        drawing.Visible = visible
    end
    
    if getgenv().ESP and visible then
        local scaleFactor = 1 / (depth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000
        local width, height = round(4 * scaleFactor), round(7 * scaleFactor)
        local x, y = round(position.X), round(position.Y)
        
        esp.box.Size = newVector2(width, height)
        esp.box.Position = newVector2(x - width / 2, y - height / 2)
        esp.box.Color = settings.teamcolor and player.TeamColor.Color or settings.defaultcolor
        esp.box.Color = esp.box.Color:Lerp(newColor3(1, 1, 1), 0.3)
        
        esp.boxoutline.Size = esp.box.Size
        esp.boxoutline.Position = esp.box.Position
        
        esp.boxinline.Size = esp.box.Size - newVector2(4, 4)
        esp.boxinline.Position = esp.box.Position + newVector2(2, 2)
        
        if settings.NameESP then
            local displayName = player.DisplayName
            local username = player.Name
            esp.name.Text = displayName .. " (@" .. username .. ")"
            esp.name.Position = newVector2(x, y - height / 2 - 16)
            esp.name.Visible = true
        else
            esp.name.Visible = false
        end
        
        if settings.Studs then
            local distance = (camera.CFrame.p - character.HumanoidRootPart.Position).Magnitude
            local distanceText = string.format("%.1f studs", distance)
            esp.studs.Text = distanceText
            esp.studs.Position = newVector2(x - width / 2, y + height / 2 + 2)
            esp.studs.Visible = true
        else
            esp.studs.Visible = false
        end
        
        if settings.HealthBar then
            local healthPercent = character.Humanoid.Health / character.Humanoid.MaxHealth
            esp.healthbar.Size = newVector2(4, height * healthPercent)
            esp.healthbar.Position = newVector2(x + width / 2 + 2, y - height / 2)
            esp.healthbar.Visible = true
        else
            esp.healthbar.Visible = false
        end
    else
        for _, drawing in pairs(esp) do
            drawing.Visible = false
        end
    end
else
    for _, drawing in pairs(esp) do
        drawing.Visible = false
    end
end
end

for _, player in ipairs(players:GetPlayers()) do
if player ~= localPlayer then
    createEsp(player)
end
end

players.PlayerAdded:Connect(function(player)
createEsp(player)
end)

players.PlayerRemoving:Connect(function(player)
removeEsp(player)
end)

runService.RenderStepped:Connect(function()
for player, drawings in pairs(espCache) do
    if settings.teamcheck and player.Team == localPlayer.Team then
        continue
    end
    updateEsp(player, drawings)
end
end)

local jointsToDraw = {
{"Head", "UpperTorso"},
{"UpperTorso", "LowerTorso"},
{"UpperTorso", "LeftUpperArm"},
{"UpperTorso", "RightUpperArm"},
{"LowerTorso", "LeftUpperLeg"},
{"LowerTorso", "RightUpperLeg"},
{"LeftUpperArm", "LeftLowerArm"},
{"RightUpperArm", "RightLowerArm"},
{"LeftUpperLeg", "LeftLowerLeg"},
{"RightUpperLeg", "RightLowerLeg"}
}

local skeletons = {}

local function updateLine(line, screenPosition1, screenPosition2, isVisible)
if getgenv().SkeletonESP and isVisible then
    line.From = screenPosition1
    line.To = screenPosition2
    line.Visible = true
    
    local color = Color3.fromHSV(tick() % 5 / 5, 0.7, 1)
    line.Color = Color3.new(color.r, color.g, color.b)
    line.Thickness = 2
    line.Transparency = 0.5
else
    line.Visible = false
end
end

local function drawSkeleton(player)
local character = player.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

local rootPart = character:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

if not skeletons[player] then
    skeletons[player] = {}
    for _, joints in ipairs(jointsToDraw) do
        local line = Drawing.new("Line")
        line.Visible = false
        skeletons[player][joints] = line
    end
end

for joints, line in pairs(skeletons[player]) do
    local part1 = character:FindFirstChild(joints[1])
    local part2 = character:FindFirstChild(joints[2])
    
    if part1 and part2 then
        local jointPosition1 = part1.Position
        local jointPosition2 = part2.Position
        
        local screenPosition1, onScreen1 = game.Workspace.CurrentCamera:WorldToViewportPoint(jointPosition1)
        local screenPosition2, onScreen2 = game.Workspace.CurrentCamera:WorldToViewportPoint(jointPosition2)
        
        local adjustedScreenPosition1 = Vector2.new(screenPosition1.X, screenPosition1.Y)
        local adjustedScreenPosition2 = Vector2.new(screenPosition2.X, screenPosition2.Y)
        
        if joints[2] == "LeftLowerArm" or joints[2] == "RightLowerArm" or joints[2] == "LeftLowerLeg" or joints[2] == "RightLowerLeg" then
            adjustedScreenPosition2 = Vector2.new(screenPosition2.X, screenPosition2.Y + 20)
        end
        
        updateLine(line, adjustedScreenPosition1, adjustedScreenPosition2, onScreen1 and onScreen2)
    else
        line.Visible = false
    end
end
end

local function onPlayerAdded(player)
if player ~= game.Players.LocalPlayer then
    drawSkeleton(player)
end
end

local function onPlayerRemoving(player)
if skeletons[player] then
    for _, line in pairs(skeletons[player]) do
        line:Remove()
    end
    skeletons[player] = nil
end
end

for _, player in ipairs(game.Players:GetPlayers()) do
if player ~= game.Players.LocalPlayer then
    drawSkeleton(player)
end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(onPlayerRemoving)

game:GetService("RunService").RenderStepped:Connect(function()
for player, _ in pairs(skeletons) do
    drawSkeleton(player)
end
end)
local userInputService = game:GetService("UserInputService")

local tracerCache = {}
local TracerColor = newColor3(1,1,1)
local TracerTransparency = 0.5
local TracerThickness = 1
local TracerEnabled = false
local SelectedTracerMode = "Over Head"
local SelectCharacterPart = "Head"

local modes = {
["From Screen"] = function()
    return newVector2(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
end,
["From Mouse"] = function()
    local mouseLocation = userInputService:GetMouseLocation()
    return newVector2(mouseLocation.X, mouseLocation.Y)
end,
["From Character"] = function()
    local character = localPlayer.Character
    if character and character:FindFirstChild(SelectCharacterPart) then
        local partPos = camera:WorldToViewportPoint(character[SelectCharacterPart].Position)
        return newVector2(partPos.X, partPos.Y)
    end
    return newVector2(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
end,
["Over Head"] = function()
    local character = localPlayer.Character
    if character and character:FindFirstChild("Head") then
        local headPos = camera:WorldToViewportPoint(character.Head.Position + Vector3.new(0, 25, 0))
        return newVector2(headPos.X, headPos.Y)
    end
    return newVector2(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
end,
}

local function createTracer()
local tracer = newDrawing("Line")
tracer.Thickness = TracerThickness
tracer.Color = TracerColor
tracer.Transparency = TracerTransparency
return tracer
end

local function updateTracers()
if not TracerEnabled then
    for _, tracer in pairs(tracerCache) do
        tracer.Visible = false
    end
    return
end

local modeFunc = modes[SelectedTracerMode]
if modeFunc then
    local fromPos = modeFunc()
    for player, tracer in pairs(tracerCache) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if targetPos.Z > 0 then
                tracer.From = fromPos
                tracer.To = newVector2(targetPos.X, targetPos.Y)
                tracer.Visible = true
                tracer.Thickness = TracerThickness
                tracer.Color = TracerColor
                tracer.Transparency = TracerTransparency
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end
else
    warn("Selected tracer mode function is not defined:", SelectedTracerMode)
end
end
for _, player in ipairs(players:GetPlayers()) do
if player ~= localPlayer then
    tracerCache[player] = createTracer()
end
end

players.PlayerAdded:Connect(function(player)
if player ~= localPlayer then
    tracerCache[player] = createTracer()
end
end)

players.PlayerRemoving:Connect(function(player)
if tracerCache[player] then
    tracerCache[player]:Remove()
    tracerCache[player] = nil
end
end)
runService.RenderStepped:Connect(updateTracers)
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

local newVector2 = Vector2.new
local newColor3 = Color3.new
local newDrawing = Drawing.new

local espCache = {}
local _3DColor = Color3.new(1, 0, 0)
local _3DThickness = 2
local _3DTransparency = 1
local ESPEnabled = false

local function createOrUpdateBoxEsp(player)
if player == localPlayer then return end

local function updateEspBox(character)
    if not espCache[player] then
        espCache[player] = {}
        for i = 1, 12 do
            local line = newDrawing("Line")
            line.Color = _3DColor
            line.Thickness = _3DThickness
            line.Transparency = _3DTransparency
            table.insert(espCache[player], line)
        end
    end
    
    local lines = espCache[player]

    local primaryPart = character.PrimaryPart
    if not primaryPart then
        for _, line in ipairs(lines) do
            line.Visible = false
        end
        return
    end
    
    local size = character:GetExtentsSize()
    local cframe = character:GetModelCFrame()
    local halfSize = size / 2

    local corners = {
        cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
        cframe * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
        cframe * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
        cframe * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z)
    }

    local screenCorners = {}
    local onScreen = false
    
    for _, corner in ipairs(corners) do
        local screenPos, visible = camera:WorldToViewportPoint(corner)
        table.insert(screenCorners, newVector2(screenPos.X, screenPos.Y))
        if visible then
            onScreen = true
        end
    end

    if not onScreen then
        for _, line in ipairs(lines) do
            line.Visible = false
        end
        return
    end

    local connections = {
        {1, 2}, {2, 4}, {4, 3}, {3, 1},
        {5, 6}, {6, 8}, {8, 7}, {7, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }

    for i, conn in ipairs(connections) do
        local line = lines[i]
        line.From = screenCorners[conn[1]]
        line.To = screenCorners[conn[2]]
        line.Visible = ESPEnabled  -- Check if ESP is enabled
    end
end

local function onCharacterAdded(character)
    local espConnection
    espConnection = runService.RenderStepped:Connect(function()
        if not player.Parent or not character.Parent then
            for _, line in ipairs(espCache[player] or {}) do
                line:Remove()
            end
            espCache[player] = nil
            if espConnection then
                espConnection:Disconnect()
            end
            return
        end
        updateEspBox(character)
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end
end

-- Connect function to player added and removing events
players.PlayerAdded:Connect(function(player)
createOrUpdateBoxEsp(player)
player.CharacterRemoving:Connect(function(character)
    if espCache[player] then
        for _, line in ipairs(espCache[player]) do
            line:Remove()
        end
        espCache[player] = nil
    end
end)
end)

players.PlayerRemoving:Connect(function(player)
if espCache[player] then
    for _, line in ipairs(espCache[player]) do
        line:Remove()
    end
    espCache[player] = nil
end
end)
local function toggleESP(enabled)
ESPEnabled = enabled
for player, lines in pairs(espCache) do
    for _, line in ipairs(lines) do
        line.Visible = enabled
    end
end
end
local Games = {
[2788229376]                     = {Name = "Da Hood", Arg = "UpdateMousePosI", Remote = "MainEvent"},
[16033173781]                    = {Name = "Da Hood Macro", Arg = "UpdateMousePosI", Remote = "MainEvent"},
[7213786345]                     = {Name = "Da Hood VC", Arg = "UpdateMousePosI", Remote = "MainEvent"},
[9825515356]                     = {Name = "Hood Customs", Arg = "MousePosUpdate", Remote = "MainEvent"},
[5602055394]                     = {Name = "Hood Modded", Arg = "MousePos", Remote = "Bullets"},
[7951883376]                     = {Name = "Hood Modded VC", Arg = "MousePos", Remote = "Bullets"},
[9183932460]                     = {Name = "Untitled Hood", Arg = "UpdateMousePos", Remote = ".gg/untitledhood"},
[17403265390]                    = {Name = "Da Downhill", Arg = "MOUSE", Remote = "MAINEVENT"},
[14412601883]                    = {Name = "Hood Bank", Arg = "MOUSE", Remote = "MAINEVENT"},
[18111448661]                    = {Name = "Da Uphill", Arg = "MOUSE", Remote = "MAINEVENT"},
[14487637618]                    = {Name = "Da Hood Bot Aim Trainer", Arg = "MOUSE", Remote = "MAINEVENT"},
[11143225577]                    = {Name = "1v1 Hood Aim Trainer", Arg = "UpdateMousePos", Remote = "MainEvent"},
[14413712255]                    = {Name = "Hood Aim", Arg = "MOUSE", Remote = "MAINEVENT"},
[17714122625]                    = {Name = "Dah Aim Trainer", Arg = "UpdateMousePos", Remote = "MainEvent"},
[12867571492]                    = {Name = "Katana Hood", Arg = "UpdateMousePos", Remote = "MainEvent"},
[11867820563]                    = {Name = "Dae Hood", Arg = "UpdateMousePos", Remote = "MainEvent"},
[17109142105]                    = {Name = "Da Battles", Arg = "MoonUpdateMousePos", Remote = "MainEvent"},
[15186202290]                    = {Name = "Da Strike", Arg = "MOUSE", Remote = "MAINEVENT"},
[16469595315]                    = {Name = "Del Hood Aim", Arg = "UpdateMousePos", Remote = "MainEvent"},
[17319408836]                    = {Name = "OG Da Hood", Arg = "UpdateMousePos", Remote = "MainEvent"},
[14975320521]                    = {Name = "Ar Hood", Arg = "UpdateMousePos", Remote = "MainEvent"},
[17200018150]                    = {Name = "Hood Of AR", Arg = "UpdateMousePos", Remote = "MainEvent"},
}

local function UpdateOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
if getgenv().OrbitShape == "Square" then
    return OrbitingLibrary.SquareOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Triangle" then
    return OrbitingLibrary.TriangleOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Circle" then
    return OrbitingLibrary.CircleOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Heart" then
    return OrbitingLibrary.HeartOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Hexagon" then
    return OrbitingLibrary.HexagonOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Decagon" then
    return OrbitingLibrary.DecagonOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
elseif getgenv().OrbitShape == "Pentagon" then
    return OrbitingLibrary.PentagonOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
else
    return OrbitingLibrary.CircleOrbit(TargetPosition, OrbitRadius, AngleOffset, HeightOffset)
end
end


local function onToolActivated(tool)
if tool:IsA("Tool") then
    tool.Activated:Connect(function()
        if getgenv().AutoShootEnabled and TargetPlayer then
            tool:Activate()
            task.wait(0.1)
        end
    end)
end
end
local Smoothnesss = 0.1
local CurrentHeightOffset = 0

local function UpdateTransparentPartPosition(TargetPosition, Distance, HeightOffset, StrafeSpeed)
local TargetDirection = (TargetPosition - LocalPlayer.Character.PrimaryPart.Position).Unit
local Offset = TargetDirection * Distance
local TransparentPartPosition           = TargetPosition + Vector3.new(0, HeightOffset, 0) - Offset

if not TransparentPart or not TransparentPart.Parent then
    TransparentPart                     = Instance.new("Part")
    TransparentPart.Size                = Vector3.new(2, 0.2, 2)
    TransparentPart.Transparency        = 1
    TransparentPart.CanCollide          = false 
    TransparentPart.Anchored            = true
    TransparentPart.Parent              = game.Workspace
end

TransparentPart.Position                = TransparentPartPosition
end

local function SmoothHeightOffset(HeightOffset)
CurrentHeightOffset = CurrentHeightOffset + (HeightOffset - CurrentHeightOffset) * Smoothnesss
return CurrentHeightOffset
end

RunService.Stepped:Connect(function()
if not getgenv().TargetStrafeEnabled or not SelectedPart then 
    return 
end

if TargetAimEnabled and TargetPlayer and TargetPlayer.Character then
    local strafeSpeed = getgenv().StrafeSpeed or 5
    local targetPart = TargetPlayer.Character:FindFirstChild(SelectedPart)
    if not targetPart then 
        return 
    end

    local targetPosition = targetPart.Position
    local playerCharacter = LocalPlayer.Character
    local playerPrimaryPart = playerCharacter and playerCharacter.PrimaryPart
    local playerPosition = playerPrimaryPart and playerPrimaryPart.Position
    if not playerPosition then 
        return 
    end

    local distance = (targetPosition - playerPosition).Magnitude
    local maxOrbitRadius = getgenv().Distance or 5
    local targetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local orbitRadiusMultiplier = targetHumanoid and targetHumanoid.Health < 4 and 6 or 3
    local orbitRadius = math.min(maxOrbitRadius, distance * orbitRadiusMultiplier)
    local angleOffset = tick() * strafeSpeed
    local desiredHeightOffset = getgenv().HeightOffset or 5
    local smoothedHeightOffset = SmoothHeightOffset(desiredHeightOffset)

    UpdateTransparentPartPosition(targetPosition, distance, smoothedHeightOffset, strafeSpeed)

    local newPosition = UpdateOrbit(targetPosition, orbitRadius, angleOffset, smoothedHeightOffset)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {playerCharacter, Workspace}
    local result = Workspace:Raycast(playerPosition, (newPosition - playerPosition).Unit * orbitRadius, raycastParams)
    if result then
        newPosition = result.Position - (newPosition - result.Position).Unit * 2
    end

    local playerHumanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
    if playerHumanoid and playerHumanoid.Health > 0 then
        playerCharacter.HumanoidRootPart.CFrame = CFrame.new(newPosition) * CFrame.Angles(0, math.rad(strafeSpeed), 0)
            + Vector3.new(0, smoothedHeightOffset, 0)
    end
else
    getgenv().TargetStrafeEnabled = false
end

if Auto_Stomp and TargetPlayer and TargetPlayer.Character then
    local targetHumanoid = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local targetHRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP and targetHumanoid and targetHumanoid.Health < 4 then
        local upperTorso = TargetPlayer.Character:FindFirstChild("UpperTorso")
        if upperTorso then
            playerCharacter.HumanoidRootPart.CFrame = upperTorso.CFrame
            wait(2)
            local event = game:GetService("ReplicatedStorage"):FindFirstChild(EventN)
            if event then
                event:FireServer(TargetPlayer)
            end
        end
    end
end

AutoShoot()
end)

local function WallCheck(destination, ignore)
local Origin = CurrentCamera.CFrame.p
local CheckRay = Ray.new(Origin, destination - Origin)
local Hit = Workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
return Hit == nil
end
local function getClosestPlayerToCursor()
local closestDist = FOVCircle.Radius
local closestPlr = nil
for _, v in ipairs(Players:GetPlayers()) do
    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
        local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
        if onScreen then
            local distToMouse = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if distToMouse < closestDist and WallCheck(v.Character.Head.Position, {LocalPlayer, v.Character}) then
                local hasBodyEffects = v.Character:FindFirstChild("BodyEffects") and not v.Character.BodyEffects:FindFirstChild("K.O")
                local hasGrabbingConstraint = not v.Character:FindFirstChild("GRABBING_COINSTRAINT")
                if (not hasBodyEffects or not hasGrabbingConstraint) then
                    closestPlr = v
                    closestDist = distToMouse
                end
            end
        end
    end
end
return closestPlr
end
local function SilentAimToggle(bool)
SilentAimEnabled = bool
if bool then
    TargetAimToggle(false)
end
end  

local function TargetAimToggle(bool)
TargetAimEnabled = bool
if bool then
    SilentAimToggle(false)
    TargetPlayer = getClosestPlayerToCursor()
    if TargetPlayer then
        Menu.Notify("Target Aim | Targeting: "..TargetPlayer.Name, 3)
    else
        Menu.Notify("Target Aim | Player Not Found within FOV", 3)
    end
else
    TargetPlayer = nil
    Menu.Notify("Target Aim | Disabled", 3)
end
end

local function UpdateCheck()
if game.PlaceId == 2788229376 then
    local Info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    local CurrentVersion = Info.Updated
    local ScriptVersion = "2024-06-12T03:13:10.12Z"
    
    print("[⚙️ 208; Version]: Current Game Version:", tostring(CurrentVersion))
    print("[⚙️ 208; Version]: Script Updated to Version", ScriptVersion)
    
    if tostring(CurrentVersion) ~= ScriptVersion then
        LocalPlayer:Kick("[⚙️ 208; Version]: 208.rip isn't updated to this new version yet. Wait for Update @ discord.gg/desync")
    else
        print("[⚙️ 208; Version]: Version check passed. The script is up to date.")
    end
else
    print("[⚙️ 208; System]: Checked only for Da Hood.")
end
end

local function Load()
loadstring(game:HttpGet("https://raw.githubusercontent.com/firm0001/uwu/main/dependencies/unc.lua"))()
UpdateCheck()
end

repeat
wait()
until game:IsLoaded()

if game:IsLoaded() then
Load()
end

getgenv().LookAt = false
getgenv().EVC = false
getgenv().EFC = false
getgenv().ECC = false
getgenv().EDC = false
getgenv().EGC = false
getgenv().ClosestPointEnabled = false
getgenv().ClosestPartEnabled = false

local cachedFriends = nil
local friendsFetched = false

local function isFriend(player)
if not friendsFetched then
    local success, friendPages = pcall(function()
        return Players:GetFriendsAsync(LocalPlayer.UserId)
    end)
    
    if success then
        cachedFriends = {}
        for _, friendPage in ipairs(friendPages:GetCurrentPage()) do
            for _, friend in ipairs(friendPage) do
                table.insert(cachedFriends, friend.Id)
            end
        end
        friendsFetched = true
    else
        warn("Failed to get friends:", friendPages)
        return false
    end
end

for _, friendId in ipairs(cachedFriends) do
    if friendId == player.UserId then
        return true
    end
end

return false
end

local function getSelectedPart(player)
if player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and getgenv().AirPartEnabled then
        if humanoid.FloorMaterial == Enum.Material.Air then
            return getgenv().SelectedAirPart
        end
    end
end
return SelectedPart
end
local function getClosestPart(player)
local closestDistance = 1 / 0
local nearestHitPart = nil
local mousePos = UserInputService:GetMouseLocation()
local closestPartPosition = nil

for _, part in ipairs(player.Character:GetChildren()) do
    if part:IsA("BasePart") then
        local screenPos, isVisible = CurrentCamera:WorldToViewportPoint(part.Position)
        screenPos = Vector2.new(screenPos.X, screenPos.Y)
        if isVisible then
            local distance = (screenPos - mousePos).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                nearestHitPart = part
            end
        end
    end
end

if nearestHitPart then
    closestPartPosition = nearestHitPart.Position
end

return closestPartPosition
end


local function isValidTarget(player)
if getgenv().EVC then
    local screenPos, isVisible = CurrentCamera:WorldToViewportPoint(player.Character[SelectedPart].Position)
    if not isVisible then
        return false
    end
end

if getgenv().EFC and isFriend(player) then
    return false
end

if getgenv().ECC then
    local isInCrew = false
    if isInCrew then
        return false
    end
end

if getgenv().EDC then
    local hasBodyEffects = player.Character:FindFirstChild("BodyEffects")
    local isDead = hasBodyEffects and hasBodyEffects:FindFirstChild("K.O")
    if isDead then
        return false
    end
end

if getgenv().EGC then
    local hasGrabbingConstraint = player.Character:FindFirstChild("GRABBING_CONSTRAINT")
    if hasGrabbingConstraint then
        return false
    end
end

return true
end

local function onToolActivated(tool)
if tool:IsA("Tool") then
    tool.Activated:Connect(function()
        local aimPos, predictedPos
        local AGS = getgenv().AGS or false
        local Plr
        
        if TargetAimEnabled and TargetPlayer then
            if isValidTarget(TargetPlayer) then
                if getgenv().ClosestPartEnabled then
                    aimPos = getClosestPart(TargetPlayer).CFrame
                    if aimPos then
                        predictedPos = aimPos.Position + (TargetPlayer.Character[SelectedPart].Velocity * (getgenv().Prediction or 0.1))
                    end
                else
                    local selectedPart = TargetPlayer.Character:FindFirstChild(getSelectedPart(TargetPlayer))
                    if selectedPart then
                        aimPos = selectedPart.CFrame
                        predictedPos = aimPos.Position + (selectedPart.Velocity * (getgenv().Prediction or 0.1))
                    end
                end

                if getgenv().LookAt then
                    local playerCharacter = LocalPlayer.Character
                    if playerCharacter then
                        local humanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, aimPos.Position)
                        end
                    end
                end
            end
        elseif SilentAimEnabled then
            Plr = getClosestPlayerToCursor()
            if Plr and isValidTarget(Plr) then
                if getgenv().ClosestPartEnabled then
                    aimPos = getClosestPart(Plr)
                    if aimPos then
                        predictedPos = aimPos + (Plr.Character[SelectedPart].Velocity * (getgenv().Prediction or 0.1))
                    end
                else
                    local selectedPart = Plr.Character:FindFirstChild(getSelectedPart(Plr))
                    if selectedPart then
                        aimPos = selectedPart.CFrame
                        predictedPos = aimPos.Position + (selectedPart.Velocity * (getgenv().Prediction or 0.1))
                    end
                end
            end
        end
        
        if AGS then
            local targetRootPart = (TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart")) or
                                   (Plr and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart"))
            if targetRootPart then
                if targetRootPart.Velocity.Y < -20 then
                    pcall(function()
                        targetRootPart.Velocity = Vector3.new(targetRootPart.Velocity.X, 0, targetRootPart.Velocity.Z)
                        targetRootPart.AssemblyLinearVelocity = Vector3.new(targetRootPart.Velocity.X, 0, targetRootPart.Velocity.Z)
                    end)
                end
            end
        end        
        if aimPos and predictedPos then
            if game.PlaceId == 9825515356 then
                predictedPos = predictedPos + Vector3.new(25, 100, 25)
            end
            local GameInfo = Games[game.PlaceId]
            if GameInfo then
                local PMethod = GameInfo.Arg or "UpdateMousePos"
                local Remote = GameInfo.Remote or "MainEvent"
                local RemoteEvent = ReplicatedStorage:FindFirstChild(Remote)
                if RemoteEvent then
                    RemoteEvent:FireServer(PMethod, predictedPos)
                end
            end
        end
    end)
end
end

LocalPlayer.CharacterAdded:Connect(function(character)
character.ChildAdded:Connect(onToolActivated)
end)

if LocalPlayer.Character then
LocalPlayer.Character.ChildAdded:Connect(onToolActivated)
end

local ResolverVersion = "Recalculate"
local Interval = 0.1

Skibidi = getgenv().Skibidi
-- Initialization
local loaded = false
local xuaaLoader = Instance.new("ScreenGui")
xuaaLoader.Name = "Summon"
xuaaLoader.Parent = game.CoreGui
xuaaLoader.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Background Frame
local background = Instance.new("Frame")
background.Name = "Background"
background.Parent = xuaaLoader
background.AnchorPoint = Vector2.new(0.5, 0.5)
background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
background.BorderSizePixel = 0
background.Position = UDim2.new(0.5, 0, 0.5, 0)
background.Size = UDim2.new(0, 641, 0, 316)

-- Title Label
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = background
title.BackgroundTransparency = 1
title.Position = UDim2.new(0.018, 0, 0, 0)
title.Size = UDim2.new(0, 376, 0, 27)
title.Font = Enum.Font.Code
title.Text = "208.rip | Dev"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

-- Holder Frame
local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.Parent = background
holder.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
holder.BorderColor3 = Color3.fromRGB(30, 30, 30)
holder.BorderSizePixel = 2
holder.Position = UDim2.new(0.018, 0, 0.085, 0)
holder.Size = UDim2.new(0, 617, 0, 276)

local loadingBar = Instance.new("Frame")
loadingBar.Parent = holder
loadingBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
loadingBar.BorderColor3 = Color3.fromRGB(30, 30, 30)
loadingBar.BorderSizePixel = 2
loadingBar.Position = UDim2.new(0.013, 0, 0.859, 0)
loadingBar.Size = UDim2.new(0, 600, 0, 29)

local bar = Instance.new("Frame")
bar.Parent = loadingBar
bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bar.BorderSizePixel = 0
bar.Size = UDim2.new(0, 0, 1, 0)

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
 ColorSequenceKeypoint.new(0, Color3.fromRGB(53, 26, 74)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 85, 235))
}
uiGradient.Rotation = -90
uiGradient.Parent = bar

local changelog = Instance.new("Frame")
changelog.Parent = holder
changelog.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
changelog.BorderColor3 = Color3.fromRGB(30, 30, 30)
changelog.BorderSizePixel = 2
changelog.Position = UDim2.new(0.013, 0, 0.042, 0)
changelog.Size = UDim2.new(0, 600, 0, 198)

local changelogTitle = Instance.new("TextLabel")
changelogTitle.Parent = changelog
changelogTitle.BackgroundTransparency = 1
changelogTitle.Position = UDim2.new(0, 0, -0.067, 0)
changelogTitle.Size = UDim2.new(0, 86, 0, 22)
changelogTitle.Font = Enum.Font.Code
changelogTitle.Text = "Changelog"
changelogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
changelogTitle.TextSize = 14
changelogTitle.TextXAlignment = Enum.TextXAlignment.Left

local changelogEntries = Instance.new("Frame")
changelogEntries.Parent = changelog
changelogEntries.BackgroundTransparency = 1
changelogEntries.Position = UDim2.new(0.015, 0, 0.056, 0)
changelogEntries.Size = UDim2.new(0, 583, 0, 178)
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = changelogEntries
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local progressText = Instance.new("TextLabel")
progressText.Parent = holder
progressText.BackgroundTransparency = 1
progressText.Position = UDim2.new(0.024, 0, 0.864, 0)
progressText.Size = UDim2.new(0, 150, 0, 25)
progressText.Font = Enum.Font.Code
progressText.Text = ""
progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
progressText.TextSize = 16
progressText.TextXAlignment = Enum.TextXAlignment.Left

local statusText = Instance.new("TextLabel")
statusText.Parent = holder
statusText.BackgroundTransparency = 1
statusText.Position = UDim2.new(0.013, 0, 0.759, 0)
statusText.Size = UDim2.new(0, 599, 0, 27)
statusText.Font = Enum.Font.Code
statusText.Text = ""
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextSize = 16

local function addChangelogEntry(add, text, date)
 local update = Instance.new("TextLabel")
 update.Parent = changelogEntries
 update.BackgroundTransparency = 1
 update.Size = UDim2.new(0, 583, 0, 22)
 update.Font = Enum.Font.Code
 if add then
     update.Text = "[+] " .. text .. " - " .. date
 else
     update.Text = "[-] " .. text .. " - " .. date
 end
 update.TextColor3 = Color3.fromRGB(255, 255, 255)
 update.TextSize = 14
 update.TextXAlignment = Enum.TextXAlignment.Left
end
local function injectScript()
 for i = 1, 100 do
     wait(0.02)
     progressText.Text = "Loading: " .. i .. "%"
     local formula = i / 100
     bar:TweenSize(UDim2.new(formula, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
     
     if i == 25 then
         statusText.Text = "Detecting Game"
     elseif i == 50 then
         statusText.Text = "Game Supported"
     elseif i == 60 then
         statusText.Text = "Injecting steroids"
         delay(2, function()
             if not bypassed then
                 game.Players.LocalPlayer:Kick("You Died.")
             end
         end)
         bypassed = true
     elseif i == 70 then
         statusText.Text = "Injected Steroids!"
     elseif i == 80 then
         statusText.Text = "Loading additional resources"
     elseif i == 90 then
         statusText.Text = "Welcome, " .. tostring(game.Players.LocalPlayer.Name)
     elseif i == 100 then
         wait(2)
         delay(10, function()
             if not loaded then
                 game.Players.LocalPlayer:Kick("208.rip | Dev failed to load correctly, please rejoin.")
             end
         end)
         loaded = true
         xuaaLoader:Destroy()
     end
 end
end
local function startInjection()
 addChangelogEntry(true, "208.rip | Release", "06/20/24")
 addChangelogEntry(true, "Full Rewrite", "06/20/24")
 addChangelogEntry(true, "Streamable + Undetected >_<", "06/20/24")
 addChangelogEntry(true, "Better Security!", "06/20/24")
 addChangelogEntry(true, "Actual Bypass 4 Camlock Detection >_<", "06/20/24")
 statusText.Text = "Injecting.."
 Menu:SetVisible(false)
 injectScript()
 task.wait()
 Menu:SetVisible(true)
Menu.Notify("208.rip has been Injected!", 5)
 Menu:Init()
end
coroutine.wrap(startInjection)()
Menu:SetSize(680, 560)
Menu.Tab("Main")
Menu.Tab("Target")
Menu.Tab("Visuals")
Menu.Tab("Settings")
local Version = "Version 5"
local versionNumber = tonumber(Version:match("%d+"))
if versionNumber and versionNumber < 5 then
 LocalPlayer:Kick("Using Wrong Version!")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui
screenGui.Enabled = false

local titleLabel = Instance.new("TextLabel", screenGui)
titleLabel.Size = UDim2.new(0, 200, 0, 20)
titleLabel.Position = UDim2.new(0, 10, 0, 20)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.TextTransparency = 0.5
titleLabel.Font = Enum.Font.Code
titleLabel.TextScaled = true
titleLabel.Text = "208.rip beta | .gg/NR"

local predictionLabel = Instance.new("TextLabel", screenGui)
predictionLabel.Size = UDim2.new(0, 200, 0, 20)
predictionLabel.Position = UDim2.new(0, 10, 0, 40)
predictionLabel.TextColor3 = Color3.new(1, 1, 1)
predictionLabel.BackgroundTransparency = 1
predictionLabel.TextTransparency = 0.5
predictionLabel.Font = Enum.Font.Code
predictionLabel.TextScaled = true
predictionLabel.Text = "Prediction: 0"

local camlockPredictionLabel = Instance.new("TextLabel", screenGui)
camlockPredictionLabel.Size = UDim2.new(0, 200, 0, 20)
camlockPredictionLabel.Position = UDim2.new(0, 10, 0, 60)
camlockPredictionLabel.TextColor3 = Color3.new(1, 1, 1)
camlockPredictionLabel.BackgroundTransparency = 1
camlockPredictionLabel.TextTransparency = 0.5
camlockPredictionLabel.Font = Enum.Font.Code
camlockPredictionLabel.TextScaled = true
camlockPredictionLabel.Text = "Camlock Prediction: 0"

local function calculatePrediction(ping, version)
if version == "Default" then
    return ping / 225 * 0.1 + 0.1
elseif version == "Old Method" then
    return ping < 130 and ping / 1000 + 0.037 or ping / 1000 + 0.033
elseif version == "New Method" then
    return 0.1 + ping / 2000 + (ping / 1000) * (ping / 1500) * 1.025
elseif version == "Best Method" then
    if ping < 130 then
        return ping / 1000 + 0.037
    else
        return ping / 1000 + 0.033
    end
elseif version == "Normal" then
    if ping < 30 then
        return 0.11252476
    elseif ping < 40 then
        return 0.11
    elseif ping < 50 then
        return 0.13544
    elseif ping < 60 then
        return 0.12
    elseif ping < 70 then
        return 0.12533
    elseif ping < 80 then
        return 0.13934
    elseif ping < 90 then
        return 0.135
    elseif ping < 100 then
        return 0.141987
    elseif ping < 110 then
        return 0.145
    elseif ping < 120 then
        return 0.15
    elseif ping < 130 then
        return 0.155
    elseif ping < 140 then
        return 0.16
    elseif ping < 150 then
        return 0.165
    elseif ping < 160 then
        return 0.17
    elseif ping < 170 then
        return 0.175
    elseif ping < 180 then
        return 0.18
    elseif ping < 190 then
        return 0.185
    elseif ping < 200 then
        return 0.19
    else
        return 0.2
    end
else
    return ping / 225 * 0.1 + 0.1
end
end

local function updatePredictionLabel(predValue, isCamlock)
 if isCamlock then
     camlockPredictionLabel.Text = "Camlock Prediction: " .. tostring(predValue)
 else
     predictionLabel.Text = "Prediction: " .. tostring(predValue)
 end
end

local function handlePrediction(getgenvKey, predictionVersionKey, labelUpdate, isCamlock)
 while true do
     if getgenv()[getgenvKey] then
         local ping = tonumber(string.split(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString(), '(')[1])
         if ping then
             local predValue = calculatePrediction(ping, getgenv()[predictionVersionKey])
             getgenv()[labelUpdate] = predValue
             updatePredictionLabel(predValue, isCamlock)
         end
     end
     wait(1)
 end
end

Menu:SetTitle("208.rip | Dev | " .. Version)

Menu.Container("Main", "Silent", "Left")
Menu.Container("Main", "Strafe", "Left")
Menu.Container("Main", "Prediction", "Left")
Menu.Container("Main", "Camlock", "Right")
Menu.Container("Main", "Configuration", "Right")
Menu.Container("Main", "Checks", "Right")
Menu.Container("Main", "Client Configuration", "Right")
Menu.Container("Settings", "Config", "Left")
Menu.Container("Visuals", "Esp", "Left")
Menu.Container("Visuals", "Tracer Configuration", "Left")
Menu.Container("Visuals", "3D Box Configuration", "Left")
Menu.Container("Visuals", "FOV", "Right")

Menu.Hotkey("Settings", "Config", "Menu Keybind", false, function(x)
 Skibidi.MenuKeybind = x
end)

Menu.CheckBox("Visuals", "Esp", "2D Box ESP", false, function(x)
 getgenv().ESP = x
end)
Menu.CheckBox("Visuals", "Esp", "3D Box ESP", false, function(x)
toggleESP(x)
end)
for _, player in ipairs(players:GetPlayers()) do
createOrUpdateBoxEsp(player)
end
Menu.CheckBox("Visuals", "Esp", "Skeleton ESP", false, function(x)
getgenv().SkeletonESP = x
end)
Menu.CheckBox("Visuals", "Esp", "Name ESP", settings.NameESP, function(x)
settings.NameESP = x
end)

Menu.CheckBox("Visuals", "Esp", "Health Bar ESP", settings.HealthBar, function(x)
settings.HealthBar = x
end)

Menu.CheckBox("Visuals", "Esp", "Studs ESP", settings.Studs, function(x)
settings.Studs = x
end)
Menu.CheckBox("Visuals", "Tracer Configuration", "Tracer(s) Enabled", false, function(x)
TracerEnabled = x
end)
Menu.ComboBox("Visuals", "Tracer Configuration", "Selected Tracer Mode...", "", {"From Screen", "From Mouse", "From Character", "Over Head"}, function(option)
SelectedTracerMode = option
end)
Menu.ComboBox("Visuals", "Tracer Configuration", "Select Part for From Character", "", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, function(option)
SelectCharacterPart = option
end)
Menu.Slider("Visuals", "Tracer Configuration", "Tracer | Transparency", 0, 1, 0.5, "", 1, function(value)
TracerTransparency = value
end)
Menu.Slider("Visuals", "Tracer Configuration", "Tracer | Thickness", 0, 10, 1, "", 1, function(value)
TracerThickness = value
end)
Menu.ColorPicker("Visuals", "Tracer Configuration", "Tracer | Color", nil, 1, function(color, alpha)
TracerColor = color
end)
Menu.Slider("Visuals", "3D Box Configuration", "3D Box | Transparency", 0, 1, 0.5, "", 1, function(value)
_3DTransparency = value
end)

Menu.Slider("Visuals", "3D Box Configuration", "3D Box | Thickness", 0, 10, 1, "", 1, function(value)
_3DThickness = value
end)

Menu.ColorPicker("Visuals", "3D Box Configuration", "3D Box | Color", nil, 1, function(color, alpha)
_3DColor = color
end)
Menu.ComboBox("Main", "Configuration", "Select Target Constant Hit Part...", "", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, function(option)
SelectedPart = option
end)
Menu.ComboBox("Main", "Configuration", "Select Multi Target Hit Part...", "", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, function(option)
SelectedPart = option
end)

Menu.ComboBox("Main", "Prediction", "Silent | Auto Pred Method", "", {"Default", "Old Method", "New Method", "Normal"}, function(option)
 if option then
     getgenv().AutoPredictionVersion = option
     if getgenv().AutoPred then
         handlePrediction('AutoPred', 'AutoPredictionVersion', 'Prediction', false)
     end
 end
end)

Menu.ComboBox("Main", "Prediction", "Camlock | Auto Pred Method", "", {"Default", "Best Method", "New Method", "Normal"}, function(option)
 if option then
     getgenv().CamlockPredictionVersion = option
     if getgenv().CamlockPred then
         handlePrediction('CamlockPred', 'CamlockPredictionVersion', 'CamlockPrediction', true)
     end
 end
end)

Menu.CheckBox("Main", "Prediction", "Silent | Auto Pred", false, function(Value)
 getgenv().AutoPred = Value
 if Value then
     handlePrediction('AutoPred', 'AutoPredictionVersion', 'Prediction', false)
 end
end)

Menu.CheckBox("Main", "Prediction", "Camlock | Auto Pred", false, function(Value)
 getgenv().CamlockPred = Value
 if Value then
     handlePrediction('CamlockPred', 'CamlockPredictionVersion', 'CamlockPrediction', true)
 end
end)

Menu.TextBox("Main", "Prediction", "Custom Silent Predictions", "0.6969", function(Value)
 getgenv().Prediction = Value
 updatePredictionLabel(Value, false)
end)

Menu.TextBox("Main", "Prediction", "Custom Camlock Predictions", "0.6969", function(Value)
 getgenv().CamlockPrediction = Value
 updatePredictionLabel(Value, true)
end)

Menu.CheckBox("Main", "Prediction", "Show Pred Stats", false, function(Value)
 screenGui.Enabled = Value
end)

Menu.CheckBox("Main", "Silent", "Enabled", false, function(Value)
getgenv().Silent = Value
if Value then
    if getgenv().SilentSelected == 'Target' then
        TargetAimToggle(true)
    else
        SilentAimToggle(true)
    end
else
    TargetAimToggle(false)
    SilentAimToggle(false)
end
end)

Menu.CheckBox("Main", "Silent", "Enable Closest Part", false, function(Value)
getgenv().ClosestPartEnabled = Value
end)

Menu.ComboBox("Main", "Silent", "Select Silent Method...", "", {"FOV", "Target"}, function(x)
getgenv().SilentSelected = x
if getgenv().Silent then
    if x == 'Target' then
        SilentAimToggle(false)
        TargetAimToggle(true)
    else
        TargetAimToggle(false)
        SilentAimToggle(true)
    end
end
end)

Menu.Hotkey("Main", "Silent", "Target Aim | Keybind", Enum.KeyCode.Z, function(value)
getgenv().TargetAimBind = value
end)

local function HandleTargetAimToggle(input, gameProcessedEvent)
if input.KeyCode == getgenv().TargetAimBind and not gameProcessedEvent then
    local newState = not TargetAimEnabled
    TargetAimToggle(newState)
end
end

UserInputService.InputBegan:Connect(HandleTargetAimToggle)
Menu.CheckBox("Main", "Silent", "Enable Anti-Ground Shots", false, function(Value)
 getgenv().LookAt = Value
end)

Menu.CheckBox("Main", "Silent", "Enable Look-At", false, function(Value)
 getgenv().AGS = Value
end)

Menu.CheckBox("Main", "Client Configuration", "Resolver", false, function(x)
 Skibidi.Resolver = x
end)

Menu.TextBox("Main", "Client Configuration", "Resolver Interval", "0.1", function(x)
 Interval = x
end)

Menu.ComboBox("Main", "Client Configuration", "Resolver Version", "Recalculate", {"Recalculate", "MoveDirection"}, function(x)
 ResolverVersion = x
end)

Menu.Button("Main", "Client Configuration", "Bypass Camlock AC", function()
 for _, con in ipairs(workspace.CurrentCamera.Changed:GetConnections()) do
     task.wait()
     con:Disable()
 end
 for _, con in ipairs(workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):GetConnections()) do
     task.wait()
     con:Disable()
 end
end)

Menu.CheckBox("Visuals", "FOV", "Draw FOV", false, function(Value)
 FOVCircle.Visible = Value
end)

Menu.CheckBox("Visuals", "FOV", "Fill FOV", false, function(Value)
 FOVCircle.Filled = Value
end)

Menu.Slider("Visuals", "FOV", "FOV | Radius", 0, 100, 50, "", 0, function(value)
 FOVCircle.Radius = value * 3
end)

Menu.Slider("Visuals", "FOV", "FOV | Transparency", 0, 1, 0.5, "", 1, function(value)
 FOVCircle.Transparency = value
end)

Menu.Slider("Visuals", "FOV", "FOV | Thickness", 0, 10, 5, "", 0, function(value)
 FOVCircle.Thickness = value
end)
Menu.ColorPicker("Visuals", "FOV", "FOV | Color", nil, 1, function(color, alpha)
    FOVCircle.Color = color
end)

local CamlockConnect = nil
local shakeOffset = Vector3.new(0, 0, 0)
local EasingStyles = Enum.EasingStyle
local LockedOpp = nil
local SelectedEasing = nil

local function getSelectedPart(player)
 if player.Character then
     local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
     if humanoid and getgenv().AirPartEnabled then
         if humanoid.FloorMaterial == Enum.Material.Air then
             return getgenv().SelectedAirPart
         end
     end
 end
 return SelectedPart
end

local function CamlockCallback(bool)
    if bool then
        if CamlockConnect then
            CamlockConnect:Disconnect()
            CamlockConnect = nil
            LockedOpp = nil
        end
        
        CamlockConnect = RunService.RenderStepped:Connect(function()
            if LockedOpp and CurrentCamera then
                local OppPart = LockedOpp.Character and LockedOpp.Character:FindFirstChild(getSelectedPart(LockedOpp) or "HumanoidRootPart")
                if OppPart then
                    local OppPartCFrame = OppPart.CFrame
                    local Prediction = getgenv().CamlockPrediction or 0.13333333333
                    local targetPosition = OppPartCFrame.Position + OppPart.Velocity * Prediction
                    if getgenv().SmoothnessEnabled then
                        local smoothnessValue = math.clamp(getgenv().Smoothness or 1, 0.1, 2)                       
                        local Xuaaa = CFrame.new(CurrentCamera.CFrame.Position, targetPosition)
                        CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(Xuaaa, smoothnessValue, SelectedEasing, Enum.EasingDirection.InOut)
                    else
                        if ThirdPerson == true and FirstPerson == true then
                            if (CurrentCamera.Focus.p - CurrentCamera.CoordinateFrame.p).Magnitude > 1 or (CurrentCamera.Focus.p - CurrentCamera.CoordinateFrame.p).Magnitude <= 1 then
                                local Xuaaa = CFrame.new(CurrentCamera.CFrame.Position, targetPosition)
                                CurrentCamera.CFrame = Xuaaa + shakeOffset
                            end
                        elseif ThirdPerson == true and FirstPerson == false then
                            if (CurrentCamera.Focus.p - CurrentCamera.CoordinateFrame.p).Magnitude > 1 then
                                local Xuaaa = CFrame.new(CurrentCamera.CFrame.Position, targetPosition)
                                CurrentCamera.CFrame = Xuaaa + shakeOffset
                            end
                        elseif ThirdPerson == false and FirstPerson == true then
                            if (CurrentCamera.Focus.p - CurrentCamera.CoordinateFrame.p).Magnitude <= 1 then
                                local Xuaaa = CFrame.new(CurrentCamera.CFrame.Position, targetPosition)
                                CurrentCamera.CFrame = Xuaaa + shakeOffset
                            end
                        else
                            local Xuaaa = CFrame.new(CurrentCamera.CFrame.Position, targetPosition)
                            CurrentCamera.CFrame = Xuaaa + shakeOffset
                        end
                    end
                else
                    LockedOpp = nil
                end
            else
                if Mouse.Target then
                    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
                    local ClosestOpp = nil
                    local closestdis = 1 / 0
                    for _, Opp in ipairs(Players:GetPlayers()) do
                        if Opp ~= LocalPlayer and Opp.Character then
                            local part = Opp.Character:FindFirstChild(getSelectedPart(Opp) or "HumanoidRootPart")
                            if part then
                                local dis = (part.Position - Mouse.Hit.p).Magnitude
                                local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
                                if onScreen and dis < closestdis and dis < FOVCircle.Radius then
                                    closestdis = dis
                                    ClosestOpp = Opp
                                end
                            end
                        end
                    end
                    if ClosestOpp then
                        LockedOpp = ClosestOpp
                    end
                end
            end
        end)
    else
        if CamlockConnect then
            CamlockConnect:Disconnect()
            CamlockConnect = nil
            LockedOpp = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
 shakeOffset = getgenv().Shake and Vector3.new(
     math.random(-getgenv().ShakeValue, getgenv().ShakeValue),
     math.random(-getgenv().ShakeValue, getgenv().ShakeValue),
     math.random(-getgenv().ShakeValue, getgenv().ShakeValue)
 ) * 0.1 or Vector3.new(0, 0, 0)
end)

local function onCharacterAdded(character)
 if CamlockConnect then
     CamlockConnect:Disconnect()
     CamlockConnect = nil
     LockedOpp = nil
 end

 character:WaitForChild("Humanoid").Died:Connect(function()
     if CamlockConnect then
         CamlockConnect:Disconnect()
         CamlockConnect = nil
         LockedOpp = nil
     end
 end)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
if LocalPlayer.Character then
 onCharacterAdded(LocalPlayer.Character)
end

Menu.CheckBox("Main", "Camlock", "Enable Camlock", false, function(Value)
 getgenv().EnableCamlock = Value
end)

Menu.Hotkey("Main", "Camlock", "Toggle Camlock | Keybind", Enum.KeyCode.X, function(value)
 getgenv().CamLockBind = value
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
 if input.KeyCode == getgenv().CamLockBind and not gameProcessedEvent then
     getgenv().EnableCamlock = not getgenv().EnableCamlock
     CamlockCallback(getgenv().EnableCamlock)
 end
end)
Menu.CheckBox("Main", "Camlock", "Enable Smoothness", false, function(value)
    getgenv().SmoothnessEnabled = value
end)

Menu.Slider("Main", "Camlock", "Smoothness Amount", 0, 2, 1, "", 1, function(value)
    getgenv().Smoothness = value
end)

Menu.ComboBox("Main", "Camlock", "Select Easing Style...", "None", {"None", "Linear", "Sine", "Back", "Quad", "Quart", "Quint", "Bounce", "Elastic", "Exponential", "Circular", "Cubic"}, function(option)
    if option then
        SelectedEasing = EasingStyles[option]
    end
end)

Menu.CheckBox("Main", "Camlock", "Shake", false, function(Value)
 getgenv().Shake = Value
end)

Menu.Slider("Main", "Camlock", "Shake Amount", 0, 10, 0, "", 0, function(value)
 getgenv().ShakeValue = value
 shakeOffset = Vector3.new(
     math.random(-value, value),
     math.random(-value, value),
     math.random(-value, value)
 ) * 0.1
end)

Menu.CheckBox("Main", "Configuration", "AirPart", false, function(Value)
 getgenv().AirPartEnabled = Value
end)
Menu.CheckBox("Main", "Strafe", "Enable Target Strafe", false, function(bool)
getgenv().TargetStrafeEnabled = bool
end)

Menu.CheckBox("Main", "Strafe", "Enable Auto Shoot", false, function(bool)
getgenv().AutoShootEnabled = bool
end)

Menu.Slider("Main", "Strafe", "Strafe Speed", 0, 25, 10, "", 0, function(value)
getgenv().StrafeSpeed = value
end)

Menu.Slider("Main", "Strafe", "Strafe Distance", 0, 25, 10, "", 0, function(value)
getgenv().Distance = value
end)

Menu.Slider("Main", "Strafe", "Strafe Height", 0, 25, 10, "", 0, function(value)
getgenv().HeightOffset = value
end)

Menu.ComboBox("Main", "Strafe", "Select Orbit Shape...", "None", {'Circle', 'Square', 'Triangle', 'Heart'}, function(option)
getgenv().OrbitShape = option
end)

Menu.CheckBox("Main", "Checks", "Enable Crew Check", false, function(Value)
getgenv().ECC = Value
end)
Menu.CheckBox("Main", "Checks", "Enable Friend(s) Check", false, function(Value)
getgenv().EFC = Value
end)

Menu.CheckBox("Main", "Checks", "Enable Visible Check", false, function(Value)
getgenv().EVC = Value
end)

Menu.CheckBox("Main", "Checks", "Enable Dead Check", false, function(Value)
getgenv().EDC = Value
end)
Menu.CheckBox("Main", "Checks", "Enable Grabbed Check", false, function(Value)
getgenv().EGC = Value
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local Camera = workspace.CurrentCamera
local toggle = true 

function GetAllPlayers()
    local PlayersExceptLocal = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            table.insert(PlayersExceptLocal, player)
        end
    end

    return PlayersExceptLocal
end

function get_calculated_velocity(obj)
    if obj.Character and obj.Character:FindFirstChild("HumanoidRootPart") then
        local RootPart = obj.Character.HumanoidRootPart
        local currentPosition = RootPart.Position
        local currentTime = tick() 
    
        task.wait(Interval)

        local newPosition = RootPart.Position
        local newTime = tick()
    
        local distanceTraveled = newPosition - currentPosition
        local timeInterval = newTime - currentTime
        local velocity = distanceTraveled / timeInterval
        
        RootPart.Velocity = velocity
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.P and not gameProcessedEvent then
        toggle = not toggle
        Menu:SetVisible(toggle)
    end
end)

RunService.RenderStepped:Connect(function(DeltaTime)
    if toggle then
        local playersToCheck = GetAllPlayers()
        
        for _, player in ipairs(playersToCheck) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if ResolverVersion == "MoveDirection" then
                    player.Character.HumanoidRootPart.Velocity = player.Character.Humanoid.MoveDirection * math.random(16, 17)
                elseif ResolverVersion == "Recalculate" then
                    get_calculated_velocity(player)
                end
            end
        end
    end
end)