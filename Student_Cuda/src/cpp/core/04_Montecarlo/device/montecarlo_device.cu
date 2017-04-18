#include "Indice1D.h"
#include "cudaTools.h"
#include "reductionADD.h"
#include <curand_kernel.h>
#include <limits.h>
#include <Indice1D.h>
#include <stdio.h>

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__global__ void setup_kernel_rand(curandState* tabDevGenerator, int deviceId);
__global__ void montecarlo(curandState* tabDevGenerator, int* ptrDevGMRes, long n, float m);

/*--------------------------------------*\sliisOkisOkcei
 * sOk
 |*		Private			*|
 \*-------------------------------------*/

static __device__ void reductionIntraThread(int* tabSM, int n, curandState* tabDevGenerator, float m);

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/**
 * output : void required !!
 */
__global__ void montecarlo(curandState* tabDevGenerator, int* ptrDevGMRes, long n, float m)
    {
    extern __shared__ int tabSM[];
    reductionIntraThread(tabSM, n, tabDevGenerator, m);
    __syncthreads();
    reductionADD<int>(tabSM, ptrDevGMRes);
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

__device__ void reductionIntraThread(int* tabSM, int n, curandState* tabDevGenerator, float m)
    {
    //pattern d'entrelacement
    const int NB_THREAD = Indice1D::nbThread();
    const int TID = Indice1D::tid();
    const int TID_LOCAL = Indice1D::tidLocal();

    float inCount = 0;
    curandState localGenerator = tabDevGenerator [TID];
    float xAlea;
    float yAlea;
    float fx;
    for (long i = 1; i <= n; i++)
	{

	xAlea = curand_uniform(&localGenerator);
	yAlea = curand_uniform(&localGenerator)*m;

	//fx = 4.0f / (1.0f + xAlea * xAlea);
	fx = sqrtf(1-(xAlea * xAlea));

	if(yAlea < fx){
	    inCount++;
	}
	}
    tabSM[TID_LOCAL] = inCount;
    }


// Each thread gets same seed, a different sequence number
// no offset
__global__ void setup_kernel_rand(curandState* tabDevGenerator, int deviceId)
    {
// Customisation du generator:
// Proposition, au lecteur de faire mieux !
// Contrainte : Doit etre différent d'un GPU à l'autre
// Contrainte : Doit etre différent d’un thread à l’autre
    const int TID = Indice1D::tid();
    int deltaSeed = deviceId * INT_MAX / 10000;
    int deltaSequence = deviceId * 100;
    int deltaOffset = deviceId * 100;
    int seed = 1234 + deltaSeed;
    int sequenceNumber = TID + deltaSequence;
    int offset = deltaOffset;
    curand_init(seed, sequenceNumber, offset, &tabDevGenerator[TID]);
    }

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

