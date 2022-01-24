local DateTime = require("util/datetime")

--[=[
    @within Group
    @prop Id number
    @readonly
    The GroupId of the group.
]=]
--[=[
    @within Group
    @prop Client Client
    @readonly
    A reference back to the client that owns this object.
]=]
--[=[
    @within Group
    @prop Name string
    @readonly
    The name of the group.
]=]
--[=[
    @within Group
    @prop Description strimg
    @readonly
    The description of the group.
]=]
--[=[
    @within Group
    @prop MemberCount number
    @readonly
    The number of members the group has.
]=]
--[=[
    @within Group
    @prop PublicEntryAllowed boolean
    @readonly
    If users are able to join the group without pending.
]=]
--[=[
    @within Group
    @prop Owner User?
    @readonly
    The owner of the group.
]=]
--[=[
    @within Group
    @prop ShoutBody string?
    @readonly
    The shout of the group.
]=]
--[=[
    @within Group
    @prop ShoutPoster User?
    @readonly
    The user that posted the shout.
]=]
--[=[
    @within Group
    @prop ShoutCreated number?
    @readonly
    When the shout was created (unix time). 
]=]
--[=[
    @within Group
    @prop ShoutUpdated number?
    @readonly
    When the shout was updated (unix time).
]=]
--[=[
    The group object can view and edit data about groups.

    @class Group
]=]
local Group = {}

--[=[
    Constructs a group object.

    @param _ Group
    @param Client Client -- The client to make requests with.
    @param GroupId number -- The GroupId of the group.
    @param Data {[any]=any} -- Optional preset data. Used within the library, not meant for general use.
    @return Group
]=]
function Group.__call (_,Client,GroupId,Data)
    local self = {}
    setmetatable(self,{__index=function (t,i)
        if Group[i] then return Group[i] end
        if Group._Requests[i] then Group._Requests[i](t) return rawget(t,i) end
    end})

    self.Client = Client
    self.Id = GroupId

    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    return self
end

--[=[
    Gets data about the group.

    @return {Name:string,Description:string,MemberCount:number,PublicEntryAllowed:boolean,Owner:User?,ShoutBody:string?,ShoutCreated:number?,ShoutUpdated:number?,ShoutPoster:User?}
]=]
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