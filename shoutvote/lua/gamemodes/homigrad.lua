-- addons/shoutvote/lua/shoutvote/gamemodes/homigrad.lua

if not SHOUT or not SHOUT.RegisterGamemode then return end

SHOUT.RegisterGamemode("homigrad", {
    -- Only offer votes when the active gamemode is Homigrad
    ShouldVote = function()
        return engine.ActiveGamemode() == "homigrad"
    end,

    -- Return the list of maps Homigrad wants to vote on
    GetMaps = function()
        -- homigradConfig.MapList should be the same table your movement-addon uses
        return homigradConfig and homigradConfig.MapList or {}
    end,

    -- Called by ShoutVote when the vote finishes
    OnVoteEnd = function(winningMap)
        -- Change level to the winning map, same as Homigrad’s default hook
        game.ConsoleCommand("changelevel " .. winningMap .. "\n")
    end,

    -- (Optional) Let Homigrad know a vote was canceled
    OnVoteCancel = function()
        hook.Run("HG_MapVoteCanceled")
    end,
})
