# Useage

```
luatrace = require("luatrace")
luatrace.tron()
······
local trace_str = luatrace.troff() # get output
```

# Output

```
luatrace: tracing with Lua hook
> test.lua 0 0
16
> test.lua 10 12
11
> test.lua 5 7
6
<
11
12
<
16
17
> ./luatrace.lua 350 359
351
```
