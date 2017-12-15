_G._savedEnv = getfenv()
module("PushUtility", package.seeall)

local role = require(GetScriptDirectory() ..  "/RoleUtility")

function GetLane( nTeam ,hHero )
        local vBot = GetLaneFrontLocation(nTeam, LANE_BOT, 0)
        local vTop = GetLaneFrontLocation(nTeam, LANE_TOP, 0)
        local vMid = GetLaneFrontLocation(nTeam, LANE_MID, 0)
        --print(GetUnitToLocationDistance(hHero, vMid))
        if GetUnitToLocationDistance(hHero, vBot) < 2500 then
            return LANE_BOT
        end
        if GetUnitToLocationDistance(hHero, vTop) < 2500 then
            return LANE_TOP
        end
        if GetUnitToLocationDistance(hHero, vMid) < 2500 then
            return LANE_MID
        end
        return LANE_NONE
end

function IsThisLaneNeedToClean(npcBot,lane)

	local front = GetLaneFrontLocation( GetTeam(), lane, 0 )
	local AllyTower = GetNearestBuilding(GetTeam(), front)
	local DistanceToFront = GetUnitToLocationDistance( npcBot, AllyTower:GetLocation() )
	local creeps = GetUnitList( UNIT_LIST_ENEMY_CREEPS )
	local creepsCount =0
	local creepsAlly = GetUnitList( UNIT_LIST_ALLIED_CREEPS )
	local creepsAllyCount =0
	for i,creep in pairs(creeps)
	do
		if(GetUnitToLocationDistance(creep,front)<=2500)
		then
			creepsCount=creepsCount+1
		end
	end
	for i,creep in pairs(creepsAlly)
	do
		if(GetUnitToLocationDistance(creep,front)<=2500)
		then
			creepsAllyCount=creepsAllyCount+1
		end
	end
	
	local CountDelta=creepsCount-creepsAllyCount
	local DistanceFactor=DistanceToFront/1500
	
	if(DistanceToFront<=6000 and DistanceFactor<=CountDelta)
	then
		--print(npcBot:GetUnitName().." need to clean lane- "..lane)
		return true
	end
	
	return false
end

function GetUnitPushLaneDesire(npcBot,lane)
	local team = GetTeam()
	local teamPush = GetPushLaneDesire( lane );

	local levelFactor = 1
	if npcBot:GetLevel() < 6 then
		levelFactor = 0
	end
	
	local mylane=GetLane(team,npcBot)
	if(mylane ~= LANE_NONE)
	then
		local ThisLaneNeedToClean=IsThisLaneNeedToClean(npcBot,mylane)
		if(ThisLaneNeedToClean==true and mylane~=lane)
		then
			return 0
		end
	end
	
	local healthRate = npcBot:GetHealth() / npcBot:GetMaxHealth()
	local manaRate = npcBot:GetMana() / npcBot:GetMaxMana()
	local stateFactor = healthRate * 0.7 + manaRate * 0.3
	
	local front = GetLaneFrontLocation( GetTeam(), lane, 0 )
	local DistanceToFront = GetUnitToLocationDistance( npcBot, front ) 
	local nearBuilding = GetNearestBuilding(team, front)
	local distBuilding = GetUnitToLocationDistance( nearBuilding, front )
	local distFactor = 0
	local tp = IsItemAvailable("item_tpscroll")
	if tp then 
		tp = tp:IsFullyCastable()
	end
	local travel = IsItemAvailable("item_travel_boots")
	if travel then 
		travel = travel:IsFullyCastable()
	end
	if DistanceToFront <= 1000 or travel then
		distFactor = 1
	elseif DistanceToFront - distBuilding >= 3000 and tp then
		if distBuilding <= 1000 then
			distFactor = 0.7
		elseif distBuilding >= 6000 then
			distFactor = 0
		else
			distFactor = -(distBuilding - 6000) * 0.7 / 5000
		end
	elseif DistanceToFront >= 10000 then
		distFactor = 0
	else
		distFactor = -(DistanceToFront - 10000) / 9000
	end
	
	local desire =  math.min(( 0.2 + 0.2 * levelFactor + 0.25 * stateFactor + 0.35 * distFactor ) * teamPush , 0.8)
	
	return desire
end

function UnitPushLaneThink(npcBot,lane)
	if (npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:GetQueuedActionType(0) == BOT_ACTION_TYPE_USE_ABILITY) then
		return;
	end

	local team = GetTeam()
	local front = GetLaneFrontLocation( GetTeam(), lane, 0 )
	local DistanceToFront = GetUnitToLocationDistance( npcBot, front ) 
	local nearBuilding = GetNearestBuilding(team, front)
	local distBuilding = GetUnitToLocationDistance( nearBuilding, front )
	local Amount=GetAmountAlongLane(lane,npcBot:GetLocation())
	local DistanceToLane=Amount.distance
	local tp = IsItemAvailable("item_tpscroll")
	if not tp or not tp:IsFullyCastable() then 
		tp = nil
	end
	local travel = IsItemAvailable("item_travel_boots")
	if not travel or not travel:IsFullyCastable() then 
		travel = nil
	end
	if DistanceToFront > 4000 then								--use tp to push quickly
		if travel then
			npcBot:Action_UseAbilityOnLocation( travel, front )
			return true
		elseif tp and DistanceToFront - distBuilding > 3000 and DistanceToLane >3000 then
			npcBot:Action_UseAbilityOnLocation( tp, front )
			return true
		end
	end
	
	local AllyTower = GetNearestBuilding(GetTeam(), front)
	local AllyTowerDistance = GetUnitToUnitDistance(npcBot,AllyTower)
	local EnemyTower = GetNearestBuilding(GetOpposingTeam(), front)
	local TowerDistance = GetUnitToUnitDistance(npcBot,EnemyTower)
	local TargetLocation		--Scatter station to avoid AOE
	
	local EnemySpawnLocation=GetEnemySpawnLocation()	--Do not dive tower
	local DistanceToEnemyHome=GetUnitToLocationDistance(npcBot,EnemySpawnLocation)
	local DistanceTowerToEnemyHome=GetUnitToLocationDistance(EnemyTower,EnemySpawnLocation)
	local MaxDiveLength=500
	
	local gamma=0
	if(TowerDistance<1000)
	then
		if(lane==LANE_MID)
		then
			gamma=-15
		end
		TargetLocation=GetSafeLocation(npcBot,EnemyTower:GetLocation(),gamma);
	else
		if(lane==LANE_MID)
		then
			gamma=-5
		end
		if(PointToPointDistance(front,EnemySpawnLocation)<DistanceTowerToEnemyHome-MaxDiveLength)
		then
			TargetLocation=GetSafeLocation(npcBot,AllyTower:GetLocation(),gamma) ;
		else
			TargetLocation=GetSafeLocation(npcBot,front,gamma) ;
		end
	end

	local creeps = npcBot:GetNearbyCreeps(1000,true);
	local enemys = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE)
	local CreepMinDistance=3000
	local Safe = false
	

	
	local creepst = npcBot:GetNearbyCreeps(1600,false);
	local creeps2 = {}
	for k,v in pairs(creepst)
	do
		if(GetUnitToUnitDistance(v,EnemyTower)<800)
		then
			table.insert(creeps2,v)
		end
	end
	

	local NoCreeps=false
	
	if(TowerDistance<GetUnitToUnitDistance(EnemyTower,AllyTower) and PointToPointDistance(front,EnemySpawnLocation)<DistanceTowerToEnemyHome-MaxDiveLength) then
		NoCreeps=true
	end
	
	if(TowerDistance>1000 or AllyTowerDistance<=700)
	then
		Safe = true
	end
	
	if(creeps2~=nil and #creeps2>=2)
	then
		for k,v in pairs(creeps2)
		do
			local tempDistance=GetUnitToUnitDistance(v,EnemyTower)
			if(tempDistance<CreepMinDistance)
			then
				CreepMinDistance=tempDistance
			end
		end
		if(TowerDistance<CreepMinDistance or DistanceToEnemyHome<DistanceTowerToEnemyHome-MaxDiveLength)
		then
			Safe = false
		else
			Safe = true
		end
	end

	local IsCreepAttackTower = false
	if(creeps2~=nil and #creeps2>=1)
	then
		for k,v in pairs(creeps2)
		do
			if(v:GetAttackTarget()==EnemyTower)
			then
				IsCreepAttackTower=true
			end
		end
	end
	
	local target,targetHealth
	if(creeps~=nil and #creeps>=1 and (GetUnitToLocationDistance(npcBot,TargetLocation)<=200 or TowerDistance<=800))
	then
		if(GetUnitToLocationDistance(target,EnemySpawnLocation)<DistanceTowerToEnemyHome-MaxDiveLength)	--This location is diving tower, do not make yourself in dangerous.
		then
			target = creeps[1]
			targetHealth=target:GetHealth()
			TargetLocation=GetSafeLocation(npcBot,target:GetLocation(),0)
		end
	end
	
	local MinDelta=150
	local level=npcBot:GetLevel()
	local health=npcBot:GetHealth()
	if(level>=11 and health>=1500)
	then
		MinDelta=200
		NoCreeps=false
	end
	
	if(IsEnemyTooMany()) then
		AssmbleWithAlly(npcBot)
	elseif (Safe==false or NoCreeps==true) and EnemyTower:GetHealth()/EnemyTower:GetMaxHealth()>=0.2  then
		StepBack( npcBot )
	elseif npcBot:WasRecentlyDamagedByTower(1) then		--if I'm under attck of tower, then try to avoid attack
	if((enemys~=nil and #enemys>=1) or not TransferHatred( npcBot ))
	then
		StepBack( npcBot )
	end
	elseif GetUnitToLocationDistance(npcBot,TargetLocation)>=MinDelta then
		npcBot:Action_MoveToLocation(TargetLocation);
	elseif target then
		local damage = npcBot:GetAttackDamage()
		local actualDamage = target:GetActualIncomingDamage(damage,DAMAGE_TYPE_PHYSICAL)
		-- if actualDamage < targetHealth and actualDamage * 2 > targetHealth and target:WasRecentlyDamagedByCreep(2) then
			-- npcBot:Action_ClearActions(true)
		-- else
			npcBot:Action_AttackUnit( target, true )
			--npcBot:Action_AttackMove(TargetLocation);
		--end
	elseif TowerDistance <= 1200 then
		if (IsCreepAttackTower) then
			npcBot:Action_AttackUnit( EnemyTower, false )
		else
			StepBack( npcBot )
		end
	else
		npcBot:Action_MoveToLocation(TargetLocation);
	end
	return true
end

-- function IsLocationSafeToAttack(location)
	-- local MaxDiveLength=200
	-- if(TowerDistance<CreepMinDistance or DistanceToEnemyHome<DistanceTowerToEnemyHome-MaxDiveLength)
	-- then
		-- Safe = false
	-- end
-- end

function GetEnemySpawnLocation()
	if GetTeam() == TEAM_RADIANT then
		return Locations.DireSpawn
	else
		return Locations.RadiantSpawn
	end
end

function GetAllySpawnLocation()
	if GetTeam() == TEAM_RADIANT then
		return Locations.RadiantSpawn
	else
		return Locations.DireSpawn
	end
end

function GetSafeLocation(npcBot,BasicLocation,gamma)
	local EnemyTeam = GetOpposingTeam()
	local Allys = npcBot:GetNearbyHeroes(1600,false,BOT_MODE_NONE)
	local MyAttackRange=npcBot:GetAttackRange()
	
	local RangeConstant=175
	local RandomInt=0
	local IsRange
	if(MyAttackRange>RangeConstant)
	then
		IsRange=true
		RandomInt=25
		--MyAttackRange=MyAttackRange-25
	else
		IsRange=false
		RandomInt=0
		--MyAttackRange=MyAttackRange+25
	end
	
	local ids = {}
	local MinDamageHeroID
	local MinDamage=1000
	for k,v in pairs(Allys)
	do
		local damage=v:GetAttackDamage()
		local AttackRange=v:GetAttackRange()
		if(damage<MinDamage and role.IsSupport(v:GetUnitName()) and AttackRange>RangeConstant)
		then
			MinDamage=damage
			MinDamageHeroID=v:GetPlayerID()
		end
	end
	
	for k,v in pairs(Allys)
	do
		local IsRange2=false
		if(v:GetAttackRange()>RangeConstant)
		then
			IsRange2=true
		end
		if(IsRange==IsRange2)
		then
			table.insert(ids,v:GetPlayerID())
		end
	end
	table.sort(ids)

	if(MinDamageHeroID==npcBot:GetPlayerID() and #Allys>=3)
	then
		MyAttackRange=800
	end

	local alpha
	if(npcBot:GetAttackRange()>RangeConstant)
	then
		alpha=210
	else
		alpha=300
	end
	local spawnloc=GetEnemySpawnLocation()
	local DistanceToEnemyHome=GetUnitToLocationDistance(npcBot,spawnloc)
	local DistanceToHome=npcBot:DistanceFromFountain() 
	local UnitVector
	if(DistanceToEnemyHome-DistanceToHome<0)
	then
		UnitVector=GetUnitVector(spawnloc,BasicLocation)
	else
		UnitVector=GetUnitVector(BasicLocation,GetAllySpawnLocation())
	end
	
	--DebugDrawLine( spawnloc, BasicLocation, 100, 0, 100 ) 
	local theta=math.deg(math.atan2(UnitVector.y,UnitVector.x))
	if(theta<0)
	then
		theta=theta+360
	end
	local myid=npcBot:GetPlayerID()
	local myNumber=1
	for k,v in pairs(ids)
	do
		if(myid==v)
		then
			myNumber=k
		end
	end
	
	local delta=math.rad(theta-alpha/2+alpha/(#ids+1)*myNumber+gamma)
	local FinalVector=Vector(math.cos(delta),math.sin(delta))
	local TargetLocation=BasicLocation+MyAttackRange*FinalVector
	--DebugDrawLine( BasicLocation, TargetLocation, 255, 0, 0 ) 
	
	return TargetLocation --+ RandomVector( RandomInt ) 
end

function IsItemAvailable(item_name)
    local npcBot = GetBot();

    for i = 0, 5, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

function GetUnitVector(vMyLocation,vTargetLocation)
	return (vTargetLocation-vMyLocation)/PointToPointDistance(vMyLocation,vTargetLocation)
end

function PointToPointDistance(p1, p2)
	return math.sqrt(( p1.x - p2.x ) ^ 2 + ( p1.y - p2.y ) ^ 2 )
end

function GetPointDistanceSqu(p1, p2)
	return ( p1.x - p2.x ) ^ 2 + ( p1.y - p2.y ) ^ 2 
end

function GetNearestBuilding(team, location)
	local buildings = GetAllBuilding( team, location )
	local minDist = 16000 ^ 2
	local nearestBuilding = nil
	for k,v in pairs(buildings) do
		local DistanceToFront = GetPointDistanceSqu(location, v:GetLocation())
		if DistanceToFront < minDist then
			if(team==GetTeam() or v:IsInvulnerable()==false)
			then
				minDist = DistanceToFront
				nearestBuilding = v
			end
		end
	end
	return nearestBuilding
end

function GetAllBuilding( team,location )
	local buildings = {}
	for i=0,10 do
		local tower = GetTower(team,i)
		if NotNilOrDead(tower) then
			table.insert(buildings,tower)
		end
	end

	for i=0,5 do
		local barrack = GetBarracks( team, i )
		if NotNilOrDead(barrack) then
			table.insert(buildings,barrack)
		end
	end

	for i=0,4 do
		local shrine = GetShrine(team, i) 
		if NotNilOrDead(shrine) then
			table.insert(buildings,shrine)
		end 
	end

	local ancient = GetAncient( team )
	table.insert(buildings,ancient)
	return buildings
end

function NotNilOrDead(unit)
	if unit==nil or unit:IsNull() then
		return false;
	end
	if unit:IsAlive() then
		return true;
	end
	return false;
end

function GetWeakestCreep(r)
	local npcBot = GetBot();
	
	local EnemyCreeps = npcBot:GetNearbyLaneCreeps(r,true);
	
	if EnemyCreeps==nil or #EnemyCreeps==0 then
		return nil,10000;
	end
	
	local WeakestCreep=nil;
	local LowestHealth=10000;
	
	for _,creep in pairs(EnemyCreeps) do
		if creep~=nil and creep:IsAlive() then
			if creep:GetHealth()<LowestHealth then
				LowestHealth=creep:GetHealth();
				WeakestCreep=creep;
			end
		end
	end
	
	return WeakestCreep,LowestHealth;
end

Locations = {
	["RadiantSpawn"]= Vector(-6950,-6275),
	["DireSpawn"]= Vector(7150, 6300),
	}
	

function TransferHatred( unit )
	if not NotNilOrDead(unit) then
		return false
	end

	local towers = unit:GetNearbyTowers( 1000, true )
	local tower
	if towers and #towers > 0 then
		tower = towers[1]
	end
    local creeps = unit:GetNearbyCreeps( 1500, false )
	-- print("hurt",#creeps)
	for k,creep in pairs(creeps) do
		if NotNilOrDead(creep) and NotNilOrDead(tower) and GetUnitToUnitDistance(tower, creep)<=tower:GetAttackRange() then
			unit:Action_AttackUnit( creep, true )
			return true
		end
	end 
	return false
end

function AssmbleWithAlly(unit)
	if not NotNilOrDead(unit) then
		return
	end
	StepBack( unit )
end

function StepBack( unit )
	if not NotNilOrDead(unit) then
		return
	end
	
	local team = GetTeam()
	local lane = GetLane(team,unit)
	local front = GetLaneFrontLocation( team, lane, 0 )
	local AllyTower = GetNearestBuilding(team, front)
	local spawnloc = AllyTower:GetLocation();
	-- local spawnloc
	-- if team == TEAM_RADIANT then
		-- spawnloc = Locations.RadiantSpawn
	-- else
		-- spawnloc = Locations.DireSpawn
	-- end

	local targetloc = Normalized(spawnloc - unit:GetLocation()) * 500 + unit:GetLocation()
	unit:Action_MoveToLocation(targetloc+RandomVector( 100 ) )
end
	
function Normalized(vector)
	local mod = ( vector.x ^ 2 + vector.y ^ 2 ) ^ 0.5
	return Vector(vector.x / mod, vector.y / mod)
end

function IsEnemyTooMany()
	local npcBot=GetBot()
	local MyLane=GetLane(GetTeam(),npcBot)
	if (MyLane==LANE_NONE)
	then
		return false
	end
	
	local AllyCount=0
	local EnemyCount=0
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local enemies = GetEnemyTeam()
	for _,ally in pairs(allies) do
		local Lane=GetLane(GetTeam(),ally)
		if NotNilOrDead(ally) and GetUnitToUnitDistance(npcBot,ally)<1600 and MyLane==Lane then
			AllyCount=AllyCount+1
		end
	end

	for _,enemy in pairs(enemies) do
		local Lane=GetLane(GetTeam(),enemy)
		if NotNilOrDead(enemy) and GetUnitToUnitDistance(npcBot,ally)<3000 and MyLane==Lane then
			EnemyCount=EnemyCount+1
		end
	end
	
	if(EnemyCount>AllyCount)
	then
		print(npcBot:GetName().." enemy is too much")
		return true
	else
		return false
	end
end


EnemyHeroListTimer=-1000;
EnemyHeroList=nil;

function GetRealHero(Candidates)
	if Candidates==nil or #Candidates==0 then
		return nil;
	end

	local q=false;
	for i,unit in pairs(Candidates) do
		if unit.isIllusion==nil or (not unit.isIllusion) then
			q=true;
		end
	end

	if not q then
		for i,unit in pairs(Candidates) do
			if unit.isRealHero~=nil and unit.isRealHero then
				return i,unit;
			end
		end
		return nil;
	end

	for i,unit in pairs(Candidates) do
		if unit:HasModifier("modifier_bloodseeker_thirst_vision") then
			return i,unit;
		end
	end

	for i,unit in pairs(Candidates) do
		local int = unit:GetAttributeValue(2);
		local baseRegen=0.01;
		if unit:GetUnitName()==npc_dota_hero_techies then
			baseRegen=0.02;
		end

		if math.abs(unit:GetManaRegen()-(baseRegen+0.04*int))>0.001 then
			return i,unit;
		end
	end

	local hpRegen=Candidates[1]:GetHealthRegen();
	local suspectind=1;
	local suspect=Candidates[1];

	for i,unit in pairs(Candidates) do
		if hpRegen<unit:GetHealthRegen() then
			suspect=unit;
			hpRegen=unit:GetHealthRegen();
			suspectind=i;
		end
	end

	for _,unit in pairs(Candidates) do
		if hpRegen>unit:GetHealthRegen() then
			return suspectind,suspect;
		end
	end

	for i,unit in pairs(Candidates) do
		if unit:IsUsingAbility() or unit:IsChanneling() then
			return i,unit;
		end
	end

	if #Candidates==1 and (Candidates[1].isIllusion==nil or (not Candidates[1].isIllusion)) then
		return 1,Candidates[1];
	end

	return nil;
end

function GetEnemyTeam()
	if EnemyHeroList~=nil and DotaTime()-EnemyHeroListTimer<0.1 then
		return EnemyHeroList;
	end

	EnemyHeroListTimer=DotaTime();
	EnemyHeroList={}

	for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		local q=false;
		for _,unit2 in pairs(EnemyHeroList) do
			if unit2:GetUnitName()==unit:GetUnitName() then
				q=true;
			end
		end

		if not q then
			local skip=false;
			if not NotNilOrDead(unit) then
				skip=true;
			end
--			if unit.isRealHero~=nil and unit.isRealHero then
--				table.insert(EnemyHeroList,unit);
--				skip=true;
--			end
--			if unit.isIllusion~=nil and unit.isIllusion then
--				skip=true;
--			end

			if not skip then
				local candidates={};
				for _,unit2 in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
					if NotNilOrDead(unit2) and unit2:GetUnitName() == unit:GetUnitName() then
						table.insert(candidates,unit2);
					end
				end

				local ind,hero=GetRealHero(candidates);
				if hero~=nil and (hero.isIllusion==nil or (not hero.isIllusion)) then
					for _,can in pairs(candidates) do
						can.isIllusion=true;
						can.isRealHero=false;
					end

					hero.isIllusion=false;
					hero.isRealHero=true;

					table.insert(EnemyHeroList,hero);
				end
			end
		end
	end

	return EnemyHeroList;
end
for k,v in pairs( PushUtility ) do _G._savedEnv[k] = v end