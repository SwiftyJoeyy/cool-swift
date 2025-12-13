-- COOL program with various expression types
class ExprTest {
    compute(x : Int, y : Int) : Bool {
        x + y * 2 < 10
    };
    
    check(val : Int) : String {
        if val < 0 then
            "negative"
        else
            if val = 0 then
                "zero"
            else
                "positive"
            fi
        fi
    };
    
    factorial(n : Int) : Int {
        let result : Int <- 1 in
            let counter : Int <- n in
            {
                while 0 < counter loop
                    {
                        result <- result * counter;
                        counter <- counter - 1;
                    }
                pool;
                result;
            }
    };
    
    calculate() : Int {
        let x : Int <- 5 in
            let y : Int <- 10 in
                x + y
    };
    
    create() : Object {
        new Object
    };
};
