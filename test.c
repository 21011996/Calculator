#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

void testresult(int a) {
	if (a == 0) {
		printf("%s \n", "OK");
	} else {
		printf("%i \n", a);
	}
}

int main() {
	int code = 0;
	int* codelink = &code;
	int answer = calculate(")", codelink);
	printf("%i \n", answer);
	printf("%i \n", *codelink);
	
	testresult(testCalculate(1, "3-*3", 0));
    testresult(testCalculate(1, "***", 0));
    testresult(testCalculate(1, "(((3-5))))))", 0));
    testresult(testCalculate(1, "-3-", 0));
    testresult(testCalculate(1, "+", 0));
    testresult(testCalculate(1, "1418/(500-400-100)", 0));
    testresult(testCalculate(1, "()"));

    testresult(testCalculate(2, "8*8/2", 8));
    testresult(testCalculate(2, "(((1+2*2)))%(13-4)", 5));
    testresult(testCalculate(2, "1000000*(((6-1-2-3)))", 0));
    testresult(testCalculate(2, "44*6-((5)-(2*2))/2+3/3*((4))*(-333)", -1068));
    testresult(testCalculate(2, "3*6/4-555%(7-8)+(((555)))/(((((99)))+(-94)))", 115));

}
