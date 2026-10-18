# GLAD OpenGL4.6

Writer this in you build.zig:

```zig
const glad = @import("glad");
//...
glad_mod = glad.gladModule(
    b,
    b.dependency("glad", .{}),
    target,
    optimize,
);
```
