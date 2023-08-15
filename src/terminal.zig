const std = @import("std");
const constants = @import("constants.zig");

const enable_line_wrap = "?7h";
const disable_line_wrap = "?7l";
const alt_screen = "?1049h";
const exit_alt_screen = "?1049l";
const set_size = "8;{d};{d}t";
const set_window_title = "0;{s}";
const begin_sychronized_update = "?2026h";
const end_sychronized_update = "?2026l";

pub fn terminal(stream: anytype) Terminal(@TypeOf(stream)) {
    return .{ .tty = stream };
}

pub fn Terminal(comptime Writer: type) type {
    const Error = Writer.Error;
    return struct {
        const Self = @This();

        tty: Writer,

        pub fn writer(self: *Self) Writer {
            return self.tty;
        }

        pub fn enableLineWrap(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ enable_line_wrap);
        }

        pub fn disableLineWrap(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ disable_line_wrap);
        }

        pub fn altScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ alt_screen);
        }

        pub fn exitAltScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ exit_alt_screen);
        }

        pub fn setSize(self: *Self, height: u16, width: u16) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ set_size, .{ height, width });
            try self.writer().writeAll(sequence);
        }

        pub fn setWindowTitle(self: *Self, title: []const u8) Error!void {
            var buffer = [_]u8{0} ** 1000;
            const sequence = try std.fmt.bufPrint(&buffer, constants.OSC ++ set_window_title ++ constants.BEL, .{title});
            try self.writer().writeAll(sequence);
        }

        pub fn beginSychronizedUpdate(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ begin_sychronized_update);
        }

        pub fn endSychronizedUpdate(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ end_sychronized_update);
        }
    };
}

test "enableLineWrap" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.enableLineWrap();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?7h");
}

test "disableLineWrap" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.disableLineWrap();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?7l");
}

test "altScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.altScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1049h");
}

test "exitAltScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.exitAltScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1049l");
}

test "setSize" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.setSize(50, 100);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[8;50;100t");
}

test "setWindowTitle" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.setWindowTitle("TestTitle");
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]0;TestTitle\x07");
}

test "beginSychronizedUpdate" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.beginSychronizedUpdate();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?2026h");
}

test "endSychronizedUpdate" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var t = terminal(fbs.writer());
    try t.endSychronizedUpdate();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?2026l");
}
