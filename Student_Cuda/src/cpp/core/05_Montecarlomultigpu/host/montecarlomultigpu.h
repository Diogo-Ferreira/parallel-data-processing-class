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

class Montecarlomultigpu
    {
	/*--------------------------------------*\
	|*		Constructor		*|
	 \*-------------------------------------*/

    public:

	/**
	 * update w by v1+v2
	 */
	Montecarlomultigpu(const Grid& grid, float xMin, float xMax, float m,int n);

	virtual ~Montecarlomultigpu(void);

	/*--------------------------------------*\
	|*		Methodes		*|
	 \*-------------------------------------*/

    public:

	void run();
	float piHat;

	/*--------------------------------------*\
	|*		Attributs		*|
	 \*-------------------------------------*/

    private:

	Grid grid;
	int n;
	float xMin;
	float xMax;
	float m;

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
