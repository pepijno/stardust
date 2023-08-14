const std = @import("std");
const Style = @import("Style.zig");
const colors = @import("colors.zig");
const screen = @import("screen.zig");
const Color = colors.Color;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const basic_ansi = try Style.init(.{.Bold}).print(allocator, "Basic ANSI Colors\n");
    try stdout.writeAll(basic_ansi);

    var i: u16 = 0;
    while (i < 16) : (i += 1) {
        if (i % 8 == 0) {
            try stdout.writeAll("\n");
        }

        const background = Color{ .ansi_color = .{ .color = @intCast(u8, i) } };

        var style = Style.init(.{}).addBackground(background);
        if (i < 5) {
            style = style.addForeground(.{ .ansi_color = .{ .color = 7 } });
        } else {
            style = style.addForeground(.{ .ansi_color = .{ .color = 0 } });
        }

        const rgb_color = background.convertToRGB();
        const output_str = try std.fmt.allocPrint(allocator, " {d:>2} {s} ", .{ i, rgb_color.rgb_color.hex });

        const color = try style.print(allocator, output_str);
        try stdout.writeAll(color);
    }
    try stdout.writeAll("\n\n");

    const ansi_256 = try Style.init(.{.Bold}).print(allocator, "Extended ANSI Colors\n");
    try stdout.writeAll(ansi_256);

    i = 16;
    while (i < 232) : (i += 1) {
        if ((i - 16) % 6 == 0) {
            try stdout.writeAll("\n");
        }

        const background = Color{ .ansi256_color = .{ .color = @intCast(u8, i) } };

        var style = Style.init(.{}).addBackground(background);
        if (i < 28) {
            style = style.addForeground(.{ .ansi_color = .{ .color = 7 } });
        } else {
            style = style.addForeground(.{ .ansi_color = .{ .color = 0 } });
        }

        const rgb_color = background.convertToRGB();
        const output_str = try std.fmt.allocPrint(allocator, " {d:>3} {s} ", .{ i, rgb_color.rgb_color.hex });

        const color = try style.print(allocator, output_str);
        try stdout.writeAll(color);
    }
    try stdout.writeAll("\n\n");

    const ansi_grayscale = try Style.init(.{.Bold}).print(allocator, "Extended ANSI Grayscale\n");
    try stdout.writeAll(ansi_grayscale);

    i = 232;
    while (i < 256) : (i += 1) {
        if ((i - 16) % 6 == 0) {
            try stdout.writeAll("\n");
        }

        const background = Color{ .ansi256_color = .{ .color = @intCast(u8, i) } };

        var style = Style.init(.{}).addBackground(background);
        if (i < 244) {
            style = style.addForeground(.{ .ansi_color = .{ .color = 7 } });
        } else {
            style = style.addForeground(.{ .ansi_color = .{ .color = 0 } });
        }

        const rgb_color = background.convertToRGB();
        const output_str = try std.fmt.allocPrint(allocator, " {d:>3} {s} ", .{ i, rgb_color.rgb_color.hex });

        const color = try style.print(allocator, output_str);
        try stdout.writeAll(color);
    }
    try stdout.writeAll("\n\n");
    try bw.flush();
}
