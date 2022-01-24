local DateTime = require("util/datetime")

--[=[
    @within User
    @prop Id number
    @readonly
    The UserId of the user.
]=]
--[=[
    @within User
    @prop Client Client
    @readonly
    A reference back to the client that owns this object.
]=]
--[=[
    @within User
    @prop Name string
    @readonly
    The Username of the user.
]=]
--[=[
    @within User
    @prop Description string
    @readonly
    The description (about me) of the user.
]=]
--[=[
    @within User
    @prop Created number
    @readonly
    The creation date/time (unix time) of the user.
]=]
--[=[
    @within User
    @prop IsBanned boolean
    @readonly
    If the user is banned or not.
]=]
--[=[
    @within User
    @prop DisplayName string
    @readonly
    The display name of the user.
]=]
--[=[
    @within User
    @prop Friends {User}
    @readonly
    A list of users the user is friended to.
]=]
--[=[
    The user object can view and edit data about users.

    @class User
]=]
local User = {}

--[=[
    Constructs a user object.

    @param _ User
    @param Client Client -- The client to make requests with.
    @param UserId number|string -- The Username or UserId.
    @param Data {[any]=any} -- Optional preset data. Used within the library, not meant for general use.
    @return User
]=]
function User.__call (_,Client,UserId,Data)
    local self = {}
    setmetatable(self,{__index=function (t,i)
        if User[i] then return User[i] end
        if User._Requests[i] then User._Requests[i](t) return rawget(t,i) end
    end})

    self.Client = Client

    if type(Data) == "table" then
        for i,v in pairs(Data) do
            self[i] = v
        end
    end

    if type(UserId) == "number" then
        self.Id = UserId
    elseif type(UserId) == "string" then
        local Success,Body = self.Client:Request("POST","https://users.roblox.com/v1/usernames/users",{},{usernames={UserId},excludeBannedUsers=true})
        if Success then
            Sucess = false
            for _,v in pairs(Body["data"]) do
                if string.lower(v.name) == string.lower(UserId) then
                    self.Id = v.id
                    self.Name = v.name
                    self.DisplayName = v.displayName
                    Success = true
                    break
                end
            end
            if Success == false then
                return nil
            end
        else
            return nil
        end
    end

    return self
end

--[=[
    Gets data about the user.

    @return {Name:string,Description:string,Created:number,IsBanned:boolean,DisplayName:string}
]=]
function User:GetData ()
    local Success,Body = self.Client:Request ("GET","https://users.roblox.com/v1/users/"..self.Id)
    if Success then
        local Data = {}
        Data.Name = Body.name
        Data.Description = Body.description
        Data.Created = DateTime(Body.created)
        Data.IsBanned = Body.isBanned
        Data.DisplayName = Body.displayName
        for i,v in pairs(Data) do
            self[i] = v
        end
        return Data
    end
end

--[=[
    Gets the users friends.

    @return {User}
]=]
function User:GetFriends ()
    local Success,Body = self.Client:Request ("GET","https://friends.roblox.com/v1/users/"..self.Id.."/friends",{userSort="Alphabetical"})
    if Success then
        self.Friends = {}
        for _,v in pairs(Body["data"]) do
            self.Friends[#self.Friends+1] = self.Client:User (v.id,{
                Description = v.description,
                Name = v.name,
                DisplayName = v.displayName,
                Created = DateTime(v.created),
                IsBanned = v.isBanned,
            })
        end
        self.FriendCount = #self.Friends
        return self.Friends
    end
end

--[=[
    Gets the number of friends the user has.

    @return number
]=]
function User:GetFriendCount ()
    local Success,Body = self.Client:Request ("GET","https://friends.roblox.com/v1/users/"..self.Id.."/friends/count")
    if Success then
        self.FriendCount = Body["count"]
        return Body["count"]
    end
end

User._Requests = {
    Name = User.GetData,
    Description = User.GetData,
    Created = User.GetData,
    IsBanned = User.GetData,
    DisplayName = User.GetData,

    Friends = User.GetFriends,
    FriendCount = User.GetFriendCount,
}

setmetatable(User,User)
return User