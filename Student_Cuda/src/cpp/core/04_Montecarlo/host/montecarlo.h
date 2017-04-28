#pragma once
#include <curand_kernel.h>
#include "cudaTools.h"
#include "Grid.h"


/*----------------------------------------------------------------------*\
 |*			Declaration 					*|
 \*---------------------------------------------------------------------*/

/*--------------------------------------*\
 |*		Public			*|
 \*-------------------------------------*/

class Montecarlo
    {
	/*--------------------------------------*\
	|*		Constructor		*|
	 \*-------------------------------------*/

    public:

	/**
	 * update w by v1+v2
	 */
	Montecarlo(const Grid& grid, float xMin, float xMax, float m,int n);

	virtual ~Montecarlo(void);

	/*--------------------------------------*\
	|*		Methodes		*|
	 \*-------------------------------------*/

    public:

	void run();
	float piHat;

	float getResult();

	int getCountArrows();

	/*--------------------------------------*\
	|*		Attributs		*|
	 \*-------------------------------------*/

    private:

	// Inputs
	dim3 dg;
	dim3 db;
	int n;
	float xMin;
	float xMax;
	float m;

	int arrowsBelow;

	//Tools
	size_t sizeOctetSM;

	int* piHatDev;
	long nbArrows;
	curandState* tabDevGenerator;
	size_t sizeOctet;
	size_t randSizeOctet;

    };

/*----------------------------------------------------------------------*\
 |*			End	 					*|
 \*---------------------------------------------------------------------*/
