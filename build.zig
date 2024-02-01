const std = @import("std");

const VERSION = @embedFile("VERSION");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = try std.SemanticVersion.parse(VERSION);

    const faiss_avx2 = b.addSharedLibrary(.{
        .name = "faiss",
        .target = target,
        .optimize = optimize,
    });
    faiss_avx2.addCSourceFiles(.{
        .files = &.{
            "vendor/faiss/faiss/AutoTune.cpp",
            "vendor/faiss/faiss/Clustering.cpp",
            "vendor/faiss/faiss/IVFlib.cpp",
            "vendor/faiss/faiss/Index.cpp",
            "vendor/faiss/faiss/Index2Layer.cpp",
            "vendor/faiss/faiss/IndexAdditiveQuantizer.cpp",
            "vendor/faiss/faiss/IndexBinary.cpp",
            "vendor/faiss/faiss/IndexBinaryFlat.cpp",
            "vendor/faiss/faiss/IndexBinaryFromFloat.cpp",
            "vendor/faiss/faiss/IndexBinaryHNSW.cpp",
            "vendor/faiss/faiss/IndexBinaryHash.cpp",
            "vendor/faiss/faiss/IndexBinaryIVF.cpp",
            "vendor/faiss/faiss/IndexFlat.cpp",
            "vendor/faiss/faiss/IndexFlatCodes.cpp",
            "vendor/faiss/faiss/IndexHNSW.cpp",
            "vendor/faiss/faiss/IndexIDMap.cpp",
            "vendor/faiss/faiss/IndexIVF.cpp",
            "vendor/faiss/faiss/IndexIVFAdditiveQuantizer.cpp",
            "vendor/faiss/faiss/IndexIVFFlat.cpp",
            "vendor/faiss/faiss/IndexIVFPQ.cpp",
            "vendor/faiss/faiss/IndexIVFFastScan.cpp",
            "vendor/faiss/faiss/IndexIVFAdditiveQuantizerFastScan.cpp",
            "vendor/faiss/faiss/IndexIVFPQFastScan.cpp",
            "vendor/faiss/faiss/IndexIVFPQR.cpp",
            "vendor/faiss/faiss/IndexIVFSpectralHash.cpp",
            "vendor/faiss/faiss/IndexLSH.cpp",
            "vendor/faiss/faiss/IndexNNDescent.cpp",
            "vendor/faiss/faiss/IndexLattice.cpp",
            "vendor/faiss/faiss/IndexNSG.cpp",
            "vendor/faiss/faiss/IndexPQ.cpp",
            "vendor/faiss/faiss/IndexFastScan.cpp",
            "vendor/faiss/faiss/IndexAdditiveQuantizerFastScan.cpp",
            "vendor/faiss/faiss/IndexPQFastScan.cpp",
            "vendor/faiss/faiss/IndexPreTransform.cpp",
            "vendor/faiss/faiss/IndexRefine.cpp",
            "vendor/faiss/faiss/IndexReplicas.cpp",
            "vendor/faiss/faiss/IndexRowwiseMinMax.cpp",
            "vendor/faiss/faiss/IndexScalarQuantizer.cpp",
            "vendor/faiss/faiss/IndexShards.cpp",
            "vendor/faiss/faiss/MatrixStats.cpp",
            "vendor/faiss/faiss/MetaIndexes.cpp",
            "vendor/faiss/faiss/VectorTransform.cpp",
            "vendor/faiss/faiss/clone_index.cpp",
            "vendor/faiss/faiss/index_factory.cpp",

            "vendor/faiss/faiss/impl/AuxIndexStructures.cpp",
            "vendor/faiss/faiss/impl/CodePacker.cpp",
            "vendor/faiss/faiss/impl/IDSelector.cpp",
            "vendor/faiss/faiss/impl/FaissException.cpp",
            "vendor/faiss/faiss/impl/HNSW.cpp",
            "vendor/faiss/faiss/impl/NSG.cpp",
            "vendor/faiss/faiss/impl/PolysemousTraining.cpp",
            "vendor/faiss/faiss/impl/ProductQuantizer.cpp",
            "vendor/faiss/faiss/impl/AdditiveQuantizer.cpp",
            "vendor/faiss/faiss/impl/ResidualQuantizer.cpp",
            "vendor/faiss/faiss/impl/LocalSearchQuantizer.cpp",
            "vendor/faiss/faiss/impl/ProductAdditiveQuantizer.cpp",
            "vendor/faiss/faiss/impl/ScalarQuantizer.cpp",
            "vendor/faiss/faiss/impl/index_read.cpp",
            "vendor/faiss/faiss/impl/index_write.cpp",
            "vendor/faiss/faiss/impl/io.cpp",
            "vendor/faiss/faiss/impl/kmeans1d.cpp",
            "vendor/faiss/faiss/impl/lattice_Zn.cpp",
            "vendor/faiss/faiss/impl/pq4_fast_scan.cpp",
            "vendor/faiss/faiss/impl/pq4_fast_scan_search_1.cpp",
            "vendor/faiss/faiss/impl/pq4_fast_scan_search_qbs.cpp",
            // "vendor/faiss/faiss/impl/io.cpp",
            // "vendor/faiss/faiss/impl/lattice_Zn.cpp",
            "vendor/faiss/faiss/impl/NNDescent.cpp",

            "vendor/faiss/faiss/invlists/BlockInvertedLists.cpp",
            "vendor/faiss/faiss/invlists/DirectMap.cpp",
            "vendor/faiss/faiss/invlists/InvertedLists.cpp",
            "vendor/faiss/faiss/invlists/InvertedListsIOHook.cpp",

            "vendor/faiss/faiss/utils/Heap.cpp",
            "vendor/faiss/faiss/utils/WorkerThread.cpp",
            "vendor/faiss/faiss/utils/distances.cpp",
            "vendor/faiss/faiss/utils/distances_simd.cpp",
            "vendor/faiss/faiss/utils/extra_distances.cpp",
            "vendor/faiss/faiss/utils/hamming.cpp",
            "vendor/faiss/faiss/utils/partitioning.cpp",
            "vendor/faiss/faiss/utils/quantize_lut.cpp",
            "vendor/faiss/faiss/utils/random.cpp",
            "vendor/faiss/faiss/utils/sorting.cpp",
            "vendor/faiss/faiss/utils/utils.cpp",
            "vendor/faiss/faiss/utils/distances_fused/avx512.cpp",
            "vendor/faiss/faiss/utils/distances_fused/distances_fused.cpp",
            "vendor/faiss/faiss/utils/distances_fused/simdlib_based.cpp",
        },
        .flags = &.{ "-mavx2", "-mfma", "-mf16c", "-mpopcnt" },
    });
    if (target.result.os.tag != .windows) {
        faiss_avx2.addCSourceFiles(.{ .files = &.{
            "vendor/faiss/faiss/invlists/OnDiskInvertedLists.cpp",
        } });
    }
    faiss_avx2.defineCMacro("FINTEGER", "int"); // may be different with avx2 support enabled
    faiss_avx2.addIncludePath(.{ .path = "vendor/faiss/" });
    faiss_avx2.linkSystemLibrary2("omp", .{});
    faiss_avx2.linkSystemLibrary2("blas", .{});
    faiss_avx2.linkSystemLibrary2("lapack", .{});
    faiss_avx2.linkLibCpp();
    faiss_avx2.root_module.pic = true;
    faiss_avx2.installHeadersDirectoryOptions(.{ .source_dir = .{ .path = "vendor/faiss/faiss" }, .install_dir = .header, .install_subdir = "faiss" });
    b.installArtifact(faiss_avx2);

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
    vss.linkSystemLibrary2("sqlite3", .{});
    vss.linkLibrary(faiss_avx2);
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
    vector.linkSystemLibrary2("sqlite3", .{});
    vector.addIncludePath(.{ .path = "vendor/json/single_include/" });
    vector.linkLibCpp();
    const install_vector = b.addInstallArtifact(vector, .{ .dest_sub_path = "vector0.so" });
    b.getInstallStep().dependOn(&install_vector.step);
}
