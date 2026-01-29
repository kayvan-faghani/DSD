#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <sys/alt_alarm.h>
#include <sys/times.h>
#include <alt_types.h>
#include <system.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>

// Test case 1
// #define step 5
// #define N 52

// Test case 2
// #define step 1/8.0
// #define N 2041

// #define N 1349
//Test case 3
#define step 1/256.0
#define N 65281

// Test Case 4
// #define N 2323
// #define RANDSEED 334

// void generateRandomVector(float x[N])
// {
//     int i;
//     srand(RANDSEED);
//     for (i=0; i<N; i++)
//     {
//         x[i] = ((float) rand()/ (float) RAND_MAX) * MAXVAL;
//     }
// }


// Generates the vector x and stores it in the memory
void generateVector(float x[N])
{
  
	int i;
	x[0] = 0;
	for (i=1; i<N; i++) {
		x[i] = x[i-1] + step;
  }
    
}

float sumVector(float x[], int M)
{
  int i;
  float y = 0;
	for (i=0; i<M; i++) {
    y += x[i] + x[i]*x[i]*x[i];
  }
  return y;
}

float calculateFunction(float x[], int M)
{
  int i;
  float y = 0;
	for (i=0; i<M; i++) {
    float a = x[i];
    y += 0.5*a+a*a*a*cos((a-128.0f)/128.0f);
  }
  return y;
}

float averageTime(int runs, float (*fptr)(float[],int),float x[], float* y)
{
  clock_t total = 0;
  clock_t exec_t1 = 0;
  clock_t exec_t2 = 0;
  for(int i = 0; i < runs; i++) {
    exec_t1 = times(NULL); // get system time before starting the process
    *y = fptr(x, N);
    exec_t2 = times(NULL); // get system time after finishing the process
    total += exec_t2-exec_t1;
  }
  printf("Total %d\n",total);
  return total/(float)runs;
}

int main()
{
  printf("Task 3!\n");

  // Define input vector
  float x[N];

  // Returned result
  float y;
  generateVector(x);

  // The following is used for timing
  averageTime(1,&calculateFunction,x,&y);
  	
  y = y/1024.0;
  printf("Result: %d \n",(int) y);
} 
