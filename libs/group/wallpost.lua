local DateTime = require("util/datetime")

--[=[
    @within WallPost
    @prop Client Client
    @readonly
    A reference back to the client that owns this object.
]=]
--[=[
    @within WallPost
    @prop Created number
    @readonly
    The date and time the post was created in unix time.
]=]
--[=[
    @within WallPost
    @prop Id number
    @readonly
    The Id of the post.
]=]
--[=[
    @within WallPost
    @prop Poster User
    @readonly
    The object for the user who made the post.
]=]
--[=[
    @within WallPost
    @prop Group Group
    @readonly
    The group that the post was made on.
]=]
--[=[
    @within WallPost
    @prop Body string
    @readonly
    The text of the post.
]=]
--[=[
    @within WallPost
    @prop Updated number
    @readonly
    The date and time the post was updated in unix time.
]=]
--[=[
    An object that represents a group wall post.

    @class WallPost
]=]
local WallPost = {}

--[=[
    Constructs a wallpost object.

    @param _ WallPost
    @param Client Client -- The client to make requests with.
    @param Id number -- The post Id.
    @param GroupId Group|number -- The Group or GroupId the post was on.
    @param UserId User|number -- The User or UserId the post was made by.
    @param Data {[any]=any} -- Optional preset data. Used within the library, not meant for general use.
    @return WallPost
]=]
function WallPost.__call (_,Client,Id,GroupId,UserId,Data)
    local self = {}

    setmetatable(self,{__index=function (t,i)
        if WallPost[i] then return WallPost[i] end
        if WallPost._Requests[i] then
            WallPost._Requests[i](t)
            return rawget(t,i)
        end
    end})

    self.Client = Client
    self.Id = Id
    
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

WallPost._Requests = {

}

setmetatable(WallPost,WallPost)
return WallPost