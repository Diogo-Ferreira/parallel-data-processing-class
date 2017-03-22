#include "Indice2D.h"
#include "cudaTools.h"
#include "Device.h"

#include "IndiceTools_GPU.h"

#include "DomaineMath_GPU.h"
#include "MandelMath.h"
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

__global__ void mandel(uchar4* ptrDevPixels, uint w, uint h, float t, DomaineMath domaineMath);

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

__global__ void mandel(uchar4* ptrDevPixels, uint w, uint h, float t,DomaineMath domaineMath)
    {
    MandelMath mandelMath = MandelMath(w,h);

    const int TID = Indice2D::tid();
    const int NB_THREADS = Indice2D::nbThread();
    const int WH = w * h;
    int i;
    int j;
    int s = TID;
    while(s < WH)
	{
	IndiceTools::toIJ(s, w, &i, &j);
	double x;
	double y;
	domaineMath.toXY(i, j, &x, &y); // fill (x,y) from (i,j)
	mandelMath.colorXY(&ptrDevPixels[s],x, y, t);
	s +=NB_THREADS;
	}
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/

