--!strict
-- xirulent 2024
-- Easy persistent spacial query

-- Import modules
local RunService = game:GetService("RunService")
local Signal = require(game:GetService("ReplicatedStorage").Packages.Signal)

-- Find the difference between two tables (https://stackoverflow.com/a/24622157/20208239)
local function difference(a, b)
	local aa = {}
	for k,v in pairs(a) do aa[v]=true end
	for k,v in pairs(b) do aa[v]=nil end
	local ret = {}
	local n = 0
	for k,v in pairs(a) do
		if aa[v] then n=n+1 ret[n]=v end
	end
	return ret
end

-- Define the class
local ExtendRegionClass = {}
ExtendRegionClass.__index = ExtendRegionClass

-- Simple type to handle watch config data.
-- EvalFunc should take a ExtendRegionClass object
-- and return a boolean. Modify any objects needed
-- within the eval function.
export type watchconf = {
	Name: string,
	OVP: OverlapParams,
	Enabled: boolean,
	EvalFunc: (...any) -> { any },
	PollingRate: number
}

-- Creates a new instance of the class
function ExtendRegionClass.new(min: Vector3, max: Vector3, watchConfig: watchconf)
	local self = setmetatable({}, ExtendRegionClass)
	-- Set class data
	self.Region = Region3.new(min,max)
	self.WatchConfig = watchConfig
	self.Signals = {}
	self.Signals.Entered = Signal.new()
	self.Signals.Exitted = Signal.new()
	self.Watch = nil
	self.Members = {}
	
	-- Begin a watch if it should start by default
	if self.WatchConfig.Enabled then
		self:StartWatch()
	end
	
	return self
end

-- Cleans up the class
function ExtendRegionClass:Destroy()
	self.Watch:Disconnect()
	for _,signal in pairs(self.Signals) do
		signal:Destroy()
	end
end

-- Find the difference between two tables (https://stackoverflow.com/a/24622157/20208239)
			local function difference(a, b)
				local aa = {}
				for k,v in pairs(a) do aa[v]=true end
				for k,v in pairs(b) do aa[v]=nil end
				local ret = {}
				local n = 0
				for k,v in pairs(a) do
					if aa[v] then n=n+1 ret[n]=v end
				end
				return ret
			end

-- Starts watching for objects which meet the eval function
function ExtendRegionClass:StartWatch()
	if not self.WatchConfig.EvalFunc then warn(`<ExtendRegionClass> Cannot start watch: No EvalFunc is defined for "{self.WatchConfig.Name}"!`) return end
	if self.Watch then warn(`<ExtendRegionClass> Cannot start watch: a watch is already running for {self.WatchConfig.Name}`) return end
	
	-- Wrap the eval function so it may be cleaned up
	local function EvalWrapper()
		-- Define some tables to store data
		local r = {} -- Results of the latest evalfunc
		local new = {} -- Members returned by evalfunc that do not exist in self.Members
		local lost = {} -- Members not returned by evalfunc that exist in self.Members
		
		r = self.WatchConfig:EvalFunc(self.Region, self.WatchConfig.OVP) -- Run the eval function
		if r == self.Members then return end -- If there are no changes in members, return
	
		local function firesignals()
			new = difference(r, self.Members)
			lost = difference(self.Members, r)
			
			for _,v in pairs(new) do
				self.Signals.Entered:Fire(v)
			end
			for _,v in pairs(lost) do
				self.Signals.Exitted:Fire(v)
			end
		end
		
		local co = coroutine.create(firesignals)
		coroutine.resume(co)
		
		-- Update self.Members to the latest data
		self.Members = r
	end
	
	-- Start a thread which will run the eval wrapper function repeatedly
	local f = task.delay(self.WatchConfig.PollingRate/1000,EvalWrapper)
	
	-- Define a connection for the Watch object so it may be manipulated elsewhere
	self.Watch = RunService.Heartbeat:Connect(function(dt: number) 
		if coroutine.status(f) == "dead" then -- If the last check has completed, begin a new one
			f = task.delay(self.WatchConfig.PollingRate/1000,EvalWrapper)
		end
	end)
end

-- Stops watching for objects which meet the eval function
function ExtendRegionClass:EndWatch()
	if not self.Watch then warn(`<ExtendRegionClass> Cannot end watch: No watch is running for "{self.WatchConfig.Name}"!`) end
	self.Watch:Disconnect()
end

return ExtendRegionClass