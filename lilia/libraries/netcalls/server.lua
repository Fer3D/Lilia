﻿
util.AddNetworkString("liaCharacterInvList")

util.AddNetworkString("liaItemDelete")

util.AddNetworkString("liaItemInstance")

util.AddNetworkString("liaInventoryInit")

util.AddNetworkString("liaInventoryData")

util.AddNetworkString("liaInventoryDelete")

util.AddNetworkString("liaInventoryAdd")

util.AddNetworkString("liaInventoryRemove")

util.AddNetworkString("liaNotify")

util.AddNetworkString("liaNotifyL")

util.AddNetworkString("liaStringReq")

util.AddNetworkString("liaTransferItem")

util.AddNetworkString("announcement_client")

util.AddNetworkString("SendMessage")

util.AddNetworkString("SendPrintTable")

util.AddNetworkString("SendPrint")

util.AddNetworkString("StringRequest")

util.AddNetworkString("ReloadLightMaps")

util.AddNetworkString("OpenInformationMenu")

util.AddNetworkString("OpenVGUI")

net.Receive(
    "StringRequest",
    function(_, client)
        local time = net.ReadUInt(32)
        local text = net.ReadString()
        if client.StrReqs and client.StrReqs[time] then
            client.StrReqs[time](text)
            client.StrReqs[time] = nil
        end
    end
)


netstream.Hook(
    "liaCharKickSelf",
    function(client)
        local char = client:getChar()
        if char then
            if not client:Alive() then char:setData("pos", nil) end
            char:kick()
        end
    end
)


net.Receive(
    "liaStringReq",
    function(_, client)
        local id = net.ReadUInt(32)
        local value = net.ReadString()
        if client.liaStrReqs and client.liaStrReqs[id] then
            client.liaStrReqs[id](value)
            client.liaStrReqs[id] = nil
        end
    end
)


net.Receive(
    "liaTransferItem",
    function(_, client)
        local itemID = net.ReadUInt(32)
        local x = net.ReadUInt(32)
        local y = net.ReadUInt(32)
        local invID = net.ReadType()
        hook.Run("HandleItemTransferRequest", client, itemID, x, y, invID)
    end
)


netstream.Hook(
    "invMv",
    function(client)
        print("Tell the developer that 'invMv' has been deprecated!")
        print("Instead, the liaTransferItem net message should be used.")
        client:ChatPrint("Tell the developer that 'invMv' has been deprecated!")
        client:ChatPrint("Instead, the liaTransferItem net message should be used.")
    end
)


netstream.Hook(
    "invAct",
    function(client, action, item, _, data)
        local character = client:getChar()
        if not character then return end
        local entity
        if isentity(item) then
            if not IsValid(item) then return end
            if item:GetPos():Distance(client:GetPos()) > 96 then return end
            if not item.liaItemID then return end
            entity = item
            item = lia.item.instances[item.liaItemID]
        else
            item = lia.item.instances[item]
        end

        if not item then return end
        local inventory = lia.inventory.instances[item.invID]
        local context = {
            client = client,
            item = item,
            entity = entity,
            action = action
        }

        if inventory and not inventory:canAccess("item", context) then return end
        item:interact(action, client, entity, data)
    end
)


netstream.Hook(
    "cmd",
    function(client, command, arguments)
        if (client.liaNextCmd or 0) < CurTime() then
            local arguments2 = {}
            for _, v in ipairs(arguments) do
                if isstring(v) or isnumber(v) then arguments2[#arguments2 + 1] = tostring(v) end
            end

            lia.command.parse(client, nil, command, arguments2)
            client.liaNextCmd = CurTime() + 0.2
        end
    end
)

