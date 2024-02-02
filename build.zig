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

    const faiss_static = b.dependency("faiss", .{
        .target = target,
        .optimize = optimize,
        .linkage = .static,
    });

    const faiss_dynamic = b.dependency("faiss", .{
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    const vss_h = b.addConfigHeader(.{ .style = .{ .cmake = .{ .path = "src/sqlite-vss.h.in" } } }, .{
        .SQLITE_VSS_VERSION = "v" ++ VERSION,
        .SQLITE_VSS_VERSION_MAJOR = @as(i64, @intCast(version.major)),
        .SQLITE_VSS_VERSION_MINOR = @as(i64, @intCast(version.minor)),
        .SQLITE_VSS_VERSION_PATCH = @as(i64, @intCast(version.patch)),
    });
    const vector_h = b.addConfigHeader(.{ .style = .{ .cmake = .{ .path = "src/sqlite-vector.h.in" } } }, .{});

    // shared libraries

    // vector library
    const vector_dynamic = b.addSharedLibrary(.{
        .name = "vector_dynamic",
        .target = target,
        .optimize = optimize,
    });
    vector_dynamic.addConfigHeader(vss_h);
    vector_dynamic.addConfigHeader(vector_h);
    vector_dynamic.installConfigHeader(vector_h, .{});
    vector_dynamic.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vector.cpp",
        },
    });
    vector_dynamic.linkLibrary(sqlite.artifact("sqlite3"));
    vector_dynamic.addIncludePath(.{ .path = "vendor/json/" });
    vector_dynamic.linkLibCpp();
    const install_vector_dynamic = b.addInstallArtifact(vector_dynamic, .{
        .dest_dir = .{ .override = .bin },
        .dest_sub_path = "vector0.so",
    });
    b.getInstallStep().dependOn(&install_vector_dynamic.step);

    // vss library
    const vss_dynamic = b.addSharedLibrary(.{
        .name = "vss_dynamic",
        .target = target,
        .optimize = optimize,
    });
    vss_dynamic.addConfigHeader(vss_h);
    vss_dynamic.installConfigHeader(vss_h, .{});
    vss_dynamic.addConfigHeader(vector_h);
    vss_dynamic.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vss.cpp",
        },
    });
    vss_dynamic.linkLibrary(sqlite.artifact("sqlite3"));
    vss_dynamic.linkLibrary(faiss_dynamic.artifact("faiss"));
    vss_dynamic.linkLibCpp();
    const install_vss_dynamic = b.addInstallArtifact(vss_dynamic, .{
        .dest_dir = .{ .override = .bin },
        .dest_sub_path = "vss0.so",
    });
    b.getInstallStep().dependOn(&install_vss_dynamic.step);

    // static libraries

    // vector library
    const vector_static = b.addStaticLibrary(.{
        .name = "vector",
        .target = target,
        .optimize = optimize,
    });
    vector_static.addConfigHeader(vss_h);
    vector_static.addConfigHeader(vector_h);
    vector_static.installConfigHeader(vector_h, .{});
    vector_static.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vector.cpp",
        },
    });
    vector_static.linkLibrary(sqlite.artifact("sqlite3"));
    vector_static.addIncludePath(.{ .path = "vendor/json/" });
    vector_static.linkLibCpp();
    b.installArtifact(vector_static);

    // vss library
    const vss_static = b.addStaticLibrary(.{
        .name = "vss",
        .target = target,
        .optimize = optimize,
    });
    vss_static.addConfigHeader(vss_h);
    vss_static.installConfigHeader(vss_h, .{});
    vss_static.addConfigHeader(vector_h);
    vss_static.addCSourceFiles(.{
        .files = &.{
            "src/sqlite-vss.cpp",
        },
    });
    vss_static.linkLibrary(sqlite.artifact("sqlite3"));
    vss_static.linkLibrary(faiss_static.artifact("faiss"));
    vss_static.linkLibCpp();
    b.installArtifact(vss_static);
}
