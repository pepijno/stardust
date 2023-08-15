const std = @import("std");
const Color = @import("colors.zig").Color;

const Profile = enum {
    TrueColor,
    ANSI256,
    ANSI,
    ASCII,

    const Self = @This();

    fn convert(self: Self, color: Color) Color {
        if (self == .ASCII) {
            return .{ .no_color = {} };
        }

        switch (color) {
            .ansi_color => |c| return c,
            .ansi256_color => |c| {
                if (self == .ANSI) {
                    return .{ .ansi_color = c.toANSI() };
                } else {
                    return color;
                }
            },
            .rgb_color => |c| {
                if (self != .TrueColor) {
                    const ansi256 = c.toANSI256();
                    if (self == .ANSI) {
                        return .{ .ansi_color = ansi256.toANSI() };
                    } else {
                        return .{ .ansi256_color = ansi256 };
                    }
                } else {
                    return color;
                }
            },
            else => return .{ .ansi_color = {} },
        }
    }
};
