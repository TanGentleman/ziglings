//! I'm editing this in nvim! :D
const std = @import("std");

pub fn main(init: std.process.Init) !u8 { 
    _ = init;
    const res = '\n';
    std.debug.print("Char: {d}", .{res});
    return res;
}
