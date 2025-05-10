lib.registerUsableItem("tablet", function(source)
    -- Lorsqu'un joueur utilise l'item "tablet", on déclenche l'événement côté client
    TriggerClientEvent("tablet:use", source)
end)
