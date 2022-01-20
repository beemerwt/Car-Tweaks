--***********************************************************
--**                   BEEMER'S CHANGES                    **
--***********************************************************

CarTweaks = _G['CarTweaks'] or {}

-- BEFORE: Took parts based on flat percentage
-- NOW: Has a minimum of 20% per part and each part can
--	take less condition depending on mechanics level
CarTweaks.takeEngineParts = function(player, args)
	local vehicle = getVehicleById(args.vehicle)
	if vehicle then
		local part = vehicle:getPartById("Engine")
		if not part then
			print('no such part Engine')
			return
		end

		local cond = part:getCondition();

    local minParts = cond / 20;
    local maxParts = cond / 5;
    local diff = maxParts - minParts;
    local modRoll = diff % 1;
    diff = math.floor(diff)

    -- Modifier % to the perfect salvage
    local modifierPct = 80;

    -- the percentage change based on skill to get a "perfect" salvage
    local perfectSalvage = ((args.skillLevel / 10) * modifierPct);

    local numParts = minParts;
    for i = 1, diff do
      if (ZombRand(100) <= perfectSalvage) then
        numParts = numParts + 1
      end
    end

    if (ZombRand(100) <= perfectSalvage * modRoll) then
      numParts = numParts + 1
    end

    numParts = math.min(numParts, math.floor(maxParts));

		if numParts > 0 then
			if args.giveXP then
				player:sendObjectChange('addXp', { perk = Perks.Mechanics:index(), xp = numParts / 2, noMultiplier = false })
			end
			
			player:sendObjectChange('addItemOfType', { type = 'Base.EngineParts', count = numParts })
		end

		part:setCondition(0)
		vehicle:transmitPartCondition(part)
		player:sendObjectChange('mechanicActionDone', { success = (numParts > 0), vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
	else
		print('no such vehicle id='..tostring(args.vehicle))
	end
end

-- BEFORE: Repaired 1% per part
-- NOW: Repairs between a minimum and maximum
--	calculated based on mechanics level.
-- 	Ranges from level 5 with a minimum of 2, maximum of 3
--  to level 10 with a minimum of 4, maximum of 6
CarTweaks.repairEngine = function(player, args)
	local vehicle = getVehicleById(args.vehicle)
	if vehicle then
		local part = vehicle:getPartById("Engine")
		if not part then
			print('no such part Engine')
			return
		end

		-- Add element of randomness to repairing for each part
		local minCondPerPart = 1 + math.floor(args.skillLevel / 3);
		local maxCondPerPart = 1 + math.floor(5 * (args.skillLevel / 10));

		local done = 0
		for i=1,args.numberOfParts do
			local condThisPart = ZombRand(minCondPerPart, maxCondPerPart + 1);
			part:setCondition(part:getCondition() + condThisPart)
			done = done + 1
			if part:getCondition() >= 100 then
				part:setCondition(100)
				break
			end
		end
		if done > 0 then
			if args.giveXP then
				player:sendObjectChange('addXp', { perk = Perks.Mechanics:index(), xp = done, noMultiplier = false })
			end
			player:sendObjectChange('removeItemType', { type = 'Base.EngineParts', count = done })
			vehicle:transmitPartCondition(part)
		end
		player:sendObjectChange('mechanicActionDone', { success = (done > 0), vehicleId = vehicle:getId(), partId = part:getId(), itemId = -1, installing = true })
	else
		print('no such vehicle id='..tostring(args.vehicle))
	end
end

-- Taken from lua/server/Vehicles/VehicleCommands.lua
CarTweaks.OnClientCommand = function(module, command, player, args)
	if module == 'CarTweaks' and CarTweaks[command] then
		CarTweaks[command](player, args)
	end
end

Events.OnClientCommand.Add(CarTweaks.OnClientCommand)