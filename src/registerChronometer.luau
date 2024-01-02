local chronometers = require(script.Parent.Chronometers)
local Alarm = require(script.Parent.Alarm)
local Timer = require(script.Parent.Timer)
local Status = require(script.Parent.Status)

return function(chronometer: Alarm.Alarm & Timer.Timer)
	assert(chronometer._status ~= Status.Idle, `Chronometer {chronometer:GetName()} has already been registered.`)
	chronometers[chronometer:GetUUID()] = chronometer
end
