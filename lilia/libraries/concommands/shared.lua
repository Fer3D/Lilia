﻿
concommand.Add(
    "lia",
    function(client, _, arguments)
        local command = arguments[1]
        table.remove(arguments, 1)
        lia.command.parse(client, nil, command or "", arguments)
    end
)

