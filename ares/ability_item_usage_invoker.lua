----------------------------------------------------------------------------
-- 	Bot: Invoker
--	Author: Yang Long 	Email: longyang_123@yeah.net
----------------------------------------------------------------------------
--------------------------------------
-- General Initialization
--------------------------------------
require(GetScriptDirectory() ..  "/utility")
require(GetScriptDirectory() ..  "/ability_item_usage_generic")

local debugmode=false
local npcBot = GetBot()
local Talents ={}
local Abilities ={}
local AbilitiesReal ={}
local currentAbilities = {}

ability_item_usage_generic.InitAbility(Abilities,AbilitiesReal,Talents) 

-- Basic skills
abilityQuas = npcBot:GetAbilityByName("invoker_quas");
abilityWex = npcBot:GetAbilityByName("invoker_wex");
abilityExort = npcBot:GetAbilityByName( "invoker_exort" );
abilityInvoke = npcBot:GetAbilityByName( "invoker_invoke" );

-- Special skills
abilityColdSnap = npcBot:GetAbilityByName( "invoker_cold_snap" );
abilityGhostWalk = npcBot:GetAbilityByName( "invoker_ghost_walk" );
abilityTornado = npcBot:GetAbilityByName( "invoker_tornado" );
abilityEMP = npcBot:GetAbilityByName( "invoker_emp" );
abilityAlacrity = npcBot:GetAbilityByName( "invoker_alacrity" );
abilityChaosMeteor = npcBot:GetAbilityByName( "invoker_chaos_meteor" );
abilitySunStrike = npcBot:GetAbilityByName( "invoker_sun_strike" );
abilityForgeSpirit = npcBot:GetAbilityByName( "invoker_forge_spirit" );
abilityIceWall = npcBot:GetAbilityByName( "invoker_ice_wall" );
abilityDeafeningBlast = npcBot:GetAbilityByName( "invoker_deafening_blast" );

-- The content of abilities:
-- 1: Quas
-- 2: Wex
-- 3: Exort
-- 4: Empty 1
-- 5: Empty 2
-- 6: Invoke

local AbilityToLevelUp=
{
	Abilities[3], 
	Abilities[1],
	Abilities[2],
	Abilities[3],
	Abilities[3],
	Abilities[3],
	Abilities[3],
	Abilities[3],
	Abilities[3],
	"talent",
	Abilities[1],
	Abilities[2],
	Abilities[1],
	Abilities[2],
	"talent",
	Abilities[1],
	Abilities[2],
	Abilities[1],
	Abilities[2],
	"talent",
	Abilities[1],
	Abilities[2],
	Abilities[1],
	Abilities[2],
	"talent",
}

local TalentTree={
	function()
		return Talents[1]
	end,
	function()
		return Talents[4]
	end,
	function()
		return Talents[6]
	end,
	function()
		return Talents[8]
	end
}

-- check skill build vs current level
utility.CheckAbilityBuild(AbilityToLevelUp)

function AbilityLevelUpThink()
	ability_item_usage_generic.AbilityLevelUpThink2(AbilityToLevelUp,TalentTree)
end

--------------------------------------
-- Ability Usage Thinking
--------------------------------------
local cast={} cast.Desire={} cast.Target={} cast.Type={}
local Consider ={}
local CanCast={utility.NCanCast,utility.NCanCast,utility.NCanCast,utility.UCanCast}
local enemyDisabled=utility.enemyDisabled

function GetComboDamage()
	return ability_item_usage_generic.GetComboDamage(AbilitiesReal)
end

function GetComboMana()
	return ability_item_usage_generic.GetComboMana(AbilitiesReal)
end

Consider[1]=function()

	local abilityNumber=1
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius();
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+0,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+0,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)

	--try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetLocation(); 
				end
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	--Last hit
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if(WeakestCreep~=nil)
		then
			if((ManaPercentage>0.5 or npcBot:GetMana()>ComboMana) and GetUnitToUnitDistance(npcBot,WeakestCreep)>=300)
			then
				local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, Damage );
				if ( locationAoE.count >= 1 ) then
					return BOT_ACTION_DESIRE_LOW-0.02, locationAoE.targetloc;
				end
			end		
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.5 or npcBot:GetMana()>ComboMana) and ability:GetLevel()>=2 )
		then
			local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, 0, 0 );
			if ( locationAoE.count >= 2 ) then
				return BOT_ACTION_DESIRE_LOW-0.01, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, Damage );

		if ( locationAoE.count >= 3 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), CastRange, Radius, 0, 0 );

		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW+0.01, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

Consider[2]=function()
local abilityNumber=2
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius()
	local CastPoint=ability:GetCastPoint()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	
	--try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,utility.GetUnitsTowardsLocation(npcBot,WeakestEnemy,GetUnitToUnitDistance(npcBot,WeakestEnemy)+100); 
				end
			end
		end
	end
	
	-- Check for a channeling enemy
	for _,npcEnemy in pairs( enemys )
	do
		if ( npcEnemy:IsChanneling() and CanCast[abilityNumber]( npcEnemy ) and not npcEnemy:HasModifier("modifier_teleporting") and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation( CastPoint ) 
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( (npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) or (npcBot:WasRecentlyDamagedByAnyHero(2.0) and #enemys>=1) ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, CastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
		
		for _,npcEnemy in pairs( enemys )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.0 ) and GetUnitToUnitDistance(npcBot,npcEnemy)<= 400) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation( CastPoint ) 
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), CastRange, Radius, CastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc
		end
		
		local npcEnemy = npcBot:GetTarget();

		if ( npcEnemy ~= nil ) 
		then
			if (CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy) and GetUnitToUnitDistance(npcBot,npcEnemy)<= CastRange)
			then
				return BOT_ACTION_DESIRE_MODERATE, utility.GetUnitsTowardsLocation(npcBot,npcEnemy,GetUnitToUnitDistance(npcBot,npcEnemy)+100)
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

Consider[3]=function()
	local abilityNumber=3
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() and ability:GetCurrentCharges()>0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = ability:GetAbilityDamage();
	local CastPoint = ability:GetCastPoint();
	
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(CastRange+300,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--Try to kill enemy hero
	if(npcBot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if ( CanCast[abilityNumber]( WeakestEnemy ) )
			then
				if(HeroHealth<=WeakestEnemy:GetActualIncomingDamage(Damage,DAMAGE_TYPE_MAGICAL) or (HeroHealth<=WeakestEnemy:GetActualIncomingDamage(GetComboDamage(),DAMAGE_TYPE_MAGICAL) and npcBot:GetMana()>ComboMana))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
				end
			end
		end
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	--protect myself
	local enemys2 = npcBot:GetNearbyHeroes( 300, true, BOT_MODE_NONE );
	if(npcBot:WasRecentlyDamagedByAnyHero(5))
	then
		for _,npcEnemy in pairs( enemys2 )
		do
			if ( CanCast[abilityNumber]( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( enemys )
		do
			if ( CanCast[abilityNumber]( npcEnemy )) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If my mana is enough,use it at enemy
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if((ManaPercentage>0.5 or npcBot:GetMana()>ComboMana) and HealthPercentage<=0.8 )
		then
			if (WeakestEnemy~=nil)
			then
				if ( CanCast[abilityNumber]( WeakestEnemy ) )
				then
					return BOT_ACTION_DESIRE_LOW,WeakestEnemy;
				end
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();

		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) and GetUnitToUnitDistance(npcBot,npcEnemy)< CastRange + 75*#allys)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

Consider[4]=function()
	local abilityNumber=4
	--------------------------------------
	-- Generic Variable Setting
	--------------------------------------
	local ability=AbilitiesReal[abilityNumber];
	
	if not ability:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local CastRange = ability:GetCastRange();
	local Damage = 0--ability:GetAbilityDamage();
	local Radius = ability:GetAOERadius()
	
	local HeroHealth=10000
	local CreepHealth=10000
	local allys = npcBot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local enemys = npcBot:GetNearbyHeroes(Radius,true,BOT_MODE_NONE)
	local WeakestEnemy,HeroHealth=utility.GetWeakestUnit(enemys)
	local towers = npcBot:GetNearbyTowers(CastRange+300,true)
	local creeps = npcBot:GetNearbyCreeps(CastRange+300,true)
	local WeakestCreep,CreepHealth=utility.GetWeakestUnit(creeps)
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	local disabledheronum=0
	for _,temphero in pairs(enemys)
	do
		if (enemyDisabled(temphero) or temphero:GetCurrentMovementSpeed()<=200)
		then
			disabledheronum=disabledheronum+1
		end
	end
			
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		if ( #enemys+disabledheronum >= 3) 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	-- If we're pushing or defending a lane
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT  ) 
	then
		if ( #enemys+#creeps<=2 and #towers>=1) 
		then
			if (ManaPercentage>0.4 or npcBot:GetMana()>ComboMana)
			then
				return BOT_ACTION_DESIRE_LOW
			end
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = npcBot:GetTarget();

		if ( npcEnemy ~= nil ) 
		then
			if ( CanCast[abilityNumber]( npcEnemy ) and GetUnitToUnitDistance(npcEnemy,npcBot)<=Radius)
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function AbilityUsageThink()

	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() )
	then 
		return
	end
	
	ComboMana=GetComboMana()
	AttackRange=npcBot:GetAttackRange()
	ManaPercentage=npcBot:GetMana()/npcBot:GetMaxMana()
	HealthPercentage=npcBot:GetHealth()/npcBot:GetMaxHealth()
	
	cast=ability_item_usage_generic.ConsiderAbility(AbilitiesReal,Consider)
	---------------------------------debug--------------------------------------------
	if(debugmode==true)
	then
		ability_item_usage_generic.PrintDebugInfo(AbilitiesReal,cast)
	end
	ability_item_usage_generic.UseAbility(AbilitiesReal,cast)
end

function CourierUsageThink() 
	ability_item_usage_generic.CourierUsageThink()
end

function AbilityPrepare(AbilitiesReal,cast)
	-- Basic skills
	--- abilityQuas = npcBot:GetAbilityByName("invoker_quas");
	--- abilityWex = npcBot:GetAbilityByName("invoker_wex");
	--- abilityExort = npcBot:GetAbilityByName( "invoker_exort" );
	--- abilityInvoke = npcBot:GetAbilityByName( "invoker_invoke" );
	--- 
	local npcBot=GetBot()
	
	local HighestDesire=0
	local HighestDesireAbility=0
	local HighestDesireAbilityBumber=0
	for i,ability in pairs(AbilitiesReal)
	do
		if (cast.Desire[i]~=nil and cast.Desire[i]>HighestDesire)
		then
			HighestDesire=cast.Desire[i]
			HighestDesireAbilityBumber=i
		end
	end

	local j=HighestDesireAbilityBumber
	local ability=AbilitiesReal[j]

	--- Abilities List
	-- 1: EMP
	-- 2: Tornado
	-- 3: Alacrity
	-- 4: Ghost Walk
	-- 5: Deafening Blast
	-- 6: Chaos Meteor
	-- 7: Cold Snap
	-- 8: Ice Wall
	-- 9: Forge Spirit
	-- 10: Sun Strike

	-- 1: Wex/Wex/Wex
	if (HighestDesireAbilityBumber == 1)
	then
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityWex);
	end

	-- 2: Quas/Wex/Wex
	if (HighestDesireAbilityBumber == 2)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityWex);
	end

	-- 3: Wex/Wex/Exort
	if (HighestDesireAbilityBumber == 3)
	then
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- 4: Quas/Quas/Wex
	if (HighestDesireAbilityBumber == 4)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityWex);	
	end

	-- 5: Quas/Wex/Exort
	if (HighestDesireAbilityBumber == 5)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- 6: Wex/Exort/Exort
	if (HighestDesireAbilityBumber == 6)
	then
		npcBot:Action_UseAbility(abilityWex);
		npcBot:Action_UseAbility(abilityExort);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- 7: Quas/Quas/Quas
	if (HighestDesireAbilityBumber == 7)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityQuas);
	end

	-- 8: Quas/Quas/Exort
	if (HighestDesireAbilityBumber == 8)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- 9: Quas/Exort/Exort
	if (HighestDesireAbilityBumber == 9)
	then
		npcBot:Action_UseAbility(abilityQuas);
		npcBot:Action_UseAbility(abilityExort);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- 10: Exort/Exort/Exort
	if (HighestDesireAbilityBumber == 9)
	then
		npcBot:Action_UseAbility(abilityExort);
		npcBot:Action_UseAbility(abilityExort);
		npcBot:Action_UseAbility(abilityExort);
	end

	-- TODO: Aghanim's Scepter will reduce the cool down time
	npcBot:Action_UseAbility(abilityInvoke);
end