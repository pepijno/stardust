const std = @import("std");
const constants = @import("constants.zig");

const enable_mouse_press = "?9h";
const disable_mouse_press = "?9l";
const enable_mouse = "?1000h";
const disable_mouse = "?1000l";
const enable_mouse_highlight = "?1001h";
const disable_mouse_highlight = "?1001l";
const enable_mouse_cell_motion = "?1002h";
const disable_mouse_cell_motion = "?1002l";
const enable_mouse_all_motion = "?1003h";
const disable_mouse_all_motion = "?1003l";
const enable_mouse_extended_mode = "?1006h";
const disable_mouse_extended_mode = "?1006l";
const enable_mouse_pixels_mode = "?1016h";
const disable_mouse_pixels_mode = "?1016l";

pub fn mouse(stream: anytype) Mouse(@TypeOf(stream)) {
    return .{ .tty = stream };
}

pub fn Mouse(comptime Writer: type) type {
    const Error = Writer.Error;
    return struct {
        const Self = @This();

        tty: Writer,

        pub fn writer(self: *Self) Writer {
            return self.tty;
        }

        pub fn enableMousePress(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_press);
        }

        pub fn disableMousePress(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_press);
        }

        pub fn enableMouse(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse);
        }

        pub fn disableMouse(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse);
        }

        pub fn enableMouseHighlight(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_highlight);
        }

        pub fn disableMouseHighlight(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_highlight);
        }

        pub fn enableMouseCellMotion(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_cell_motion);
        }

        pub fn disableMouseCellMotion(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_cell_motion);
        }

        pub fn enableMouseAllMotion(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_all_motion);
        }

        pub fn disableMouseAllMotion(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_all_motion);
        }

        pub fn enableMouseExtendedMode(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_extended_mode);
        }

        pub fn disableMouseExtendedMode(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_extended_mode);
        }

        pub fn enableMousePixelsMode(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_mouse_pixels_mode);
        }

        pub fn disableMousePixelsMode(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_mouse_pixels_mode);
        }
    };
}

test "enableMousePress" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMousePress();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?9h");
}

test "disableMousePress" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMousePress();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?9l");
}

test "enableMouse" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMouse();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1000h");
}

test "disableMouse" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMouse();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1000l");
}

test "enableMouseHighlight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMouseHighlight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1001h");
}

test "disableMouseHighlight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMouseHighlight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1001l");
}

test "enableMouseCellMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMouseCellMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1002h");
}

test "disableMouseCellMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMouseCellMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1002l");
}

test "enableMouseAllMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMouseAllMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1003h");
}

test "disableMouseAllMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMouseAllMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1003l");
}

test "enableMouseExtendedMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMouseExtendedMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1006h");
}

test "disableMouseExtendedMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMouseExtendedMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1006l");
}

test "enableMousePixelsMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.enableMousePixelsMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1016h");
}

test "disableMousePixelsMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var m = mouse(fbs.writer());
    try m.disableMousePixelsMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1016l");
}
