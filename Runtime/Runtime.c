//
//  Runtime.c
//  CoolSwift
//
//  Created by Joe Maghzal on 13/08/2026.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

// ============ Object ============

typedef struct Object Object;

typedef struct Object_vtable {
    void (*abort)(Object* self);
    Object* (*copy)(Object* self);
    char* type_name;
    size_t size;
} Object_vtable;

struct Object {
    Object_vtable* vtable;
};

void Object_abort(Object* self) {
    fprintf(stderr, "Abort called\n");
    exit(1);
}

const char* Object_type_name(Object* self) {
    return self->vtable->type_name;
}

Object* Object_copy(Object* self) {
    size_t size = self->vtable->size;
    Object* copy = malloc(size);
    memcpy(copy, self, size);
    return copy;
}

Object_vtable Object_vtable_instance = {
    .abort = Object_abort,
    .copy = Object_copy,
    .type_name = "Object",
    .size = sizeof(Object),
};


// ============ Int ============

typedef struct {
    Object base;
    int32_t value;
} Int;

Object_vtable Int_vtable_instance = {
    .abort = Object_abort,
    .copy = Int_copy,
    .type_name = "Int",
    .size = sizeof(Int),
};

Int* Int_new(int32_t value) {
    Int* self = malloc(sizeof(Int));
    self->base.vtable = &Int_vtable_instance;
    self->value = value;
    return self;
}

Int* Int_add(Int* self, Int* other) {
    return Int_new(self->value + other->value);
}
Int* Int_sub(Int* self, Int* other) {
    return Int_new(self->value - other->value);
}
Int* Int_mul(Int* self, Int* other) {
    return Int_new(self->value * other->value);
}
Int* Int_div(Int* self, Int* other) {
    return Int_new(self->value / other->value);
}


// ============ IO ============

typedef struct {
    Object base;
} IO;

Object_vtable IO_vtable_instance = {
    .abort = Object_abort,
    .copy = Object_copy,
    .type_name = "IO",
    .size = sizeof(IO),
};

IO* IO_new() {
    IO* self = malloc(sizeof(IO));
    self->base.vtable = &IO_vtable_instance;
    return self;
}

IO* IO_out_string(void* self, char* str) {
    if (str) {
        printf("%s", str);
        fflush(stdout);
    }
    return self;
}

IO* IO_out_int(void* self, int x) {
    printf("%d", x);
    fflush(stdout);
    return self;
}

String* IO_in_string(void* self) {
    char* buffer = malloc(1024);
    if (!buffer) {
        fprintf(stderr, "Out of memory in IO.in_string\n");
        exit(1);
    }
    if (fgets(buffer, 1024, stdin)) {
        size_t len = strlen(buffer);
        if (len > 0 && buffer[len-1] == '\n') {
            buffer[len-1] = '\0';
        }
        return buffer;
    }
    buffer[0] = '\0';
    return String_new(buffer);
}

Int* IO_in_int(void* self) {
    int x = 0;
    if (scanf("%d", &x) != 1) {
        int c;
        while ((c = getchar()) != '\n' && c != EOF);
    }
    return Int_new(x);
}


// ============ String ============

typedef struct {
    Object base;
    char* value;
} String;

Object_vtable String_vtable_instance = {
    .abort = Object_abort,
    .copy = String_copy,
    .type_name = "String",
    .size = sizeof(String),
};

String* String_new(char* value) {
    String* self = malloc(sizeof(String));
    self->base.vtable = &String_vtable_instance;
    self->value = value;
    return self;
}

Int* String_length(String* string) {
    char* str = string->value;
    if (!str) return 0;
    int str_len = (int)strlen(str);
    
    return Int_new(str_len);
}

String* String_concat(String* string1, String* string2) {
    char* str1 = string1->value;
    char* str2 = string2->value;
    
    if (!str1) str1 = "";
    if (!str2) str2 = "";
    
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    
    char* result = malloc(len1 + len2 + 1);
    if (!result) {
        fprintf(stderr, "Out of memory in String.concat\n");
        exit(1);
    }
    
    strcpy(result, str1);
    strcat(result, str2);
    return String_new(result);
}

String* String_substr(String* string, Int* start, Int* len) {
    char* str = string->value;
    if (!str) str = "";
    
    int str_len = (int)strlen(str);
    int len_int = len->value;
    int start_int = start->value;
    
    if (start_int < 0 || start_int >= str_len || len_int < 0) {
        fprintf(stderr, "String.substr out of range\n");
        exit(1);
    }
    
    if (start_int + len_int > str_len) {
        len = str_len - start;
    }
    
    char* result = malloc(len_int + 1);
    if (!result) {
        fprintf(stderr, "Out of memory in String.substr\n");
        exit(1);
    }
    
    strncpy(result, str + start_int, len_int);
    result[len_int] = '\0';
    return String_new(result);
}


// ============ Bool ============

typedef struct {
    Object base;
    bool value;
} Bool;

Object_vtable Bool_vtable_instance = {
    .abort = Object_abort,
    .copy = Bool_copy,
    .type_name = "Bool",
    .size = sizeof(Bool),
};

Bool* Bool_new(bool value) {
    Bool* self = malloc(sizeof(Bool));
    self->base.vtable = &Bool_vtable_instance;
    self->value = value;
    return self;
}


// ============ Memory allocation wrapper ============

void* cool_malloc(int size) {
    void* ptr = malloc(size);
    if (!ptr) {
        fprintf(stderr, "Out of memory\n");
        exit(1);
    }
    return ptr;
}
