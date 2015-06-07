#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

int main() {
	//ssize_t readd;
	char buff[1024];
	//readd = read(STDIN_FILENO, buff, 4096);
	//int64_t code;
	//int64_t value= calculate(buff, code);
	//int code2 = code;
	//int value2 = value;
	//printf("%i \n", value2);
	//printf("%i \n", code2);

	//printf("%i \n", constructor("1+2+3"));
	//printf("%i \n", strlength("1+2+3"));
	char* s = "1+2+3";
	int q;
	Lexer lex = constructor("1+2+3",buff);
	write(STDOUT_FILENO, buff, 6);
	next(lex, buff);
	//write(STDOUT_FILENO, buff, 6);


}