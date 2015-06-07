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

void calculate(char const *s, int64_t code);

Lexer constructor(char const *s, char *a);
int strlength(char const *s);
int parseExpr(Lexer lex);
int parseSum(Lexer lex);
int parseMultiplier(Lexer lex);
void next(Lexer lex,char *s);
int isDigit(char const *s, int number);
int parseValue(Lexer lex);
int parseInt(char const *s);

#ifdef __cplusplus
}
#endif

#endif