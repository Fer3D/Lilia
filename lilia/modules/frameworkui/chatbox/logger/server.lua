﻿
lia.log.addType(
    "chat",
    function(client, ...)
        local arg = {...}
        return Format("[%s] %s: %s", arg[1], client:Name(), arg[2])
    end
)

