local HttpService = game:GetService("HttpService")

local Signal = require(script.Parent.Parent.Signal)
local Status = require(script.Parent.Status)

type TimerImpl = {
	__index: TimerImpl,
	new: (length: number, callback: () -> ()) -> Timer,
	_update: (self: Timer, dt: number) -> (),
	GetStatus: (self: Timer) -> Status.Status,
	Pause: (self: Timer) -> (),
	Cancel: (self: Timer) -> (),
	Resume: (self: Timer) -> (),
	AssignName: (self: Timer, name: string) -> (),
	GetName: (self: Timer) -> string,
	GetUUID: (self: Timer) -> string,
	Read: (self: Timer, formatStyle: string) -> string | number,
}

export type Timer = typeof(setmetatable(
	{} :: {
		_length: number,
		_remainingTime: number,
		_status: Status.Status,
		_UUID: string,
		_name: string,
		Ended: Signal.Signal<nil>,
	},
	{} :: TimerImpl
))

local Timer = {} :: TimerImpl
Timer.__index = Timer

function Timer.new(length: number)
	local self = setmetatable({
		_length = length,
		_remainingTime = length,
		_status = Status.Idle,
		_UUID = HttpService:GenerateGUID(false),
	}, Timer)

	self._name = "Timer_" .. self._UUID
	self.Ended = Signal.new()

	return self
end

function Timer:_update(dt: number)
	if self._status ~= Status.Running then
		return
	end

	self._remainingTime -= dt

	if self._remainingTime <= 0 then
		self._status = Status.Ended
		self.Ended:Fire()
		self.Ended:Destroy()
	end
end

function Timer:Cancel()
	self._status = Status.Ended
end

function Timer:Pause()
	self._status = Status.Paused
end

function Timer:Resume()
	self._status = Status.Running
end

function Timer:GetStatus()
	return self._status
end

function Timer:AssignName(name: string)
	self._name = name
end

function Timer:GetName()
	return self._name
end

function Timer:GetUUID()
	return self._UUID
end

function Timer:Read(formatStyle: string)
	local hours = math.floor(self._remainingTime / 3600)
	local minutes = math.floor((self._remainingTime % 3600) / 60)
	local seconds = math.floor(self._remainingTime % 60)

	if formatStyle == "HH:MM:SS" then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	elseif formatStyle == "HH:MM" then
		return string.format("%02d:%02d", hours, minutes)
	elseif "HH" then
		return string.format("%02d", hours)
	elseif "suffix" then
		if hours >= 24 then
			return `{hours // 24}d`
		elseif hours > 0 then
			return `{hours}h`
		elseif minutes > 0 then
			return `{minutes}m`
		else
			return `{seconds}s`
		end
	end

	return self._remainingTime
end

return Timer
