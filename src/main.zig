const std = @import("std");
const bingo_card = @import("models/bingo_card_v1.zig");

pub fn main() !void {
    const my_card = try bingo_card.BingoCardV1.initRandom();
    try my_card.printCard();
}
