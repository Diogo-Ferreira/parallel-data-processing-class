#include "../../05_Montecarlomultigpu/host/montecarlomultigpu.h"

#include <iostream>

#include "Device.h"
#include <curand_kernel.h>
#include "montecarlo.h"
using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/


/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/
/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			Implementation 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Constructeur			*|
 \*-------------------------------------*/

Montecarlomultigpu::Montecarlomultigpu(const Grid& grid, float xMin, float xMax, float m, int n) :
	 n(n), xMin(xMin), xMax(xMax), m(m)
    {
	this->grid = grid;
	//Device::memcpyHToD(this->piHatDev, this->piHat, sizeOctet);
    }

Montecarlomultigpu::~Montecarlomultigpu(void)
    {
    //MM (device free)
	{
	Device::lastCudaError("AddVector MM (end deallocation)"); // temp debug, facultatif
	}
    }
/*--------------------------------------*\
 |*		Methode			*|
 \*-------------------------------------*/

void Montecarlomultigpu::run()
    {
	int nbDevice=Device::getDeviceCount() ;
	int nbFlechetteGPU=n/nbDevice;
	int sumTotal=0 ;
	cout << "Nombre de device " << nbDevice << endl;
	#pragma omp parallel for reduction(+:sumTotal)
	for (int idDevice=0; idDevice< nbDevice ; idDevice ++)
	    {
	    cudaSetDevice (idDevice) ; // idDevice nintervient plus ensuite
	    Montecarlo montecarlo(grid, xMin, xMax, m, nbFlechetteGPU) ;// sur le device courant !
	    montecarlo.run() ; // sur le device courant !
	    sumTotal += montecarlo.getCountArrows();
	    }

	cout << "Somme du total : " << sumTotal << endl;
	// Finalisation mathématique coté host
	//piHat = 2.0f*(float)sumTotal/(float)n*(fabsf(xMax-xMin)*m);
	this->piHat = 2.0*(double)sumTotal/(double)n*((double)xMax-(double)xMin)*(double)m;


    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
