#ifndef _PROJECT_PARSER_H
#define _PROJECT_PARSER_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
Extracts value from string
*/

int calculate(char const *s, int* code);

/**
Tests calculate with 3 different options:
1 - should fail
2 - should equals

On option 1 returns 0 if test passed, 1 if test failed.
On option 2 returns 0 if test passed, number = shouldEquals-calculate if test failed.
*/

int testCalculate(int option, char const *s, int shouldEquals);

#ifdef __cplusplus
}
#endif

#endif
