-- Comprehensive COOL program testing all features
class List {
    item : Int;
    next : List;
    
    init(i : Int, n : List) : List {
        {
            item <- i;
            next <- n;
            self;
        }
    };
    
    flatten() : String {
        let string : String <- "" in
            string
    };
};

class Main inherits IO {
    main() : Object {
        let hello : String <- "Hello World!\n",
            list : List <- (new List).init(1, new List)
        in {
            out_string(hello);
            out_int(list.item);
            out_string("\n");
        }
    };
};
