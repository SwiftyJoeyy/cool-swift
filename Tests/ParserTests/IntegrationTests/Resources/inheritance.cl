-- COOL program demonstrating inheritance
class Point {
    x : Int;
    y : Int;
    
    init(x_val : Int, y_val : Int) : SELF_TYPE {
        {
            x <- x_val;
            y <- y_val;
            self;
        }
    };
};

class Point3D inherits Point {
    z : Int;
    
    init3D(x_val : Int, y_val : Int, z_val : Int) : SELF_TYPE {
        {
            x <- x_val;
            y <- y_val;
            z <- z_val;
            self;
        }
    };
};
