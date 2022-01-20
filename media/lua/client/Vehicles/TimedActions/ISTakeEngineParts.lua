--***********************************************************
--**                    THE INDIE STONE                    **
--**             Modified By: Beemer (CarTweaks)           **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISTakeEngineParts = ISBaseTimedAction:derive("ISTakeEngineParts")

function ISTakeEngineParts:isValid()
	return true;
end

function ISTakeEngineParts:update()
	self.character:faceThisObject(self.vehicle)
	self.item:setJobDelta(self:getJobDelta())
  self.character:setMetabolicTarget(Metabolics.MediumWork);
end

function ISTakeEngineParts:start()
	self.item:setJobType(getText("IGUI_TakeEngineParts"))
end

function ISTakeEngineParts:stop()
	self.item:setJobDelta(0)
	ISBaseTimedAction.stop(self)
end

function ISTakeEngineParts:perform()
	ISBaseTimedAction.perform(self)
	self.item:setJobDelta(0)

	local skill = self.character:getPerkLevel(Perks.Mechanics);
	local args = { vehicle = self.vehicle:getId(), skillLevel = skill, addXp = shouldAddXp }
	args.giveXP = self.character:getMechanicsItem(self.part:getVehicle():getMechanicalID() .. "3") == nil

	sendClientCommand(self.character, 'CarTweaks', 'takeEngineParts', args)
	self.character:addMechanicsItem(self.vehicle:getMechanicalID() .. "3", self.part, getGameTime():getCalender():getTimeInMillis());
end

function ISTakeEngineParts:new(character, part, item, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.vehicle = part:getVehicle()
	o.part = part
	o.item = item
	o.maxTime = time
	o.jobType = getText("IGUI_TakeEngineParts")
	return o
end

