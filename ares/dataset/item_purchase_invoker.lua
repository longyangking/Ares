require( GetScriptDirectory().."../genericutils" ) 

local ItemsToBuy = 
{ 
	"item_tango",
	"item_clarity",
	"item_branches",
	"item_branches",
	"item_wind_lace",
	"item_magic_stick",
	"item_enchanted_mango",			
	"item_boots",
	"item_belt_of_strength",
	"item_gloves",					

	"item_ring_of_health",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",		
	
	"item_boots_of_elves",
	"item_boots_of_elves", 
	"item_ogre_axe",				
	"item_slippers",
	"item_circlet",
	"item_recipe_wraith_band",		
	
	"item_gauntlets",
	"item_circlet",
	"item_recipe_bracer",
	"item_gauntlets",
	"item_circlet",
	"item_recipe_bracer",
	"item_staff_of_wizardry",
	"item_recipe_rod_of_atos",		
	
	"item_staff_of_wizardry",
	"item_void_stone",
	"item_recipe_cyclone",				
	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",		
	"item_void_stone",
	"item_ultimate_orb",
	"item_mystic_staff",			
}

utility.checkItemBuild(ItemsToBuy)

function ItemPurchaseThink()
	utility.BuySupportItem()
	utility.ItemPurchase(ItemsToBuy)
end