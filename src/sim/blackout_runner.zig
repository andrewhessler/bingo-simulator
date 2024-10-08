const std = @import("std");
const BingoCardV1 = @import("../models/bingo_card_v1.zig").BingoCardV1;

pub const BlackoutRunner = struct {
    prng: *std.Random.DefaultPrng = undefined,

    pub fn init(a_prng: *std.Random.DefaultPrng) BlackoutRunner {
        return .{
            .prng = a_prng,
        };
    }

    pub fn simBlackoutBingo(self: *const BlackoutRunner, card: BingoCardV1, games_won_by_turn: *[75]u64, games: u64) void {
        var fixed_n_columns: [5]u8 = undefined;
        for (card.n_column, 0..) |value, i| {
            fixed_n_columns[i] = value orelse 0;
        }

        var columns: [5][5]u8 = .{ card.b_column, card.i_column, fixed_n_columns, card.g_column, card.o_column };
        for (&columns) |*column| {
            std.mem.sort(u8, column, {}, std.sort.asc(u8));
        }

        for (0..games) |_| {
            const call_order = getRandomCallOrder(self.prng);
            const turn_won = runSim(call_order, columns);
            games_won_by_turn[turn_won] += 1;
        }

        var total_games_52_or_less: u64 = 0;
        for (games_won_by_turn, 0..) |games_won, i| {
            if (i < 52) {
                total_games_52_or_less += games_won;
            }
        }

        const games_float: f64 = @floatFromInt(games);
        const total_games_less_than: f64 = @floatFromInt(total_games_52_or_less);
        std.debug.print("Percent Win <=52: {d}\n", .{total_games_less_than / games_float});
    }

    fn runSim(call_order: [75]u8, columns: [5][5]u8) u8 {
        var values_found: u8 = 0;
        var turn_won: u8 = 0;
        for (call_order, 0..) |value, i| {
            const column: u8 = @divFloor(value - 1, 15);
            for (columns[column]) |column_value| {
                if (column_value == value) {
                    values_found += 1;
                }
            }
            if (values_found == 24) {
                turn_won = @intCast(i);
                break;
            }
        }
        return turn_won;
    }
};

fn getRandomCallOrder(prng: *std.Random.DefaultPrng) [75]u8 {
    var bingo_balls: [75]u8 = undefined;
    inline for (&bingo_balls, 0..) |*ball, i| {
        ball.* = @intCast(i + 1);
    }
    for (0..75) |i| {
        const j = prng.random().intRangeAtMost(u8, @intCast(i), @intCast(bingo_balls.len - 1));
        const temp = bingo_balls[i];
        bingo_balls[i] = bingo_balls[j];
        bingo_balls[j] = temp;
    }
    return bingo_balls;
}
