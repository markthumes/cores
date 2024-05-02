#include <math.h>
#include <stdio.h>

#define PI 4.0f*atan(1.0f)

int main(){
	int steps = 1000;
	int scale = 1000;
	for( int i = 0; i < steps; i++ ){
		float value = sinf(i*PI/steps);
		//-1 = 0;
		//+1 = 1000;
		fprintf(stdout, "%03x\n", (int)(scale * value));
	}
}
