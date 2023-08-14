const std = @import("std");
const constants = @import("constants.zig");

const ColorError = error{
    FormatError,
    InvalidXTermColor,
    InvalidHexString,
};

const foreground_sequence = "38";
const background_sequence = "48";

pub const Color = union(enum) {
    const Self = @This();

    ansi_color: ANSIColor,
    ansi256_color: ANSI256Color,
    rgb_color: RGBColor,

    pub fn sequence(self: Self, buffer: []u8, background: bool) ColorError!usize {
        switch (self) {
            inline else => |color| return try color.sequence(buffer, background),
        }
    }

    pub fn asString(self: Self) []const u8 {
        switch (self) {
            inline else => |color| return color.asString(),
        }
    }

    pub fn convertToRGB(self: Self) Color {
        return switch (self) {
            .ansi_color => |ansi| .{ .rgb_color = .{ .hex = constants.ansi_hex[ansi.color] } },
            .ansi256_color => |ansi256| .{ .rgb_color = .{ .hex = constants.ansi_hex[ansi256.color] } },
            .rgb_color => |_| self,
        };
    }
};

pub const ANSIColor = struct {
    color: u8,

    pub fn sequence(self: @This(), buffer: []u8, background: bool) ColorError!usize {
        const background_mod = if (background) self.color + 10 else self.color;
        const value = if (self.color < 8) background_mod + 30 else background_mod - 8 + 90;
        const result = std.fmt.bufPrint(buffer, "{d}", .{value}) catch return ColorError.FormatError;
        return result.len;
    }

    pub fn asString(self: @This()) []const u8 {
        return constants.ansi_hex[self.color];
    }
};

pub const ANSI256Color = struct {
    color: u8,

    pub fn sequence(self: @This(), buffer: []u8, background: bool) ColorError!usize {
        const prefix = if (background) background_sequence else foreground_sequence;
        const result = std.fmt.bufPrint(buffer, "{s};5;{d}", .{ prefix, self.color }) catch return ColorError.FormatError;
        return result.len;
    }

    pub fn asString(self: @This()) []const u8 {
        return constants.ansi_hex[self.color];
    }
};

pub const RGBColor = struct {
    hex: []const u8,

    pub fn sequence(self: @This(), buffer: []u8, background: bool) ColorError!usize {
        if (self.hex.len < 6 or self.hex.len > 7) {
            return ColorError.InvalidHexString;
        }
        if (self.hex.len == 7 and self.hex[0] != '#') {
            return ColorError.InvalidHexString;
        }

        const prefix = if (background) background_sequence else foreground_sequence;

        const start_index: usize = if (self.hex.len == 7) 1 else 0;
        const red = std.fmt.parseInt(u8, self.hex[start_index .. start_index + 2], 16) catch return ColorError.InvalidHexString;
        const green = std.fmt.parseInt(u8, self.hex[start_index + 2 .. start_index + 4], 16) catch return ColorError.InvalidHexString;
        const blue = std.fmt.parseInt(u8, self.hex[start_index + 4 .. start_index + 6], 16) catch return ColorError.InvalidHexString;

        const result = std.fmt.bufPrint(buffer, "{s};2;{d};{d};{d}", .{ prefix, red, green, blue }) catch return ColorError.FormatError;
        return result.len;
    }

    pub fn asString(self: @This()) []const u8 {
        return self.hex;
    }
};

pub fn xTermColor(s: []const u8) ColorError!RGBColor {
    if (s.len < 24 or s.len > 25) {
        return ColorError.InvalidXTermColor;
    }

    var str = s;
    if (std.mem.endsWith(u8, s, constants.ESC)) {
        str = std.mem.trimRight(u8, s, constants.ESC);
    } else if (std.mem.endsWith(u8, s, constants.BEL)) {
        str = std.mem.trimRight(u8, s, constants.BEL);
    } else if (std.mem.endsWith(u8, s, constants.ST)) {
        str = std.mem.trimRight(u8, s, constants.ST);
    } else {
        return ColorError.InvalidXTermColor;
    }

    str = str[4..];
    const prefix = ";rgb:";

    if (!std.mem.startsWith(u8, str, prefix)) {
        return ColorError.InvalidXTermColor;
    }
    str = std.mem.trimLeft(u8, str, prefix);
    return .{
        .hex = str[0..2] ++ str[5..7] ++ str[10..12],
    };
}

test "ANSIColor less than eight without background" {
    const color = ANSIColor{ .color = 5 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, false);
    try std.testing.expectEqualStrings(buffer[0..result], "35");
}

test "ANSIColor less than eight with background" {
    const color = ANSIColor{ .color = 5 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, true);
    try std.testing.expectEqualStrings(buffer[0..result], "45");
}

test "ANSIColor greater than eight without background" {
    const color = ANSIColor{ .color = 9 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, false);
    try std.testing.expectEqualStrings(buffer[0..result], "91");
}

test "ANSIColor greater than eight with background" {
    const color = ANSIColor{ .color = 9 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, true);
    try std.testing.expectEqualStrings(buffer[0..result], "101");
}

test "ANSI256Color without background" {
    const color = ANSI256Color{ .color = 174 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, false);
    try std.testing.expectEqualStrings(buffer[0..result], "38;5;174");
}

test "ANSI256Color with background" {
    const color = ANSI256Color{ .color = 174 };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, true);
    try std.testing.expectEqualStrings(buffer[0..result], "48;5;174");
}

test "RGBColor without background" {
    const color = RGBColor{ .hex = "8899AA" };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, false);
    try std.testing.expectEqualStrings(buffer[0..result], "38;2;136;153;170");
}

test "RGBColor with background" {
    const color = RGBColor{ .hex = "8899AA" };
    var buffer: [100]u8 = undefined;
    const result = try color.sequence(&buffer, true);
    try std.testing.expectEqualStrings(buffer[0..result], "48;2;136;153;170");
}

test "xTermColor with valid xTerm string ending with ESC" {
    const color_str = "\x1b]11;rgb:fafa/fafa/fafa\x1b";
    const color = try xTermColor(color_str);
    try std.testing.expectEqualStrings(color.hex, "fafafa");
}

test "xTermColor with valid xTerm string ending with BEL" {
    const color_str = "\x1b]11;rgb:1212/3434/5656\x07";
    const color = try xTermColor(color_str);
    try std.testing.expectEqualStrings(color.hex, "123456");
}

test "xTermColor with valid xTerm string ending with ST" {
    const color_str = "\x1b]11;rgb:1212/3434/5656\x1b\\";
    const color = try xTermColor(color_str);
    try std.testing.expectEqualStrings(color.hex, "123456");
}

test "xTermColor with invalid xTerm string with incorrect suffix" {
    const color_str = "\x1b]11;rgb:fafa/fafa/fafaZZ";
    const color = xTermColor(color_str);
    try std.testing.expectEqual(color, ColorError.InvalidXTermColor);
}

test "xTermColor with invalid xTerm string with incorrect length" {
    const color_str = "\x1b]11;rgb:fafa/fafa";
    const color = xTermColor(color_str);
    try std.testing.expectEqual(color, ColorError.InvalidXTermColor);
}

test "xTermColor with invalid xTerm string without ;rgb: prefix" {
    const color_str = "\x1b]11;foo:fafa/fafa/fafa\x1b";
    const color = xTermColor(color_str);
    try std.testing.expectEqual(color, ColorError.InvalidXTermColor);
}
