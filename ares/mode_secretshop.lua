function GetDesire()
	
	local npcBot = GetBot();

	local desire = 0.0;
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() )		
	then
		return 0
	end
	
	if ( npcBot.secretShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) then
		local d=npcBot:DistanceFromSecretShop()
		if d<3000
		then
			desire = (3000-d)/3000*0.3+0.3;				
		end
	end
  
	return desire

end

----------------------------------------------------------------------------------------------------