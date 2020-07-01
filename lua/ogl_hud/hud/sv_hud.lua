
OGLHUD = {}

RunConsoleCommand("mp_show_voice_icons", "0")

function OGLHUD.SendAlert(title, body, time, ply)
    net.Start("OGLHUD.Alert")
        net.WriteString(string.upper(title))
        net.WriteString(body)
        net.WriteUInt(CurTime() + time, 16)
    net.Send(ply)
end

function OGLHUD.BroadcastAlert(title, body, time)
    net.Start("OGLHUD.Alert")
        net.WriteString(string.upper(title))
        net.WriteString(body)
        net.WriteUInt(CurTime() + time, 16)
    net.Broadcast()
end

hook.Add("playerWanted", "OGLHUD.Want", function(ply, actor, reason)
    OGLHUD.BroadcastAlert(
        "Wanted",
        DarkRP.getPhrase(
            "wanted_by_police",
            ply:Nick(),
            reason,
            IsValid(actor) and actor:Nick() or DarkRP.getPhrase("disconnected_player")
        ),
        10
    )

   -- return true
end)

hook.Add("playerUnWanted", "OGLHUD.UnWant", function(ply, actor)
    OGLHUD.SendAlert(
        "Unwanted",
        IsValid(actor) and DarkRP.getPhrase("wanted_revoked", ply:Nick(), actor:Nick() or "") or DarkRP.getPhrase("wanted_expired", ply:Nick()),
        10,
        ply
    )

   -- return true
end)


hook.Add("playerWarranted", "OGLHUD.Warrant", function(ply, warranter, reason)
    OGLHUD.BroadcastAlert(
        "Warrant Approved",
        DarkRP.getPhrase(
            "warrant_approved",
            ply:Nick(),
            reason,
            IsValid(warranter) and warranter:Nick() or DarkRP.getPhrase("disconnected_player")
        ),
        10
    )

    --return true
end)

local isLockdown = false

hook.Add("Tick", "OGLHUD.LockdownCheck", function()
    if isLockdown != GetGlobalBool("DarkRP_LockDown") then
        isLockdown = !isLockdown

        if isLockdown then
            OGLHUD.BroadcastAlert(
                "Lockdown",
                "The mayor has initiated a lockdown. Return to your home.",
                10
            )
        else
            OGLHUD.BroadcastAlert(
                "Lockdown Over",
                "The mayor has ended the lockdown.",
                10
            )
        end
    end
end)


hook.Add("playerArrested", "OGLHUD.Arrest", function(criminal, time, actor)
    net.Start("OGLHUD.Arrest")
     net.WriteUInt(time, 32)
    net.Send(criminal)
end)

util.AddNetworkString("OGLHUD.Alert")
util.AddNetworkString("OGLHUD.Arrest")