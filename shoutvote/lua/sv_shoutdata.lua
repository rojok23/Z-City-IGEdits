--Shout Vote Server Dist
SHOUT.Database = {}

function SHOUT.Database.Setup()
	sql.Query("CREATE TABLE IF NOT EXISTS shoutvote_maps(map VARCHAR(50) NOT NULL, roundsago INTEGER NOT NULL, lastplayed BIGINT NOT NULL, PRIMARY KEY(map));")
end
hook.Add("InitPostEntity","VOTING_InitSetupDatabase",SHOUT.Database.Setup)

function SHOUT.Database.SaveCurrentMap()
	local map = string.lower(game.GetMap())
	local lastplayed = os.time()
	sql.Query("INSERT OR IGNORE INTO shoutvote_maps VALUES(" .. sql.SQLStr(map) .. ", 0, " .. lastplayed .. " ); UPDATE shoutvote_maps SET roundsago = 0, lastplayed = ".. lastplayed .." WHERE map = "..sql.SQLStr(map)..";");
end

function SHOUT.Database.UpdateLastPlayedRounds()
	sql.Query("UPDATE shoutvote_maps SET roundsago = roundsago + 1;");
end

function SHOUT.Database.FindExcludedMapsByRoundsAgo(roundsago)
	local r = sql.Query("SELECT * FROM shoutvote_maps WHERE roundsago < " .. tonumber(roundsago) .. " ;")
	return r or {}
end

function SHOUT.Database.FindExcludedMapsByLastPlayed(minutes)
	local lastplayed = os.time() - (minutes*60)
    local r = sql.Query("SELECT * FROM shoutvote_maps WHERE lastplayed > " .. tonumber(lastplayed) .. " ;")
	return r or {}
end