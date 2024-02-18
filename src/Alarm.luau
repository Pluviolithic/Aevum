local HttpService = game:GetService("HttpService")

local Signal = require(script.Parent.Parent.Signal)
local Status = require(script.Parent.Status)

type AlarmImpl = {
	__index: AlarmImpl,
	new: (finishTime: number, callback: () -> ()) -> Alarm,
	_update: (self: Alarm, dt: number) -> (),
	GetStatus: (self: Alarm) -> Status.Status,
	Pause: (self: Alarm) -> (),
	Cancel: (self: Alarm) -> (),
	Resume: (self: Alarm) -> (),
	AssignName: (self: Alarm, name: string) -> (),
	GetName: (self: Alarm) -> string,
	GetUUID: (self: Alarm) -> string,
	Read: (self: Alarm) -> DateTime,
}

export type Alarm = typeof(setmetatable(
	{} :: {
		_finishTime: number,
		_status: Status.Status,
		_UUID: string,
		_name: string,
		Ended: Signal.Signal<nil>,
	},
	{} :: AlarmImpl
))

local Alarm = {} :: AlarmImpl
Alarm.__index = Alarm

function Alarm.new(finishTime: number)
	local self = setmetatable({
		_finishTime = finishTime,
		_status = Status.Idle,
		_UUID = HttpService:GenerateGUID(false),
	}, Alarm)

	self._name = "Alarm_" .. self._UUID
	self.Ended = Signal.new()

	return self
end

function Alarm:_update()
	if self._status == Status.Ended then
		return
	end

	if tick() >= self._finishTime then
		self._status = Status.Ended
		self.Ended:Fire()
		self.Ended:Destroy()
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

function Alarm:Read()
	return DateTime.fromUnixTimestamp(self._finishTime)
end

return Alarm
