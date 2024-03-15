const expect = @import("std").testing.expect;
const print = @import("std").debug.print;

const ComparatorReturn = enum{
    eq,
    lt,
    gt,
};

fn sub_comparator(comptime T: type) fn (a: T, b: T) ComparatorReturn{
    return struct{
        pub fn sub(a: T, b: T) ComparatorReturn {
            const s: T = a - b; 
            if(s == 0){
                return ComparatorReturn.eq;
            }else if(s < 0){
                return ComparatorReturn.lt;
            }
            return ComparatorReturn.gt;
        }
    }.sub;
}

fn binarySearchGeneric(comptime T: type, array: []const T,
                       search_val: T,
                       comparator: *const fn(a: T, b: T) ComparatorReturn) bool{
    var start: [*]const T = array.ptr;
    var end: [*]const T = array.ptr + (array.len - 1);
    var mid: [*]const T = undefined;
    while ( @intFromPtr(end) >= @intFromPtr(start) ){
        // Zig allows pointer arithmetic
        // one can add integers to a pointer, but not other pointers
        // so we determin the number of items to move and then add to start
        // zig handles the sizeof(T) when adding to the pointer
        mid = start + (@intFromPtr(end) - @intFromPtr(start)) / @sizeOf(T) / 2;
        switch(comparator(search_val, mid[0])){
            .eq => return true,
            .lt => end = mid - 1,
            .gt => start = mid + 1,
        }
    }
    return false;
}


test "test binary search" {
    var data_array = [_]i8 {1, 2, 4, 5, 6, 9};
    try expect(binarySearchGeneric(i8, &data_array, 1, sub_comparator(i8)) == true);
    try expect(binarySearchGeneric(i8, &data_array, 0, sub_comparator(i8)) == false);
}
