--[=[
	@class Aevum

	A clock library for Roblox that tracks countdowns and more.
]=]

local RunService = game:GetService("RunService")

local Aevum = {
	_chronometers = require(script.Chronometers),
	registerChronometer = require(script.registerChronometer),
	Alarm = require(script.Alarm),
	Timer = require(script.Timer),
}

RunService.Heartbeat:Connect(function(dt)
	for UUID, Chronometer in pairs(Aevum._chronometers) do
		if Chronometer:GetStatus() == "Paused" then
			continue
		end

		Chronometer:_update(dt)

		if Chronometer:GetStatus() == "Ended" then
			Aevum._chronometers[UUID] = nil
		end
	end
end)

return Aevum
