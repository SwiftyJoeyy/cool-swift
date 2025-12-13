-- COOL program with various method signatures
class Calculator {
    reset() : Int {
        0
    };
    
    square(x : Int) : Int {
        x * x
    };
    
    add(a : Int, b : Int) : Int {
        a + b
    };
    
    getString() : String {
        "hello"
    };
    
    getBool() : Bool {
        true
    };
    
    getObject() : Object {
        new Object
    };
    
    process(x : Int) : Int {
        {
            reset();
            square(add(x, 1));
        }
    };
};
