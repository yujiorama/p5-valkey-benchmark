#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "valkey.h"  // libvalkeyのヘッダーファイルをインクルード

MODULE = Valkey::XS    PACKAGE = Valkey::XS

PROTOTYPES: ENABLE

void
hello_world()
  CODE:
    printf("Hello, World from XS!\n");

int
add(a, b)
  int a
  int b
  CODE:
    RETVAL = a + b;
  OUTPUT:
    RETVAL
