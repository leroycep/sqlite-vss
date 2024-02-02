const std = @import("std");

const VERSION = @embedFile("VERSION");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = try std.SemanticVersion.parse(VERSION);

    const sqlite = b.dependency("sqlite", .{
        .target = target,
        .optimize = optimize,
    });

    const faiss = b.dependency("faiss", .{
        .target = target,
        .optimize = optimize,
    });

    const vss_h = b.addConfigHeader(.{ .style = .{ .cmake = .{ .path = "src/sqlite-vss.h.in" } } }, .{
        .SQLITE_VSS_VERSION = "v" ++ VERSION,
        .SQLITE_VSS_VERSION_MAJOR = @as(i64, @intCast(version.major)),
        .SQLITE_VSS_VERSION_MINOR = @as(i64, @intCast(version.minor)),
        .SQLITE_VSS_VERSION_PATCH = @as(i64, @intCast(version.patch)),
    });
    const vector_h = b.addConfigHeader(.{ .style = .{ .cmake = .{ .path = "src/sqlite-vector.h.in" } } }, .{});

    // vss library
    const vss = b.addSharedLibrary(.{
        .name = "vss0",
        .target = target,
        .optimize = optimize,
    });
    vss.addConfigHeader(vss_h);
    vss.addConfigHeader(vector_h);
    vss.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vss.cpp",
        },
    });
    vss.linkLibrary(sqlite.artifact("sqlite3"));
    vss.linkLibrary(faiss.artifact("faiss"));
    vss.linkLibCpp();
    const install_vss = b.addInstallArtifact(vss, .{ .dest_sub_path = "vss0.so" });
    b.getInstallStep().dependOn(&install_vss.step);

    // vector library
    const vector = b.addSharedLibrary(.{
        .name = "vector0",
        .target = target,
        .optimize = optimize,
    });
    vector.addConfigHeader(vss_h);
    vector.addConfigHeader(vector_h);
    vector.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vector.cpp",
        },
    });
    vector.linkLibrary(sqlite.artifact("sqlite3"));
    vector.addIncludePath(.{ .path = "vendor/json/single_include/" });
    vector.linkLibCpp();
    const install_vector = b.addInstallArtifact(vector, .{ .dest_sub_path = "vector0.so" });
    b.getInstallStep().dependOn(&install_vector.step);
}
