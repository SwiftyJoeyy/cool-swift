-- Test diagnostic errors
class Test {
    x : Int <- 123abc;
    y : String <- "has
newline";
    z : Int <- 456xyz;
    w : String <- "unclosed
};
