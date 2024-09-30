const std = @import("std");
const BingoCardV1 = @import("../models/bingo_card_v1.zig").BingoCardV1;

pub const BlackoutRunner = struct {
    prng: *std.Random.DefaultPrng = undefined,
    num: u8 = 11,

    pub fn init(a_prng: *std.Random.DefaultPrng) BlackoutRunner {
        return .{
            .prng = a_prng,
        };
    }

    pub fn simBlackoutBingo(self: *const BlackoutRunner, card: BingoCardV1) void {
        var fixed_n_columns: [5]u8 = undefined;
        for (card.n_column, 0..) |value, i| {
            fixed_n_columns[i] = value orelse 0;
        }
        var columns: [5][5]u8 = .{ card.b_column, card.i_column, fixed_n_columns, card.g_column, card.o_column };
        var values: [25]u8 = undefined;
        for (&columns) |*column| {
            std.mem.sort(u8, column, {}, comptime std.sort.asc(u8));
            values = mergeSortedArraysAsc(&values, column[0..]);
        }
        std.debug.print("{any}", .{card.b_column});
        std.debug.print("{any}", .{self.num});
    }
};

fn mergeSortedArraysAsc(array_one: *[25]u8, array_two: *[5]u8) []u8 {
    var count_one = 0;
    var count_two = 0;
    var merged_array: [array_one.len + array_two.len]u8 = undefined;
    var i = 0;

    while (count_one < array_one.len and count_two < array_two.len) {
        if (array_one[count_one] < array_two[count_two]) {
            merged_array[i] = array_one[count_one];
            count_one += 1;
        } else {
            merged_array[i] = array_two[count_two];
            count_two += 1;
        }
        i += 1;
    }
    if (count_one == array_one.len) {
        merged_array = merged_array ++ array_two[count_two..array_two.len];
    } else {
        merged_array = merged_array ++ array_one[count_one..array_one.len];
    }

    return merged_array;
}

test "merges sorted arrays" {
    const array_one = .{ 1, 2, 3, 10 };
    const array_two = .{ 5, 6, 8, 14, 17 };

    const merged_array = mergeSortedArraysAsc(array_one, array_two);
    std.testing.expect(std.mem.eql(merged_array, .{ 1, 2, 3, 5, 6, 8, 10, 14, 17 }));
}
