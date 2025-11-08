-- Test method dispatch and punctuation
class Test {
    test() : Object {
        {
            obj.method();
            obj.method(1, 2, 3);
            obj@Parent.method();
            self.type_name();
            (new Test).init();
        }
    };
};
