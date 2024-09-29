const std = @import("std");

const B_MIN_VALUE = 1;
const I_MIN_VALUE = 16;
const N_MIN_VALUE = 31;
const G_MIN_VALUE = 46;
const O_MIN_VALUE = 61;

const BINGO_COLUMN_HEADER_CHARS: [5]u8 = .{ 'B', 'I', 'N', 'G', 'O' };
const BINGO_CARD_HEADER = "| B | I | N | G | O |\n";
var b_values = generate_bingo_col_values(B_MIN_VALUE);
var i_values = generate_bingo_col_values(I_MIN_VALUE);
var n_values = generate_bingo_col_values(N_MIN_VALUE);
var g_values = generate_bingo_col_values(G_MIN_VALUE);
var o_values = generate_bingo_col_values(O_MIN_VALUE);

pub const BingoCardV1 = struct {
    b_columns: [5]u8,
    i_columns: [5]u8,
    n_columns: [5]u8,
    g_columns: [5]u8,
    o_columns: [5]u8,

    pub fn initRandom() !BingoCardV1 {
        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.posix.getrandom(std.mem.asBytes(&seed));
            std.debug.print("{d}\n", .{seed});
            break :blk seed;
        });

        return .{
            .b_columns = get_random_5(b_values[0..], &prng),
            .i_columns = get_random_5(i_values[0..], &prng),
            .n_columns = get_random_5(n_values[0..], &prng),
            .g_columns = get_random_5(g_values[0..], &prng),
            .o_columns = get_random_5(o_values[0..], &prng),
        };
    }

    pub fn printCard(self: *const BingoCardV1) !void {
        const stdout = std.io.getStdOut().writer();
        const format_string = comptime buildRowFormatString();
        try stdout.print(BINGO_CARD_HEADER, .{});
        for (0..5) |i| {
            try stdout.print(format_string, .{ self.b_columns[i], self.i_columns[i], self.n_columns[i], self.g_columns[i], self.o_columns[i] });
        }
    }
};

fn buildRowFormatString() []const u8 {
    var format_string: []const u8 = "|";
    for (BINGO_COLUMN_HEADER_CHARS) |_| {
        format_string = format_string ++ "{d: ^3}" ++ "|";
    }
    format_string = format_string ++ "\n";
    return format_string;
}

fn generate_bingo_col_values(beginning: u8) [15]u8 {
    var init: [15]u8 = undefined;
    for (&init, beginning..) |*value, i| {
        value.* = @intCast(i);
    }
    return init;
}

fn get_random_5(arr: []u8, prng: *std.rand.DefaultPrng) [5]u8 {
    for (0..4) |i| {
        const j = prng.random().intRangeAtMost(u8, @intCast(i), @intCast(arr.len - 1));
        const temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
    const first_5: [5]u8 = arr[0..5].*;
    return first_5;
}

test "return random value" {
    var value: u8 = undefined;
    value = try BingoCardV1.initRandom();

    try std.testing.expect(1 == 1);
}

test "b values contain all values 1 to 15" {
    for (b_values, 0..) |value, i| {
        try std.testing.expect(value == i + B_MIN_VALUE);
    }
}

test "i values contain all values 16 to 30" {
    for (i_values, 0..) |value, i| {
        try std.testing.expect(value == i + I_MIN_VALUE);
    }
}

test "n values contain all values 31 to 45" {
    for (n_values, 0..) |value, i| {
        try std.testing.expect(value == i + N_MIN_VALUE);
    }
}

test "g values contain all values 46 to 60" {
    for (g_values, 0..) |value, i| {
        try std.testing.expect(value == i + G_MIN_VALUE);
    }
}

test "o values contain all values 61 to 75" {
    for (o_values, 0..) |value, i| {
        try std.testing.expect(value == i + O_MIN_VALUE);
    }
}
