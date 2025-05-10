local tabletOpen = false
local link = nil
local tabletObject = nil
local isBusy = false

-- 📦 Fonction pour afficher la tablette UI
function openTabletUI()
    if isBusy then return end
    isBusy = true

    tabletOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", url = link })

    -- 🧏‍♀️ Jouer l'animation tablette assise
    loadAnimDict("amb@world_human_seat_wall_tablet@female@base")
    TaskPlayAnim(PlayerPedId(), "amb@world_human_seat_wall_tablet@female@base", "base", 8.0, -8.0, -1, 49, 0, false, false, false)

    -- 🧊 Créer le prop tablette
    local playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    RequestModel("prop_cs_tablet")
    while not HasModelLoaded("prop_cs_tablet") do
        Wait(10)
    end

    tabletObject = CreateObject(GetHashKey("prop_cs_tablet"), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(tabletObject, playerPed, GetPedBoneIndex(playerPed, 57005), 0.10, 0.02, -0.05, 0.0, 180.0, 90.0, true, true, false, true, 1, true)

    -- 🔊 Son ouverture
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    isBusy = false
end

-- ❌ Fonction pour fermer la tablette
function closeTablet()
    if isBusy then return end
    isBusy = true

    tabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    ClearPedTasks(PlayerPedId())
    if tabletObject then
        DeleteEntity(tabletObject)
        tabletObject = nil
    end

    -- 🔊 Son fermeture
    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    isBusy = false
end

-- 🧼 Utilitaire pour charger les animations
function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

-- 🔘 Partie 1 : Commande /tablet
RegisterCommand("tablet", function()
    if tabletOpen then
        closeTablet()
    else
        openTabletUI()
    end
end)

-- ⌨️ Partie 2 : Touche F4
RegisterKeyMapping("tablet", "Ouvrir la tablette", "keyboard", "F4")

-- 🎒 Partie 3 : Utilisation d’un item
RegisterNetEvent("tablet:use")
AddEventHandler("tablet:use", function()
    if tabletOpen then
        closeTablet()
    else
        openTabletUI()
    end
end)

-- 🌐 Fermeture depuis le JS
RegisterNUICallback("close", function(_, cb)
    closeTablet()
    cb({})
end)

-- 🔁 Reset du lien
RegisterNUICallback("resetLink", function(_, cb)
    link = nil
    cb({})
end)

-- 💾 Sauvegarde du lien
RegisterNUICallback("saveLink", function(data, cb)
    link = data.url
    cb({})
end)
