MapVote.TaskManager = MapVote.TaskManager or {
    maxTimePerTick = 0.01,
    tasks = {}
}
local TaskManager = MapVote.TaskManager

---@param task thread
function TaskManager.AddTask( task )
    if #TaskManager.tasks == 0 then
        TaskManager.StartLoop()
    end
    table.insert( TaskManager.tasks, task )
end

---@param func function
function TaskManager.AddFunc( func )
    local task = coroutine.create( func )
    TaskManager.AddTask( task )
end

function TaskManager.StartLoop()
    hook.Add( "Tick", "MapVote_TaskLoop", function()
        local startTime = SysTime()
        local maxPerTick = TaskManager.maxTimePerTick
        while SysTime() - startTime < maxPerTick do
            if #TaskManager.tasks == 0 then
                print( "MapVote: Task list empty, removing hook" )
                hook.Remove( "Tick", "MapVote_TaskLoop" )
                return
            end

            local i = math.random( #TaskManager.tasks )
            local task = TaskManager.tasks[i]
            local ok, _ = coroutine.resume( task )
            if not ok then
                table.remove( TaskManager.tasks, i )
            end
        end
    end )
end
