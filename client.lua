Citizen.CreateThread(function()
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
        SetTimeout(5000, RefreshSongInfo)
    end
   
    RegisterNetEvent("Spotify:GiveSongInfo")
    AddEventHandler("Spotify:GiveSongInfo", function(SongInfo)
        SongData = SongInfo
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
           
            DrawText2D("~g~Spotify:~s~ Song: ~o~"..SongData.SongName.."~s~ Artist: ~o~"..SongData.SongArtist, 0.37, 0.1)
           
        end
    end

end)

RegisterCommand("spotifyignore",function()
ShowNotification = false
end,false)

