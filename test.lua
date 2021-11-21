-- Can the tracer survive a pcall?

luatrace = require("luatrace")

function ok()
  return 1
end


function pcall_ok()
  ok()
end


luatrace.tron()
pcall_ok()
local trace_str = luatrace.troff()
print(trace_str)