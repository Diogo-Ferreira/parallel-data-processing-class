#include "Indice2D.h"
#include "Indice1D.h"
#include "cudaTools.h"
#include <stdio.h>

__global__ void histogramd(int* ptrTabData, int tabSize, int *ptrDevResult);
static __device__ void reductionIntraThread(int *ptrTabData, int tabSize, int *tabSM);
__device__ void reductionInterBlock(int* TAB_SM, int* ptrGM);

__global__ void histogramd(int* ptrTabData, int tabSize, int *ptrDevResult)
    {
    extern __shared__ int tabSM[];


    reductionIntraThread(ptrTabData, tabSize, tabSM);
    __syncthreads();
    reductionInterBlock(tabSM, ptrDevResult);

    }
__device__ void reductionIntraThread(int *ptrTabData, int tabSize, int *tabSM)
    {
    const int NB_THREAD = Indice2D::nbThread();
    const int TID_LOCAL = Indice2D::tidLocal();
    const int TID = Indice2D::tid();

    int s = TID;

    while (s < tabSize)
	{
	atomicAdd(&tabSM[ptrTabData[s]], 1);
	s += NB_THREAD;
	}
    }

__device__ void reductionInterBlock(int* tabSM, int* tabGM)
    {
    if (Indice2D::tidLocal() == 0)
    	    {
    	    for (int i = 0; i < 256; i++)
    		{
    		atomicAdd(&tabGM[i], tabSM[i]);
    		}
    	    }
    }
