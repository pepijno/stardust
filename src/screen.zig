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

/// Mouse
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

const enable_bracketed_paste = "?2004h";
const disable_bracketed_paste = "?2004l";
const start_bracketed_paste = "200~";
const end_bracketed_paste = "201~";

const set_window_title = "2;{s}";
const set_foreground_color = "10;{s}";
const set_background_color = "11;{s}";
const set_cursor_color = "12;{s}";

// Screen.
const restore_screen = "?47l";
const save_screen = "?47h";
const alt_screen = "?1049h";
const exit_alt_screen = "?1049l";

pub fn output(stream: anytype) Output(@TypeOf(stream)) {
    return .{ .tty = stream };
}

pub fn Output(comptime Writer: type) type {
    const Error = Writer.Error;
    return struct {
        const Self = @This();

        tty: Writer,

        pub fn writer(self: *Self) Writer {
            return self.tty;
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

        pub fn altScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ alt_screen);
        }

        pub fn exitAltScreen(self: *Self) Error!void {
            try self.writer().writeAll(constants.CSI ++ exit_alt_screen);
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

        pub fn setWindowTitle(self: *Self, title: []const u8) Error!void {
            var buffer = [_]u8{0} ** 1000;
            const sequence = try std.fmt.bufPrint(&buffer, constants.OSC ++ set_window_title ++ constants.BEL, .{title});
            try self.writer().writeAll(sequence);
        }
    };
}

test "reset" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.reset();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[0m");
}

test "setForegroundColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.setForegroundColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]10;#0000d7\x07");
}

test "setBackgroundColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.setBackgroundColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]11;#0000d7\x07");
}

test "setCursorColor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.setCursorColor(.{ .ansi_color = .{ .color = 20 } });
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]12;#0000d7\x07");
}

test "restoreScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.restoreScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?47l");
}

test "saveScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.saveScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?47h");
}

test "altScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.altScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1049h");
}

test "exitAltScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.exitAltScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1049l");
}

test "clearScreen" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.clearScreen();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2J\x1b[1;1H");
}

test "moveCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.moveCursor(4, 5);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[5;4H");
}

test "hideCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.hideCursor();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?25l");
}

test "showCursor" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.showCursor();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?25h");
}

test "saveCursorPosition" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.saveCursorPosition();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[s");
}

test "restoreCursorPosition" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.restoreCursorPosition();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[u");
}

test "cursorUp" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorUp(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11A");
}

test "cursorDown" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorDown(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11B");
}

test "cursorForward" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorForward(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11C");
}

test "cursorBack" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorBack(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11D");
}

test "cursorNextLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorNextLine(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11E");
}

test "cursorPrevLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.cursorPrevLine(11);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[11F");
}

test "clearLine" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.clearLine();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2K");
}

test "clearLineLeft" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.clearLineLeft();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[1K");
}

test "clearLineRight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.clearLineRight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[0K");
}

test "clearLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.clearLines(5);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K\x1b[1A\x1b[2K");
}

test "changeScrollingRegion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.changeScrollingRegion(5, 7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[5;7r");
}

test "insertLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.insertLines(7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[7L");
}

test "deleteLines" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.deleteLines(7);
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[7M");
}

test "enableMousePress" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMousePress();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?9h");
}

test "disableMousePress" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMousePress();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?9l");
}

test "enableMouse" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMouse();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1000h");
}

test "disableMouse" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMouse();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1000l");
}

test "enableMouseHighlight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMouseHighlight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1001h");
}

test "disableMouseHighlight" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMouseHighlight();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1001l");
}

test "enableMouseCellMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMouseCellMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1002h");
}

test "disableMouseCellMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMouseCellMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1002l");
}

test "enableMouseAllMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMouseAllMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1003h");
}

test "disableMouseAllMotion" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMouseAllMotion();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1003l");
}

test "enableMouseExtendedMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMouseExtendedMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1006h");
}

test "disableMouseExtendedMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMouseExtendedMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1006l");
}

test "enableMousePixelsMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.enableMousePixelsMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1016h");
}

test "disableMousePixelsMode" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.disableMousePixelsMode();
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b[?1016l");
}

test "setWindowTitle" {
    var buffer: [100]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    var o = output(fbs.writer());
    try o.setWindowTitle("TestTitle");
    try std.testing.expectEqualSlices(u8, fbs.getWritten(), "\x1b]2;TestTitle\x07");
}
