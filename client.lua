Citizen.CreateThread(function()
    RadioList = {
        "RADIO_01_CLASS_ROCK", 
        "RADIO_02_POP",
        "RADIO_03_HIPHOP_NEW",
        "RADIO_04_PUNK",
        "RADIO_05_TALK_01",
        "RADIO_06_COUNTRY",
        "RADIO_07_DANCE_01",
        "RADIO_08_MEXICAN",
        "RADIO_09_HIPHOP_OLD",
        "RADIO_12_REGGAE",
        "RADIO_13_JAZZ",
        "RADIO_14_DANCE_02",
        "RADIO_15_MOTOWN",
        "RADIO_20_THELAB",
        "RADIO_16_SILVERLAKE",
        "RADIO_17_FUNK",
        "RADIO_18_90S_ROCK",
        "RADIO_19_USER",
    }

    Plylists = {}

    LastRadioIndex = GetPlayerRadioStationIndex()

ShowNotification = true
    function DrawText2D(text, x, y)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextScale(0.0, 0.3)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x,y)
    end

    function DisplayHelpText(text)
	AddTextEntry('MEOW_IM_A_KID', text)
        BeginTextCommandDisplayHelp('MEOW_IM_A_KID')
        EndTextCommandDisplayHelp(0,0,1,6000)
    end
   
    local SongData = nil
   
    function RefreshSongInfo()
        TriggerServerEvent("Spotify:GetSongInfo")
        TriggerServerEvent("Spotify:GetPlaylists")
        SetTimeout(5000, RefreshSongInfo)
    end
   
    RegisterNetEvent("Spotify:GiveSongInfo")
    AddEventHandler("Spotify:GiveSongInfo", function(SongInfo)
        SongData = SongInfo
    end)

    RegisterNetEvent("Spotify:GivePlaylists")
    AddEventHandler("Spotify:GivePlaylists", function(Playlists,PlaylistsInfos)
        for i,radio in ipairs(RadioList) do
            if Playlists[i] ~= nil then
            AddTextEntry(radio, Playlists[i])
            end
        end
        Plylists =  PlaylistsInfos
        if LastRadioIndex ~= GetPlayerRadioStationIndex() then
        TriggerServerEvent("Spotify:PlayRadioStation", GetPlayerRadioStationIndex())
        end
        LastRadioIndex = GetPlayerRadioStationIndex()
    end)

    RegisterNetEvent("Spotify:Notify")
    AddEventHandler("Spotify:Notify", function(SongInfo)
if ShowNotification then
        DisplayHelpText("Hey there, it seems like you're not signed into your spotify account yet! Please visit: ~r~https://whogivesashitabout.it/~w~. To stop this from appearing instead, type /spotifyignore in chat.")
end
    end)
   
    RefreshSongInfo()
   
    function SetupDashScaleform()
        Dash = RequestScaleformMovie("dashboard")
        while not HasScaleformMovieLoaded(Dash) do
            Wait(0)
        end
       
        return Dash
    end
   
    local Dashboard = SetupDashScaleform()
    while true do
        Citizen.Wait(0)
        if SongData ~= nil then
            if IsPedInAnyVehicle(PlayerPedId(), true) then
                PushScaleformMovieFunction(Dashboard, "SET_RADIO")
                PushScaleformMovieFunctionParameterString("")
                PushScaleformMovieFunctionParameterString("Spotify")
                PushScaleformMovieFunctionParameterString(SongData.SongArtist)
                PushScaleformMovieFunctionParameterString(SongData.SongName)
                PopScaleformMovieFunctionVoid()
            end
           
            DrawText2D("~g~Spotify:~s~ Song: ~o~"..SongData.SongName.."~s~ Artist: ~o~"..SongData.SongArtist, 0.02, 0.02)
           
        end
    end

end)

RegisterCommand("spotifyignore",function()
ShowNotification = false
end,false)

