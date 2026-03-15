local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Config.GameConfig)

local MarketplaceService = {}
MarketplaceService._store = DataStoreService:GetDataStore("HXH_MARKET_V1")

function MarketplaceService:PostListing(player, profile, itemName, amount, price)
    if (profile.Inventory.Items[itemName] or 0) < amount then
        return false, "Not enough item stock"
    end

    profile.Inventory.Items[itemName] -= amount
    local listingId = HttpService:GenerateGUID(false)

    local listing = {
        ListingId = listingId,
        SellerId = player.UserId,
        SellerName = player.Name,
        ItemName = itemName,
        Amount = amount,
        Price = price,
        CreatedAt = os.time(),
    }

    local success, err = pcall(function()
        self._store:SetAsync(listingId, listing)
    end)

    if not success then
        profile.Inventory.Items[itemName] += amount
        return false, err
    end

    return true, listing
end

function MarketplaceService:ListListings(limit)
    limit = limit or 30
    local pages = self._store:ListKeysAsync("", limit)
    local items = {}

    for _, entry in ipairs(pages:GetCurrentPage()) do
        local ok, listing = pcall(function()
            return self._store:GetAsync(entry.KeyName)
        end)

        if ok and listing then
            table.insert(items, listing)
        end
    end

    table.sort(items, function(a, b)
        return a.CreatedAt > b.CreatedAt
    end)

    return items
end

function MarketplaceService:BuyListing(profile, listing)
    if profile.Jenny < listing.Price then
        return false, "Not enough Jenny"
    end

    local tax = math.floor(listing.Price * GameConfig.Taxes.Marketplace)
    profile.Jenny -= listing.Price
    profile.Inventory.Items[listing.ItemName] = (profile.Inventory.Items[listing.ItemName] or 0) + listing.Amount

    return true, tax
end

return MarketplaceService
