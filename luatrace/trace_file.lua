-- Write luatrace traces to a file. Each line is one of
-- [S>] <filename> <linedefined> <lastlinedefined>  -- Start or call into a trace at filename somewhere in the function defined at linedefined
-- <                                            -- Return from a function
-- R <thread_id>                                -- Resume the thread thread_id
-- Y                                            -- Yield
-- P                                            -- pcall - the current line is protected for the duration of the following call
-- E                                            -- Error - unwind the stack until you find a p.
-- <linenumber> <microseconds>                  -- Accumulate microseconds against linenumber
-- Usually, a line will have time accumulated to it before and after it calls a function, so
-- function b() return 1 end
-- function c() return 2 end
-- a = b() + c()
-- will be traced as
-- 3 (time)
-- > (file) 1 1
-- 1 (time)
-- <
-- 3 (time)
-- > (file) 2 2
-- 2 (time)
-- <
-- 3 (time)


local DEFAULT_TRACE_LIMIT = 10000       -- How many traces to store before writing them out
                                        -- What to call the trace file

-- Maybe these should be fields of a trace-file table.
local traces                            -- Array of traces
local count                             -- Number of traces
local limit                             -- How many traces we'll hold before we write them to...


-- Write traces to a file ------------------------------------------------------

local function write_trace(a, b, c, d)
    local line = ""
    if type(a) == "number" then
        line = tonumber(a) .. "\n"
    elseif a:match("[>ST]") then
        line = a .. " " .. tostring(b) .. " " .. tostring(c) .. " " .. tostring(d) .. "\n"
    elseif a == "R" then
        line = "R " .. tostring(b) .. "\n"
    else -- It's one of <, Y, P or E
        line = a .. "\n"
    end
    return line
end




local function write_traces()
  local trace_str = ""
  for i = 1, count do
    local t = traces[i]
    trace_str = trace_str .. write_trace(t[1], t[2], t[3], t[4])
  end
  count = 0
  return trace_str
end


-- API -------------------------------------------------------------------------

local trace_file = {}

local defaults =
{
  trace_limit = DEFAULT_TRACE_LIMIT
}

local function get_settings(s)
  s = s or {}
  for k, v in pairs(defaults) do
    if not s[k] then s[k] = v end
  end
  return s
end


function trace_file.record(a, b, c, d)
  if limit < 2 then
    write_trace(a, b, c, d)
  else
    count = count + 1
    traces[count] = { a, b, c, d }
    if count > limit then write_traces() end
  end
end


function trace_file.open(settings)
  settings = get_settings(settings)

  limit = settings.trace_limit

  count, traces = 0, {}
end


function trace_file.close()
  return write_traces()
end


return trace_file


-- EOF -------------------------------------------------------------------------

