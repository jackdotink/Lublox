local http = require("coro-http")
local json = require("json")
local qs = require("querystring")

local User = require("user")

local Group = require("group/group")
local Role = require("group/role")
local Member = require("group/member")

local Pages = require("util/pages")

local function MakeRequest (Method,Endpoint,Headers,Body)
    local Response,ResponseBody = http.request(Method,Endpoint,Headers,Body)
    local ReturnHeaders = {}
    for i,v in pairs(Response) do
        if type(v) == "table" then
            ReturnHeaders[v[1]] = v[2]
        else
            ReturnHeaders[i] = v
        end
    end
    local ReturnBody = {}
    ReturnBody = json.decode(ResponseBody)
    return ReturnHeaders,ReturnBody
end

local Client = {}

function Client.__index (t,i)
    if Client._Requests[i] then t[i] = Client._Requests[i](t) return rawget(t,i) end
end

function Client.__call ()
    local self = {}
    setmetatable(self,{__index=Client})

    return self
end

function Client:Group (GroupId,Data)
    return Group(self,GroupId,Data)
end

function Client:Role (RoleId,Data)
    return Role(self,RoleId,Data)
end

function Client:Member (GroupId,UserId,Data)
    return Member(self,GroupId,UserId,Data)
end

function Client:User (UserId,Data)
    return User(self,UserId,Data)
end

function Client:PageCursor (Endpoint,Tags,Interpret,SortOrder,Limit,PageDataLocation,PageNextLocation,PagePreviousLocation,CursorTag,LimitTag,SortOrderTag)
    return Pages.PageCursor(self,Endpoint,Tags,Interpret,SortOrder,Limit,PageDataLocation,PageNextLocation,PagePreviousLocation,CursorTag,LimitTag,SortOrderTag)
end

function Client:Authenticate (Cookie)
    self.Cookie = Cookie
    -- do http request to confirm authentication,
    -- otherwise error.
end

function Client:Request (Method,Endpoint,Tags,Headers,Body)
    if Tags then
        Endpoint = Endpoint.."?"..qs.stringify(Tags)
    end
    local H = Headers or {}
    if Method ~= "GET" then
        H[#H+1] = {"X-CSRF-TOKEN",self.Token}
    end
    H[#H+1] = {"Cookie",self.Cookie}
    local B = nil
    if Body then
        B = json.encode (Body)
    end
    local HR,BR = MakeRequest (Method,Endpoint,H,B)
    if HR["x-csrf-token"] ~= nil then
        self.Token = HR["x-csrf-token"]
        if HR["code"] == 403 then
            H = Headers or {}
            H[#H+1] = {"X-CSRF-TOKEN",self.Token}
            H[#H+1] = {"Cookie",self.cookie}
            HR,BR = MakeRequest (Method,Endpoint,H,B)
            return HR["code"] == 200,BR,HR
        end
        return HR["code"] == 200,BR,HR
    end
    return HR["code"] == 200,BR,HR 
end

Client._Requests = {
    
}

setmetatable(Client,Client)
return Client