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
    no_color: NoColor,

    pub fn sequence(self: Self, buffer: []u8, background: bool) ColorError!usize {
        switch (self) {
            .no_color => return 0,
            inline else => |color| return try color.sequence(buffer, background),
        }
    }

    pub fn asString(self: Self) []const u8 {
        switch (self) {
            .no_color => return "",
            inline else => |color| return color.asString(),
        }
    }

    pub fn convertToRGB(self: Self) Color {
        return switch (self) {
            .no_color => .{ .rgb_color = .{ .hex = "#000000" } },
            .ansi_color => |ansi| .{ .rgb_color = .{ .hex = constants.ansi_hex[ansi.color] } },
            .ansi256_color => |ansi256| .{ .rgb_color = .{ .hex = constants.ansi_hex[ansi256.color] } },
            .rgb_color => |_| self,
        };
    }
};

pub const NoColor = struct {};

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

    pub fn toANSI(self: @This()) ANSIColor {
        const c = hexToHSL(constants.ansi_hex(self.color));
        var max = std.math.floatMax(f64);
        var r: u8 = 0;
        for (0..16) |i| {
            const cb = hexToHSL(constants.ansi_hex(i));
            const distance_sq = ((c[0] - cb[0]) / 100.0) * ((c[0] - cb[0]) / 100.0) + (c[1] - cb[1]) * (c[1] - cb[1]) + (c[2] - cb[2]) * (c[2] - cb[2]);

            if (distance_sq < max) {
                r = i;
                max = distance_sq;
            }
        }

        return .{ .color = r };
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

    pub fn toANSI256(self: @This()) ANSI256Color {
        const start_index: usize = if (self.hex.len == 7) 1 else 0;
        const red = std.fmt.parseInt(u8, self.hex[start_index .. start_index + 2], 16) catch return ColorError.InvalidHexString;
        const green = std.fmt.parseInt(u8, self.hex[start_index + 2 .. start_index + 4], 16) catch return ColorError.InvalidHexString;
        const blue = std.fmt.parseInt(u8, self.hex[start_index + 4 .. start_index + 6], 16) catch return ColorError.InvalidHexString;
        const r = v2ci(red);
        const g = v2ci(green);
        const b = v2ci(blue);
        const ci = 36 * r + 6 * g + b;
        const i2cv = [_]u8{ 0, 0x5f, 0x87, 0xaf, 0xd7, 0xff };
        const cr = i2cv[r];
        const cb = i2cv[b];
        const cg = i2cv[g];

        const average = (r + g + b) / 3;
        const grey_index = if (average > 238) 23 else (average - 3) / 10;
        const gv = 8 + 10 * grey_index;

        const c2_hex: [7]u8 = undefined;
        const g2_hex: [7]u8 = undefined;
        _ = std.fmt.bufPrint(&c2_hex, "#{x:0>2}{x:0>2}{x:0>2}", .{ cr, cb, cg }) catch unreachable;
        _ = std.fmt.bufPrint(&g2_hex, "#{x:0>2}{x:0>2}{x:0>2}", .{ gv, gv, gv }) catch unreachable;

        const hex_hsl = hexToHSL(self.hex);
        const c2_hsl = hexToHSL(c2_hex);
        const g2_hsl = hexToHSL(g2_hex);

        const distance_c2_sq = ((hex_hsl[0] - c2_hsl[0]) / 100.0) * ((hex_hsl[0] - c2_hsl[0]) / 100.0) + (hex_hsl[1] - c2_hsl[1]) * (hex_hsl[1] - c2_hsl[1]) + (hex_hsl[2] - c2_hsl[2]) * (hex_hsl[2] - c2_hsl[2]);
        const distance_g2_sq = ((hex_hsl[0] - g2_hsl[0]) / 100.0) * ((hex_hsl[0] - g2_hsl[0]) / 100.0) + (hex_hsl[1] - g2_hsl[1]) * (hex_hsl[1] - g2_hsl[1]) + (hex_hsl[2] - g2_hsl[2]) * (hex_hsl[2] - g2_hsl[2]);

        if (distance_c2_sq < distance_g2_sq) {
            return .{ .color = 16 + ci };
        } else {
            return .{ .color = 232 + grey_index };
        }
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

fn hexToHSL(hex: []const u8) struct { f64, f64, f64 } {
    const start_index: usize = if (hex.len == 7) 1 else 0;
    const red: f64 = @floatFromInt(std.fmt.parseInt(u8, hex[start_index .. start_index + 2], 16) catch return ColorError.InvalidHexString);
    const green: f64 = @floatFromInt(std.fmt.parseInt(u8, hex[start_index + 2 .. start_index + 4], 16) catch return ColorError.InvalidHexString);
    const blue: f64 = @floatFromInt(std.fmt.parseInt(u8, hex[start_index + 4 .. start_index + 6], 16) catch return ColorError.InvalidHexString);

    const max: f64 = @max(@max(red, green), blue);
    const min: f64 = @min(@min(red, green), blue);

    const l = (max - min) / 2.0;

    if (min == max) {
        return .{
            0,
            0,
            l,
        };
    } else {
        const s = if (l < 0.5) (max - min) / (max + min) else (max - min) / (2.0 - max - min);
        var h = if (max == red) (green - blue) / (max - min) else if (max == green) 2.0 + (blue - red) / (max - min) else 4.0 + (red - green) / (max - min);
        h *= 60.0;
        if (h < 0) {
            h += 360.0;
        }
        return .{
            h,
            s,
            l,
        };
    }
}

fn v2ci(v: u8) u8 {
    if (v < 48) {
        return 0;
    } else if (v < 115) {
        return 1;
    } else {
        return (v - 35) / 40;
    }
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
