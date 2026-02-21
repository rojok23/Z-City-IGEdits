if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('cl_shoutvote.lua')
	AddCSLuaFile('sh_shoutconfig.lua')
	AddCSLuaFile('sh_shoutvoteulx.lua')
	AddCSLuaFile('cl_shoutfonts.lua')
	
	--Add panel files
	AddCSLuaFile('panels/cl_voterow.lua')
	AddCSLuaFile('panels/cl_votecountdown.lua')
	AddCSLuaFile('panels/cl_rtvribbon.lua')
	
	--Add server files
	include('sv_shoutvote.lua')
	
	--Add resources
	local function AddResourceDir(dir)
		local files, dirs = file.Find(dir.."/*", "GAME")

		for _, fdir in pairs(dirs) do
			if fdir != ".svn" then
				AddResourceDir(dir.."/"..fdir)
			end
		end

		for k,v in pairs(files) do
			//print(dir.."/"..v)
			resource.AddSingleFile(dir.."/"..v)
		end
	end

	AddResourceDir("materials/shoutvote")
	resource.AddFile("resource/fonts/BebasNeue.ttf")
	resource.AddFile("resource/fonts/OpenSansC.ttf")
end

if CLIENT then
	include('cl_shoutvote.lua')
end