const std = @import("std");
const fs = std.fs;
const os = std.os;
const io = std.io;
const posix = std.posix;

const sb = @import("./ui/spellbook.zig");

const BingoCardV1 = @import("models/bingo_card_v1.zig").BingoCardV1;

const BlackoutRunner = @import("sim/blackout_runner.zig").BlackoutRunner;

const THREAD_COUNT = 4;

const Self = @This();

var tty: ?posix.fd_t = null;

const Writer = io.Writer(posix.fd_t, posix.WriteError, posix.write);
fn writer() Writer {
    return .{ .context = tty.? };
}

const BufferedWriter = io.BufferedWriter(4096, Writer);
fn bufferedWriter() BufferedWriter {
    return io.bufferedWriter(writer());
}

pub fn main() !void {
    // var tty = try fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
    // defer tty.close();

    // const original = try os.linux.tcgetattr(tty.handle);
    tty = try posix.open("/dev/tty", posix.O{ .ACCMODE = posix.ACCMODE.RDWR }, 0);
    const original = try posix.tcgetattr(tty.?);

    var raw = original;
    raw.lflag = posix.tc_lflag_t{
        .ECHO = false,
        .ICANON = false,
        .ISIG = false,
        .IEXTEN = false,
    };
    raw.iflag = posix.tc_iflag_t{
        .IXON = false,
        .ICRNL = false,
        .BRKINT = false,
        .INPCK = false,
        .ISTRIP = false,
    };
    raw.oflag = posix.tc_oflag_t{
        .OPOST = false,
    };
    raw.cflag = posix.tc_cflag_t{
        .CSIZE = posix.CSIZE.CS8,
    };

    raw.cc[5] = 0;
    raw.cc[6] = 0;
    try posix.tcsetattr(tty.?, .FLUSH, raw);
    var bufwrtr = io.bufferedWriter(Writer{ .context = tty.? });
    const wrtr = bufwrtr.writer();
    try wrtr.writeAll("\x1B[0;1;32mHello" ++ "Hi" ++ "\r\n");
    _ = try bufwrtr.flush();
    try posix.tcsetattr(tty.?, .FLUSH, original);
}

fn restoreTerminal(my_tty: *posix.fd_t, original: anytype) !void {
    try posix.tcsetattr(my_tty.*, .FLUSH, original.*);
    unreachable;
}

fn runSimulation() void {
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
