api_key = ""
name = GetConvar("sv_hostname", "My new fxserver")
print(name)
PerformHttpRequest("https://whogivesashitabout.it:443/fivem/registerserver", function(err,text,headers)
print(json.encode(headers))
print(err)
    text = json.decode(text)
    if text.success then
    print("------------------------------------------")
    print("-------SpotiFive is setup correctly------")
    print("------------------------------------------")

    api_key = text.code
    else
        print("------------------------------------------")
        print("SpotiFive ERROR: COULDN't RETRIEVE A KEY!")
        print("------------------------------------------")
    end
    
    end, "POST", json.encode({["name"]=name}),{["Content-Type"]="application/json"})

function GetUserToken(id,serverid,cb)
    local token = nil
    local id=id
    local cb=cb
    local serverid = serverid
PerformHttpRequest("https://whogivesashitabout.it/fivem/send", function(err,text,headers)
local text = json.decode(text)

if text.success ~= false then
    PerformHttpRequest('https://api.spotify.com/v1/me/player', function(statusCode, returned, headers)
        if statusCode == 200 or statusCode == 202 then
            token = text.access_token
            cb(token)
        else
            PerformHttpRequest("https://whogivesashitabout.it/auth/spotify/refresh", function(err,res,headers)
                res = json.decode(res)
                if res.success ~= false then
                    token = res.access_token
                    cb(token)
                else
                    
                    print("SPOTIFIVEM::ERROR::COULDN'T REFRESH TOKEN!")
                    TriggerClientEvent("Spotify:Notify",serverid)
                end
                end, "POST", json.encode({["steam"]=id,["identifier"]=api_key}), {["Content-Type"]="application/json"})
        end
    end, 'GET', '', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..text.access_token })
    
else
    PerformHttpRequest("https://whogivesashitabout.it/auth/spotify/refresh", function(err,res,headers)
        res = json.decode(res)
        if res.success ~= false then
            token = res.access_token
            cb(token)
        else
            
            print("SPOTIFIVEM::ERROR::COULDN'T REFRESH TOKEN!")
            TriggerClientEvent("Spotify:Notify",serverid)
        end
        end, "POST", json.encode({["steam"]=id,["identifier"]=api_key}), {["Content-Type"]="application/json"})
end
end, "POST", json.encode({["steam"]=id,["identifier"]=api_key}), {["Content-Type"]="application/json"})
return
end


function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
 
    if seconds <= 0 then
        return "00:00:00";
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return mins..":"..secs
    end
end
 
RegisterNetEvent("Spotify:GetSongInfo")
AddEventHandler("Spotify:GetSongInfo", function()
    local Triggerer = source
    GetUserToken(GetPlayerIdentifiers(source)[1],source,function(OAuthKey)
    PerformHttpRequest('https://api.spotify.com/v1/me/player', function(statusCode, returned, headers)
        if statusCode == 200 or statusCode == 202  then
            local data = json.decode(returned)
            local SpotifyInfo = {SongArtist = data["item"]["artists"][1]["name"], SongName = data["item"]["name"]}
            TriggerClientEvent("Spotify:GiveSongInfo", Triggerer, SpotifyInfo)
        else
            print("An error occured, status code: "..statusCode)
            print("Full error message:"..returned)
        end
    end, 'GET', '', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..OAuthKey })
    end)
end)
 
function PlaySong(uri, auth)
    PerformHttpRequest('https://api.spotify.com/v1/me/player/play', function(statusCode, returned, headers)
    end, 'PUT', '{"uris":["'..uri..'"]}', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..auth })
end
 
local parties = {}
 
RegisterCommand("spotify", function(source, args, rawCommand)
    GetUserToken(GetPlayerIdentifiers(source)[1],source,function(OAuthKey)
    local option = args[1]
    local theSource = source
    if option == 'pause' then
        PerformHttpRequest('https://api.spotify.com/v1/me/player/pause', function(statusCode, returned, headers)
        end, 'PUT', '', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..OAuthKey })
        TriggerClientEvent("chat:addMessage", source, { args = { "^2Spotify", "Paused song" } })
    elseif option == 'cursong' then
        PerformHttpRequest('https://api.spotify.com/v1/me/player', function(statusCode, returned, headers)
            local data = json.decode(returned)
            local SongArtist = data["item"]["artists"][1]["name"]
            local SongName = data["item"]["name"]
            local SongUri = data["item"]["uri"]
            local Time = data["progress_ms"] / 1000
            TriggerClientEvent("chat:addMessage", source, { args = { "^2Spotify", "Current song: ^3"..SongName.."\n^7Artist: ^3"..SongArtist.."\n^7Time: ^3"..SecondsToClock(Time).."^7\nUri: ^3"..SongUri } })
        end, 'GET', '', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..OAuthKey })
    elseif option == 'play' then
        local song = args[2]
        if song == nil then
            PerformHttpRequest('https://api.spotify.com/v1/me/player/play', function(statusCode, returned, headers)
            end, 'PUT', '', { ["Content-Type"] = 'application/json', ["Authorization"] = 'Bearer '..OAuthKey })
            TriggerClientEvent("chat:addMessage", source, { args = { "^2Spotify", "Playing song" } })
        else
            PlaySong(song, OAuthKey)
        end
    end
end)
end, false)

local verFile = LoadResourceFile(GetCurrentResourceName(), "version.json")
local curVersion = json.decode(verFile).version
Citizen.CreateThread( function()
	local updatePath = "/IllusiveTea/SpotiFive-FXServer"
	local resourceName = "SpotiFive ("..GetCurrentResourceName()..")"
	PerformHttpRequest("https://raw.githubusercontent.com"..updatePath.."/master/version.json", function(err, response, headers)
		local data = json.decode(response)


		if curVersion ~= data.version and tonumber(curVersion) < tonumber(data.version) then
			print("\n--------------------------------------------------------------------------")
			print("\n"..resourceName.." is outdated.\nCurrent Version: "..data.version.."\nYour Version: "..curVersion.."\nPlease update it from https://github.com"..updatePath.."")
			print("\nUpdate Changelog:\n"..data.changelog)
			print("\n--------------------------------------------------------------------------")
		elseif tonumber(curVersion) > tonumber(data.version) then
			print("Your version of "..resourceName.." seems to be higher than the current version.")
		else
			print(resourceName.." is up to date!")
		end
	end, "GET", "", {version = 'this'})
end)
