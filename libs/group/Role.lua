--[=[
    @within Role
    @prop Id number
    @readonly
    The RoleId of the role.
]=]
--[=[
    @within Role
    @prop Client Client
    @readonly
    A reference back to the client that owns this object.
]=]
--[=[
    @within Role
    @prop Name string
    @readonly
    The name of the role.
]=]
--[=[
    @within Role
    @prop Description string
    @readonly
    The description of the role.
]=]
--[=[
    @within Role
    @prop Rank number
    @readonly
    The rank of the role, a number between 0 and 255.
]=]
--[=[
    @within Role
    @prop MemberCount number
    @readonly
    The number of members that are this role.
]=]
--[=[
    @within Role
    @prop Group Group
    @readonly
    The group that this role is a part of.
]=]
--[=[
    @within Role
    @prop Members PageCursor
    @readonly
    A PageCursor object that retrieves the members in the role.
]=]
--[=[
    The role object can view and edit data about roles.

    @class Role
]=]
local Role = {}

--[=[
    Constructs a user object.

    @param _ Role
    @param Client Client -- The client to make requests with.
    @param RoleId number|string -- The RoleId of the role.
    @param Data {[any]=any} -- Optional preset data. Used within the library, not meant for general use.
    @return Role
]=]
function Role.__call (_,Client,RoleId,Data)
    local self = {}
    setmetatable(self,{__index=function (t,i)
        if Role[i] then return Role[i] end
        if Role._Requests[i] then
            Role._Requests[i](t)
            return rawget(t,i)
        end
    end})

    self.Client = Client
    self.Id = RoleId
    
    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    return self
end

--[=[
    Gets data about the role.

    @return {Name:string,Description:string,Rank:number,MemberCount:number}
]=]
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

--[=[
    Gets a PageCursor object with every member that has this role.

    @return PageCursor
]=]
function Role:GetMembers ()
    local Data = self.Client:PageCursor ("https://groups.roblox.com/v1/groups/"..self.Group.Id.."/roles/"..self.Id.."/users",nil,function(v)
        return self.Client:Member (self.Group,v.userId)
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