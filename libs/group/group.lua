local DateTime = require("util/datetime")

local Group = {}

function Group.__index (t,i)
    if Group._Requests[i] then Group._Requests[i](t) return rawget(t,i) end
end

function Group.__call (_,Client,GroupId,Data)
    local self = {}
    setmetatable(self,{__index=Group})

    self.Client = Client
    self.Id = GroupId

    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    return self
end

function Group:GetData ()
    local Success,Body = self.Client:Request ("GET","https://groups.roblox.com/v1/groups/"..self.Id)
    if Success then
        local Data = {}
        Data.Name = Body.name
        Data.Description = Body.description
        Data.MemberCount = Body.memberCount
        Data.PublicEntryAllowed = Body.publicEntryAllowed
        if Body.owner then
            Data.Owner = self.Client:User (Body.owner.userId,{
                Name = Body.owner.username,
                DisplayName = Body.owner.displayName,
            })
        end
        if Body.shout then
            Data.ShoutBody = Body.shout.body
            Data.ShoutCreated = DateTime (Body.shout.created)
            Data.ShoutUpdated = DateTime (Body.shout.updated)
            if Body.shout.poster then
                Data.ShoutPoster = self.Client:User (Body.shout.poster.userId,{
                    Name = Body.shout.poster.username,
                    DisplayName = Body.shout.poster.displayName,
                })
            end
        end
        for i,v in pairs(Data) do
            self[i] = v
        end
        return Data
    end
end

Group._Requests = {
    Name = Group.GetData,
    Description = Group.GetData,
    MemberCount = Group.GetData,
    PublicEntryAllowed = Group.GetData,
    Owner = Group.GetData,
    ShoutBody = Group.GetData,
    ShoutPoster = Group.GetData,
    ShoutCreated = Group.GetData,
    ShoutUpdated = Group.GetData,
}

setmetatable(Group,Group)
return Group