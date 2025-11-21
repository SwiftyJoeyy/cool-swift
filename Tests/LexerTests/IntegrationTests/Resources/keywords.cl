-- Test all keywords and case sensitivity
class Foo inherits Bar {
    let x : Int <- if true then 1 else 0 fi in
        while not isvoid x loop
            case x of
                n : Int => n;
            esac
        pool;
    
    -- Keywords are case-insensitive (except true/false)
    CLASS Test INHERITS Object {
        IF x THEN y ELSE z FI;
    };
    
    -- true/false must start with lowercase
    x : Bool <- true;
    y : Bool <- false;
};
