#include "Indice1D.h"
#include "cudaTools.h"
#include "reductionADD.h"

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

__global__ void slice(int n, float* ptrDevGMRes);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

static __device__ void reductionIntraThread(float* tabSM, int nbSlice);

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

/**
 * output : void required !!
 */
__global__ void slice(int nbSlice, float* ptrDevGMRes)
    {
    extern __shared__ float tabSM[];
    reductionIntraThread(tabSM, nbSlice);
    __syncthreads();
    reductionADD<float>(tabSM, ptrDevGMRes);
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

__device__ void reductionIntraThread(float* tabSM, int nbSlice)
    {
    //pattern d'entrelacement
    const int NB_THREAD = Indice1D::nbThread();
    const int TID = Indice1D::tid();
    const int TID_LOCAL = Indice1D::tidLocal();
    const float DX=1.0f/(float)nbSlice;

    float localSum = 0;
    int s = TID;
    while (s < nbSlice)
	{
	float xs = s*DX;
	localSum += 4.0f / (1.0f + xs * xs);
	//localSum++;
	s += NB_THREAD;
	}
    tabSM[TID_LOCAL] = localSum/(float)nbSlice;
    }


/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

