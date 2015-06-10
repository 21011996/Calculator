#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>


int testCalculate(char const *s, double value){
	int code = 0;
        int* codelink = &code;
        double answer = calculate(s, codelink);
        return value - answer;

}
void testresult(double a) {
	if (a == 0) {
		printf("%s \n", "OK");
	} else {
		printf("%f \n", a);
	}
}

int main() {
	testresult(testCalculate("8.8/2", 4.4));
	testresult(testCalculate("(((1+2*2)))%(13-4)", 5.0));
	testresult(testCalculate("1000000*(((6-1-2-3)))", 0.0));
	testresult(testCalculate("44*6-((5)-(2*2))/2+3/3*((4))*(-333)", -1068.0));
	testresult(testCalculate("3*6/4-555(7-8)+(((555)))/(((((99)))+(-94)))", 115.0));
}
