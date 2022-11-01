local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Teams = game:GetService("Teams");

local ConvertToPosition = loadstring(game:HttpGet("https://raw.githubusercontent.com/Perthys/convert_to_position/main/main.lua"))();
local Sort = loadstring(game:HttpGet('https://raw.githubusercontent.com/Perthys/SmartSort/main/main.lua'))()
local DumpTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/strawbberrys/LuaScripts/main/TableDumper.lua"))()

local DistanceAlgo = Sort.new()
    :Add("Distance", 2, "Higher")

local Whitelist = {
    "Brett290";
    "Chad5555";
    "Perthyz";
    "Hwalalki_Mata";
}

local LocalPlayer = Players.LocalPlayer;

local Deflectors = Teams:FindFirstChild("Deflectors");

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();

if shared.Signal then
    shared.Signal:Disconnect();
end

shared.Signal = LocalPlayer.CharacterAdded:Connect(function(Char)
    Character = Char;
end)

local function GetBall()
    local Ball = workspace:FindFirstChild("Ball");
    
    if Ball then
        local Main = Ball:FindFirstChild("Main");
        
        for Index, Value in pairs(Ball:GetChildren()) do
            if Value:IsA("BasePart") then
                Value.CanCollide = false
            end
        end
        return Main
    end
end

local function LookAt(Part1, PositionArg) 
    PositionArg = ConvertToPosition(PositionArg)
    Part1:PivotTo(CFrame.new(Part1.Position, Vector3.new(PositionArg.X, Part1.Position.Y, PositionArg.Z)))
end

local function GetNearestPlayer()
    local SortedData = {};
    
    for Index, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and not table.find(Whitelist, Player.Name) and Player.Team == Deflectors then
            local OtherCharacter = Player.Character;
             
            if OtherCharacter then
                local Distance = (OtherCharacter:GetPivot().Position - Character:GetPivot().Position).Magnitude;
                
                table.insert(SortedData, {
                    Instance = Player;
                    Distance = Distance;
                })
            end
        end
    end
    
    SortedData = DistanceAlgo:Sort(SortedData);
    
    if #SortedData > 1 and SortedData[1] and SortedData[1].Instance then
        return SortedData[1].Instance;
    end
end

local function Main()
    if LocalPlayer.Team == Deflectors then
        local Ball = GetBall();
        
        if Character then
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart");
            local Humanoid = Character:FindFirstChild("Humanoid");
                
            if HumanoidRootPart and Humanoid then
                                        
                local DeflectorsPlayers = Deflectors:GetPlayers();
                
                if Character:FindFirstChild("TargetHighlight") then
                    LookAt(HumanoidRootPart, Ball.Position)
                    Humanoid.TargetPoint = (Vector3.zero);
                end    
                        
                if #DeflectorsPlayers > 2 and not Character:FindFirstChild("TargetHighlight") then
                    local Player = GetNearestPlayer()
                            
                    if Player then
                        local Character = Player.Character 
                            
                        if Character then
                            LookAt(HumanoidRootPart, Character:GetPivot())
                            Humanoid:MoveTo(Character:GetPivot().Position)
                        end
                    end
                end
                
                if Ball then
                    if Ball:FindFirstChild("Touch") then
                        Ball:Destroy();
                    end
                    
                    local Distance = (HumanoidRootPart.Position - Ball.Position).Magnitude
                    
                    if Distance <= 18 and not Character:FindFirstChild("TargetHighlight") then
                        local Directional = HumanoidRootPart.CFrame:ToObjectSpace(Ball.CFrame)
                        
                        LookAt(HumanoidRootPart, Ball.Position)
                        Humanoid.AutoRotate = false;
                        Humanoid.TargetPoint = (Vector3.zero);
                        Humanoid:MoveTo(HumanoidRootPart.CFrame * CFrame.new(-Directional.X, 0, Distance).Position)
                    end
                    
                    if Distance <= 8 and Character:FindFirstChild("TargetHighlight") then
                        local Deflection = Character:FindFirstChild("Deflection");
                            
                        if Deflection then
                            local Remote = Deflection:FindFirstChild("Remote");
                        
                            if Remote then
                                Humanoid.TargetPoint = (Vector3.zero);
                                
                                Remote:FireServer("Deflect", HumanoidRootPart.CFrame.LookVector + Vector3.new(0/0, 0/0, 0/0))
                            end
                        end
                    end
                end
            end
        end
    end
end

shared.Looped = false;
wait()
shared.Looped = true;

while shared.Looped do
    Main()
    task.wait()
end
