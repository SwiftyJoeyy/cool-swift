-- Comprehensive COOL program
class List {
    item : String;
    next : List;
    
    init(i : String, n : List) : List {
        {
            item <- i;
            next <- n;
            self;
        }
    };
    
    flatten() : String {
        let string : String <- item in
            if isvoid next then
                string
            else
                string.concat(next.flatten())
            fi
    };
};

class Main inherits IO {
    main() : Object {
        let hello : String <- "Hello ",
            world : String <- "World!",
            newline : String <- "\n" in
            out_string(hello.concat(world).concat(newline))
    };
    
    testCase(x : Int) : String {
        case x of
            n : Int => "integer";
            s : String => "string";
            o : Object => "object";
        esac
    };
    
    testDispatch() : Object {
        let obj : Object <- new List in
            obj@Object.type_name()
    };
};
