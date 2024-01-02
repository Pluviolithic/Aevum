local HttpService = game:GetService("HttpService")

local Status = require(script.Parent.Status)

type AlarmImpl = {
	__index: AlarmImpl,
	new: (finishTime: DateTime, precision: string, callback: () -> ()) -> Alarm,
	_callback: () -> (),
	_update: (self: Alarm, dt: number) -> (),
	GetStatus: (self: Alarm) -> Status.Status,
	Pause: (self: Alarm) -> (),
	Cancel: (self: Alarm) -> (),
	Resume: (self: Alarm) -> (),
	AssignName: (self: Alarm, name: string) -> (),
	GetName: (self: Alarm) -> string,
	GetUUID: (self: Alarm) -> string,
}

export type Alarm = typeof(setmetatable(
	{} :: {
		_finishTime: number,
		_precision: string,
		_callback: () -> (),
		_status: Status.Status,
		_UUID: string,
		_name: string,
	},
	{} :: AlarmImpl
))

local Alarm = {} :: AlarmImpl
Alarm.__index = Alarm

function Alarm.new(finishTime: DateTime, precision: string, callback: () -> ())
	local t
	if precision == "ms" then
		t = finishTime.UnixTimestampMillis
	else
		t = finishTime.UnixTimestamp
	end
	local self = setmetatable({
		_finishTime = t,
		_precision = precision,
		_callback = callback,
		_status = Status.Idle,
		_UUID = HttpService:GenerateGUID(false),
	}, Alarm)

	self._name = self._UUID

	return self
end

function Alarm:_update()
	if self._precision == "ms" then
		if DateTime.now().UnixTimestampMillis >= self._finishTime then
			self._status = Status.Ended
			self._callback()
		end
	elseif self._precision == "s" then
		if DateTime.now().UnixTimestamp >= self._finishTime then
			self._status = Status.Ended
			self._callback()
		end
	elseif self._precision == "m" then
		if DateTime.now().UnixTimestamp // 60 >= self._finishTime then
			self._status = Status.Ended
			self._callback()
		end
	elseif self._precision == "h" then
		if DateTime.now().UnixTimestamp // 3600 >= self._finishTime then
			self._status = Status.Ended
			self._callback()
		end
	end
end

function Alarm:Cancel()
	self._status = Status.Ended
end

function Alarm:GetStatus()
	return self._status
end

function Alarm:AssignName(name: string)
	self._name = name
end

function Alarm:GetName()
	return self._name
end

function Alarm:GetUUID()
	return self._UUID
end

return Alarm
