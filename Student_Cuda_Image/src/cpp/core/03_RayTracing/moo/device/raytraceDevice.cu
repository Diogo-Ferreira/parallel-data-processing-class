#include "Indice2D.h"
#include "cudaTools.h"
#include "Device.h"

#include "IndiceTools_GPU.h"

#include "../length_cm.h"

#include "DomaineMath_GPU.h"
#include "RaytraceMath.h"
using namespace gpu;

// Attention : 	Choix du nom est impotant!
//		VagueDevice.cu et non Vague.cu
// 		Dans ce dernier cas, probl�me de linkage, car le nom du .cu est le meme que le nom d'un .cpp (host)
//		On a donc ajouter Device (ou n'importequoi) pour que les noms soient diff�rents!

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__global__ void raytraceGM(uchar4* ptrDevPixels, Sphere* ptrDevTabSphere, int nbSpheres, uint w, uint h, float t);
__host__ void uploadGPU(Sphere* tabValue);
__global__ void raytraceCM(uchar4* ptrDevPixels, uint w, uint h, float t);
__device__ void work(uchar4* ptrDevPixels,Sphere* ptrDevSphere, int n, uint w, uint h, float t);
__global__ void rayTracingSM(uchar4* ptrDevPixels, uint w, uint h, float dt, Sphere* ptrDevTabSphere);
__device__ void copyGMtoSM(Sphere* ptrDevTabSphere, Sphere* tab_SM);
/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__global__ void raytraceGM(uchar4* ptrDevPixels, Sphere* ptrDevTabSphere, int nbSpheres, uint w, uint h, float t)
    {
    work(ptrDevPixels, ptrDevTabSphere, nbSpheres, w, h, t);
    }

// Déclaration Constante globale
__constant__ Sphere SPHERE_CM[LENGTH_CM];
/**
 * call once by the host
 */
__host__ void uploadGPU(Sphere* tabValue)
    {
    size_t size = LENGTH_CM * sizeof(Sphere);
    int offset = 0;
    HANDLE_ERROR(cudaMemcpyToSymbol(SPHERE_CM, tabValue, size, offset, cudaMemcpyHostToDevice));
    }

__device__ void copyGMtoSM(Sphere* ptrDevTabSphere, Sphere* tab_SM)
    {
    const int TID_LOCAL = Indice2D::tidLocal();
    const int NB_THREAD_LOCAL = Indice2D::nbThreadLocal();
    int s = TID_LOCAL;
    int NB_SPHERE = LENGTH_CM;

    while (s < NB_SPHERE)
	{
	tab_SM[s] = ptrDevTabSphere[s];
	s += NB_THREAD_LOCAL;
	}
    }

__global__ void raytraceCM(uchar4* ptrDevPixels, uint w, uint h, float t)
    {

    work(ptrDevPixels, SPHERE_CM, LENGTH_CM, w, h, t);
    }

__global__ void rayTracingSM(uchar4* ptrDevPixels, uint w, uint h, float t, Sphere* ptrDevTabSphere)
    {
    extern __shared__ Sphere tab_SM[];
    copyGMtoSM(ptrDevTabSphere, tab_SM);

    __syncthreads();
    work(ptrDevPixels, tab_SM, LENGTH_CM, w, h, t);
    }
__device__ void work(uchar4* ptrDevPixels,Sphere* ptrDevSphere, int n, uint w, uint h, float t)
{
    RaytraceMath raytraceMath = RaytraceMath(w, h, ptrDevSphere, n);

    const int TID = Indice2D::tid();
    const int NB_THREADS = Indice2D::nbThread();
    const int WH = w * h;
    int i;
    int j;
    int s = TID;

    while (s < WH)
    {
    IndiceTools::toIJ(s, w, &i, &j);
    raytraceMath.colorIJ(&ptrDevPixels[s], i, j, t);
    s += NB_THREADS;
    }
}

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

