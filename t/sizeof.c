#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include "valkey.h"

// valkeyReply デバッグ用関数
void debug_valkeyReply(valkeyReply* reply) {
    printf("valkeyReply at %p\n", (void*)reply);
    printf("  type: %d\n", reply->type);
    printf("  integer: %lld\n", reply->integer);
    printf("  dval: %f\n", reply->dval);
    printf("  len: %zu\n", reply->len);
    printf("  str: %p\n", (void*)reply->str);
    printf("  vtype: %.3s\n", reply->vtype);
    printf("  elements: %zu\n", reply->elements);
    printf("  element: %p\n", (void*)reply->element);
}

void debug_valkeyReply_array(valkeyReply** array, size_t num_elements) {
    for (size_t i = 0; i < num_elements; i++) {
        printf("Element [%zu]:\n", i);
        debug_valkeyReply(array[i]);
    }
}

int main() {
    printf("Size of int: %zu\n", sizeof(int));
    printf("Size of long long: %zu\n", sizeof(long long));
    printf("Size of size_t: %zu\n", sizeof(size_t));
    printf("Size of pointer: %zu\n", sizeof(void*));

    printf("sizeof(valkeyReply): %zu\n", sizeof(valkeyReply)); // 構造体全体のサイズ

    // 各フィールドのオフセットを表示
    printf("Offset of type:      %zu, Size: %zu\n", offsetof(valkeyReply, type), sizeof(((valkeyReply*)0)->type));
    printf("Offset of integer:   %zu, Size: %zu\n", offsetof(valkeyReply, integer), sizeof(((valkeyReply*)0)->integer));
    printf("Offset of dval:      %zu, Size: %zu\n", offsetof(valkeyReply, dval), sizeof(((valkeyReply*)0)->dval));
    printf("Offset of len:       %zu, Size: %zu\n", offsetof(valkeyReply, len), sizeof(((valkeyReply*)0)->len));
    printf("Offset of str:       %zu, Size: %zu\n", offsetof(valkeyReply, str), sizeof(((valkeyReply*)0)->str));
    printf("Offset of vtype:     %zu, Size: %zu\n", offsetof(valkeyReply, vtype), sizeof(((valkeyReply*)0)->vtype));
    printf("Offset of elements:  %zu, Size: %zu\n", offsetof(valkeyReply, elements), sizeof(((valkeyReply*)0)->elements));
    printf("Offset of element:   %zu, Size: %zu\n", offsetof(valkeyReply, element), sizeof(((valkeyReply*)0)->element));

//    valkeyReply r1;
//    memset(&r1, 0, sizeof(r1));
//    r1.type = 1;
//    r1.str = "a";
//    r1.len = strlen(r1.str);
//    valkeyReply r2;
//    memset(&r2, 0, sizeof(r2));
//    r2.type = 1;
//    r2.str = "bb";
//    r2.len = strlen(r2.str);
//    valkeyReply r3;
//    memset(&r3, 0, sizeof(r3));
//    r3.type = 3;
//    r3.integer = 3;
//    valkeyReply *element[3] = {&r1, &r2, &r3};
//    valkeyReply r;
//    memset(&r, 0, sizeof(r));
//    r.type = 2;
//    r.elements = 3;
//    r.element = element;
//    debug_valkeyReply(&r);
//    debug_valkeyReply_array(r.element, r.elements);

    valkeyReply element1 = {1, 42, 3.14, 4, "hello", "TXT", 0, NULL};
    valkeyReply element2 = {2, 55, 6.28, 5, "world", "TXT", 0, NULL};
    valkeyReply element3 = {3, 66, 9.42, 6, "test", "TXT", 0, NULL};

    valkeyReply *elements[3] = {&element1, &element2, &element3};

    valkeyReply parent = {9, 0, 0.0, 0, NULL, "ARR", 3, elements};

    printf("Parent Address: %p\n", (void*)&parent);
    printf("Number of elements: %zu\n", parent.elements);
    for (size_t i = 0; i < parent.elements; i++) {
        printf("Element %zu Address: %p, Type: %d\n", i, (void*)parent.element[i], parent.element[i]->type);
    }

    return 0;
}
