const std = @import("std");
const glad = @import("glad");

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    const outfile_path = args[1];

    // const outfile = std.Io.File.stdout();
    const outfile = try std.Io.Dir.cwd().createFile(io, outfile_path, .{});
    defer outfile.close(io);

    var buffer: [64]u8 = undefined;
    var writer = outfile.writer(io, &buffer);
    const w = &writer.interface;

    try w.writeAll(
        \\const glad = @import("glad");
        \\
        \\pub const loadGLLoader = glad.gladLoadGLLoader;
        \\
    );

    const info = @typeInfo(glad).@"struct";
    for (info.decl_names) |decl_name| if (!std.mem.startsWith(u8, decl_name, "glad")) {
        if (std.mem.cutPrefix(u8, decl_name, "gl")) |name| {
            try w.print("pub const {c}{s} = glad.{s};\n", .{
                std.ascii.toLower(name[0]),
                name[1..],
                decl_name,
            });
        } else if (std.mem.cutPrefix(u8, decl_name, "GL_")) |name| {
            if (std.ascii.isAlphabetic(name[0])) {
                try w.print("pub const {s} = glad.{s};\n", .{
                    name,
                    decl_name,
                });
            } else {
                try w.print("pub const @\"{s}\" = glad.{s};\n", .{
                    name,
                    decl_name,
                });
            }
        }
    };

    try w.flush();
}
