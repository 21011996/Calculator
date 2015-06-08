#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

int main() {
	int code = 0;
	int* codelink = &code;
	int answer = calculate("3*6/2-555/(7-8)+(((555)))/(((((99)))+(-94)))", codelink);
	printf("%i \n", answer);
	printf("%i \n", *codelink);

	answer = calculate("15+3", codelink);
        printf("%i \n", answer);
        printf("%i \n", *codelink);
}
