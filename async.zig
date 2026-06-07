// Run with `zig run async.zig -OReleaseFast` with and without the mutex.lock
const std = @import("std");
const print = std.debug.print;

const SharedState = struct {
    counter: u32 = 0,
    mutex: std.Io.Mutex = .init,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const start_time = std.Io.Timestamp.now(io, .awake);
    var state = SharedState{};

    var group: std.Io.Group = .init;
    const num_tasks = 5;
    const increments_per_task = 5_000;

    var i: usize = 0;
    while (i < num_tasks) : (i += 1) {
        group.async(io, increment, .{ io, &state, increments_per_task });
    }

    try group.await(io);

    print("Counter: {}\n", .{state.counter});
    const end_time = std.Io.Timestamp.now(io, .awake);
    print("Duration: {f}\n", .{start_time.durationTo(end_time)});
}

fn increment(io: std.Io, state: *SharedState, times: u32) void {
    for (0..times) |_| {
        // state.mutex.lock(io) catch return;
        // defer state.mutex.unlock(io);

        // Sleep to give the other tasks a chance to run in the meantime.
        // We do this here only to make nondeterminism more visible.
        io.sleep(std.Io.Duration.fromMilliseconds(1), .awake) catch {};

        state.counter += 1;
    }
}
