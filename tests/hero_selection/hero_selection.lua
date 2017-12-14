-- This script will define the heros directly during hero selection process

local hero_list_radiant = {
    "npc_dota_hero_antimage",
    "npc_dota_hero_invoker",
    "npc_dota_hero_bane",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_crystal_maiden"
}

local hero_list_dire = {
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_mirana",
    "npc_dota_hero_nevermore"
}

function Think()
    if (GetTeam() == TEAM_RADIANT)
    then
        local IDs = GetTeamPlayers(GetTeam());
        for i,id in pairs(IDs)
        do
            SelectHero(id,hero_list_radiant[i]);
        end
    elseif (GetTeam() == TEAM_DIRE)
    then
        local IDs = GetTeamPlayers(GetTeam());
        for i,id in pairs(IDs)
        do
            SelectHero(id,hero_list_radiant[i]);
        end
    end
end