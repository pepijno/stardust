const std = @import("std");
const constants = @import("constants.zig");
const colors = @import("colors.zig");

const hide_cursor = "?25l";
const show_cursor = "?25h";
const save_cursor_position = "s";
const restore_cursor_position = "u";
const cursor_up_one_line = "1A";
const cursor_up = "{d}A";
const cursor_down = "{d}B";
const cursor_forward = "{d}C";
const cursor_back = "{d}D";
const cursor_next_line = "{d}E";
const cursor_previous_line = "{d}F";
const cursor_position = "{d};{d}H";
const erase_display = "{d}J";
const erase_line_right = "0K";
const erase_line_left = "1K";
const erase_entire_line = "2K";
const change_scrolling_region = "{d};{d}r";
const insert_line = "{d}L";
const delete_line = "{d}M";
const set_foreground_color = "10;{s}";
const set_background_color = "11;{s}";
const set_cursor_color = "12;{s}";
const restore_screen = "?47l";
const save_screen = "?47h";

pub fn screen(stream: anytype) Screen(@TypeOf(stream)) {
    return .{ .stream = stream };
}

pub fn Screen(comptime Writer: type) type {
    const Error = Writer.Error;
    return struct {
        const Self = @This();

        stream: Writer,

        pub fn writer(self: *Self) Writer {
            return self.stream;
        }

        pub fn reset(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ "0m");
        }

        pub fn setForegroundColor(self: *Self, color: colors.Color) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.OSC ++ set_foreground_color ++ constants.BEL, .{color.asString()});
            try self.writer().writeAll(sequence);
        }

        pub fn setBackgroundColor(self: *Self, color: colors.Color) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.OSC ++ set_background_color ++ constants.BEL, .{color.asString()});
            try self.writer().writeAll(sequence);
        }

        pub fn setCursorColor(self: *Self, color: colors.Color) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.OSC ++ set_cursor_color ++ constants.BEL, .{color.asString()});
            try self.writer().writeAll(sequence);
        }

        pub fn restoreScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ restore_screen);
        }

        pub fn saveScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ save_screen);
        }

        pub fn clearScreen(self: *Self) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ erase_display, .{2});
            try self.writer().writeAll(sequence);
            try self.moveCursor(1, 1);
        }

        pub fn moveCursor(self: *Self, x: u16, y: u16) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_position, .{ y, x });
            try self.writer().writeAll(sequence);
        }

        pub fn hideCursor(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ hide_cursor);
        }

        pub fn showCursor(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ show_cursor);
        }

        pub fn saveCursorPosition(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ save_cursor_position);
        }

        pub fn restoreCursorPosition(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ restore_cursor_position);
        }

        pub fn cursorUp(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_up, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn cursorDown(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_down, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn cursorForward(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_forward, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn cursorBack(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_back, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn cursorNextLine(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_next_line, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn cursorPrevLine(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ cursor_previous_line, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn clearLine(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ erase_entire_line);
        }

        pub fn clearLineLeft(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ erase_line_left);
        }

        pub fn clearLineRight(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ erase_line_right);
        }

        pub fn clearLines(self: *Self, n: u32) Error!void {
            const clear_line_str = constants.CSI ++ erase_entire_line;
            const cursor_up_str = constants.CSI ++ cursor_up_one_line;
            try self.writer().writeAll(clear_line_str);
            for (0..n) |_| {
                try self.writer().writeAll(cursor_up_str ++ clear_line_str);
            }
        }

        pub fn changeScrollingRegion(self: *Self, top: u32, bottom: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ change_scrolling_region, .{ top, bottom });
            try self.writer().writeAll(sequence);
        }

        pub fn insertLines(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ insert_line, .{n});
            try self.writer().writeAll(sequence);
        }

        pub fn deleteLines(self: *Self, n: u32) Error!void {
            var buffer = [_]u8{0} ** 100;
            const sequence = try std.fmt.bufPrint(&buffer, constants.CSI ++ delete_line, .{n});
            try self.writer().writeAll(sequence);
        }
    };
}

test "reset" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.reset();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[0m");
}

test "setForegroundColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.setForegroundColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]10;#0000d7\x07");
}

test "setBackgroundColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.setBackgroundColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]11;#0000d7\x07");
}

test "setCursorColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.setCursorColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]12;#0000d7\x07");
}

test "restoreScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.restoreScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?47l");
}

test "saveScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.saveScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?47h");
}

test "clearScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.clearScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2J\x1b[1;1H");
}

test "moveCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.moveCursor(4, 5);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[5;4H");
}

test "hideCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.hideCursor();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?25l");
}

test "showCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.showCursor();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?25h");
}

test "saveCursorPosition" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.saveCursorPosition();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[s");
}

test "restoreCursorPosition" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.restoreCursorPosition();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[u");
}

test "cursorUp" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorUp(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11A");
}

test "cursorDown" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorDown(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11B");
}

test "cursorForward" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorForward(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11C");
}

test "cursorBack" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorBack(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11D");
}

test "cursorNextLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorNextLine(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11E");
}

test "cursorPrevLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.cursorPrevLine(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11F");
}

test "clearLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.clearLine();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2K");
}

test "clearLineLeft" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.clearLineLeft();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[1K");
}

test "clearLineRight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.clearLineRight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[0K");
}

test "clearLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.clearLines(5);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K");
}

test "changeScrollingRegion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.changeScrollingRegion(5, 7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[5;7r");
}

test "insertLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.insertLines(7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[7L");
}

test "deleteLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var s = screen(fbs.writer());
    try s.deleteLines(7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[7M");
}
