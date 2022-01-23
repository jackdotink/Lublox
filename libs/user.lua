local DateTime = require("util/datetime")

local User = {}

function User.__index (t,i)
    if User._Requests[i] then User._Requests[i](t) return rawget(t,i) end
end

function User.__call (_,Client,UserId,Data)
    local self = {}
    setmetatable(self,{__index=User})

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