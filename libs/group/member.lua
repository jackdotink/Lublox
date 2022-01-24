--[=[
    @within Member
    @prop User User
    @readonly
    The user that the member object represents.
]=]
--[=[
    @within Member
    @prop Group Group
    @readonly
    The group that the user is in.
]=]
--[=[
    @within Member
    @prop Client Client
    @readonly
    A reference back to the client that owns this object.
]=]
--[=[
    @within Member
    @prop Role Role
    @readonly
    The role the user has in the group.
]=]
--[=[
    The member object can view and edit data about users in groups.

    @class Member
]=]
local Member = {}

--[=[
    Constructs a member object.

    @param _ Member
    @param Client Client -- The client to make requests with.
    @param GroupId Group|number -- The Group or GroupId the member belongs to.
    @param UserId User|number -- The User or UserId the member object represents.
    @param Data {[any]=any} -- Optional preset data. Used within the library, not meant for general use.
    @return Member
]=]
function Member.__call (_,Client,GroupId,UserId,Data)
    local self = {}
    setmetatable(self,{__index=function (t,i)
        if Member[i] then return Member[i] end
        if Member._Requests[i] then Member._Requests[i](t) return rawget(t,i) end
    end})

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

--[=[
    Gets the role of the member in the group.

    @return Role?
]=]
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

--[=[
    Sets the role of the member in the group.

    @param Role Role|number -- The Role or RoleId to set the user to.
    @return boolean
]=]
function Member:SetRole (Role)
    local RoleId = Role
    if type(RoleId) == "table" then RoleId = RoleId.Id end
    local Success = self.Client:Request ("PATCH","https://groups.roblox.com/v1/groups/"..self.Group.Id.."/users/"..self.User.Id,nil,nil,{roleId=RoleId})
    return Success
end

--[=[
    Exiles the member from the group.

    @return boolean
]=]
function Member:Exile ()
    local Success = self.Client:Request ("DELETE","https://groups.roblox.com/v1/groups/"..self.Group.Id.."/users/"..self.User.Id)
    return Success
end

Member._Requests = {
    Role = Member.GetRole,
}

setmetatable(Member,Member)
return Member