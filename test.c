#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

int main() {
	char buff[1024];
	char* s = "1+2+3";
	int q;
	int answer = calculate("1+2",q);
	printf("%i \n", answer);


}
