const std = @import("std");
const BingoCardV1 = @import("models/bingo_card_v1.zig").BingoCardV1;
const BlackoutRunner = @import("sim/blackout_runner.zig").BlackoutRunner;
const THREAD_COUNT = 4;

pub fn main() !void {
    var games_won_by_turn: [THREAD_COUNT][75]u64 = .{std.mem.zeroes([75]u64)} ** THREAD_COUNT;

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    var threads: [THREAD_COUNT]std.Thread = undefined;
    for (0..THREAD_COUNT) |i| {
        threads[i] = try std.Thread.spawn(.{}, createCardAndSim, .{
            &prng,
            &games_won_by_turn[i],
        });
    }

    for (0..THREAD_COUNT) |i| {
        threads[i].join();
    }
}

fn createCardAndSim(prng: *std.Random.DefaultPrng, win_storage: *[75]u64) void {
    const my_card = BingoCardV1.initRandom(prng);
    const runner = BlackoutRunner.init(prng);

    runner.simBlackoutBingo(my_card, win_storage, 25_000_000);
}
