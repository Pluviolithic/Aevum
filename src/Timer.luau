local HttpService = game:GetService("HttpService")

local Status = require(script.Parent.Status)

type TimerImpl = {
	__index: TimerImpl,
	new: (length: number, callback: () -> ()) -> Timer,
	_callback: () -> (),
	_update: (self: Timer, dt: number) -> (),
	GetStatus: (self: Timer) -> Status.Status,
	Pause: (self: Timer) -> (),
	Cancel: (self: Timer) -> (),
	Resume: (self: Timer) -> (),
	AssignName: (self: Timer, name: string) -> (),
	GetName: (self: Timer) -> string,
	GetUUID: (self: Timer) -> string,
}

export type Timer = typeof(setmetatable(
	{} :: { _length: number, _callback: () -> (), _status: Status.Status, _UUID: string, _name: string },
	{} :: TimerImpl
))

local Timer = {} :: TimerImpl
Timer.__index = Timer

function Timer.new(length: number, callback: () -> ())
	local self = setmetatable({
		_length = length,
		_callback = callback,
		_status = Status.Idle,
		_UUID = HttpService:GenerateGUID(false),
	}, Timer)

	self._name = "Timer_" .. self._UUID

	return self
end

function Timer:_update(dt: number)
	self._length -= dt

	if self._length <= 0 then
		self._status = Status.Ended
		task.spawn(self._callback)
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

return Timer
