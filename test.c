#include <stdio.h>
#include <unistd.h>
#include "expressionParser.h"
#include <math.h>

int main() {
	int q;
	int answer = calculate("1+(2)",q);
	printf("%i \n", answer);
	printf("%i \n", q);

}
