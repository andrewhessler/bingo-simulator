const std = @import("std");
const BingoCardV1 = @import("models/bingo_card_v1.zig").BingoCardV1;
const BlackoutRunner = @import("sim/blackout_runner.zig").BlackoutRunner;

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const my_card = BingoCardV1.initRandom(&prng);
    const runner = BlackoutRunner.init(&prng);

    try my_card.printCard();
    runner.simBlackoutBingo(my_card);
}
