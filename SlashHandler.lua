local Commands = {}

SLASH_HUNTERTRACKINGBAR1 = "/huntertrackingbar"
function SlashCmdList.HUNTERTRACKINGBAR(cmd, ...)
    cmd = strlower(cmd)
    if (Commands[cmd]) then
        Commands[cmd].callback(...)
    else
        -- TODO: Show message and list all available commands.
    end
end

-- TODO: Not sure if this is sufficient.
if (not SlashCmdList.HTB) then
    SLASH_HUNTERTRACKINGBAR2 = "/htb"
end

Commands.unlock = {
    description = "Unlock the bar.",
    callback = function()
        -- TODO: Implement
    end,
}

Commands.lock = {
    description = "Lock the bar.",
    callback = function()
        -- TODO: Implement
    end,
}