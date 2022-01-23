local Role = {}

function Role.__index (t,i)
    if Role._Requests[i] then Role._Requests[i](t) return rawget(t,i) end
end

function Role.__call (_,Client,RoleId,Data)
    local self = {}
    setmetatable(self,{__index=Role})

    self.Client = Client
    self.Id = RoleId
    
    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    return self
end

function Role:GetData ()
    local Success,Body = self.Client:Request ("GET","https://groups.roblox.com/v1/roles",{ids=self.Id})
    if Success then
        local Data = {}
        Data.Name = Body.name
        Data.Description = Body.description
        Data.Rank = Body.rank
        Data.MemberCount = Body.memberCount
        if rawget(self,"Group") == nil then
            Data.Group = self.Client:Group (Body.groupId)
        end
        for i,v in pairs(Data) do
            self[i] = v
        end
        return Data
    end
end

function Role:GetMembers ()
    local Data = self.Client:PageCursor ("https://groups.roblox.com/v1/groups/"..self.Group.Id.."/roles/"..self.Id.."/users",nil,function(v)
        return self.Client:Member (self.Group.Id,v.userId)
    end)
    self.Members = Data
    return Data
end

Role._Requests = {
    Name = Role.GetData,
    Description = Role.GetData,
    Rank = Role.GetData,
    MemberCount = Role.GetData,
    Group = Role.GetData,

    Members = Role.GetMembers,
}

setmetatable(Role,Role)
return Role