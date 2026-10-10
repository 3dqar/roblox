-- Color Rush is a free color-memory mini-game, NOT a casino or wagering game.
-- No Coins/Robux are staked or lost. Server owns outcomes and grants rewards.
local Rep=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local reward=Rep:WaitForChild("ObbyBonusCoins")
local event=Instance.new("RemoteEvent")
event.Name="ColorRushEvent"
event.Parent=Rep
local colors={"Red","Black","Green"}
local sessions={}
local lastPlayed={}
local COOLDOWN=90
local function notify(player,kind,value)
    event:FireClient(player,kind,value)
end
event.OnServerEvent:Connect(function(player,kind,choice)
    if kind=="Start" then
        if sessions[player] then return end
        local remaining=COOLDOWN-(os.clock()-(lastPlayed[player] or -COOLDOWN))
        if remaining>0 then
            notify(player,"Wait",math.ceil(remaining))
            return
        end
        local sequence={}
        for i=1,4 do sequence[i]=colors[math.random(1,#colors)] end
        sessions[player]={sequence=sequence,expires=os.clock()+22}
        notify(player,"Sequence",sequence)
    elseif kind=="Answer" then
        local session=sessions[player]
        if not session or os.clock()>session.expires then
            sessions[player]=nil
            notify(player,"Expired",0)
            return
        end
        if type(choice)~="table" or #choice~=4 then return end
        sessions[player]=nil
        lastPlayed[player]=os.clock()
        local correct=true
        for i=1,4 do
            if choice[i]~=session.sequence[i] then correct=false;break end
        end
        if correct then
            reward:Fire(player,"ColorRush")
            notify(player,"Result",true)
        else
            notify(player,"Result",false)
        end
    end
end)
Players.PlayerRemoving:Connect(function(player)
    sessions[player]=nil
    lastPlayed[player]=nil
end)
