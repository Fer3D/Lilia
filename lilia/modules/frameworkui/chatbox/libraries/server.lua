﻿
function ChatboxCore:PostPlayerSay(client, message, chatType)
    lia.log.add(client, "chat", chatType and chatType:upper() or "??", message)
end


function ChatboxCore:SaveData()
    self:setData(self.OOCBans)
end


function ChatboxCore:LoadData()
    self.OOCBans = self:getData()
end


function ChatboxCore:InitializedModules()
    SetGlobalBool("oocblocked", false)
end

