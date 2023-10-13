const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const is_dynamic = b.option(bool, "shared", "Build libui as a dynamically linked library") orelse false;

    const lib = if (is_dynamic)
        b.addSharedLibrary(.{
            .name = "ui",
            .target = target,
            .optimize = optimize,
        })
    else
        b.addStaticLibrary(.{
            .name = "ui",
            .target = target,
            .optimize = optimize,
        });
    lib.linkLibC();
    lib.addIncludePath(.{ .path = "common" });
    lib.installHeader("ui.h", "ui.h");
    lib.defineCMacro("libui_EXPORTS", "");
    lib.addCSourceFiles(.{
        .files = &.{
            "common/areaevents.c",
            "common/attribute.c",
            "common/attrlist.c",
            "common/attrstr.c",
            "common/control.c",
            "common/debug.c",
            "common/matrix.c",
            "common/opentype.c",
            "common/shouldquit.c",
            "common/table.c",
            "common/tablemodel.c",
            "common/tablevalue.c",
            "common/userbugs.c",
            "common/utf.c",
        },
        .flags = &.{},
    });

    if (target.isDarwin()) {
        // use darwin/*.m backend
        lib.installHeader("ui_darwin.h", "ui_darwin.h");
        lib.addIncludePath(.{ .path = "darwin" });
        lib.linkFramework("Foundation");
        lib.linkFramework("Appkit");
        lib.addSystemIncludePath(.{ .path = "Cocoa" });
        lib.addCSourceFiles(.{
            .files = &.{
                "darwin/aat.m",
                "darwin/alloc.m",
                "darwin/areaevents.m",
                "darwin/area.m",
                "darwin/attrstr.m",
                "darwin/autolayout.m",
                "darwin/box.m",
                "darwin/button.m",
                "darwin/checkbox.m",
                "darwin/colorbutton.m",
                "darwin/combobox.m",
                "darwin/control.m",
                "darwin/datetimepicker.m",
                "darwin/debug.m",
                "darwin/draw.m",
                "darwin/drawtext.m",
                "darwin/editablecombo.m",
                "darwin/entry.m",
                "darwin/event.m",
                "darwin/fontbutton.m",
                "darwin/fontmatch.m",
                "darwin/fonttraits.m",
                "darwin/fontvariation.m",
                "darwin/form.m",
                "darwin/future.m",
                "darwin/graphemes.m",
                "darwin/grid.m",
                "darwin/group.m",
                "darwin/image.m",
                "darwin/label.m",
                "darwin/main.m",
                "darwin/menu.m",
                "darwin/multilineentry.m",
                "darwin/nstextfield.m",
                "darwin/opentype.m",
                "darwin/progressbar.m",
                "darwin/radiobuttons.m",
                "darwin/scrollview.m",
                "darwin/separator.m",
                "darwin/slider.m",
                "darwin/spinbox.m",
                "darwin/stddialogs.m",
                "darwin/tablecolumn.m",
                "darwin/table.m",
                "darwin/tab.m",
                "darwin/text.m",
                "darwin/undocumented.m",
                "darwin/util.m",
                "darwin/window.m",
                "darwin/winmoveresize.m",
            },
            .flags = &.{},
        });
    } else if (target.isWindows()) {
        // use windows/*.cpp backend
        lib.installHeader("ui_windows.h", "ui_windows.h");
        lib.subsystem = .Windows;
        lib.addIncludePath(.{ .path = "windows" });
        lib.linkSystemLibrary("user32");
        lib.linkSystemLibrary("kernel32");
        lib.linkSystemLibrary("gdi32");
        lib.linkSystemLibrary("comctl32");
        lib.linkSystemLibrary("uxtheme");
        lib.linkSystemLibrary("msimg32");
        lib.linkSystemLibrary("comdlg32");
        lib.linkSystemLibrary("d2d1");
        lib.linkSystemLibrary("dwrite");
        lib.linkSystemLibrary("ole32");
        lib.linkSystemLibrary("oleaut32");
        lib.linkSystemLibrary("oleacc");
        lib.linkSystemLibrary("uuid");
        lib.linkSystemLibrary("windowscodecs");
        lib.linkLibCpp();

        // Compile
        if (is_dynamic) {
            lib.addWin32ResourceFile(.{
                .file = .{ .path = "windows/resources.rc" },
                .flags = &.{},
            });
        }

        lib.addCSourceFiles(.{
            .files = &.{
                "windows/alloc.cpp",
                "windows/area.cpp",
                "windows/areadraw.cpp",
                "windows/areaevents.cpp",
                "windows/areascroll.cpp",
                "windows/areautil.cpp",
                "windows/attrstr.cpp",
                "windows/box.cpp",
                "windows/button.cpp",
                "windows/checkbox.cpp",
                "windows/colorbutton.cpp",
                "windows/colordialog.cpp",
                "windows/combobox.cpp",
                "windows/container.cpp",
                "windows/control.cpp",
                "windows/d2dscratch.cpp",
                "windows/datetimepicker.cpp",
                "windows/debug.cpp",
                "windows/draw.cpp",
                "windows/drawmatrix.cpp",
                "windows/drawpath.cpp",
                "windows/drawtext.cpp",
                "windows/dwrite.cpp",
                "windows/editablecombo.cpp",
                "windows/entry.cpp",
                "windows/events.cpp",
                "windows/fontbutton.cpp",
                "windows/fontdialog.cpp",
                "windows/fontmatch.cpp",
                "windows/form.cpp",
                "windows/graphemes.cpp",
                "windows/grid.cpp",
                "windows/group.cpp",
                "windows/image.cpp",
                "windows/init.cpp",
                "windows/label.cpp",
                "windows/main.cpp",
                "windows/menu.cpp",
                "windows/multilineentry.cpp",
                "windows/opentype.cpp",
                "windows/parent.cpp",
                "windows/progressbar.cpp",
                "windows/radiobuttons.cpp",
                "windows/separator.cpp",
                "windows/sizing.cpp",
                "windows/slider.cpp",
                "windows/spinbox.cpp",
                "windows/stddialogs.cpp",
                "windows/tab.cpp",
                "windows/table.cpp",
                "windows/tabledispinfo.cpp",
                "windows/tabledraw.cpp",
                "windows/tableediting.cpp",
                "windows/tablemetrics.cpp",
                "windows/tabpage.cpp",
                "windows/text.cpp",
                "windows/utf16.cpp",
                "windows/utilwin.cpp",
                "windows/window.cpp",
                "windows/winpublic.cpp",
                "windows/winutil.cpp",
            },
            .flags = if (is_dynamic) &.{} else &.{"-D_UI_STATIC"},
        });
    } else {
        // assume unix/*.c backend
        lib.installHeader("ui_unix.h", "ui_unix.h");
        lib.linkSystemLibrary("gtk+-3.0");
        lib.addIncludePath(.{ .path = "unix" });
        lib.addCSourceFiles(.{
            .files = &.{
                "unix/alloc.c",
                "unix/area.c",
                "unix/attrstr.c",
                "unix/box.c",
                "unix/button.c",
                "unix/cellrendererbutton.c",
                "unix/checkbox.c",
                "unix/child.c",
                "unix/colorbutton.c",
                "unix/combobox.c",
                "unix/control.c",
                "unix/datetimepicker.c",
                "unix/debug.c",
                "unix/draw.c",
                "unix/drawmatrix.c",
                "unix/drawpath.c",
                "unix/drawtext.c",
                "unix/editablecombo.c",
                "unix/entry.c",
                "unix/fontbutton.c",
                "unix/fontmatch.c",
                "unix/form.c",
                "unix/future.c",
                "unix/graphemes.c",
                "unix/grid.c",
                "unix/group.c",
                "unix/image.c",
                "unix/label.c",
                "unix/main.c",
                "unix/menu.c",
                "unix/multilineentry.c",
                "unix/opentype.c",
                "unix/progressbar.c",
                "unix/radiobuttons.c",
                "unix/separator.c",
                "unix/slider.c",
                "unix/spinbox.c",
                "unix/stddialogs.c",
                "unix/tab.c",
                "unix/table.c",
                "unix/tablemodel.c",
                "unix/text.c",
                "unix/util.c",
                "unix/window.c",
            },
            .flags = &.{},
        });
    }

    b.installArtifact(lib);

    // build examples
    const example_names = [_][]const u8{
        "controlgallery",
        "datetime",
        "drawtext",
        "hello-world",
        "histogram",
        "timer",
        "window",
    };
    const examples = [_][]const u8{
        "examples/controlgallery/main.c",
        "examples/datetime/main.c",
        "examples/drawtext/main.c",
        "examples/hello-world/main.c",
        "examples/histogram/main.c",
        "examples/timer/main.c",
        "examples/window/main.c",
    };
    for (examples, example_names) |example, name| {
        const exe = b.addExecutable(.{
            .name = name,
            .target = target,
            .optimize = optimize,
            .root_source_file = .{ .path = example },
        });
        exe.linkLibrary(lib);
        if (target.isWindows()) {
            exe.addWin32ResourceFile(.{
                .file = .{ .path = "examples/resources.rc" },
                .flags = if (is_dynamic) &.{} else &.{ "/d", "_UI_STATIC" },
            });
        }
        b.installArtifact(exe);
    }

    // add cpp-multithread example
    // Needs own build logic due to cpp
    {
        const exe = b.addExecutable(.{
            .name = "cpp-multithread",
            .target = target,
            .optimize = optimize,
            .root_source_file = .{ .path = "examples/cpp-multithread/main.cpp" },
        });
        exe.linkLibrary(lib);
        exe.linkLibCpp();

        if (target.isWindows()) {
            exe.addWin32ResourceFile(.{
                .file = .{ .path = "examples/resources.rc" },
                .flags = if (is_dynamic) &.{} else &.{ "/d", "_UI_STATIC" },
            });
        }

        b.installArtifact(exe);
    }
}
