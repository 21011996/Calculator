#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>


int testCalculate(int a, char const *s, int value){
	int code = 0;
        int* codelink = &code;
        int answer = calculate(s, codelink);
        return value - answer;

}
void testresult(int a) {
	if (a == 0) {
		printf("%s \n", "OK");
	} else {
		printf("%i \n", a);
	}
}

int main() {
/*	int code = 0;
	int* codelink = &code;
	int answer = calculate("8*8/2", codelink);
	printf("%i \n", answer);
	printf("%i \n", *codelink);
*/
    testresult(testCalculate(2, "8*8/2%3", 2));
    testresult(testCalculate(2, "(((1+2*2)))%(13-4)", 5));
    testresult(testCalculate(2, "1000000*(((6-1-2-3)))", 0));
    testresult(testCalculate(2, "44*6-((5)-(2*2))/2+3/3*((4))*(-333)", -1068));
    testresult(testCalculate(2, "3*6/4-555%(7-8)+(((555)))/(((((99)))+(-94)))", 115));

}
