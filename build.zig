const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.dependency("translate_c", .{});
    const glad: Translator = .init(translate_c, .{
        .c_source_file = b.path("src/glad.c"),
        .target = target,
        .optimize = optimize,
    });
    glad.addIncludePath(b.path("include/"));

    const gen = b.addExecutable(.{
        .name = "gen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("gen/glad.zig"),
            .target = b.graph.host,
            .optimize = .fast,
            .imports = &.{
                .{ .name = "glad", .module = glad.mod },
            },
        }),
    });
    const run = b.addRunArtifact(gen);
    const path = run.addOutputFileArg2("glad.zig", .{});

    const glad_mod = b.addModule("glad", .{
        .root_source_file = path,
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "glad", .module = glad.mod },
        },
    });

    _ = &glad_mod;
}
