#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

int main() {
	int code = 0;
	int* codelink = &code;
	int answer = calculate(")", codelink);
	printf("%i \n", answer);
	printf("%i \n", *codelink);

}
