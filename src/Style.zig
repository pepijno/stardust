const Self = @This();

const std = @import("std");
const constants = @import("constants.zig");
const colors = @import("colors.zig");

pub const Styles = enum {
    Bold,
    Faint,
    Italic,
    Underline,
    Blink,
    Reverse,
    CrossOut,
    Overline,
};

styles: std.EnumSet(Styles),
foreground: ?colors.Color = null,
background: ?colors.Color = null,

pub fn init(comptime styles: anytype) Self {
    var self = Self{
        .styles = std.EnumSet(Styles){},
    };

    inline for (styles) |style| {
        self.styles.insert(style);
    }

    return self;
}

pub fn addStyle(self: Self, style: Styles) Self {
    var styles_set = self.styles;
    styles_set.insert(style);
    return .{
        .styles = styles_set,
        .foreground = self.foreground,
        .background = self.background,
    };
}

pub fn addForeground(self: Self, color: colors.Color) Self {
    return .{
        .styles = self.styles,
        .foreground = color,
        .background = self.background,
    };
}

pub fn addBackground(self: Self, color: colors.Color) Self {
    return .{
        .styles = self.styles,
        .foreground = self.foreground,
        .background = color,
    };
}

pub fn print(self: Self, allocator: std.mem.Allocator, str: []const u8) ![]const u8 {
    if (self.styles.count() == 0 and self.background == null and self.foreground == null) {
        return std.fmt.allocPrint(allocator, "{s}", .{str});
    }

    const styles_size = @typeInfo(Styles).Enum.fields.len * 3 + 2 * 16;
    var styles: [styles_size]u8 = undefined;
    var styles_set = self.styles;
    var iterator = styles_set.iterator();
    var index: usize = 0;
    while (iterator.next()) |style| {
        if (index > 0) {
            styles[index] = ';';
            index += 1;
        }
        const sequence = switch (style) {
            .Bold => constants.bold,
            .Faint => constants.faint,
            .Italic => constants.italic,
            .Underline => constants.underline,
            .Blink => constants.blink,
            .Reverse => constants.reverse,
            .CrossOut => constants.cross_out,
            .Overline => constants.overline,
        };
        std.mem.copy(u8, styles[index..], sequence);
        index += sequence.len;
    }

    if (self.background) |b_color| {
        if (index > 0) {
            styles[index] = ';';
            index += 1;
        }
        const sequence_len = try b_color.sequence(styles[index..], true);
        index += sequence_len;
    }

    if (self.foreground) |f_color| {
        if (index > 0) {
            styles[index] = ';';
            index += 1;
        }
        const sequence_len = try f_color.sequence(styles[index..], false);
        index += sequence_len;
    }

    if (std.mem.eql(u8, &styles, "")) {
        return std.fmt.allocPrint(allocator, "{s}", .{str});
    }

    return try std.fmt.allocPrint(allocator, "{s}{s}m{s}{s}m", .{ constants.CSI, styles[0..index], str, constants.CSI ++ constants.reset });
}

test "print without styles and colors" {
    const style = Self.init(.{});
    const printed = try style.print(std.testing.allocator, "Test");
    defer std.testing.allocator.free(printed);
    try std.testing.expectEqualStrings(printed, "Test");
}

test "print all styles" {
    const style = Self.init(.{
        .Bold,
        .Faint,
        .Italic,
        .Underline,
        .Blink,
        .Reverse,
        .CrossOut,
        .Overline,
    })
        .addForeground(.{ .ansi_color = .{ .color = 10 } })
        .addBackground(.{ .ansi_color = .{ .color = 30 } });
    const printed = try style.print(std.testing.allocator, "Test");
    defer std.testing.allocator.free(printed);
    try std.testing.expectEqualSlices(u8, printed, "\x1b[1;2;3;4;5;7;9;53;122;92mTest\x1b[0m");
}
