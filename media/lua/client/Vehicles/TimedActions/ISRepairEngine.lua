--***********************************************************
--**                    THE INDIE STONE                    **
--**             Modified By: Beemer (CarTweaks)           **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISRepairEngine = ISBaseTimedAction:derive("ISRepairEngine")

function ISRepairEngine:isValid()
--	return self.vehicle:isInArea(self.part:getArea(), self.character)
	return true;
end

function ISRepairEngine:waitToStart()
	self.character:faceThisObject(self.vehicle)
	return self.character:shouldBeTurning()
end

function ISRepairEngine:update()
	self.character:faceThisObject(self.vehicle)
	self.item:setJobDelta(self:getJobDelta())
  self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function ISRepairEngine:start()
	self.item:setJobType(getText("IGUI_RepairEngine"))
	self:setActionAnim("VehicleWorkOnMid")
end

function ISRepairEngine:stop()
	self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function ISRepairEngine:perform()
	ISBaseTimedAction.perform(self)
	self.item:setJobDelta(0)

	local skill = self.character:getPerkLevel(Perks.Mechanics);
	local ignoreEngineLevel = SandboxVars.CarTweaks.IgnoreEngineLevelForRepair
	if ignoreEngineLevel == false then
		-- subtract levels for engines with repair lvl >4
		skill = skill - self.vehicle:getScript():getEngineRepairLevel() + 4; 
	end
	local numberOfParts = self.character:getInventory():getNumberOfItem("EngineParts", false, true);
	local args = { vehicle = self.vehicle:getId(), condition = self.part:getCondition(), skillLevel = skill, numberOfParts = numberOfParts }
	args.giveXP = self.character:getMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2") == nil

	sendClientCommand(self.character, 'CarTweaks', 'repairEngine', args)
	self.character:addMechanicsItem(self.part:getVehicle():getMechanicalID() .. "2", self.part, getGameTime():getCalender():getTimeInMillis());
end

function ISRepairEngine:new(character, part, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = part:getVehicle()
	o.part = part
	o.item = item
	o.maxTime = time
	o.jobType = getText("IGUI_RepairEngine")
	return o
end

