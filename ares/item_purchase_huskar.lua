----------------------------------------------------------------------------
--	Ranked Matchmaking AI v1.0a
--	Author: adamqqq		Email:adamqqq@163.com
----------------------------------------------------------------------------
require( GetScriptDirectory().."/utility" ) 

local ItemsToBuy = 
{ 
	"item_tango",
	"item_flask",
	"item_branches",
	"item_branches",
	"item_boots",
	"item_magic_stick",
	"item_enchanted_mango",			--大魔棒7.07
	"item_belt_of_strength",
	"item_gloves",					--假腿

	"item_circlet",
	"item_ring_of_protection",
	"item_recipe_urn_of_shadows",	
	"item_infused_raindrop",		--骨灰盒7.06
	
	"item_helm_of_iron_will", 
	"item_gloves", 
	"item_blades_of_attack",
	"item_recipe_armlet",			--臂章
	
	"item_belt_of_strength", 
	"item_ogre_axe",
	"item_recipe_sange",
	"item_talisman_of_evasion",		--天堂
	
	"item_boots_of_elves",
	"item_boots_of_elves", 
	"item_ogre_axe",				--魔龙枪
	
	"item_ring_of_health",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",
	"item_slippers",
	"item_circlet",
	"item_recipe_wraith_band",		--大推推7.07
	
	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",		--蓝杖

	"item_lifesteal",
	"item_reaver", 
	"item_claymore",				--撒旦7.07
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.ItemPurchase(ItemsToBuy)
end