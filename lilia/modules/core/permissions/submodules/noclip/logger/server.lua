﻿
lia.log.addType("observerEnter", function(client, ...) return string.format("%s has entered observer.", client:Name()) end)

lia.log.addType("observerExit", function(client, ...) return string.format("%s has left observer.", client:Name()) end)

