module ppl4.utils;

import ppl4.all;

ulong time(void delegate() d) {
    StopWatch w;
    w.start();
    d();
    return w.peek().total!"nsecs";
}

T minOf(T)(T a, T b) {
    return a < b ? a : b;
}
T maxOf(T)(T a, T b) {
    return a > b ? a : b;
}
