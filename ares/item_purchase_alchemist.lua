----------------------------------------------------------------------------
--	Ranked Matchmaking AI v1.0a
--	Author: adamqqq		Email:adamqqq@163.com
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_tango",
    "item_stout_shield",
	"item_quelling_blade",
	"item_branches",

	"item_ring_of_regen",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",			--灵魂之戒7.07
	
	"item_boots",

	"item_helm_of_iron_will", 
	"item_gloves", 
	"item_blades_of_attack",
	"item_recipe_armlet",			--臂章
	
	"item_relic",
	"item_recipe_radiance",			--辉耀
	
	"item_recipe_travel_boots",		--飞鞋
	
	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",
	"item_ultimate_orb",
	"item_recipe_manta",			--分身
	
	"item_vitality_booster",
	"item_point_booster",
	"item_energy_booster",
	"item_mystic_staff",			--玲珑心
	
	"item_platemail",
	"item_mystic_staff",
	"item_recipe_shivas_guard",		--希瓦
	
	"item_platemail",
	"item_hyperstone",
	"item_chainmail",
	"item_recipe_assault",			--强袭
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.ItemPurchase(ItemsToBuy)
end