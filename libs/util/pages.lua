local PageCursor = {}

function PageCursor.__call (_,Client,Endpoint,Tags,Interpret,SortOrder,Limit,PageDataLocation,PageNextLocation,PagePreviousLocation,CursorTag,LimitTag,SortOrderTag)
    local self = {}
    setmetatable(self,{__index=PageCursor})

    self.Client = Client
    self.Endpoint = Endpoint
    self.Tags = Tags
    self.Interpret = Interpret
    self.SortOrder = SortOrder or "Asc"
    self.Limit = Limit or 10

    self.PageDataLocation = PageDataLocation or "data"
    self.PageNextLocation = PageNextLocation or "nextPageCursor"
    self.PagePreviousLocation = PagePreviousLocation or "previousPageCursor"
    self.CursorTag = CursorTag or "cursor"
    self.LimitTag = LimitTag or "limit"
    self.SortOrderTag = SortOrderTag or "sortOrder"

    self.LastPage = false
    self.FirstPage = true

    return self
end

function PageCursor:Next ()
    if self.LastPage then
        error("Lublox: You cannot use method 'Next' when you are on the last page!")
    end

    local Tags = self.Tags or {}
    if self.NextCursor then Tags[self.CursorTag] = self.NextCursor end
    Tags[self.SortOrderTag] = self.SortOrder
    Tags[self.LimitTag] = self.Limit

    local Success,Body = self.Client:Request ("GET",self.Endpoint,Tags)
    if Success then
        self.LastPage = Body[self.PageNextLocation] ~= nil
        self.FirstPage = Body[self.PagePreviousLocation] ~= nil
        self.NextCursor = Body[self.PageNextLocation]
        self.PreviousCursor = Body[self.PagePreviousLocation]
        local Data = {}
        for _,v in pairs(Body[self.PageDataLocation]) do
            Data[#Data+1] = self.Interpret(v)
        end
        return Data
    end
end

function PageCursor:Previous ()
    if self.FirstPage then
        error("Lublox: You cannot use method 'Previous' when you are on the first page!")
    end

    local Tags = self.Tags or {}
    if self.PreviousCursor then Tags[self.CursorTag] = self.PreviousCursor end
    Tags[self.SortOrderTag] = self.SortOrder
    Tags[self.LimitTag] = self.Limit

    local Success,Body = self.Client:Request ("GET",self.Endpoint,Tags)
    if Success then
        self.LastPage = Body[self.PageNextLocation] ~= nil
        self.FirstPage = Body[self.PagePreviousLocation] ~= nil
        self.NextCursor = Body[self.PageNextLocation]
        self.PreviousCursor = Body[self.PagePreviousLocation]
        local Data = {}
        for _,v in pairs(Body[self.PageDataLocation]) do
            Data[#Data+1] = self.Interpret(v)
        end
        return Data
    end
end

return {PageCursor=PageCursor}