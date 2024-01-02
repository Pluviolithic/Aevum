export type Status = "Idle" | "Ended" | "Paused" | "Running"
return {
	Idle = "Idle", -- has not yet been added to the scheduler
	Ended = "Ended", -- has been cancelled or completed
	Paused = "Paused", -- has been paused
	Running = "Running", -- is currently running
} :: { [string]: Status }
