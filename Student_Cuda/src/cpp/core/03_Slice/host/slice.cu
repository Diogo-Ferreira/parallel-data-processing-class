#include "slice.h"

#include <iostream>

#include "Device.h"

using std::cout;
using std::endl;

/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Imported	 	*|
 \*-------------------------------------*/

extern __global__ void slice(int n, float* GM);

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

Slice::Slice(const Grid& grid, int n) :
	 n(n)
    {
    this->sizeOctet = sizeof(float); // octet



    // Grid
	{
	this->dg = grid.dg;
	this->db = grid.db;
	}
	Device::malloc(&this->piHatDev, sizeOctet);
	Device::memclear(this->piHatDev, sizeOctet);

	sizeOctetSM = grid.db.x * sizeof(float);

	//Device::memcpyHToD(this->piHatDev, this->piHat, sizeOctet);
    }

Slice::~Slice(void)
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

void Slice::run()
    {
    Device::lastCudaError("Slice (before)"); // temp debug
    slice<<<dg,db, sizeOctetSM>>>(n, piHatDev); // assynchrone
    Device::lastCudaError("addVecteur (after)"); // temp debug

    //Device::synchronize(); // Temp,debug, only for printf in  GPU

    // MM (Device -> Host)
	{
	Device::memcpyDToH(&piHat, piHatDev, sizeOctet); // barriere synchronisation implicite
	}
    }

/*--------------------------------------*\
 |*		Private			*|
 \*-------------------------------------*/

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
