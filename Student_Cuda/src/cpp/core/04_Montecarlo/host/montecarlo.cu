#include "montecarlo.h"

#include <iostream>

#include "Device.h"
#include <curand_kernel.h>
using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

extern __global__ void montecarlo(curandState* tabDevGenerator, int* ptrDevGMRes, long n, float m);
extern __global__ void setup_kernel_rand(curandState* tabDevGenerator, int deviceId);


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

Montecarlo::Montecarlo(const Grid& grid, float xMin, float xMax, float m, int n) :
	 n(n), xMin(xMin), xMax(xMax), m(m)
    {
    this->sizeOctet = sizeof(float); // octet
    this->randSizeOctet = sizeof(curandState);


    // Grid
	{
	this->dg = grid.dg;
	this->db = grid.db;
	}

	int nbThread = grid.threadCounts();
	cout << "nb threads" << nbThread << endl;
	curandState* ptrDevGenerator=nullptr;

	Device::malloc(&this->piHatDev, sizeOctet);
	Device::memclear(this->piHatDev, sizeOctet);

	Device::malloc(&this->tabDevGenerator, randSizeOctet*nbThread);
	Device::memclear(this->tabDevGenerator, randSizeOctet*nbThread);
	this->nbArrows = n/nbThread;

	sizeOctetSM = grid.db.x * sizeof(float);

	//Device::memcpyHToD(this->piHatDev, this->piHat, sizeOctet);
    }

Montecarlo::~Montecarlo(void)
    {
    //MM (device free)
	{
	Device::free(piHatDev);

	Device::lastCudaError("AddVector MM (end deallocation)"); // temp debug, facultatif
	}
    }
/*--------------------------------------*\
 |*		Methode			*|
 \*-------------------------------------*/

void Montecarlo::run()
    {
    Device::lastCudaError("Slice (before)"); // temp debug

    setup_kernel_rand<<<dg,db>>>(this->tabDevGenerator, Device::getDeviceId());
    cout << "nb arrows" << nbArrows << endl;
    montecarlo<<<dg,db, sizeOctetSM>>>(this->tabDevGenerator, piHatDev, nbArrows, m); // assynchrone
    Device::lastCudaError("addVecteur (after)"); // temp debug

    //Device::synchronize(); // Temp,debug, only for printf in  GPU

    // MM (Device -> Host)
	{
	Device::memcpyDToH(&arrowsBelow, piHatDev, sizeOctet); // barriere synchronisation implicite
	}

	cout << "hello " << arrowsBelow << endl;

	//this->piHat = arrowsBelow/nbArrows*((xMax-xMin)*m);
	this->piHat = 2.0*(double)arrowsBelow/(double)n*(xMax-xMin)*m;
    }

float Montecarlo::getResult()
    {
	return piHat;
    }

int Montecarlo::getCountArrows()
    {
	return arrowsBelow;
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
