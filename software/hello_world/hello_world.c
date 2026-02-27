  #include <stdlib.h>
  #include <sys/alt_stdio.h>
  #include <sys/alt_alarm.h>
  #include <sys/times.h>
  #include <alt_types.h>
  #include <system.h>
  #include <stdio.h>
  #include <unistd.h>
  #include <math.h>
  #include "custom_instr.h"

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

  float calculateFunctionTask6(float x[], int M)
  {
    int i;
    float a_left;
    float a_right;
    float a_2;
    float cos_f;
    float a_cos;
    float y = 0;
    for (i=0; i<M; i++) {
      float a = x[i];
      a_left = cust_fp_mul(0.5,a);
      a_2 = cust_fp_mul(a,a);
      cos_f = cos((a-128.0f)/128.0f);
      a_cos = cust_fp_mul(a, cos_f);
      a_right = cust_fp_mul(a_2,a_cos);
      y += cust_fp_add_sub(1,a_left,a_right);
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
    averageTime(1,&calculateFunctionTask6,x,&y);
    // clock_t exec_t1 = 0;
    // clock_t exec_t2 = 0;
    // exec_t1 = times(NULL); // get system time before starting the process
    // y = calculateFunction(x,N);
    // exec_t2 = times(NULL); // get system time after starting the process
    // printf("Ticks: %d\n",exec_t2-exec_t1);
    printf("Result: %f \n",y);
  } 
