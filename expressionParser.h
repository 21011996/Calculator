#ifndef _PROJECT_PARSER_H
#define _PROJECT_PARSER_H
#include <stdint.h>
#include <stddef.h>
#include <string.h>

/**
 * int sign
 * int size
 * int64_t* data
 * base is 2^64
 */
typedef void* Lexer;

#ifdef __cplusplus
extern "C" {
#endif

/**
Extracts value from string
*/

int calculate(char const *s, int code);

#ifdef __cplusplus
}
#endif

#endif
