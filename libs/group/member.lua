local Member = {}

function Member.__index (t,i)
    if Member._Requests[i] then Member._Requests[i](t) return rawget(t,i) end
end

function Member.__call (_,Client,GroupId,UserId,Data)
    local self = {}
    setmetatable(self,{__index=Member})

    self.Client = Client
    
    if type(GroupId) == "number" then
        self.Group = Client:Group (GroupId)
    elseif type(GroupId) == "table" then
        self.Group = GroupId
    else
        error ("Lublox: Invalid type for group!")
    end

    if type(UserId) == "number" or type(UserId) == "string" then
        self.User = Client:User (UserId)
    elseif type(UserId) == "table" then
        self.User = UserId 
    else
        error ("Lublox: Invalid type for user!")
    end

    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    return self
end

function Member:GetRole ()
    local Success,Body = self.Client:Request ("GET","https://groups.roblox.com/v1/users/"..self.User.Id.."/groups/roles")
    if Success then
        for _,v in Body["data"] do
            if v.group.id == self.Group.Id then
                self.Role = self.Client:Role (v.role.id,{Name=v.role.name,Rank=v.role.rank})
                return self.Role
            end
        end
    end
end

function Member:SetRole (Role)
    local RoleId = Role
    if type(RoleId) == "table" then RoleId = RoleId.Id end
    local Success = self.Client:Request ("PATCH","https://groups.roblox.com/v1/groups/"..self.Group.Id.."/users/"..self.User.Id,nil,nil,{roleId=RoleId})
    return Success
end

function Member:Exile ()
    local Success = self.Client:Request ("DELETE","https://groups.roblox.com/v1/groups/"..self.Group.Id.."/users/"..self.User.Id)
    return Success
end

Member._Requests = {
    Role = Member.GetRole,
}

setmetatable(Member,Member)
return Member