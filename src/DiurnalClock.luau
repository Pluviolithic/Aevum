local HttpService = game:GetService("HttpService")

local Signal = require(script.Parent.Parent.Signal)
local Status = require(script.Parent.Status)

export type DiurnalClockImpl = {
	__index: DiurnalClockImpl,
	new: (period: number?, startTime: number?) -> DiurnalClock,
	_callbacks: { () -> () },
	_update: (self: DiurnalClock, dt: number) -> (),
	GetStatus: (self: DiurnalClock) -> Status.Status,
	Pause: (self: DiurnalClock) -> (),
	Cancel: (self: DiurnalClock) -> (),
	Resume: (self: DiurnalClock) -> (),
	AssignName: (self: DiurnalClock, name: string) -> (),
	GetName: (self: DiurnalClock) -> string,
	GetUUID: (self: DiurnalClock) -> string,
	Read: (self: DiurnalClock, formatStyle: string?) -> number | string,
	SetPeriod: (self: DiurnalClock, period: number) -> (),
}

export type DiurnalClock = typeof(setmetatable(
	{} :: {
		_period: number,
		_time: number,
		_status: Status.Status,
		_UUID: string,
		_name: string,
		_startTime: number,
		Updated: Signal.Signal<number>,
	},
	{} :: DiurnalClockImpl
))

local DiurnalClock = {} :: DiurnalClockImpl
DiurnalClock.__index = DiurnalClock

function DiurnalClock.new(period: number?, startTime: number?)
	local self = setmetatable({
		_period = period or 24,
		_time = startTime or 0,
		_status = Status.Idle,
		_UUID = HttpService:GenerateGUID(false),
	}, DiurnalClock)

	self._startTime = self._time
	self._name = "DiurnalClock_" .. self._UUID
	self.Updated = Signal.new()

	return self
end

function DiurnalClock:_update(dt: number)
	if self._status == Status.Ended then
		return
	end

	self._time = (self._time + dt) % self._period
	self.Updated:Fire(self._time)
end

function DiurnalClock:Cancel()
	self._status = Status.Ended
end

function DiurnalClock:Pause()
	self._status = Status.Paused
end

function DiurnalClock:Resume()
	self._status = Status.Running
end

function DiurnalClock:GetStatus()
	return self._status
end

function DiurnalClock:AssignName(name: string)
	self._name = name
end

function DiurnalClock:GetName()
	return self._name
end

function DiurnalClock:GetUUID()
	return self._UUID
end

function DiurnalClock:Read(formatStyle: string?)
	local hours = math.floor(self._time / 3600)
	local minutes = math.floor((self._time % 3600) / 60)
	local seconds = math.floor(self._time % 60)

	if formatStyle == "HH:MM:SS" then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	elseif formatStyle == "HH:MM" then
		return string.format("%02d:%02d", hours, minutes)
	elseif "HH" then
		return string.format("%02d", hours)
	end

	return self._time
end

function DiurnalClock:SetPeriod(period: number)
	self._period = period
end

return DiurnalClock
